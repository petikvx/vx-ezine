#pragma inline

#include<mem.h>
#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<ctype.h>
#include <fcntl.h>
#include<string.h>
#include<io.h>
#include<dir.h>
#include<dos.h>

#define LENBUFFER 18
#define TRUE 1
#define FALSE 0

char DirBuffer[MAXPATH];
unsigned char buffer[LENBUFFER];
char *VirusName="Suburbs";
// ��吝�� ��᪠
unsigned char Maska[]={'[','V','D','/','S','L','A','M',']',
                         0,'S','u','b','u','r','b','s',0};
int sign=0;
int Fcure=FALSE;
int Fall =FALSE;
// �ਧ����? �ਧ����!
int Tinf=0, Tfile=0, Tdir=0, Tcure=0;

void CheckFile(char *Handle);
void GrepDir(void);
void CureFile(int Handle);
void CheckMemory(void);
void CheckInt13(void);
int CheckBoot(unsigned char drive);
void FindBoot(unsigned char drive);

void interrupt INT23(...) {
}
void interrupt INT24(...) {
      asm mov al,3
}

//***********************************************************************
void main (int argc, char *argv[]) {
void interrupt ( *oldINT23)(...);
void interrupt ( *oldINT24)(...);
char params;
struct  time t1,t2;
unsigned char drive;
char OldDir[MAXPATH];
getcwd(OldDir, MAXPATH);
if (argc >= 2)  {
     if (!strcmp(argv[1],"/?")) {
        printf("\n ��ଠ� �맮�� antivir [drive] [-cure] [-all]");
        printf("\n   drive   ��� ��᪠ (�� 㬮�砭�� ⥪�騩)");
        printf("\n   -cure   ����� ��ࠦ���� 䠩��");
        printf("\n   -all    �஢����� �� 䠩��\n");
        exit(0);
        } // end "/?"

     for (params=1; params < argc; params++) {
       if (!strcmp(argv[params],"-cure")) Fcure=TRUE;
       if (!strcmp(argv[params],"-all")) Fall=TRUE;
       }

     if ((toupper(*argv[1]) < 'A' && *argv[1] != '-') ||
       (toupper(*argv[1]) > setdisk(getdisk())+'A')) {
       printf("\n�� �� �� ��� ⠪�� %c \n",argv[1]);
       exit(1);
       } // end if < 'A' ||
     setdisk(toupper(*argv[1])-'A');
    } // end if (argc >= 2)
  else printf ("\nantivir /?  ��� �������⥫쭮� ���ଠ樨\n");

// ��� [beep] ����ࠩ� !!!!! ��祭��, � �� ����� !
printf("\n     ������������������������������Ŀ");
printf("\n     � ��⨢��� - '����ﭭ�'      �"); // �� ��� ��᭨���� !
printf("\n     �         (�) 97 �.�����  v1.1 �");
printf("\n     ��[ ");
printf("%c: ",getdisk()+'A');
if (Fall) printf (" *.* ]�������������������\n\n");
    else  printf (" *.com ]�����������������\n\n");

drive=getdisk();
if (drive >= 2) drive=0x80;  // ���� �� ��⠩᪠� ������� :((

chdir("/");
oldINT23=getvect(0x23);
setvect(0x23, INT23);
oldINT24=getvect(0x24);
setvect(0x24, INT24);
CheckMemory();
// �� �����-� ���� � ����� ᨭ������ ��⨪� !!!!
// ���� �� ���� � ⠪�� �������� ��� :))
CheckInt13();

// �᫨ � ��� ������� ᨣ����� ����
// � ����஢뢠�� ����⠭�������� ��� (����, �� � �������� FindBoot :))
if (CheckBoot(drive) && Fcure) FindBoot(drive);

GrepDir();
setvect(0x23,oldINT23);
setvect(0x24,oldINT24);
setdisk(*argv[0]-'A');
chdir(OldDir);
cprintf("%c",8);
printf(" \n �⮣�: �ன���� ��⠫���� %i",Tdir);
printf("\n                    䠩��� %i",Tfile);
printf("\n �� ���: ��ࠦ����� 䠩��� %i",Tinf);
if (Fcure) printf("\n         �뫥祭��� 䠩��� %i",Tcure);
printf("\n");
}
//***********************************************************************
void CureFile(int Handle) {
unsigned char RealByte[3];
 lseek(Handle, 0, SEEK_SET);
 _read(Handle, RealByte, 3);
// � ���� �� ��� 䠩� ???
 if (!((RealByte[0]=='M') && (RealByte[1]=='Z')) ||
      ((RealByte[0]=='Z') && (RealByte[1]=='M'))) {
   // ���-� ��� ������ ���� ��XOR���� �����
   lseek(Handle, -LENBUFFER-3, SEEK_END);
   _read(Handle, RealByte, 3);
   // ����஢��� �� DES �������
   RealByte[0] ^= 0x21;
   RealByte[1] ^= 0x85;
   RealByte[2] ^= 0x2D;
   lseek(Handle, 0, SEEK_SET);
   // ����⠭����� ��ਣ������ ��砫�� �����
   if (_write(Handle, RealByte, 3) != -1) {
            lseek(Handle, -0x189, SEEK_END);
            // ��१��� �����
            if (_write(Handle, RealByte, 0) != -1) {
                                    // ���稪 ��ࠢ����� 䠩��� !!
                                            Tcure++;
                                            printf("   ��楫�� !!");
                                           }
                                       else printf("  �訡�� �����");
           }
      else printf("  �訡�� ����� �ਣ������� ����");
 }  // end if 'MZ' 'ZM'
 else printf(" - ��� 䠩�� ?? �� ���� !!");
}
//***********************************************************************
void CheckMemory(void) {
char maska[]={0xE9,0xED,0x00,0xB0,0x03,0xCF,0x80,
              0xFC,0x4B,0x74,0x03,0xE9,0xDD,0x00};
   asm cld
   // �஢�ઠ �� ��᪥ �� ����稨 � �����
   asm mov ax,0x20
   asm mov es,ax
   asm mov di,0
   asm mov cx,14
   asm lea si,maska
   asm rep cmpsb
   asm jne exit
   asm mov [es:9],0x9090   // �������
   printf("\n� ����� ����� Suburbs - �����०�� !!!\n");
exit:
}
//***********************************************************************
void GrepDir(void) {
struct ffblk ffblk;
int FindDir;
FindDir=findfirst("*.*", &ffblk, 0x10);
 while (!FindDir) {
   if (sign == 60) sign = 0;
   switch (sign) {
     case 0: cprintf("%c|",8); break;
     case 19: cprintf("%c\\",8); break;
     case 39: cprintf("%c-",8); break;
     case 59: cprintf("%c/",8);
   }
   sign++;
   // ��⠫�� ???

   if (ffblk.ff_attrib != 0x10 &&
       (Fall || strstr(ffblk.ff_name,".COM"))) {
          CheckFile(ffblk.ff_name);
    }

   if (ffblk.ff_attrib == 0x10 &&
       ffblk.ff_name[0] != '.') {
               Tdir++;
               chdir(ffblk.ff_name);
               GrepDir();
               chdir("..");
               }

   FindDir = findnext(&ffblk);
   }
}
//***********************************************************************
void CheckFile(char *FileName) {
struct ffblk ffblk;
struct ftime ft;
int Handle, FindFile, FileAttrib;
   Tfile++;
   asm {
   // ��࠭�� ��ਡ��� 䠩�� � ��ᨬ ��
   // �� �� �ᯮ���� � ����� �� �㭪�� �� ��.... � � ....
     mov ax,0x4300
     mov dx,FileName
     int 0x21
     mov FileAttrib,cx
     mov ax,0x4301
     mov cx,0
     mov dx,FileName
     int 0x21
   }
   // �⪪�뢠�� 䠩�� :-))
   Handle=_open(FileName, O_RDWR);
   getftime(Handle, &ft);      // ��࠭��� ����, �६�
   lseek(Handle, -LENBUFFER, SEEK_END);
   _read(Handle, buffer, LENBUFFER);
    if (memcmp(Maska ,buffer, LENBUFFER) == 0) {
                  getcwd(DirBuffer, MAXPATH);
                  cprintf("%c",8);
                  printf("%s\\%s - ����� %s",DirBuffer,FileName,VirusName);
                  // ���稪 ��ࠦ����� 䠩���
                  Tinf++;
                  // "...� ������� ���宩 � ������..."
                  if (Fcure)  CureFile(Handle);
                  printf("\n");
                 }
   setftime(Handle, &ft);  // ����⠭����� ����, �६�
   close(Handle);
   asm {  // ����⠭����� ��ਡ���
     mov cx,FileAttrib
     mov ax,0x4301
     mov dx,FileName
     int 0x21
   }
}

