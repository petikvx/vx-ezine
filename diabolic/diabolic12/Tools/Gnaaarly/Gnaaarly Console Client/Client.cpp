//Winsock example - remote control :: Client
//(c)2005 by Sebastian Senf

#include <winsock2.h>
#include <windows.h>
#include <stdio.h>
#include <small.h>

void Help(void);

int main()
{
	WSADATA			WSA;
	SOCKET			ConnectSock;
	SOCKADDR_IN		SockAddr;
	char			Buffer[500];
	char			ServerIp[20];
	char			RetBuffer[2000];
	char			Return[2000];
	unsigned short	ReturnLength;

	printf("winsock example - remote control  ::  Client\n");
	printf("############################################\n\n");

	printf("Server IP (l for localhost 127.0.0.1): ");
	gets(ServerIp);

	if(lstrcmp(ServerIp, "l") == 0) lstrcpy(ServerIp, "127.0.0.1");
	
	if(WSAStartup(MAKEWORD(2, 0), &WSA) == 0)
	{
		ConnectSock = socket(AF_INET, SOCK_STREAM, 0);

		if(ConnectSock != INVALID_SOCKET)
		{
			memset(&SockAddr, 0, sizeof(SockAddr));

			SockAddr.sin_family		 = AF_INET;
			SockAddr.sin_port		 = htons(30687);
			SockAddr.sin_addr.s_addr = inet_addr(ServerIp);
			
			if(connect(ConnectSock, (SOCKADDR *)&SockAddr, sizeof(SockAddr)) != SOCKET_ERROR)
			{
				printf("\n\nConnected, enter Commands (!help):\n\n");

				while(lstrcmp(Buffer, "!quit") != 0 && lstrcmp(Buffer, "!close") != 0)
				{
					gets(Buffer);

					if(lstrlen(Buffer) > 500)
					{
						printf("Too long command.\n\n");
						continue;
					}

					if(lstrcmp(Buffer, "") == 0)
					{
						printf("No command.\n\n");
						continue;
					}

					if(lstrcmp(Buffer, "!cls") == 0)
					{
						system("cls");
						continue;
					}

					if(lstrcmp(Buffer, "!help") == 0)
					{
						Help();
						continue;
					}

					send(ConnectSock, Buffer, lstrlen(Buffer), 0);

					ReturnLength = recv(ConnectSock, RetBuffer, sizeof(RetBuffer), 0);
					lstrcpyn(Return, RetBuffer, ReturnLength + 1);

					printf(Return);
					printf("\n\n");
				}

				printf("\nTo close client press enter...");
				gets(Buffer);

				closesocket(ConnectSock);
				WSACleanup();

				return 0;
			}

			closesocket(ConnectSock);
		}

		WSACleanup();
	}

	printf("\n\nCan not connect to server...\n");
	printf("To close client press enter...");
	gets(Buffer);

	return 0;
}

void Help(void)
{
	char	WinDir[MAX_PATH];
	char	CurDir[MAX_PATH];

	if(GetWindowsDirectory(WinDir, sizeof(WinDir)) != 0)
	{
		lstrcat(WinDir, "\\Notepad.exe ");

		if(GetCurrentDirectory(sizeof(CurDir), CurDir) != 0)
		{
			lstrcat(CurDir, "\\Commands.txt");
			lstrcat(WinDir, CurDir);
		
			if(WinExec(WinDir, SW_SHOW) > 31)
			{
				printf("\n");
				return;
			}
		}
	}
	
	MessageBox(0, "Can not pick up Notepad. Please open Commands.txt by yourself.", "ERROR", MB_ICONERROR);
	return;
}