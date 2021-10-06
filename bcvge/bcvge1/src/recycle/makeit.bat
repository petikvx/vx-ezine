tasm32.exe /ml /m5 /zn recycle.asm
tlink32.exe /aa /Tpe /x /c recycle.obj,,,import32.lib
tasm32.exe /ml /m5 /zn injector.asm
tlink32.exe /aa /Tpe /x /c injector.obj,,,import32.lib
injector