set path=\dev\bin
TASM32 /z /m5 /ml /kh500000 /i\dev\include worm > tasm.txt
TLINK32 /Tpe /aa /L\dev\lib worm,,, import32.lib
brc -32 worm.rc
del *.obj
del *.map
del *.res
