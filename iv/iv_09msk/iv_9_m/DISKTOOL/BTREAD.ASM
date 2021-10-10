;(C) Saxon
;Чтение базовой таблицы для дискет в файл basetbl.dmp
.MODEL TINY
.CODE
        ORG 100H
START:
        XOR     AX,AX
        PUSH    AX
        POP     ES
        LDS     SI,DWORD PTR ES:[78H]
        MOV     CX,0BH              
        PUSH    CS
        POP     ES
        MOV     DI,OFFSET BUF
        REP     MOVSB
        
        MOV     AH,3CH
        MOV     CX,0
        PUSH    CS
        POP     DS
        MOV     DX,OFFSET FN
        INT     21H
        MOV     BX,AX

        MOV     AH,40H
        MOV     CX,0BH
        MOV     DX,OFFSET BUF
        INT     21H
        
        MOV     AH,3EH
        int     21h
        mov     ah,09h
        mov     dx,offset ok
        INT     21H

        INT     20H
FN      DB      'basetbl.dmp',0        
ok      db      10,13,'Ok. $'
BUF     DB      0BH     DUP (?)        
        DB      '$'
        END     START
