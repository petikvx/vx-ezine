@ECHO OFF
c:\tasm\win\tasm32.exe  /s /m -mx /ic:\tasm\win %1
c:\tasm\win\tlink32.exe /Tpe -aa -c -x %1,,,c:\tasm\win\import32.lib
del %1.obj
rem c:\my\util\patch.exe %1.exe 21F 60 E0
