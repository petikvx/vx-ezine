.586
.model flat

VRPC_SERV_PORT		=		0E903h ; 1001

.data

include vrpc.inc

kern32				db		'kernel32', 0
user32				db		'user32', 0

fBeep				db		'Beep', 0
fLocalAlloc			db		'LocalAlloc', 0
fMessageBoxA		db		'MessageBoxA', 0
fLocalFree			db		'LocalFree', 0
fCreateFileA		db		'CreateFileA', 0
fReadFile			db		'ReadFile', 0
fCloseHandle		db		'CloseHandle', 0

server_side_msg		db		'incoming chat request', 0
msg_len	= $ - server_side_msg

auto_path			db		'c:\autoexec.bat', 0
auto_len = $ - auto_path

buf					db		513 dup (0)

vrpc_cs				VRPC_call_struct	<>

wss					dw					?
					dw					?
					db					256 dup (?)
					db					128 dup (?)
					db					?
					db					?
					dd					?


.code

main:
	push	offset wss
	push	101h
    call	WSAStartup

	; структура вызова vrpc	
	mov		EDI, offset vrpc_cs
	; порт сервера
	mov		[EDI.vrpc_call_addr.sin_port], VRPC_SERV_PORT
	; адресс сервера 127.0.0.1
	mov		[EDI.vrpc_call_addr.sin_addr], 0100007Fh
	; нужна€ библиотека
	mov		[EDI.vrpc_call_lib], offset kern32
	; формат передачи параметров на сервере:
	; 0 - stdcall, 1 - cdecl, 2 - fastcall
	mov		[EDI.vrpc_call_cnv], 0
	; тип функции:
	; 0 - внешн€€, 1 - внутренн€€, 2 - по адресу
	mov		[EDI.vrpc_call_kind], 0

	; бипкнем пару раз
	mov		ESI, offset fBeep
	mov		ECX, 2
	push	1000
	push	200
	call	vrpc_call
	
	mov		ESI, offset fBeep
	mov		ECX, 2
	push	2000
	push	200
	call	vrpc_call
	
	; прочитаем название первой секции сервера
	mov		ESI, offset buf
	mov		ECX, 8
	mov		EAX, 400000h + 1F8h
	call	vrpc_read
	
	; покажем название
	push	0
	push	0
	push	offset buf
	push	0
	api		MessageBoxA
	
	; выделим немного пам€ти
	mov		ESI, offset fLocalAlloc
	mov		ECX, 2
	push	LMEM_FIXED
	push	1024
	call	vrpc_call

	; EAX -> выделенна€ пам€ть на стороне сервера
	; запишем наше сообщение в выделенную пам€ть
	mov		EBP, EAX
	mov		ESI, offset server_side_msg
	mov		ECX, msg_len
	call	vrpc_write
	
	; покажем месадж бокс, пока на серваке не тыкнут ќ  управление
	; к нам не вернетс€, пыталс€ € сделать асинхронный режим, да что-то
	; он глючит дико
	mov		[EDI.vrpc_call_lib], offset user32
	mov		ESI, offset fMessageBoxA
	mov		ECX, 4
	push	0
	push	EBP
	push	EBP
	push	0
	call	vrpc_call
	
	; передадим на сервер путь к файлу,
	; оставив место под один из параметров ReadFile
	mov		EAX, EBP
	add		EAX, 4
	push	EAX
	mov		ESI, offset auto_path
	mov		ECX, auto_len
	call	vrpc_write
	
	; откроем файл
	mov		[EDI.vrpc_call_lib], offset kern32
	mov		ESI, offset fCreateFileA
	mov		ECX, 7
	mov		EAX, EBP
	add		EAX, 4
	push	EAX
	push	GENERIC_READ
	push	0
	push	0
	push	OPEN_ALWAYS
	push	0
	push	0
	call	vrpc_call
	
	; EAX = хендл файла
	; читаем из файла
	mov		EDX, EAX
	mov		ESI, offset fReadFile
	mov		ECX, 5
	push	EDX
	mov		EAX, EBP
	add		EAX, 4
	push	EAX
	push	512
	push	EBP
	push	0
	call	vrpc_call

	; закроем файл	
	mov		ESI, offset fCloseHandle
	mov		ECX, 1
	push	EDX
	call	vrpc_call
	
	; переносим к себе считанные данные
	mov		EAX, EBP
	mov		ESI, offset buf
	mov		ECX, 512
	call	vrpc_read
	
	; высвободим пам€ть
	mov		ESI, offset fLocalFree
	mov		ECX, 1
	push	EBP
	call	vrpc_call
	
	; добавим нолик после считанных данных что б получше смотрелось
	mov		EBX, offset buf
	mov		EAX, [EBX]
	add		EBX, 4
	mov		1 ptr [EBX + EAX], 0
	
	; покажем autoexec.bat
	push	0
	push	0
	push	EBX
	push	0
	api		MessageBoxA

	call	WSACleanup

	api		ExitProcess, LIB_KERN
	ret
end main