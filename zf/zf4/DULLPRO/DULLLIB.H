/*******************************************************************/
/* DULLLIB - ������⥪� ��楤�� ��� ��������樮����� �������  */
/* ������� ���� �� ��� ��� COM/EXE/NE/PE �ணࠬ�.               */
/* (c) �������쥢 �., ����� 2001                                  */
/*******************************************************************/

#define WORD unsigned int
#define BYTE unsigned char
#define DWORD unsigned long

#define my_create(path,mode) creat(path,mode)
#define my_open(path,access) open(path,access)
#define my_close(handle) close(handle)
#define my_read(handle,buf,num) read(handle,buf,num)
#define my_write(handle,buf,num) write(handle,buf,num)
#define my_seek(handle,offset,origin) lseek(handle,offset,origin)
#define my_alloc(size) malloc(size)
#define my_free(pointer) free(pointer)

#define Align(x,y) ((x)%(y)?((x)/(y)+1)*(y):(x))

#define BUFLEN 512
#define C_LEN 46
#define N_LEN 71
#define P_LEN 43
#define E_LEN 40

struct enuns
 {
  unsigned char en[5];
  unsigned cs;
};

struct jump
 {
  unsigned char jmp;
  unsigned int  ofs;
};

struct EXEhdr
{
  unsigned MZ;      // +0   'MZ'
  unsigned PartPag; // +2   ����� �������� ��᫥���� ��࠭���
  unsigned PageCnt; // +4   ����� ��ࠧ� (+���������) � 512-���⭨���
  unsigned ReloCnt; // +6   �᫮ ������⮢ � Relocation Table
  unsigned HdrSize; // +8   ����� ��������� � 16-���⭨���
  unsigned MinMem;  // +0aH ������ �ॡ㥬�� �����
  unsigned MaxMem;  // +0cH ���ᨬ� �ॡ㥬�� �����
  unsigned ReloSS;  // +0eH ᥣ���� �⥪� (�⭮�⥫쭮 RootS)
  unsigned ExeSP;   // +10H 㪠��⥫� �⥪�
  unsigned ChkSum;  // +12H ����஫쭠� �㬬�
  unsigned ExeIP;   // +14H ���稪 ������
  unsigned ReloCS;  // +16H ᥣ���� ���� (�⭮�⥫쭮 RootS)
  unsigned TablOff; // +18H ������ � 䠩�� 1-�� ������� Relocation Table
  unsigned Overlay; // +1aH ����� ���૥�
  unsigned r1;      // +1cH ��१�ࢨ஢���
  unsigned r2;      // +1eH ��१�ࢨ஢���
};

struct ReloTab
{
 unsigned r_off;    // ���饭��
 unsigned r_seg;    // �������
};

struct WINhdr
{
  struct EXEhdr dosHdr; // EXE-���������
  BYTE   reserved[28];  // ???
  WORD   winInfoOffset; // ���饭�� NE- ��� PE-���������
  WORD   reserved2;     // ???
  BYTE   dosStub[1];    // ��� �����誨
};

struct tagTBSEGMENT
{
 WORD segDataOffset;  // +00 ᬥ饭�� ᥣ���� � 512-������
                      //     ᥪ��� _��_��砫�_䠩��_ !!!
 WORD segLen;         // +02 ����� ᥣ���� � �����;
 WORD segFlags;       // +04 ᫮�� ���ᠭ�� ᥣ����;
 WORD segMinSize;     // +06 १�ࢨ�㥬�� ��� ᥣ���� ������,
                      //     0 ����砥� ���ᨬ�: 64��.
};

struct tagRELOCATEITEM
{
 BYTE addressType;    // +00 ᯮᮡ ������� ���� ��뫪�
 BYTE relocationType; // +01 ⨯ ����஥筮� ��뫪�
 WORD itemOffset;     // +02 ᬥ饭�� � ᥣ���� �� ५����襭�
 WORD index;          // +04 ������ � ⠡��� ��뫮�,
                      //     ���� ����� ᥣ����
 WORD extra;          // +06 ���浪��� ����� �㭪樨,
                      //     ���� ᬥ饭�� � ᥣ����
};

