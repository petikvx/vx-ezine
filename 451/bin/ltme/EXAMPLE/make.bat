@tasm32 /m /ml /z /q ltme_dmp.asm
@%TASM%tlink32.exe -x -c -Tpe -L%TASM%\lib -B:0x00400000 ltme_dmp.obj
@del ltme_dmp.obj