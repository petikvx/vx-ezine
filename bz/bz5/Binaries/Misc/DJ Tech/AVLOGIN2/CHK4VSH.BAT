@echo off

REM ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
REM บ This batch file is intended to check for McAfee's Vshield 2.x      บ
REM บ Written by: DJ TECH @ McAfee PSET  June  1995                      บ
REM ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

REM REPLACE "XXX" WITH CURRENT VERSION NUMBER
CHKVSHLD 
if errorlevel 3 goto error3
if errorlevel 2 goto error2
if errorlevel 1 goto error1

:ERROR3
   echo ษออออออออออออออออออออออออออออออออออออออออออออออป
   echo บ  A CHKVSHLD internal error has occurred.     บ
   echo บ      Please contact the Help Desk.           บ
   echo ศออออออออออออออออออออออออออออออออออออออออออออออผ
   echo.
   pause
   echo ---------------------------------------------------------------------->>J:\USER\%USER_ID%\C4VSH.LOG
   K:\PUBLIC\SYSTIME >>J:\USER\%USER_ID%\C4VSH.LOG
   echo CHKVSHLD ErrorLevel 3 occured at above date / time >>J:\USER\%USER_ID%\C4VSH.LOG
   echo ---------------------------------------------------------------------->>K:\MCAFEE\ALLC4VSH.LOG
   K:\PUBLIC\SYSTIME >>K:\MCAFEE\ALLC4VSH.LOG
   echo CHKVSHLD ErrorLevel 3 occured at above date / time on User %USER_ID% >>K:\MCAFEE\ALLC4VSH.LOG
   
   REM THE NEXT LINE WOULD BE WHERE THE BATCH FILE WOULD LOGOUT THE USER IF AN ERROR OCCURED CHECKING FOR VSHIELD
   rem LOGOUT
   
goto end

:ERROR2
   echo ษออออออออออออออออออออออออออออออออออออออออออออออป
   echo บ VShield has not been installed on your PC.   บ
   echo บ     Access to network has been denied.       บ
   echo บ       Please contact the Help Desk.          บ
   echo ศออออออออออออออออออออออออออออออออออออออออออออออผ
   echo.
   pause
   echo ---------------------------------------------------------------------->>K:C4VSH.LOG
   F:\PUBLIC\SYSTIME >>K:C4VSH.LOG
   echo CHKVSHLD ErrorLevel 2 occured at above date / time >>K:C4VSH.LOG
   echo ---------------------------------------------------------------------->>X:\MCAFEE\ALLC4VSH.LOG
   F:\PUBLIC\SYSTIME >>X:\MCAFEE\ALLC4VSH.LOG
   echo CHKVSHLD ErrorLevel 2 occured at above date / time on User %USER_ID% >>X:\MCAFEE\ALLC4VSH.LOG

   REM THE NEXT LINE WOULD BE WHERE THE BATCH FILE WOULD LOGOUT THE USER NOT LOADING VSHIELD
   rem LOGOUT
   
goto end

:ERROR1
   echo ษออออออออออออออออออออออออออออออออออออออออออออออป
   echo บ An old version of VShield has been installed.บ
   echo บ Access to the network has been denied. Pleaseบ
   echo บ contact the Help Desk to have a new version  บ
   echo บ installed.                                   บ
   echo ศออออออออออออออออออออออออออออออออออออออออออออออผ
   echo.
   pause
   echo ---------------------------------------------------------------------->>K:C4VSH.LOG
   F:\PUBLIC\SYSTIME >>K:C4VSH.LOG
   echo CHKVSHLD ErrorLevel 1 occured at above date / time >>K:C4VSH.LOG
   echo ---------------------------------------------------------------------->>X:\MCAFEE\ALLC4VSH.LOG
   F:\PUBLIC\SYSTIME >>X:\MCAFEE\ALLC4VSH.LOG
   echo CHKVSHLD ErrorLevel 1 occured at above date / time on User %USER_ID% >>X:\MCAFEE\ALLC4VSH.LOG
   
   REM THE NEXT LINE WOULD LOGOUT THE USER IF THEY DID NOT HAVE THE SPECIFIC VERSION OF VSHIELD SPECIFIED
   REM OF COURSE THAT WOULD REQUIRE THE /V "XXXX" PARAMETER AT THE BEGINNING OF THIS BATCH FILE.
   rem LOGOUT
   goto end

:end
