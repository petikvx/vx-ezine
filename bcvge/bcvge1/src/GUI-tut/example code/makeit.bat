rc gui.rc
ml /c /coff /Cp gui.asm
Link /SUBSYSTEM:WINDOWS /LIBPATH:c:\masm32\lib gui.obj gui.res

