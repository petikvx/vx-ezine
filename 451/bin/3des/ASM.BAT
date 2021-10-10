@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc 3des.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 3des.obj
@del 3des.obj>NUL