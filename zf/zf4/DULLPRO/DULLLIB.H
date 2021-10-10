/*******************************************************************/
/* DULLLIB - библиотека процедур для демонстрационного генератора  */
/* навесных защит от НСК для COM/EXE/NE/PE программ.               */
/* (c) Климентьев К., Самара 2001                                  */
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
  unsigned PartPag; // +2   длина неполной последней страницы
  unsigned PageCnt; // +4   длина образа (+заголовок) в 512-байтниках
  unsigned ReloCnt; // +6   число элементов в Relocation Table
  unsigned HdrSize; // +8   длина заголовка в 16-байтниках
  unsigned MinMem;  // +0aH минимум требуемой памяти
  unsigned MaxMem;  // +0cH максимум требуемой памяти
  unsigned ReloSS;  // +0eH сегмент стека (относительно RootS)
  unsigned ExeSP;   // +10H указатель стека
  unsigned ChkSum;  // +12H контрольная сумма
  unsigned ExeIP;   // +14H счетчик команд
  unsigned ReloCS;  // +16H сегмент кода (относительно RootS)
  unsigned TablOff; // +18H позиция в файле 1-го элемента Relocation Table
  unsigned Overlay; // +1aH номер оверлея
  unsigned r1;      // +1cH зарезервировано
  unsigned r2;      // +1eH зарезервировано
};

struct ReloTab
{
 unsigned r_off;    // Смещение
 unsigned r_seg;    // Сегмент
};

struct WINhdr
{
  struct EXEhdr dosHdr; // EXE-заголовок
  BYTE   reserved[28];  // ???
  WORD   winInfoOffset; // Смещение NE- или PE-заголовка
  WORD   reserved2;     // ???
  BYTE   dosStub[1];    // Код заглушки
};

struct tagTBSEGMENT
{
 WORD segDataOffset;  // +00 смещение сегмента в 512-байтных
                      //     секторах _от_начала_файла_ !!!
 WORD segLen;         // +02 длина сегмента в байтах;
 WORD segFlags;       // +04 слово описания сегмента;
 WORD segMinSize;     // +06 резервируемая под сегмент память,
                      //     0 означает максимум: 64Кб.
};

struct tagRELOCATEITEM
{
 BYTE addressType;    // +00 способ задания адреса ссылки
 BYTE relocationType; // +01 тип настроечной ссылки
 WORD itemOffset;     // +02 смещение в сегменте до релокейшена
 WORD index;          // +04 индекс в таблице ссылок,
                      //     либо номер сегмента
 WORD extra;          // +06 порядковый номер функции,
                      //     либо смещение в сегменте
};

struct NEhdr
{
 WORD  NE;               // +0   0x454E = 'NE'
 BYTE  linkerVersion;    // +2   версия компоновщика
 BYTE  linkerRevision;   // +3   ревизия компоновщика
 WORD  entryTabOffset;   // +4   смещение таблицы точек входа
 WORD  entryTabLen;      // +6   длина таблицы точек входа
 DWORD reserved1;        // +8   ???
 WORD  exeFlags;         // +0CH биты описания исполняемого кода
 WORD  dataSegNum;       // +0EH число сегментов "автоданных"
 WORD  localHeapSize;    // +10H исходный размер локального хипа
 WORD  stackSize;        // +12H -"- стека
 WORD  NE_IP;            // +14H смещение в сегменте точки входа
 WORD  NE_CS;            // +16H индекс сегмента точки входа
 WORD  NE_SP;            // +18H смещение в стековом сегменте
 WORD  NE_SS;            // +1AH индекс стекового сегмента (с 1)
 WORD  segTabEntries;    // +1CH к-во элементов в таблице сегментов
 WORD  modTabEntries;    // +1EH -"- в таблице вхождений
 WORD  nonResTabSize;    // +20H -"- в таблице нерезидентов
 WORD  segTabOffset;     // +22H смещ. до табл. сегментов от NEHdr
 WORD  resTabOffset;     // +24H -"- до таблицы ресурсов
 WORD  resNameTabOffset; // +26H -"- до таблицы имен ресурсов
 WORD  modTabOffset;     // +28H -"- до таблицы модулей
 WORD  impTabOffset;     // +2AH -"- до таблицы импорта
 WORD  nonResTabOffset;  // +2CH -"- до таблицы нерезидентов
 WORD  reserved2;        // +2EH ???
 WORD  numEntryPoints;   // +30H к-во перемещаемых точек входа
 WORD  shiftCount;       // +32H Log(SegSiz,2)
 WORD  numResourceSegs;  // +34H число ресурсных сегментов
 BYTE  targetOS;         // +36H код операционной системы
 BYTE  miscFlags;        // +37H прочие биты описания программы
 WORD  fastLoadOffset;   // +38H смещение области быстрой загрузки
 WORD  fastLoadSize;     // +3AH размер области быстрой загрузки
 WORD  reserved3;        // +3CH ???
 BYTE  winRevision;      // +3EH текущая версия Форток
 BYTE  winVersion;       // +3FH текущая ревизия Форток
};

