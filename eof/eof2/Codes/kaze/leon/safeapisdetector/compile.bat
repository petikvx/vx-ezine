@echo off
"d:\bin\tasm32.exe" /ml /l /m3  %1.asm %1.obj
"d:\bin\tlink32.exe" /Tpe /aa  %1.obj ,main.exe,, "d:\bin\zz.lib"

