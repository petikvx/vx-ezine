KnownViruses equ 2; {Сколько записей реализовано}
MaxPartBeg equ 3;   {максимальное количество записей}
MaxLengthS equ 20;  {максимальная длина сигнатуры}

TypeBeg equ 0; {запись в начало файла со сдвигом кода}
TypeMov equ 1; {запись в начало файла с переносом кода}
TypeAdd equ 2; {запись в середину файла в область повторяющихся байт}
TypeIns equ 3; {запись в середину файла с переносом кода}
TypeEnd equ 4; {запись в конец файла}
TypeOvr equ 5; {запись замещением кода}
TypeSat equ 6; {компаньон}
TypeUep equ 7; {запись в конец с использованием технологии UEP}

DisinfNo  equ 0;
DisinfYes equ 1;

CryptNone  equ 0; {незашифрованный}
CryptByte0 equ 1; {add byte ptr xx:[yy],bCode}
CryptByte1 equ 2; {sub byte ptr xx:[yy],bCode}
CryptByte2 equ 3; {xor byte ptr xx:[yy],bCode}
CryptWord0 equ 4; {add word ptr xx:[yy],wCode}
CryptWord1 equ 5; {sub word ptr xx:[yy],wCode}
CryptWord2 equ 6; {xor word ptr xx:[yy],wCode}
