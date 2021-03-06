/*******************************************************************/
/* DULLLIB - ������⥪� ��楤�� ��� ��������樮����� �������� */
/* ������� ���� �� ��� ��� COM/EXE/NE/PE �ணࠬ�.               */
/* (c) �������쥢 �., ����� 2001                                  */
/*******************************************************************/
#include <stdio.h>
#include <io.h>
#include <stat.h>
#include <fcntl.h>
#include <dos.h>
#include <string.h>
#include <alloc.h>
#include <string.h>
#include "dullpro.h"

extern unsigned char BIOS_CSUM;

unsigned char Module_COM[C_LEN] =
{
0x60, 0x1E, 0x68, 0x00, 0xF0, 0x1F, 0x2B, 0xC0, 0x8B, 0xF0, 0xB9,
0x00, 0x01, 0xFC, 0xAC, 0x02, 0xE0, 0xE2, 0xFB, 0x1F, 0x80, 0xFC,
0x00, 0x61, 0x74, 0x01, 0xC3, 0xC6, 0x06, 0x00, 0x01, 0x00, 0xC6,
0x06, 0x01, 0x01, 0x00, 0xC6, 0x06, 0x02, 0x01, 0x00, 0x68, 0x00,
0x01, 0xC3
};

unsigned char Module_EXE[E_LEN] =
{
0x060,0x01E,0x068,0x000,0x0F0,0x01F,0x02B,0x0C0,
0x08B,0x0F0,0x0B9,0x000,0x001,0x0FC,0x0AC,0x002,
0x0E0,0x0E2,0x0FB,0x01F,0x080,0x0FC,0x000,0x061,
0x074,0x004,0x0B4,0x04C,0x0CD,0x021,0x08C,0x0C0,
0x005,0x000,0x000,0x050,0x068,0x000,0x000,0x0CB
};

unsigned char Module_PE[P_LEN] =
{
 0x060, 0x0BE, 0x000, 0x000, 0x00F, 0x000, 0x02B, 0x0C0,
 0x0B9, 0x000, 0x001, 0x000, 0x000, 0x0FC, 0x0AC, 0x002,
 0x0E0, 0x0E2, 0x0FB, 0x080, 0x0FC, 0x000, 0x00F, 0x084,
 0x009, 0x000, 0x000, 0x000, 0x061, 0x06A, 0x000, 0x0FF,
 0x015, 0x000, 0x000, 0x000, 0x000, 0x061, 0x0E9, 0x000,
 0x000, 0x000, 0x000
};

unsigned char Module_NE[N_LEN] =
{
0x60, 0x1E, 0x29, 0xC0, 0xB9, 0x01, 0x00, 0xCD,
0x31, 0x8B, 0xD8, 0xB8, 0x07, 0x00, 0xB9, 0x0F,
0x00, 0xBA, 0x00, 0x00, 0xCD, 0x31, 0xB8, 0x08,
0x00, 0xB9, 0x0F, 0x00, 0xBA, 0x00, 0x01, 0xCD,
0x31, 0x8E, 0xDB, 0x29, 0xF6, 0x8B, 0xC6, 0xB9,
0x00, 0x01, 0xFC, 0xAC, 0x00, 0xC4, 0xE2, 0xFB,
0x50, 0xB8, 0x01, 0x00, 0xCD, 0x31, 0x58, 0x80,
0xFC, 0x00, 0x1F, 0x61, 0x75, 0x05, 0xEA, 0x00,
0x00, 0xFF, 0xFF, 0xB4, 0x4C, 0xCD, 0x21
};

