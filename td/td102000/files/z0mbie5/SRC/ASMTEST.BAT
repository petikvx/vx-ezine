:: assemble virus dropper test.asm
@echo off
del test.ex_
tasm32.exe /m /ml /z test.asm
tlink32.exe -x -c -Tpe -aa test.obj,test.ex_,,x:\tasm\win\import32.lib
del test.obj
