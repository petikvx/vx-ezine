; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²                                            ²²²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²  FlyCatcher þ Version 1.1 beta þ xxxxxxx   °°²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²² ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ °°²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²            (c) 1998 ReCoder                °°²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²                                            °°²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²²²°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°²²²²²²²²²²²²²
; ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

        .MODEL  TINY
        .RADIX  16

        .CODE
        .286

CUSTOM       equ     'Samara.1536'
CAPSLOCK     equ     1

        ORG 100
;---------------------------------------------------------------------------
;  Go to StartUp Proc
;---------------------------------------------------------------------------
start:
             jmp     StartUp

_OldInt8             label       dword
                     db          4 dup (?)
_OldInt9             label       dword
                     db          4 dup (?)
_OldInt21            label       dword
                     db          4 dup (?)

NotClear             db          ?
_CapsPressed         db          0               ; Used to turn off
_BlockCount          dw          0

;---------------------------------------------------------------------------
;  New keyboard handler
;---------------------------------------------------------------------------
NewInt9      proc
             pusha
             push        es

             in          al, 60
;==========================================================================
IfDef CAPSLOCK
             cmp         al, 03A          ; Caps Lock
             jne         Cont1
             mov         cs:[_CapsPressed], 0FF
             jmp         ExitInt9
Cont1:
             cmp         al, 0BA          ; Caps Lock up
             jne         Cont2
             mov         cs:[_CapsPressed], 0
             jmp         ExitInt9
EndIf
Cont2:
; Add here other key handlers
ExitInt9:
             pushf
             call        dword ptr CS:_OldInt9
QuitInt9:
             pop         es
             popa

             iret
NewInt9      endp
;---------------------------------------------------------------------------
;  New timer handler
;---------------------------------------------------------------------------
NewInt8      proc
             pusha
             push        es

; Timer

ExitInt8:
             pushf
             call        dword ptr CS:_OldInt8
QuitInt8:
             pop         es
             popa

             iret
NewInt8      endp
;---------------------------------------------------------------------------
;  New Int 21 handler
;---------------------------------------------------------------------------
NewInt21     proc
             cmp         ax, 0FFFF
             jne         NotMine
             cmp         bx, 0A55A
             jne         NotMine
             cmp         cx, 00000
             jne         I21_Cont1
; 'I am here' interrupt
             mov         ax, 0
             mov         bx, 05AA5
             mov         dx, cs:_BlockCount
             stc
             iret
I21_Cont1:
             cmp         cx, 00001
             jne         I21_Cont2
             call        UnhookVectors
             push        cs
             pop         dx
             iret
I21_Cont2:
; No more functions supported
             stc
             iret
NotMine:
IfDef CAPSLOCK
             cmp         cs:[_CapsPressed], 0
             jne         I21_Quit
EndIf
;---------------------------------------------------------------------------
; Virus calls go here ...
; ...
             cmp         ah, 99h
             jne         I21_Quit
             mov         ah, 66h
             inc         cs:_BlockCount
             stc
             iret
;---------------------------------------------------------------------------
I21_Quit:
             jmp         dword ptr CS:_OldInt21

NewInt21     endp

;---------------------------------------------------------------------------
UNHOOK       MACRO Intr, Handler
             mov     ax, 3500 + Intr
             int     21
             mov     dx, es
             cmp     cx, dx
             jne     QuitUnhookErr
             cmp     bx, offset Handler
             jne     QuitUnhookErr
             ENDM

RESTORE      MACRO Intr, OldAddr
             mov     ax, cs:word ptr OldAddr+2
             mov     dx, cs:word ptr OldAddr
             mov     ds, ax
             mov     ax, 2500+Intr
             int     21
             ENDM

UnhookVectors  proc near
             push    ds
             push    cs
             pop     ds

             mov     cx, ds

;---------------------------------------------------------------------------

             UNHOOK  8,  NewInt8
             UNHOOK  9,  NewInt9
             UNHOOK  21, NewInt21

             RESTORE 21, _OldInt21
             RESTORE 9,  _OldInt9
             RESTORE 8,  _OldInt8

             jmp short QuitUnhook
QuitUnhookErr:
             mov     ax, 0
QuitUnhook:
             pop     ds
             ret
UnhookVectors  endp

;=======================================================================
TSR_Frontier label   byte ; ============================================
;=======================================================================

ScanCommandLine      proc ; IN: bx = two char switch OUT: al = present?
             mov     si, 81
             mov     cl, cs:[80]
ScanLoop:
             lodsw
             dec     si
             cmp     ax, bx
             je      ScanFound
             loop    ScanLoop
             xor     al, al
             ret
ScanFound:
             mov     al, 0FF
             ret
ScanCommandLine      endp

HOOK         MACRO Intr, Saved, Handler
             mov     ax, 3500+Intr
             int     21
             mov     word ptr Saved+2, es
             mov     word ptr Saved, bx

             lea     dx, Handler
             mov     ax, 2500+Intr
             int     21
             ENDM

HookVectors    proc near

             HOOK    8,  _OldInt8, NewInt8
             HOOK    9,  _OldInt9, NewInt9
             HOOK    21, _OldInt21, NewInt21

             mov     ax, word ptr cs:[02C]
             mov     es, ax
             mov     ah, 49
             int     21

             ret
HookVectors    endp

Installed            db          0
SwitchInstall        db          1
SwitchUninstall      db          0
SwitchHelp           db          0

StartUp:
;---------------------------------------------------------------------------
             mov         ah, 9
             lea         dx, _Copyright
             int         21
