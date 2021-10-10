;--------------------------------------------------------------------
;  File: TXTWIN.ASM
;
;  Text mode windowing routines
;
;  Author: Rock Steady
;
VideoStruct             Struc
    rows                db      ?
    columns             db      ?
    IsCGA               db      ?
    IsColor             DB      ?
    VideoSegment        dw      ?
    VideoOffset         dw      ?
VideoStruct             ENDS

WindowStruct            Struc
    TopLeftRow          db      ?
    TopLeftCol          db      ?
    BottomRightRow      db      ?
    BottomRightCol      db      ?
    BorderAttribute     db      ?
    TextAttribute       db      ?
    Savebuffer          dw      ?
WindowStruct            ENDS

; Character codes for window frame
TopLeftCorner   =       0DAh
TopRightCorner  =       0BFh
BotRightCorner  =       0D9h
botLeftCorner   =       0C0h
Vline           =       0B3h
Hline           =       0C4h

                .MODEL Small
                PUBLIC v_clrscr, v_twindow, v_clrwin
                PUBLIC v_getwin, v_putwin, v_printwin
                .CODE
                EXTRN  V_chrout:NEAR, v_strout:NEAR, v_getchattr:NEAR
;----------------------------------------------------------
;  v_clrscr  Clear Screen
;
;  Entry:  DS:BX = Address of VideoStruct structure
;          AH = attribute
;
v_clrscr                PROC
                push    ax
                push    bx
                push    cx
                push    dx
                mov     cx, 0
                mov     dh, 26 ; [bx].rows
                dec     dh  
                mov     dl, 81 ;[bx].columns
                dec     dl
                mov     ah,0   ;(bh-ah)
                mov     bh,0
                mov     ax, 600h
                int     10h
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
v_clrscr                ENDP
;--------------------------------------------------------------------
;  v_clrwin  Clear a Window
;
;  Entry: DS:SI = address of WindowStruct structure
;
v_clrwin                PROC
                push    ax
                push    bx
                push    cx
                push    dx
                mov     ch, [si].TopLeftRow
                mov     cl, [si].TopLeftCol
                mov     dh, [si].BottomRightRow
                mov     dl, [si].BottomRightCol
                mov     bh, [si].TextAttribute
                add     cx, 0101h
                sub     dx, 0101h
                mov     ax,600h
                int     10h
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
v_clrwin        ENDP
;--------------------------------------------------------------------
; v_twindow  Draw a window
; Entry DS:BX = address of VideoStruct structure
;       DS:SI = address of WindowStruct structure
;
v_twindow               PROC
                push    ax
                push    cx
                push    dx

                mov     ah, [si].TextAttribute
                mov     dh, [si].TopLeftRow
                mov     dl, [si].TopLeftCol
                mov     al, TopLeftCorner
                call    v_chrout
                xor     cx, cx
                mov     cl, [si].BottomRightCol
                sub     cl, [si].TopLeftCol
                dec     cx
                push    cx
                mov     al, HLINE
; first the hoizontal lines
DrawTopHLine:
                inc     dl
                call    v_chrout
                loop    DrawTopHLine
                inc     dl
                mov     al, TopRightCorner
                call    v_chrout
                mov     dh, [si].BottomRightRow
                mov     al, BotRightCorner
                call    v_chrout
                mov     al, Hline
                pop     cx
DrawBotHline:
                dec     dl
                call    v_chrout
                loop    DrawbotHline
                dec     dl
                mov     al, botLeftCorner
                call    v_chrout
; now the vertical lines
                mov     cl, [si].BottomRightRow
                sub     cl, [si].TopLeftRow
                dec     cx
                push    cx
                mov     al, Vline
DrawLeftVLine:
                dec     dh
                call    v_chrout
                loop    DrawLeftVLine
                pop     cx
                mov     dl, [si].BottomRightCol
DrawRightVline:
                call    v_chrout
                inc     dh
                loop    DrawRightVLine
                pop     dx
                pop     cx
                pop     ax
                ret
v_twindow               ENDP
;--------------------------------------------------------------------
; v_printwin  Print a String in a window
;
; Entry: DS:BX = address of VideoStruct structure
;        DS:SI = address of WindowStruct Structure
;        DS:DI = string to be printed
;        DH = row (relative to top left corner)
;        DL = column
; Exit: Prints the string, but does not check if printed extends
;       beyond boundary of window
;
v_printwin              PROC
                push    dx
                push    si
                push    di
                mov     ah, [si].TextAttribute
                add     dh, [si].TopLeftRow
                add     dl, [si].TopLeftCol
                mov     si, di
                call    v_strout
                pop     di
                pop     si
                pop     dx
                ret
v_printwin              ENDP
;--------------------------------------------------------------------
;  v_getwin  Save area undereath a windo
;
;  Entry: DS:BX = address of VideoStruct structure
;         DS:SI = address of WindowStruct Structure
;  Exit: Contents of are underneath the window is in the
;        SaveBuffer field of WindowStruct
;
v_getwin                PROC
;make room for a local variable
                push    bp
                mov     bp, sp
                sub     sp, 2
                push    cx
                push    dx
                push    di
;compute number of rows and columns to save
                xor     cx, cx
                mov     cl, [si].BottomRightCol
                sub     cl, [si].TopLeftCol
                inc     cx
                mov     [bp-2], cx
                mov     cl, [si].BottomRightRow
                sub     cl, [si].TopLeftRow
                inc     cx
; point ES:DI to buffer
                push    ds
                pop     es
                mov     di, [si].Savebuffer
                cld
; start saveing row by row
                mov     dh, [si].TopLeftRow
LoopOverRows:
                push    cx
                mov     cx, [bp-2]
                mov     dl, [si].TopLeftCol
SaveOneRow:
                call    v_getchattr
                stosw
                inc     dl
                loop    SaveOneRow
                inc     dh
                pop     cx
                loop    LoopOverRows
                pop     di
                pop     dx
                pop     cx
                mov     sp, bp
                pop     bp
                ret
v_getwin                ENDP
;--------------------------------------------------------------------
;  v_putwin  Save Area underneath a Window
;
; Entry: DS:BX = address of VideoStruct structure
;        DS:SI = address of WindowStruct structure
; Exit: Window is redrawn using contents saved in the buffere whose
;       address is in the Savebuffer field of WindowStruct
;
v_putwin                PROC
;make room for a local vaiable
                push    bp
                mov     bp, sp
                sub     sp, 2
                push    cx
                push    dx
                push    si
                push    di
; use DI for accsessing WindowStruct because
; DS:SI will be used to address SaveeBuffer
                mov     di, si
                mov     si, [di].SaveBuffer
; compute number of rows and columns of window
                xor     cx,cx
                mov     cl, [di].BottomRightCol
                sub     cl, [di].TopLeftCol
                inc     cx
                mov     [bp-2], cx
                mov     cl, [di].BottomRightRow
                sub     cl, [di].topLeftRow
                inc     cx
; start restoring row by row
                mov     dh, [di].TopLeftRow
                cld
NextRow:
                push    cx
                mov     cx, [bp-2]
                mov     dl, [di].TopLeftCol
RestoreOneRow:
                lodsw
                call    v_chrout
                inc     dl
                loop    RestoreOneRow
                inc     dh
                pop     cx
                loop    NextRow
                pop     di
                pop     si
                pop     dx
                pop     cx
                mov     sp, bp
                pop     bp
                ret
v_putwin                ENDP
                END
