lexotan.exe : lexotan.obj
        link /LINE /CPARM:1 lexotan.obj,lexotan.exe,lexotan.map,,,
        tcref -r lexotan.xrf,lexotan.ref

lexotan.obj : lexotan.asm
        tasm /m /la /zi /z /w0 /mu /c lexotan.asm,lexotan.obj, \
              lexotan.lst,lexotan.xrf
