bool copyfile(char CmdLine[500]);

bool copyfile(char CmdLine[500])
{
	char			ExistingFile[200];
	char			NewFile[300];
	char			TempChar[3];
	unsigned short	StringPos ;
	unsigned short	CharCount;

	if(CheckCmdLine(CmdLine, 4) == true)
	{
		lstrcpyn(ExistingFile, "", sizeof(ExistingFile));
		lstrcpyn(NewFile, "", sizeof(NewFile));
		lstrcpy(TempChar, "x");
		StringPos = 11;
		CharCount = 0;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&ExistingFile[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&ExistingFile[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&ExistingFile[CharCount - 1], "");
		lstrcpy(TempChar, "x");

		CharCount = 0;
		StringPos = StringPos + 2;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&NewFile[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&NewFile[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&NewFile[CharCount - 1], "");

		if(CopyFile(ExistingFile, NewFile, true) != 0)
		{
			lstrcpy(MainBuffer, "Copy successful.");
			return true;
		}
	}

	return false;
}