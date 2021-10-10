@echo off
%BCC55%bin\bcc32.exe -lap -5 -C -P -pr -ff -O2 -Tm5 -lH:16777216 -I%BCC55%include -L%BCC55%lib -H -H=%TEMP%\revert.csm revert.cpp LDE32\lde32.obj cw32i.lib
del revert.tds
del revert.obj
