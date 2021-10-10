@tasm /m/t/z/q dos2win.asd
@tlink /x dos2win.obj
@del dos2win.obj
@del dos2win.exd
@ren dos2win.exe dos2win.exd
@tasm32 /ml/m/t/z/q dos2win.asm
@tlink32 -x /Tpe /ap /c dos2win.obj,,,import32.lib,dos2win.def
@del dos2win.obj