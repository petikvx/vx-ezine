::%BC5%bin\bcc32.exe -P -3 -k- -O2 -I%BC5%include  -H=x.csm -L%BC5%lib\ ct.c %BC5%\lib\cw32i.lib
::del ct.obj

%BC5%bin\bcc32.exe -P -3 -k- -O2 -I%BC5%include  -H=x.csm -L%BC5%lib\ stospack.c %BC5%\lib\cw32i.lib
del stospack.obj


del *.tds>nul
del x.csm
del *.#*