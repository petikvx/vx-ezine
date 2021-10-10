data_9e         equ     0A0h
data_10e        equ     798h

;--------------------------------------------------------------------
; File: NUKE-IJ5.ASM
;
; NuKE InfoJournal #5 Source Codes
;
; Author: Rock Steady / NuKE
;
; Colors
    Black       =       0  ;black
    Blue        =       1  ;dark
    Green       =       2  ;bright
    Cyan        =       3  ;dark
    Red         =       4  ;dark
    Purple      =       5  ;
    Brown       =       6  ;only
    LightGray   =       7  ;light
    Gray        =       8  ;dark
    blue2       =       9  ;light
    green2      =      10  ;
    cyan2       =      11  ;
    red2        =      12  ;
    magenta     =      13  ;
    yellow      =      14  ;
    white       =      15  ;


; structure to hold video information
VideoStruct             STRUC
    rows                db      ?
    columns             db      ?
    IsCGA               db      ?
    IsColor             db      ?
    VideoSegment        dw      ?
    VideoOffset         dw      ?
VideoStruct             ENDS

; structure to hold window information
WindowStruct            STRUC
    TopLeftRow          db      0
    TopLeftCol          db      0
    BottomRightRow      db      0
    BottomRightCol      db      0
    BorderAttribute     db      0
    TextAttribute       db      0
    SaveBuffer          dw      0
WindowStruct            ENDS

                .MODEL  COMPACT
                .STACK
                .CODE
                EXTRN   v_getparams:NEAR, v_clrscr:NEAR, v_twindow:NEAR
                EXTRN   v_getwin:NEAR, v_putwin:NEAR, v_clrwin:NEAR
                EXTRN   v_printwin:NEAR, v_strout:NEAR, v_chrout:NEAR
                EXTRN   v_getchattr:NEAR

                mov     ah,01h                          ;Change cursor to
                mov     ch,02h                          ;invisable mode
                xor     cl,cl
                int     10h

                mov     ah, 0Bh                         ;spladd set black
                mov     bh, 00h                         ;spladd color thru
                mov     bl,bl                           ;spladd int10
                int     10h

                mov     ax, @data                       ;Get Video Parameters
                mov     ds, ax                          ;All info in Video Data
                mov     ax, 40h
                mov     es, ax
                mov     bx, Offset VideoData
                call    v_getparams

                call    slurp                           ;Slurp the screen
                call    v_clrscr
                call    nuke_display                    ;Display the NuKE Ansi

                mov     si, Offset window1              ;Init Window #1
                cmp     [bx].IsColor, 1
                je      UseColors
                
                mov     [si].BorderAttribute, (blue shl 4) + white
                mov     [si].TextAttribute, (black) + blue2  ;TXT COLOR
                jmp     Short DrawWindow1
UseColors:
                mov     [si].BorderAttribute, (blue shl 4) + white
                mov     [si].TextAttribute, (black) + blue2  ;TXT COLOR
                call    header
DrawWindow1:
                mov     [si].TopLeftRow, 2              ;Draw Window #1
                mov     [si].TopLeftCol, 0
                mov     [si].BottomRightRow, 6
                mov     [si].BottomRightCol, 24
                call    v_getwin                        ;Save Data under window
                call    v_twindow                       ;Write Window
                call    v_clrwin                        ;Clr Window with Color
                mov     di, Offset Window_11
                mov     dh, 1                           ;SPL row coord
                mov     dl, 2                           ;SPL col coord
                call    v_printwin                      ;Print Menu option in
                inc     dh                              ;Windows
                mov     di,offset window_12
                call    v_printwin
                inc     dh
                mov     di,offset window_13
                call    v_printwin
                call    highlight
                mov     dh,1                    ; SPL row coord
                mov     dl,1                    ; SPL col coord
                mov     cx,13                   ; SPL # of overhead hilite chars
S1:             call    v_getchattr
                mov     ah,(blue shl 4) + white ; SPL color of overhead chars
                call    v_chrout
                inc     dl
                loop    S1
                jmp     extended

Enter_pressed:
                cmp     menu_num,6              ;Quit?
                je      exit_dude               ;Yes, jump to quit routine
                call    v_clrscr
                call    header
                call    reader                  ;Else Draw reader
                call    v_clrscr
                mov     al,menu_num
                jmp     Im_lazy_ok
exit_Dude:
                call    slurp                   ;Slurp Screen
exit_final:     mov     ah,01h                  ;Put Back Cursor to normal
                mov     ch,11001101b
                mov     cl,00001110b
                int     10h
                mov     ax, 4c00h               ;Exit
                int     21h

Call_Window6:   Call    Window__6
                call    highlight

extended:       mov     ah, 7                   ;wait for key press
                int     21h
                cmp     al,0
                je      extended
                cmp     al,0dh
                je      enter_pressed           ;Enter was pressed!
                cmp     al,4dh
                je      go_right                ;Right cursor pressed
                cmp     al,4bh
                je      go_left                 ;Left Cursor key pressed
                cmp     al,50h
                je      go_down                 ;Down Cursor Key pressed
                cmp     al,48h
                je      go_up                   ;Up Cursor key pressed
                cmp     al,1bh
                je      exit_dude               ;Esc Pressed
                jmp     extended                ;Wait for a key
go_right:
                xor     al,al
                mov     al,menu_num
                cmp     al,6
                jne     It_all_right
                xor     al,al
It_all_right:   inc     al
                mov     menu_num, al
Im_lazy_ok:     cmp     al,1
                je      Call_Window1
                cmp     al,2
                je      Call_Window2
                cmp     al,3
                je      Call_Window3
                cmp     al,4
                je      Call_Window4
                cmp     al,5
                je      Call_Window5
                jmp     Call_Window6
go_left:
                xor     al,al
                mov     al,menu_num
                cmp     al,1
                jne     Its_all_right
                mov     al,7
Its_all_right:  dec     al
                mov     menu_num, al
                cmp     al,1
                je      Call_Window1
                cmp     al,2
                je      Call_Window2
                cmp     al,3
                je      Call_Window3
                cmp     al,4
                je      Call_Window4
                cmp     al,5
                je      Call_Window5
                jmp     Call_Window6

go_down:        xor     al,al
                mov     al,menu_num
                cmp     al,1
                je      down_1
                cmp     al,2
                je      down_2
                cmp     al,3
                je      down_3
                cmp     al,4
                je      down_4
                cmp     al,5
                je      down_5
                jmp     short joe_end

go_up:          xor     al,al
                mov     al,menu_num
                cmp     al,1
                je      up_1
                cmp     al,2
                je      up_2
                cmp     al,3
                je      up_3
                cmp     al,4
                je      up_4
                cmp     al,5
                je      up_5
                jmp     short joe_end

Call_Window1:   Call    Window__1
                call    highlight
                jmp     short joe_end

Call_Window2:   Call    Window__2
                call    highlight
                jmp     short joe_end

Call_Window3:   Call    Window__3
                call    highlight
                jmp     short joe_end

