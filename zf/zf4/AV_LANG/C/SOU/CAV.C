/*********************************************************************/
/*         Простейший антивирус на Borland или TopSpeed C            */
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
 path    [PATH_LEN],  /* Строка имени текущего подкаталога           */
 old_path[PATH_LEN],  /* Строка имени начального местоположения      */
 drive   [DRIVE_LEN], /* Строка имени требуемого устройства          */
 blank   [BLANK_LEN]; /* Пустая строка                               */
int
 n_dir,               /* Количество отсканированных каталогов        */
 n_fil,               /* Количество исследованных файлов             */
 n_ill,               /* Количество больных и исцеленных файлов      */
 l,                   /* Длина имени файла                           */
 i;                   /* Временный индекс                            */

/*********************************************************************/
/*         Процедура проверки зараженности вирусом 460               */
/*********************************************************************/
int infected1( char *fn )
 {

  int f, q, r;
  long p;
  unsigned char sigbuf[8];

  f = open( fn, O_BINARY|O_RDWR);
  q = read( f , sigbuf, 3);
  if (sigbuf[0]==0xE9)           // Первая команда JMP ?
   {
    p = lseek( f, (long)(*((unsigned *)(&sigbuf[1])))+3, SEEK_SET);
    q = read(f, sigbuf, 8);
    if((sigbuf[0]==0x1E)&&       // Проверка сигнатуры
       (sigbuf[1]==0x8C)&&
       (sigbuf[2]==0xD8)&&
       (sigbuf[3]==0x05)&&
       (sigbuf[6]==0x8E)&&
       (sigbuf[7]==0xD8))
        { n_ill++; r=BAD; printf(" - болен 460 и исцелен!\n"); }
     else r=GOOD;
  }
  else r=GOOD;
  close(f);
  return r;
}

/**********************************************************************/
/*       Процедура лечения от вируса 460                              */
/**********************************************************************/
cure1( char *fn )
 {
  int  f, q, i;
  long l, p;
  unsigned char buf[3], par[16];

  f = open ( fn, O_BINARY|O_RDWR );
  l = lseek( f, 0, SEEK_END );          // Длина файла
  p = lseek( f, l-0x9B, SEEK_SET);      // На "заначку"
  q = read ( f, buf, 3);                // Спрятанные байты
  p = lseek( f, 0, SEEK_SET );          // На начало
  q = write( f, buf, 3);                // Возвращаем на место
  p = lseek( f, l-0x1C4-16, SEEK_SET);  // На начало вируса "с запасом"
  q = read ( f, par, 16);               // Читаем конец проги и начало виря
  i=15; while ((!par[i])&&(i)) i--;     // Ищем границу
  p = lseek( f, l-0x1C4-15+i, SEEK_SET);// Истинный конец проги
  q = _write( f, par, 0);               // Отрубаем хвост
  close(f);
}

/**********************************************************************/
/*       Процедура проверки зараженности вирусом 112                  */
/**********************************************************************/
int infected2( char *fn )
 {
  int f, q, r;
  long p;
  unsigned char sigbuf[8];

  f = open( fn, O_BINARY|O_RDWR);
  q = read(f, sigbuf, 8);
  if((sigbuf[0]==0x8C)&&       // Проверка сигнатуры
     (sigbuf[1]==0xCA)&&
     (sigbuf[2]==0xFE)&&
     (sigbuf[3]==0xC6)&&
     (sigbuf[4]==0x8E)&&
     (sigbuf[5]==0xC2))
      { n_ill++; r=BAD; printf(" - болен 112 и исцелен!\n"); }
  else r=GOOD;
  close(f);
  return r;
}

/**********************************************************************/
/*       Процедура лечения от вируса 112                              */
/**********************************************************************/
cure2( char *fn)
 {
  int  f, q, p, i;
  long l, _r, _w;
  unsigned char buf[112];

  f = open ( fn, O_BINARY|O_RDWR );
  _r = 112;                         // Позиция чтения
  _w = 0;                           // Позиция записи
  q = 112;
  while (q==112)
  {
   lseek( f, _r, SEEK_SET );
   q  = read ( f, buf, 112);
   lseek( f, _w, SEEK_SET );
   write( f, buf, q);                // Пишем сколько прочитали !
   _r+=112;                          // Инкрементируем позицию чтения
   _w+=112;                          // Инкрементируем позицию записи
  }
  _write( f, buf, 0);                // Отсекаем хвост
  close(f);
}

/**********************************************************************/
/* Рекурсивная процедура обхода дерева каталогов "методом переходов": */
/* - проверяемый каталог всегда текущий;                              */
/* - маска поиска всегда "*.*".                                       */
/**********************************************************************/
walk()
 {
  int found_d, found_f;
  struct find_t buf;

  /* Поиск каталогов */
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

  /* К этому моменту неотсканированных нижележащих каталогов
  больще не осталось - сканируем файлы */

  n_dir++;
  getcwd( path, PATH_LEN );

  /* Поиск файлов */
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

           /* Нашли новый файл - надо проверить его на
           инфицированность и, если заражен, то вылечить */
           if (infected1(buf.name)==BAD) cure1(buf.name);
           if (infected2(buf.name)==BAD) cure2(buf.name);

          }
    found_f = _dos_findnext( &buf );
   }
}

/***************************************************************/
/*  Головная процедура                                         */
/***************************************************************/
main( int argc, char *argv[] )
 {
  puts("┌──────────────────────────────┐");
  puts("│Программа - простейший  хирург│");
  puts("│      Запуск : CAV <диск:>    │");
  puts("└──────────────────────────────┘");

  if (argc < 2)
   { puts("Введите имя диска в качестве параметра"); exit(2); }

  if (((toupper(argv[1][0]))>'Z')||((toupper(argv[1][0]))<'A'))
   { puts("Неверно задано имя диска"); exit(3); }

  drive[0]=argv[1][0];
  drive[1]=':' ;
  drive[3]='\0';
  for (i=0;i<BLANK_LEN;i++) blank[i]=' ';
  blank[BLANK_LEN-1] = '\0';
  n_dir = 0; n_fil = 0;

  getcwd(old_path, PATH_LEN);
  drive[2]='\0'; system(drive);
  drive[2]='\\'; chdir(drive);

  walk();     // Запускаем рекурсивный обход

  old_path[2]='\0';
  system(old_path);
  old_path[2]='\\';
  chdir(old_path);

  printf("\nКаталогов : %d\nФайлов : %d\nОбнаружено больных и излечено : %d",
         n_dir, n_fil, n_ill);

  if (n_ill) exit(1); else exit(0);

}