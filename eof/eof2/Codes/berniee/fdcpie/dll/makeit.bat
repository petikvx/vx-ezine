@echo off
if exist test.obj del test.obj
if exist test.dll del test.dll
\masm32\bin\ml /c /coff test.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:test.def test.obj 
del test.obj
del test.exp
dir test.*
pause
