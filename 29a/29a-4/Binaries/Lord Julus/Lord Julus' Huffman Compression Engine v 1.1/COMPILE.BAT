@tasm32 -ml -m  ljhce32.asm
@tlink32 -Tpe -ap -c -x ljhce32,,,import32.lib
@pewrsec ljhce32.exe
@del ljhce32.obj