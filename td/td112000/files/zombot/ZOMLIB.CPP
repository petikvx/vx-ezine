
// replacement for some standard C functions

#ifdef ZASM             // C++ RTL takes 50k. this stuff takes < 1k. ;-)

//---------------------------------------------------------------------------

#define exit(x)         ExitProcess(x);

//---------------------------------------------------------------------------

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
#define stricmp         strcmpi
#define vsprintf        wvsprintf
#define sprintf         wsprintf
#define memset(s,c,n)   setmem(s,n,c)

//---------------------------------------------------------------------------

void setmem(char*s, int n, char c)
{
  while (n--) *s++ = c;
}

#define memcpy  my_memcpy
void my_memcpy(void*d, void*s, int n)
{
  while (n--) *((char*)d)++ = *((char*)s)++;
}

#define strchr   my_strchr              // such trick, to fix ambiguity
char* my_strchr(char*x, char y)
{
  while ( (*x) && (*x != y) ) x++;
  return *x == y ? x : 0;
}

//---------------------------------------------------------------------------

int atoi(char *s)
{
  int x = 0;
  while ((*s>='0')&&(*s<='9'))
    x = x * 10 + *s++ - '0';
  return *s == 0 ? x : 0;
}

#define itoa my_itoa
char *my_itoa(int value, char *s, int radix)
{
  char *c = s;
  do
  {
    *c++ = (value % radix) + '0';
    value = value / radix;
  } while (value);
  *c = 0;
  return s;
}

//---------------------------------------------------------------------------

#endif // ZASM