struct NEhdr
{
 WORD  NE;               // +0   0x454E = 'NE'
 BYTE  linkerVersion;    // +2   ����� ��������騪�
 BYTE  linkerRevision;   // +3   ॢ���� ��������騪�
 WORD  entryTabOffset;   // +4   ᬥ饭�� ⠡���� �祪 �室�
 WORD  entryTabLen;      // +6   ����� ⠡���� �祪 �室�
 DWORD reserved1;        // +8   ???
 WORD  exeFlags;         // +0CH ���� ���ᠭ�� �ᯮ��塞��� ����
 WORD  dataSegNum;       // +0EH �᫮ ᥣ���⮢ "��⮤�����"
 WORD  localHeapSize;    // +10H ��室�� ࠧ��� �����쭮�� 娯�
 WORD  stackSize;        // +12H -"- �⥪�
 WORD  NE_IP;            // +14H ᬥ饭�� � ᥣ���� �窨 �室�
 WORD  NE_CS;            // +16H ������ ᥣ���� �窨 �室�
 WORD  NE_SP;            // +18H ᬥ饭�� � �⥪���� ᥣ����
 WORD  NE_SS;            // +1AH ������ �⥪����� ᥣ���� (� 1)
 WORD  segTabEntries;    // +1CH �-�� ������⮢ � ⠡��� ᥣ���⮢
 WORD  modTabEntries;    // +1EH -"- � ⠡��� �宦�����
 WORD  nonResTabSize;    // +20H -"- � ⠡��� ��१����⮢
 WORD  segTabOffset;     // +22H ᬥ�. �� ⠡�. ᥣ���⮢ �� NEHdr
 WORD  resTabOffset;     // +24H -"- �� ⠡���� ����ᮢ
 WORD  resNameTabOffset; // +26H -"- �� ⠡���� ���� ����ᮢ
 WORD  modTabOffset;     // +28H -"- �� ⠡���� ���㫥�
 WORD  impTabOffset;     // +2AH -"- �� ⠡���� ������
 WORD  nonResTabOffset;  // +2CH -"- �� ⠡���� ��१����⮢
 WORD  reserved2;        // +2EH ???
 WORD  numEntryPoints;   // +30H �-�� ��६�頥��� �祪 �室�
 WORD  shiftCount;       // +32H Log(SegSiz,2)
 WORD  numResourceSegs;  // +34H �᫮ ������� ᥣ���⮢
 BYTE  targetOS;         // +36H ��� ����樮���� ��⥬�
 BYTE  miscFlags;        // +37H ��稥 ���� ���ᠭ�� �ணࠬ��
 WORD  fastLoadOffset;   // +38H ᬥ饭�� ������ ����ன ����㧪�
 WORD  fastLoadSize;     // +3AH ࠧ��� ������ ����ன ����㧪�
 WORD  reserved3;        // +3CH ???
 BYTE  winRevision;      // +3EH ⥪��� ����� ���⮪
 BYTE  winVersion;       // +3FH ⥪��� ॢ���� ���⮪
};

