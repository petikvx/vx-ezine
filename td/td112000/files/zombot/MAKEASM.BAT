@echo off
if exist zombot.exe del zombot.exe
if exist zombot.exe goto exit
%BCC55%bin\bcc32.exe -DZASM -3 -C -P -O1 -pr -ff -d -S -I%BCC55%include zombot.cpp
if not exist zombot.asm goto exit
%tasm32%tasm32 /m /ml /z zombot.asm
if not exist zombot.obj goto exit
%tasm32%tlink32 -Tpe -aa -x -c -B:0x10000000 -n -Af:2048 c0x32.obj zombot.obj,zombot.exe,,%tasm32%import32.lib
if not exist zombot.exe goto exit
del zombot.asm
del zombot.obj
dataencr.exe 1
:exit
