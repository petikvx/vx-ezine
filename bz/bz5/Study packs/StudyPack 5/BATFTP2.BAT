@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Check that three parameters were passed, if not jump to USAGE
IF ()==(%3) GOTO USAGE

:: Start with a clear screen
CLS
ECHO.
ECHO.             Simple FTP operations from a Batch file - 2
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters.
ECHO.
ECHO. FTP to remote site: %1
ECHO.

:: First create a script of the FTP commands with ECHO+redirection

:: Start a Script file: we use %1 as the sitename
ECHO.open %1>%TEMP%.\_FTP

:: Append further lines with >> append operator

:: Append parameter %2 as the UserName
ECHO.%2>>%TEMP%.\_FTP

:: Append parameter %3 as the PassWord
ECHO.%3>>%TEMP%.\_FTP

:: Specify your own CD command for correct remote subfolder
ECHO.cd /work/myfiles>>%TEMP%.\_FTP

:: Append your own FTP commands, for example PUT or GET
:: (these two commands are purely illustrative)
ECHO.put localfile.htm>>%TEMP%.\_FTP
ECHO.get remotefile.htm>>%TEMP%.\_FTP

:: Finish building the script by adding a QUIT command, which will
:: close the FTP session and return control to this Batch file
ECHO.quit>>%TEMP%.\_FTP

ECHO. The FTP script is created in file _FTP in TEMP folder as follows:
ECHO.
TYPE %TEMP%.\_FTP
ECHO.
ECHO. Running script with command line: "ftp -i -s:%%TEMP%%.\_FTP"
ECHO. To suppress session display, use: "ftp -i -s:%%TEMP%%.\_FTP>NUL"
ECHO. To log the FTP session, use line: "ftp -i -s:%%TEMP%%.\_FTP>LOGFILE.TXT"
ECHO. (Omit the "quotes" around the example command lines above)
ECHO.
ECHO. Connecting to site: %1 ...
ECHO.

:: This command line runs the script through the FTP command
:: (for help with FTP command-line switches, use: ftp -? )
ftp -i -s:%TEMP%.\_FTP
:: To suppress session display, use: ftp -i -s:%TEMP%.\_FTP>NUL
:: To log the FTP session, use line: ftp -i -s:%TEMP%.\_FTP>LOGFILE.TXT

:: Delete the Script workfile
DEL %TEMP%.\_FTP

ECHO. Finished FTP session.
ECHO.
GOTO EOF

:USAGE
ECHO.
ECHO.             Simple FTP operations from a Batch file - 2
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters.
ECHO.
ECHO. Usage: %0 my.sitename.net MyUserName MyPassWord
ECHO.
ECHO. Connects to site: my.sitename.net, and then supplies:
ECHO. MyUserName as UserName and MyPassWord as the PassWord
ECHO.

:EOF {End-of-file}
::               Component of StudyPack 5 - Batch FTP
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
