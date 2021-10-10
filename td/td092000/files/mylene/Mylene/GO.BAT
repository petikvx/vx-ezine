@echo off
chdir stub
call go
chdir ..
tasm /m loader.asm
tlink /t loader.obj
bin2db loader.com
bin2db mylene.jpg
tasm32 /m/ml mylene.asm
tlink32 mylene.obj
del *.map
del *.obj
mstub.com
del *.asb