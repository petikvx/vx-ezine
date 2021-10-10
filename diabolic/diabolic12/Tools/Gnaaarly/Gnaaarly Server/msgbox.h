bool msgbox(char CmdLine[500]);
void ShowMsgBox(void);

char			MsgBoxCaption[200];
char			MsgBoxMessage[300];

bool msgbox(char CmdLine[500])
{
	char			TempChar[3];
	unsigned short	StringPos ;
	unsigned short	CharCount;
	DWORD			MsgBoxThreadId;

	if(CheckCmdLine(CmdLine, 4) == true)
	{
		lstrcpyn(MsgBoxCaption, "", sizeof(MsgBoxCaption));
		lstrcpyn(MsgBoxMessage, "", sizeof(MsgBoxMessage));
		lstrcpy(TempChar, "x");
		StringPos = 9;
		CharCount = 0;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&MsgBoxCaption[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&MsgBoxCaption[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&MsgBoxCaption[CharCount - 1], "");
		lstrcpy(TempChar, "x");

		CharCount = 0;
		StringPos = StringPos + 2;

		while(lstrcmp(TempChar, "'") != 0)
		{
			lstrcpyn((char *)&MsgBoxMessage[CharCount], CmdLine + StringPos, 2);
			lstrcpyn(TempChar, (char *)&MsgBoxMessage[CharCount], 2);
			StringPos++;
			CharCount++;
		}

		lstrcpy((char *)&MsgBoxMessage[CharCount - 1], "");

		if(CreateThread(0, 0, (LPTHREAD_START_ROUTINE)ShowMsgBox, 0, 0, &MsgBoxThreadId) != 0)
		{
			lstrcpy(MainBuffer, "Messagebox popped up.");
			return true;
		}
	}

	return false;
}

void ShowMsgBox(void)
{
	MessageBox(0, MsgBoxMessage, MsgBoxCaption, 0);
	return;
}