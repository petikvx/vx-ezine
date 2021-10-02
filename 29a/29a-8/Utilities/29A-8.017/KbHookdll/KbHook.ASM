.386
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
includelib \masm32\lib\kernel32.lib
include \masm32\include\user32.inc
includelib \masm32\lib\user32.lib

_RecursivScan PROTO :DWORD, :DWORD
RecursivScan PROTO :DWORD, :DWORD
FileSearchAllFixedDrives PROTO :DWORD

.const
WM_KBHOOKINSTALLED  equ WM_USER + 11
WM_KBHOOKREMOVED    equ WM_USER + 12
WM_KEYCAPTURED      equ WM_USER + 13

.data


SrchPattern db    '*',0
bkl          db '\',0
;ROOT         db 'C:',0

.data?
hInstance dd ?
hHook dd ?
hWnd dd ?
PathFile	db 512 dup (?)
DrivesBuf   db 100 dup (?)
.code
DllEntry proc hInst:HINSTANCE, reason:DWORD, reserved1:DWORD
	push hInst
	pop hInstance
      mov  eax,TRUE
      ret
DllEntry Endp

KeyboardProc  proc  nCode:dword, wParam:dword, lParam :dword
      .IF     nCode == HC_ACTION	
      
         mov    eax,lParam
         test   eax,80000000h
         jz     @F
         invoke PostMessage,hWnd,WM_KEYCAPTURED,wParam,eax
        @@:
        
      .ELSEIF nCode < 0
	   invoke CallNextHookEx,hHook,nCode,wParam,lParam
         ret
      .ENDIF
      xor   eax,eax
      ret
KeyboardProc endp

InstallKBHook proc hwnd:DWORD


      push    hwnd
      pop     hWnd
      invoke  SetWindowsHookEx,WH_KEYBOARD	, addr KeyboardProc,   hInstance, 0
      mov     hHook,eax 

      invoke PostMessage,hWnd,WM_KBHOOKINSTALLED,0,0
      
      ret
InstallKBHook endp

RemoveKBHook  proc

      invoke UnhookWindowsHookEx, hHook
      invoke SendMessage,hWnd,WM_KBHOOKREMOVED,0,0
      ret
RemoveKBHook  endp  

FileSearchAllFixedDrives proc uses esi pCtrlRoutine:DWORD

       invoke  GetLogicalDriveStrings, SIZEOF DrivesBuf, addr DrivesBuf
       lea     esi, [DrivesBuf]
        
      EnumDrivesLoop:
       invoke  GetDriveType, esi
       
       .IF     EAX == DRIVE_FIXED
       
               invoke RecursivScan, esi, pCtrlRoutine
               
       .ENDIF
       
       add     esi, 4
       cmp     byte ptr [esi], 0
       jnz     EnumDrivesLoop
       
       ret
FileSearchAllFixedDrives endp

RecursivScan    proc uses edi ebx ecx esi edx pStartPath:DWORD,\
                                              pCtrlRoutine:DWORD

        LOCAL   CurDir[512]                     :BYTE

        invoke  GetCurrentDirectory, sizeof CurDir, addr CurDir
        invoke  _RecursivScan, pStartPath,  pCtrlRoutine
        invoke  SetCurrentDirectory, addr CurDir
        ret            
RecursivScan    endp

_RecursivScan    proc  pStartPath:DWORD,\
                       pCtrlRoutine:DWORD
                
        LOCAL   CurDir[512]                     :BYTE
        LOCAL   PrevDir[512]                    :BYTE
        LOCAL   fd                              :WIN32_FIND_DATA
        LOCAL   fHandle                         :DWORD

        invoke  lstrcpy, addr CurDir, pStartPath 
	  mov     edi,pStartPath 
	  xor	    al,al
       @@:
	  cmp     byte ptr [edi],0
	  jz      @F
	  inc     edi
	  jmp     @B
       @@:
	  cmp     byte ptr [edi-1],'\'
	  jz      @F
    	  mov     byte ptr [edi],'\'
	  and     byte ptr [edi+1],0
       @@:


        invoke  SetCurrentDirectory, addr CurDir
        
        
        
        invoke  FindFirstFile, addr SrchPattern, addr fd
        mov     fHandle,eax
	  
        invoke  GetCurrentDirectory, sizeof PrevDir, addr PrevDir
        srchlp:
       
        cmp     byte ptr [fd.cFileName],'.'
        jz      wasdir
        test    fd.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
        jz      notdir
       
        invoke  _RecursivScan, addr fd.cFileName,  pCtrlRoutine
        invoke  SetCurrentDirectory, addr PrevDir 
        jmp     wasdir
        notdir:

	invoke lstrcpy, addr PathFile, addr PrevDir

	cmp     byte ptr [PrevDir+3] , 0
	jz      @F
        invoke lstrcat, addr PathFile, addr bkl
       @@:
        invoke lstrcat, addr PathFile, addr fd.cFileName
	push  fd.nFileSizeLow
        push  OFFSET PathFile
        call  dword ptr [pCtrlRoutine]

        wasdir:
        
        invoke  FindNextFile, fHandle, addr fd
        or      eax,eax
        jnz     srchlp

        invoke  FindClose, fHandle
  	  

        ret            
_RecursivScan    endp
End DllEntry
