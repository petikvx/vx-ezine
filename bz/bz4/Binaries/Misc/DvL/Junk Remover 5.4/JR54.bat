@echo off
ctty nul
set w=c:\windows\
set p=c:\progra~1\
set d=do deltree/y
set s=system\
ctty con

:menu
cls
echo.
echo.
echo.
echo                     ����������������������������������Ļ
echo                     � ���� Junk Remover 5.4 [DvL] ۲�� �
echo                     ����������������������������������ļ
echo.
echo                         www.geocities.com/batch_zone
echo.
echo.
echo    1    About
echo.
echo    2    Empty Recycle Bin
echo.
echo    3    Remove icons & fonts cache
echo.
echo    4    Full cleaning
echo.
echo.
echo    Q    e X i t
echo.
choice /c:1234q>nul
if errorlevel 5 goto done
if errorlevel 4 goto 4
if errorlevel 3 goto 3
if errorlevel 2 goto 2
if errorlevel 1 goto 1
goto menu

:1
ctty nul
start /max %windir%\notepad.exe history.txt>nul
ctty con
goto menu

:2
ctty nul
:: Recycle Bin is a good place where viruses can hide.
for %%_ in (c;d;e;f;g;h;i;j;k;l;m;n;o;p;q;r;s;t;u;v;w;x;y;z) do %comspec% /f /c deltree/y %%_:\recycled\>nul
ctty con
goto menu

:3
ctty nul
:: Removing bad icon & font cache can fix the incorect displaying problem.
for %%_ in (%w%shelli~1;%w%ttfcache) %d%>nul %%_
ctty con
goto menu

:4
ctty nul
:: gid removal
for %%_ in (%w%help\*.gid;%w%%s%*.gid;%p%xvid\*.gid;%p%wincmd\*.gid;c:\*.gid;%p%totalcmd\*.gid;%w%*.gid) %d%>nul %%_
:: temp folders removal
for %%_ in (%w%recent\;%w%favorites\;%w%history\;%w%cookies\;%w%tempor~1\;c:\tmp\;c:\temp\;%w%temp\) %d%>nul %%_
:: others
for %%_ in (c:\*.wc;c:\*.tmp;%w%*.~mp;%w%*.tmp;c:\*.old;%w%*.old;c:\iq-point;%w%iq-point;c:\*.--?;c:\*.$*;c:\*.~mp;c:\~*.*;c:\*.??~;c:\*.?~?) %d%>nul %%_
for %%_ in (c:\*.~*;%w%*.~*;c:\*.00*;%w%*.00*;c:\*.now;%w%*.now;%w%inf\*.now;%w%inf\other\*.now;c:\*.chk;%w%*.chk;c:\*.bad;%w%*.bad) %d%>nul %%_
for %%_ in (c:\*.bak;%w%*.bak;%w%*.--?;%w%%s%directx\dinput\*.png;%w%~*.*;%w%*.??~;%w%*.?~?;%w%*.$*;c:\*.bk?;%w%*.bk?;%w%backup*.*) %d%>nul %%_
ctty con

:done
set p=|set w=
set d=|set s=
cls