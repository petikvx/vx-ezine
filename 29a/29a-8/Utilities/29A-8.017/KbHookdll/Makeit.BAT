@echo off

\masm32\bin\ml /c /coff /Cp KbHook.asm

\masm32\bin\Link /SECTION:.bss,S  /DLL /DEF:KbHook.def /SUBSYSTEM:WINDOWS /LIBPATH:\masm32\lib KbHook.obj

pause