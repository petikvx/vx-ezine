@echo off
@ver|find "XP"|if errorlevel 1 goto m|if not errorlevel 1 exit
:m
cls
echo.
echo.
echo.
echo                     ÉÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ»
echo                     ³ °±²Û Junk Remover 5.3 [DvL] Û²±° ³ 
echo                     ÈÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¼
echo.
echo                  www.geocities.com/ratty_dvl/BATch/main.htm
echo.
echo.
echo.
echo    1    About
echo.
echo    2    Empty Recycle Bin
echo.
echo    3    Full cleaning
echo.
echo.
echo    X    Get me outta here !
echo.
choice /c:123X>nul
if errorlevel 4 goto done
if errorlevel 3 goto 3
if errorlevel 2 goto 2
if errorlevel 1 goto 1
goto done

:1
ctty nul
start /max %windir%\notepad.exe readme.txt>nul
ctty con
goto m
:2
ctty nul
set r=:\recycled\
set c=command /f /c attrib -a -r -s -h
set d=command /f /c dir
set g=RECYCLED
set i=if not errorlevel 1 deltree/y
set j=if errorlevel 1 goto
set f=find
:d
%c% d:\%g%
%d% d:\>1
%f% "%g%" 1|%i% d%r%|%j% e
:e
%c% e:\%g%
%d% e:\>1
%f% "%g%" 1|%i% e%r%|%j% f
:f
%c% f:\%g%
%d% f:\>1
%f% "%g%" 1|%i% f%r%|%j% g
:g
%c% g:\%g%
%d% g:\>1
%f% "%g%" 1|%i% g%r%|%j% r
:r
deltree/y 1>nul
for %%a in (c%r%, h%r%, i%r%, j%r%, k%r%, l%r%, m%r%, n%r%, o%r%, p%r%, q%r%, r%r%, s%r%, t%r%, u%r%, v%r%, w%r%, x%r%, y%r%, z%r%) do deltree/y>nul %%a
set r=|set c=|set d=
set g=|set i=|set j=
set f=
ctty con
goto m
:3
ctty nul
set p=c:\progra~1\
set w=c:\windows\
set d=do deltree/y
set s=system\
for %%b in (%w%recent\, %w%favorites\, %w%history\, %w%cookies\, %w%tempor~1\, %p%wincmd\*.url, %p%winrar\*.txt, %p%xvid\*.url, %w%*.~*, c:\*.00*) %d%>nul %%b
for %%c in (%p%regcle~1\backups\, %w%help\*.gid, %w%%s%*.gid, %w%inf\other\*.now, c:\mypict~1\thumbs.db, %p%totalcmd\*.txt, %p%totalcmd\*.wri) %d%>nul %%c
for %%d in (c:\mydocu~1\mypict~1\thumbs.db, %w%shelli~1, %w%ttfcache, %w%locals~1\tempor~1\, %w%applic~1\micros~1\office\recent\, %p%totalcmd\*.url, c:\*.prv) %d%>nul %%d
for %%e in (%w%pchealth\helpctr\datacoll\, %p%window~2\*.log, %w%verlauf\, %p%belarc\advisor\%s%tmp\*.ht*, %p%cpu-z\*.ht*, %p%xvid\*.txt, %p%netscape\users\default\cache\) %d%>nul %%e
for %%f in (%p%office~1\*.log, %p%iolo\system~1\manu*.txt, %p%inocul~2\aup*.exe, %p%intern~1\*.txt, %p%plus!\*.txt, %p%xvid\*.gid, %w%web\wallpa~1\) %d%>nul %%f
for %%g in (c:\mirc\logs\, c:\mirc32\logs\, %p%mirc\logs\, %p%mirc32\logs\, %p%winamp\dem*.mp3, %p%winamp\*.txt, %p%winamp\*.ht*, %p%wincmd\*.txt) %d%>nul %%g
for %%h in (%p%xvid\*.ht*, %w%%s%directx\dinput\*.png, %w%sysbckup\rbbad.cab, %w%%s%sfp\*plog.txt, %w%%s%ff*.txt, %w%%s%advert.dll, %p%netscape\users\default\archive\) %d%>nul %%h
for %%i in (%w%applog\, %w%applic~1\tempor~1\, %w%index.dat, %w%msc*.dir, %w%msdownld.tmp, %w%backup*.wbk, %w%iq-point, %w%*.---, %w%*.$*) %d%>nul %%i
for %%j in (%w%*.~mp, %w%~*.*, %w%*.??~, %w%*.dos, %w%*.ftg, %w%*.fts, %w%*.nch, %w%*.now, %w%*.pch, %w%*.prv, %w%*.rws, %p%wincmd\*.gid, c:\*.gid) %d%>nul %%j
for %%k in (%w%*.?~?, %w%*.00*, %w%*.ilk, %w%*.log, %w%*.mtx, %w%*.ncb, %w%*.old, %w%*.sbr, %w%*.syd, %w%*.tmp, %w%*.txt, %p%totalcmd\*.gid, c:\*.aps) %d%>nul %%k
for %%l in (%w%*.aps, %w%*.wc, %w%*.wri, c:\msc*.dir, c:\msd*.tmp, c:\backup*.wbk, c:\*.---, c:\*.$*, c:\*.~*, c:\*.~mp, c:\~*.*, c:\*.??~, c:\*.?~?) %d%>nul %%l
for %%m in (%w%*.bad, c:\*.bad, c:\*.bak, c:\*.bk?, c:\*.bmk, c:\*.bsc, c:\*.rws, c:\*.syd, c:\*.tmp, c:\suhdlog.dat, %w%*.htz, %w%*.gid, %w%*.chk, %w%*.dmp) %d%>nul %%m
for %%n in (%w%*.bak, c:\*.chk, c:\*.db$, c:\*.dmp, c:\*.dos, c:\*.ftg, c:\*.sbr, c:\*.txt, c:\*.pch, %w%*.bsc, c:\*.wri, c:\*.mtx, c:\*.ilk, c:\*.htz) %d%>nul %%n
for %%o in (%w%*.bk?, c:\*.fts, c:\*.log, c:\*.ncb, c:\*.nch, c:\*.now, c:\*.wc, c:\iq-point, %w%*.db$, c:\*.old, %w%*.bmk, c:\tmp\, c:\temp\, %w%temp\) %d%>nul %%o
for %%p in (%w%%s%sfp\ie\msc*.dir, %p%intern~1\w2k\msc*.dir, %p%common~1\micros~1\triedit\msc*.dir, %p%common~1\micros~1\msinfo\msc*.dir, %w%inf\*.now) %d%>nul %%p
set p=|set w=
set d=|set s=
ctty con
:done
cls