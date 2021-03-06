/*********************************************************************/
/*         ���⥩訩 ��⨢���� �� Borland ��� TopSpeed C            */
/*                        by DrMad for ZF4                           */
/*********************************************************************/
#include <stdio.h>
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

char
 path    [PATH_LEN],  /* ��ப� ����� ⥪�饣� �����⠫���           */
 old_path[PATH_LEN],  /* ��ப� ����� ��砫쭮�� ���⮯��������      */
 drive   [DRIVE_LEN], /* ��ப� ����� �ॡ㥬��� ���ன�⢠          */
 blank   [BLANK_LEN]; /* ����� ��ப�                               */
int
 n_dir,               /* ������⢮ ��᪠��஢����� ��⠫����        */
 n_fil,               /* ������⢮ ��᫥�������� 䠩���             */
 n_ill,               /* ������⢮ ������ � ��楫����� 䠩���      */
 l,                   /* ����� ����� 䠩��                           */
 i;                   /* �६���� ������                            */

/*********************************************************************/
/*         ��楤�� �஢�ન ��ࠦ������ ����ᮬ 460               */
/*********************************************************************/
int infected1( char *fn )
 {

  int f, q, r;
  long p;
  unsigned char sigbuf[8];

  f = open( fn, O_BINARY|O_RDWR);
  q = read( f , sigbuf, 3);
  if (sigbuf[0]==0xE9)           // ��ࢠ� ������� JMP ?
   {
    p = lseek( f, (long)(*((unsigned *)(&sigbuf[1])))+3, SEEK_SET);
    q = read(f, sigbuf, 8);
    if((sigbuf[0]==0x1E)&&       // �஢�ઠ ᨣ������
       (sigbuf[1]==0x8C)&&
       (sigbuf[2]==0xD8)&&
       (sigbuf[3]==0x05)&&
       (sigbuf[6]==0x8E)&&
       (sigbuf[7]==0xD8))
        { n_ill++; r=BAD; printf(" - ����� 460 � ��楫��!\n"); }
     else r=GOOD;
  }
  else r=GOOD;
  close(f);
  return r;
}

/**********************************************************************/
/*       ��楤�� ��祭�� �� ����� 460                              */
/**********************************************************************/
cure1( char *fn )
 {
  int  f, q, i;
  long l, p;
  unsigned char buf[3], par[16];

  f = open ( fn, O_BINARY|O_RDWR );
  l = lseek( f, 0, SEEK_END );          // ����� 䠩��
  p = lseek( f, l-0x9B, SEEK_SET);      // �� "������"
  q = read ( f, buf, 3);                // ����⠭�� �����
  p = lseek( f, 0, SEEK_SET );          // �� ��砫�
  q = write( f, buf, 3);                // �����頥� �� ����
  p = lseek( f, l-0x1C4-16, SEEK_SET);  // �� ��砫� ����� "� ����ᮬ"
  q = read ( f, par, 16);               // ��⠥� ����� �ண� � ��砫� ����
  i=15; while ((!par[i])&&(i)) i--;     // �饬 �࠭���
  p = lseek( f, l-0x1C4-15+i, SEEK_SET);// ��⨭�� ����� �ண�
  q = _write( f, par, 0);               // ���㡠�� 墮��
  close(f);
}

/**********************************************************************/
/*       ��楤�� �஢�ન ��ࠦ������ ����ᮬ 112                  */
/**********************************************************************/
int infected2( char *fn )
 {
  int f, q, r;
  long p;
  unsigned char sigbuf[8];

  f = open( fn, O_BINARY|O_RDWR);
  q = read(f, sigbuf, 8);
  if((sigbuf[0]==0x8C)&&       // �஢�ઠ ᨣ������
     (sigbuf[1]==0xCA)&&
     (sigbuf[2]==0xFE)&&
     (sigbuf[3]==0xC6)&&
     (sigbuf[4]==0x8E)&&
     (sigbuf[5]==0xC2))
      { n_ill++; r=BAD; printf(" - ����� 112 � ��楫��!\n"); }
  else r=GOOD;
  close(f);
  return r;
}

