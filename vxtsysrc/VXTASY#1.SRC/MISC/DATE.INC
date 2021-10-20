; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
; ³ (c) Lord Julus - 2000		 Vxtasy #1 - Magazine source code ³
; ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


commandline db 256 dup (0)
parameters  db '/h', 0
	    db '/H', 0
	    db '-h', 0
	    db '-H', 0
	    db '/nosound', 0
	    db '-nosound', 0
	    db 0FEh

help_text label

db 13, 10
db 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',13,10
db 'Vx-tasy isuue #1 - Smart Article Reader (C) by Lord Julus 1999	    ', 13,10
db 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',13,10
db 'Command line options:', 13,10
db '		  /h	    - This help screen', 13,10
db '		  /nosound  - Disable music', 13, 10, 13,10
db 'Press F1 in program for more info', 13, 10
db 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
db 13, 10, '$'

no_sound    db 0

;____________________________________________________________________________|
cpu_type	dw 0
;-----------------------------------------------------------------------------
vga			db 0
coloana_ecran		db 0
linie_ecran		db 0
pagina_video		db 0
atribut_curent		db 0
mod_video_initial	db 0
store_ax		dw 0
was_in_buttons		dw 0
;-----------------------------------------------------------------------------
mouse		db 0
;-----------------------------------------------------------------------------
font		db 0		;spune daca am incarcat fontul sau nu
temp_1	db 0
temp_2	db 0
;-----------------------------------------------------------------------------
;cursor grafic de mouse |
;------------------------
mouse_orizontal db 0
mouse_vertical	db 0
flag		db 0	;spune daca este alta coloana sau linie
flag2		db 0
store_vidmode_bios	db 0
save_cx 	dw 0
save_dx 	dw 0
sus		dw 0
jos		dw 0
adresa		dw 0
;------------
tabela	label
I=0
REPT 25
	dw I*160
I=I+1
ENDM
;------------


cursor_original dw 0,40h,60h,70h,78h,7ch,7eh,7ch,78h,5ch,1ch,0eh,6,6,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

		dw 0ff1fh,0ff1fh,0ff0fh,0ff07h,0ff03h,0ff01h	;masca
		dw 0ff00h,0ff01h,0ff01h,0ff01h,0ff01h,0ffe0h
		dw 0fff0h,0fff0h,0fff8h,0ffffh

		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh

punere_curenta	dw 0,40h,60h,70h,78h,7ch,7eh,7ch,78h,5ch,1ch,0eh,6,6,0,0
		dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

		dw 0ff1fh,0ff1fh,0ff0fh,0ff07h,0ff03h,0ff01h	;masca
		dw 0ff00h,0ff01h,0ff01h,0ff01h,0ff01h,0ffe0h
		dw 0fff0h,0fff0h,0fff8h,0ffffh

		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh
		dw 0ffffh,0ffffh,0ffffh,0ffffh

