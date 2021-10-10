@echo off
a86 %1.asm %1.com
IF ERRORLEVEL 1 GOTO END
DEL %1.SYM
:END
