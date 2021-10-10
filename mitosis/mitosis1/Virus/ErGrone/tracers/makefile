# -------------------------------------------------------
# MAKEFILE para el programa "Técnicas antidebugger v1.0"
# -------------------------------------------------------
# Por favor, no sea anticuado.
# utilize el make.exe de Turbo assembler para facilitarse la vida.
#
# Si desea cambiar el nombre del PE destino sólo debe de entender
# la siguiente sintaxis de los makefiles:
# 		Objetivo: [dependencia1 [dependencia2 ...] ]
# Y por favor respete el Tabulador, asi como las disposición de las 
# líneas, sino el makefile chilla como loca.
#
# Makefile realizado por Jtag. Diciembre del 2002.
# -------------------------------------------------------
tracersexe: tracers.asm
        tasm32 tracers,tracersexe /ml /m5 /q /t /zn
        tlink32 /Tpe /c /aa tracersexe.obj,,,import32.lib
