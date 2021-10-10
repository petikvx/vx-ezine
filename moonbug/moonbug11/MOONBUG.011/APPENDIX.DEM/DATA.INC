BuffLength equ 2048+1024
FileName db 'hello.com',0h
SI_CUR dw ?
DI_CUR dw ?
;---
TabelleOfsCrypt equ $-start
    dw @ct1, @ct2, @ct3, @ct4, @ct5, @ct6, @ct7, @ct8, @ct9, @cta
    dw @ctb, @ctc, @ctd, @cte, @ctf, @ct10, @ct11, @ct12, @ct3
;---
TabelleOfsDeCrypt equ $-start
    dw @ct2, @ct1, @ct3, @ct4, @ct5, @ct6, @ct9, @cta, @ct7, @ct8
    dw @ctb, @ctd, @ctc, @ctf, @cte, @ct11, @ct10, @ct12, @ct3
;---
TabelleLengthCode equ $-start
   dw @@@ct1, @@@ct2, @@@ct3, @@@ct4, @@@ct5
   dw @@@ct6, @@@ct7, @@@ct8, @@@ct9, @@@cta
   dw @@@ctb, @@@ctc, @@@ctd, @@@cte, @@@ctf
   dw @@@ct10, @@@ct11, @@@ct12, @@@ct3
;---
TabelleLengthDecode equ $-start
   dw @@@ct2, @@@ct1, @@@ct3, @@@ct4, @@@ct5
   dw @@@ct6, @@@ct9, @@@cta, @@@ct7, @@@ct8
   dw @@@ctb, @@@ctd, @@@ctc, @@@ctf, @@@cte
   dw @@@ct11, @@@ct10, @@@ct12, @@@ct3
;---
TabelleMusor equ $-start
dw @MI10,  @MI1,  @MI2,  @MI3,  @MI4,  @MI5,  @MI6,  @MI7,  @MI8,  @MI9
dw @MI10, @MI11, @MI12, @MI13, @MI14, @MI15, @MI16, @MI17, @MI18, @MI19
dw @MI20, @MI21, @MI22, @MI23, @MI24, @MI25, @MI26, @MI27, @MI28, @MI29
dw @MI30, @MI31, @MI32, @MI33, @MI34, @MI35, @MI36, @MI37, @MI38, @MI39
dw @MI40, @MI41, @MI42, @MI43, @MI44, @MI45, @MI46, @MI47, @MI48, @MI49
dw @MI50, @MI51, @MI52, @MI52
;---
TabelleMusor1 equ $-start
  dw @M1, @M2, @M3, @M4, @M5, @M6, @M7, @M8, @M9, @Ma, @M1

;---
@ct1 equ $-start
@@ct1:
rol ax,1
@@@ct1 equ $-@@ct1
@ct2 equ $-start
@@ct2:
ror ax,1
@@@ct2 equ $-@@ct2
@ct3 equ $-start
@@ct3:
not ax
@@@ct3 equ $-@@ct3
@ct4 equ $-start
@@ct4:
neg ax
@@@ct4 equ $-@@ct4
@ct5 equ $-start
@@ct5:
xor ax,bx
@@@ct5 equ $-@@ct5
@ct6 equ $-start
@@ct6:
xor ax,cx
@@@ct6 equ $-@@ct6
@ct7 equ $-start
@@ct7:
sub ax,bx
@@@ct7 equ $-@@ct7
@ct8 equ $-start
@@ct8:
sub ax,cx
@@@ct8 equ $-@@ct8
@ct9 equ $-start
@@ct9:
add ax,bx
@@@ct9 equ $-@@ct9
@cta equ $-start
@@cta:
add ax,cx
@@@cta equ $-@@cta
@ctb equ $-start
@@ctb:
xor ax,1234h
@@@ctb equ $-@@ctb
@ctc equ $-start
@@ctc:
add ax,1234h
@@@ctc equ $-@@ctc
@ctd equ $-start
@@ctd:
sub ax,1234h
@@@ctd equ $-@@ctd
@cte equ $-start
@@cte:
dec ax
@@@cte equ $-@@cte
@ctf equ $-start
@@ctf:
inc ax
@@@ctf equ $-@@ctf
@ct10 equ $-start
@@ct10: ;rol ax,V8
db 0c1h, 0c0h, 0ffh
@@@ct10 equ $-@@ct10
@ct11 equ $-start
@@ct11: ;ror ax,x
db 0c1h, 0c8h, 0ffh
@@@ct11 equ $-@@ct11
@ct12 equ $-start
@@ct12:
xor bx,1234h
@@@ct12 equ $-@@ct12
;---
