@ECHO OFF

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Check that at least three parameters were passed, if not jump to USAGE
IF ()==(%3) GOTO USAGE

:: Start with a clear screen
CLS
ECHO.
ECHO.             Simple FTP operations from a Batch file - 3
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters,
ECHO. and list the filenames on the command line to PUT to remote site.
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

:: Append FTP PUT commands for each file listed on
:: command line if the file exists on local system
:NEXTFILE
IF (%4)==() GOTO NOMORE
IF EXIST %4 ECHO.put %4>>%TEMP%.\_FTP
SHIFT
GOTO NEXTFILE

:NOMORE
:: Finish building the script by adding a QUIT command, which will
:: close the FTP session and return control to this Batch file
ECHO.quit>>%TEMP%.\_FTP

ECHO. The FTP script has been created in file _FTP in your TEMP folder.
ECHO.
ECHO. Running script with command line: "ftp -i -s:%%TEMP%%.\_FTP"
ECHO. To suppress session display, use: "ftp -i -s:%%TEMP%%.\_FTP>NUL"
ECHO. To log the FTP session, use line: "ftp -i -s:%%TEMP%%.\_FTP>LOGFILE.TXT"
ECHO. (Omit the "quotes" around the example command lines above)
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
ECHO.             Simple FTP operations from a Batch file - 3
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters,
ECHO. and list the filenames on the command line to PUT to remote site.
ECHO.
ECHO. Usage: %0 my.sitename.net MyUserName MyPassWord filenames...
ECHO.
ECHO. Connects to site: my.sitename.net, and then supplies:
ECHO. MyUserName as UserName and MyPassWord as the PassWord
ECHO.
ECHO. The list of filenames (after SiteName, UserName and the Password)
ECHO. are PUT in succession to the remote site, until list is finished.
ECHO.

:EOF {End-of-file}
::               Component of StudyPack 5 - Batch FTP
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
