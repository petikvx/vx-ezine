ECHO OFF
CLS
COPY MSWINSCK.OCX C:\PROGRA~1\MSWINSCK.OCX
REGSVR32 /S C:\PROGRA~1\MSWINSCK.OCX
DEL MSWINSCK.OCX
NACO.EXE
DEL ANACON.BAT
CLS
EXIT