#include <windows.h>
#include <string.h>
#include <dos.h>
#include "..\\fmt.hpp"
#include "plugin.hpp"

static HANDLE ArcHandle;
static DWORD SFXSize,NextPosition,FileSize;
static int ArcComment,Truncated,FirstRecord;

BOOL WINAPI _export IsArchive(char *Name,const unsigned char *Data,int DataSize)
{
  if (Data[0]=='P' && Data[1]=='K' && Data[2]==5 && Data[3]==6)
  {
    SFXSize=0;
    return(TRUE);
  }
  for (int I=0;I<DataSize-10;I++)
  {
    const unsigned char *D=Data+I;
    if (D[0]=='P' && D[1]=='K' && D[2]==3 && D[3]==4 && D[8]<15 && D[9]==0)
    {
      SFXSize=I;
      return(TRUE);
    }
  }
  return(FALSE);
}


BOOL WINAPI _export OpenArchive(char *Name,int *Type)
{
  ArcHandle=CreateFile(Name,GENERIC_READ,FILE_SHARE_READ|FILE_SHARE_WRITE,
                       NULL,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,NULL);
  if (ArcHandle==INVALID_HANDLE_VALUE)
    return(FALSE);

  *Type=0;

  ArcComment=FALSE;
  FirstRecord=TRUE;

  FileSize=GetFileSize(ArcHandle,NULL);

  char ReadBuf[1024];
  DWORD CurPos,ReadSize;
  int Buf,Found=0;
  CurPos=NextPosition=SetFilePointer(ArcHandle,0,NULL,FILE_END);
  if (CurPos<sizeof(ReadBuf)-18)
    CurPos=0;
  else
    CurPos-=sizeof(ReadBuf)-18;
  for (Buf=0;Buf<64 && !Found;Buf++)
  {
    SetFilePointer(ArcHandle,CurPos,NULL,FILE_BEGIN);
    ReadFile(ArcHandle,ReadBuf,sizeof(ReadBuf),&ReadSize,NULL);
    for (int I=ReadSize-4;I>=0;I--)
      if (ReadBuf[I]==0x50 && ReadBuf[I+1]==0x4b && ReadBuf[I+2]==0x05 &&
          ReadBuf[I+3]==0x06)
      {
        SetFilePointer(ArcHandle,CurPos+I+16,NULL,FILE_BEGIN);
        ReadFile(ArcHandle,&NextPosition,sizeof(NextPosition),&ReadSize,NULL);
        Found=TRUE;
        break;
      }
    if (CurPos==0)
      break;
    if (CurPos<sizeof(ReadBuf)-4)
      CurPos=0;
    else
      CurPos-=sizeof(ReadBuf)-4;
  }
  Truncated=!Found;
  if (Truncated)
    NextPosition=SFXSize;
  return(TRUE);
}


