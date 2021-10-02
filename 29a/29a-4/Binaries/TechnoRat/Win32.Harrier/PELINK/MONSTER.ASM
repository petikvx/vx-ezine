; ---------------------------------------------------------
; This is example file for "PE Linker" (Spawner) ;-)
;                             (C) 19-Jul-1997y by TechnoRat
; ---------------------------------------------------------
		.386
		.Model	Flat, StdCall
; ---------------------------------------------------------
Extrn		MessageBoxA:Proc
; ---------------------------------------------------------
		.Data
Db 'For Crazy TASM32+TLINK32, fuck!!!'
; ---------------------------------------------------------
		.Code
		Public	StubEntryLabel
		Public	StubImportPlace
		Public	ImagePlace
		Public	CurrentPlace
		Public	FixUpsPlace
		Public	FixUpsCounter
		Public	ImportPlace
		Public	ImportLength
		Public	BufferPlace
; ---------------------------------------------------------
Start:		PushA
		Call	Self
Self:		Pop	EBx
		Sub	EBx,(Offset Self - Offset Start)
		Db	0BEh
FixUpsPlace	Dd	?		; Mov ESi,xxxx
		Db	0B9h
FixUpsCounter	Dd	?		; Mov ECx,xxxx
Again:		Mov	EDi,[EBx+ESi]
		Add	[EBx+EDi],EBx
		Add	ESi,4
		Loop	Again
		Mov	Here,EBx

		Push	0			; Here my code
		Push	Offset MsgTitle
		Push	Offset MsgText1
		Push	0
		Call	MessageBoxA

		Mov	EAx,StubEntryLabel	; Jump to Dumbo ;-)
		Add	EAx,Here
		Sub	EAx,CurrentPlace
		Mov	JmpTo,EAx
		PopA
		Call	[JmpTo]

		PushA
		Push	0			; Here can be my code too
		Push	Offset MsgTitle
		Push	Offset MsgText2
		Push	0
		Call	MessageBoxA
		PopA
		Ret

; ---------------------------------------------------------
Here		Dd	?
MsgText1	Db	'I am alive!',0
MsgText2	Db	'I am still alive!',0
MsgTitle	Db	'Monster Notify.',0
JmpTo		Dd	?

; ---------------------------------------------------------
StubEntryLabel	Dd	?
ImagePlace	Dd	?
CurrentPlace	Dd	?
StubImportPlace	Dd	?
ImportPlace	Dd	?
ImportLength	Dd	?
BufferPlace	Dd	?

; ---------------------------------------------------------
		End	Start
; ---------------------------------------------------------
