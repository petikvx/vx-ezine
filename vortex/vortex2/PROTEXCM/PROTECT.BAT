echo off
rem ONLY USE THIS FOR FILES THAT HAVE NOT ALREADY BEEN PKLITED OR LZEXED!!!
cls
if exist %1.%2 goto filefound
echo To use PROTECT.BAT, the first parameter is the name part of the filename
echo  and the second part is the extension:
echo ÿ
echo Here is an example to protect MYPROG.EXE:
echo   PROTECT MYPROG EXE
echo Here is an example to protect MYPROG.COM:
echo   PROTECT MYPROG COM
echo ÿ
echo (Basically, just leave out the period and use a space between the
echo  filename and the extension.)
echo ÿ
echo Please only use this on files that have not already been compressed!!!
goto end
:filefound
if %2==COM goto comfile
if %2==com goto comfile
if %2==Com goto comfile
if %2==COm goto comfile
if %2==cOM goto comfile
if %2==cOm goto comfile
if %2==coM goto comfile
del %1.old >NUL
del %1.tmp >NUL
rem YOU CAN USE PKLITE BELOW, BUT USE THE -B (BACKUP) OPTION AND CHANGE
REM THE SUFFIXES FROM .OLD TO .BAK!!!!!!!!!!!!!!
lzexe %1.EXE 
if exist %1.old goto exenormal
echo %1.EXE could not be compressed by LZEXE...
goto end    
:exenormal
ren %1.old %1.tmp
protexcm %1.EXE Put the desired password here!!!
del %1.old >NUL
ren %1.tmp %1.old
echo %1.EXE has been protected, %1.OLD is the original!
goto end
:comfile
rem SEE THE COMMENT ABOVE ABOUT PKLITE, BUT ON COM FILES!!!!!!!
protexcm %1.COM Put the desired password here!!!
:end