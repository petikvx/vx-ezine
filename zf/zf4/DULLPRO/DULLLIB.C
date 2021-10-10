/*******************************************************************/
/* DULLLIB - библиотека процедур для демонстрационного гененратора */
/* навесных защит от НСК для COM/EXE/NE/PE программ.               */
/* (c) Климентьев К., Самара 2001                                  */
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
/* Инфицирование COM-файлов                                   */
/**************************************************************/
int Infect_COM(char *fn)
 {
   int  f;                 /* Хэндл */
   long l;                 /* Длина файла */
   unsigned char b1,b2,b3; /* Сохраненные байты */
   struct enuns e;         /* Буфер под ENUNS */
   struct jump  j;         /* Команда передачи управления на модуль */

   /* Открываем файл */
   f = my_open(fn,O_RDWR|O_BINARY);
   if (f==-1) return -1;

   /* Читаем стартовые байты */
   my_read(f,&b1,1);
   my_read(f,&b2,1);
   my_read(f,&b3,1);

   /* Переходим на позицию ENUNS и читаем 7 байтов */
   my_seek(f,-7,SEEK_END);
   my_read(f,&e,7);

   /* Переходим на конец файла, определяя его длину */
   l=my_seek(f,0,SEEK_END);

   /* Сохраняем в инфекторе стартовые байты */
   Module_COM[0x1F] = b1;
   Module_COM[0x24] = b2;
   Module_COM[0x29] = b3;

   /* Сохраняем в инфекторе контрольную сумму BIOS */
   Module_COM[0x16] = BIOS_CSUM;

   /* Генерируем команду перехода на инфектор вида JMP <code> */
   j.jmp = 0xE9;
   j.ofs = (unsigned) (l-3);

   /* Приписываем инфектор к концу файла */
   my_write(f, Module_COM, C_LEN);

   /* Если присутствует ENUNS, то корректируем смещение
      и приписываем все это к концу файла */
   if ((e.en[3]=='N')&&(e.en[4]=='S'))
        {
         e.cs += (unsigned) C_LEN;
         e.cs += (unsigned) 7;     /* !!! */
         my_write(f,&e,7);
     }

   /* Переходим на начало файла и вписываем команду JMP */
   my_seek(f,0,SEEK_SET);
   my_write(f,&j,3);

   /* Закрываем файл */
   my_close(f);

   return 0;
}

/**************************************************************/
/* Инфицирование EXE-файлов (методом вируса Voronezh.1600)    */
/**************************************************************/
int Infect_EXE(char *fn)
{
  int  f;                 /* Хэндл */
  long curr_p;            /* Текущая позиция элемента Relocation */
  long relo_p;            /* Текущая позиция настраиваемого слова */
  long base_a;            /* Базовый адрес образа задачи */
  long read_p, write_p;   /* Позиции чтения/записи */
  unsigned w;             /* Буфер под настраиваемое слово */
  unsigned char b1[BUFLEN];  /* Буфер #1 */
  unsigned char b2[BUFLEN];  /* Буфер #2 */
  struct ReloTab  rt;
  struct EXEhdr   eh;
  int i, q1, q2;

  /* Открываем файл */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* Читаем заголовок */
  my_read(f,&eh,sizeof(eh));

  /* Сохраняем в инфекторе ReloCS и ExeIP */
  *((unsigned *)(&Module_EXE[0x21])) = eh.ReloCS+0x10+3;
  *((unsigned *)(&Module_EXE[0x25])) = eh.ExeIP;

  /* Сохраняем в инфекторе контрольную сумму BIOS */
  Module_EXE[0x16] = BIOS_CSUM;

  /* Видоизменяем точку входа в заголовке */
  eh.ReloCS=0;
  eh.ExeIP=0;

  /* Сдвигаем сегмент стека */
  eh.ReloSS+=3;

  /* Видоизменяем длину программы */
  eh.PartPag+=E_LEN;
  if (eh.PartPag>511)
   {
    eh.PartPag=eh.PartPag%BUFLEN;
    eh.PageCnt++;
  }

  /* Записываем заголовок на место */
  my_seek(f,0,SEEK_SET);
  my_write(f,&eh,sizeof(eh));

  /* Базовая позиция в файле для образа задачи */
  base_a = eh.HdrSize*16;

  /* Настраиаем Relocation Table */
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

   /* Освобождаем место для инфектора */
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

   /* Записываем инфектор в "каверну" */
   my_seek(f,(unsigned long)(eh.HdrSize*16),SEEK_SET);
   my_write(f,&Module_EXE,E_LEN);

   my_close(f);

}

