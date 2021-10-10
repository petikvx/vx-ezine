/***************************************************************/
/*             Демонстрационный антивирус-фаг                  */
/*             (c) Климентьев К. Самара, 1997                  */
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
 path[PATH_LEN],     /* Строка имени текущего подкаталога      */
 old_path[PATH_LEN], /* Строка имени начального местоположения */
 drive[DRIVE_LEN],   /* Строка имени требуемого устройства     */
 blank[BLANK_LEN],   /* Пустая строка                          */
 selfn[PATH_LEN];   /* Копия имени                            */

int
 n_dir,              /* Количество отсканированных каталогов   */
 n_fil,              /* Количество исследованных файлов        */
 n_ill;              /* Количество больных и исцеленных файлов */

int
 l,                  /* Длина имени файла                      */
 i,j,                /* Временный индекс                       */
 nd,                 /* Количество драйвов                     */
 tmp;                /* Временная переменная                   */

unsigned
 old_date,               /* Старая дата                        */
 old_time,               /* Старое время                       */
 old_attr;               /* Старый атрибут                     */

int
 found_b;                /* Признак очередной лечилки          */
struct
 find_t buf_b;           /* DTA под поиск лечилок              */

unsigned
 q;                      /* Количество прочитанных байтов      */

long
 len;                    /* Длина лечилки                      */

int
 f;                      /* Файл лечилки                       */

char
 *a[MAXVIR];             /* Массив указателей на лечилки       */

int
 nv;                     /* Количество лечилок                 */

unsigned
 old_o, old_s;           /* Старые значения смещения/сегмента  */

union  REGS  ir, or;     /* Регистры для вызова лечилки        */
struct SREGS sr;

int all=0;               /* Признак просмотра всех файлов      */
int trt=0;               /* Признак лечения                    */

/***************************************************************/
/*    Процедура сохранения атрибута/времени/даты               */
/***************************************************************/
int save_atd( char *path )
 {
   int h;

/* Сохранить атрибут и сбросить его */
  _dos_getfileattr ( path, &old_attr );
  _dos_setfileattr ( path, 0 );

/* Сохранить дату и время файла */
  _dos_open  ( path, O_RDWR, &h );
  _dos_getftime ( h, &old_date, &old_time );
  _dos_close ( h );

}

/***************************************************************/
/*  Процедура восстановления атрибута/времени/даты             */
/***************************************************************/
int rest_atd( char *path )
 {
   int h;

   /* Восстановить время/дату файла */
   _dos_open ( path, O_RDWR, &h );
   _dos_setftime ( h, old_date, old_time );
   _dos_close ( h );

    /* Восстановить атрибут */
   _dos_setfileattr ( path, old_attr );
}


