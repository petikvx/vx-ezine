;Как определить где находиться COMMAND.COM и программные пути?
;Эта программка - ответ.

.model tiny
.code
    org 100h
start:
    mov cx,4f43h
    mov bx,534dh
    mov bp,4
    call search
    call print
    mov cx,4150h
    mov bx,4854h
    mov bp,1
    call search
    jmp short print
search:
    mov ds,cs:[2ch]
    xor si,si
    inc si
search_1:
    dec si
    lodsw
    cmp ax,cx
    jne search_1
    lodsw
    cmp ax,bx
    jne search_1
    add si,bp
    ret
print:
    mov ah,2
    mov dl,0dh
    int 21h
    mov dl,0ah
    int 21h
print_1:
    lodsb
    cmp al,';'
    je short print
    or al,al
    je short exit_print
    mov ah,2
    mov dl,al
    int 21h
    jmp short print_1
exit_print:
    ret
end start