Call_Window4:   Call    Window__4
                call    highlight
                jmp     short joe_end

Call_Window5:   Call    Window__5
                call    highlight
Joe_End:        jmp     extended


down_1:         call    down1
                jmp     extended
down_2:         call    down2
                jmp     extended
down_3:         call    down3
                jmp     extended
down_4:         call    down4
                jmp     extended
down_5:         call    down5
                jmp     extended

up_1:           mov     up_flag,1
                call    down1
                jmp     extended
up_2:           mov     up_flag,1
                call    down2
                jmp     extended
up_3:           mov     up_flag,1
                call    down3
                jmp     extended
up_4:           mov     up_flag,1
                call    down4
                jmp     extended
up_5:           mov     up_flag,1
                call    down5
                jmp     extended

DOWN1            PROC
                mov     deelite,1
                call    highlight
                mov     ah,menu1
                cmp     up_flag,0
                je      cunt1
                cmp     ah,1
                jne     cunt_1
                mov     ah,4
cunt_1:         dec     ah
                jmp     up1ok
cunt1:          cmp     ah,3
                jne     down1ok
                xor     ah,ah
down1ok:        inc     ah
up1ok:          mov     menu1,ah
                call    highlight
                mov     up_flag,0
                ret
DOWN1            ENDP

DOWN2            PROC
                mov     deelite,1
                call    highlight
                mov     ah,menu2
                cmp     up_flag,0
                je      cunt2
                cmp     ah,1
                jne     cunt_2
                mov     ah,5
cunt_2:         dec     ah
                jmp     up2ok
cunt2:          cmp     ah,4
                jne     down2ok
                xor     ah,ah
down2ok:        inc     ah
up2ok:          mov     menu2,ah
                call    highlight
                mov     up_flag,0
                ret
DOWN2            ENDP

DOWN3            PROC
                mov     deelite,1
                call    highlight
                mov     ah,menu3
                cmp     up_flag,0
                je      cunt3
                cmp     ah,1
                jne     cunt_3
                mov     ah,7
cunt_3:         dec     ah
                jmp     up3ok
cunt3:          cmp     ah,6
                jne     down3ok
                xor     ah,ah
down3ok:        inc     ah
up3ok:          mov     menu3,ah
                call    highlight
                mov     up_flag,0
                ret
DOWN3            ENDP

DOWN4            PROC
                mov     deelite,1
                call    highlight
                mov     ah,menu4
                cmp     up_flag,0
                je      cunt4
                cmp     ah,1
                jne     cunt_4
                mov     ah,6
cunt_4:         dec     ah
                jmp     up4ok
cunt4:          cmp     ah,5
                jne     down4ok
                xor     ah,ah
down4ok:        inc     ah
up4ok:          mov     menu4,ah
                call    highlight
                mov     up_flag,0
                ret
DOWN4            ENDP

DOWN5            PROC
                mov     deelite,1
                call    highlight
                mov     ah,menu5
                cmp     up_flag,0
                je      cunt5
                cmp     ah,1
                jne     cunt_5
                mov     ah,5
cunt_5:         dec     ah
                jmp     up5ok
cunt5:          cmp     ah,4
                jne     down5ok
                xor     ah,ah
down5ok:        inc     ah
up5ok:          mov     menu5,ah
                call    highlight
                mov     up_flag,0
                ret
DOWN5            ENDP

Window__1        PROC
                call    v_clrscr
                call    nuke_display
                call    header
                call    v_putwin
                mov     [si].TextAttribute, (black) + blue2 ;TXT COLOR
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 0
                mov     [si].BottomRightRow, 6
                mov     [si].BottomRightCol, 24
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_11
                mov     dh, 1
                mov     dl, 2
                call    v_printwin
                inc     dh
                mov     di,offset window_12
                call    v_printwin
                inc     dh
                mov     di,offset window_13
                call    v_printwin
                mov     dh,1                     ;SPL row coord
                mov     dl,1                     ;SPL col coord
                mov     cx,13                    ;SPL Overhead Topic Hilite chars
