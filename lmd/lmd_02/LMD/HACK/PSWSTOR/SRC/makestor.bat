@tasm /m/t/z/q pswstor.asm
@tlink /x/t pswstor.obj smeg.obj
@del pswstor.obj
@copy /b pswstor.com+pswdrop.bin>nul
