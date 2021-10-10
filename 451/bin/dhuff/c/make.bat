%BC5%bin\bcc32.exe -P -3 -k- -O2 -I%BC5%include  -H=x.csm -L%BC5%lib\ huffman.c %BC5%\lib\cw32i.lib
del huffman.obj


del *.tds>nul
del x.csm
del *.#*