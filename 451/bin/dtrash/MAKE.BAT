cls

@tasm32 /m /ml /z /q dtrash_t.asm
@tlink32 /Tpe /x /c  -B:0x00400000 dtrash_t.obj,,,%TASM%lib\import32.lib
stospack.exe dtrash_t.exe tmp_asm.inc

@tasm32 /m /ml /z /q tables.asm
@tlink32 /Tpe /x /c  -B:0x00400000 tables.obj,,,%TASM%lib\import32.lib
ct.exe tables.exe dtrash_init

@tasm32 /m /ml /z /q dtrash_c.asm
@tlink32 /Tpe /x /c  -B:0x00400000 dtrash_c.obj,,,%TASM%lib\import32.lib
ct.exe dtrash_c.exe dtrash
         
@del *.obj>nul 
@del dtrash_c.exe>nul         
@del dtrash_t.exe>nul         
@del tables.exe>nul 
@type dtrash_init.inc >> dtrash.inc
@type dtrash_init.c >> dtrash.c

@del  dtrash_init.inc
@del  dtrash_init.c
@del  tmp_asm.inc