struct PEhdr
{
 // Постоянная часть
 DWORD PE;         // +00  Сигнатура
 WORD MachType;    // +04  Тип процессора
 WORD NOfSections; // +06  Количество секций
 DWORD TimDat;     // +08  Время/дата создания
 DWORD PSymTable;  // +0СH Адрес таблицы символов
 DWORD NOfSymbols; // +10H К-во строк в таблице символов
 WORD SzOfOptHdr;  // +14H Размер переменной части
 WORD Flags;       // +16H Флаги
 // Переменная часть
 WORD R1;          // +18H ???
 BYTE MajorLnkV;   // +1AH Старшая версия линкера
 BYTE MinorLnkV;   // +1BH Младшая версия линкера
 DWORD SizeOfCode; // +1CH Размер исполняемого кода
 DWORD SizeOfInD;  // +20H Размер иниц-ных данных
 DWORD SizeOfUnInD;// +24H Размер неиниц-ных данных
 DWORD EntryPoint; // +28H Адрес точки входа
 DWORD BaseOfCode; // +2CH Смещ. кода в памяти
 DWORD BaseOfData; // +30H Смещ. иниц-ных данных в памяти
 // NT-часть
 DWORD ImBase;     // +34H RVA отобpажения файла в память
 DWORD SectAlign;  // +38H Фактор выравнивания объектов в ОЗУ
 DWORD FileAlign;  // +3CH Фактор выравнивания объектов в файле
 WORD MajorOSV;    // +40H |
 WORD MinorOSV;    // +42H |
 WORD MajorImV;    // +44H |
 WORD MinorImV;    // +46H +> Версии и субверсии компонентов
 WORD MajorSSV;    // +48H |
 WORD MinorSSV;    // +4AH |
 DWORD Win32Vers;  // +4CH |
 DWORD SizeOfIm;   // +50H Размер образа программы в ОЗУ
 DWORD SizeOfHd;   // +54H Размеp заголовка и таблицы объектов
 DWORD CSum;       // +58H Контpольная сумма
 WORD SubS;        // +5CH
 WORD ProcFlags;   // +5EH
 DWORD SizeOfStR;  // +60H
 DWORD SizeOfStC;  // +64H
 DWORD SizeOfHpR;  // +68H
 DWORD SizeOfHpC;  // +6CH
 DWORD LoaderFlags;// +70H
 DWORD NrOfRVAs;   // +74H
 // Описано только у Hard Wisdom
 DWORD ExRVA;      // +78h RVA таблицы экспорта
 DWORD ExSize;     // +7Ch размер таблицы экспорта
 DWORD ImRVA;      // +80h RVA таблицы импорта
 DWORD ImSize;     // +84h размер таблицы импорта
 DWORD RsRVA;      // +88h RVA таблицы ресурсов
 DWORD RsSize;     // +8Ch размер таблицы ресурсов
 DWORD ExcRVA;     // +90h RVA таблицы исключений
 DWORD ExcSize;    // +94h размер таблицы исключений
 DWORD ScRVA;      // +98h RVA таблицы безопасности
 DWORD ScSize;     // +9Ch размер таблицы безопасности
 DWORD FURVA;      // +A0h RVA таблицы настроек
 DWORD FUSize;     // +A4h размер таблицы настроек
 DWORD DbRVA;      // +A8h RVA таблицы отладочной инф.
 DWORD DbSize;     // +ACh размер таблицы отладочной инф.
 DWORD IDRVA;      // +B0h RVA строки описани модуля
 DWORD IDSize;     // +B4h размер строки описания модуля
 DWORD MhRVA;      // +B8h RVA таблицы описания процессора
 DWORD MhSize;     // +BCh размер таблицы описания процессора
 DWORD TLRVA;      // +C0h RVA области данных цепочек
 DWORD TLSize;     // +C4h размер области данных цепочек
 DWORD LCRVA;      // +C8h RVA таблицы параметров загрузки
 DWORD LCSize;     // +CCh размер таблицы параметров загрузки
 DWORD R2[2];      // +D0h ???
 DWORD IARVA;      // +D8h RVA ???
 DWORD IASize;     // +DCh размер ???
 DWORD R3[2];      // +E0h ???
 DWORD R4[2];      // +E8h ???
 DWORD R5[2];      // +F0h ???
};

struct PEObjTbl
{
 BYTE  ObjName[8]; // Символьное имя объекта
 DWORD VirtSize;   // Размер секции объекта в памяти
 DWORD VirtRVA;    // Смещение секции от начала образа в памяти
 DWORD PhSize;     // Размер секции объекта на диске
 DWORD PhOffset;   // Смещение секции от начала файла
 DWORD R1[3];      // ???
 DWORD ObjFlags;   // Флаги свойств секции
};

struct PEITbl
{
 DWORD Chars;      // +00  (Адрес таблицы имен функций)
 DWORD TimeDate;   // +04  Время/дата создания
 DWORD Forward;    // +08  ???
 DWORD NamePtr;    // +0Ch Адрес имен библиотек
 DWORD Thunk;      // +10h Адрес библиотеки адресов функций
                   //      (также адрес адреса таблицы имен функций)
};

int Infect_COM(char *fn);
int Infect_EXE(char *fn);
int Infect_NE (char *fn);
int Infect_PE (char *fn);