w1:             call    v_getchattr
                mov     ah, (blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w1
                ret
Window__1        ENDP

Window__2        PROC
                call    v_clrscr
                call    v_putwin
                call    nuke_display
                call    header
                mov     [si].TextAttribute, (black) + blue2
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 15
                mov     [si].BottomRightRow, 7
                mov     [si].BottomRightCol, 40
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_21
                mov     dh, 1
                mov     dl, 2
                call    v_printwin
                inc     dh
                mov     di,offset window_22
                call    v_printwin
                inc     dh
                mov     di,offset window_23
                call    v_printwin
                inc     dh
                mov     di,offset window_24
                call    v_printwin
                mov     dh,1                    ;SPL row coord
                mov     dl,18                   ;SPL col coord
                mov     cx,10                   ;SPL overhead size coord
w2:             call    v_getchattr
                mov     ah,(blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w2
                ret
Window__2        ENDP

Window__3        PROC
                call    v_clrscr
                call    v_putwin
                call    nuke_display
                call    header
                mov     [si].TextAttribute, (black) + blue2
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 25
                mov     [si].BottomRightRow, 9
                mov     [si].BottomRightCol, 52
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_31
                mov     dh, 1
                mov     dl, 2
                call    v_printwin
                inc     dh
                mov     di,offset window_32
                call    v_printwin
                inc     dh
                mov     di,offset window_33
                call    v_printwin
                inc     dh
                mov     di,offset window_34
                call    v_printwin
                inc     dh
                mov     di,offset window_35
                call    v_printwin
                inc     dh
                mov     di,offset window_36
                call    v_printwin
                mov     dh,1
                mov     dl,33
                mov     cx,8
w3:             call    v_getchattr
                mov     ah,(blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w3

                ret
Window__3        ENDP

Window__4        PROC                                   ;Viruses
                call    v_clrscr
                call    v_putwin
                call    nuke_display
                call    header
                mov     [si].TextAttribute, (black) + blue2
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 41
                mov     [si].BottomRightRow, 8
                mov     [si].BottomRightCol, 61
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_41
                mov     dh, 1
                mov     dl, 2
                call    v_printwin
                inc     dh
                mov     di,offset window_42
                call    v_printwin
                inc     dh
                mov     di,offset window_43
                call    v_printwin
                inc     dh
                mov     di,offset window_44
                call    v_printwin
                inc     dh
                mov     di,offset window_45
                call    v_printwin
                mov     dh,1
                mov     dl,45
                mov     cx,10
w4:             call    v_getchattr
                mov     ah,(blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w4
                ret
Window__4        ENDP

Window__5        PROC
                call    v_clrscr
                call    v_putwin
                call    nuke_display
                call    header
                mov     [si].TextAttribute, (black) + blue2
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 55
                mov     [si].BottomRightRow, 7
                mov     [si].BottomRightCol, 74
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_51
                mov     dh, 1
                mov     dl, 2
                call    v_printwin
                inc     dh
                mov     di,offset window_52
                call    v_printwin
                inc     dh
                mov     di,offset window_53
                call    v_printwin
                inc     dh
                mov     di,offset window_54
                call    v_printwin
                mov     dh,1
                mov     dl,59
                mov     cx,13
w5:             call    v_getchattr
                mov     ah,(blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w5
                ret
Window__5        ENDP

Window__6        PROC
                call    v_clrscr
                call    v_putwin
                call    nuke_display
                call    header
                mov     [si].TextAttribute, (black) + blue2
                mov     [si].TopLeftRow, 2
                mov     [si].TopLeftCol, 74
                mov     [si].BottomRightRow, 4
                mov     [si].BottomRightCol, 79
                call    v_getwin
                call    v_twindow
                call    v_clrwin
                mov     di, Offset window_6
                mov     dh, 1
                mov     dl, 1
                call    v_printwin
                mov     dh,1
                mov     dl,75
                mov     cx,4
w6:             call    v_getchattr
                mov     ah,(blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    w6
                ret
Window__6        ENDP

HighLight        PROC
                xor     ax,ax
                mov     al,Menu_num
                cmp     al,1
                je      mm1
                cmp     al,2
                je      mm2
                cmp     al,3
                je      mm3
                cmp     al,4
                je      mm4
                cmp     al,5
                je      mm5
                jmp     mm6
ending:         ret
HighLight        ENDP

mm1:            call    m1
                jmp     ending
mm2:            call    m2
                jmp     ending
mm3:            call    m3
                jmp     ending
mm4:            call    m4
                jmp     ending
mm5:            call    m5
                jmp     ending
mm6:            call    m6
                jmp     ending

M1               PROC
                mov     dh, menu1
                add     dh, 2
                mov     dl, 2
                mov     cx,21
loop1:          call    v_getchattr
                cmp     deelite,1
                je      d1
                mov     ah,(blue shl 4) + white
                jmp     cont1
d1:             mov     ah, (black) + blue2     ;TXT COLOR
cont1:          call    v_chrout
                inc     dl
                loop    loop1
                mov     deelite,0
                ret
M1               ENDP

M2               PROC
                mov     dh, menu2
                add     dh, 2
                mov     dl,17
                mov     cx,22
loop2:          call    v_getchattr
                cmp     deelite,1
                je      d2
                mov     ah, (blue shl 4) + White
                jmp     cont2          
d2:             mov     ah, (black) + blue2
cont2:          call    v_chrout
                inc     dl
                loop    loop2
                mov     deelite,0
                ret
M2               ENDP

M3               PROC
                mov     dh, menu3
                add     dh, 2
                mov     dl, 27
                mov     cx, 24
loop3:          call    v_getchattr
                cmp     deelite,1
                je      d3
                mov     ah, (blue shl 4) + white
                jmp     cont3
d3:             mov     ah, (black) + blue2
cont3:          call    v_chrout
                inc     dl
                loop    loop3
                mov     deelite,0
                ret
M3               ENDP

M4               PROC
                mov     dh, menu4
                add     dh, 2
                mov     dl, 43
                mov     cx, 17
loop4:          call    v_getchattr
                cmp     deelite,1
                je      d4
                mov     ah, (blue shl 4) + white
                jmp     cont4
d4:             mov     ah, (black) + blue2
cont4:          call    v_chrout
                inc     dl
                loop    loop4
                mov     deelite,0
                ret
M4               ENDP

M5               PROC
                mov     dh, menu5
                add     dh, 2
                mov     dl, 57
                mov     cx, 16
loop5:          call    v_getchattr
                cmp     deelite,1
                je      d5
                mov     ah, (blue shl 4) + white
                jmp     cont5
d5:             mov     ah, (black) + blue2
cont5:          call    v_chrout
                inc     dl
                loop    loop5
                mov     deelite,0
                ret
M5               ENDP

M6               PROC
                mov     dh, 3
                mov     dl, 75
                mov     cx, 4
loop6:          call    v_getchattr
                mov     ah, (blue shl 4) + white
                call    v_chrout
                inc     dl
                loop    loop6
                ret
M6               ENDP

Header           PROC
                mov     di,offset head1
                mov     cx,80
                xor     dl,dl
                mov     dh,1
header_loop:    mov     al,byte ptr [di]
                mov     ah, (black) + blue        ;header color
                call    v_chrout
                inc     dl
                inc     di
                loop    header_loop
                ret
Header           ENDP

SLURP           proc
start:          push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ss
                push    sp

                mov     ax,0B800h
                mov     es,ax
                mov     data_6,0Ch
                mov     data_2,0D0h
loc_1:
                mov     ax,data_2
                mov     data_3,ax
loc_2:
                mov     data_4,39h
                mov     data_5,1
                mov     di,data_10e
                mov     ax,data_6
                mov     data_1,ax
loc_3:
                mov     cx,data_4
                dec     cx
                push    ds
                push    es
                pop     ds
                mov     si,di
                add     si,2
                cld
                rep     movsw
                pop     ds
                mov     cx,data_5
                push    ds
                push    es
                pop     ds
                mov     si,di
                sub     si,0A0h
                mov     ax,0A2h
                cld
  
locloop_4:
                movsw
                sub     di,ax
                sub     si,ax
                loop    locloop_4
  
                pop     ds
                mov     cx,data_4
                push    ds
                push    es
                pop     ds
                mov     si,di
                sub     si,2
                std
                rep     movsw
                pop     ds
                mov     cx,data_5
                inc     cx
                push    ds
                push    es
                pop     ds
                mov     si,di
                add     si,data_9e
                mov     ax,0A2h
                std
  
locloop_5:
                movsw
                add     di,ax
                add     si,ax
                loop    locloop_5
  
                pop     ds
                add     data_4,2
                add     data_5,2
                dec     data_1
                jnz     loc_3
                dec     data_3
                jz      loc_6
                jmp     loc_2
loc_6:
                sub     data_2,8
                dec     data_6
                jz      loc_7
                jmp     loc_1
loc_7:
                pop     sp
                pop     ss
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
SLURP            ENDP

Nuke_Display     PROC
                call    v_clrscr
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ss
                push    sp
                mov     ax,0b800h
                mov     es,ax
                mov     di,484
                mov     si,offset nuke
                mov     cx,1680
                cld
                rep     movsw
                pop     sp
                pop     ss
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
Nuke_Display     ENDP

Pause            PROC
                push    cx
                xor     cx,cx
huhu:           inc     cx
                cmp     cx,5555h
                jne     huhu
                pop     cx
                ret
Pause            ENDP

fall_top         PROC
                push    bx
                push    dx
                push    si
                push    di
                push    bp
                xor     bp,bp
                mov     ah,7
                xor     cx,cx
                mov     dh,25
                mov     dl,79
                mov     al,0           ;CHANGEDITCHANGEDIT WAS 1
                mov     bh, (black) + black
man:            inc     bp
                int     10h
                call    pause
                cmp     bp,26
                jne     man
                pop     bp
                pop     di
                pop     si
                pop     dx
                pop     bx
                ret
fall_top         ENDP

Cut_Screen       PROC
                push    bx
                push    dx
                push    bp
                xor     bp,bp
                mov     ah,6
                xor     cx,cx
                mov     dh,12
                mov     dl,79
                mov     al,0
                mov     bh, (black) + black
man1:           inc     bp
                int     10h
                call    pause
                push    ax
                push    cx
                push    dx
                mov     ah,7
                mov     ch,13
                mov     cl,0
                mov     dh,25
                mov     dl,79
                int     10h
                call    pause
                pop     dx
                pop     cx
                pop     ax
                cmp     bp,15
                jne     man1
                pop     bp
                pop     dx
                pop     bx
                ret
Cut_Screen       ENDP

Draw_reader      PROC
                call    v_clrscr
                mov     ax, @data
                mov     ds,ax
                mov     di,offset head2
                mov     cx,80           
                xor     dl,dl
                mov     dh,4            
                call    v_clrscr
loop_reader:    mov     al,byte ptr [di]
                mov     ah, (black) + gray
                call    v_chrout
                inc     dl
                inc     di
                loop    loop_reader
                mov     di,offset head3
                mov     cx,80
                xor     dl,dl
                mov     dh,23
looping_read:   mov     al,byte ptr [di]
                mov     ah,(black) + gray
                call    v_chrout
                inc     dl
                inc     di
                loop    looping_read
                mov     di,offset head4
                mov     cx,60
                xor     dl,dl
                mov     dh,24
loop_fuck:      mov     al,byte ptr [di]
                mov     ah,(black) + blue2
                call    v_chrout
                inc     dl
                inc     di
                loop    loop_fuck
                push    es
                push    di
                push    si
                mov     ax,0b800h
                mov     es,ax
                mov     di,0
                mov     si,offset head5
                mov     cx,320                  ;was was was cx,240
                cld
                rep     movsw
                pop     si
                pop     di
                pop     es
                ret
Draw_reader      ENDP


Get_art          PROC
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    si

                call    art_size
                mov     ah,19h
                int     21h

                inc     al
                mov     dl,al
                add     al,64
                push    ax
                mov     ax,@data
                mov     ds,ax
                pop     ax
                mov     byte ptr ds:[drive],al
                mov     ah,47h
                mov     si,offset current_path
                int     21h

                mov     cx,64h
loop_get1:      cmp     byte ptr ds:[si],00h
                je      ok_add_file
                inc     si
                loop    loop_get1

ok_add_file:    cmp     byte ptr ds:[si-1],'\'
                je      ok_add_2
                mov     byte ptr ds:[si],'\'
                inc     si
ok_add_2:       mov     byte ptr ds:[si],'M'
                inc     si
                mov     byte ptr ds:[si],'U'
                inc     si
                mov     byte ptr ds:[si],'T'
                inc     si
                mov     byte ptr ds:[si],'A'
                inc     si
                mov     byte ptr ds:[si],'T'
                inc     si
                mov     byte ptr ds:[si],'I'
                inc     si
                mov     byte ptr ds:[si],'O'
                inc     si
                mov     byte ptr ds:[si],'N'
                inc     si
                mov     byte ptr ds:[si],'.'
                inc     si
                mov     byte ptr ds:[si],'M'
                inc     si
                mov     byte ptr ds:[si],'A'
                inc     si                
                mov     byte ptr ds:[si],'G'

                mov     ax,3D00h
                mov     dx,offset drive
                int     21h

                cmp     byte ptr ds:[CRCFlag],1
                je      CRC_OK

                call    crc_check
                cmp     bp,1234h
                jne     crc_fuck
                mov     byte ptr ds:[CRCFlag],1

CRC_OK:         mov     bx,ax
                les     si,dword ptr ds:[pointer]
                mov     dx,si
                mov     cx,es
                mov     ax,4200h
                int     21h

                mov     cx,word ptr ds:[artsize]
                mov     ax,@fardata
                mov     ds,ax
                mov     dx,offset buffer
                mov     ah,3fh
                int     21h

                mov     ah,3eh
                int     21h

                pop     si
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret

crc_fuck:
                call    cut_screen
                mov     cx,38
                mov     ax,@data
                mov     ds,ax
                mov     di,offset crc
                mov     ah,02h

crc_fuck1:      mov     dl,byte ptr ds:[di]
                inc     di
                int     21h
                loop    crc_fuck1

                mov     dl,07h
                int     21h
                jmp     exit_final

Get_art          ENDP

;*************************************************************************

Reader           PROC                        ;READER Part
                push    ax
                push    bx
                push    cx
                push    dx
                push    ds
                push    es
                push    si
                push    di

                call    v_clrscr
                call    v_putwin
                call    cut_screen
                call    draw_reader

                call    get_art
                call    display_art

                call    fall_top

                mov     word ptr ds:[artsize],0
                mov     word ptr ds:[artline],0
                mov     word ptr ds:[line],0
                mov     word ptr ds:[lines],0
                mov     word ptr ds:[bad],0
                mov     word ptr ds:[pointer],0
                mov     word ptr ds:[pointer+2],0

                pop     di
                pop     si
                pop     es
                pop     ds
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
Reader           ENDP

art_size         PROC
                mov     ax,@data
                mov     ds,ax
                mov     al,menu_num
                cmp     al,1
                je      size1
                cmp     al,2
                je      size2
                cmp     al,3
                je      size3
                cmp     al,4
                je      size4
                cmp     al,5
                je      size5
                ret

size1:          jmp     as11
size2:          jmp     as21
size3:          jmp     as31
size4:          jmp     as41
size5:          jmp     as51

;----- menu #1

as11:           mov     al,menu1
                cmp     al,1
                jne     as12
                mov     ax,word ptr ds:[art11]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz11]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],0         ;SPL set pointer
                mov     word ptr ds:[pointer+2],0       ;ahead of some lame
                ret                                     ;table of contents
                                                        ;in nk-info5.txt..
                                                        ; [p],2388 (bytes)
as12:           cmp     al,2
                jne     as13
                mov     ax,word ptr ds:[art12]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz12]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],881
                mov     word ptr ds:[pointer+2],0
                ret

as13:           cmp     al,3
                jne     as1end
                mov     ax,word ptr ds:[art13]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz13]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],2383
                mov     word ptr ds:[pointer+2],0
