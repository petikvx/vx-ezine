bool start(char CmdLine[500]);

bool start(char CmdLine[500])
{
	HWND	Tray;
	HWND	Start;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		Tray = FindWindow("Shell_TrayWnd", 0);
		Start = FindWindowEx(Tray, 0, "button", 0);

		if(Tray != 0 && Start != 0)
		{
			if(lstrcmp(CmdLine, "!start 'hide'") == 0)
			{
				ShowWindow(Start, SW_HIDE);
				lstrcpy(MainBuffer, "Start button invisible.");
				return true;
			}

			if(lstrcmp(CmdLine, "!start 'show'") == 0)
			{
				ShowWindow(Start, SW_SHOW);
				lstrcpy(MainBuffer, "Start button visible.");
				return true;
			}
		}
	}

	return false;
}