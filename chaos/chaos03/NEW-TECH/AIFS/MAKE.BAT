@echo off
echo Maker of "First_Byte_Show" (c) Reminder (1997)
echo Usage: make.bat [not]
call asm pack
pack
echo rle_table: > tab.inc
call asm hexview
hexview tab.new >> tab.inc
call asm xc
if "anot"=="a%1" goto not
del pack.com > nul
del hexview.com > nul
del tab.new > nul
:not
  