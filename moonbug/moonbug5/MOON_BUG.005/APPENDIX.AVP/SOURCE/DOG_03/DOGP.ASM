.8086

CSEG    segment
        assume cs:CSEG,ds:CSEG,es:CSEG

        org 100h

        MAXLEN_PATH EQU 80               ;   

START:
      JMP DOCTOR

Ident   dw 0aabbh
        dw 0ccddh
        dw 0eeffh
IdLen equ $-Ident

DOCTOR:
      CALL INFORMATION                 ;๋ค ็  จญไฎเฌ ๆจจ
      CALL TEST_MEMORY                 ;ฅแโจเฎข ญจฅ ฏ ฌ๏โจ ญ  ง เ งใ
      CALL TEST_PARAM                  ;ฅแโจเฎข ญจฅ ชฎฌฌ ญคญฎฉ แโเฎชจ
      CALL FILE_MENAGER                ;   
      MOV AX,4C00H
      INT 21H

;=================  ====================================

INCLUDE BASED.INC      ;   
INCLUDE SETMODE.INC    ;    
INCLUDE VIR_MEM.INC    ;     
INCLUDE SERVICE.INC    ;   
INCLUDE FIND.INC       ;    
INCLUDE VIRUSEN.INC    ;      
;INCLUDE RAPORT.INC     ;    
INCLUDE CONST.INC      ;   

CSEG ENDS
     END START

