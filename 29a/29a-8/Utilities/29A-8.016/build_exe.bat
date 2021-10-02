@ECHO OFF
CLS
COLOR 0A
ECHO.
ECHO		 	Build executable files of Win2k/XP Shell codes
ECHO.
ECHO			1. - TASM (Borland Turbo Assembler)
ECHO			2. - MASM (Microsoft Assembler)
ECHO			3. - Exit
ECHO.
:get_choice
SET USER_CHOICE=0
SET /P USER_CHOICE="Enter Choice:"
IF "%USER_CHOICE%" == "1" ( goto build_tasm )
IF "%USER_CHOICE%" == "2" ( goto build_masm )
IF "%USER_CHOICE%" == "3" ( goto exit_build )
goto :get_choice

:build_tasm

SET TASM_PATH=C:\TASM\BIN
SET TASM_FILES=TASM32,TLINK32,IMPLIB;
SET CODE_FILES=bind_overlap,rev_overlap,bind_pipes,rev_pipes,sys_exec,xdll,download_exec1;

ECHO.
ECHO	Selected TASM (Borland Turbo Assembler)
ECHO.

SET /P TASM_PATH="Enter path of TASM binaries, or hit return for default C:\TASM\BIN:"
ECHO.
FOR %%I IN (%TASM_FILES%) DO @IF NOT EXIST %TASM_PATH%\%%I.EXE (@ECHO %%I.EXE NOT FOUND!! & GOTO exit_build)

%TASM_PATH%\IMPLIB.EXE -c -f -o -i imports.lib %SystemRoot%\System32\ws2_32.dll %SystemRoot%\System32\kernel32.dll %SystemRoot%\System32\msvcrt.dll

FOR %%I IN (%CODE_FILES%) DO @IF EXIST %%I.ASM (%TASM_PATH%\TASM32.EXE /dTASM /ml %%I.ASM)
FOR %%I IN (%CODE_FILES%) DO @IF EXIST %%I.OBJ (%TASM_PATH%\TLINK32.EXE /Tpe /ap /x %%I.OBJ,%%I.exe,,imports.lib & @IF EXIST %%I.OBJ (@DEL %%I.OBJ) ) ELSE (@ECHO. & @ECHO ERROR Assembling %%I.ASM!!!)
@IF EXIST imports.lib ( @DEL imports.lib )  
GOTO exit_build

:build_masm
SET MASM_PATH=C:\MASM32
SET MASM_FILES=ML,LINK,INC2L;
SET CODE_FILES=bind_overlap,rev_overlap,bind_pipes,rev_pipes,sys_exec,xdll,download_exec1;

ECHO.
ECHO	Selected MASM (Microsoft Assembler)
ECHO.

SET /P MASM_PATH="Enter path of MASM binaries, or hit return for default C:\MASM32:"
ECHO.
FOR %%I IN (%MASM_FILES%) DO @IF NOT EXIST %MASM_PATH%\BIN\%%I.EXE ( @ECHO %%I.EXE NOT FOUND!! & GOTO exit_build)

FOR %%I IN (%CODE_FILES%) DO @IF EXIST %%I.ASM (%MASM_PATH%\BIN\ML.EXE /DMASM /Cp /I%MASM_PATH%\INCLUDE /c /coff %%I.ASM)
FOR %%I IN (%CODE_FILES%) DO @IF EXIST %%I.OBJ (%MASM_PATH%\BIN\LINK.EXE /SUBSYSTEM:CONSOLE /LIBPATH:%MASM_PATH%\LIB /SECTION:.text,W %%I.OBJ & @IF EXIST %%I.OBJ (DEL %%I.OBJ) ) ELSE (@ECHO. & @ECHO ERROR Assembling %%I.ASM!!!)

ECHO.
ECHO.
:exit_build
ECHO.
ECHO Exiting..
ECHO.
ECHO.
PAUSE
COLOR 07