@echo off
cls
c:\borland\bc\bin\bcc32.exe -5 -C -P -pr -ff -O2 -Ic:\borland\bc\include -H -H=c:\windows\temp\%1.csm %1.cpp cw32i.lib
del %1.obj
