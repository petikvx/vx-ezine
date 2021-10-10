del ring0.exe
tasm32 /s /m /z /ml /la ring0
tlink32 /Tpe /aa /c /x ring0,ring0.exe,, /L import32.lib ring0.lib
del ring0.obj
