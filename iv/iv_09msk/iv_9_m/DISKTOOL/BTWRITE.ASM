;(C) Saxon
; Замещение в памяти Базовой Таблицы для Дискет из файла BASETBL.DMP
; (По адресу вектора 1Eh)
.MODEL TINY
.CODE

        ORG 100H
START:
        MOV     AX,3D00H
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET FN
        INT     21H
        MOV     BX,AX
        
        XOR     AX,AX
        PUSH    AX
        POP     ES
        LDS     SI,DWORD PTR ES:[78H]
        MOV     DX,SI
        MOV     CX,0BH
        MOV     AH,3FH
        INT     21H
        
        CMP     CX,AX
        JNE     ERROR
	xor ax,ax
	int 13h
        push    cs
        pop     ds
        mov     dx,offset Ok
        mov     ah,09h
        int     21h
EXIT:        
        MOV     AH,3EH
        INT     21H
        xor     ax,ax
        int     13h
        INT     20H
ERROR:
        MOV     AH,09H
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET ERRMES
        INT     21H
        JMP     EXIT
FN      DB      'basetbl.dmp',0        
ERRMES  DB      10,13,'ERROR FILE ! $'
OK      DB      10,13,'Ok. $'
        END     START

