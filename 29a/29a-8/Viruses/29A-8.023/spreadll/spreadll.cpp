#include "..\common\spread.h"


void PayLoad()
{
    MessageBox( NULL, "PayLoad", "", MB_OK );
}

BOOL WINAPI DllMain( HINSTANCE hInstance, DWORD ul_reason_for_call, LPVOID lpReserved )
{
	if ( ul_reason_for_call == DLL_PROCESS_ATTACH ) 
	{
        DisableThreadLibraryCalls( hInstance );

		if ( BuildIATTable( GetModuleHandle( NULL ) ) )
		{
		   PayLoad();
		}
	}

	return TRUE;
}
