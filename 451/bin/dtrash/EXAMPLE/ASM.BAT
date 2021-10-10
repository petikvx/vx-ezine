@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc example.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 example.obj
@del example.obj>NUL