@echo off
batmen -t "Welcome to BatMenu" -k "*intro 1" 0 0 24 80
batmen -t "Welcome to BatMenu" -k "*intro 2" 3 3 18 74
batmen -t "Shareware is Great!" -k "*intro 3" 4 16 16 38
batmen -t "Shareware is Great!" -k "*intro 4" 4 16 16 49
batmen -t "Titles are Optional" -l 8 -k "*menu1" 4 16 11 46
if errorlevel 9 goto nine
if errorlevel 8 goto eight
if errorlevel 7 goto seven
if errorlevel 6 goto six
if errorlevel 5 goto five
if errorlevel 4 goto four
if errorlevel 3 goto three
if errorlevel 2 goto two
if errorlevel 1 goto one
if errorlevel 0 goto zero
goto next
:nine
echo You chose selection nine
goto next
:eight
echo You chose selection eight
goto next
:seven
echo You chose selection seven
goto next
:six
echo You chose selection six
goto next
:five
echo You chose selection five
goto next
:four
echo You chose selection four
goto next
:three
echo You chose selection three
goto next
:two
echo You chose selection two
goto next
:one
echo You chose selection one
goto next
:zero
echo You chose selection zero
:next
pause
batmen -l 8 -k "*menu2" 4 16 9 46
batmen -k "*menu3" 0 50 11 12
batmen -t "Please Support Shareware!" -k "*menu4" 4 5 11 75
if errorlevel 9 goto end
batmen -c -t "Please Support Shareware!" -k "*menu5" 1 2 22 75
:end
