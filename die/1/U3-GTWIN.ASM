; Rat Heart's Find Windozy's Hide-away (aka directory! ;))

;Effective Code Length = 1Dh = 29 Bytes
; The text string 'GetWindowsDirectoryA' is 20 characters
; so looking for and calling this API is a waste of code! ;)

; Because, take a look -
;   API Name = 20 bytes
;   Calling = 5 (call) + 10 (2 params, dword length) = 15

; There's 30 bytes.. Although it's possible to cut the code down
; by pushing registers, but you've still gotta find the damn API!

;Thanx go to Murkry /iKx for his document on Win95 Structures!


CopyRange       equ     0C00h           ;Should be in here!

        .386p
        .model flat

extrn   MessageBoxA:PROC
extrn   ExitProcess:PROC

        .data
MyWinTitle      db      'Rat Heart''s GetWinDir',0

        .data?
Env             db      CopyRange+1 dup (?)

        .code

start:  mov     esi,[esi+40h]
        mov     esi,[esi]                       ;Dig into Environ Settings
        mov     ecx,CopyRange                   ;Our scan range
findwin:
        cmp     dword ptr [esi],'dniw'          ;Scan for 'windir=' but
        jne     nothere                         ;don't check EVERY byte
        cmp     word ptr [esi+5],'=r'           ;that's wastefull!
        je      GotIt                           ;We've found it.. Msg it!
nothere:
        inc     esi                             ;move along settings
        loop    findwin                         ;Check the data
        jmp     loser                           ;Shit, not here! Problems!

GotIt:  add     esi,7h                          ;Skip past 'windir='

; ESI = Ptr to Windows Directory, Here!!!

        push    0
        push    offset MyWinTitle
        push    esi
        push    0
        call    MessageBoxA                     ;Show the user the dir.

loser:
        push    0
        call    ExitProcess                     ;Leave the app.!

        end     start
