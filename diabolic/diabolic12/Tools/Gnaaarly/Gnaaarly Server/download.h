#include <wininet.h>
#include <urlmon.h>

bool download(char CmdLine[500]);

bool download(char CmdLine[500])
{
	DWORD			Connected;
	char			URL[250];
	char			SavePath[250];
	char			TempChar[3];
	unsigned short	StringPos;
	unsigned short	CharCount;

	if(CheckCmdLine(CmdLine, 4) == true)
	{
		if(InternetGetConnectedState(&Connected, 0) == 1)
		{
			lstrcpyn(URL, "", sizeof(URL));
			lstrcpyn(SavePath, "", sizeof(SavePath));
			lstrcpy(TempChar, "x");
			StringPos = 11;
			CharCount = 0;

			while(lstrcmp(TempChar, "'") != 0)
			{
				lstrcpyn((char *)&URL[CharCount], CmdLine + StringPos, 2);
				lstrcpyn(TempChar, (char *)&URL[CharCount], 2);
				StringPos++;
				CharCount++;
			}

			lstrcpy((char *)&URL[CharCount - 1], "");
			lstrcpy(TempChar, "x");

			CharCount = 0;
			StringPos = StringPos + 2;

			while(lstrcmp(TempChar, "'") != 0)
			{
				lstrcpyn((char *)&SavePath[CharCount], CmdLine + StringPos, 2);
				lstrcpyn(TempChar, (char *)&SavePath[CharCount], 2);
				StringPos++;
				CharCount++;
			}

			lstrcpy((char *)&SavePath[CharCount - 1], "");

			if(URLDownloadToFile(0, URL, SavePath, 0, 0) == S_OK)
			{
				lstrcpy(MainBuffer, "Download complete.");
				return true;
			}
		}
	}

	return false;
}