/**************************************************************/
/* Инфицирование NE-файлов (методом вируса Win.WinTiny)       */
/**************************************************************/
int Infect_NE(char *fn)
{
  int  f;                    /* Хэндл */
  long l;                    /* Длина файла */
  struct WINhdr   wh;        /* Обобщенный заголовок Win-программы */
  struct NEhdr    nh;        /* NE-заголовок */
  struct tagTBSEGMENT *st;   /* Указатель на таблицу сегментов */
  struct tagRELOCATEITEM rt; /* Строка Relocation Table */
  int    _one=1;

  /* Сохраняем в инфекторе контрольную сумму BIOS */
  Module_NE[0x39] = BIOS_CSUM;

  /* Открываем файл */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* Читаем обобщенный заголовок Win-программы */
  my_read(f, &wh, sizeof(wh));

  /* Определяем старую длину NE-программы */
  l=my_seek( f, 0, SEEK_END);

  /* Переходим на NE-заголовок */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);

  /* Считываем NE-заголовок */
  my_read(f, &nh, sizeof(nh));

  /* Переходим на таблицу сегментов */
  my_seek(f, (long) (wh.winInfoOffset + nh.segTabOffset), SEEK_SET);

  /* Распределяем память под таблицу сегментов (с учетом пустой строки) */
  st = (struct tagTBSEGMENT *) my_alloc((nh.segTabEntries+1)*sizeof(struct tagTBSEGMENT));

  /* Считываем таблицу сегментов полностью */
  my_read(f, st, nh.segTabEntries*sizeof(struct tagTBSEGMENT) );

  /* Модифицируем кол-во элементов таблицы сегментов в NE-заголовке */
  nh.segTabEntries++;

  /* Модифицируем необходимые смещения в NE-заголовке */
  nh.entryTabOffset+=8;
  nh.resTabOffset+=8;
  nh.resNameTabOffset+=8;
  nh.modTabOffset+=8;
  nh.impTabOffset+=8;
  if (nh.nonResTabOffset) nh.nonResTabOffset+=8;

  /* Сохраняем в Relocation Table старые значения NE_IP и NE_CS */
  rt.index = nh.NE_CS;
  rt.extra = nh.NE_IP;

  /* Модифицируем значения точки входа в NE-заголовке */
  nh.NE_IP=0;                // Смещение первой команды инфектора
  nh.NE_CS=nh.segTabEntries; // Индекс кодового сегмента в таблице сегментов

  /* Исправляем файловый адрес NE-заголовка в обобщенном заголовке */
  wh.winInfoOffset-=8;

  /* Рассчитываем длину файла, выровненную по лог. секторам */
  if (l%(1<<nh.shiftCount)) l=(l/(1<<nh.shiftCount)+1)*(1<<nh.shiftCount);

  /* Сформируем новую строку в таблице сегментов */
  st[nh.segTabEntries-1].segDataOffset = (int) (l/(1<<nh.shiftCount));
  st[nh.segTabEntries-1].segLen        = N_LEN;
  st[nh.segTabEntries-1].segFlags      = 0x180;
  st[nh.segTabEntries-1].segMinSize    = N_LEN;

  /* Сформируем новую строку в Relocation Table */
  rt.addressType=3;    // Тип адреса релокейшена есть Segm:Off
  rt.relocationType=4; // Флаги релокейшена (недокументировано!)
  rt.itemOffset = 63;  // Смещение релокейшена в инфекторе

  /* Переходим на начало файла и записываем модифицированный
   обобщенный заголовок */
  my_seek(f, 0, SEEK_SET);
  my_write(f, &wh, sizeof(wh));

  /* Переходим в новую позицию NE-заголовка и записываем
   модифицированные NE-заголовок и таблицу сегментов */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);
  my_write(f, &nh, sizeof(nh));
  my_write(f, st, nh.segTabEntries*sizeof(struct tagTBSEGMENT));

  /* Переходим на конец файла, выровненный по лог. секторам */
  my_seek(f, l, SEEK_SET);

  /* Записываем код инфектора */
  my_write(f, Module_NE, N_LEN);

  /* Вписываем количество строк в Relocation Table */
  my_write(f, &_one, 2);

  /* Вписываем саму Relocation Table */
  my_write(f, &rt, sizeof(rt));

  /* Закрываем файл */
  my_close(f);
}

