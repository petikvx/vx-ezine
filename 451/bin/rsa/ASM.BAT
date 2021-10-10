@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc rsa.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 rsa.obj
@del rsa.obj>NUL