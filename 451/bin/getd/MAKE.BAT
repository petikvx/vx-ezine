cls

@tasm32 /m /ml /z /q getd_c.asm
@tlink32 /Tpe /x /c  -B:0x00400000 getd_c.obj,,,%TASM%lib\import32.lib
ct.exe getd_c.exe getd
         
@del *.obj>nul
@del getd_c.exe>nul