;-----------------------------------------------------------------------------
; Простейшая реализация всем полюбившейся функции.
;-----------------------------------------------------------------------------
; Управление выводом:
;    \n        = новая строка (db  0Dh,0Ah)
;    \\        = \
;    \00000000 = byte/word/dword число в hex (\0D - вставит CR, \0A0D - CRLF)
;
;    %         - трактовка очередного параметра
;                (параметры берутся со стека, трактуются и выводятся в той
;                 или иной форме)
;    %c        = символ
;
;Далее: () - обязательные поля
;       [] - необязательные
;
;    %s($|c|s|z|00)
;     └─┼─┼─┼─┼─┼──── вывод строки
;       └─┼─┼─┼─┼────  заканчивается херней "$"
;         └─┼─┼─┼────  заканчивается символом CR (0Dh)
;           └─┼─┼────  заканчивается пробелом
;             └─┼────  заканчивается нулем
;               └────  имеет длину 00 hex
;
;    %i[-](b|w|d)(00)(b|d|h)
;     └─┼────┼────┼─────┼───── вывод целого
;       └────┼────┼─────┼───── со знаком
;            └────┼─────┼───── byte/word/dword
;                 └─────┼───── размер поля (если 00 - выравнивание слева)
;                       └───── binary/decimal/hex
;
;
;-----------------------------------------------------------------------------
LOCALS                                ;НужнО
sprintf      proc                     ;
      pop    dword ptr @@ret_addr     ;Сохраняем адрес возврата
                                      ;
      pop    edi                      ;EDI -> буффер
      pop    esi                      ;ESI -> строку инициализации
                                      ;
  @@main:                             ;
      lodsb                           ;AL=символ
      or     al, al                   ;Это конец строки?
      jz     @@exit                   ;Выход...
                                      ;
      cmp    al, '\'                  ;Это управляющий символ?
      jne    @@not_slash              ;дальше...
      lodsb                           ;
      cmp    al, 'n'                  ;"\n" ?
      jne    @@not_crlf               ;
      mov    al, 0Dh                  ;Ставим CRLF
      call   to_buff                  ;
      mov    al, 0Ah                  ;
      jmp    @@out_char               ;
  @@not_crlf:                         ;
      cmp    al, '\'                  ;"\\" ?
      je     @@out_char               ;выводим один слэш
   @@its_hex:                         ;
      dec    esi                      ;
      mov    bl, 8                    ;
      call   ascii_to_hex             ;Пытаемся взять hex число
      jc     @@loop                   ;
      mov    eax, edx                 ;
      or     ecx, ecx                 ;Ничего не получилось?
      jz     @@loop                   ;дальше...
      inc    ecx                      ;
      shr    ecx, 1                   ;
   @@write_hex:                       ;Выводим побайтно.
      call   to_buff                  ;
      shr    eax, 8                   ;
      loop   @@write_hex              ;
      jmp    @@loop                   ;
                                      ;
  @@not_slash:                        ;
      cmp    al, '%'                  ;Другой уравляющий символ?
      jne    @@out_char               ;дальше...
      lodsb                           ;
      cmp    al, 'c'                  ;"%c" ?
      jne    @@not_pchar              ;
      pop    eax                      ;EAX - AL=символу
      jmp    @@out_char               ;выводим
  @@not_pchar:                        ;
      cmp    al, 's'                  ;"%s" ?
      jne    @@not_pstr               ;
      lodsb                           ;
      mov    dl, '$'                  ;DL = символ конца строки
      cmp    al, dl                   ;"%s$" ?
      je     @@out_psx                ;
      mov    dl, 0Dh                  ;
      cmp    al, 'c'                  ;"%sc" ?
      je     @@out_psx                ;
      mov    dl, ' '                  ;
      cmp    al, 's'                  ;"%ss" ?
      je     @@out_psx                ;
      xor    dl, dl                   ;
      cmp    al, 'z'                  ;"%sz" ?
      jne    @@not_psx                ;
                                      ;
  @@out_psx:                          ;
      pop    ecx                      ;ECX -> строку
                                      ;
  @@psx_cycle:                        ;Выводим строку
      mov    al, [ecx]                ;
      inc    ecx                      ;
      cmp    al, dl                   ;до символа в DL
      jz     @@loop                   ;
      call   to_buff                  ;
      jmp    @@psx_cycle              ;
                                      ;
  @@not_psx:                          ;
      dec    esi                      ;
      call   is_hex                   ;Это hex?
      jc     @@loop                   ;
      mov    bl, 2                    ;Тогда конвертируем в число
      call   ascii_to_dec             ;
      jc     @@loop                   ;
      mov    ecx, edx                 ;Копируем байты, сколько указано.
      or     ecx, ecx                 ;
      jz     @@loop                   ;
      pop    edx                      ;EDX -> строку
   @@write_h:                         ;
      mov    al, [edx]                ;
      inc    edx                      ;
      call   to_buff                  ;
      loop   @@write_h                ;
      jmp    @@loop                   ;
                                      ;
  @@not_pstr:                         ;
      cmp    al, 'i'                  ;"%i" ?
      jne    @@not_integer            ;
      lodsb                           ;
      xor    edx, edx                 ;EDX - знака нет
      cmp    al, '-'                  ;Знаковое?
      jne    @@wo_sign                ;
      lodsb                           ;
      inc    edx                      ;EDX - знак есть
  @@wo_sign:                          ;
      pop    ebx                      ;EBX = число
                                      ;
      cmp    al, 'd'                  ;Dword?
      jne     @@try_word              ;
      or     edx, edx                 ;Знаковое
      jz     @@sfixed                 ;
      xor    edx, edx                 ;Корректируем
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
      jmp    @@sfixed                 ;
                                      ;
  @@try_word:                         ;
      cmp    al, 'w'                  ;Word?
      jne     @@byte                  ;
      movzx  ebx, bx                  ;Нулевое расширене
      or     edx, edx                 ;
      jz     @@sfixed                 ;
      movsx  ebx, bx                  ;Знаковое расширение
      xor    edx, edx                 ;
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
      jmp    @@sfixed                 ;
                                      ;
  @@byte:                             ;Byte!
      movzx  ebx, bl                  ;Нулевое расширение
      or     edx, edx                 ;
      jz     @@sfixed                 ;
      movsx  ebx, bl                  ;Знаковое расширение
      xor    edx, edx                 ;
      test   ebx, ebx                 ;
      jns    @@sfixed                 ;
      inc    edx                      ;
      neg    ebx                      ;
                                      ;
  @@sfixed:                           ;
      push   ebx edx                  ;
      mov    eax, ebx                 ;
      mov    bl, 2                    ;
      call   ascii_to_dec             ;Берем ширину поля
      mov    ecx, edx                 ;
      pop    edx ebx                  ;
      jc     @@loop                   ;
                                      ;EBX = число
                                      ;ECX = ширина поля вывода
                                      ;EDX = знак
                                      ;
      lodsb                           ;Берем символ формата
      push   ebx                      ;
      mov    ebx, 16                  ;EBX = основание системы (16 - hex)
      cmp    al, 'h'                  ;hex?
      je     @@convert                ;
      mov    ebx, 10                  ;10 - dec
      cmp    al, 'd'                  ;dec?
      je     @@convert                ;
      mov    ebx, 2                   ;2 - bin
  @@convert:                          ;
      pop    eax                      ;EAX = число
      call   all_to_ascii             ;Выводим
      jmp    @@loop                   ;
                                      ;
  @@not_integer:                      ;
                                      ;
  @@out_char:                         ;
      call   to_buff                  ;Вывод символа в буффер
                                      ;
  @@loop:                             ;
      jmp    @@main                   ;Циклим
                                      ;
  @@exit:                             ;
      xor    al, al                   ;Выводим 0
      call   to_buff                  ;
      push   12345678h                ;Возвращаемся
  @@ret_addr equ $-4                  ;
      ret                             ;
