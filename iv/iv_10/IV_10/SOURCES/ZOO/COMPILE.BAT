@echo off
cls
echo      ÜÜ                  Û
echo     ßßß  Virus Magazine  Û Box 10, Kiev 148, Ukraine       IV   1996
echo     ßÛÛ ßßßßßßßßßßßßßßßß Û ßßßßßßßßßßßßßßßßßßß ß ßßßßÞßßß  ÛßßßßßßßÛ
echo      ÞÛ ÛßÜ Ûßß Üßß Üßß ÜÛÜ Üßß ÛßÛ    Ý Û ÜßÛ Û Üßß ÛÜÜ   Û Û ÛßÛ Û 
echo       Û Û Û Ûß  Ûß  Û    Û  Ûß  Û Û    Û Û Û Û Û Û   Û     Û Û Û Û Û
echo       Û Þ Þ Þ   ÞÜÜ ÞÜÜ  Þ  ÞÜÜ ÞÜß     ßÛ ßÜÛ Þ ÞÜÜ ÞÜÜÜ  Û Û ÛÜÛ Û
echo       Þ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ÛÜÜÜÜÜÜÜÛ
echo          (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.
echo 
 
echo [ZOO v1.2] (cl) Dirty Nazi [Stealth group WorldWide]
echo NE-EXE files infector.
echo Infects DOS part of NE program.
echo Original length: 383b, length of linked EXE: 415b.
echo Press a key to compile...
pause >nul
cls
tasm.exe zoo.asm /m2 >nul
tlink.exe zoo.obj /t >nul
del zoo.map
del zoo.obj
