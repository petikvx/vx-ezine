@echo off
echo off
cls
echo Generating a testset for testing polymorph viruses....
echo Press a key to generate approx. 4000? test samples or Crtl-C to bail out
pause
rosegoat /STart=5000 /dec=10 /END=200
rosegoat /STart=60000 /dec=200  /Filler=$CC
rosegoat /STart=60000 /dec=250 /call /Filler=0
rosegoat /STart=60000 /dec=250 /jmp /Filler=0
rosegoat /STart=60000 /dec=250 /ZM /EXE
rosegoat /STart=1500 /dec=1 /end=200 /Filler=0
rosegoat /trash /Start=17000
rosegoat /rom /Dec=200
rosegoat /hex /dec=100
rosegoat /asc /dec=75
rosegoat /asc /zm /Filler=0
del testit.bat > nul
echo @echo off > polytest.bat
for %%A in (ROS*.*) do echo %%A >> polytest.bat
echo Now run POLYTEST.BAT... and delete ROSEGOAT if it's in the current dir!