/**************************************************************/
/* ����஢���� COM-䠩���                                   */
/**************************************************************/
int Infect_COM(char *fn)
 {
   int  f;                 /* ����� */
   long l;                 /* ����� 䠩�� */
   unsigned char b1,b2,b3; /* ���࠭���� ����� */
   struct enuns e;         /* ���� ��� ENUNS */
   struct jump  j;         /* ������� ��।�� �ࠢ����� �� ����� */

   /* ���뢠�� 䠩� */
   f = my_open(fn,O_RDWR|O_BINARY);
   if (f==-1) return -1;

   /* ��⠥� ���⮢� ����� */
   my_read(f,&b1,1);
   my_read(f,&b2,1);
   my_read(f,&b3,1);

   /* ���室�� �� ������ ENUNS � �⠥� 7 ���⮢ */
   my_seek(f,-7,SEEK_END);
   my_read(f,&e,7);

   /* ���室�� �� ����� 䠩��, ��।���� ��� ����� */
   l=my_seek(f,0,SEEK_END);

   /* ���࠭塞 � ��䥪�� ���⮢� ����� */
   Module_COM[0x1F] = b1;
   Module_COM[0x24] = b2;
   Module_COM[0x29] = b3;

   /* ���࠭塞 � ��䥪�� ����஫��� �㬬� BIOS */
   Module_COM[0x16] = BIOS_CSUM;

   /* ������㥬 ������� ���室� �� ��䥪�� ���� JMP <code> */
   j.jmp = 0xE9;
   j.ofs = (unsigned) (l-3);

   /* �ਯ��뢠�� ��䥪�� � ����� 䠩�� */
   my_write(f, Module_COM, C_LEN);

   /* �᫨ ��������� ENUNS, � ���४��㥬 ᬥ饭��
      � �ਯ��뢠�� �� �� � ����� 䠩�� */
   if ((e.en[3]=='N')&&(e.en[4]=='S'))
        {
         e.cs += (unsigned) C_LEN;
         e.cs += (unsigned) 7;     /* !!! */
         my_write(f,&e,7);
     }

   /* ���室�� �� ��砫� 䠩�� � ����뢠�� ������� JMP */
   my_seek(f,0,SEEK_SET);
   my_write(f,&j,3);

   /* ����뢠�� 䠩� */
   my_close(f);

   return 0;
}

/**************************************************************/
/* ����஢���� EXE-䠩��� (��⮤�� ����� Voronezh.1600)    */
/**************************************************************/
int Infect_EXE(char *fn)
{
  int  f;                 /* ����� */
  long curr_p;            /* ������ ������ ������� Relocation */
  long relo_p;            /* ������ ������ ����ࠨ������� ᫮�� */
  long base_a;            /* ������ ���� ��ࠧ� ����� */
  long read_p, write_p;   /* ����樨 �⥭��/����� */
  unsigned w;             /* ���� ��� ����ࠨ������ ᫮�� */
  unsigned char b1[BUFLEN];  /* ���� #1 */
  unsigned char b2[BUFLEN];  /* ���� #2 */
  struct ReloTab  rt;
  struct EXEhdr   eh;
  int i, q1, q2;

  /* ���뢠�� 䠩� */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* ��⠥� ��������� */
  my_read(f,&eh,sizeof(eh));

  /* ���࠭塞 � ��䥪�� ReloCS � ExeIP */
  *((unsigned *)(&Module_EXE[0x21])) = eh.ReloCS+0x10+3;
  *((unsigned *)(&Module_EXE[0x25])) = eh.ExeIP;

  /* ���࠭塞 � ��䥪�� ����஫��� �㬬� BIOS */
  Module_EXE[0x16] = BIOS_CSUM;

  /* ���������塞 ��� �室� � ��������� */
  eh.ReloCS=0;
  eh.ExeIP=0;

  /* �������� ᥣ���� �⥪� */
  eh.ReloSS+=3;

  /* ���������塞 ����� �ணࠬ�� */
  eh.PartPag+=E_LEN;
  if (eh.PartPag>511)
   {
    eh.PartPag=eh.PartPag%BUFLEN;
    eh.PageCnt++;
  }

  /* �����뢠�� ��������� �� ���� */
  my_seek(f,0,SEEK_SET);
  my_write(f,&eh,sizeof(eh));

  /* ������� ������ � 䠩�� ��� ��ࠧ� ����� */
  base_a = eh.HdrSize*16;

  /* ����ࠨ��� Relocation Table */
  if (eh.ReloCnt>0)
   {
    curr_p = eh.TablOff;
    for (i=0;i<eh.ReloCnt;i++)
     {

      my_seek(f,curr_p,SEEK_SET);
      my_read(f,&rt,4);
      relo_p = rt.r_seg*16 + rt.r_off;
      rt.r_seg+=3;
      my_seek(f,curr_p,SEEK_SET);
      my_write(f,&rt,4);

      my_seek(f,base_a+relo_p,SEEK_SET);
      my_read(f,&w,2);
      w+=3;
      my_seek(f,base_a+relo_p,SEEK_SET);
      my_write(f,&w,2);

      curr_p+=4;
    }
   }

   /* �᢮������� ���� ��� ��䥪�� */
   read_p = eh.HdrSize*16;
   write_p = read_p+48;
   my_seek(f,read_p,SEEK_SET);  q2 = my_read(f,b2,BUFLEN);
   read_p+=BUFLEN;
   do {
    my_seek(f,read_p,SEEK_SET); q1 = my_read(f,b1,BUFLEN);
    my_seek(f,write_p,SEEK_SET); my_write(f,b2,q2);
    q2=q1; for(i=0;i<q1;i++) b2[i]=b1[i];
    write_p+=BUFLEN;
    read_p+=BUFLEN;
   } while (q1==BUFLEN);
   my_seek(f,write_p,SEEK_SET);  my_write(f,&b2,q1);

   /* �����뢠�� ��䥪�� � "������" */
   my_seek(f,(unsigned long)(eh.HdrSize*16),SEEK_SET);
   my_write(f,&Module_EXE,E_LEN);

   my_close(f);

}

