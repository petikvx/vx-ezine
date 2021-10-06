ml -coff -Cx -DMASM6 -DBLD_COFF -DIS_32 evil.asm
link -vxd -def:evil.def evil.obj

