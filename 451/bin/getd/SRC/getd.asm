

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
;
;  GETD v 1.0
;
; Getd( VOID* PEBufer,
;        VOID* *(Malloc(DWORD cnt)),
;        VOID  *(Free(VOID* ptr)),
;        DWORD *(Dasm(VOID* code,CMD* out,VOID* table))
;        VOID* DasmTable);
;
; Out:   EAX = bufer with addres list (r/w) & region map
;        EAX = 0 ,if error occured
;
; (c) 451 2003
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

@dgd                    equ             <+4*8+4>

__pebufer               equ             4 ptr[ebp    @dgd]
__malloc                equ             4 ptr[ebp+4  @dgd]
__free                  equ             4 ptr[ebp+8  @dgd]
__dasm                  equ             4 ptr[ebp+12 @dgd]
__dtables               equ             4 ptr[ebp+16 @dgd]

;----------------------------------------------------------------------------

__tfixup                equ             4 ptr[ebp-4]
__delta                 equ             4 ptr[ebp-8]
__base                  equ             4 ptr[ebp-12]
__imagebase             equ             4 ptr[ebp-16]
__importRVA             equ             4 ptr[ebp-20]
__code                  equ             4 ptr[ebp-24]


;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께
getd:
;                int 3

                pusha
                mov ebp,esp
                sub esp,24

                mov edx,__pebufer

                cmp 2 ptr[edx],'ZM'                             ; EXE?
                jne @@getd_error                                ;

                cmp 2 ptr [edx.mz_tablOff],40h                  ; New exe?
                jne @@getd_error                                ;

                mov ebx,[edx.mz_peOffset]                       ;
                add ebx,edx                                     ; EBX = header

                cmp 4 ptr[ebx],'EP'                             ; PE?
                jne @@getd_error                                ;

;------------------------------------------------------------------------------

                mov eax,[ebx.pe_fixupRVA]                       ; Fixups check
                or eax,eax                                      ;
                jz @@getd_error

                mov eax,[ebx.pe_importRVA]                      ; Import check
                or eax,eax                                      ;
                jz @@getd_error                                 ;
                mov __importRVA,eax

                mov eax,[ebx.pe_codeRVA]                        ; Code check
                or eax,eax                                      ;
                jz @@getd_error

                push 4 ptr[ebx.pe_imagebase]
                pop __imagebase

;------------------------------------------------------------------------------

                push 4 ptr [ebx.pe_imagesize]                   ; Get image
                call __malloc                                   ; bufer
                add esp,4                                       ;
                or eax,eax
                jz @@getd_error

                mov ecx,[ebx.pe_headersize]                     ;
                mov esi,edx                                     ; Load headers
                mov edi,eax                                     ;
                                                                ;
                push esi                                        ;
                rep movsb                                       ;
                pop esi                                         ;

                xchg edx,eax                                    ; EDX =
                                                                ;  New Image
                mov ebx,[edx.mz_peOffset]                       ; EBX =
                add ebx,edx                                     ;  New pe-header
                mov __base,edx

;같 Load Objects 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

                movzx eax,[ebx.pe_NThsize]                      ;
                lea eax,[eax+ebx+18h]                           ; EAX = Obj table

                mov ecx,[eax.pe_Obj_vSize]                      ;
                add ecx,[ebx.pe_codeRVA]                        ; Code bound
                mov __code,ecx                                  ;


                movzx ecx,[ebx.pe_objcnt]                       ; ECX = Obj cnt

@@image_load:

                mov edi,[eax.pe_Obj_RVA]                        ; EDI = RVA

                cmp edi,[ebx.pe_codeRVA]                        ; Sections before
                jb @@getd_error_free                            ; code?
                                                                ;
                pusha
                add edi,edx                                     ;
                add esi,[eax.pe_Obj_offset]                     ; ESI = Obj offset
                mov ecx,[eax.pe_Obj_pSize]                      ; ECX = Obj size
                rep movsb                                       ;
                popa

                dec ecx                                         ;
                jz @@fixup_view                                 ; Last?

                add edi,[eax.pe_Obj_vSize]                      ; Check bounds
                cmp edi,[(eax+40).pe_Obj_RVA]                   ;
                ja @@getd_error_free                            ;

                add eax,40
                jmp @@image_load

;같 View Fixups 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같�
@@fixup_view:

                mov esi,[ebx.pe_fixupRVA]                       ; ESI = Fixups
                add esi,edx                                     ;

                mov ecx,[ebx.pe_fixupSize]                      ; ECX = Fixup's
                cmp ecx,8                                       ;        size
                jbe @@getd_error_free

                lea eax,[ecx*2]                                 ;
                push eax                                        ; Temp fixups
                call __malloc                                   ; bufer
                add esp,4                                       ;

                or eax,eax
                jz @@getd_error_free

                mov __tfixup,eax                                ;
                xchg edi,eax                                    ; EDI = out table

                push ebx
                push edi

