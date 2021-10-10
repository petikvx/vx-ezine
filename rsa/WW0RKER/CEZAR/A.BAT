@echo off
tasm /m cezar.asm
tlink /x cezar.obj wwpe.obj
exe2bin cezar.exe cezar.com
del cezar.obj
del cezar.exe