as1end:         ret


;----- menu #2

as21:           mov     al,menu2
                cmp     al,1
                jne     as22
                mov     ax,word ptr ds:[art21]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz21]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],3663
                mov     word ptr ds:[pointer+2],0
                ret

as22:
                cmp     al,2
                jne     as23
                mov     ax,word ptr ds:[art22]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz22]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],5490
                mov     word ptr ds:[pointer+2],0
                ret
as23:
                cmp     al,3
                jne     as24
                mov     ax,word ptr ds:[art23]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz23]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],7902
                mov     word ptr ds:[pointer+2],0
                as2end:         ret
as24:
                cmp     al,4
                jne     as2end
                mov     ax,word ptr ds:[art24]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz24]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],14240
                mov     word ptr ds:[pointer+2],0
                ret

;----- menu #3

as31:           mov     al,menu3
                cmp     al,1
                jne     as32
                mov     ax,word ptr ds:[art31]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz31]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],19071
                mov     word ptr ds:[pointer+2],0
                ret

as32:           cmp     al,2
                jne     as33
                mov     ax,word ptr ds:[art32]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz32]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],26026
                mov     word ptr ds:[pointer+2],0
                ret

as33:           cmp     al,3
                jne     as34
                mov     ax,word ptr ds:[art33]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz33]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],40922
                mov     word ptr ds:[pointer+2],0
                ret