sprintf      endp                     ;
                                      ;
;-----------------------------------------------------------------------------
;Вывод символа в буффер
;AL = символ
;EDI -> буффер
;-----------------------------------------------------------------------------
to_buff      proc                     ;
      mov    [edi], al                ;
      inc    edi                      ;
      ret                             ;
to_buff      endp                     ;
                                      ;
;-----------------------------------------------------------------------------
;Определяет, пренадлежит ли символ множеству десятичных знаков
;AL = символ
;Выход: CF = 0 - пренадлежит
;            1 - нет
;-----------------------------------------------------------------------------
is_dec         proc                   ;
      cmp      al, '0'                ;
      jb       @@exit                 ;
      cmp      al, '9'                ;
      ja       @@exit                 ;
      clc                             ;
      ret                             ;
  @@exit:                             ;
      stc                             ;
      ret                             ;
is_dec         endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;Определяет, пренадлежит ли символ множеству шестнадцатеричных знаков
;AL = символ
;Выход: CF = 0 - пренадлежит
;            1 - нет
;-----------------------------------------------------------------------------
is_hex         proc                   ;
      call     is_dec                 ;
      jnc      @@ok                   ;
      and      al, 0DFh               ;
      cmp      al, 'A'                ;
      jb       @@exit                 ;
      cmp      al, 'F'                ;
      jbe      @@ok                   ;
  @@exit:                             ;
      stc                             ;
      ret                             ;
  @@ok:                               ;
      clc                             ;
      ret                             ;
is_hex         endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;Преобразует HEX знаки ASCII в число (рекурсивна)
;ESI -> ascii строку
; BL =  сколько символов преобразовывать (ограничитель рекурсии)
;Выход:
; ECX = сколько символов действительно преобразовано
; EDX = число
;-----------------------------------------------------------------------------
ascii_to_hex   proc                   ;
      xor      edx, edx               ;
      xor      ecx, ecx               ;
      mov      al, [esi]              ;
      call     is_hex                 ;
      jc       @@exit                 ;
      sub      bl, 1                  ;
      jc       @@exit                 ;
      inc      esi                    ;
                                      ;
      push     ax                     ;
      call     ascii_to_hex           ;
      pop      ax                     ;
                                      ;
      movzx    eax, al                ;
      sub      al, '0'                ;
      cmp      al, 9                  ;
      jbe      @@1                    ;
      sub      al, 'A'-'0'-0Ah        ;
  @@1:                                ;
      push     ecx                    ;
      shl      ecx, 2                 ;
      shl      eax, cl                ;
      or       edx, eax               ;
      pop      ecx                    ;
      inc      ecx                    ;
      clc                             ;
                                      ;
  @@exit:                             ;
      ret                             ;
