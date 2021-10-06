@ECHO OFF
IF (GOTO:)==(%1) %1%2 {Subroutine-Handler}

:: Check that the Operating System is suitable
ECHO/Not suitable for Windows NT/2000/XP&GOTO :EOF>NUL

:: Check that at least three parameters were passed, if not jump to USAGE
IF ()==(%3) GOTO USAGE

:: In this Batch file, we're going to recall ourselves to run the
:: _REPORT Subroutine. However, since we shall be using SHIFT to
:: loop through command-line parameters, we need to save the %0
:: name now, or it will be lost as soon as we use SHIFT. Therefore
:: we store the %0 name in variable SELF and use %SELF% for recalls.
SET SELF=%0

:: Start with a clear screen
CLS
ECHO.
ECHO.             Simple FTP operations from a Batch file - 6
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters,
ECHO. and list the filenames on the command line to PUT to remote site.
ECHO. (types *.cgi *.css *.htm *.html *.js *.pl and *.txt PUT as ASCII,
ECHO.  other types PUT as binary. Add any other file types, as desired)
ECHO.
ECHO. This example uses !command in the FTP script to recall Subroutine
ECHO. to display progress messages during the processing of the script.
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
:: The ! command runs a local command line, which can be a recall
:: of this Batch file, as here, where the _REPORT Subroutine is called
ECHO.!%SELF% GOTO: _REPORT Remote folder: /work/myfiles>>%TEMP%.\_FTP

:: Append FTP PUT commands for each file listed on
:: command line if the file exists on local system
:NEXTFILE
IF (%4)==() GOTO NOMORE

:: Identify whether to set ASCII or BINARY mode transfer by checking
:: the %4 parameter in turn against the set of ASCII extensions

:: Check for *.CGI (Common Gateway Interface script) - we append a :
:: (= colon) to the filename parameter and check for ".CGI:" to make
:: sure we are checking the extension against last three characters
:: in the file name. Otherwise FIND may locate the .CGI anywhere in
:: the filename (although it is very unlikely to occur elsewhere).
:: FIND /i (case insensitive) since file name may be upper or lowercase
ECHO. %4: | find /i ".CGI:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.CSS (Cascading Style Sheet file)
ECHO. %4: | find /i ".CSS:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.HTM (HyperText Markup Language file)
ECHO. %4: | find /i ".HTM:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.HTML (alternative EXTension for HyperText Markup Language file)
ECHO. %4: | find /i ".HTML:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.JS   (JavaScript file)
ECHO. %4: | find /i ".JS:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.PL   (PerL script)
ECHO. %4: | find /i ".PL:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Check for *.TXT  (standard TeXT file)
ECHO. %4: | find /i ".TXT:">NUL
IF NOT ERRORLEVEL 1 GOTO ASCII

:: Other types treated as BINARY
:: Set BINARY mode transfer
ECHO.binary>>%TEMP%.\_FTP
:: The ! command runs a local command-line, which can be a recall
:: of this Batch file, as here, where the _REPORT Subroutine is called
ECHO.!%SELF% GOTO: _REPORT Using binary mode for %4>>%TEMP%.\_FTP
GOTO CHECKWILD

:ASCII
:: Set ASCII mode transfer
ECHO.ascii>>%TEMP%.\_FTP
:: The ! command runs a local command-line, which can be a recall
:: of this Batch file, as here, where the _REPORT Subroutine is called
ECHO.!%SELF% GOTO: _REPORT Using ascii mode for %4>>%TEMP%.\_FTP

:CHECKWILD
:: Check if parameter is a wildcard. We enclose the parameter in
:: [brackets] simply to avoid ECHO.+wildcard (say *.*) expanding
:: in the form ECHO.*.* (if ECHO. is followed immediately by * or
:: a ? it generates an error).
ECHO.[%4]|find "*">NUL
IF NOT ERRORLEVEL 1 GOTO WILDCARD
ECHO.[%4]|find "?">NUL
IF NOT ERRORLEVEL 1 GOTO WILDCARD

:: Not a wildcard
IF EXIST %4 ECHO.put %4>>%TEMP%.\_FTP
:: The ! command runs a local command-line, which can be a recall
:: of this Batch file, as here, where the _REPORT Subroutine is called
ECHO.!%SELF% GOTO: _REPORT Transferring %4>>%TEMP%.\_FTP
SHIFT
GOTO NEXTFILE

:WILDCARD
IF EXIST %4 ECHO.mput %4>>%TEMP%.\_FTP
:: The ! command runs a local command-line, which can be a recall
:: of this Batch file, as here, where the _REPORT Subroutine is called
ECHO.!%SELF% GOTO: _REPORT Transferring files matching %4>>%TEMP%.\_FTP
SHIFT
GOTO NEXTFILE

:NOMORE
:: Finish building the script by adding a QUIT command, which will
:: close the FTP session and return control to this Batch file
ECHO.quit>>%TEMP%.\_FTP

ECHO. The FTP script has been created in file _FTP in your TEMP folder.
ECHO.
ECHO. Running script with command line: "ftp -i -s:%%TEMP%%.\_FTP>NUL"
ECHO.

:: This command line runs the script through the FTP command
:: (for help with FTP command-line switches, use: ftp -? )
:: We suppress session display with >NUL but progress messages will
:: still be displayed since they're explicitly redirected to CON
:: in the _REPORT Subroutine
ftp -i -s:%TEMP%.\_FTP>NUL

:: Delete the Script workfile and clear the SELF variable
DEL %TEMP%.\_FTP
SET SELF=

ECHO. Finished FTP session.
ECHO.

GOTO EOF {=Subroutine-section-below=}
:_REPORT (Usage: CALL %0 GOTO: _REPORT message to report)
:: Redirect the parameters passed explicity to CON in order to
:: the bypass >NUL redirection in FTP command line. If this
:: explicit redirection to CON is not used, the messages would
:: merely be redirected to NUL by the FTP command line

:: This Subroutine is called by each of the !commands in the FTP
:: script as it runs. This allows the display of progress messages
:: while the main session report is suppressed by >NUL redirection

ECHO. %3 %4 %5 %6 %7 %8 %9 >CON

GOTO EOF
:USAGE
ECHO.
ECHO.             Simple FTP operations from a Batch file - 6
ECHO.
ECHO. This Batch file is for illustration and syntax only. You must add
ECHO. your SiteName, UserName, and PassWord as command line parameters,
ECHO. and list the filenames on the command line to PUT to remote site.
ECHO. (types *.cgi *.css *.htm *.html *.js *.pl and *.txt PUT as ASCII,
ECHO.  other types PUT as binary. Add any other file types, as desired)
ECHO.
ECHO. Usage: %0 my.sitename.net MyUserName MyPassWord filenames...
ECHO.
ECHO. Connects to site: my.sitename.net, and then supplies:
ECHO. MyUserName as UserName and MyPassWord as the PassWord
ECHO.
ECHO. The list of filenames (after SiteName, UserName and the Password)
ECHO. are PUT to remote site, until list is finished (filename list can
ECHO. use wildcards, such as: *.htm *.css *.zip). ASCII/BINARY transfer
ECHO. mode is set from EXTension. Progress messages are displayed using
ECHO. a Batch Subroutine (that is called by the FTP script as it runs).
ECHO.

:EOF {End-of-file}
::               Component of StudyPack 5 - Batch FTP
::                     William and Linda Allen
:: (c) Copyright Allen & Company 2003 - all rights reserved (c)
