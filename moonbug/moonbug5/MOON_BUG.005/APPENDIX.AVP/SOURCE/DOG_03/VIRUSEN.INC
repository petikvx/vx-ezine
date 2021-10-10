;************* ’…‘’ˆŽ‚€ˆ… ”€‰‹Ž‚ € ‘‹“—€‰ ˆ”…Š–ˆˆ ***********
UKOL:
     CALL CLR_EOL
     LEA SI,CPATH
     CALL TELEWRITE
     LEA SI,KOSAYA
     CALL TELEWRITE
     MOV SI,9EH
     CALL TELEWRITE
     PUSH CX
     MOV CX,0FFFFH
WAITEN:
     LOOP WAITEN
     POP CX
     RET
