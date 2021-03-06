@echo off
REM ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
REM Ί This batch file is intended to run McAfee's SCAN v2.x and echo any Ί
REM Ί error messages back to the users screen for diagnostic purposes    Ί
REM Ί         Written by: DJ TECH @ McAfee PSET June 1995                Ί
REM ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
CLS
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί                        **  ATTENTION  **                           Ί
echo Ί         Scanning your local drives before allowing login!          Ί
echo Ί            Written by: DJ TECH @ McAfee PSET June 1995             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo .
REM SCAN C:\ WILL JUST SCAN MBR AND ROOT DIRECTORY FOR VIRUSES
REM SCAN /ADL /NOBREAK WILL SCAN MBR AND WHOLE HARD DRIVE FOR VIRUSES
REM SCAN /ADL /NOBREAK
REM SCAN C:\ /ALL /PAUSE /REPORT k:lastscan.rpt /frequency 4 
O:\SCAN C: /NOBREAK /PAUSE /report k:lastscan.rpt 

if errorlevel 21 goto error21
if errorlevel 20 goto error20
if errorlevel 18 goto error18
if errorlevel 17 goto error17
if errorlevel 16 goto error16
if errorlevel 15 goto error15
if errorlevel 14 goto error14
if errorlevel 13 goto error13
if errorlevel 12 goto error12
if errorlevel 11 goto error11
if errorlevel 10 goto error10
if errorlevel 9 goto error9
if errorlevel 8 goto error8
if errorlevel 7 goto error7
if errorlevel 6 goto error6
if errorlevel 5 goto error5
if errorlevel 4 goto error4
if errorlevel 3 goto error3
if errorlevel 2 goto error2
if errorlevel 1 goto error1
if errorlevel 0 goto error0
goto end

:error21
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                        ***  NON-CRITICAL ERROR  ***  Ί
echo Ί A "system" error has occured while SCANNING your local drives for viruses.Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί ErrorLevel=21+                                                            Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
pause
echo ---------------------------------------------------------------------      >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo A "system" error has occured while SCANNING your local drives for viruses. >>K:SCAN.LOG 
echo ErrorLevel 21 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo A "system" error has occured while SCANNING your local drives for viruses. >>o:\viruslog\allscan.log
echo ErrorLevel 21 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto END

:error20
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                        ***  NON-CRITICAL ERROR  ***  Ί
echo Ί The SCANNING /FREQUENCY is set to ON and your last SCAN falls within an   Ί
echo Ί acceptable time frame.                                                    Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί ErrorLevel=20                                                             Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
rem pause
goto AFTEREND

:error18
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί A validation file has been modified (/CF or /CV options).                 Ί
echo Ί ErrorLevel=18                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo A validation file has been modified (/CF or /CV options).                  >>K:SCAN.LOG
echo ErrorLevel 18 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo A validation file has been modified (/CF or /CV options).                  >>o:\viruslog\allscan.log
echo ErrorLevel 18 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto END

:error17
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί No drive, directory or file was specified; nothing to scan.               Ί
echo Ί ErrorLevel=17                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG  
echo No drive, directory or file was specified; nothing to scan.                >>K:SCAN.LOG  
echo ErrorLevel 17 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo No drive, directory or file was specified; nothing to scan.                >>o:\viruslog\allscan.log  
echo ErrorLevel 17 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto END
        
:error16
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An error occured while accessing a specified drive or file.               Ί
echo Ί ErrorLevel=16                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An error occured while accessing a specified drive or file.                >>K:SCAN.LOG
echo ErrorLevel 16 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An error occured while accessing a specified drive or file.                >>o:\viruslog\allscan.log
echo ErrorLevel 16 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error15
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί VirusScan self-check failed. It may be infected or damaged.               Ί
echo Ί ErrorLevel=15                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo VirusScan self-check failed. It may be infected or damaged.                >>K:SCAN.LOG
echo ErrorLevel 15 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo VirusScan self-check failed. It may be infected or damaged.                >>o:\viruslog\allscan.log
echo ErrorLevel 15 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.                                                                           
goto end

