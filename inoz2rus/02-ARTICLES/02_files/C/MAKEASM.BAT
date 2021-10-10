@echo off
set T32=c:\dev\tasm\
if exist del %1.obj
%T32%bin\tasm32.exe /s /ml /c /m9 /z /zi %1.asm
