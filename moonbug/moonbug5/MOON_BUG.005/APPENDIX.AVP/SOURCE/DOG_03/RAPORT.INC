;************** è•Á†‚Ï Æ‚Á•‚† ¢ ‰†©´ ***********************************
REPORT_MENAGER:
             lea dx,EN_ER
             call PRINT_MSG
             lea dx,MSG_1_REP
             call PRINT_MSG
             mov ax,ALL_CHECK
             mov STR_WORD,ax
             call DECODE_STRING
             lea dx,MSG_2_REP
             call PRINT_MSG
             mov ax,ALL_INFECTED
             mov STR_WORD,ax
             call DECODE_STRING
             lea dx,MSG_3_REP
             call PRINT_MSG
             mov ax,ALL_cured
             mov STR_WORD,ax
             call DECODE_STRING
             lea dx,MSG_4_REP
             call PRINT_MSG
             mov ax,ALL_KILLED
             mov STR_WORD,ax
             call DECODE_STRING
             lea dx,EN_ER
             call PRINT_MSG
             ret

;****************** èÖêÖÇéÑ óàëãÄ Ç ëíêéäì ****************************
DECODE_STRING:
     mov STR_REPORT[0],0
     mov STR_REPORT[1],0
     mov STR_REPORT[2],0
     mov STR_REPORT[3],0
     mov STR_REPORT[4],0
     mov FLAG_DECRYPT,0
CALCULATE_BYTE:
     cmp STR_WORD,10
     jnl DECODE
     jmp ENDE_DECODE
DECODE:
     inc STR_REPORT[1]
     sub STR_WORD,10
     cmp STR_REPORT[1],10
     jl  CALCULATE_BYTE
     inc STR_REPORT[2]
     mov STR_REPORT[1],0
     cmp STR_REPORT[2],10
     jl CALCULATE_BYTE
     inc STR_REPORT[3]
     mov STR_REPORT[2],0
     cmp STR_REPORT[3],10
     jl CALCULATE_BYTE
     inc STR_REPORT[4]
     mov STR_REPORT[3],0
     cmp STR_REPORT[4],10
     jmp CALCULATE_BYTE
FLAG_DECRYPT db ?
ENDE_DECODE:
     cmp STR_REPORT[4],0
     jz LOC_R1
     mov al,STR_REPORT[4]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R1:
     cmp STR_REPORT[3],0
     jnz LOC_R2
     cmp FLAG_DECRYPT,0
     jz LOC_R3
LOC_R2:
     mov al,STR_REPORT[3]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R3:
     cmp STR_REPORT[2],0
     jnz LOC_R4
     cmp FLAG_DECRYPT,0
     jz LOC_R5
LOC_R4:
     mov al,STR_REPORT[2]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R5:
     cmp STR_REPORT[1],0
     jnz LOC_R6
     cmp FLAG_DECRYPT,0
     jz LOC_R7
LOC_R6:
     mov al,STR_REPORT[1]
     add al,30h
     mov ah,0eh
     int 10h
     mov FLAG_DECRYPT,1
LOC_R7:
     mov ax,STR_WORD
     add al,30h
     mov ah,0eh
     int 10h
     mov STR_WORD,0
ret
