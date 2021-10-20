; ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
; ณ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ณ
; ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

; (c) 1998-2000
;
; Lord Julus' S.A.R. VXTASY release

;ฤฤฤฤฤฤฤฤฤฤด PROGRAM TITLE: Smart Article Reader รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

title "Vx-tasy #1"			   ; program header
.286					   ; 286 style
.287					   ; coprocessor needed !
.model huge				   ; tiny model
jumps					   ; solve jumps
masm51					   ;
quirks					   ;
					   ;
musicon = 1				   ;

;ฤฤฤฤฤฤฤฤฤฤด STACK SEGMENT รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

STACK_SEGMENT segment para stack	   ; STACK segment
	      db 400h dup (0)		   ;
STACK_SEGMENT ends			   ;

;ฤฤฤฤฤฤฤฤฤฤด DATA SEGMENT รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

DATA_SEGMENT segment word 'data'	   ; DATA segment
include misc\windata.inc		   ;
include misc\butdata.inc		   ;
include gfc_data.inc			   ;
include gmc_data.inc			   ;
intro_text label			   ;
db 13, 10				   ;
db "ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ",13,10
db "		Vx-tasy Issue #1 - The Win32 Document (C) 1999		    ",13,10
db "ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ",13,10
db "		Smart Article Reader - by  Lord Julus (C) 1999		    ",13,10
db "ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ",13,10
					   ;
db 13, 10, '$'				   ;
					   ;
Parray	DB   300h*2 DUP (0)		   ; Array to hold 2 entire palettes
					   ;
DATA_SEGMENT ends			   ;
					   ;
					   ;
;ฤฤฤฤฤฤฤฤฤฤด DATA SEGMENT รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
					   ;
if musicon				   ;
SEGMENT 	modo			   ; adlib track (RAD)
LABEL		module	byte		   ;
		include misc\module.inc    ;
ENDS					   ;
endif					   ;
					   ;
include surprise\surprise.dat		   ;
					   ;
;ฤฤฤฤฤฤฤฤฤฤด CODE SEGMENT รฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

CODE_SEGMENT segment word 'code'
	     assume CS:CODE_SEGMENT, DS:DATA_SEGMENT, SS:STACK_SEGMENT
					   ;
start:					   ; entry point
	jmp realstart			   ;
					   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copyright db "	þ     Vx-tasy issue no. 1 (July 1999)	    þ  "	   ;
author	  db "	þ		Lord Julus (C)		    þ  "	   ;
version_  db "	þ		    V.1.0		    þ  "	   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
					   ;
realstart:				   ;
					   ;
	mov ax, DATA_SEGMENT		   ;
	mov ds, ax			   ;
	lea dx, intro_text		   ;
	mov ah, 09h			   ;
	int 21h 			   ;
	call parse_command_line 	   ;
	push ds 			   ;
	pop es				   ;
					   ;
	call gmc_start			   ;
	mov ax, 4c00h			   ;
	int 21h 			   ;
					   ;
include gfc_code.inc			   ;
include gmc_code.inc			   ;
include misc\wincode.inc		   ;
include misc\butcode.inc		   ;
include misc\keywait.inc		   ;
include misc\fade.inc			   ;
include misc\cmdline.inc		   ;
if musicon				   ;
include misc\music.inc			   ;
include misc\player.inc 		   ;
endif					   ;
					   ;
include surprise\surprise.cod		   ;
include misc\bmp.inc			   ;
CODE_SEGMENT ends			   ; code end
	     end start			   ;
