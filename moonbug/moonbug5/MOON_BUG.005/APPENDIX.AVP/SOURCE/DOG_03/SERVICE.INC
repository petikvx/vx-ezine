;****************** Вывод информации на экран **************************
INFORMATION:
        lea dx,INFORMATIONS
PRINT_MSG:
        mov ah,09h
        int 21h
        ret

;*************** ОЧИСТКА ТЕКУЩЕЙ СТРОКИ *************************
CLR_EOL:
        PUSH DS
        PUSH DX
        PUSH AX

        PUSH CS
        POP DS

        LEA DX,HOME_LINE
        MOV AH,09H
        INT 21H
        LEA DX,PURE_LINE
        MOV AH,09H
        INT 21H
        LEA DX,HOME_LINE
        MOV AH,09H
        INT 21H
        POP AX
        POP DX
        POP DS
        RET

;********* Печать текстовой строки до 0 символа *****************
;----------------------------
;Вход: DS:SI - указывают на выводимую строку
;Выход: нет
;----------------------------
TELEWRITE:
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH SI
        mov ah,0eh
        xor cx,cx
        xor bx,bx
LOOP_TELEWRITE:
        mov al,ds:[si]
        CMP AL,0
        JZ END_TELEWRITE
        INT 10H
        INC SI
        JMP LOOP_TELEWRITE
END_TELEWRITE:
        POP SI
        POP CX
        POP BX
        POP AX
        RET