void CheckInt13(void) {
// ���� �������� �� ᥡ� (� ��᫥ �� ⥫� ��⨢���) � ����� ��⨢���
// �� ��� !! ��� ��-�� ��᫥���� ���� ���� ��᪨

char maska[]={0xF8,0x75,0xF4,0x50,0x56,0x1E,0x06,0x33,0xC0,0x8E,0xD8,
              0xE8,0x1B,0x02,0x81,0x3E,0x86,0x00,0x80,0x02,0xEB,0x21,
              0x06,0xC4,0x06,0x84,0x00,0x2E,0x89,0x84,0xB6,0x02,
              0xC3,0xC3}; // �� ����� �� ��᪨ ���᪠ !!!
int lenmaska=sizeof(maska)-2;
     asm mov ax,0
     asm mov es,ax
m1:
     asm mov bx,0
m2:
     asm mov di,bx
     asm lea si,maska
     asm mov cx,lenmaska
     asm rep cmpsb
     asm jnz m3
     asm mov ax,0xC3C3
     asm cmp ax,word ptr[es:di]
     asm je exit  // �� �� �� � ᠬ� � ����� :))
     asm nop       // ���� �� ���? � ����� ᨭ������ ��諨
     asm sub di,lenmaska
     asm mov byte ptr[es:di+1],0xEB   // ������� 13��� ���뢠���
     asm mov byte ptr[es:di+0x1D5],0xEB   // ������� ������樨
     printf("\n� ����� ����� new!boot - �����०�� !!!\n");
     asm jmp exit
m3:
     asm inc bx
     asm jnz m2
     asm mov ax,es
     asm add ax,0x1000
// ��� ⠪ � 饤� ��� ����, �� �� ᠬ��
// ���������� :)) � � �������� !!
     asm cmp ax,0xA000
     asm je exit
     asm mov es,ax
     asm jmp m1
exit:
}
//************************************************************
int CheckBoot(unsigned char drive) {
unsigned char buffer[512];
char maska[]={0xFA,0x33,0xC0,0x8E,0xD0,0xBC,0x00,0x7C,
              0xBB,0x13,0x04,0x36,0x83,0x2F,0x02,0xCD,0x12,
              0xB1,0x06,0xD3,0xE0,0x50,0x8E,0xC0,0xBA};
int lenmaska=sizeof(maska);
int offmaska=0x3E; // ᬥ饭�� �� ��砫� �ࠢ����� � ���
char track=0;
if (drive >= 0x80) track=1;

 asm mov ax,0x201  // �⠥� ���� ᥪ��
 asm mov cx,1      // �㫥��� ᥪ�� � 樫����
 asm mov dh,track      // ��ࢠ� ��஭�
 asm mov dl,drive  // ���ன�⢮
 asm lea bx,buffer
 asm int 0x13
 asm jnc m1
 printf("\n�訡�� �� �⥭�� BOOT ᥪ�� ��᪠\n");
 return FALSE;
m1:
 asm lea si,maska
 asm lea di,buffer
 asm add di,offmaska
 asm mov cx,lenmaska
 asm rep cmpsb
 asm jnz exit
 if (drive < 0x80) printf("\n� ��� %c: ����� - new!boot !!!\n",getdisk()+'A');
  else printf("\n� ��� C: ����� - new!boot !!!\n");
 return TRUE;
exit:
 return FALSE;
}
//***************************************************
void FindBoot(unsigned char drive) {
unsigned char buffer[512];
char track=0;
if (drive >= 0x80) track=1;
 asm mov ax,0x201  // �⠥� ���� ᥪ��
 asm mov cx,1      // �㫥��� ᥪ�� � 樫����
 asm mov dh,track      // ��஭�
 asm mov dl,drive  // ���ன�⢮
 asm lea bx,buffer
 asm int 0x13
 asm jnc m1
 printf("\n�訡�� �� �⥭�� ����᭮�� BOOT ᥪ�� ��᪠\n");
 asm jmp exit
m1:
 asm mov ax,[ds:bx+0x16]    // ࠧ��� FAT � ᥪ���
 asm mul byte ptr[ds:bx+0x10] // ������⢮ FAT
 asm mov dx,[ds:bx+0x11]      // �᫮ ����ᥩ� ��୥��� ��⠫���
 asm mov cl,4
 asm shr dx,cl
 asm add ax,dx
 asm xor dx,dx
 asm div word ptr[ds:bx+0x18] // �᫮ ᥪ�� �� ��஦��
 asm add al,track
 asm push dx
 asm xor dx,dx
 asm div word ptr[ds:bx+0x1A] // �᫮ ��஭ (�������)
 asm mov dh,dl
 asm pop cx
 asm mov ax,0x201  // �⠥� ���� ᥪ��
 asm mov dl,drive  // ���ன�⢮
 asm lea bx,buffer
 asm int 0x13
 asm jnc m2
 printf("\n�訡�� �� �⥭�� �����饣� BOOT ᥪ�� ��᪠\n");
 asm jmp exit
m2: // ����஢��
 asm mov ax,'Po'
 asm mov cx,0x1FF
decod:
 asm xor ds:[bx],ax
 asm add ax,'pu'
 asm inc bx
 asm loop decod
 printf("\n�����஢�� BOOT�");
 asm mov ax,0x301  // �����뢠�� ����஢���� boot
 asm mov cx,1      // �㫥��� ᥪ�� � 樫����
 asm mov dh,track      // ��஭�
 asm mov dl,drive  // ���ன�⢮
 asm lea bx,buffer
 asm int 0x13
 asm jnc m3
 printf("\n�訡�� �� ����� BOOT ᥪ�� ��᪠\n");
 goto exit;
m3:
 printf(" - ����ᠭ !!!\n");
exit:
}