;
;=============================================================================
;LZ32Decompression subroutines.
;All rights may be reserved by SexyDufus
;Disassembled by Green Monster with LITTLE help of IDA v3.xx
;==============================================================================
;
;Interface:
;int   lz_decompresss(char *inbuf, char *outbuf, int size, char *buf)
;
;-----------------------------------------------------------------------------
;Расжимает Сжимает данные из inbuf, записывая полученное в outbuf.
;Для словаря используется внешний буффер (buf)
;Возвращает размер того, что получилось.
;=============================================================================
;

VarFrame        struc                      ;
vf_Const01FF    dw ?                       ;Маска (извратная) = (1<<9)-1
vf_Const03FF    dw ?                       ;Еще одна          = (1<<10)-1
vf_Const07FF    dw ?                       ;Третья            = (1<<11)-1
vf_Const0FFF    dw ?                       ;Последняя         = (1<<12)-1
                                           ;
vf_Sym1         dw ?                       ;Символы
vf_Sym2         dw ?                       ;
vf_Sym3         dw ?                       ;
                                           ;
vf_FreeSym      dw ?                       ;Свободный символ
vf_CharCount    dw ?                       ;Счетчик букв
vf_DictSize     dw ?                       ;Размер словаря
vf_BitSize      dw ?                       ;Разрядность
vf_SimpleChar   db ?                       ;Буква
vf_CharToLink   db ?                       ;И так понятно
                                           ;
vf_InBufRelPos  dw ?                       ;Позиция во входном буфере
field_1A        dw ?                       ;
vf_OutBufPos    dd ?                       ;Позиция в выходном буфере
field_20        dw ?                       ;
field_22        dw ?                       ;
                                           ;Аргументы
vf_InBuf        dd ?                       ;char *inbuf
vf_OutBuf       dd ?                       ;char *outbuf
vf_SuxxSize     dd ?                       ;char *size (не нужОн)
vf_Malloced     dd ?                       ;char *buf (словарь)
VarFrame        ends                       ;
                                           ;
;=============================================================================
;Основная процедурка
;=============================================================================
lz_decompress   proc near                  ;
                sub     eax, eax           ;
                push    eax                ;Инициализация структуры
                push    eax                ;
                push    9                  ;
                push    2000000h           ;
                push    1020000h           ;
                push    eax                ;
                push    0FFF07FFh          ;Маски
                push    3FF01FFh           ;
                mov     ebp, esp           ;
                                           ;
get_next_sym:                              ;
                call    Get_Sym            ;Получили символ
                cmp     ax, 101h           ; 101h - конец данных
                jz      lzd_exit           ;
                cmp     ax, 100h           ; 100h - сброс словаря
                jnz     short other_syms   ;
                                           ;
                call    lzd_init           ;Сброс
                                           ;
                call    Get_Sym            ;И символом все забиваем
                mov     [ebp+VarFrame.vf_Sym1], ax        ;
                mov     [ebp+VarFrame.vf_Sym2], ax        ;
                mov     [ebp+VarFrame.vf_CharToLink], al  ;
                mov     [ebp+VarFrame.vf_SimpleChar], al  ;
                call    Save_Char          ;Первый символ всегда простой
                jmp     short get_next_sym ;
; ───────────────────────────────────────────────────────────────────────────
                                           ;
other_syms:                                ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                mov     [ebp+VarFrame.vf_Sym3], ax      ;
                cmp     ax, [ebp+VarFrame.vf_FreeSym]   ;Символ уже в словаре?
                jl      short already_in_dict           ;
                                                        ;
                movzx   eax, [ebp+VarFrame.vf_Sym2]     ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                movzx   eax, [ebp+VarFrame.vf_SimpleChar]
                push    eax                             ;Оставить в стеке
                inc     [ebp+VarFrame.vf_CharCount]     ;
                                                        ;
already_in_dict:                                        ;
                cmp     [ebp+VarFrame.vf_Sym1], 0FFh    ;
                jle     short one_time_again            ;
;                                                       ;
                movzx   ebx, [ebp+VarFrame.vf_Sym1]     ;
                call    _Calc_Sym_Pos                   ;
                mov     al, [ebx+2]                     ;
                push    eax                             ;Составляем цепочку в стеке
                inc     [ebp+VarFrame.vf_CharCount]     ;
                movzx   eax, word ptr [ebx]             ;
                mov     [ebp+VarFrame.vf_Sym1], ax      ;
                jmp     short already_in_dict           ;
; ───────────────────────────────────────────────────────────────────────────
                                                        ;
one_time_again:                                         ;
                movzx   eax, [ebp+VarFrame.vf_Sym1]        ;
                mov     [ebp+VarFrame.vf_SimpleChar], al   ;
                mov     [ebp+VarFrame.vf_CharToLink], al   ;
                push    eax                                ;
                inc     [ebp+VarFrame.vf_CharCount]        ;
                movzx   ecx, [ebp+VarFrame.vf_CharCount]   ;
                jcxz    no_chars                           ;
                                                           ;