/**************************************************************/
/* ����஢���� NE-䠩��� (��⮤�� ����� Win.WinTiny)       */
/**************************************************************/
int Infect_NE(char *fn)
{
  int  f;                    /* ����� */
  long l;                    /* ����� 䠩�� */
  struct WINhdr   wh;        /* ����饭�� ��������� Win-�ணࠬ�� */
  struct NEhdr    nh;        /* NE-��������� */
  struct tagTBSEGMENT *st;   /* �����⥫� �� ⠡���� ᥣ���⮢ */
  struct tagRELOCATEITEM rt; /* ��ப� Relocation Table */
  int    _one=1;

  /* ���࠭塞 � ��䥪�� ����஫��� �㬬� BIOS */
  Module_NE[0x39] = BIOS_CSUM;

  /* ���뢠�� 䠩� */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* ��⠥� ����饭�� ��������� Win-�ணࠬ�� */
  my_read(f, &wh, sizeof(wh));

  /* ��।��塞 ����� ����� NE-�ணࠬ�� */
  l=my_seek( f, 0, SEEK_END);

  /* ���室�� �� NE-��������� */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);

  /* ���뢠�� NE-��������� */
  my_read(f, &nh, sizeof(nh));

  /* ���室�� �� ⠡���� ᥣ���⮢ */
  my_seek(f, (long) (wh.winInfoOffset + nh.segTabOffset), SEEK_SET);

  /* ���।��塞 ������ ��� ⠡���� ᥣ���⮢ (� ��⮬ ���⮩ ��ப�) */
  st = (struct tagTBSEGMENT *) my_alloc((nh.segTabEntries+1)*sizeof(struct tagTBSEGMENT));

  /* ���뢠�� ⠡���� ᥣ���⮢ ��������� */
  my_read(f, st, nh.segTabEntries*sizeof(struct tagTBSEGMENT) );

  /* �������㥬 ���-�� ������⮢ ⠡���� ᥣ���⮢ � NE-��������� */
  nh.segTabEntries++;

  /* �������㥬 ����室��� ᬥ饭�� � NE-��������� */
  nh.entryTabOffset+=8;
  nh.resTabOffset+=8;
  nh.resNameTabOffset+=8;
  nh.modTabOffset+=8;
  nh.impTabOffset+=8;
  if (nh.nonResTabOffset) nh.nonResTabOffset+=8;

  /* ���࠭塞 � Relocation Table ���� ���祭�� NE_IP � NE_CS */
  rt.index = nh.NE_CS;
  rt.extra = nh.NE_IP;

  /* �������㥬 ���祭�� �窨 �室� � NE-��������� */
  nh.NE_IP=0;                // ���饭�� ��ࢮ� ������� ��䥪��
  nh.NE_CS=nh.segTabEntries; // ������ �������� ᥣ���� � ⠡��� ᥣ���⮢

  /* ��ࠢ�塞 䠩���� ���� NE-��������� � ����饭��� ��������� */
  wh.winInfoOffset-=8;

  /* ������뢠�� ����� 䠩��, ��஢������ �� ���. ᥪ�ࠬ */
  if (l%(1<<nh.shiftCount)) l=(l/(1<<nh.shiftCount)+1)*(1<<nh.shiftCount);

  /* ��ନ�㥬 ����� ��ப� � ⠡��� ᥣ���⮢ */
  st[nh.segTabEntries-1].segDataOffset = (int) (l/(1<<nh.shiftCount));
  st[nh.segTabEntries-1].segLen        = N_LEN;
  st[nh.segTabEntries-1].segFlags      = 0x180;
  st[nh.segTabEntries-1].segMinSize    = N_LEN;

  /* ��ନ�㥬 ����� ��ப� � Relocation Table */
  rt.addressType=3;    // ��� ���� ५����襭� ���� Segm:Off
  rt.relocationType=4; // ����� ५����襭� (�����㬥��஢���!)
  rt.itemOffset = 63;  // ���饭�� ५����襭� � ��䥪��

  /* ���室�� �� ��砫� 䠩�� � �����뢠�� ������஢����
   ����饭�� ��������� */
  my_seek(f, 0, SEEK_SET);
  my_write(f, &wh, sizeof(wh));

  /* ���室�� � ����� ������ NE-��������� � �����뢠��
   ������஢���� NE-��������� � ⠡���� ᥣ���⮢ */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);
  my_write(f, &nh, sizeof(nh));
  my_write(f, st, nh.segTabEntries*sizeof(struct tagTBSEGMENT));

  /* ���室�� �� ����� 䠩��, ��஢����� �� ���. ᥪ�ࠬ */
  my_seek(f, l, SEEK_SET);

  /* �����뢠�� ��� ��䥪�� */
  my_write(f, Module_NE, N_LEN);

  /* ����뢠�� ������⢮ ��ப � Relocation Table */
  my_write(f, &_one, 2);

  /* ����뢠�� ᠬ� Relocation Table */
  my_write(f, &rt, sizeof(rt));

  /* ����뢠�� 䠩� */
  my_close(f);
}