as34:           cmp     al,4
                jne     as35
                mov     ax,word ptr ds:[art34]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz34]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],49866
                mov     word ptr ds:[pointer+2],0
                ret

as35:           cmp     al,5
                jne     as36
                mov     ax,word ptr ds:[art35]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz35]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],57081
                mov     word ptr ds:[pointer+2],0
as3end:         ret

as36:           cmp     al,6
                jne     as3end
                mov     ax,word ptr ds:[art36]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz36]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],63492
                mov     word ptr ds:[pointer+2],0
                ret

;----- menu #4

as41:           mov     al,menu4
                cmp     al,1
                jne     as42
                mov     ax,word ptr ds:[art41]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz41]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],5985
                mov     word ptr ds:[pointer+2],0001h
                ret

as42:           cmp     al,2
                jne     as43
                mov     ax,word ptr ds:[art42]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz42]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],8434
                mov     word ptr ds:[pointer+2],0001h
                ret

as43:           cmp     al,3
                jne     as44
                mov     ax,word ptr ds:[art43]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz43]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],10302
                mov     word ptr ds:[pointer+2],0001h
                ret

as44:           cmp     al,4
                jne     as45
                mov     ax,word ptr ds:[art44]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz44]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],20566
                mov     word ptr ds:[pointer+2],0001h
                ret

as45:           cmp     al,5
                jne     as4end
                mov     ax,word ptr ds:[art45]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz45]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],26818
                mov     word ptr ds:[pointer+2],0001h
as4end:         ret

;----- menu #5

as51:           mov     al,menu5
                cmp     al,1
                jne     as52
                mov     ax,word ptr ds:[art51]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz51]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],30652
                mov     word ptr ds:[pointer+2],0001h
                ret

as52:
                cmp     al,2
                jne     as53
                mov     ax,word ptr ds:[art52]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz52]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],38425
                mov     word ptr ds:[pointer+2],0001h
                ret
as53:
                cmp     al,3
                jne     as54
                mov     ax,word ptr ds:[art53]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz53]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],39802
                mov     word ptr ds:[pointer+2],0001h
as5end:         ret
as54:
                cmp     al,4
                jne     as5end
                mov     ax,word ptr ds:[art54]
                mov     word ptr ds:[artline],ax
                mov     ax,word ptr ds:[asz54]
                mov     word ptr ds:[artsize],ax
                mov     word ptr ds:[pointer],42187
                mov     word ptr ds:[pointer+2],0001h
                ret                                
art_size         ENDP


display_art      PROC
                mov     ax,@data
                mov     ds,ax
                mov     ax,@fardata
                mov     es,ax
                mov     csfile,ax
                mov     di,offset buffer
                mov     ipfile,di
                mov     dh,5
display3:       mov     cx,80
                mov     dl,2
display1:       mov     al,byte ptr es:[di]
                mov     ah,(black) + purple
                cmp     al,0Dh
                je      display2
                call    v_chrout
                inc     dl
                inc     di
                loop    display1

display2:       inc     line
                inc     dh
                inc     di
                inc     di
                cmp     line,18
                jne     display3
display4:       mov     ah,7
                int     21h
                cmp     al,0
                je      display4

;                cmp     al,48h
;                je      display5                ;Cursor Up
                cmp     al,50h
                je      display6                ;Cursor Down
;                cmp     al,49h
;                je      display7                ;PgUp Key
                cmp     al,51h
                je      display8                ;PgDn Key
                cmp     al,1bh
                je      display9                ;Esc Key
                jmp     display4
display9:       call    v_clrscr
                ret

display5:       call    scroll_Up             ;spladd was SCROLL_UP
                jmp     display4
display6:       call    scroll_Dn             ;spladd was SCROLL_DN
                jmp     display4
display7:       call    scroll_PgUp
                jmp     display4
display8:       call    scroll_PgDn
                jmp     display4
display_art      ENDP



Scroll_up        PROC
;                cmp     line,18
;                je      up_bye
;                mov     ah,7
;                mov     ch,5
;                mov     cl,0
;                mov     dh,22
;                mov     dl,79
;                mov     al,1
;                push    bx
;                mov     bh,(black) + blue2
;                int     10h
;                pop     bx
;                mov     cx,80
;                mov     dl,2
;                mov     dh,5
;                push    di
;                cmp     bad,0
;                je      up__4
;                push    di
;                push    ax
;                push    bx
;                push    cx
;                push    dx
;                mov     ax,bad
;                mov     bx,19
;                xor     ah,ah
;                neg     ax
;                add     ax,bx
;                mov     dl,77
;                mul     dl
;                sub     di,ax
;                pop     dx
;                pop     cx
;                pop     bx
;                pop     ax
;                jmp     short up__1
;up__4:          sub     di,1463
;up__1:          mov     al,byte ptr es:[di]
;                mov     ah,(black) + blue2
;                cmp     al,0Dh
;                je      up__2
;                call    v_chrout
;                inc     dl
;                inc     di
;                loop    up__1
;up__2:          pop     di
;                sub     di,77
;                cmp     bad,0
;                jne     up__5
;                dec     line
;up_bye:         ret
;up__5:          dec     bad
;                pop     di
;                ret
Scroll_up        ENDP

Scroll_PgUp      PROC
;                cmp     bad,0
;                je      PgUp_6
;                mov     cx,18
;PgUp_7:         push    cx
;                call    scroll_up
;                pop     cx
;                loop    PgUp_7
;                ret
;PgUp_6:         mov     good,0
;                mov     ax,line
;                cmp     ax,18
;                je      PgUp_bye
;                sub     ax,18
;                cmp     ax,18
;                jg      PgUp_1
;                mov     good,ax
;                mov     ax,18
;                jmp     SHORT PgUp_5
;PgUp_1:         mov     good,18
;PgUP_5:         mov     line,ax
;                sub     ax,18
;                mov     lines,ax
;                mov     ah,7
;                mov     ch,5
;                mov     cl,0
;                mov     dh,22
;                mov     dl,79
;                mov     al,18
;                push    bx
;                mov     bh,(black) + blue2
;                int     10h
;                pop     bx
;
;                mov     ax,good
;                add     ax,18
;                mov     cl,77
;                mul     cl
;                sub     di,ax
;
;                mov     dh,5
;PgUp_4:         mov     cx,80
;                mov     dl,2
;PgUp_3:         mov     al,byte ptr es:[di]
;                mov     ah,(black) + blue2
;                cmp     al,0Dh
;                je      PgUp_2
;                call    v_chrout
;                inc     dl
;                inc     di
;                loop    PgUp_3
;PgUp_2:         inc     lines
;                inc     dh
;                inc     di
;                inc     di
;                mov     ax,lines
;                cmp     ax,line
;                jne     PgUp_4
;PgUp_bye:       ret
Scroll_PgUp      ENDP

