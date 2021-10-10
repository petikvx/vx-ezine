;----------------------------------------------------------
; File: TXTIO.ASM
;
; Low-Level txt mode I/O routines
;
; Author: Rock Steady / NuKE
;

VideoStruct             struc
    Rows                db      ?
    Columns             db      ?
    IsCga               db      ?
    IsColor             db      ?
    VideoSegment        dw      ?
    VideoOffset         dw      ?
VideoStruct             ends

BIOSdata                Segment at 40h
        org 49h
    VideoMode           db      ?
    ScreenColumns       db      ?
        org 4eh
    VMemOffset          dw      ?
        org 63h
    VideoPort           dw      ?
        org 84h
    ScreenRows          db      ?
        org 87h
    EGAinfo             db      ?
BIOSdata                ends
;----------------------------------------------------------
;  Define some macros...
;
ComputeVideoAddress     Macro
;  Entry: DS:BX pointer to videdodata
;         DH,DL row, column
;  Exit:  DI will be offset of byte in video Memory
;         ES will be segment address of video memory
;
                push    ax
                mov     al,[bx].columns
                mul     dh
                xor     dh,dh
                add     ax,dx
                shl     ax,1
                add     ax,[bx].VideoOffset
                mov     di,ax
                pop     ax
                mov     es,[bx].VideoSegment
                ENDM

SynchWait       Macro
                LOCAL  wait1, wait2
; Entry : NONE
; Exit Horizontal retrace begins
                mov     dx,3dah
wait1:          in      al,dx
                test    al,1
                jnz     wait1
wait2:          in      al,dx
                test    al,1
                jz      wait2
                ENDM
;----------------------------------------------------------------------
                .MODEL SMALL
                .CODE
                PUBLIC v_getparams
                PUBLIC v_strout, v_chrout, v_getchattr
;----------------------------------------------------------------------
; Determine video information
; Entry:  DS:BX points to VideoStruct struture
; Exit:   Structure is filled with video info.
;
v_getparams     proc
                mov     ax, BIOSdata
                mov     es, ax
                ASSUME  es:BIOSdata
                push    bx
                mov     ah,12h
                mov     bl,10h
                int     10h
                mov     cl,bl
                pop     bx
                cmp     cl,10h
                jne     IsEGAactive
                cmp     VideoPort,3d4h
                jne     NotCGA1
                mov     [bx].IsCGA,1
                jmp     short skipNotCGA
NotCGA1:
                mov     [bx].IsCGA,0
skipNotCGA:
                mov     [bx].rows,25
                jmp     short CheckColor
IsEGAactive:
                test    EGAinfo,8
                je      EGAactive
                cmp     VideoPort, 3d4h
                jne     EGAactive
                mov     [bx].IsCGA,1
                jmp     short skipEGAactive
EGAactive:
                mov     [bx].IsCGA,0
skipEGAactive:
                mov     al,ScreenRows
                mov     [bx].rows, al
                inc     [bx].rows
CheckColor:
                cmp     VideoPort, 3d4h
                jne     mono
                mov     [bx].IsColor,1
                mov     word ptr [bx].VideoSegment, 0B800h
                jmp     short skipmono
Mono:
                mov     [bx].IsColor,0
                mov     word ptr [bx].VideoSegment, 0B000h
skipMono:
                mov     al, ScreenColumns
                mov     [bx].columns, al
                mov     ax, VMemOffset
                mov     [bx].VideoOffset, ax
                ret
v_getparams     ENDP
;--------------------------------------------------------------------
; v_strout: Display a String
;
; Entry: DS:BI points to ASCIIZ string to be printed
;        DS:BX points to VideoStruct structure
;        DH = row position
;        DL = cloumn position
;        AH = attribute
;
v_strout        proc
                push    ax
                push    cx
                push    dx
                push    si
                push    di
                push    es
                ComputeVideoAddress
                cld
sout1:          lodsb
                or      al,al
                jz      soutdone
                test    byte ptr [bx].IsCGA,1
                jz      soutnosynch
                mov     cx, ax
                cli
                SYNCHWAIT
                xchg    ax, cx
                stosw
                sti
                jmp     sout1
soutnosynch:
                stosw
                jmp     sout1
soutdone:
                pop     es
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
v_strout        ENDP
;--------------------------------------------------------------------
; v_chrout Print a single charater
;
; Entry: DS:BX points to VideoStruct structure
;        AL = character to be displayed
;        DH = row position
;        DL = cloumn position
;        AH = attribute
;
v_chrout        proc
                push    ax
                push    cx
                push    dx
                push    di
                push    es
                ComputeVideoAddress
                test    Byte ptr [bx].IsCGA, 1
                jz      coutnosynch
                mov     cx, ax
                cli
                SynchWait
                xchg    ax, cx
                stosw
                sti
                jmp     Short coutdone
coutnosynch:
                stosw
coutdone:
                pop     es
                pop     di
                pop     dx
                pop     cx
                pop     ax
                ret
v_chrout        ENDP
;--------------------------------------------------------------------
; v_getchattr   Return char and attr
;
; Entry: DS:BX =  address of VideoStruct Structure
;        DH = row position
;        DL = columns position
; Exit:  AL = character at that position
;        AH = attribute
;
v_getchattr     proc
                push    dx
                push    di
                push    es
                ComputeVideoAddress
                test    byte ptr [bx].IsCGA, 1
                jz      gcnosynch
                SynchWait
gcnosynch:
                mov     ax, es:[di]
                pop     es
                pop     di
                pop     dx
                ret
v_getchattr     ENDP
                END