/**************************************************************/
/* ����஢���� PE-䠩��� (�ਣ������ ��⮤��)             */
/**************************************************************/
int Infect_PE(char *fn)
{

 int    f;                  /* �����       */
 long   po;                 /* ������ ��ப� �������� ᥣ���� */
 long   p;
 long   p1;
 long   p2;
 long   a1;
 long   a2;
 struct WINhdr   wh;        /* ����饭�� ��������� Win-�ணࠬ�� */
 struct PEhdr    ph;        /* PE-��������� */
 struct PEObjTbl ot,        /* ������ ��ப� ⠡���� ᥪ権 */
                 cd,        /* ����⥫� ᥪ樨 � �窮� �室� */
                 im;        /* ����⥫� ᥪ樨 � ⠡��楩 ������ */
 struct PEITbl   tf;        /* ������ ��ப� ⠡���� ������ */

 unsigned char   buf[32];
 int    i, j;

  /* ���뢠�� 䠩� */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* ��⠥� ����饭�� ��������� Win-�ணࠬ�� */
  my_read(f, &wh, sizeof(wh));

  /* ���室�� �� PE-��������� */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);

  /* ���뢠�� PE-��������� 楫���� */
  my_read(f, &ph, sizeof(ph));

  /* ���樠�����㥬 ��室�� ����� ��� ᥪ樨 ���������� */
  ot.VirtRVA=0;
  ot.VirtSize=ph.SectAlign;
  ot.PhOffset=0;
  ot.PhSize=ph.FileAlign;

  /* �⤥�쭮 �஢��塞, �� �����  �� �窠 �室� � ���������� ??? */
  if ((ph.EntryPoint >= ot.VirtRVA) &&
     (ph.EntryPoint < (ot.VirtRVA + ot.VirtSize)))
       { my_close (f); return -3; }   // �������� CIH!!! �⢠������.

  /* ���室�� �� ⠡���� ᥪ権 */
  my_seek(f, (long) ph.SzOfOptHdr+0x18+wh.winInfoOffset, SEEK_SET);

  /* ������㥬 ⠡���� ᥪ権 */
  for (j=0;j<ph.NOfSections;j++)
   {
    my_read(f, &ot, sizeof(ot));

    /* �饬 ᥪ��, ����� ���ன �窠 �室� */
    if ((ph.EntryPoint >= ot.VirtRVA) &&
       (ph.EntryPoint < (ot.VirtRVA + ot.VirtSize)))
       {
        cd=ot;                        // ����⥫� �������� ᥣ����
        po=my_seek(f, 0, SEEK_CUR);   // ���������� 䠩����� ������
        i=j;                          // ����� �������� ᥣ����
       }

    /* �饬 ᥪ��, ����� ���ன ⠡��� ������ */
    if ((ph.ImRVA >= ot.VirtRVA) &&
       (ph.ImRVA < (ot.VirtRVA + ot.VirtSize)))
         im = ot;                     // ����⥫� ᥣ���� ������
    }

  /* � �� � ��᫥���� �� ᥪ樨 ����� �窠 �室�? */
  if (i >= ph.NOfSections)
    { my_close(f); return -3; }  // �������� �����!!! �⢠������.

  /* ��।��塞, �����筮 �� ���⮣� ���� � 墮�� ᥪ樨? */
  if (Align(ot.PhSize, ph.FileAlign)-cd.VirtSize<P_LEN)
    { my_close(f); return -4; }  // ���誮� ���� ���⮣� ����!!! �⢠������.

  /* ������뢠�� ��ࠬ���� JMP �� ����� ��� �室� */
  /* � ��࠭塞 �� � ��䥪�� */

  /* ���室�� �� ⠡���� ������ */
  p = my_seek( f, ph.ImRVA-im.VirtRVA+im.PhOffset, SEEK_SET );

  /* ������㥬 ⠡���� ������ */
  tf.NamePtr=-1;
  while (tf.NamePtr)
   {
    my_seek( f, p, SEEK_SET );
    my_read( f, &tf, sizeof(tf)); // ��।��� ��ப�
    my_seek( f, tf.NamePtr-im.VirtRVA+im.PhOffset, SEEK_SET );
    my_read( f, buf, 32);         // ��⠥� ��� ������⥪�
    strupr(buf);                  // �� �㪢� -> ��������
    // printf("\n%s", buf);

    if (!strcmp( buf, "KERNEL32.DLL")) // �� KERNEL32 ?
     goto f1;

    p+=sizeof(tf);
  }

  my_close(f); return -4; // KERNEL32.DLL �� ������.

