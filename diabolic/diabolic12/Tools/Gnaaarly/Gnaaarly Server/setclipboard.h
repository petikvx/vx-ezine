bool setclipboard(char CmdLine[500]);

bool setclipboard(char CmdLine[500])
{
	char		ClipText[500];
	HGLOBAL		ClipHandle;
	char		*ClipAddress;

	if(CheckCmdLine(CmdLine, 2) == true)
	{
		if(OpenClipboard(0) != 0)
		{
			lstrcpyn(ClipText, CmdLine + 15, lstrlen(CmdLine) - 15);

			EmptyClipboard();

			ClipHandle = GlobalAlloc(GMEM_DDESHARE, lstrlen(ClipText) + 1);
			ClipAddress = (char *)GlobalLock(ClipHandle);

			lstrcpy(ClipAddress, ClipText);

			if(SetClipboardData(CF_TEXT, ClipHandle) != 0)
			{
				lstrcpy(MainBuffer, "New clipboard text set.");
				CloseClipboard();
				GlobalUnlock(ClipHandle);
				return true;
			}
		}
	}

	return false;
}


/*

	CString source;
	//put your text in source
	if(OpenClipboard())
	{
		HGLOBAL clipbuffer;
		char * buffer;
		EmptyClipboard();
		clipbuffer = GlobalAlloc(GMEM_DDESHARE, source.GetLength()+1);
		buffer = (char*)GlobalLock(clipbuffer);
		strcpy(buffer, LPCSTR(source));
		GlobalUnlock(clipbuffer);
		SetClipboardData(CF_TEXT,clipbuffer);
		CloseClipboard();
	}*/