ascii_to_hex   endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;Преобразует DEC знаки ASCII в число (рекурсивна)
;ESI -> ascii строку
; BL =  сколько символов преобразовывать (ограничитель рекурсии)
;Выход:
; ECX = сколько символов действительно преобразовано
; EDX = число
;-----------------------------------------------------------------------------
ascii_to_dec   proc                   ;
      xor      edx, edx               ;
      xor      ecx, ecx               ;
      mov      al, [esi]              ;
      call     is_dec                 ;
      jc       @@exit                 ;
      sub      bl, 1                  ;
      jc       @@exit                 ;
                                      ;
      inc      esi                    ;
                                      ;
      push     ax                     ;
      call     ascii_to_dec           ;
      pop      ax                     ;
                                      ;
      movzx    eax, al                ;
      sub      al, '0'                ;
      push     ecx                    ;
      jecxz    @@add                  ;
   @@pow:                             ;
      lea      ebx, [eax*2]           ;
      lea      eax, [eax*8+ebx]       ;
      loop     @@pow                  ;
                                      ;
  @@add:                              ;
      add      edx, eax               ;
      pop      ecx                    ;
      inc      ecx                    ;
      clc                             ;
                                      ;
  @@exit:                             ;
      ret                             ;
ascii_to_dec   endp                   ;
                                      ;
;-----------------------------------------------------------------------------
                                      ;
get_max_cap    proc                   ;
      mov      ecx, 7                 ;
      cmp      ebx, 16                ;
      je       @@exit                 ;
      mov      ecx, 9                 ;
      cmp      ebx, 10                ;
      je       @@exit                 ;
      mov      ecx, 31                ;
  @@exit:                             ;
      ret                             ;
get_max_cap    endp                   ;
                                      ;
;-----------------------------------------------------------------------------
;Степень
;-----------------------------------------------------------------------------
pow   proc                            ;
      push     eax ecx                ;
                                      ;
      mov      ebx, edx               ;
      xor      eax, eax               ;
      inc      eax                    ;
      jecxz    @@exit                 ;
  @@pow:                              ;
      mul      ebx                    ;
      loop     @@pow                  ;
                                      ;
  @@exit:                             ;
      mov      ebx, eax               ;
      pop      ecx eax                ;
      ret                             ;
pow   endp                            ;
                                      ;
;-----------------------------------------------------------------------------
;ВСЕ в ASCII
;Ниччо не комментирую, сорри, сами поймете (если охота)
;-----------------------------------------------------------------------------
all_to_ascii   proc PASCAL
      LOCAL    Frame:Dword, Digs:DWord, Buffe:Byte:32, DBS:DWord, Capa:DWord
      USES     esi                    ;
                                      ;
      lea      esi, Buffe             ;
      mov      DBS, ebx               ;
      mov      Frame, ecx             ;
      mov      Digs, 0                ;
                                      ;
      call     get_max_cap            ;
      mov      Capa, ecx              ;
                                      ;
      or       edx, edx               ;
      jz       @@rec                  ;
      push     eax                    ;
      mov      al, '-'                ;
      call     to_buff                ;
      pop      eax                    ;
                                      ;
 @@rec:                               ;
      mov      edx, DBS               ;
      call     pow                    ;
                                      ;
      xor      edx, edx               ;
      div      ebx                    ;
                                      ;
      cmp      Digs, 0                ;
      jne      @@2                    ;
      or       eax, eax               ;
      jz       @@2                    ;
      mov      Digs, ecx              ;
  @@2:                                ;
      mov      [esi], al              ;
      inc      esi                    ;
      mov      eax, edx               ;
      sub      ecx, 1                 ;
      jnc      @@rec                  ;
      inc      Digs                   ;
                                      ;
      lea      esi, Buffe             ;
      add      esi, Capa              ;
      inc      esi                    ;
      mov      ecx, Digs              ;
      sub      esi, ecx               ;
                                      ;
      mov      eax, Frame             ;
      mov      ebx, eax               ;
      sub      eax, ecx               ;
      jbe      @@gen_chars            ;
                                      ;
      mov      ecx, eax               ;
      mov      al, '0'                ;
  @@fill:                             ;
      call     to_buff                ;
      loop     @@fill                 ;
      mov      ecx, Digs              ;
                                      ;
  @@gen_chars:                        ;
      mov      al, [esi]              ;
      add      al, '0'                ;
      cmp      al, '9'                ;
      jbe      @@3                    ;
      add      al, 'A'-'0'-0Ah        ;
  @@3:                                ;
      call     to_buff                ;
      inc      esi                    ;
      loop     @@gen_chars            ;
                                      ;
      ret                             ;
all_to_ascii   endp                   ;
                                      ;
