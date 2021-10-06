REM ******************************************
REM ******************************************
REM **                                      **
REM **       UPX simple GUI by Benji        **
REM **                                      **
REM **  Written by Benji on 31 August 2002  **
REM **      Contact me @ ICQ# 65355624      **
REM **                                      **
REM **          UPX version 1.22w           **
REM **      http://upx.sourceforge.net      **
REM **                                      **
REM ******************************************
REM ******************************************
TITLE UPX simple GUI by Benji
COLOR 3E
CLS
@ECHO OFF
ECHO  ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
ECHO  บ                                                                            บ
ECHO  บ         Copyright (c) 2002 and later - Benji - All rights reserved         บ
ECHO  บ                                                                            บ
ECHO  ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
ECHO.
ECHO.
ECHO           ษอป ษอป ษอป ษอป     ษอป ษอป ษอป     ษอป ษอป ษอป ษอป ษอป ษอป
ECHO           บRบ บiบ บPบ บpบ     บTบ บhบ บEบ     บsบ บYบ บsบ บTบ บeบ บMบ
ECHO           ศอผ ศอผ ศอผ ศอผ     ศอผ ศอผ ศอผ     ศอผ ศอผ ศอผ ศอผ ศอผ ศอผ
ECHO.
ECHO.
ECHO   Please select action (your file must be on desktop!):
ECHO.
GOTO QUESTION
:WRONG_ANSWER
ECHO   Please type a number from 1 to 6!!!
ECHO.
:QUESTION
ECHO    1) COMPRESS - Default operation, will compress the file specified.
ECHO    2) DECOMPRESS - Will uncompress the file you've just compressed.
ECHO    3) TEST - Tests the integrity of the compressed and uncompressed data.
ECHO    4) LIST - Prints out some information about the compressed files.
ECHO    5) VERSION - Prints the version of UPX.
ECHO    6) HELP - Prints the help and additional options.
ECHO.
SET /p ans=%1
IF "%ans%"=="1" GOTO COMPRESS
IF "%ans%"=="2" GOTO DECOMPRESS
IF "%ans%"=="3" GOTO TEST
IF "%ans%"=="4" GOTO LIST
IF "%ans%"=="5" GOTO VERSION
IF "%ans%"=="6" GOTO HELP
GOTO WRONG_ANSWER
:COMPRESS
ECHO   Please type the name of file to compress:
ECHO.
SET /p file=%2
ECHO.
ECHO   Choose compression level, from 1 (pretty fast, but light compression)
ECHO   to 10 (best compression, may take a long time). If you want to use the
ECHO   default compression level (8 for files smaller than 512 kb, 7 otherwise)
ECHO   type 0, if you want a super-awesome compression :-) type 11.
ECHO.
SET /p level=%3
IF "%level%"=="0" GOTO COMPRESS_DEFAULT
IF "%level%"=="10" GOTO COMPRESS_BEST
IF "%level%"=="11" GOTO COMPRESS_AWESOME
CLS
upx -"%level%" "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:COMPRESS_DEFAULT
CLS
upx "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:COMPRESS_BEST
CLS
upx --best "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:COMPRESS_AWESOME
CLS
upx --best --crp-ms=100000 "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:DECOMPRESS
ECHO   Please type the name of file to decompress:
ECHO.
SET /p file=%2
CLS
upx -d "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:TEST
ECHO   Please type the name of file to test:
ECHO.
SET /p file=%2
CLS
upx -t "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:LIST
ECHO   Please type the name of file to list:
ECHO.
SET /p file=%2
CLS
upx -l "%USERPROFILE%"\Desktop\\"%file%"
ECHO.
GOTO END
:VERSION
CLS
upx --version
ECHO.
GOTO END
:HELP
CLS
upx --help
ECHO.
GOTO END
:END
PAUSE
ECHO ON
EXIT