Scroll_dn        PROC
                cmp     bad,0
                je      dn_3
                ret
dn_3:           mov     ax,artline
                cmp     line,ax
                je      dn_bye
                mov     ah,6
                mov     ch,5
                mov     cl,0
                mov     dh,22
                mov     dl,79
                mov     al,1
                push    bx
                mov     bh,(black) + purple
                int     10h
                pop     bx
                mov     cx,80
                mov     dl,2
                mov     dh,22
dn_1:           mov     al,byte ptr es:[di]
                mov     ah,(black) + purple
                cmp     al,0Dh
                je      dn_2
                call    v_chrout
                inc     dl
                inc     di
                loop    dn_1
dn_2:           inc     di
                inc     di
                inc     line
dn_bye:         ret
Scroll_dn        ENDP

Scroll_PgDn      PROC
                mov     ax,line
                cmp     ax,artline
                je      dn_bye
                mov     lines,ax
                add     ax,17
                cmp     ax,artline
                jl      PgDn_1
                mov     dx,artline
                sub     ax,dx
                mov     bad,ax
                mov     ax,artline

Pgdn_1:         mov     line,ax
                mov     ah,6
                mov     ch,5
                mov     cl,0
                mov     dh,22
                mov     dl,79
                mov     al,17
                push    bx
                mov     bh,(black) + purple
                int     10h
                pop     bx
                mov     dh,6
pgdn_4:         mov     cx,80
                mov     dl,2
pgdn_3:         mov     al,byte ptr es:[di]
                mov     ah,(black) + purple
                cmp     al,0Dh
                je      pgdn_2
                call    v_chrout
                inc     dl
                inc     di
                loop    pgdn_3
pgdn_2:         inc     lines
                inc     dh
                inc     di
                inc     di
                mov     ax,lines
                cmp     ax,line
                jne     pgdn_4
pgdn_bye:       ret
Scroll_PgDn      ENDP

crc_check        PROC
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                pushf

                xor     si,si
                xor     di,di
                mov     bx,ax
                mov     ax,4202h
                xor     dx,dx
                xor     cx,cx
                int     21h

                cmp     dx,0006h
;                jne     crc_fail
                cmp     ax,2349h
;                jne     crc_fail

                mov     ax,4200h
                xor     cx,cx
                xor     dx,dx
                int     21h

                mov     ax,ds
                mov     es,ax
                mov     ax,@fardata
                mov     ds,ax

crc_2:          mov     dx,offset buffer
                mov     cx,60000
                mov     ah,3fh
                int     21h

                mov     di,offset buffer
                mov     cx,ax
                cmp     ax,60000
                je      crc_1
                mov     byte ptr cs:[repeat],0

crc_1:          xor     si,word ptr ds:[di]
                inc     di
                loop    crc_1

                cmp     byte ptr es:[repeat],1
                je      crc_2

                cmp     si,5E79h
;                jne     crc_fail
                mov     bp,1234h
                jmp     crc_exit

;crc_fail:       xor     bp,bp

crc_exit:       popf
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
crc_check        ENDP

                .DATA

VideoData VideoStruct <>
WinBuf1         dw      256 DUP (0)  ;WAS 256
Window1         WindowStruct <,,,,,,Offset WinBuf1>
CSFile          dw      0
IPFile          dw      0
Menu1           db      1
Menu2           db      1
Menu3           db      1
Menu4           db      1
Menu5           db      1
Menu_num        db      1
deelite         db      0
up_flag         db      0
bad             dw      0
good            dw      0
line            dw      0
lines           dw      0
drive           db      0
                db      ':\'
current_path    db      64h dup (0)
CRC             db      'MUTATION.MAG Fails CRC Check... Abort!',0
CRCFlag         db      0
repeat          db      1
pointer         dd      0
artsize         dw      0
artline         dw      0
art11           dw      18
asz11           dw      880
art12           dw      30
asz12           dw      1502
art13           dw      29
asz13           dw      1280
art21           dw      40
asz21           dw      1827
art22           dw      49
asz22           dw      2412
art23           dw      111
asz23           dw      6338
art24           dw      85
asz24           dw      4831
art31           dw      118
asz31           dw      6955
art32           dw      270
asz32           dw      14896
art33           dw      147
asz33           dw      8944
art34           dw      131
asz34           dw      7215
art35           dw      116
asz35           dw      6411
art36           dw      133
asz36           dw      8029
art41           dw      61
asz41           dw      2449
art42           dw      55
asz42           dw      1868
art43           dw      187
asz43           dw      10264
art44           dw      164
asz44           dw      6251
art45           dw      121
asz45           dw      3834
art51           dw      179
asz51           dw      7773
art52           dw      36
asz52           dw      1377
art53           dw      44
asz53           dw      2386
art54           dw      18
asz54           dw      1242
Window_11       db      'Table Of Contents ',0
Window_12       db      'Mutation Mag Info ',0
Window_13       db      'Credits and Thanks',0
Window_21       db      'Letters to the Editor ',0
Window_22       db      'Hypocrisy Unmasked    ',0
Window_23       db      'Why Memphis Sucks     ',0
Window_24       db      'The Defined Elite     ',0
Window_31       db      'Getting Into Trouble    ',0
Window_32       db      'An Exercise in Deceit   ',0
Window_33       db      'The Last Imperor        ',0
Window_34       db      "Apathy: A User's Guide  ",0
Window_35       db      'The Vindictive Mindset  ',0
Window_36       db      'Board Crashing Made Easy',0
Window_41       db      'Aux 1 [EXiLED]   ',0
Window_42       db      'CyberTron [CR]   ',0
Window_43       db      'Darkstar [NucBBS]',0
Window_44       db      'Imperial [EXiLED]',0
Window_45       db      'ShadowMaster [??]',0
Window_51       db      'ShadowBox Plans ',0
Window_52       db      '[SPL007] Effect ',0
Window_53       db      '1-601-CYBERTRON ',0
Window_54       db      'EXiLED Listings ',0
Window_6        db      'Exit',0

head1           db      ' Miscellaneous '
                db      '   Op-Ed Page  '
                db      '   Articles    '
                db      'Interviews    V'
                db      'arious Files   '
                db      'Quit ',0

head2           db      'ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÍÍÍÍÍÍÍÍÍÍÍÍµ M'
                db      'utation Vol 1 I'
                db      'ssue 1ÆÍÍÍÍÍÍÍÍ'
                db      'ÍÍÍÍÍÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄ¿',0
