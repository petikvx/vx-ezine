@%TASM%tasm32 /m /m5  /ml /zn /z /q /i%TASM%\inc md5.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 md5.obj
@del md5.obj>NUL