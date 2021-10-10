;
;=============================================================================
;LZ32Compression subroutines.
;All rights may be reserved by SexyDufus
;Disassembled by IDA v3.xx with little help of Green Monster ;-)
;==============================================================================
;
;Interface:
;int   lz_compresss(char *inbuf, char *outbuf, int size, char *buf)
;
;-----------------------------------------------------------------------------
;Сжимает size байтов из inbuf, записывая полученное в outbuf.
;Для словаря используется внешний буффер (buf)
;Возвращает размер сжатого.
;=============================================================================
;

;Непонятки:
;char   = буква = байт = то, что грузится из inbuf
;symbol = символ = переменное количество бит (9-12), пишется в outbuf


;---------------------------------------------------
;Стуктура локальных переменных (одна на все функции)

ProcFrame       struc                      ;
FirstSym        dw ?                       ;Первый символ
Link            dw ?                       ;Связка
DictBound       dw ?                       ;Текущая граница словаря
BitsPerSym      dw ?                       ;Битовая размерность вывода
                                           ;(увеличивается по мере накопления
                                           ; словаря)
NextInChar      db ?                       ;Следующая буква в потоке ввода
field_9         db ?                       ;  Фигня
field_A         db ?                       ;  Еще одна
field_B         db ?                       ;  Третья
                                           ;Вывод: NextChar был DWORD'ом ;-)
                                           ;
OutBufPos       dd ?                       ;Текущая позиция вывода
InBufRelPos     dd ?                       ;Текущая позиция ввода
RetEIP          dd ?                       ;Адрес возврата lz_compress
                                           ;
                                           ;Аргументы:
InBuf           dd ?                       ;Входной буффер
OutBuf          dd ?                       ;Выходной буффер
SuxxSize        dd ?                       ;Размер данных во входном буффере
Malloced        dd ?                       ;Кусок памяти для словаря
ProcFrame       ends                       ;
                                           ;
;-------------------------------------------
;Структура словарной записи                ;
;                                          ;
TableItem       struc                      ;
Sym             dw ?                       ;Символ
NextSym         dw ?                       ;Следующий символ
NextChar        db ?                       ;Следующая буква в цепочке
TableItem       ends                       ;
                                           ;
;=============================================================================
; Основная функция
;=============================================================================
lz_compress     proc near                  ;
                sub     eax, eax           ;
                push    eax                ;Обнуляются поля структуры
                push    eax                ;
                push    eax                ;
                push    eax                ;
                push    eax                ;
                mov     ebp, esp           ;EBP -> ProcFrame
                                           ;
                call    lz_init            ;Сброс словаря
;                                          ;
                sub     eax, eax           ;
                inc     ah                 ;Символ 100h = "сбросить словарь"
                call    Save_And_Step      ;Вывести в выходной поток
                                           ;
                call    Get_Byte           ;Получить первый байт.
                                           ;
@@compess_cycle:                           ;AL = буква
                sub     ah, ah             ;
                                           ;AX = символ
@@get_chain:                               ;Ищем уникальную цепочку букв
                mov     [ebp+ProcFrame.FirstSym], ax
                call    Get_Byte           ;
                jb      short lzc_exit     ;
                                           ;
                mov     [ebp+ProcFrame.NextInChar], al
                movzx   ebx, [ebp+ProcFrame.FirstSym]
                call    Search_Table       ;
                jnb     short @@get_chain  ;
                                           ;Цепочка найдена
                call    Set_Char_Link      ;
                                           ;Выводим символ
                push    ebx                ;
                movzx   eax, [ebp+ProcFrame.FirstSym]
                call    Save_And_Step      ;
                pop     ebx                ;
                mov     al, [ebp+ProcFrame.NextInChar]
                cmp     bx, [ebp+ProcFrame.DictBound]
                jl      short @@compess_cycle
                                           ;
                cmp     [ebp+ProcFrame.BitsPerSym], 0Ch  ;Предел разрядности?
                jl      short next_bit     ;
                                           ;
                sub     eax, eax           ;
                inc     ah                 ; 100h - переинициализировать словарь
                call    Save_And_Step      ;
                call    lz_init            ; И сами переинициализируем
                mov     al, [ebp+ProcFrame.NextInChar]
                jmp     short @@compess_cycle
; ───────────────────────────────────────────────────────────────────────────
                                           ;
next_bit:                                  ;
                inc     [ebp+ProcFrame.BitsPerSym]   ;Увеличиваем разрядность
                shl     [ebp+ProcFrame.DictBound], 1 ;Увеличиваем словарь
                jmp     short @@compess_cycle
; ───────────────────────────────────────────────────────────────────────────
                                           ;
lzc_exit:                                  ;
                movzx   eax, [ebp+ProcFrame.FirstSym]
                call    Save_And_Step      ;
                mov     eax, 101h          ; 101h - конецъ цепочки
                call    Save_And_Step      ;
                xchg    eax, edi           ;
                sub     eax, [ebp+ProcFrame.OutBuf]  ;EAX = end-start = size
                add     esp, 14h           ;
                retn    10h                ;
lz_compress     endp                       ;
                                           ;
;-----------------------------------------------------------------------------
;Переинициализирует словарь
;-----------------------------------------------------------------------------
lz_init         proc near                  ;
                pusha                      ;
                mov     [ebp+ProcFrame.BitsPerSym], 9     ;9 бит на символ вывода
                mov     [ebp+ProcFrame.DictBound], 200h   ;512 символов словарь
                sub     eax, eax           ;
                dec     eax                ;
                                           ;Очистка словаря
                mov     ecx, 280h          ; В оригинале почему-то так...
                                           ;
                mov     edi, [ebp+ProcFrame.Malloced]
                repe stosw                 ;STOSW - это вообще круто ;-)
                                           ;
                mov     [ebp+ProcFrame.Link], 102h ;Первый свободный символ
                                           ;
                                           ;(00-FF) - простые символы-буквы
                                           ;          (элементарный словарь)
                                           ; 100    - символ сброса словаря
                                           ; 101    - конец данных
                                           ;102-... - свободные символы
                                           ;
                popa                       ;
                retn                       ;
