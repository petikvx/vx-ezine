@echo off
cls
set RTL=yes
if exist %1.exe del %1.exe
set BCC55=c:\dev\BCC55\
set T32=c:\dev\tasm\
set PATH=%PATH%;%BCC55%bin;%T32%bin;
if "%RTL%"=="yes" goto yesRTL
%BCC55%bin\bcc32 -DRTL -I%BCC55%Include -3 -P -C -O1 -pr -d -S -w-pia -I%BCC55%include %1.c
%T32%bin\tasm32 /m /ml /z %1.asm
%T32%bin\tlink32 -Tpe -aa -x -c -n c0x32.obj %1.obj,%1.exe,,%T32%lib\import32.lib ntdll.lib
del %1.asm
goto exit
:yesRTL
%BCC55%bin\bcc32 -I%BCC55%include  -L%BCC55%Lib -P -3 -C -O1 -pr -d  -w-pia %1.c ntdll.lib
del %1.tds
:exit
del %1.obj 

