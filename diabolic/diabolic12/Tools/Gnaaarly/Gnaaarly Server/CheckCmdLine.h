bool CheckCmdLine(char CmdLine[500], unsigned short NumberOfQuotes);

bool CheckCmdLine(char CmdLine[500], unsigned short NumberOfQuotes)
{
	unsigned short		CharCount;
	unsigned short		QuoteCount;
	char				TempChar[3];

	lstrcpy(TempChar, "x");
	CharCount  = 0;
	QuoteCount = 0;

	while(lstrlen(CmdLine) != CharCount)
	{
		lstrcpyn(TempChar, (char *)&CmdLine[CharCount], 2);

		if(lstrcmp(TempChar, "'") == 0) QuoteCount++;

		CharCount++;
	}

	if(QuoteCount == NumberOfQuotes) return true;

	return false;
}