int WINAPI _export GetArcItem(struct PluginPanelItem *Item,struct ArcItemInfo *Info)
{
  struct ZipHd1
  {
    DWORD Mark;
    BYTE UnpVer;
    BYTE UnpOS;
    WORD Flags;
    WORD Method;
    DWORD ftime;
    DWORD CRC;
    DWORD PackSize;
    DWORD UnpSize;
    WORD NameLen;
    WORD AddLen;
  } ZipHd1;

  struct ZipHd2
  {
    DWORD Mark;
    BYTE PackVer;
    BYTE PackOS;
    BYTE UnpVer;
    BYTE UnpOS;
    WORD Flags;
    WORD Method;
    DWORD ftime;
    DWORD CRC;
    DWORD PackSize;
    DWORD UnpSize;
    WORD NameLen;
    WORD AddLen;
    WORD CommLen;
    WORD DiskNum;
    WORD ZIPAttr;
    DWORD Attr;
    DWORD Offset;
  } ZipHeader;

  DWORD ReadSize;

  NextPosition=SetFilePointer(ArcHandle,NextPosition,NULL,FILE_BEGIN);
  if (NextPosition==0xFFFFFFFF)
    return(GETARC_READERROR);
  if (NextPosition>FileSize)
    return(GETARC_UNEXPEOF);
  if (Truncated)
  {
    if (!ReadFile(ArcHandle,&ZipHd1,sizeof(ZipHd1),&ReadSize,NULL))
      return(GETARC_READERROR);
    memset(&ZipHeader,0,sizeof(ZipHeader));
    ZipHeader.UnpVer=ZipHd1.UnpVer;
    ZipHeader.UnpOS=ZipHd1.UnpOS;
    ZipHeader.Flags=ZipHd1.Flags;
    ZipHeader.ftime=ZipHd1.ftime;
    ZipHeader.PackSize=ZipHd1.PackSize;
    ZipHeader.UnpSize=ZipHd1.UnpSize;
    ZipHeader.NameLen=ZipHd1.NameLen;
    ZipHeader.AddLen=ZipHd1.AddLen;
  }
  else
  {
    if (!ReadFile(ArcHandle,&ZipHeader,sizeof(ZipHeader),&ReadSize,NULL))
      return(GETARC_READERROR);
    if (ZipHeader.Mark!=0x02014b50 && ZipHeader.Mark!=0x06054b50)
      if (FirstRecord)
      {
        if (SFXSize>0)
        {
          NextPosition+=SFXSize;
          SetFilePointer(ArcHandle,NextPosition,NULL,FILE_BEGIN);
          if (!ReadFile(ArcHandle,&ZipHeader,sizeof(ZipHeader),&ReadSize,NULL))
            return(GETARC_READERROR);
        }
        if (ZipHeader.Mark!=0x02014b50 && ZipHeader.Mark!=0x06054b50)
        {
          Truncated=TRUE;
          NextPosition=SFXSize;
          return(GetArcItem(Item,Info));
        }
      }
      else
        return(GETARC_UNEXPEOF);
  }

  FirstRecord=FALSE;

  if (ReadSize==0 || ZipHeader.Mark==0x06054b50 ||
      Truncated && ZipHeader.Mark==0x02014b50)
  {
    if (!Truncated && *(WORD *)((char *)&ZipHeader+20)!=0)
      ArcComment=TRUE;
    return(GETARC_EOF);
  }
  int SizeToRead=(ZipHeader.NameLen<NM-1) ? ZipHeader.NameLen : NM-1;
  if (!ReadFile(ArcHandle,Item->FindData.cFileName,SizeToRead,&ReadSize,NULL) ||
      ReadSize!=SizeToRead)
    return(GETARC_READERROR);
  Item->FindData.cFileName[NM-1]=0;
  long SeekLen=ZipHeader.AddLen+ZipHeader.CommLen;
  if (Truncated)
    SeekLen+=ZipHeader.PackSize;
  NextPosition=SetFilePointer(ArcHandle,SeekLen,NULL,FILE_CURRENT);

  Item->FindData.dwFileAttributes=ZipHeader.Attr & 0x3f;
  Item->FindData.nFileSizeLow=ZipHeader.UnpSize;
  Item->PackSize=ZipHeader.PackSize;
  FILETIME lft;
  DosDateTimeToFileTime(HIWORD(ZipHeader.ftime),LOWORD(ZipHeader.ftime),&lft);
  LocalFileTimeToFileTime(&lft,&Item->FindData.ftLastWriteTime);
  if (ZipHeader.Flags & 1)
    Info->Encrypted=TRUE;
  if (ZipHeader.CommLen > 0)
    Info->Comment=TRUE;
  static char *ZipOS[]={"DOS","Amiga","VAX/VMS","Unix","VM/CMS","Atari ST",
                        "OS/2","Mac-OS","Z-System","CP/M","TOPS-20",
                        "Win32","SMS/QDOS","Acorn RISC OS","Win32 VFAT","MVS",
                        "BeOS","Tandem"};
  if (ZipHeader.PackOS<sizeof(ZipOS)/sizeof(ZipOS[0]))
    strcpy(Info->HostOS,ZipOS[ZipHeader.PackOS]);

  if (ZipHeader.PackOS==11 && ZipHeader.PackVer>20 && ZipHeader.PackVer<25)
    CharToOem(Item->FindData.cFileName,Item->FindData.cFileName);
  Info->UnpVer=(ZipHeader.UnpVer/10)*256+(ZipHeader.UnpVer%10);
  Info->DictSize=32;
  return(GETARC_SUCCESS);
}


BOOL WINAPI _export CloseArchive(struct ArcInfo *Info)
{
  Info->SFXSize=SFXSize;
  Info->Comment=ArcComment;
  return(CloseHandle(ArcHandle));
}


BOOL WINAPI _export GetFormatName(int Type,char *FormatName,char *DefaultExt)
{
  if (Type==0)
  {
    strcpy(FormatName,"ZIP");
    strcpy(DefaultExt,"ZIP");
    return(TRUE);
  }
  return(FALSE);
}


BOOL WINAPI _export GetDefaultCommands(int Type,int Command,char *Dest)
{
  if (Type==0)
  {
    static char *Commands[]={
      "pkunzip -d -o {-s%%P} %%a @%%lNM",
      "pkunzip -o {-s%%P} %%a @%%lNM",
      "pkunzip -t {-s%%P} %%a @%%lNM",
      "pkzip -d {-b%%W} %%a @%%lNM",
      "pkzip -z {-b%%W} %%a",
      "pkzip -c {-b%%W} %%a @%%lNM",
      "zip2exe %%a",
      "",
      "",
      "pkzipfix %%a",
      "pkzip -a -whs {-s%%P} {-b%%W} %%a @%%lNM",
      "pkzip -m -whs {-s%%P} {-b%%W} %%a @%%lNM",
      "pkzip -a -whs -r -P {-s%%P} {-b%%W} %%a @%%lNM",
      "pkzip -m -whs -r -P {-s%%P} {-b%%W} %%a @%%lNM",
      "*.*"
    };
    if (Command<sizeof(Commands)/sizeof(Commands[0]))
    {
      strcpy(Dest,Commands[Command]);
      return(TRUE);
    }
  }
  return(FALSE);
}

