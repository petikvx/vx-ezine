;-[linux64.inc]---------------------------------------------------------------
;
; Linux x64 Constants and Structures.
;
; Constants:
;	STDOUT				- Standard output fd
;	NULL				- NULL = 0
;	MAX_PATH			- MAX filename length (excluding trailing 0)
;	whence				- seek() whence values
;	open flags			- open() 'flags' field values
;	file modes (permissions)	- file permission modes
;	st_mode constants		- file file/device type modes
;	mmap prot values		- mmap() memory protection values
;	mmap flags field		- mmap() flags values
;	sigaction constants		- signal related constants
;	ptrace constants		- ptrace related constants
;	clone constants			- clone related constants
;
; Structures:
;	stat				- Linux x64 Stat buf
;	linux_dirent			- Linux x64 dirent entry
;	sigaction			- Linux x64 sigaction struc
;	signalstack
;	sigcontext			- Linux x64 sigcontext struc
;	ucontext			- Linux x64 ucontext struc
;-----------------------------------------------------------------------------
%define	STDOUT		1

%define	NULL		0

%define	MAX_PATH	255

%define	AT_FDCWD	-100

;-[whence]--------------------------------------------------------------------
%define SEEK_SET	0x00
%define SEEK_CUR	0x01
%define SEEK_END	0x02

;-[open flags]----------------------------------------------------------------
%define O_RDONLY	0x00000000
%define O_WRONLY	0x00000001
%define O_RDWR		0x00000002
%define O_CREAT		0x00000040
%define O_EXCL		0x00000080
%define O_NOCTTY	0x00000100
%define O_TRUNC		0x00000200
%define O_APPEND	0x00000400
%define O_ASYNC		0x00002000
%define O_CLOEXEC	0x00080000
%define O_DIRECTORY	0x00010000
%define O_NONBLOCK	0x00000800
%define O_NDELAY	0x00000800
%define O_SYNC		0x00101000

;-[file modes (permissions)]--------------------------------------------------
%define S_IRWXU		00700O
%define S_IRUSR		00400O
%define S_IWUSR		00200O
%define S_IXUSR		00100O
%define S_IRWXG		00070O
%define S_IRGRP		00040O
%define S_IWGRP		00020O
%define S_IXGRP		00010O
%define S_IRWXO		00007O
%define S_IROTH		00004O
%define S_IWOTH		00002O
%define S_IXOTH		00001O

;-[st_mode constants]---------------------------------------------------------
%define S_IFMT		0170000O
%define S_IFSOCK	0140000O
%define S_IFLNK		0120000O
%define S_IFREG		0100000O
%define S_IFBLK		0060000O
%define S_IFDIR		0040000O
%define S_IFCHR		0020000O
%define S_IFIFO		0010000O
%define S_ISUID		0004000O
%define S_ISGID		0002000O
%define S_ISVTX		0001000O

;-[mmap prot values]----------------------------------------------------------
%define PROT_EXEC 	0x00000004
%define PROT_READ 	0x00000001
%define PROT_WRITE 	0x00000002
%define PROT_NONE 	0x00000000

;-[mmap flags field]----------------------------------------------------------
%define MAP_SHARED	0x00000001
%define MAP_PRIVATE	0x00000002
%define MAP_32BIT	0x00000040
%define MAP_ANONYMOUS	0x00000020
%define MAP_FIXED	0x00000010
%define MAP_GROWSDOWN	0x00000100
%define MAP_HUGETLB	0x00040000
%define MAP_LOCKED	0x00002000
%define MAP_NONBLOCK	0x00010000
%define MAP_NORESERVE	0x00004000
%define MAP_POPULATE	0x00008000
%define MAP_STACK	0x00020000

;-[signal constants]----------------------------------------------------------
%define	SIGILL		04
%define SIGTRAP		05

%define ILL_ILLOPC	01	; illegal opcode