;굇 Build data table based on fixups 굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇

@@fixup_obj:

                lodsd                                           ; EDX =
                xchg ebx,eax                                    ;   Page
                lodsd                                           ; EAX = Block
                                                                ;       Size
                sub ecx,eax
                sub eax,8
                shr eax,1

                push ecx                                        ; Fixups size
@@fixup_blk:
                push eax

                lodsw                                           ; AX = type+adress

                ror eax,4
                or ah,ah
                jz @@fixup_blk_next

                rol eax,4                                       ; EAX = fixup delta
                and ah,0Fh                                      ;
                add eax,ebx                                     ; + Page

                cmp eax,__code                                  ; Not code reference?
                ja @@fixup_blk_next                             ;

;----------------------------------------------------------------------------
                mov ecx,__imagebase

                mov eax,[edx+eax]                               ; Get data RVA
                sub eax,ecx                                     ; - imagebase

                cmp eax,__code                                  ; To code?
                jb @@fixup_blk_next                             ;

;같 Check for import reference 같같같같같같같같같같같같같같같같같같같같같같같
;EAX = data RVA

                pusha

                mov ecx,__importRVA
                add ecx,edx

                xchg ebx,eax

@@__DLL:
                mov esi,[ecx.import_lookupRVA]                  ; Lookup tbl
                mov edi,[ecx.import_adrRVA]                     ; Address tbl

                or edi,edi                                      ; Last DLL?
                jz @@__DLL_end                                  ;

                or esi,esi                                      ; 2nd import
                jnz @@__function_pre                            ; type?

                mov esi,edi                                     ; Lookup = address
;------------------------------------------------------------------------------
@@__function_pre:

                add esi,edx

;------------------------------------------------------------------------------
@@__function:
                lodsd
                or eax,eax
                jz @@__function_end

                cmp edi,ebx                                     ; To import?
                je @@__ierror                                   ;

                add edi,4
                jmp @@__function
;-----------------------------------------------------------------------------
@@__function_end:

                add ecx,20
                jmp @@__DLL
@@__DLL_end:
                clc
                jmp @@__iend
@@__ierror:
                stc
@@__iend:
                popa
                jc @@fixup_blk_next

;------------------------------------------------------------------------------

                add eax,ecx                                     ; + imagebase

                push edi
                mov ecx,edi
                mov edi,__tfixup
                sub ecx,edi
                shr ecx,2
                repnz scasd
                cmp [edi-4],eax
                pop edi

                jz @@fixup_blk_next
                or ecx,ecx
                jnz @@fixup_blk_next

;------------------------------------------------------------------------------
                stosd

@@fixup_blk_next:

                pop eax

                dec eax
                jnz @@fixup_blk

                pop ecx

                or ecx,ecx
                jnz @@fixup_obj


;� Disassembler routines 께께께께께께께께께께께께께께께께께께께께께께께께께께께

                mov ecx,edi                                     ;
                pop esi                                         ; ESI = Fix table
                sub ecx,esi                                     ; ECX = Table size
                pop ebx

                mov edx,[ebx.pe_RVA]                            ; EDX =RVA

                mov eax,[ebx.pe_codeSize]                       ;
                shl eax,3                                       ; (codesize/4)*16*2
                push eax                                        ;
                call __malloc                                   ; Get out bufer
                add esp,4                                       ;
                or eax,eax
                jz @@getd_error_free
                xchg eax,edi                                    ; EDI = out table

                shr ecx,2                                       ; ECX = elem count
                call shsort                                     ; Sort list

                mov eax,[ebx.pe_codeRVA]                        ;
                add eax,[ebx.pe_codeSize]                       ; EAX = seemed
                sub eax,[ebx.pe_RVA]                            ;  code size

                push edi

                sub esp,SIZE cmd                                ;
                mov ebx,esp                                     ; EBX = Out
                scasd

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

@@data_dasm:

                ; ESI = fixup ripped table
                push eax
                push esi
                push ecx
                push ebx

                push edx

                add edx,__base
                push __dtables                                  ; Diasessembler Tables
                push ebx                                        ; Out bufer
                push edx                                        ; Code
                call __dasm                                     ; call disassmbler
                add esp,4*3

                pop edx

                mov __delta,eax
                inc eax
                jz @@dd_error

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

                test [ebx.lc_flags],LF_MEM                      ; Memory using?
                jz @@dd_next                                    ;

                test [ebx.lc_flags],LF_REG1+LF_BASE+LF_INDEX
                jnz @@dd_next

                cmp [ebx.lc_soffset],4                          ; Offset size=4?
                jne @@dd_next                                   ;