/**********************************************************************/
/*       ��楤�� ��祭�� �� ����� 112                              */
/**********************************************************************/
cure2( char *fn)
 {
  int  f, q, p, i;
  long l, _r, _w;
  unsigned char buf[112];

  f = open ( fn, O_BINARY|O_RDWR );
  _r = 112;                         // ������ �⥭��
  _w = 0;                           // ������ �����
  q = 112;
  while (q==112)
  {
   lseek( f, _r, SEEK_SET );
   q  = read ( f, buf, 112);
   lseek( f, _w, SEEK_SET );
   write( f, buf, q);                // ��襬 ᪮�쪮 ���⠫� !
   _r+=112;                          // ���६����㥬 ������ �⥭��
   _w+=112;                          // ���६����㥬 ������ �����
  }
  _write( f, buf, 0);                // ��ᥪ��� 墮��
  close(f);
}

/**********************************************************************/
/* �����ᨢ��� ��楤�� ��室� ��ॢ� ��⠫���� "��⮤�� ���室��": */
/* - �஢��塞� ��⠫�� �ᥣ�� ⥪�騩;                              */
/* - ��᪠ ���᪠ �ᥣ�� "*.*".                                       */
/**********************************************************************/
walk()
 {
  int found_d, found_f;
  struct find_t buf;

  /* ���� ��⠫���� */
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

  /* � �⮬� ������� ����᪠��஢����� ���������� ��⠫����
  ����� �� ��⠫��� - ᪠���㥬 䠩�� */

  n_dir++;
  getcwd( path, PATH_LEN );

  /* ���� 䠩��� */
  found_f = _dos_findfirst("*.*",_A_NORMAL ,&buf);
  while (found_f == F_FOUND)
   {
    l = strlen( buf.name );
    if (((buf.name[l-3]=='C')&&
         (buf.name[l-2]=='O')&&
         (buf.name[l-1]=='M'))||
        ((buf.name[l-3]=='E')&&
         (buf.name[l-2]=='X')&&
         (buf.name[l-1]=='E')))
          {
           n_fil++;
           printf("%c%s",13,blank);
           printf("%c%s\\%s ",13,path,buf.name);

           /* ��諨 ���� 䠩� - ���� �஢���� ��� ��
           ����஢������� �, �᫨ ��ࠦ��, � �뫥��� */
           if (infected1(buf.name)==BAD) cure1(buf.name);
           if (infected2(buf.name)==BAD) cure2(buf.name);

          }
    found_f = _dos_findnext( &buf );
   }
}

/***************************************************************/
/*  �������� ��楤��                                         */
/***************************************************************/
main( int argc, char *argv[] )
 {
  puts("������������������������������Ŀ");
  puts("��ணࠬ�� - ���⥩訩  ���ࣳ");
  puts("�      ����� : CAV <���:>    �");
  puts("��������������������������������");

  if (argc < 2)
   { puts("������ ��� ��᪠ � ����⢥ ��ࠬ���"); exit(2); }

  if (((toupper(argv[1][0]))>'Z')||((toupper(argv[1][0]))<'A'))
   { puts("����୮ ������ ��� ��᪠"); exit(3); }

  drive[0]=argv[1][0];
  drive[1]=':' ;
  drive[3]='\0';
  for (i=0;i<BLANK_LEN;i++) blank[i]=' ';
  blank[BLANK_LEN-1] = '\0';
  n_dir = 0; n_fil = 0;

  getcwd(old_path, PATH_LEN);
  drive[2]='\0'; system(drive);
  drive[2]='\\'; chdir(drive);

  walk();     // ����᪠�� ४��ᨢ�� ��室

  old_path[2]='\0';
  system(old_path);
  old_path[2]='\\';
  chdir(old_path);

  printf("\n��⠫���� : %d\n������ : %d\n�����㦥�� ������ � ����祭� : %d",
         n_dir, n_fil, n_ill);

  if (n_ill) exit(1); else exit(0);

}