@echo off
arj e -y %0>nul
arj a _multino.arj _*.*>nul
call _makedrp.bat
del _*.*>nul