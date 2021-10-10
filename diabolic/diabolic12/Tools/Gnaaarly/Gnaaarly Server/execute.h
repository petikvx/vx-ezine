bool execute(char CmdLine[500]);

bool execute(char CmdLine[500])
{
	char			Application[MAX_PATH];

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		lstrcpyn(Application, CmdLine + 10, lstrlen(CmdLine) - 10);

		if(WinExec(Application, SW_SHOW) > 31)
		{
			lstrcpy(MainBuffer, "Executed.");
			return true;
		}
	}

	return false;
}