;---------------------------------------------------------------------------
             mov         ax, 0FFFF
             mov         bx, 0A55A
             xor         cx, cx
             xor         dx, dx
             int         21
             mov         _BlockCount, dx
             cmp         ax, 0
             jne         EndTsrCheck
             cmp         bx, 05AA5
             jne         EndTsrCheck
             mov         Installed, 0FF
EndTsrCheck:
;---------------------------------------------------------------------------
             mov         bx, 'i/'
             call        ScanCommandLine
             mov         SwitchInstall, al
             mov         bx, 'u/'
             call        ScanCommandLine
             mov         SwitchUninstall, al
             mov         bx, '?/'
             call        ScanCommandLine
             mov         SwitchHelp, al
             or          al, al
             jz          NoHelp
;---------------------------------------------------------------------------
             mov         ah, 9
             lea         dx, _Usage
             int         21
;---------------------------------------------------------------------------
ReportStatus:
             mov         ah, 9
             lea         dx, _Status
             int         21

             cmp         Installed, 0
             je          ReportOff

             lea         dx, _On
             mov         ah, 9
             int         21

             std
             mov         cx, 5
             mov         si, 10d
             lea         di, _Digits + 4
             mov         ax, _BlockCount
             xor         dx, dx
NextDigit:
             cmp         ax, 0
             je          NoMoreDigits
             div         si
             xchg        ax, dx
             add         al, '0'
             stosb
             xor         ax, ax
             xchg        ax, dx
             jmp         NextDigit
NoMoreDigits:
             lea         dx, _Count
             jmp short ReportStatus2
ReportOff:
             lea         dx, _Off
ReportStatus2:
             mov         ah, 9
             int         21

             int         20
NoHelp:
             cmp         Installed, 0
             je          NotInstalled
;---------------------------------------------------------------------------
IsInstalled:
; Already installed
             cmp         SwitchUninstall, 0
             jne         DoUninstall              ; Uninstall !
             cmp         SwitchInstall, 0
             je          BackToDos
             mov         ah, 9
             lea         dx, _Installed2
             int         21
BackToDos:
             int         20
;---------------------------------------------------------------------------
NotInstalled:
             cmp         SwitchInstall, 0
             jne         DoInstall
             cmp         SwitchUninstall, 0
             je          BackToDos

             mov         ah, 9
             lea         dx, _NotInstalled2
             int         21
             jmp short BackToDos
DoUninstall:
;---------------------------------------------------------------------------
;  Uninstall
;---------------------------------------------------------------------------
             mov         ax, 0FFFF
             mov         bx, 0A55A
             mov         cx, 00001
             int         21
             cmp         ax, 0
             jne         ContUninstall
             mov         ah, 9
             lea         dx, _CannotUninstall
             int         21
             int         20
ContUninstall:
; dx => PSP of TSR part
             mov     es, dx
             mov     ah, 49
             int     21

             lea         dx, _Removed
             mov         ah, 9
             int         21
             int         20
;---------------------------------------------------------------------------
DoInstall:
;---------------------------------------------------------------------------
;  Hook vectors
;---------------------------------------------------------------------------
             call        HookVectors
;---------------------------------------------------------------------------
             mov         _BlockCount, 0
             mov         ah, 9
             lea         dx, _Loaded
             int         21
;---------------------------------------------------------------------------
;  Stay TSR
;---------------------------------------------------------------------------
             lea     dx, TSR_Frontier
             int     27

_Installed2      label   byte
        db      'FlyCatcher is already installed',0Ah,0Dh
        db      0Ah,0Dh,'$'
_NotInstalled2   label   byte
        db      'FlyCatcher currently is not installed',0Ah,0Dh
        db      0Ah,0Dh,'$'
_CannotUninstall label   byte
        db      'Cannot uninstall FlyCatcher',0Ah,0Dh
        db      0Ah,0Dh,'$'
_Loaded          label   byte
        db      'FlyCatcher has been installed successfully.'
        db      0Ah,0Dh,'$'
_Removed         label   byte
        db      'FlyCatcher has been uninstalled',0Ah,0Dh
        db      0Ah,0Dh,'$'
_Status          label   byte
        db      'Current state: $'
_On              label   byte
        db      'ON'
        db      0Ah,0Dh,'$'
_Off             label   byte
        db      'OFF'
        db      0Ah,0Dh,'$'
_Count           label   byte
        db      'Catched flies (virus calls): '
_Digits db      '    0'
        db      0Ah,0Dh,'$'

_Copyright       label   byte
        db      'FlyCatcher þ TSR Virus Blocking Monitor þ Version 1.1 þ [Generic]',0Ah,0Dh
        db      'Copyright (c) 1998 by ReCoder (Email: recoder@usa.net, FIDO: 2:5020/272.62)', 0Ah,0Dh
IfDef CUSTOM
        db      0Ah,0Dh, '* This version has been customized for ', CUSTOM, 0Ah,0Dh
EndIf
        db      0Ah,0Dh,'$'

_Usage           label   byte
        db      'Usage:',0Ah,0Dh
        db      '  C:\>FlyCatch.com /i - install monotor',0Ah,0Dh
        db      '  C:\>FlyCatch.com /u - uninstall monotor',0Ah,0Dh
        db      '  C:\>FlyCatch.com /? - get help information',0Ah,0Dh
        db      0Ah,0Dh
        db      'Press and hold <CapsLock> to suspend monitoring',0Ah,0Dh
        db      0Ah,0Dh,'$'
;---------------------------------------------------------------------------
             END     start