:error14
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί The SCAN.DAT file is out of date; upgrade VirusScan data files.           Ί
echo Ί ErrorLevel=14                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo The SCAN.DAT file is out of date; upgrade VirusScan data files.            >>K:SCAN.LOG
echo ErrorLevel 14 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo The SCAN.DAT file is out of date; upgrade VirusScan data files.            >>o:\viruslog\allscan.log
echo ErrorLevel 14 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error13
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  VIRUS  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses         Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί One or more viruses were found in the master boot record, or boot sector, Ί
echo Ί or a virus(s) were found in the files listed.                             Ί
echo Ί ErrorLevel=13                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo Virus(s) were found in the MBR or LBS, or were found in the files listed.  >>K:SCAN.LOG
echo ErrorLevel 13 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo Virus(s) were found in the MBR or LBS, or were found in the files listed.  >>o:\viruslog\allscan.log
echo ErrorLevel 13 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto NOTINMEM
                  
:error12
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An error occured while attempting to remove a virus, such as no           Ί
echo Ί CLEAN.DAT file found, or VirusScan was unable to remove the virus.        Ί
echo Ί ErrorLevel=12                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo Error removing a virus, such as no CLEAN.DAT, unable to remove the virus.  >>K:SCAN.LOG       
echo ErrorLevel 12 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo Error removing a virus, such as no CLEAN.DAT, unable to remove the virus.  >>o:\viruslog\allscan.log       
echo ErrorLevel 12 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end
                  
:error11
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An internal program error occurred.                                       Ί
echo Ί ErrorLevel=11                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An internal program error occurred.                                        >>K:SCAN.LOG
echo ErrorLevel 11 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An internal program error occurred.                                        >>o:\viruslog\allscan.log
echo ErrorLevel 11 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error10
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  VIRUS  ***     Ί
echo Ί A virus found in memory this could be an actual virus or traces left from Ί
echo Ί a prior operation. Possibly a false alarm generated by a conflict or TSR. Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί A virus was found in memory.                                              Ί
echo Ί ErrorLevel=10                                                             Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo A virus was found in memory.                                               >>K:SCAN.LOG 
echo ErrorLevel 10 occured at above date / time                                 >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo A virus was found in memory.                                               >>o:\viruslog\allscan.log 
echo ErrorLevel 10 occured at above date / time on User %log_name%              >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto critical

:error9
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί Incompatible or unrecognized option(s) or arguements were specified       Ί
echo Ί ErrorLevel=9                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo Incompatible or unrecognized option(s) or arguements were specified        >>K:SCAN.LOG
echo ErrorLevel 9 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo Incompatible or unrecognized option(s) or arguements were specified        >>o:\viruslog\allscan.log
echo ErrorLevel 9 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error8
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί A file required to run VirusScan, such as SCAN.DAT, is missing.           Ί
echo Ί ErrorLevel=8                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo A file required to run VirusScan, such as SCAN.DAT, is missing.            >>K:SCAN.LOG
echo ErrorLevel 8 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo A file required to run VirusScan, such as SCAN.DAT, is missing.            >>o:\viruslog\allscan.log
echo ErrorLevel 8 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error7
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An error in accessing an international message file (MCAFEE.MSG)          Ί
echo Ί ErrorLevel=7                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An error in accessing an international message file (MCAFEE.MSG)           >>K:SCAN.LOG
echo ErrorLevel 7 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An error in accessing an international message file (MCAFEE.MSG)           >>o:\viruslog\allscan.log
echo ErrorLevel 7 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error6
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An internal program error occurred.                                       Ί
echo Ί ErrorLevel=6                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An internal program error occurred.                                        >>K:SCAN.LOG
echo ErrorLevel 6 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An internal program error occurred.                                        >>o:\viruslog\allscan.log
echo ErrorLevel 6 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error5
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  MEMORY ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί Insufficient memory to load program or complete operation.                Ί
echo Ί ErrorLevel=5                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo Insufficient memory to load program or complete operation.                 >>K:SCAN.LOG
echo ErrorLevel 5 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo Insufficient memory to load program or complete operation.                 >>o:\viruslog\allscan.log
echo ErrorLevel 5 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error4
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An error occured while accessing the file created with the /AF option.    Ί
echo Ί ErrorLevel=4                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An error occured while accessing the file created with the /AF option.     >>K:SCAN.LOG
echo ErrorLevel 4 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An error occured while accessing the file created with the /AF option.     >>o:\viruslog\allscan.log
echo ErrorLevel 4 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error3
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί An error occured while accessing a disk (reading or writing).             Ί
echo Ί ErrorLevel=3                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo An error occured while accessing a disk (reading or writing).              >>K:SCAN.LOG
echo ErrorLevel 3 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo An error occured while accessing a disk (reading or writing).              >>o:\viruslog\allscan.log
echo ErrorLevel 3 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error2
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  ERROR  ***     Ί
echo Ί An error has occured while SCANNING your local drives for viruses.        Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί A VirusScan database (*.DAT) file is corrupted.                           Ί
echo Ί ErrorLevel=2                                                              Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo A VirusScan database (*.DAT) file is corrupted.                            >>K:SCAN.LOG
echo ErrorLevel 2 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo A VirusScan database (*.DAT) file is corrupted.                            >>o:\viruslog\allscan.log
echo ErrorLevel 2 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error1
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  WARNING  ***                                  ***  VIRUS  ***     Ί
echo Ί A virus has been detected by VirusScan.                                   Ί
echo Ί Please refer to your documentation or contact SYSADMIN / Help Desk        Ί
echo ΜΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΉ
echo Ί Error occured while accessing a file (reading or writing).                Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.                                 
pause
echo ----------------------------------------------------------------------     >>K:SCAN.LOG
z:\SYSTIME                                                                      >>K:SCAN.LOG
echo Error occured while accessing a file (reading or writing).                 >>K:SCAN.LOG
echo ErrorLevel 1 occured at above date / time                                  >>K:SCAN.LOG
echo ----------------------------------------------------------------------     >>o:\viruslog\allscan.log
z:\SYSTIME                                                                      >>o:\viruslog\allscan.log
echo Error occured while accessing a file (reading or writing).                 >>o:\viruslog\allscan.log
echo ErrorLevel 1 occured at above date / time on User %log_name%               >>o:\viruslog\allscan.log
echo %log_name% is located at station number %station%                          >>o:\viruslog\allscan.log 
echo.
goto end

