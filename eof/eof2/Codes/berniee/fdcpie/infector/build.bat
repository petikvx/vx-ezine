\masm32\bin\ml /c /coff fdcp.asm
\masm32\bin\link /SUBSYSTEM:WINDOWS /SECTION:.text,rw fdcp.obj
pause