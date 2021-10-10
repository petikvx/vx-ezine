
 ; input:  EBX=imagebase
 ; output: EAX=@[exitprocess]

find_exitprocess:       mov     ecx, [ebx+3Ch]
                        mov     ecx, [ebx+ecx].pe_importtablerva
__cycle:                mov     esi, [ebx+ecx+00h] ; import lookup
                        or      esi, esi
                        jz      __error
                        mov     eax, [ebx+ecx+10h] ; address table
                        add     eax, ebx
__scan:                 mov     edx, [ebx+esi]
                        or      edx, edx
                        jz      __break
                        mov     edi, [edx+ebx+2]
                        neg     edi
                        cmp     edi, -'tixE'
                        jne     __1
                        mov     edi, [edx+ebx+6]
                        not     edi
                        cmp     edi, not 'corP'
                        je      __found
__1:                    add     esi, 4
                        add     eax, 4
                        jmp     __scan
__break:                add     ecx, 14h
                        jmp     __cycle
__error:                xor     eax, eax
                        stc
                        ret
__found:                clc
                        ret
