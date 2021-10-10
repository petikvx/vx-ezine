.8086

CSEG    segment
        assume cs:CSEG,ds:CSEG,es:CSEG

        org 100h

        MAXLEN_PATH EQU 80               ;€‘€‹€ „‹€ ‘’ ‘€

START:
      JMP DOCTOR

Ident   dw 0aabbh
        dw 0ccddh
        dw 0eeffh
IdLen equ $-Ident

DOCTOR:
      CALL INFORMATION                 ;‚λ¤ η  ¨­δ®ΰ¬ ζ¨¨
      CALL TEST_MEMORY                 ;’¥αβ¨ΰ®Ά ­¨¥ ― ¬οβ¨ ­  § ΰ §γ
      CALL TEST_PARAM                  ;’¥αβ¨ΰ®Ά ­¨¥ ª®¬¬ ­¤­®© αβΰ®ª¨
      CALL FILE_MENAGER                ;‘ ”€‰‹‚  €’€‹ƒ€
      MOV AX,4C00H
      INT 21H

;================= –…„“› ====================================

INCLUDE BASED.INC      ;–…„“› „‹—… ‚“‘›• €‡
INCLUDE SETMODE.INC    ;–…„“› ’…‘’‚€  €’ €€…’‚
INCLUDE VIR_MEM.INC    ;–…„“› ‘€  “„€‹… …‡„…’›• ‚“‘‚
INCLUDE SERVICE.INC    ;–…„“› ’…”…‰‘€ ‘ ‹‡‚€’…‹…
INCLUDE FIND.INC       ;–…„“› ‘€ ”€‰‹‚ „‹ ’…‘’‚€
INCLUDE VIRUSEN.INC    ;–…„“› ‘€  ‹…—… ‚“‘‚ ‚ ”€‰‹…
;INCLUDE RAPORT.INC     ;–…„“› ‚›‚„€ ’—…’‚ €’› ƒ€›
INCLUDE CONST.INC      ;‘‘’€’›  ………›… ƒ€›

CSEG ENDS
     END START

