#include "D:\BC\BIN\CRC.C"
#include <dos.h>
#include <sys/stat.h>
#include <dir.h>
#include "conio.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>



// DEFINES ***********************

#define ts_year(ts)  ((int)((ts >> 25) & 0x7f) + 1980)
#define ts_month(ts) ((int)(ts >> 21) & 0x0f)      /* 1..12 means Jan..Dec */
#define ts_day(ts)   ((int)(ts >> 16) & 0x1f)      /* 1..31 means 1st..31st */
#define ts_hour(ts)  ((int)(ts >> 11) & 0x1f)
#define ts_min(ts)   ((int)(ts >> 5) & 0x3f)
#define ts_sec(ts)   ((int)((ts & 0x1f) * 2))

#define YES 1
#define NO  0

#define FPROT  1
#define AVPRO  2
#define TBAV   3

#define NAME   1
#define EXT    2
#define SIZE   3
#define CRC    4




// STRUCTURES ********************

struct zipit{
    long sig;
    int xver;
    int bitflag;
    int method;
    long timedate;
    long crc;
    long compsize;
    long fullsize;
    int namelen;
    int fieldlen;
    }Ziphdr;

struct testrectype {
    long Number;
    char FileName[15];
    long size;
    char date[13];
    long crc;
    char Vname[42];
    char Parent[15];
} Rec;

struct mine{
     int Scanner;       // 0 = DON'T CHECK AT ALL
                        // 1 = F-PROT
                        // 2 = AVPRO
                        // 3 = TBSCAN
     int Escstop;       // 1 = Escape key stops processing
     int PrintFile;     // 1 = Print duplicate/unique report to a file
     int PrintScrn;     // 1 = Print file data to screen
     int Subdirs;       // 1 = Process subdirectories when adding
     int MakeBatch;     // 1 = Create a batch file to delete duplicates
     } Config;

typedef struct nodetag
{
     char name[13];
     long size;
     long crc;
     struct nodetag *next;
} SING_LINK_LIST_NODE;

SING_LINK_LIST_NODE *nhead, *ntail;




// VARIABLES *********************

char *ptr;
char ch;
char CurDir[251];
char MainDir[251];
char DataFile[70];
char FileSpec[50];
char origdir[251];
char ParentFile[15];
char q;
char szTemp[150];
FILE *Batch;
FILE *Dat;
FILE *fp2;
FILE *fp;
FILE *Log;
FILE *new;
FILE *Res;
int SortBy=NAME;
long i;
long totala86=0;
long totalasm=0;
long totalbin=0;
long totalboo=0;
long totalc=0;
long totalcom=0;
long totalexefile=0;
long totalfile=0;
long totalobj=0;
long totalpas=0;
long totalscr=0;
long totaltd0=0;
long totalZipfile=0;




// FUNCTIONS *********************

int GetZipData(char *file);
int searchlist(char *file);
void AddRecord(void);
void addsl(SING_LINK_LIST_NODE**,SING_LINK_LIST_NODE**);
void CheckAvpro(void);
void CheckFprot(void);
void Checking(char *file);
void ConvertDescAvpro(void);
void ConvertDescFprot(void);
void ErrorQuit(char *msg);
void findfile(void);
void OpenReading(void);
void OpenWriting(void);
void removelist(SING_LINK_LIST_NODE*);
void setto14(void);
void showtimedate(long the_data);
void viewlist(SING_LINK_LIST_NODE*);


