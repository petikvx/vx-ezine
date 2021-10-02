C:\masm32\bin\ml /c /coff /Cp delayload.asm
C:\masm32\bin\link /DLL /DEF:delayload.def /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib delayload.obj delayload.res
pause
