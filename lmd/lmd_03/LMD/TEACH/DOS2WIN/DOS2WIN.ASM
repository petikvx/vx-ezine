.386p
.model flat, stdcall

global		GetCurrentProcess:proc
global		SetPriorityClass:proc
global		SetErrorMode:proc
global		GetCommandLineA:proc
global		GetStdHandle:proc
global		WriteConsoleA:proc
global		ReadConsoleInputA:proc
global		CreateFileA:proc
global		ReadFile:proc
global		SetFilePointer:proc
global		WriteFile:proc
global		CloseHandle:proc
global		MessageBeep:proc
global		ExitProcess:proc

include		dos2win.inc

.data

copyleft	dw	len_copyleft
		db	10,'*DOS2WIN* 0.01 cyrillic file convertor',13,10
		db	'(c) Andrew Basharimov,2:454/2.175@fido.',13,10
		db	'[Win32 compatible part is processing]'
crlf		db	13,10
len_copyleft	=	$-copyleft-2

helpme		dw	len_helpme
		db	'Used for convert dos/win russian letters to win/dos.',13,10,10
		db	'Usage: DOS2WIN [/D] inputfile',13,10
		db	'when inputfile - source file,',13,10
		db	'     /D        - convert win to dos letters.',13,10,10
		db	'Please read DOS2WIN.RTF for full information.',13,10,10
		db	'Press any key to exit...'
len_helpme	=	$-helpme-2

process		dw	len_process
		db	'Processing...'
len_process	=	$-process-2

ok_conv		dw	len_ok_conv
		db	MB_OK,'File successfully converted.'
len_ok_conv	=	$-ok_conv-2-1

err_switch	dw	len_err_switch
		db	-1,'Invalid switch.'
len_err_switch	=	$-err_switch-2-1

not_found	dw	len_not_found
		db	-1,"File isn't found."
len_not_found	=	$-not_found-2-1

err_read	dw	len_err_read
		db	-1,'Error read(write) from(to) file.'
len_err_read	=	$-err_read-2-1

dos2win 	db	'ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖ×ØÙÚÛÜİŞßàáâãäåæçèéêëìíîï---¦+¦¦¬¬¦¦¬---¬'
		db	'L+T+-+¦¦Lã¦T¦=+¦¦TTLL-ã++----¦¦-ğñòóôõö÷øùúûüışÿ¨¸ªº¯¿¡¢°•·v¹¤¦ '

win2dos 	db	"??'",'?":ÅØ?%?<?????',"''",'""--?T?>????ÿö÷?ı?³ğcò<¿-Rôø+???çúñüó>'
		db	'???õ€‚ƒ„…†‡ˆ‰Š‹Œ‘’“”•–—˜™š›œŸ ¡¢£¤¥¦§¨©ª«¬­®¯àáâãäåæçèéêëìíîï'

sem_long_path	db	0
pxlat		dd	offset dos2win

pcmd_line	dd	?
stdout_handle	dd	?
stdin_handle	dd	?
num_written	dd	?
h_object	dd	?
num_fread	dd	?
num_fwritten	dd	?
filename	db	MAX_PATH dup (?)

myinput_record	INPUT_RECORD	<>		;â.ª.,4ex,¤«ï mouse event áâàãªâãà 
						;§ ­¨¬ ¥â ¡®«ìè¥ ¬¥áâ , ç¥¬ ¤«ï ª« ¢ë,
						;à §¬¥áâ¨¬ ¥¥ ¯¥à¥¤ ¡ãä¥à®¬
file_buff	db	65535 dup (?)

.code

win_start:	cld
		push	SEM_FAILCRITICALERRORS or SEM_NOOPENFILEERRORSBOX
		call	SetErrorMode
		call	GetCurrentProcess
		push	HIGH_PRIORITY_CLASS
		push	eax
		call	SetPriorityClass
		push	STD_OUTPUT_HANDLE
		call	GetStdHandle
		mov	stdout_handle,eax
		push	STD_INPUT_HANDLE
		call	GetStdHandle
		mov	stdin_handle,eax
		mov	esi,offset copyleft
		call	print
		call	GetCommandLineA
		xchg	esi,eax
		mov	edi,offset filename
		push	edi
		lodsb
		cmp	al,'"'
		jne	skip_short
		xchg	edi,esi
		repne	scasb
		xchg	esi,edi
		jmp	scan_path

