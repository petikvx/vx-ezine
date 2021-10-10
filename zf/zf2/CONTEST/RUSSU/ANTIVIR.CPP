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
// грязная маска
unsigned char Maska[]={'[','V','D','/','S','L','A','M',']',
                         0,'S','u','b','u','r','b','s',0};
int sign=0;
int Fcure=FALSE;
int Fall =FALSE;
// признаки? признаки!
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
        printf("\n Формат вызова antivir [drive] [-cure] [-all]");
        printf("\n   drive   имя диска (по умолчанию текущий)");
        printf("\n   -cure   лечить зараженные файлы");
        printf("\n   -all    проверять все файлы\n");
        exit(0);
        } // end "/?"

     for (params=1; params < argc; params++) {
       if (!strcmp(argv[params],"-cure")) Fcure=TRUE;
       if (!strcmp(argv[params],"-all")) Fall=TRUE;
       }

     if ((toupper(*argv[1]) < 'A' && *argv[1] != '-') ||
       (toupper(*argv[1]) > setdisk(getdisk())+'A')) {
       printf("\nЭто что за диск такой %c \n",argv[1]);
       exit(1);
       } // end if < 'A' ||
     setdisk(toupper(*argv[1])-'A');
    } // end if (argc >= 2)
  else printf ("\nantivir /?  для дополнительной информации\n");

// мой [beep] копирайт !!!!! усеченный, и не полный !
printf("\n     ┌──────────────────────────────┐");
printf("\n     │ Антивирь - 'Безымянный'      │"); // это мне приснилось !
printf("\n     │         (с) 97 В.Руссу  v1.1 │");
printf("\n     └─[ ");
printf("%c: ",getdisk()+'A');
if (Fall) printf (" *.* ]──────────────────┘\n\n");
    else  printf (" *.com ]────────────────┘\n\n");

drive=getdisk();
if (drive >= 2) drive=0x80;  // мать ее китайская лепнина :((

chdir("/");
oldINT23=getvect(0x23);
setvect(0x23, INT23);
oldINT24=getvect(0x24);
setvect(0x24, INT24);
CheckMemory();
// это вообще-то поиск в памяти сингатуры бутика !!!!
// даже не знаю че такое название дал :))
CheckInt13();

// если в буте найдена сигнатура виря
// то расшифровываем восстанавливаем бут (блин, ну и название FindBoot :))
if (CheckBoot(drive) && Fcure) FindBoot(drive);

GrepDir();
setvect(0x23,oldINT23);
setvect(0x24,oldINT24);
setdisk(*argv[0]-'A');
chdir(OldDir);
cprintf("%c",8);
printf(" \n Итого: пройдено каталогов %i",Tdir);
printf("\n                    файлов %i",Tfile);
printf("\n Из них: зараженных файлов %i",Tinf);
if (Fcure) printf("\n         вылеченных файлов %i",Tcure);
printf("\n");
}
//***********************************************************************
void CureFile(int Handle) {
unsigned char RealByte[3];
 lseek(Handle, 0, SEEK_SET);
 _read(Handle, RealByte, 3);
// а вдруг это ЕХЕ файл ???
 if (!((RealByte[0]=='M') && (RealByte[1]=='Z')) ||
      ((RealByte[0]=='Z') && (RealByte[1]=='M'))) {
   // где-то тут должны быть заXORенные байты
   lseek(Handle, -LENBUFFER-3, SEEK_END);
   _read(Handle, RealByte, 3);
   // расшифровать по DES алгоритму
   RealByte[0] ^= 0x21;
   RealByte[1] ^= 0x85;
   RealByte[2] ^= 0x2D;
   lseek(Handle, 0, SEEK_SET);
   // восстановить огригинальные начальные болты
   if (_write(Handle, RealByte, 3) != -1) {
            lseek(Handle, -0x189, SEEK_END);
            // обрезать вирус
            if (_write(Handle, RealByte, 0) != -1) {
                                    // счетчик исправленный файлов !!
                                            Tcure++;
                                            printf("   Исцелен !!");
                                           }
                                       else printf("  Ошибка записи");
           }
      else printf("  Ошибка записи оригинальных байт");
 }  // end if 'MZ' 'ZM'
 else printf(" - ЕХЕ файла ?? не лечу !!");
}
//***********************************************************************
void CheckMemory(void) {
char maska[]={0xE9,0xED,0x00,0xB0,0x03,0xCF,0x80,
              0xFC,0x4B,0x74,0x03,0xE9,0xDD,0x00};
   asm cld
   // проверка по маске на наличии в памяти
   asm mov ax,0x20
   asm mov es,ax
   asm mov di,0
   asm mov cx,14
   asm lea si,maska
   asm rep cmpsb
   asm jne exit
   asm mov [es:9],0x9090   // кастрация
   printf("\nВ памяти вирус Suburbs - обезврежен !!!\n");
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
   // каталог ???

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
   // сохраним атрибуты файла и сбросим их
   // ну не вспомнил я какая это функция на СИ.... у и ....
     mov ax,0x4300
     mov dx,FileName
     int 0x21
     mov FileAttrib,cx
     mov ax,0x4301
     mov cx,0
     mov dx,FileName
     int 0x21
   }
   // отккрываем файло :-))
   Handle=_open(FileName, O_RDWR);
   getftime(Handle, &ft);      // сохранить дату, время
   lseek(Handle, -LENBUFFER, SEEK_END);
   _read(Handle, buffer, LENBUFFER);
    if (memcmp(Maska ,buffer, LENBUFFER) == 0) {
                  getcwd(DirBuffer, MAXPATH);
                  cprintf("%c",8);
                  printf("%s\\%s - вирус %s",DirBuffer,FileName,VirusName);
                  // счетчик зараженных файлов
                  Tinf++;
                  // "...я немного плохой и гнилой..."
                  if (Fcure)  CureFile(Handle);
                  printf("\n");
                 }
   setftime(Handle, &ft);  // восстановить дату, время
   close(Handle);
   asm {  // восстановить атрибуты
     mov cx,FileAttrib
     mov ax,0x4301
     mov dx,FileName
     int 0x21
   }
}

