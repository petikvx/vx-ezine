@ECHO OFF
IF '%2'=='' GOTO Syntax
ECHO N DI$K$PAC.$$$> DISKSPAC.SCR
ECHO RBX>>           DISKSPAC.SCR
ECHO %1>>            DISKSPAC.SCR
ECHO RCX>>           DISKSPAC.SCR
ECHO %2>>            DISKSPAC.SCR
ECHO W>>             DISKSPAC.SCR
ECHO Q>>             DISKSPAC.SCR
DEBUG < DISKSPAC.SCR > NUL
DEL DISKSPAC.SCR
IF NOT EXIST DI$K$PAC.$$$ GOTO NoRoom
DEL DI$K$PAC.$$$
ECHO Requested disk space is available
GOTO End
:NoRoom
ECHO Requested disk space is not available
:End
