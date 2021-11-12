@echo off
D:\bcc55\bin\bcc32 -ID:\bcc55\include ebv_cpp.cpp
F:\asm\tasm5\bin\tasm32 /mx /m ebv_asm.asm
F:\asm\tasm5\bin\tlink32 /Tpe /aa -LD:\bcc55\lib ebv_cpp.obj ebv_asm.obj,ebv.exe,,F:\asm\tasm5\lib\import32.lib,ebv.def
del *.obj
del *.map