struct PEhdr
{
 // ����ﭭ�� ����
 DWORD PE;         // +00  ��������
 WORD MachType;    // +04  ��� ������
 WORD NOfSections; // +06  ������⢮ ᥪ権
 DWORD TimDat;     // +08  �६�/��� ᮧ�����
 DWORD PSymTable;  // +0�H ���� ⠡���� ᨬ�����
 DWORD NOfSymbols; // +10H �-�� ��ப � ⠡��� ᨬ�����
 WORD SzOfOptHdr;  // +14H ������ ��६����� ���
 WORD Flags;       // +16H �����
 // ��६����� ����
 WORD R1;          // +18H ???
 BYTE MajorLnkV;   // +1AH ����� ����� ������
 BYTE MinorLnkV;   // +1BH ������ ����� ������
 DWORD SizeOfCode; // +1CH ������ �ᯮ��塞��� ����
 DWORD SizeOfInD;  // +20H ������ ����-��� ������
 DWORD SizeOfUnInD;// +24H ������ ������-��� ������
 DWORD EntryPoint; // +28H ���� �窨 �室�
 DWORD BaseOfCode; // +2CH ����. ���� � �����
 DWORD BaseOfData; // +30H ����. ����-��� ������ � �����
 // NT-����
 DWORD ImBase;     // +34H RVA �⮡p������ 䠩�� � ������
 DWORD SectAlign;  // +38H ����� ��ࠢ������� ��ꥪ⮢ � ���
 DWORD FileAlign;  // +3CH ����� ��ࠢ������� ��ꥪ⮢ � 䠩��
 WORD MajorOSV;    // +40H |
 WORD MinorOSV;    // +42H |
 WORD MajorImV;    // +44H |
 WORD MinorImV;    // +46H +> ���ᨨ � �㡢��ᨨ ��������⮢
 WORD MajorSSV;    // +48H |
 WORD MinorSSV;    // +4AH |
 DWORD Win32Vers;  // +4CH |
 DWORD SizeOfIm;   // +50H ������ ��ࠧ� �ணࠬ�� � ���
 DWORD SizeOfHd;   // +54H �����p ��������� � ⠡���� ��ꥪ⮢
 DWORD CSum;       // +58H ����p��쭠� �㬬�
 WORD SubS;        // +5CH
 WORD ProcFlags;   // +5EH
 DWORD SizeOfStR;  // +60H
 DWORD SizeOfStC;  // +64H
 DWORD SizeOfHpR;  // +68H
 DWORD SizeOfHpC;  // +6CH
 DWORD LoaderFlags;// +70H
 DWORD NrOfRVAs;   // +74H
 // ���ᠭ� ⮫쪮 � Hard Wisdom
 DWORD ExRVA;      // +78h RVA ⠡���� ��ᯮ��
 DWORD ExSize;     // +7Ch ࠧ��� ⠡���� ��ᯮ��
 DWORD ImRVA;      // +80h RVA ⠡���� ������
 DWORD ImSize;     // +84h ࠧ��� ⠡���� ������
 DWORD RsRVA;      // +88h RVA ⠡���� ����ᮢ
 DWORD RsSize;     // +8Ch ࠧ��� ⠡���� ����ᮢ
 DWORD ExcRVA;     // +90h RVA ⠡���� �᪫�祭��
 DWORD ExcSize;    // +94h ࠧ��� ⠡���� �᪫�祭��
 DWORD ScRVA;      // +98h RVA ⠡���� ������᭮��
 DWORD ScSize;     // +9Ch ࠧ��� ⠡���� ������᭮��
 DWORD FURVA;      // +A0h RVA ⠡���� ����஥�
 DWORD FUSize;     // +A4h ࠧ��� ⠡���� ����஥�
 DWORD DbRVA;      // +A8h RVA ⠡���� �⫠��筮� ���.
 DWORD DbSize;     // +ACh ࠧ��� ⠡���� �⫠��筮� ���.
 DWORD IDRVA;      // +B0h RVA ��ப� ���ᠭ� �����
 DWORD IDSize;     // +B4h ࠧ��� ��ப� ���ᠭ�� �����
 DWORD MhRVA;      // +B8h RVA ⠡���� ���ᠭ�� ������
 DWORD MhSize;     // +BCh ࠧ��� ⠡���� ���ᠭ�� ������
 DWORD TLRVA;      // +C0h RVA ������ ������ 楯�祪
 DWORD TLSize;     // +C4h ࠧ��� ������ ������ 楯�祪
 DWORD LCRVA;      // +C8h RVA ⠡���� ��ࠬ��஢ ����㧪�
 DWORD LCSize;     // +CCh ࠧ��� ⠡���� ��ࠬ��஢ ����㧪�
 DWORD R2[2];      // +D0h ???
 DWORD IARVA;      // +D8h RVA ???
 DWORD IASize;     // +DCh ࠧ��� ???
 DWORD R3[2];      // +E0h ???
 DWORD R4[2];      // +E8h ???
 DWORD R5[2];      // +F0h ???
};

struct PEObjTbl
{
 BYTE  ObjName[8]; // ������쭮� ��� ��ꥪ�
 DWORD VirtSize;   // ������ ᥪ樨 ��ꥪ� � �����
 DWORD VirtRVA;    // ���饭�� ᥪ樨 �� ��砫� ��ࠧ� � �����
 DWORD PhSize;     // ������ ᥪ樨 ��ꥪ� �� ��᪥
 DWORD PhOffset;   // ���饭�� ᥪ樨 �� ��砫� 䠩��
 DWORD R1[3];      // ???
 DWORD ObjFlags;   // ����� ᢮��� ᥪ樨
};

struct PEITbl
{
 DWORD Chars;      // +00  (���� ⠡���� ���� �㭪権)
 DWORD TimeDate;   // +04  �६�/��� ᮧ�����
 DWORD Forward;    // +08  ???
 DWORD NamePtr;    // +0Ch ���� ���� ������⥪
 DWORD Thunk;      // +10h ���� ������⥪� ���ᮢ �㭪権
                   //      (⠪�� ���� ���� ⠡���� ���� �㭪権)
};

int Infect_COM(char *fn);
int Infect_EXE(char *fn);
int Infect_NE (char *fn);
int Infect_PE (char *fn);
