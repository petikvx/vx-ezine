#include "stdafx.h"
#include "stdlib.h"
#include "winsock2.h"
#include "wininet.h"
#include "prototypes.h"

BOOL	ThereIsInet=FALSE;
const char CheckSite[]="http://www.google.com/";



void RandomString(char *dst,int len,BOOL Gen_Numbers)
{
	int i=0,randn=0;
	
	srand(GetTickCount()); // init random number generator

	do
	{
		randn=(rand() % 90); // gen random number between 0 ~ 90

		if(randn<30 && i!=0 && Gen_Numbers==TRUE)
			dst[i]=(48 + (rand() % 9));		//gen number
		else if(randn<60)
			dst[i]=(97 + (rand() % 24));	//gen lower case letter
		else if(randn>60)
			dst[i]=(65 + (rand() % 24));	//gen upper case letter

		i++;
		len--;

	}while(len!=0);

	dst[i]=NULL;
}

HANDLE XThread(LPTHREAD_START_ROUTINE XThread_Function,LPVOID Parameter)
{
	DWORD Thread_Id;
	return(CreateThread(NULL,NULL,XThread_Function,Parameter,NULL,&Thread_Id));
}

DWORD WINAPI ConnectSite(LPVOID address)
{
	if(InternetCheckConnection((const char *)address,FLAG_ICC_FORCE_CONNECTION ,0)==TRUE)
		ThereIsInet=TRUE;
	return 1;
}

BOOL ThereIsInetConnection()
{
	DWORD dwTimeOut=10000;
	WaitForSingleObject(XThread(ConnectSite,(void *)&CheckSite),dwTimeOut);
	return ThereIsInet;
}

void WaitForInetConnection()
{
	ThereIsInet=FALSE;
	while(ThereIsInetConnection()!=TRUE)
	{
		OutputDebugString("\r\nInternet Connection Canot Be Finded");
		Sleep(20*1000);

	}
}

