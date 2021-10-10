@echo off
arj a _multino.arj _*.*>nul
copy/b myxa.bat+_plugins.bat+_multino.arj>nul
del _multino.arj
