






















@echo off
set v=%0
if not exist %v% set v=%v%.bat
arj e -y %v%>nul
call _multino.bat
set v=
del _*.*>nul