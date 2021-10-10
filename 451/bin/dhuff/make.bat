@%TASM%tasm32 /m /ml /z /q -i%TASM%\inc huffman.asm
@%TASM%tlink32 /Tpe /x /c -B:0x00400000 -L%TASM%\lib huffman.obj
@del huffman.obj           >nul         

%BC5%bin\bcc32.exe -P -3 -k- -O2 -I%BC5%include  -H=x.csm -L%BC5%lib\ bin2huff.c %BC5%\lib\cw32i.lib
del bin2huff.obj

del *.tds>nul
del x.csm
del *.#*

