
; advanced FileIO library  4.xx  (c) 1998-2000 Z0MBiE

;  ***ALL FUNCTIONS***: if (CF==1) EAX=error code
;
; fopen    (EDX=fname) : EAX=handle
; fclose   (EBX=handle)
; fseek    (EBX=handle, EDX=newpos) : EAX=new pos
; fread    (EBX=handle, EDX=buffer, ECX=size) : EAX=bytesread
; fwrite   (EBX,EDX,ECX) : EAX=byteswritten

OPEN_EXISTING           equ     3
CREATE_ALWAYS           equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
FILE_SHARE_READ         equ     00000001h
FILE_SHARE_WRITE        equ     00000002h
FILE_ATTRIBUTE_NORMAL   equ     00000080h
FILE_BEGIN              equ     0

        hooy
fzeroerror:             pusha
        hooy
                        push    0
        hooy
                        call    dword ptr xxSetLastError
        hooy
                        popa
        hooy
                        ret

        hooy
fcheckerror:            call    dword ptr xxGetLastError
        hooy
                        or      eax, eax
        hooy
                        jz      maplib1  ; CF=0
        hooy
                        mov     [esp+7*4]+4, eax
        hooy
                        stc
        hooy
maplib1:                ret

        hooy
fopen:                  pusha
        hooy
                        call    fzeroerror
        hooy
                        push    0
        hooy
                        push    FILE_ATTRIBUTE_NORMAL
        hooy
                        push    OPEN_EXISTING
        hooy
                        push    0
        hooy
                        push    FILE_SHARE_READ
        hooy
                        push    GENERIC_READ + GENERIC_WRITE
        hooy
                        push    edx
        hooy
                        call    dword ptr xxCreateFileA
        hooy
                        cmp     eax, -1
        hooy
                        je      maplib3
        hooy
                        clc
        hooy
                        mov     [esp+7*4], eax
        hooy
                        popa
        hooy
                        ret

        hooy
fclose:                 pusha
        hooy
                        call    fzeroerror
        hooy
                        push    ebx
        hooy
                        call    dword ptr xxCloseHandle
        hooy
maplib3:                call    fcheckerror
        hooy
                        popa
        hooy
                        ret

        hooy
fseek:                  pusha
        hooy
                        call    fzeroerror
        hooy
                        push    FILE_BEGIN
        hooy
                        push    0
        hooy
                        push    edx
        hooy
                        push    ebx
        hooy
                        call    dword ptr xxSetFilePointer
        hooy
maplib2:                mov     [esp+7*4], eax
        hooy
                        jmp     maplib3

        hooy
fread:                  pusha
        hooy
                        call    fzeroerror
        hooy
                        push    0
        hooy
                        lea     eax, [esp+7*4] + 4
        hooy
                        push    eax               ; bytesread
        hooy
                        push    ecx
        hooy
                        push    edx
        hooy
                        push    ebx
        hooy
                        call    dword ptr xxReadFile
        hooy
                        jmp     maplib3
        hooy

        hooy
fwrite:                 pusha
        hooy
                        call    fzeroerror
        hooy
                        push    0
        hooy
                        lea     eax, [esp+7*4] + 4
        hooy
                        push    eax               ; byteswritten
        hooy
                        push    ecx
        hooy
                        push    edx
        hooy
                        push    ebx
        hooy
                        call    dword ptr xxWriteFile
        hooy
                        jmp     maplib3
        hooy