lz_init         endp                       ;
                                           ;
;------------------------------------------------------------------------------------
;Записывает символ ТЕКУЩЕЙ разрядности (9-...бит) в выходной поток из EAX
;------------------------------------------------------------------------------------
Save_And_Step   proc near                  ;
                push    eax                ;
                mov     eax, [ebp+ProcFrame.OutBufPos] ;EAX -> бит в выходном буффере
                movzx   ecx, word ptr [ebp.ProcFrame.BitsPerSym] ;ECX = разрядность
                add     [ebp+ProcFrame.OutBufPos], ecx ;Step
                                           ;Считаем номер бита
                mov     ecx, 8             ;
                sub     edx, edx           ;
                div     ecx                ; EDX = OutBufPos mod 8
                add     eax, [ebp+ProcFrame.OutBuf]
                xchg    eax, edi           ;EDI -> Куда писать
                pop     eax                ;
                                           ;
                mov     ecx, edx           ;
                sub     edx, edx           ;
                jcxz    save_3bytes        ;Переход, если ровно на границе бита
                                           ;
                shl     eax, cl            ;
                or      al, [edi]          ;
                                           ;
save_3bytes:                               ;
                stosw                      ;
                shr     eax, 10h           ;
                stosb                      ;
                retn                       ;
Save_And_Step   endp                       ;
                                           ;
;-----------------------------------------------------------------------------
;Читает букву из входного потока в AL.
;-----------------------------------------------------------------------------
Get_Byte        proc near                  ;
                mov     esi, [ebp+ProcFrame.InBuf]       ; ESI -> InBuf
                mov     edi, [ebp+ProcFrame.InBufRelPos] ; EDI -> RelInBufPos
                cmp     edi, [ebp+ProcFrame.SuxxSize]    ; Уже кончилось?
                jnb     short byaka                      ;
;                                                        ;
                mov     al, [esi+edi]                    ;Читаем
                inc     [ebp+ProcFrame.InBufRelPos]      ;
                clc                                      ;
                retn                                     ;
    byaka:                                               ;
                stc                                      ;
                retn                                     ;
Get_Byte        endp                                     ;
                                                         ;
;-----------------------------------------------------------------------------
;Поиск по словарю
;-----------------------------------------------------------------------------
Search_Table    proc near
                call    Calc_Sym_Pos                ;ESI -> TableItem
                sub     edi, edi                    ;EDI=0=флаг success'а
                cmp     [esi+TableItem.Sym], 0FFFFh ;Есь символ?
                jz      short not_found             ;
                                                    ;
                inc     edi                         ;взвели флаг
                movzx   ebx, [esi+TableItem.Sym]    ;EBX=символ
                                                    ;
scan_chain:                                         ;
                call    Calc_Sym_Pos                ;
                cmp     [esi+TableItem.NextChar], al  ;Есть связь?
                jnz     short next_char             ;
                                                    ;
                clc                                 ;Уже есть?
                movzx   eax, bx                     ;EAX=символ цепочки
                retn                                ;
; ───────────────────────────────────────────────────────────────────────────
                                                    ;
next_char:                                          ;
                cmp     [esi+TableItem.NextSym], 0FFFFh  ;Конецъ цепочки?
                jz      short not_found             ;
                movzx   ebx, [esi+TableItem.NextSym] ;EBX=следующий символ
                jmp     short scan_chain            ;
; ───────────────────────────────────────────────────────────────────────────
                                                    ;
not_found:                                          ;
                stc                                 ;Нет такой цепочки
                retn                                ;
Search_Table    endp                                ;
                                                    ;
;-----------------------------------------------------------------------------
;Расчитывает адрес TableItem в словаре по символу в EBX
;-----------------------------------------------------------------------------
Calc_Sym_Pos    proc near                           ;
                lea     esi, [ebx+ebx*4]            ; ESI = EBX*sizeof(TableItem)
                add     esi, [ebp+ProcFrame.Malloced] ;ESI += смещ. буфера
                retn                                ;
Calc_Sym_Pos    endp                                ;
                                                    ;
;-----------------------------------------------------------------------------
;Связка буквы и символа в словаре
;-----------------------------------------------------------------------------
Set_Char_Link   proc near                           ;
                movzx   ebx, [ebp+ProcFrame.Link]   ;
                cmp     edi, 0                      ; EDI=Search_Table status
                jz      short set_link              ;
                mov     [esi.TableItem.NextSym], bx ;
                jmp     short test_sym              ;
; ───────────────────────────────────────────────────────────────────────────
                                                    ;
set_link:                                           ;
                mov     [esi.TableItem.Sym], bx     ;Прописывается символ
                                                    ;
test_sym:                                           ;
                cmp     bx, 1000h                   ;
                jz      short scl_exit              ;
                                                    ;
                call    Calc_Sym_Pos                ; Забить FFFF'ами
                mov     word ptr [esi.TableItem.Sym], 0FFFFh
                mov     word ptr [esi.TableItem.NextSym], 0FFFFh
                mov     [esi.TableItem.NextChar], al
                inc     [ebp+ProcFrame.Link]        ;
                                                    ;
scl_exit:                                           ;
                retn                                ;
Set_Char_Link   endp                                ;
                                                    ;