:error0
echo.
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί    ***  ALL GOOD  ***                            *** NO PROBLEMS  ***     Ί
echo Ί              Everything ran fine.  There is no problem!                   Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo.
rem pause not needed when everything is ok
echo.
goto afterend

:end
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί       A NON-CRITICAL ERROR HAS OCCURED, PLEASE MAKE A NOTE OF IT          Ί
echo Ί            YOU WILL TEMPORARILY BE ALLOWED ONTO THE NETWORK               Ί
echo Ί                PLEASE CONTACT YOUR SYSTEM ADMINISTRATOR                   Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
pause
echo off
goto afterend

:notinmem
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί                   *** VIRUS ALERT ERROR ***                               Ί
echo Ί A VIRUS WAS FOUND, HOWEVER YOU WILL BE ALLOWED TO CONTINUE AT THIS TIME   Ί
echo Ί IF THE VIRUS CONTINUES YOU MAY NOT BE ALLOWED ONTO THE NETWORK NEXT TIME  Ί
echo Ί                                                                           Ί
echo Ί             PLEASE CONTACT THE SYSADMIN OR HELP DESK AT # xxxx            Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo off
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί  WOULD YOU LIKE TO ATTEMPT TO CLEAN THE VIRUS NOW? (y/n)                  Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
choice /c:yn /t:y,10
if errorlevel 2 goto afterend
if errorlevel 1 goto clean
goto afterend

:CRITICAL
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί                   *** CRITICAL VIRUS ERROR ***                            Ί
echo Ί    SINCE A CRITICAL ERROR HAS OCCURED YOU ARE NOW BEING LOGGED OFF        Ί
echo Ί             PLEASE CONTACT THE SYSADMIN OR HELP DESK AT # xxxx            Ί
echo Ί                                                                           Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
echo off
echo.
z:\LOGOUT.EXE
goto offnet

:afterend
rem the syntax of the following line is critical; if there is a space after = it will not work!
set SCAN=YES
echo off
echo ΙΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝ»
echo Ί  Thank you for running VirusScan         Ί
echo Ί Scanning has completed successfully      Ί
echo ΘΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΝΌ
goto offnet

:clean
rem next line for users that found a virus ERRORLEVEL 13, not in memory just on hard drive
O:\SCAN C: /NOBREAK /report k:lastscan.rpt /frequency 96 /clean
goto afterend

:offnet
rem very end!

