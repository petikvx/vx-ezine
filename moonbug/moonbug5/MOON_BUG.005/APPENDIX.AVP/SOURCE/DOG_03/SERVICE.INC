;****************** �뢮� ���ଠ樨 �� ��࠭ **************************
INFORMATION:
        lea dx,INFORMATIONS
PRINT_MSG:
        mov ah,09h
        int 21h
        ret

;*************** ������� ������� ������ *************************
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

;********* ����� ⥪�⮢�� ��ப� �� 0 ᨬ���� *****************
;----------------------------
;�室: DS:SI - 㪠�뢠�� �� �뢮����� ��ப�
;��室: ���
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
