@ECHO off

ECHO RMSIRCDE.BAT -- W32/Sircam-A Virus Beseitigungs-Werkzeug
ECHO Version 1.60 (deutsch)
ECHO Copyright (c) 2001, Sophos Plc, www.sophos.com
ECHO:

REM Falls als Text-Datei erhalten, bitte in RMSIRCDE.BAT umbenennen.
REM Bitte am DOS-Prompt RMSIRCDE.BAT eintippen oder
REM die Datei doppelklicken, um sie auszufuehren.


REM Braucht Schreibzugriff auf %windir%

if "%windir%"=="" goto nojoy
REM Das Programm REGEDIT.EXE wird benoetigt.
if not exist %windir%\regedit.exe goto noreg
REM Die Umgebungsvariable %windir% muss gesetzt sein.


ECHO REGEDIT4>%windir%\sirc.reg
ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunServices]>>%windir%\sirc.reg
ECHO "Driver32"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO [HKEY_CLASSES_ROOT\exefile\shell\open\command]>>%windir%\sirc.reg
ECHO @="\"%%1\" %%*">>%windir%\sirc.reg
ECHO [HKEY_LOCAL_MACHINE\SOFTWARE\SirCam]>>%windir%\sirc.reg
ECHO "FB1B"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FB1BA"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FB1BB"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FC0"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FC1"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FC9"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FD1"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FD2"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FD3"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg
ECHO "FD7"="Overwritten when removing W32/Sircam-A, please delete.">>%windir%\sirc.reg

ECHO Kopieren von REGEDIT.EXE nach REGEDIT.COM
COPY %windir%\regedit.exe %windir%\regedit.com > NUL
ECHO Entferne Vireneintraege aus der Registry
start /w %windir%\regedit.com /s %windir%\sirc.reg
ECHO Entferne REGEDIT.COM
DEL %windir%\regedit.com

ECHO Versuche Virendateien zu loeschen
if exist %windir%\system\scam32.exe ATTRIB -H %windir%\system\scam32.exe
if exist %windir%\system\scam32.exe DEL %windir%\system\scam32.exe
if exist %windir%\system32\scam32.exe ATTRIB -H %windir%\system32\scam32.exe
if exist %windir%\system32\scam32.exe DEL %windir%\system32\scam32.exe

if exist c:\recycled\sirc32.exe ATTRIB -H c:\recycled\sirc32.exe
if exist c:\recycled\sirc32.exe DEL c:\recycled\sirc32.exe
if exist %TEMP%\sirc32.exe DEL %TEMP%\sirc32.exe
if exist %windir%\run32.exe ATTRIB -H -R -S %windir%\run32.exe
if exist %windir%\rundll32.exe ATTRIB -H -R -S %windir%\rundll32.exe
if exist %windir%\run32.exe DEL %windir%\rundll32.exe
if exist %windir%\run32.exe rename %windir%\run32.exe %windir%\rundll32.exe
if exist %windir%\scmx32.exe DEL %windir%\scmx32.exe
if exist %windir%\Startmen―Programme\Autostart\"Microsoft Internet Office.exe" DEL %windir%\Startmen―Programme\Autostart\"Microsoft Internet Office.exe"
if exist %USERPROFILE%\Startmen―Programme\Autostart\"Microsoft Internet Office.exe" DEL %USERPROFILE%\Startmen―Programme\Autostart\"Microsoft Internet Office.exe"
if exist c:\recycled\Sircam.sys DEL c:\recycled\Sircam.sys

REM Folgende Zeilen gelten, wenn Windows nicht im Laufwerk C: installiert ist.
if exist %windir%\..\recycled\sirc32.exe ATTRIB -H %windir%\..\recycled\sirc32.exe
if exist %windir%\..\recycled\sirc32.exe DEL %windir\..\recycled\sirc32.exe
if exist %windir%\..\recycled\Sircam.sys DEL %windir%\..\recycled\Sircam.sys

ECHO Entferne Arbeitsdatei
DEL %windir%\sirc.reg
ECHO:
ECHO:
ECHO Fertig. Scannen Sie dieses System mit einer aktuellen Version von
ECHO Sophos Anti-Virus, inkl. den neuesten Virendefinitionen (IDE-Files).
ECHO:
ECHO:
ECHO                  Als letzte Massnahme, muessen Sie nun
ECHO          Ihren Papierkorb (Recycle Bin) auf Ihrem Rechner leeren!
ECHO:
goto end

:nojoy
ECHO:
ECHO          Ihre Windows Umgebungsvariable ist nicht gesetzt. 
ECHO      Die W32/Sircam-A Desinfektion kann nicht durchgefuehrt werden.
ECHO            Bitte starten Sie Ihren Rechner neu und setzen 
Echo       Sie die Umgebungsvariable %windir% auf Ihr Windows Verzeichnis!             
ECHO:
ECHO:
ECHO        Bei weiteren Fragen kontaktieren Sie den Technischen Support.
ECHO                 Sophos Technischer Support: +49 6136 91193
ECHO:
goto end

:noreg
ECHO:
ECHO     REGEDIT.EXE ist in Ihrem %windir% Verzeichnis nicht vorhanden.
EchO     Die W32/Sircam-A Desinfektion kann nicht durchgefuehrt werden.
ECHO  Kopieren Sie die REGEDIT.EXE von einem sauberen Rechner mit dem gleichen 
ECHO       Betriebssystem in das %windir% Verzeichnis Ihres Computers.
ECHO:
ECHO:
ECHO       Bei weiteren Fragen kontaktieren Sie den Technischen Support.          
ECHO                  Sophos Technischer Support: +49 6136 91193
ECHO:
goto end

:end
pause

