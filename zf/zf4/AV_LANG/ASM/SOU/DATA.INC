;TCrypto = record
TypeCryptCode db ? ;    {0 - �����騩�� ���, 1 - ����ﭭ�}
ConstCrypCodW dw ? ;    {��� � ᫮��}
ConstCrypCodB db ? ;    {��� � ����}
CodeOffsetCrp dw ? ;    {ᬥ饭�� �����饣��� ����}
BegOfCrypt    dw ? ;    {��砫� ����஢������ �ࠣ����}
LengthCrypt   dw ? ;    {����� ����஢������ �ࠣ����}

;TSigInfo = record
SigOffset1  dw ?          ; {��१�ࢨ஢���}
SigLength1  dw ?          ; {ࠧ��� ᨣ������}
SigArray1   db 20 dup (?) ; {ᨣ�����}

;TSigInfo = record
SigOffset2  dw ?          ; {��१�ࢨ஢���}
SigLength2  dw ?          ; {ࠧ��� ᨣ������}
SigArray2   db 20 dup (?) ; {ᨣ�����}

;TBegInfo = record
BytesOffset dw ? ;    {ᬥ饭�� ���}
BytesLength db ? ;    {ࠧ��� ���}
BytesCrypt  db ? ;    {�ਧ��� ���樨}
CodeOffset  dw ? ;    {ᬥ饭�� ���� ���}
SourceOffs  dw ? ;    {ᬥ饭�� �ਣ������� ����}

;TSignature = packed record
VirNameLen  db ?
VirName     db 40 dup (?); {�������� �����}
VirLength   dw ?         ; {����� �����}
TypeWrt     db ?         ; {⨯ ����� � 䠩�}
Desinfect   db ?         ; {����������� �����䥪樨}
CryptInfo   db ?         ; {���ᠭ�� ���樨}

VirBegOffs  dw ?         ; {ᬥ饭�� ��砫� ���� �����}
BytesPartCo db ?         ; {������⢮ ��⥩ ��砫��� ����}
TypeSatelit db ?         ; {�����: 0 - ���, 1 - ���७��}
SatelitName db 8 dup (?) ; {��� ��� ��⥫��}
Extension   db 3 dup (?) ; {���७�� ��� ��⥫��}
CouFind     dw ?         ; {������⢮ �宦�����}

FlagInfect db ?
SI_SAVE    dw ?
CurFile    db ?

AllPathFound  dw 0
AllFileFound  dw 0
AllFileTested dw 0
AllErrorFound dw 0
AllKnownVirus dw 0
AllFileInfect dw 0
AllFileCured  dw 0
AllFileErased dw 0
AllVirusFound dw 0
AllVurusSkip  dw 0
AllFileError  dw 0


pCountPath   db 'Directory found  ','$'
pFilesFound  db 'Files found      ','$'
pFileTested  db 'Scaned files     ','$'
pCouError    db 'I/O error found  ','$'
pKnowVirus   db 'Known viruses    ','$'
pInfectFound db 'Infected files   ','$'
pCouCureFile db 'Desinfected files','$'
pEraseFile   db 'Erased files     ','$'
pCountVirus  db 'Viruses finded   ','$'
pCouSkipVir  db 'Skiped viruses   ','$'
pFileError   db 'Errors in files  ','$'

OkMode_1 db '/O'
LoMode_1 db '/P'
CuMode_1 db '/C'
OkMode_2 db '/o'
LoMode_2 db '/p'
CuMode_2 db '/c'

NO_MEM        db 0ah,0dh,'Not enoug memory',0ah,0dh,'$'
ErrorOpenFile db 'I/O error','$'
FileTooBig    db 'file too big','$'

OkFile        db 'Ok','$'
SkipFile      db 'skiped','$'
CureFile      db 'cured','$'
InfectFile    db 'found ','$'
KillFile      db 'killed','$'

InfoMSG db 0ah, 0dh, 'USAGE: ASMAV.EXE Path [Keys]',0ah,0dh
        db '       Path:',0ah,0dh
        db '             Driver:[\Path]',0ah,0dh
        db '       Keys:',0ah,0dh
        db '             /O - show Ok',0ah,0dh
        db '             /C - cure mode',0ah,0dh
        db '             /P - protokol save',0ah,0dh
        db 'Example:',0ah,0dh
        db '         ASMAV.EXE D:\TEST /O /P /C',0ah,0dh,'$'

Yes_No_Byte db 0

msk     db '*.*',0  ; ����� 䠩�� �᪠��.
pth     db '\',0      ; ��� �᪠��.
dsk     db 2          ; �� ����� ��᪥ (ᥩ�� - �)
all     db '*.*',0    ; �⮡� �室��� �� �� �����⠫���
old     db '..',0     ; �।��騩 ��⠫��
oldpath db 64 dup (0) ; ���� ��⠫��
curpath db 64 dup (0) ; ⥪�騩 ��⠫��

ClrEolC db 0dh
        db 79 dup (' ')
        db 0dh, '$'

OkMode db ?
CuMode db ?
LoMode db ?

FileAttr dw ?
FileTime dw ?
FileDate dw ?
SouFileH dw ?
TarFileH dw ?
FileLength dw ?

SouFileName db 13 dup (?)
TarFileName db 13 dup (?)

startpath db 80 dup (?)

FSEG      dw ?
BufRead   db ?
EraseFlag db ?

LBL          label byte
