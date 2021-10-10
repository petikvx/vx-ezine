@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc deal-128.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 deal-128.obj
@del deal-128.obj>NUL