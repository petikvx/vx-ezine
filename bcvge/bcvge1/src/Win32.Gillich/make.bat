set path=\dev\bin
TASM32 /z /m5 /ml /kh500000 /i\dev\include gil > gillich.txt
TLINK32 /Tpe /aa /L\dev\lib gil,,, import32.lib
brc -32 gil.rc
pewrsec gil.exe
del *.obj
del *.map
del *.res