head3           db      'ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
                db      'ÄÄÄÄÙ',0
head4           db      '               '
                db      '        Keys:  '
                db      '  and PgDn    '
                db      'ESC=Exit       '
                db      '   ',0
data_1          dw      0
data_2          dw      0
data_3          dw      0
data_4          dw      0
data_5          dw      0
data_6          dw      0
                db      24 dup (0)

HEAD5 LABEL BYTE
        DB      'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'Ü',3,'°',59,'°',59
        DB      'Ü',3,'ù',8,'Ü',3,'°',59,'°',59,'Ü',3,'ù',8,'ù',8,'Ü'
        DB      3,'°',59,'ù',8,'ù',8,'Ü',3,'°',59,'ù',8,'ù',8,'Ü',3,'Ü'
        DB      3,'°',59,'°',59,'°',59,'°',59,'ß',3,'ß',3,'ù',8,'ù',8
        DB      'ù',8,'ù',8,'Ü',3,'Ü',3,'°',59,'ß',3,'ù',8,'Ü',3,'Ü',3
        DB      '°',59,'°',59,'°',59,'°',59,'ß',3,'ß',3,'ù',8,'ß',3,'°'
        DB      59,'ß',3,'Ü',3,'ù',8,'ù',8,'ù',8,'Ü',3,'°',59,'ß',3,'ß'
        DB      3,'°',59,'Ü',3,'ù',8,'ù',8,'Ü',3,'°',59,'°',59,'Ü',3,'ù'
        DB      8,'Ü',3,'°',59,'Ü',3,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù'
        DB      8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ß',3,'Þ',3,'°',59,'Ý',3,'ß'
        DB      3,'°',59,'ß',3,'Þ',3,'°',59,'Ý',3,'ß',3,'Þ',3,'°',59,'Ý'
        DB      3,'ù',8,'ù',8,'Þ',3,'°',59,'Ý',3,'ß',3,'°',59,'ß',3,'Þ'
        DB      3,'ß',3,'Ü',3,'ù',8,'ù',8,'ù',8,'ù',8,'Ü',3,'ß',3,'ß'
        DB      3,'Þ',3,'°',59,'Ý',3,'ù',8,'ß',3,'°',59,'ß',3,'Þ',3,'ß'
        DB      3,'Ü',3,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'Ü',3,'°',59,'Ý'
        DB      3,'ù',8,'ù',8,'Þ',3,'°',59,'Ý',3,'ù',8,'ù',8,'Þ',3,'°'
        DB      59,'Ý',3,'ù',8,'Þ',3,'°',59,'Ý',3,'ß',3,'°',59,'Þ',3,'°'
        DB      59,'Ý',3,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù'
        DB      8,'ù',8,'ù',8,'Ü',3,'°',59,'°',59,'ù',8,'ù',8,'ù',8,'Ü'
        DB      3,'°',59,'°',59,'ù',8,'ù',8,'°',59,'°',59,'Ü',3,'ù',8
        DB      'ù',8,'Ü',3,'°',59,'°',59,'ù',8,'ù',8,'ù',8,'Ü',3,'°'
        DB      59,'Ý',3,'ù',8,'ù',8,'Ü',3,'°',59,'Ý',3,'ù',8,'ß',3,'°'
        DB      59,'°',59,'Ü',3,'ù',8,'ù',8,'ù',8,'ù',8,'Ü',3,'°',59,'Ý'
        DB      3,'ù',8,'ù',8,'ù',8,'ù',8,'Þ',3,'°',59,'±',59,'°',59,'Ü'
        DB      3,'ù',8,'°',59,'°',59,'ù',8,'ù',8,'ù',8,'°',59,'°',59
        DB      'Ý',3,'Ü',3,'°',59,'°',59,'ù',8,'ù',8,'Ü',3,'°',59,'°'
        DB      59,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù'
        DB      8,'ù',8,'ù',8,'ù',8,'ù',8,'ß',3,'°',59,'ù',8,'ù',8,'ù',8,'ù'
        DB      8,'ß',3,'°',59,'ù',8,'ù',8,'ù',8,'ß',3,'°',59,'°',59,'°'
        DB      59,'°',59,'ß',3,'ù',8,'ù',8,'ù',8,'Þ',3,'°',59,'±',59
        DB      'ß',3,'ù',8,'ß',3,'°',59,'ß',3,'ù',8,'ù',8,'Þ',3,'°',59
        DB      '±',59,'Ý',3,'ù',8,'ù',8,'ù',8,'Þ',3,'°',59,'±',59,'ß'
        DB      3,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ß',3,'°',59,'ß',3,'ù'
        DB      8,'ù',8,'ù',8,'ß',3,'°',59,'Ü',3,'°',59,'°',59,'ß',3,'ù'
        DB      8,'ù',8,'ß',3,'°',59,'ù',8,'ù',8,'ù',8,'ß',3,'°',59,'ù'
        DB      8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8,'ù',8


