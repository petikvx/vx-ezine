KnownViruses equ 2; {����쪮 ����ᥩ ॠ��������}
MaxPartBeg equ 3;   {���ᨬ��쭮� ������⢮ ����ᥩ}
MaxLengthS equ 20;  {���ᨬ��쭠� ����� ᨣ������}

TypeBeg equ 0; {������ � ��砫� 䠩�� � ᤢ���� ����}
TypeMov equ 1; {������ � ��砫� 䠩�� � ��७�ᮬ ����}
TypeAdd equ 2; {������ � �।��� 䠩�� � ������� ����������� ����}
TypeIns equ 3; {������ � �।��� 䠩�� � ��७�ᮬ ����}
TypeEnd equ 4; {������ � ����� 䠩��}
TypeOvr equ 5; {������ ����饭��� ����}
TypeSat equ 6; {������쮭}
TypeUep equ 7; {������ � ����� � �ᯮ�짮������ �孮����� UEP}

DisinfNo  equ 0;
DisinfYes equ 1;

CryptNone  equ 0; {������஢����}
CryptByte0 equ 1; {add byte ptr xx:[yy],bCode}
CryptByte1 equ 2; {sub byte ptr xx:[yy],bCode}
CryptByte2 equ 3; {xor byte ptr xx:[yy],bCode}
CryptWord0 equ 4; {add word ptr xx:[yy],wCode}
CryptWord1 equ 5; {sub word ptr xx:[yy],wCode}
CryptWord2 equ 6; {xor word ptr xx:[yy],wCode}
