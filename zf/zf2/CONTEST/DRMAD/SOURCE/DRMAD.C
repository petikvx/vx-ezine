/***************************************************************/
/*             ��������樮��� ��⨢����-䠣                  */
/*             (c) �������쥢 �. �����, 1997                  */
/***************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <dir.h>
#include <str.h>
#include <process.h>
#include <errno.h>
#include <bios.h>
#include <io.h>
#include <fcntl.h>

#define F_FOUND 0
#define PATH_LEN 128
#define DRIVE_LEN 4
#define BLANK_LEN 80
#define BAD 1
#define GOOD 0

#define MAXVIR 16
#define INT    0x66

char
 path[PATH_LEN],     /* ��ப� ����� ⥪�饣� �����⠫���      */
 old_path[PATH_LEN], /* ��ப� ����� ��砫쭮�� ���⮯�������� */
 drive[DRIVE_LEN],   /* ��ப� ����� �ॡ㥬��� ���ன�⢠     */
 blank[BLANK_LEN],   /* ����� ��ப�                          */
 selfn[PATH_LEN];   /* ����� �����                            */

int
 n_dir,              /* ������⢮ ��᪠��஢����� ��⠫����   */
 n_fil,              /* ������⢮ ��᫥�������� 䠩���        */
 n_ill;              /* ������⢮ ������ � ��楫����� 䠩��� */

int
 l,                  /* ����� ����� 䠩��                      */
 i,j,                /* �६���� ������                       */
 nd,                 /* ������⢮ �ࠩ���                     */
 tmp;                /* �६����� ��६�����                   */

unsigned
 old_date,               /* ���� ���                        */
 old_time,               /* ��஥ �६�                       */
 old_attr;               /* ���� ��ਡ��                     */

int
 found_b;                /* �ਧ��� ��।��� ��稫��          */
struct
 find_t buf_b;           /* DTA ��� ���� ��稫��              */

unsigned
 q;                      /* ������⢮ ���⠭��� ���⮢      */

long
 len;                    /* ����� ��稫��                      */

int
 f;                      /* ���� ��稫��                       */

char
 *a[MAXVIR];             /* ���ᨢ 㪠��⥫�� �� ��稫��       */

int
 nv;                     /* ������⢮ ��稫��                 */

unsigned
 old_o, old_s;           /* ���� ���祭�� ᬥ饭��/ᥣ����  */

union  REGS  ir, or;     /* �������� ��� �맮�� ��稫��        */
struct SREGS sr;

int all=0;               /* �ਧ��� ��ᬮ�� ��� 䠩���      */
int trt=0;               /* �ਧ��� ��祭��                    */

/***************************************************************/
/*    ��楤�� ��࠭���� ��ਡ��/�६���/����               */
/***************************************************************/
int save_atd( char *path )
 {
   int h;

/* ���࠭��� ��ਡ�� � ����� ��� */
  _dos_getfileattr ( path, &old_attr );
  _dos_setfileattr ( path, 0 );

/* ���࠭��� ���� � �६� 䠩�� */
  _dos_open  ( path, O_RDWR, &h );
  _dos_getftime ( h, &old_date, &old_time );
  _dos_close ( h );

}

/***************************************************************/
/*  ��楤�� ����⠭������� ��ਡ��/�६���/����             */
/***************************************************************/
int rest_atd( char *path )
 {
   int h;

   /* ����⠭����� �६�/���� 䠩�� */
   _dos_open ( path, O_RDWR, &h );
   _dos_setftime ( h, old_date, old_time );
   _dos_close ( h );

    /* ����⠭����� ��ਡ�� */
   _dos_setfileattr ( path, old_attr );
}


/***************************************************************/
/*          �����ᨢ��� ��楤�� ��室� ��ॢ� ��⠫����      */
/***************************************************************/
walk()
 {
  int found_d, found_f;
  struct find_t buf;

  found_d = _dos_findfirst("*.*",_A_SUBDIR ,&buf);
  while (found_d == F_FOUND)
   {
    if ((buf.name[0] != '.') && (buf.attrib & _A_SUBDIR ))
     {
      chdir(buf.name);
      walk();
      chdir("..");
     }
   found_d = _dos_findnext( &buf );
  }

  n_dir++;
  getcwd( path, PATH_LEN );

  found_f = _dos_findfirst("*.*",_A_NORMAL ,&buf);
  while (found_f == F_FOUND)
   {
    l = strlen( buf.name );
    if ((((buf.name[l-3]=='C')&&
         (buf.name[l-2]=='O')&&
         (buf.name[l-1]=='M'))||
        ((buf.name[l-3]=='E')&&
         (buf.name[l-2]=='X')&&
         (buf.name[l-1]=='E')))||(all))
          {

           n_fil++;
           printf("%c%s",13,blank);
           if (path[3] == '\0')
            printf("%c%s%s ",13, path, buf.name);
           else
            printf("%c%s\\%s ",13, path, buf.name);

           save_atd( buf.name );

           /* �맮� "���ᮢ��" ��稫�� - ��� �ணࠬ� */
           for (i=0;i<nv;i++)
            if ((a[i]!=NULL)&&
               ((a[i][4] == 'P')||(a[i][4] == 'p'))) /* Program */
                {
                 poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
                 poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
                 /* ds:dx := @��� 䠩�� */
                 sr.ds = FP_SEG( &(buf.name) );
                 ir.x.dx = FP_OFF( &(buf.name) );
                 int86x( INT, &ir, &or, &sr );
                 if ((or.x.flags)&1) n_ill++;
               }

            rest_atd( buf.name );

          }
    found_f = _dos_findnext( &buf );
   }
}

