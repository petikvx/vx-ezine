tasm32.exe /ml /m5 /zn dataenc.asm
tlink32.exe /aa /Tpe /x /c dataenc.obj,,,import32.lib

