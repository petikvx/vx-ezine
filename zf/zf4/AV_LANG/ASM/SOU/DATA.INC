;TCrypto = record
TypeCryptCode db ? ;    {0 - меняющийся код, 1 - постоянный}
ConstCrypCodW dw ? ;    {код в слово}
ConstCrypCodB db ? ;    {код в байт}
CodeOffsetCrp dw ? ;    {смещение меняющегося кода}
BegOfCrypt    dw ? ;    {начало зашифрованного фрагмента}
LengthCrypt   dw ? ;    {длина зашифрованного фрагмента}

;TSigInfo = record
SigOffset1  dw ?          ; {зарезервировано}
SigLength1  dw ?          ; {размер сигнатуры}
SigArray1   db 20 dup (?) ; {сигнатура}

;TSigInfo = record
SigOffset2  dw ?          ; {зарезервировано}
SigLength2  dw ?          ; {размер сигнатуры}
SigArray2   db 20 dup (?) ; {сигнатура}

;TBegInfo = record
BytesOffset dw ? ;    {смещение части}
BytesLength db ? ;    {размер части}
BytesCrypt  db ? ;    {признак шифрации}
CodeOffset  dw ? ;    {смещение кода шифра}
SourceOffs  dw ? ;    {смещение оригинальных байт}

;TSignature = packed record
VirNameLen  db ?
VirName     db 40 dup (?); {название вируса}
VirLength   dw ?         ; {длина вируса}
TypeWrt     db ?         ; {тип записи в файл}
Desinfect   db ?         ; {возможность дезинфекции}
CryptInfo   db ?         ; {описание шифрации}

VirBegOffs  dw ?         ; {смещение начала кода вируса}
BytesPartCo db ?         ; {количество частей начальных байт}
TypeSatelit db ?         ; {меняет: 0 - имя, 1 - расширение}
SatelitName db 8 dup (?) ; {имя для саттелита}
Extension   db 3 dup (?) ; {расширение для саттелита}
CouFind     dw ?         ; {количество вхождений}

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

msk     db '*.*',0  ; Какие файлы искать.
pth     db '\',0      ; Где искать.
dsk     db 2          ; на каком диске (сейчас - С)
all     db '*.*',0    ; Чтобы входить во все подкаталоги
old     db '..',0     ; предыдущий каталог
oldpath db 64 dup (0) ; старый каталог
curpath db 64 dup (0) ; текущий каталог

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