skip_short:	lodsb
		cmp	al,' '
		je	scan_path
		or	al,al
		jnz	skip_short

get_help:	mov	esi,offset helpme
		call	print
		mov	esi,offset myinput_record
next_key:	push	esi
		push	offset num_written		;real num read
		push	1				;num of input_records
		push	esi
		push	stdin_handle
		call	ReadConsoleInputA
		pop	esi
		xchg	ecx,eax
		jecxz	go_exit				;if error
		cmp	[esi.EventType],KEY_EVENT
		jne	next_key
		cmp	[esi.KeyDown],FALSE
		je	next_key

go_exit:	push	0
		call	ExitProcess

scan_path:	lodsb
		cmp	al,'/'
		jne	no_switch
		lodsb
		and	al,not ' '
		cmp	al,'D'
		jne	get_err_switch
		mov	pxlat,offset win2dos
		jmp	scan_path

no_switch:	test	sem_long_path,1
		jnz	no_skip_space
		cmp	al,' '
		je	scan_end

no_skip_space:	cmp	al,'"'
		jne	store_path
		xor	sem_long_path,1
		jmp	scan_path

store_path:	stosb

scan_end:	or	al,al
		jnz	scan_path
		pop	edi
		cmp	al,[edi]
		je	get_help
		mov	esi,offset process
		call	print
		push	0				;tmp
		push	FILE_FLAG_SEQUENTIAL_SCAN	;flags&attribs
		push	OPEN_EXISTING			;mode
		push	0				;security
		push	0				;share (not shared!)
		push	GENERIC_READ or GENERIC_WRITE	;access mode
		push	edi				;lpfilename
		call	CreateFileA
		inc	eax
		jz	get_not_found
		dec	eax
		mov	h_object,eax

next_read:	push	0				;overlapped
		push	offset num_fread		;real num read
		push	65535				;num of read
		push	offset file_buff		;pointer to buffer
		push	h_object			;handle object
		call	ReadFile
		or	eax,eax
		jz	close_file
		mov	ecx,num_fread
		jecxz	close_file
		push	ecx
		push	FILE_CURRENT			;method
		push	0				;high distance
		neg	ecx
		push	ecx				;distance to move
		push	h_object
		call	SetFilePointer
		pop	ecx
		inc	eax
		jz	close_file
		mov	esi,offset file_buff
		mov	ebx,pxlat
		push	0				;overlapped
		push	offset num_fwritten		;real num written
		push	ecx esi

next_xlat:	lodsb
		sub	al,80h
		jb	no_conv
		xlat
		mov	[esi-1],al

no_conv:	loopd	next_xlat

		push	h_object
		call	WriteFile
		or	eax,eax
		jz	close_file
		xor	eax,eax
		mov	ecx,num_fwritten
		cmp	ecx,num_fread
		je	next_read

close_file:	push	eax
		push	h_object
		call	CloseHandle
		pop	ecx
		mov	esi,offset err_read
		jecxz	print_exit
		mov	esi,offset ok_conv
		jmp	print_exit
		
get_err_switch:	mov	esi,offset err_switch
		jmp	print_exit

get_not_found:	mov	esi,offset not_found

print_exit:	push	offset go_exit

print:		mov	eax,offset num_written
		push	0				;for 2nd call
		push	eax
		push	0				;reserved
		push	eax				;real num written
		lodsw
		movzx	eax,ax
		push	eax				;len
		xor	eax,eax				;MB_OK==0
		cmp	al,[esi]
		je	beep
		cmp	byte ptr [esi],-1
		jne	no_beep
		mov	al,MB_ICONQUESTION
beep:		inc	esi
		push	esi eax
		call	MessageBeep
		pop	esi
no_beep:	push	esi
		push	stdout_handle			;handle
		call	WriteConsoleA
		push	2
		push	offset crlf
		push	stdout_handle
		call	WriteConsoleA
		retn

		end	win_start
