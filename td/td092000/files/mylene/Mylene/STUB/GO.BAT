@echo off
tasm /m stub.asm
tlink /t stub.obj,stub.dat
..\bin2db stub.dat
del stub.dat
tasm /m rstub.asm
tlink /t rstub.obj,rstub.dat
del *.exe
rename rstub.dat stub.exe
del *.map
del *.obj
del *.asb