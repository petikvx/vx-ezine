#include "stdafx.h"
#include "prototypes.h"





BOOL IsValidMail(char mail[])
{
	BOOL there_is_at=FALSE,there_is_dot=FALSE;

	int i;

	for(i=0;i<lstrlen(mail);i++)
	{
		if(mail[i]=='@')
			there_is_at=TRUE;
		if(mail[i]=='.')
			there_is_dot=TRUE;
	}
	
	return(there_is_at && there_is_dot);
}


BOOL AddMail(DuelMailList &xml,char Mail[])
{
	int i;

	for(i=0;i<xml.NumberOfMails;i++)
		if(lstrcmp(xml.Email[i],Mail)==0)
			return FALSE;

	if(xml.NumberOfMails<Duel_Max_Mails && IsValidMail(Mail)==TRUE)
	{
		CharLower(Mail);
		lstrcpy(xml.Email[xml.NumberOfMails],Mail);
		xml.NumberOfMails++;
		AddToLog(Mail,Duel_Log_Mail_Founded,TRUE);
		return TRUE;
	}
	else
		return FALSE;
}

void ScanBuffer(char *buffer,int size,DuelMailList &xml)
{
	char *bp;
	int i,xlen=0,xlen2;
	char mail[40];

	int mp=0;
	
	//valid mail : user@domain.suffix
	
	for(i=0;i<size-1;i++)
	{
		bp=strchr(buffer,'@');
		if(bp==NULL)			//if there is no @ than get out
			break;
		
		i+=(bp-buffer);		//move index

		//get user len
		xlen=0;

		mp=0;

		do
		{

			bp--;

			if(*bp<48)
				break;		//minimum char
			if(*bp>122)
				break;		//maximum char

			if(*bp<97 && *bp>90)
				break;

			if(*bp<65 && *bp>57)
				break;

			xlen++;

			if(xlen>20)
				goto no_dot;
			
		}while(TRUE);



		if(xlen<2)
			goto no_dot;

		bp++;
		
		xlen++;
		

		memcpy(mail,bp,xlen);

		mp+=xlen;

		bp+=xlen;

		buffer=bp;
		

		bp=strchr(bp,'.');


		if(bp==NULL)
			goto no_dot;

		if((bp-buffer)>15)
			goto no_dot;

		xlen2=xlen;
		xlen=0;


		do
		{
			xlen++;

			bp--;

			if(*bp=='@')
				break;

		}while(TRUE);

		xlen2++;

		memcpy(mail+mp,bp+1,xlen);

		mp+=xlen;

		bp+=xlen+1;

		xlen=0;


		do
		{
			if(*(bp+xlen)!='.')
			{
				if(*(bp+xlen)<48)
					break;		//minimum char
				if(*(bp+xlen)>122)
					break;		//maximum char

				if(*(bp+xlen)<97 && *bp>90)
					break;

				if(*(bp+xlen)<65 && *bp>57)
					break;
			}

			xlen++;

			if(xlen>15)
				break;

		}while(TRUE);


		if(xlen<15)
			memcpy(mail+mp,bp,xlen);

		mail[mp+xlen]=NULL;
		


		if(IsValidMail(mail)==TRUE)	
			AddMail(xml,mail);
		
no_dot:
		buffer+=i;			//move buffer pointer
	}


}


void FindMails(char File[],DuelMailList &xml)
{
	char buffer[1024];
	HANDLE hfile;
	DWORD readed;

	hfile=CreateFile(File,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
	
	if(hfile!=INVALID_HANDLE_VALUE)
	{
		while(ReadFile(hfile,buffer,sizeof(buffer)-24,&readed,NULL))
		{
			if(readed==0)
				break;
			
			try
			{
				ScanBuffer(buffer,readed,xml);
			}
			catch(...)
			{
				__asm nop
			}
		}
		CloseHandle(hfile);
	}
}


void InitMailList(DuelMailList &xml)
{
	memset(&xml,0,sizeof(xml));
	xml.NumberOfMails=0;
}
