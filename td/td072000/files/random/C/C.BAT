@echo off
if /%1==/ goto exit
if exist %1.exe del %1.exe
X:\BC\BIN\BCC32.EXE -5 -C -P -a8 -O2 -d -pr -ff -tWM -lap %1.c
if exist %1.obj del %1.obj
:exit
