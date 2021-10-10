@echo off
set ASMLIBS=\asm\lib
set ASMBIN=\asm\bin
if not exist %AMSLIBS%\msvcrt.lib %ASMBIN%\implib %ASMLIBS%\msvcrt.lib c:\windows\system\msvcrt.dll
%ASMBIN%\tasm32  /ml /m /dCOMPRESS lzce32.asm,lz32comp
%ASMBIN%\tlink32 /x /Tpe /aa /c /L%ASMLIBS% lz32comp,lz32comp,,import32 msvcrt,,,,,,
%ASMBIN%\tasm32  /ml /m /dDECOMPRESS lzce32.asm,lz32dcmp
%ASMBIN%\tlink32 /x /Tpe /aa /c /L%ASMLIBS% lz32dcmp,lz32dcmp,,import32 msvcrt,,,,,,
