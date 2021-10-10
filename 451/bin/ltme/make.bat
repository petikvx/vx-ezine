@echo off

cls
tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc core.asm
tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 core.obj
pause

tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc mutator.asm
tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 mutator.obj
pause

del x.csm
del *.#00

ct.exe core.exe ltme_core
ct.exe mutator.exe ltme_mutator

del *.obj
del core.exe
del mutator.exe