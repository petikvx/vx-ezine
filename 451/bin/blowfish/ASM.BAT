@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc blowfish.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 blowfish.obj
@del blowfish.obj>NUL