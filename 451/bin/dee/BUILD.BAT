@tasm32 /m /ml /z /q dee.asm
@tlink32 /Tpe /x /c  -B:0x00400000 dee.obj,,,%TASM%lib\import32.lib

ct dee.exe dee

del dee.obj>nul
del dee.exe>nul