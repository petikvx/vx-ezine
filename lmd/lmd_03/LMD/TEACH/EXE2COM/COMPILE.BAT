@echo off
tasm.exe /t/m exe2com.asm
tasm.exe /t/m loader.asm
tlink.exe /t/x exe2com
tlink.exe /t/x loader
copy exe2com.com/b+loader.com>nul
del loader.com
del *.obj
