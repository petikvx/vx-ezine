@echo off
del *.obj
rc dropper.rc
cvtres /machine:ix86 dropper.res
ren dropper.obj icon.obj
\masm32\bin\ml /c /coff dropper.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS dropper.obj icon.obj
