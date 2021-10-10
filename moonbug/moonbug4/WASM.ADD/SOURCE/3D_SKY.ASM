;This program shows how to make a 3d-sky in ASM.                (C) 1996 J/SOFT.
;System requirements: CPU 8086/88, 128KB RAM, CGA. (works fine on XT :)

num     equ 100         ;Number of stars.
        mov ax,6
        int 10h

        mov cx,num              ;Y array - bytes
set_y   call rnd                ;X array - words
        cmp al,200
        jnc set_y
        mov bx,cx
        mov [bx+offset _y],al
        add bx,bx
        call rnd
        xor ah,ah
        mov [bx+offset _x],ax
        loop set_y

main    call pset
        call halt               ;Wait for retrace.
        call pset

        mov cx,num
c_add   mov bx,cx
        add bx,bx
        mov ax,cx
        sar ax
        sar ax
        inc ax
        add ax,[bx+offset _x]
        cmp ax,640
        jc c_cnt
        sub ax,640
        push ax
        push bx
        mov bx,cx
        mov al,[bx+offset _y]
        inc al
        cmp al,200
        jnz y_add
        xor al,al
y_add   mov [bx+offset _y],al
        pop bx
        pop ax

c_cnt   mov [bx+offset _x],ax
        loop c_add

        in al,60h
        cmp al,1
        jnz main
        mov ax,3
        int 10h         ;Restore normal text mode
        int 20h         ;and exit to DOS.

_x      ds 2*(num+1)
_y      ds num+1
r1      db 5
r2      db 90
r3      db 37
rnd     mov ah,[r1]
        mov al,[r2]
        mov [r1],al
        add ah,al
        mov al,[r3]
        mov [r2],al
        add al,ah
        rol al
        mov [r3],al
        retn
halt    mov dx,3dah
vrt     in al,dx
        test al,8
        jnz vrt
novrt   in al,dx
        test al,8
        jz novrt
        retn

pset    mov cx,num      ;al=color
pset1   push cx
        ;mov al,cl
        ;and al,3
        ;or al,128
        mov AL,128+3
        mov bx,cx
        mov dl,[bx+offset _y]
        xor dh,dh               ;dx=y
        add bx,bx
        mov cx,[bx+offset _x]   ;cx=x
        mov ah,0ch
        int 10h
        pop cx
        loop pset1
        retn