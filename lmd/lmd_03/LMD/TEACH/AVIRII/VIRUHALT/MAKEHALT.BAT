@tasm /m/t/z viruhalt.asm
@tlink /x/t viruhalt.obj
@del viruhalt.obj
@copy /b viruhalt.com+halt_mbr.bin>nul
@supd viruhalt.com>nul