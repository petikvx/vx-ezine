; ---------------------------------------------------------
; This is example file for "PE Linker" (Installer)
;                             (C) 19-Jul-1997y by TechnoRat
; ---------------------------------------------------------
		.386
		.Model	Flat,StdCall
; ---------------------------------------------------------
Extrn		MessageBoxA:Proc
; ---------------------------------------------------------
		.Data
MsgText		Db	'I was run Ok!',0
MsgTitle	Db	'Dumbo.',0
; ---------------------------------------------------------
		.Code
Start:		Push	0
		Push	Offset MsgTitle
		Push	Offset MsgText
		Push	0
		Call	MessageBoxA
		Ret
; ---------------------------------------------------------
		End	Start
; ---------------------------------------------------------
