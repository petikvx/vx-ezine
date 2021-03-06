; 旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
; � (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code �
; 읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

; (c) 1998-2000
;
; Lord Julus' S.A.R. VXTASY release

;컴컴컴컴컴� PROGRAM TITLE: Smart Article Reader 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴

title "Vx-tasy #1"			   ; program header
.286					   ; 286 style
.287					   ; coprocessor needed !
.model huge				   ; tiny model
jumps					   ; solve jumps
masm51					   ;
quirks					   ;
					   ;
musicon = 1				   ;

;컴컴컴컴컴� STACK SEGMENT 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

STACK_SEGMENT segment para stack	   ; STACK segment
	      db 400h dup (0)		   ;
STACK_SEGMENT ends			   ;

;컴컴컴컴컴� DATA SEGMENT 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

DATA_SEGMENT segment word 'data'	   ; DATA segment
include misc\windata.inc		   ;
include misc\butdata.inc		   ;
include gfc_data.inc			   ;
include gmc_data.inc			   ;
intro_text label			   ;
db 13, 10				   ;
db "袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴",13,10
db "		Vx-tasy Issue #1 - The Win32 Document (C) 1999		    ",13,10
db "袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴",13,10
db "		Smart Article Reader - by  Lord Julus (C) 1999		    ",13,10
db "袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴袴",13,10
					   ;
db 13, 10, '$'				   ;
					   ;
Parray	DB   300h*2 DUP (0)		   ; Array to hold 2 entire palettes
					   ;
DATA_SEGMENT ends			   ;
					   ;
					   ;
;컴컴컴컴컴� DATA SEGMENT 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
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
;컴컴컴컴컴� CODE SEGMENT 쳐컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴

CODE_SEGMENT segment word 'code'
	     assume CS:CODE_SEGMENT, DS:DATA_SEGMENT, SS:STACK_SEGMENT
					   ;
start:					   ; entry point
	jmp realstart			   ;
					   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
copyright db "	�     Vx-tasy issue no. 1 (July 1999)	    �  "	   ;
author	  db "	�		Lord Julus (C)		    �  "	   ;
version_  db "	�		    V.1.0		    �  "	   ;
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
