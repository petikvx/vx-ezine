; 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
;               Initiate settings

initsettings:	lea	eax, [modulefilename]
		stdcall checksum,eax,0
		lea	edi, [regdatakey]
		stdcall makehashword,edi,edx
		lea	esi, [inithandle]
		push	eax
		invoke	RegOpenKeyEx,HKEY_CLASSES_ROOT,edi,0,0,0,KEY_ALL_ACCESS,0,esi,esp
		pop	eax
		and	byte [edi], 0
		lea	eax, [connectsettings]
		push	512
		invoke	RegQueryValueEx,[esi],edi,0,0,eax,esp
		pop	eax
