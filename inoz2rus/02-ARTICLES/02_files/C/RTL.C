
#define malloc(x)       ((void*)GlobalAlloc(GMEM_FIXED|GMEM_ZEROINIT, x))
#define free(x)         GlobalFree(x)

#undef  strlen
#undef  strcpy
#undef  strcmp
#undef  strcmpi
#undef  memset
#undef  setmem
#undef  memcpy

#define strlen          lstrlen
#define strcpy          lstrcpy
#define strcmp          lstrcmp
#define strcmpi         lstrcmpi
#define strcat          lstrcat
#define vsprintf        wvsprintf
#define sprintf         wsprintf