%define	SA_SIGINFO	0x4
%define SA_NODEFER	0x40000000
%define	SA_RESTORER	0x04000000

;-[ptrace constants]----------------------------------------------------------
%define	PTRACE_TRACEME	0
%define PTRACE_ATTACH	16
%define	PTRACE_DETACH	17

%define PR_SET_PTRACER 	0x59616d61

;-[clone constants]-----------------------------------------------------------
%define CLONE_VM	0x100
%define CLONE_FS	0x200
%define CLONE_FILES	0x400
%define CLONE_SIGHAND	0x800
%define CLONE_VFORK	0x4000
%define CLONE_THREAD	0x10000

;-[stat]----------------------------------------------------------------------
struc	stat
	.st_dev		resq	1
	.st_ino		resq	1
	.st_nlink	resq	1
	.st_mode	resd	1
	.st_uid		resd	1
	.st_gid		resd	1
	.__pad0		resd	1
	.st_rdev	resq	1
	.st_size	resq	1
	.st_blksize	resq	1
	.st_blocks	resq	1
	.st_atime	resq	1
	.st_atime_nsec	resq	1
	.st_mtime	resq	1
	.st_mtime_nsec	resq	1
	.st_ctime	resq	1
	.st_ctime_nsec	resq	1
	.__unused	resq	3
endstruc

%if stat_size != 0x90
	%error stat should be 0x90 bytes.
%endif

;-[linux_dirent]--------------------------------------------------------------
struc linux_dirent
	.d_ino		resq	1
	.d_off		resq	1
	.d_reclen	resw	1
endstruc
;-[time_t]--------------------------------------------------------------------
struc time_t
	.time_seconds	resq	1
	.time_nsec	resq	1
endstruc

;-[sigaction]-----------------------------------------------------------------
struc	sigaction
	.sa_handler	resq	1
	.sa_flags	resq	1
	.sa_restorer	resq	1
	.sa_mask	resq	16
endstruc

;-[signalstack]---------------------------------------------------------------
struc	signalstack
	.ss_sp		resq	1
	.ss_flags	resq	1
	.ss_size	resq	1
endstruc

;-[sigcontext]----------------------------------------------------------------
struc	sigcontext
	.r8		resq	1		; +00
	.r9		resq	1		; +08
	.r10		resq	1		; +16
	.r11		resq	1		; +24
	.r12		resq	1		; +32
	.r13		resq	1		; +40
	.r14		resq	1		; +48
	.r15		resq	1		; +56
	.rdi		resq	1		; +64
	.rsi		resq	1		; +72
	.rbp		resq	1		; +80
	.rdx		resq	1		; +88
	.rbx		resq	1		; +96
	.rax		resq	1		; +104
	.rcx		resq	1		; +112
	.rsp		resq	1		; +120
	.rip		resq	1		; +128
	.eflags		resq	1		; +136
	.cs		resw	1		; +144
	.gs		resw	1		; +146
	.fs		resw	1		; +148
	.__pad0		resw	1		; +150
	.err		resq	1		; +152
	.trapno		resq	1		; +160
	.oldmask	resq	1		; +168
	.cr2		resq	1		; +176
	.fpstate	resq	1		; +184
	.reserved	resq	8		; +192
endstruc

;-[ucontext]------------------------------------------------------------------
struc	ucontext
	.uc_flags	resq	1			; +0x0
	.uc_link	resq	1			; +0x8
	.uc_stack	resb	signalstack_size	; +0x10
	.uc_mcontext	resb	sigcontext_size		; 28h
	.uc_sigmask	resq	16			; 128h
							; 228h
endstruc

;-[siginfo]-------------------------------------------------------------------
struc	siginfo
	.si_signo	resd	1	; 0
	.si_errno	resd	1	; 4
	.si_code	resd	1	; 8
	.unused		resd	1	; 12
	._addr		resq	1	; 16
endstruc