@@dd_chck:
                lodsd
                cmp eax,[ebx.lc_offset]                         ; fixup = offset?
                je @@dd_d_bit
                loop @@dd_chck
                jmp @@dd_next
@@dd_d_bit:

                stosd                                           ; dRVA
                mov eax,edx                                     ; cRVA
                add eax,__imagebase                             ;
                stosd                                           ;
                mov eax,__delta                                 ; cSize
                stosd                                           ;

                xor eax,eax
                inc eax


                mov CL,[ebx.lc_mask1]
                mov ebx,[ebx.lc_flags]

                cmp CL,08Fh                                     ; POP common
                je @@dd_rw4                                     ;

;------------------------------------------------------------------------------

                cmp CL,0A0h                                     ; MOV [...],eax
                je @@dd_do                                      ;

;------------------------------------------------------------------------------

                cmp CL,0C6h                                     ; MOV [...],im
                je @@dd_write                                   ;

;------------------------------------------------------------------------------
                cmp CL,088h                                     ; MOV common
                jne @@dd_read
@@dd_do:
                test bx,LF_SDV                                  ;
                jnz @@dd_read                                   ; D = 1 ?

;------------------------------------------------------------------------------
@@dd_write:

                test bx,LF_WV                                   ; W test
                jz @@dd_rw1                                     ;

@@dd_rwop:
                test bl,LF_POP                                  ; operand prefix?
                jz @@dd_rw4                                     ;

@@dd_rw2:
                mov AH,2
                jmp @@dd_stos
@@dd_rw4:
                mov AH,4                                        ; Data size(4)
                jmp @@dd_stos                                   ;
@@dd_rw1:
                mov AH,1                                        ; Data size(1)

;------------------------------------------------------------------------------
@@dd_stos:
                stosd                                           ; cdType
                jmp @@dd_next

;------------------------------------------------------------------------------
@@dd_read:
                xor eax,eax                                     ; type = 0

                test bx,LF_S                                    ; S?
                jz @@dd_read_w                                  ;

                test bx,LF_SDV                                  ;
                jnz @@dd_rw4                                    ; S = 1?
@@dd_read_w:
                test bx,LF_W                                    ; W?
                jnz @@dd_write                                  ;

                jmp @@dd_rwop                                   ; op prefix?


;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
@@dd_next:
                add edx,__delta                                 ; + cSize

                pop ebx
                pop ecx
                pop esi
                pop eax

                sub eax,__delta
                jns @@data_dasm

                jmp @@dd_exit

@@dd_error:
                add esp,4*4
@@dd_exit:
;굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇

                add esp,SIZE cmd

                mov eax,edi
                mov edx,edi
                pop edi
                sub eax,edi
                sub eax,4

                shr eax,4
                jz @@getd_error_free

                dec ecx
                jz @@getd_dend

                push edi
                stosd                                           ; References count

;께 Regions 께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께�

                mov edi,edx

                push edi
                scasd

                lodsd
                xchg eax,ebx
                mov edx,ebx
@@seek_r:
                push ecx

                lodsd
                lea ecx,[edx+4]
                cmp eax,ecx
                je @@seek_r_cnt1

                mov ecx,edx
                sub ecx,ebx
                shr ecx,2
                jz @@seek1

                dec ecx
                jz @@seek1
                inc ecx
                inc ecx

                push eax                                        ;
                xchg eax,ebx                                    ;
                stosd                                           ;
                                                                ; Write begin &
                xchg eax,ecx                                    ; cnt
                stosd                                           ;
                pop eax                                         ;

@@seek1:
                mov ebx,eax                                     ; EBX = first

@@seek_r_cnt1:
                mov edx,eax                                     ; EDX = last

                pop ecx
                loop @@seek_r

                mov eax,edi                                     ; Write reigns
                pop edi                                         ; count
                sub eax,edi                                     ;
                shr eax,3                                       ;
                dec eax                                         ;
                stosd                                           ;

                pop edi
;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

@@getd_dend:

                push esi                                        ; Seemed fixups
                call __free                                       ;
                add esp,4

;께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께께

@@getd_free:
                push __base                                     ;
                call __free                                     ; Pe Image
                add esp,4                                       ;

@@getd_exit:
                add esp,24
                mov [esp._eax],edi
                popa
                ret

@@getd_error:
                xor edi,edi
                jmp @@getd_exit

@@getd_error_free:
                xor edi,edi
                jmp @@getd_free


include src\sort.inc

