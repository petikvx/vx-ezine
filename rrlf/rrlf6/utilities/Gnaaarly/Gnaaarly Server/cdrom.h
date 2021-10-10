#include <mmsystem.h>

bool cdrom(char CmdLine[500]);

bool cdrom(char CmdLine[500])
{
	char	CdOpen[]  = "Set cdaudio door open wait";
	char	CdClose[] = "Set cdaudio door closed wait";

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		if(lstrcmp(CmdLine, "!cdrom 'open'") == 0)
		{
			if(mciSendString(CdOpen, 0, 0, 0) == 0) 
			{
				lstrcpy(MainBuffer, "CD-Rom opened.");
				return true;
			}
		}

		if(lstrcmp(CmdLine, "!cdrom 'close'") == 0)
		{
			if(mciSendString(CdClose, 0, 0, 0) == 0)
			{
				lstrcpy(MainBuffer, "CD-Rom closed.");
				return true;
			}
		}
	}

	return false;
}