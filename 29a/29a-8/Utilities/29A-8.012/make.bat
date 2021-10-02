@echo off
tasm32 /m /ml /l makedb.asm
tlink32 makedb.obj,,,import32.lib

makedb vcl32.dat

tasm32 /m /ml /l vcl32console.asm
tlink32 vcl32console.obj,,,import32.lib

tasm32 /m /ml /l vcl32.asm
tlink32 -aa vcl32.obj,,,import32.lib,,vcl32.res
pewrsec /SEC:.rsrc vcl32.exe