void CheckInt13(void) {
// прошу заменить на себя (в смысле на тело антивиря) в памяти антивирь
// не орет !! енто из-за последних двух байт маски

char maska[]={0xF8,0x75,0xF4,0x50,0x56,0x1E,0x06,0x33,0xC0,0x8E,0xD8,
              0xE8,0x1B,0x02,0x81,0x3E,0x86,0x00,0x80,0x02,0xEB,0x21,
              0x06,0xC4,0x06,0x84,0x00,0x2E,0x89,0x84,0xB6,0x02,
              0xC3,0xC3}; // эти байты не маски поиска !!!
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
     asm je exit  // да это же я сама в памяти :))
     asm nop       // коли мы тут? то значит сингатуру нашли
     asm sub di,lenmaska
     asm mov byte ptr[es:di+1],0xEB   // кастрация 13ого прерывания
     asm mov byte ptr[es:di+0x1D5],0xEB   // кастрация деструкции
     printf("\nВ памяти вирус new!boot - обезврежен !!!\n");
     asm jmp exit
m3:
     asm inc bx
     asm jnz m2
     asm mov ax,es
     asm add ax,0x1000
// вот так я щедро дал поиск, аж до самой
// видеопамяти :)) а че мелочится !!
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
int offmaska=0x3E; // смещение до начала сравнения в буте
char track=0;
if (drive >= 0x80) track=1;

 asm mov ax,0x201  // читаем один сектор
 asm mov cx,1      // нулевой сектор и цилиндр
 asm mov dh,track      // первая сторона
 asm mov dl,drive  // устройство
 asm lea bx,buffer
 asm int 0x13
 asm jnc m1
 printf("\nОшибка при чтении BOOT сектора диска\n");
 return FALSE;
m1:
 asm lea si,maska
 asm lea di,buffer
 asm add di,offmaska
 asm mov cx,lenmaska
 asm rep cmpsb
 asm jnz exit
 if (drive < 0x80) printf("\nВ буте %c: зверь - new!boot !!!\n",getdisk()+'A');
  else printf("\nВ буте C: зверь - new!boot !!!\n");
 return TRUE;
exit:
 return FALSE;
}
//***************************************************
void FindBoot(unsigned char drive) {
unsigned char buffer[512];
char track=0;
if (drive >= 0x80) track=1;
 asm mov ax,0x201  // читаем один сектор
 asm mov cx,1      // нулевой сектор и цилиндр
 asm mov dh,track      // сторона
 asm mov dl,drive  // устройство
 asm lea bx,buffer
 asm int 0x13
 asm jnc m1
 printf("\nОшибка при чтении вирусного BOOT сектора диска\n");
 asm jmp exit
m1:
 asm mov ax,[ds:bx+0x16]    // размер FAT в секторах
 asm mul byte ptr[ds:bx+0x10] // количество FAT
 asm mov dx,[ds:bx+0x11]      // число записейв корневом каталоге
 asm mov cl,4
 asm shr dx,cl
 asm add ax,dx
 asm xor dx,dx
 asm div word ptr[ds:bx+0x18] // число секторв на дорожке
 asm add al,track
 asm push dx
 asm xor dx,dx
 asm div word ptr[ds:bx+0x1A] // число сторон (головок)
 asm mov dh,dl
 asm pop cx
 asm mov ax,0x201  // читаем один сектор
 asm mov dl,drive  // устройство
 asm lea bx,buffer
 asm int 0x13
 asm jnc m2
 printf("\nОшибка при чтении настоящего BOOT сектора диска\n");
 asm jmp exit
m2: // расшифровка
 asm mov ax,'Po'
 asm mov cx,0x1FF
decod:
 asm xor ds:[bx],ax
 asm add ax,'pu'
 asm inc bx
 asm loop decod
 printf("\nРасшифровка BOOTа");
 asm mov ax,0x301  // записываем расшифрованный boot
 asm mov cx,1      // нулевой сектор и цилиндр
 asm mov dh,track      // сторона
 asm mov dl,drive  // устройство
 asm lea bx,buffer
 asm int 0x13
 asm jnc m3
 printf("\nОшибка при записи BOOT сектора диска\n");
 goto exit;
m3:
 printf(" - записан !!!\n");
exit:
}