; (c) Reminder  (1997)

rm 	equ 00001000b
r8	equ 0
r16 	equ 0
_seg	equ 0
mem	equ 2
mem16	equ 2
mem8	equ 2
imm32	equ 4
imm16	equ 2
imm8	equ 1
non	equ 0
feature equ 00001111b

_table:

;!!! 0
db rm+r8
db rm+r16
db r8+rm
db r16+rm	
db imm8
db imm16
db non
db non

db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non
db non			;feature

;!!! 10
db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non
db non

db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non
db non

;!!! 20
db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non			; es:
db non			; daa

db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non			; cs:
db non			; das

;!!! 30
db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non			; ss:
db non			; aaa

db rm+r8
db rm+r16
db r8+rm
db r16+rm
db imm8
db imm16
db non			; ds:
db non			; aas

;!!! 40
db non
db non
db non
db non
db non
db non
db non
db non

db non
db non
db non
db non
db non
db non
db non
db non

;!!! 50
db non
db non
db non
db non
db non
db non
db non
db non

db non
db non
db non
db non
db non
db non
db non
db non

;!!! 60
db non
db non
db non			; ???
db non  		; ???
db non
db non
db non
db non

db imm16
db rm+imm16
db imm8
db rm+imm8
db non
db non
db non
db non

;!!! 70
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8

db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8

;!!! 80
db rm+imm8
db rm+imm16
db rm+imm8	;???
db rm+imm16	;???
db rm+r8
db rm+r16
db r8+rm
db r16+rm

db rm+r8
db rm+r16
db r8+rm
db r16+rm
db rm+_seg
db r16+mem
db _seg+rm
db rm

;!!! 90
db non
db non
db non
db non
db non
db non
db non
db non

db non
db non
db imm32
db non
db non
db non
db non
db non

;!!! A0
db mem8
db mem16
db mem8
db mem16
db non
db non
db non
db non

db mem8
db mem16
db non
db non
db non
db non
db non
db non

;!!! B0
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8

db imm16
db imm16
db imm16
db imm16
db imm16
db imm16
db imm16
db imm16

;!!! C0
db rm+imm8
db rm+imm8
db imm16
db non
db r16+mem
db r16+mem
db rm+imm8
db rm+imm16

db imm16+imm8
db non
db imm16
db non
db non
db imm8
db non
db non

;!!! D0
db rm
db rm
db rm
db rm
db imm8
db imm8
db non			; setalc
db non

db rm
db rm
db rm
db rm
db rm
db rm
db rm
db rm

;!!! E0
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8
db imm8

db imm16
db imm16
db imm32
db imm8
db non
db non
db non
db non

;!!! F0
db non
db non			; feature
db non
db non
db non
db non
db rm+imm8
db rm+imm16

db non
db non
db non
db non
db non
db non
db rm
db rm
;-------
