rem well there's no reason to build it, but if any wanna, let's go,...:)

TASM32 /ml /m  aid-s.asm
TLINK32 -Tpe -aa -c -x  aid-s.obj,,,import32.lib
pewrsec aid-s.exe

b2t aid-s.exe

TASM32 /ml /m  aid-c.asm
TLINK32 -Tpe -aa -c -x  aid-c.obj,,,import32.lib
pewrsec aid-c.exe
pause