/**************************************************************/
/* Инфицирование PE-файлов (оригинальным методом)             */
/**************************************************************/
int Infect_PE(char *fn)
{

 int    f;                  /* Хэндл       */
 long   po;                 /* Позиция строки кодового сегмента */
 long   p;
 long   p1;
 long   p2;
 long   a1;
 long   a2;
 struct WINhdr   wh;        /* Обобщенный заголовок Win-программы */
 struct PEhdr    ph;        /* PE-заголовок */
 struct PEObjTbl ot,        /* Текущая строка таблицы секций */
                 cd,        /* Описатель секции с точкой входа */
                 im;        /* Описатель секции с таблицей импорта */
 struct PEITbl   tf;        /* Текущая строка таблицы импорта */

 unsigned char   buf[32];
 int    i, j;

  /* Открываем файл */
  f = my_open(fn,O_RDWR|O_BINARY);
  if (f==-1) return -1;

  /* Читаем обобщенный заголовок Win-программы */
  my_read(f, &wh, sizeof(wh));

  /* Переходим на PE-заголовок */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);

  /* Считываем PE-заголовок целиком */
  my_read(f, &ph, sizeof(ph));

  /* Инициализируем исходные данные для секции заголовков */
  ot.VirtRVA=0;
  ot.VirtSize=ph.SectAlign;
  ot.PhOffset=0;
  ot.PhSize=ph.FileAlign;

  /* Отдельно проверяем, не лежит  ли точка входа в заголовках ??? */
  if ((ph.EntryPoint >= ot.VirtRVA) &&
     (ph.EntryPoint < (ot.VirtRVA + ot.VirtSize)))
       { my_close (f); return -3; }   // Возможен CIH!!! Отваливаем.

  /* Переходим на таблицу секций */
  my_seek(f, (long) ph.SzOfOptHdr+0x18+wh.winInfoOffset, SEEK_SET);

  /* Сканируем таблицу секций */
  for (j=0;j<ph.NOfSections;j++)
   {
    my_read(f, &ot, sizeof(ot));

    /* Ищем секцию, внутри которой точка входа */
    if ((ph.EntryPoint >= ot.VirtRVA) &&
       (ph.EntryPoint < (ot.VirtRVA + ot.VirtSize)))
       {
        cd=ot;                        // Описатель кодового сегмента
        po=my_seek(f, 0, SEEK_CUR);   // Запоминаем файловую позицию
        i=j;                          // Номер кодового сегмента
       }

    /* Ищем секцию, внутри которой таблица импорта */
    if ((ph.ImRVA >= ot.VirtRVA) &&
       (ph.ImRVA < (ot.VirtRVA + ot.VirtSize)))
         im = ot;                     // Описатель сегмента импорта
    }

  /* А не в последней ли секции лежит точка входа? */
  if (i >= ph.NOfSections)
    { my_close(f); return -3; }  // Возможен вирус!!! Отваливаем.

  /* Определяем, достаточно ли пустого места в хвосте секции? */
  if (Align(ot.PhSize, ph.FileAlign)-cd.VirtSize<P_LEN)
    { my_close(f); return -4; }  // Слишком мало пустого места!!! Отваливаем.

  /* Рассчитываем параметры JMP на старую точку входа */
  /* И сохраняем их в инфекторе */

  /* Переходим на таблицу импорта */
  p = my_seek( f, ph.ImRVA-im.VirtRVA+im.PhOffset, SEEK_SET );

  /* Сканируем таблицу импорта */
  tf.NamePtr=-1;
  while (tf.NamePtr)
   {
    my_seek( f, p, SEEK_SET );
    my_read( f, &tf, sizeof(tf)); // Очередная строка
    my_seek( f, tf.NamePtr-im.VirtRVA+im.PhOffset, SEEK_SET );
    my_read( f, buf, 32);         // Читаем имя библиотеки
    strupr(buf);                  // Все буквы -> заглавные
    // printf("\n%s", buf);

    if (!strcmp( buf, "KERNEL32.DLL")) // Это KERNEL32 ?
     goto f1;

    p+=sizeof(tf);
  }

  my_close(f); return -4; // KERNEL32.DLL не найден.