/***************************************************************/
/*          Рекурсивная процедура обхода дерева каталогов      */
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

           /* Вызов "массовых" лечилок - для программ */
           for (i=0;i<nv;i++)
            if ((a[i]!=NULL)&&
               ((a[i][4] == 'P')||(a[i][4] == 'p'))) /* Program */
                {
                 poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
                 poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
                 /* ds:dx := @имя файла */
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

  puts("\n ███▀███  ┌───────────────────────┐");
  puts(" ██   ██  │  Doctor MAD v1.0 Beta │");
  puts(" ███▄███  ├───────────────────────┤");
  puts("С|-@-@-|3 │   Демонстрационный    │");
  puts(" |  6  |  │  антивирус - полифаг  │");
  puts("/  _%~  \\ │(c) Климентьев, Самара │");
  puts("\\       / │     сентябрь 1997     │");
  puts(" ~~~~~~~  └───────────────────────┘\n");

  if (argc < 2)
   {
     puts("Запуск: DRMAD <что> [<как>]");
     puts("        что - логическое имя диска (например, C:), или");
     puts("              * - признак обхода всех доступных дисков. ");
     puts("        как - /c - признак необходимости лечения, или");
     puts("              /a - признак тестирования всех файлов.");
     exit(2);
    }

  if ((((toupper(argv[1][0]))>'Z')||((toupper(argv[1][0]))<'A'))&&
     (argv[1][0]!='*'))
   {
    puts("Неверно задано имя диска");
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
     puts("Неверно задан ключ");
     exit(4);
    }
     if (toupper(argv[i][1]) == 'A') all=1;
     if (toupper(argv[i][1]) == 'C') trt=1;
   }
  }

  n_dir = n_fil = 0;

  /* Сохраняем свое имя */
  i = 0;
  while (argv[0][i]) { selfn[i]=argv[0][i]; i++; }
  selfn[i] = '\0';

  for (i=0;i<BLANK_LEN;i++) blank[i]=' '; blank[BLANK_LEN-1] = '\0';
  if (argv[1][0] == '*')
    { drive[0]='C'; nd = 24; }
  else
    { drive[0]=argv[1][0]; nd = 1; }
  drive[1]=':';  drive[3]='\0';

  /* Формирование маски для поиска лечилок */
  i=0;
  while (selfn[i] != '\0') i++;
  while (selfn[i] != '\\') i--;
  tmp=i;
  selfn[i+1]='*'; selfn[i+2]='.';
  selfn[i+3]='A'; selfn[i+4]='V';
  selfn[i+5]='I'; selfn[i+6]='\0';

  for (i=0;i<MAXVIR;i++) a[i] = NULL;

  /* Поиск и загрузка лечилок */
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
      puts("Не хватает динамической памяти");
      exit(5);
     }
    len  = lseek( f, 0, SEEK_SET );
    q    = _dos_read( f, (void far *) a[i], 0xFFFF, &q );
    _dos_close( f );
    found_b = _dos_findnext( &buf_b ); i++;
  }

  nv = i;
  printf("Антивирусных баз : %d\n", nv );
  if (!(nv)) exit(6);

  old_o = peek( 0, INT*4 );
  old_s = peek( 0, INT*4+2 );

  for (i=0;i<nv;i++)
   {
    printf("%u) %s ; ", i+1, &(a[i][3]));
    if ((i)&&(!(i%3))) printf("\n");
  }
  puts("\n──────────────────────────────────────────");

  /* Вызов "разовых" лечилок - сначала для памяти */
  for (i=0;i<nv;i++)
   if ((a[i]!=NULL)&&
      ((a[i][4] == 'M')||(a[i][4] == 'm')))   /* Memory */
        {
         poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
         poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
         ir.x.bx = 0x80;
         /* Память лечить обязательно !!! */
         ir.x.ax = 1;
         int86x( INT, &ir, &or, &sr );
         if ((or.x.flags)&1) n_ill++;
        }

  /* Вызов "разовых" лечилок - для загрузочных секторов */
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

  /* Проверка себя на зараженность */
  n_fil++;
  printf("%c%s",13,blank);
  printf("%c%s%s ",13,path,argv[0]);
  for (i=0;i<nv;i++)
  {
   if ((a[i]!=NULL)&&
      ((a[i][4] == 'p')||(a[i][4] == 'P'))) /* Программы */
       {
        poke( 0, INT*4,   FP_OFF ((void far *) a[i]) );
        poke( 0, INT*4+2, FP_SEG ((void far *) a[i]) );
        /* ds:dx := @имя файла */
        sr.ds = FP_SEG( argv[0] );
        ir.x.dx = FP_OFF( argv[0] );
        /* Себя лечить обязательно !!! */
        ir.x.ax = 1;
        int86x( INT, &ir, &or, &sr );
        if ((or.x.flags)&1) n_ill++;
       }
  }
  printf("\n");

  getcwd(old_path, PATH_LEN);

  /* Цикл по требуемым дискам */
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

    /* Если задана только дискета */
    if ((drive[0] == 'A')||
        (drive[0] == 'B')||
        (drive[0] == 'a')||
        (drive[0] == 'b'))
     {
      q = 'Y';
      while (((char)q == 'Y')||( (char)q == 'y'))
      {

       /* Вызов "разовых" лечилок для FDD */
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
       printf("\nЕще один гибкий диск ? [Y/N]");
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

  puts("──────────────────────────────────────────");

  if (trt)
   printf("\nКаталогов : %d\nФайлов : %d\nОбнаружено и излечено зараженых объектов: %d",
          n_dir, n_fil, n_ill);
  else
   printf("\nКаталогов : %d\nФайлов : %d\nОбнаружено зараженых объектов: %d",
          n_dir, n_fil, n_ill);

  poke( 0, INT*4,   old_o);
  poke( 0, INT*4+2, old_s );

  puts("\n\nДык, версия-то Beta. Увидите ошибку, примите за улыбку :-)");

  if (n_ill)
    exit(1);
  else
   exit(0);

}