save_from_stack:                                           ;Записываем цепочку
                pop     eax                                ;
                call    Save_Char                          ;в выходной поток
                loop    save_from_stack                    ;
                                                           ;
no_chars:                                                  ;
                mov     [ebp+VarFrame.vf_CharCount], cx    ;
                                                           ;
                call    Add_Chain                          ;
                movzx   eax, [ebp+VarFrame.vf_Sym3]        ;
                mov     [ebp+VarFrame.vf_Sym2], ax         ;
                movzx   ebx, [ebp+VarFrame.vf_FreeSym]     ;
;                                                          ;
                cmp     bx, [ebp+VarFrame.vf_DictSize]     ;
                jl      get_next_sym                       ;
;                                                          ;
                cmp     [ebp+VarFrame.vf_BitSize], 0Ch     ;
                jz      get_next_sym                       ;
                                                           ;
                inc     [ebp+VarFrame.vf_BitSize]          ;Увеличиваем ее
                shl     [ebp+VarFrame.vf_DictSize], 1      ;И размер словаря
                jmp     get_next_sym                       ;
; ───────────────────────────────────────────────────────────────────────────
                                                           ;
lzd_exit:                                                  ;
                xchg    eax, edi                           ;EAX = end-start = size
                sub     eax, [ebp+VarFrame.vf_OutBuf]      ;
                add     esp, 20h                           ;
                retn    10h                                ;
lz_decompress   endp                                       ;
                                                           ;
;-----------------------------------------------------------------------------
;Рассчитывает адрес элемента словаря по номеру символу
;-----------------------------------------------------------------------------
_Calc_Sym_Pos   proc near                                  ;
                lea     ebx, [ebx+ebx*2]                   ;EBX *= 3
                add     ebx, [ebp+VarFrame.vf_Malloced]    ;
                retn                                       ;
_Calc_Sym_Pos   endp                                       ;
                                                           ;
;-----------------------------------------------------------------------------
;Читает символ переменной разрядности из входного потока
;-----------------------------------------------------------------------------
Get_Sym         proc near                                 ;
                movzx   eax, [ebp+VarFrame.vf_BitSize]    ;
                add     eax, dword ptr [ebp+VarFrame.vf_InBufRelPos]
                xchg    eax, dword ptr [ebp+VarFrame.vf_InBufRelPos]
                mov     ecx, 8                            ;
                sub     edx, edx                          ;
                div     ecx                               ; /8 (bits per byte)
                add     eax, [ebp+VarFrame.vf_InBuf]      ;
                xchg    eax, esi                          ;
                lodsw                                     ;Загружаем 3 байта
                movzx   ebx, ax                           ;
                lodsb                                     ;
                movzx   ecx, dx                           ;
                jcxz    getsym_exit                       ;
                                                          ;Выбираем то, что нужно
select_bits:                                              ;
                shr     al, 1                             ;
                rcr     bx, 1                             ;
                loop    select_bits                       ;
                                                          ;
getsym_exit:                                              ;
                movzx   eax, bx                           ;
                movzx   ebx, [ebp+VarFrame.vf_BitSize]    ;
                                                          ;
                sub     ebx, 9                            ;
                and     ax, [ebp+ebx*2+VarFrame.vf_Const01FF]
                                                          ;
                retn                                      ;
Get_Sym         endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;Переинициализировать словарь
;-----------------------------------------------------------------------------
lzd_init        proc near                                 ;
                mov     [ebp+VarFrame.vf_BitSize], 9      ;Разрядность
                mov     [ebp+VarFrame.vf_DictSize], 200h  ;Размер словаря
                mov     [ebp+VarFrame.vf_FreeSym], 102h   ;Первый свободный символ
                retn                                      ;
lzd_init        endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;Сохраняет букву в выходной поток.
;-----------------------------------------------------------------------------
Save_Char       proc near                                 ;
                mov     edi, [ebp+VarFrame.vf_OutBufPos]  ;
                add     edi, [ebp+VarFrame.vf_OutBuf]     ;
                stosb                                     ;
                inc     [ebp+VarFrame.vf_OutBufPos]       ;
                retn                                      ;
Save_Char       endp                                      ;
                                                          ;
;-----------------------------------------------------------------------------
;Прописывает связи в словарь
;-----------------------------------------------------------------------------
Add_Chain       proc near                                 ;
                movzx   ebx, [ebp+VarFrame.vf_FreeSym]    ;
                call    _Calc_Sym_Pos                     ;
                movzx   eax, [ebp+VarFrame.vf_CharToLink] ;
                mov     [ebx+2], al                       ;
                movzx   eax, [ebp+VarFrame.vf_Sym2]       ;
                mov     [ebx], ax                         ;
                inc     [ebp+VarFrame.vf_FreeSym]         ;
                retn                                      ;
Add_Chain       endp                                      ;
                                                          ;