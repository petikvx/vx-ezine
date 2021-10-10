
; advanced FileIO library  4.xx  (c) 1998-2000 Z0MBiE

;  ***ALL FUNCTIONS***: if (CF==1) EAX=error code
;
; fcreate  (EDX=fname) : EAX=handle
; fopen_ro (EDX=fname) : EAX=handle
; fopen_rw (EDX=fname) : EAX=handle
; fclose   (EBX=handle)
; fseek    (EBX=handle, EDX=newpos) : EAX=new pos
; fread    (EBX=handle, EDX=buffer, ECX=size) : EAX=bytesread
; fwrite   (EBX,EDX,ECX) : EAX=byteswritten
; fsetattr (EBX,ECX)
; fgetsize (EBX) : EAX

OPEN_EXISTING           equ     3
CREATE_ALWAYS           equ     2
GENERIC_READ            equ     80000000h
GENERIC_WRITE           equ     40000000h
FILE_SHARE_READ         equ     00000001h
FILE_SHARE_WRITE        equ     00000002h
FILE_ATTRIBUTE_NORMAL   equ     00000080h
FILE_BEGIN              equ     0
FILE_END                equ     2

fzeroerror:             pusha
                        push    0
                        call    xxSetLastError
                        popa
                        ret

fcheckerror:            call    xxGetLastError
                        or      eax, eax
                        jz      maplib1  ; CF=0
                        mov     [esp+7*4]+4, eax
                        stc
maplib1:                ret

fcreate:                pusha
                        call    fzeroerror
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    CREATE_ALWAYS
                        jmp     maplib9

fopen_ro:               pusha
                        call    fzeroerror
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    OPEN_EXISTING
                        push    0
                        push    FILE_SHARE_READ + FILE_SHARE_WRITE
                        push    GENERIC_READ
                        jmp     maplib10

fopen_rw:               pusha
                        call    fzeroerror
                        push    0
                        push    FILE_ATTRIBUTE_NORMAL
                        push    OPEN_EXISTING
maplib9:                push    0
                        push    FILE_SHARE_READ + FILE_SHARE_WRITE
                        push    GENERIC_READ + GENERIC_WRITE
maplib10:               push    edx
                        call    xxCreateFileA
                        cmp     eax, -1
                        je      maplib3
                        clc
                        mov     [esp+7*4], eax
                        popa
                        ret

fclose:                 pusha
                        call    fzeroerror
                        push    ebx
                        call    xxCloseHandle
maplib3:                call    fcheckerror
                        popa
                        ret

fseekend:               pusha
                        call    fzeroerror
                        push    FILE_END
                        xor     edx, edx
                        jmp     maplib6

fseek:                  pusha
                        call    fzeroerror
                        push    FILE_BEGIN
maplib6:                push    0
                        push    edx
                        push    ebx
                        call    xxSetFilePointer
maplib2:                mov     [esp+7*4], eax
                        jmp     maplib3

fread:                  pusha
                        call    maplib7
                        call    xxReadFile
                        jmp     maplib3

fwrite:                 pusha
                        call    maplib7
                        call    xxWriteFile
                        jmp     maplib3

maplib7:                pop     esi
                        call    fzeroerror
                        push    0
                        lea     eax, [esp+7*4] + 4
                        push    eax               ; byteswritten
                        push    ecx
                        push    edx
                        push    ebx
                        jmp     esi

fsetattr:               pusha
                        call    fzeroerror
                        push    ecx
                        push    edx
                        call    xxSetFileAttributesA
                        jmp     maplib3

fgetsize:               pusha
                        call    fzeroerror
                        push    0
                        push    ebx
                        call    xxGetFileSize
                        jmp     maplib2
