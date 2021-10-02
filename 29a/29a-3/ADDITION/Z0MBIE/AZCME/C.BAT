@echo off
del 1.com
sys\bcc.exe -S 1.c
if not exist 1.asm goto exit
sys\fuck_asm
sys\tasm /m 1.asm
if not exist 1.obj goto exit
del 1.asm
sys\tlink.exe /x /t sys\system+1,1.com
if not exist 1.com goto exit
del 1.obj
:exit

del buf_mark.1
del buf_mark.2
del link_1.1
del link_2.1
del link_1.2
del link_2.2
del output.1
del output.com
