;----------------------------------------------------;procedure KhizhnjakFill;
@Khizhnjak0:
KhizhnjakMyName         db 'Khizhnjak.452','$'
KhizhnjakMyNameLen      equ $-@Khizhnjak0
KhizhnjakMyLength       equ 452
KhizhnjakMyTypeWrt      equ TypeEnd
KhizhnjakMyDesinfect    equ DisinfYes
KhizhnjakMyCryptInfo    equ CryptNone
KhizhnjakMySigLength1   equ 7
KhizhnjakMySigArray1_1  equ 0A0h
KhizhnjakMySigArray1    db 039h,002h,02Eh,0A2h,000h,001h
KhizhnjakMySigOffset2   equ 0CCh
KhizhnjakMySigLength2   equ 9
KhizhnjakMySigArray2    db 072h,036h,080h,03Eh,0D2h,002h,037h,075h,003h
KhizhnjakMyVirBegOffs   equ 8
KhizhnjakMyBytesPartCo  equ 1
KhizhnjakMyBytesOffset1 equ 0121h
KhizhnjakMyBytesLength  equ 3
KhizhnjakMyBytesCrypt   equ CryptNone
KhizhnjakMySourceOffs   equ 0
KhizhnjakMyCouFind      dw 0
;--------------------------------------------------------;procedure RedArc112;
@RedArc0:
RedArcMyName            db 'RedArc.112','$'
RedArcMyNameLen         equ $-@RedArc0
RedArcMyLength          equ 112
RedArcMyTypeWrt         equ TypeBeg
RedArcMyDesinfect       equ DisinfYes
RedArcMyCryptInfo       equ CryptNone
RedArcMySigLength1      equ 12
RedArcMySigArray1_1     equ 053h
RedArcMySigArray1       db 068h,06fh,06dh,068h,02eh,063h,068h,02ah,03fh
                        db 08bh,0d4h
RedArcMySigOffset2      equ 04bh
RedArcMySigLength2      equ 9
RedArcMySigArray2       db 0b4h,040h,0feh,0c6h,0cdh,021h,055h,05ch,0cbh
RedArcMyVirBegOffs      equ 0
RedArcMyBytesPartCo     equ 0
RedArcMyCouFind         dw 0
