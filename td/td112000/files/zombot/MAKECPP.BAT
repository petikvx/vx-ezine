@echo off
%BCC55%bin\bcc32.exe -3 -C -P -laa -I%BCC55%include -L%BCC55%lib -H -H=%TEMP%\zombot.csm zombot.cpp
del zombot.tds
del zombot.obj