f1:

  /* Устанавливаем указатели на адреса таблиц имен и адресов */
  p2 = lseek(f, tf.Thunk-im.VirtRVA+im.PhOffset, SEEK_SET);
  if (tf.Chars) // Microsoft
   p1 = lseek(f, tf.Chars-im.VirtRVA+im.PhOffset, SEEK_SET);
  else          // Borland
   p1 = p2;

  /* Синхронно сканируем обе таблицы */
  a1=-1;
  while(a1)
   {
    my_seek(f, p1, SEEK_SET);
    my_read(f, &a1, 4);        // Адрес очередного имени
    my_seek(f, a1-im.VirtRVA+im.PhOffset+2, SEEK_SET);
    my_read(f, buf, 32);       // Читаем очередное имя API-функции
    // printf("\n%s 0x%lX", buf,
    // p2 - imp.PhOffset + imp.VirtRVA + ph.ImBase);

    if (!strcmp(buf,"ExitProcess")) // Это ExitProcess?
     goto f2;

    p1+=4;                     // Синхронно
    p2+=4;                     //  смещаемся по таблицам
  }

  my_close(f); return -4;       // ExitProcess не найден.

f2:

  /* Рассчитываем адрес в памяти для ссылки на KERNEL32.ExitProcess */
  a2 = p2 - im.PhOffset + im.VirtRVA + ph.ImBase;

  /* Сохраняем его внутри инфектора */
  *((long *)(&Module_PE[0x21])) = a2;

  /* Рассчитываем адрес для JMP на старую точку входа */
  a2 = ph.EntryPoint - (cd.VirtRVA+cd.VirtSize+P_LEN+1);

  /* Сохрняем его внутри инфектора */
  *((long *)(&Module_PE[0x27])) = a2;

  /* Сохраняем в инфекторе контрольную сумму BIOS */
  Module_PE[0x15] = BIOS_CSUM;

  /* Рассчитываем новую позицию точки входа в PE-заголовке */
  ph.EntryPoint = cd.VirtRVA+cd.VirtSize+1;

  /* Переходим на позицию PE-заголовка и записываем его на старое место */
  my_seek(f, (long) wh.winInfoOffset, SEEK_SET);
  my_write( f, &(ph), sizeof(ph) );

  /* Переходим на пустой хвост внутри секции  и записываем код инфектора */
  my_seek(f, cd.PhOffset+cd.VirtSize+1, SEEK_SET);
  my_write( f, Module_PE, P_LEN );

  /* Рассчитываем новую виртуальную длину секции в таблице объектов */
  ot.VirtSize+=P_LEN+1;

  /* Делаем ее читабельно/писабельно/исполнябельной */
  // cd.ObjFlags=cd.ObjFlags|0x40000000|0x80000000|0x20000000|0x00000020;

  /* Переходим на "кодовую" строку в таблице объектов и обновляем ее */
  my_seek(f, po, SEEK_SET);
  my_write( f, &(cd), sizeof(cd) );

  close(f);
  return 0;
}