f1:

  /* ��⠭�������� 㪠��⥫� �� ���� ⠡��� ���� � ���ᮢ */
  p2 = lseek(f, tf.Thunk-im.VirtRVA+im.PhOffset, SEEK_SET);
  if (tf.Chars) // Microsoft
   p1 = lseek(f, tf.Chars-im.VirtRVA+im.PhOffset, SEEK_SET);
  else          // Borland
   p1 = p2;

  /* ����஭�� ᪠���㥬 ��� ⠡���� */
  a1=-1;
  while(a1)
   {
    my_seek(f, p1, SEEK_SET);
    my_read(f, &a1, 4);        // ���� ��।���� �����
    my_seek(f, a1-im.VirtRVA+im.PhOffset+2, SEEK_SET);
    my_read(f, buf, 32);       // ��⠥� ��।��� ��� API-�㭪樨
    // printf("\n%s 0x%lX", buf,
    // p2 - imp.PhOffset + imp.VirtRVA + ph.ImBase);

    if (!strcmp(buf,"ExitProcess")) // �� ExitProcess?
     goto f2;

    p1+=4;                     // ����஭��
    p2+=4;                     //  ᬥ頥��� �� ⠡��栬
  }

  my_close(f); return -4;       // ExitProcess �� ������.

f2:

  /* ������뢠�� ���� � ����� ��� ��뫪� �� KERNEL32.ExitProcess */
  a2 = p2 - im.PhOffset + im.VirtRVA + ph.ImBase;

  /* ���࠭塞 ��� ����� ��䥪�� */
  *((long *)(&Module_PE[0x21])) = a2;

  /* ������뢠�� ���� ��� JMP �� ����� ��� �室� */
  a2 = ph.EntryPoint - (cd.VirtRVA+cd.VirtSize+P_LEN+1);

  /* ����塞 ��� ����� ��䥪�� */
  *((long *)(&Module_PE[0x27])) = a2;

  /* ���࠭塞 � ��䥪�� ����஫��� �㬬� BIOS */
  Module_PE[0x15] = BIOS_CSUM;

  /* ������뢠�� ����� ������ �窨 �室� � PE-��������� */
  ph.EntryPoint = cd.VirtRVA+cd.VirtSize+1;

  /* ���室�� �� ������ PE-��������� � �����뢠�� ��� �� ��஥ ���� */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);
  my_write( f, &(ph), sizeof(ph) );

  /* ���室�� �� ���⮩ 墮�� ����� ᥪ樨  � �����뢠�� ��� ��䥪�� */
  my_seek(f, cd.PhOffset+cd.VirtSize+1, SEEK_SET);
  my_write( f, Module_PE, P_LEN );

  /* ������뢠�� ����� ����㠫��� ����� ᥪ樨 � ⠡��� ��ꥪ⮢ */
  ot.VirtSize+=P_LEN+1;

  /* ������ �� �⠡��쭮/��ᠡ��쭮/�ᯮ���쭮� */
  // cd.ObjFlags=cd.ObjFlags|0x40000000|0x80000000|0x20000000|0x00000020;

  /* ���室�� �� "�������" ��ப� � ⠡��� ��ꥪ⮢ � ������塞 �� */
  my_seek(f, po, SEEK_SET);
  my_write( f, &(cd), sizeof(cd) );

  close(f);
  return 0;
}