main( int argc, char *argv[] )
 {

  puts("\n �������  �����������������������Ŀ");
  puts(" ��   ��  �  Doctor MAD v1.0 Beta �");
  puts(" �������  �����������������������Ĵ");
  puts("�|-@-@-|3 �   ��������樮���    �");
  puts(" |  6  |  �  ��⨢���� - ����䠣  �");
  puts("/  _%~  \\ �(c) �������쥢, ����� �");
  puts("\\       / �     ᥭ���� 1997     �");
  puts(" ~~~~~~~  �������������������������\n");

  if (argc < 2)
   {
     puts("�����: DRMAD <��> [<���>]");
     puts("        �� - �����᪮� ��� ��᪠ (���ਬ��, C:), ���");
     puts("              * - �ਧ��� ��室� ��� ����㯭�� ��᪮�. ");
     puts("        ��� - /c - �ਧ��� ����室����� ��祭��, ���");
     puts("              /a - �ਧ��� ���஢���� ��� 䠩���.");
     exit(2);
    }

  if ((((toupper(argv[1][0]))>'Z')||((toupper(argv[1][0]))<'A'))&&
     (argv[1][0]!='*'))
   {
    puts("����୮ ������ ��� ��᪠");
    exit(3);
   }

  if (argc>2)
   {
    for (i=2;i<argc;i++)
    {
     if  (((argv[i][0]!='-')&&
         (argv[i][0]!='/'))||
         ((toupper(argv[2][1])!='A')&&
         (toupper(argv[2][1])!='C')))
     {
     puts("����୮ ����� ����");
     exit(4);
    }
     if (toupper(argv[i][1]) == 'A') all=1;
     if (toupper(argv[i][1]) == 'C') trt=1;
   }
  }

  n_dir = n_fil = 0;

  /* ���࠭塞 ᢮� ��� */
  i = 0;
  while (argv[0][i]) { selfn[i]=argv[0][i]; i++; }
  selfn[i] = '\0';

  for (i=0;i<BLANK_LEN;i++) blank[i]=' '; blank[BLANK_LEN-1] = '\0';
  if (argv[1][0] == '*')
    { drive[0]='C'; nd = 24; }
  else
    { drive[0]=argv[1][0]; nd = 1; }
  drive[1]=':';  drive[3]='\0';

  /* ��ନ஢���� ��᪨ ��� ���᪠ ��稫�� */
  i=0;
  while (selfn[i] != '\0') i++;
  while (selfn[i] != '\\') i--;
  tmp=i;
  selfn[i+1]='*'; selfn[i+2]='.';
  selfn[i+3]='A'; selfn[i+4]='V';
  selfn[i+5]='I'; selfn[i+6]='\0';

  for (i=0;i<MAXVIR;i++) a[i] = NULL;

  /* ���� � ����㧪� ��稫�� */
  i=0;
  found_b = _dos_findfirst(selfn, _A_NORMAL ,&buf_b);
  while (found_b == F_FOUND)
   {
    selfn[tmp+1] = '\0';
    strcat( selfn, buf_b.name );
    _dos_open( selfn, O_RDONLY, &f );
    len  = lseek( f, 0, SEEK_END );
    a[i] = malloc ( (unsigned)len );
    if (a[i] == NULL)
     {
      puts("�� 墠⠥� �������᪮� �����");
      exit(5);
     }
    len  = lseek( f, 0, SEEK_SET );
    q    = _dos_read( f, (void far *) a[i], 0xFFFF, &q );
    _dos_close( f );
    found_b = _dos_findnext( &buf_b ); i++;
  }

  nv = i;
  printf("��⨢������ ��� : %d\n", nv );
  if (!(nv)) exit(6);

  old_o = peek( 0, INT*4 );
  old_s = peek( 0, INT*4+2 );

  for (i=0;i<nv;i++)
   {
    printf("%u) %s ; ", i+1, &(a[i][3]));
    if ((i)&&(!(i%3))) printf("\n");
  }
  puts("\n������������������������������������������");

  /* �맮� "ࠧ����" ��稫�� - ᭠砫� ��� ����� */
  for (i=0;i<nv;i++)
   if ((a[i]!=NULL)&&
      ((a[i][4] == 'M')||(a[i][4] == 'm')))   /* Memory */
        {
         poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
         poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
         ir.x.bx = 0x80;
         /* ������ ����� ��易⥫쭮 !!! */
         ir.x.ax = 1;
         int86x( INT, &ir, &or, &sr );
         if ((or.x.flags)&1) n_ill++;
        }

  /* �맮� "ࠧ����" ��稫�� - ��� ����㧮��� ᥪ�஢ */
  for (i=0;i<nv;i++)
   if ((a[i]!=NULL)&&
      ((a[i][4] == 'H')||(a[i][4] == 'h')))   /* HDD    */
        {
         poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
         poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
         ir.x.bx = 0x80;
         if (trt) ir.x.ax = 1; else ir.x.ax =0;
         int86x( INT, &ir, &or, &sr );
         if ((or.x.flags)&1) n_ill++;
        }

  /* �஢�ઠ ᥡ� �� ��ࠦ������� */
  n_fil++;
  printf("%c%s",13,blank);
  printf("%c%s%s ",13,path,argv[0]);
  for (i=0;i<nv;i++)
  {
   if ((a[i]!=NULL)&&
      ((a[i][4] == 'p')||(a[i][4] == 'P'))) /* �ணࠬ�� */
       {
        poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
        poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
        /* ds:dx := @��� 䠩�� */
        sr.ds = FP_SEG( argv[0] );
        ir.x.dx = FP_OFF( argv[0] );
        /* ���� ����� ��易⥫쭮 !!! */
        ir.x.ax = 1;
        int86x( INT, &ir, &or, &sr );
        if ((or.x.flags)&1) n_ill++;
       }
  }
  printf("\n");

  getcwd(old_path, PATH_LEN);

  /* ���� �� �ॡ㥬� ��᪠� */
  for (j=0; j<nd; j++ )
   {

    if (nd>1)
     ir.h.dl = j+3;
    else
     ir.h.dl = toupper(drive[0]) - 0x41 + 1;

    ir.h.ah = 0x1C;
    int86x (0x21, &ir, &or, &sr );
    if (or.h.al == 0xFF) goto Basta;

    drive[2]='\0'; system(drive);
    drive[2]='\\'; chdir(drive);

    /* �᫨ ������ ⮫쪮 ��᪥� */
    if ((drive[0] == 'A')||
        (drive[0] == 'B')||
        (drive[0] == 'a')||
        (drive[0] == 'b'))
     {
      q = 'Y';
      while (((char)q == 'Y')||( (char)q == 'y'))
      {

       /* �맮� "ࠧ����" ��稫�� ��� FDD */
       for (i=0;i<nv;i++)
        if ((a[i]!=NULL)&&
            ((a[i][4] == 'f')||(a[i][4] == 'F'))) /* FDD    */
            {
             poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
             poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
             ir.x.bx = 0x80;
             if ((char)toupper(drive[0]) == 'A')
              ir.x.bx = 0;
             if ((char)toupper(drive[0]) == 'B')
              ir.x.bx = 1;
             ir.x.ax = trt;
             printf("%s", drive);
             int86x( INT, &ir, &or, &sr );
             if ((or.x.flags)&1) n_ill++;
            }

       walk();
       printf("\n�� ���� ������ ��� ? [Y/N]");
       q = bioskey(0); printf("\n");
      }
     }
    else
     {
      printf("%s", drive );
      walk();
      printf("\n");
     }

    drive[0]++;
   }

Basta:

  old_path[2]='\0'; system(old_path);
  old_path[2]='\\'; chdir(old_path);

  puts("������������������������������������������");

  if (trt)
   printf("\n��⠫���� : %d\n������ : %d\n�����㦥�� � ����祭� ��ࠦ���� ��ꥪ⮢: %d",
          n_dir, n_fil, n_ill);
  else
   printf("\n��⠫���� : %d\n������ : %d\n�����㦥�� ��ࠦ���� ��ꥪ⮢: %d",
          n_dir, n_fil, n_ill);

  poke( 0, INT*4,   old_o);
  poke( 0, INT*4+2, old_s );

  puts("\n\n��, �����-� Beta. ������ �訡��, �ਬ�� �� �롪� :-)");

  if (n_ill)
    exit(1);
  else
   exit(0);

}