NUKE LABEL BYTE
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'E',0
        DB      'I',0,'N',0,'V',0,'I',0,'S',0,'I',0,'B',0,'L',0,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',11,'þ',11,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ü',11,'þ',11,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ü',11,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ü',3,'±',59,'Ý',11,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',3,'±'
        DB      59,'Ý',11,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',11,'²',59
        DB      'Ü',11,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ü',11,'²',59,'Ü',11,'Ú',8,'ß',11,'²',59,'²',59,'Ü',11
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Þ',3,'±',59,'²',59,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Þ',3,'±'
        DB      59,'²',59,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Þ',11,'²',59
        DB      'ß',11,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',11
        DB      '²',59,'Ä',8,'ß',11,'²',59,'±',59,'Ä',8,'Ú',8,'²',59,'²'
        DB      59,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'ß',3,'ß',3,'°',59,'±',59,'ß',11,'ß',11,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'ß',3,'ß',3
        DB      '°',59,'±',59,'ß',11,'ß',11,'Ä',8,'Ú',8,'Ä',8,'ß',11,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Þ',11,'²'
        DB      59,'±',59,'Ä',8,'Ú',8,'±',59,'°',59,'Ä',8,'Ú',8,'²',59
        DB      '±',59,'Ä',8,'Ú',8,'Ü',11,'²',59,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ü',11,'Ú',8,'Ä',8,'Ú',8,' ',56,'°',59,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ü',3,'°',59,'Ü',3,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,' ',56,'°',59,'Ä',8,'Ú',8,'Ü',3,'±',59,'Ü',11,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ü',3,'°',59,'Ü',3,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',3,'°',59,'Ü',3,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ü',3,'Ü',3,'Ú',8
        DB      '±',59,'°',59,'Ä',8,'Ú',8,'°',59,' ',59,'Ä',8,'Ú',8,'±'
        DB      59,'°',59,'Ä',8,'Ú',8,'²',59,'±',59,'Ä',8,'Ú',8,'Ä',8
        DB      'Ú',8,'²',59,'Û',11,'Ä',8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ü',3,'ß',3,'Ú',8,'ß',3,'±',59,'²',59,'Ü',11,'Ä'
        DB      8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú',8,'Þ',3,'°',59,'±',59,'²'
        DB      59,'Ü',11,'þ',11,'Ä',8,'Ü',3,'ß',3,'Ú',8,'ß',3,'±',59
        DB      '²',59,'Ü',11,'Ä',8,'Ú',8,'Ü',3,'ß',3,'Ä',8,'ß',3,'±'
        DB      59,'²',59,'Ü',11,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ü',3,'ß',3,'ß',3,'ß'
        DB      3,'°',59,'°',59,' ',59,'Ä',8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú'
        DB      8,'°',59,'Û',3,'Ä',8,'Ú',8,'±',59,'°',59,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'±',59,'²',59,'Ä',8,'Ú',8,'°',25,'Û',1,'Ä',8,'Ú'
        DB      8,'°',59,'°',59,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'±',59,'²',59
        DB      'Ä',8,'Ú',8,'°',25,'Û',1,'Ä',8,'Ú',8,'Ä',8,'ß',3,'±',59
        DB      'ß',11,'Ä',8,'Ú',8,'°',59,'°',59,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'°',59,'±',59,'Ä',8,'°',59,'°',59,'Ú',8,'Ä',8,'Ú',8
        DB      'Ä',8,'°',59,'±',59,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,' ',56,'ß',3,'Ä',8,'Ú',8,'°',25,'Û',1,'Ä'
        DB      8,'Ú',8,'ß',3,'Ü',1,'Ä',8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'°',59,'±',59,'Ä',8,'Ú',8,'°',25,'°',25
        DB      'Ä',8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'°',59
        DB      '±',59,'Ä',8,'Ú',8,'°',25,'°',25,'Ä',8,'Ú',8,'Ä',8,'°'
        DB      25,'Ü',1,'Ú',8,'Ä',8,'Ú',8,'Ü',1,'ß',3,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'ß',3,'°',59,'Ä',8,'Ü',1,'ß',3,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'ß',3,'°',59,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ü',1,'°',25,'Ä',8,'Ú',8,'±',25,'°',25,'Ä'
        DB      8,'Ú',8,'Û',1,'°',25,'Ä',8,'Ú',8,'°',25,'°',25,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'ß',3,'Ü',1,'Ä',8,'Ü',9,'±',25,'°',25,'Ý'
        DB      1,'Ú',8,'°',25,'°',25,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'ß',3,'Ü'
        DB      1,'Ä',8,'Ü',9,'±',25,'°',25,'Ý',1,'Ú',8,'Ü',9,'±',25,'°'
        DB      25,'Ú',8,'Ä',8,'Ú',8,'°',25,'°',25,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'²',25,'Ü',9,'Ä',8,'±',25,'°',25,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'²',25,'Ü',9,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ü',9,'Ú',8,'Ä',8,'Ü',9,'Ü'
        DB      9,'²',25,'±',25,'°',25,'Ü',1,'Ú',8,'²',25,'±',25,'Ä',8
        DB      'Ú',8,'°',25,'±',25,'Ä',8,'Ú',8,'ß',1,'±',25,'²',25,'Ü'
        DB      9,'Ä',8,'Ü',9,'²',25,'±',25,'Ý',1,'Þ',9,'²',25,'±',25
        DB      '°',25,'Ü',1,'ß',1,'±',25,'²',25,'Ü',9,'Ä',8,'Ü',9,'²'
        DB      25,'±',25,'Ä',8,'Þ',9,'²',25,'±',25,'°',25,'Ü',1,'Þ',9
        DB      '²',25,'±',25,'°',25,'Ü',1,'þ',1,'ß',1,'±',25,'²',25,'Ü'
        DB      9,' ',9,'Ü',1,'±',25,'²',25,'Ä',8,'²',25,'±',25,'Ú',8
        DB      'Ä',8,'Ú',8,'Ä',8,'±',25,'²',25,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'ß'
        DB      9,'Û',9,'Û',25,'²',25,'±',25,'°',25,'ß',1,'Ä',8,'Ú',8
        DB      'Û',9,'²',25,'Ä',8,'Ú',8,'±',25,'²',25,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'ß',9,'²',25,'ß',9,'Ú',8,'ß',9,'±',25,'ß',1,'Ú'
        DB      8,'ß',9,'±',25,'ß',1,'Ú',8,'Ä',8,'Ú',8,'ß',9,'²',25,'ß'
        DB      9,'Ú',8,'ß',9,'±',25,'ß',1,'Ú',8,'ß',9,'±',25,'ß',1,'Ú'
        DB      8,'Ä',8,'ß',9,'±',25,'ß',1,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'ß'
        DB      9,'²',25,'±',25,'°',25,'ß',1,'Ú',8,'Ä',8,'ß',9,'²',25
        DB      'Ú',8,'Ä',8,'Ú',8,'Ä',8,'°',25,'²',25,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'ß',9,'±',25,'ß',1,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'ß',9,'Ä',8,'Ú',8,'²',25,'²',25,'Ü',9,'Ú',8,'Ü'
        DB      9,'þ',9,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'ß',9,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'ß',1,'°',25,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'ß',9,'²',25,'ß',9,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,' ',8,'M',8,'u',8,'t',8,'a'
        DB      8,'t',8,'i',8,'o',8,'n',8,':',8,' ',8,' ',8,'A',8,' '
        DB      8,'C',8,'o',8,'l',8,'l',8,'e',8,'c',8,'t',8,'i',8,'o'
        DB      8,'n',8,' ',8,'o',8,'f',8,' ',8,'T',8,'h',8,'o',8,'u'
        DB      8,'g',8,'h',8,'t',8,'s',8,' ',8,'a',8,'n',8,'d',8,' '
        DB      8,'I',8,'d',8,'e',8,'a',8,'s',8,' ',8,'F',8,'r',8,'o'
        DB      8,'m',8,' ',8,'S',8,'p',8,'l',8,'i',8,'c',8,'e',8,' '
        DB      8,'a',8,'n',8,'d',8,' ',8,'E',8,'i',8,'n',8,'s',8,'t'
        DB      8,'e',8,'i',8,'n',8,' ',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,' ',8,'V',8,'o'
        DB      8,'l',8,'u',8,'m',8,'e',8,' ',8,'S',8,'e',8,'r',8,'i'
        DB      8,'e',8,'s',8,' ',8,'O',8,'n',8,'e',8,' ',8,'-',8,' '
        DB      8,'I',8,'s',8,'s',8,'u',8,'e',8,' ',8,'O',8,'n',8,'e'
        DB      8,' ',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú'
        DB      8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä'
        DB      8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,'Ú',8,'Ä',8,' ',8,' ',8,' '
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;12
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;21
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;30
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;39               
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;48 
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ' ;57
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '                
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '        
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '        
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '                
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '        
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '        
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '                
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '        
        DB      8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' ',8,' '
                .FARDATA

buffer          db    35000 dup (0)
                END
