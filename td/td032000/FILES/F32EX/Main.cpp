#define STRICT
#include <windows.h>

typedef struct _SEH   
{     
 _SEH  *m_pSEH;     
 DWORD  m_pExcFunction;
} SEH, *PSEH;   

DWORD FindK32(DWORD dwStartAddress, DWORD dwMinAddress);

int WINAPI WinMain(HINSTANCE hInstance, // handle to current instance
                   HINSTANCE hPrevInstance,     // handle to previous instance
                   LPSTR lpCmdLine,     // pointer to command line
                   int nCmdShow         // show state of window
                  )
{

  SEH  *seh;   

  __asm{ 
        mov eax, fs:[0]   // указатель на список обработчиков
                          // лежит здесь         
        mov [seh], eax        
       }
   // если seh->m_pSEH = -1   
   // то это последний в списке обработчик
   // он то нам и нужен   
  while((DWORD)seh->m_pSEH != 0xffffffff)
     seh = seh->m_pSEH;   
   
      
   // seh->m_pExcFunction - этот адрес мы передаем
   // стандартной процедуре нахождения HMODULE k32
  DWORD dwFn = seh->m_pExcFunction;
  char  Buf[256];

  wsprintf(Buf, "\nK32 SEX function = %08X \n K32 base = %08X \n Address CreateFileA = %08X", dwFn, FindK32(dwFn, 0), GetProcAddress((HMODULE)FindK32(dwFn, 0), "CreateFileA")); 
  
  MessageBox(NULL, Buf, "Find k32 SEH", MB_OK);

  return (int)dwFn;
}

DWORD FindK32(DWORD dwStartAddress, DWORD dwMinAddress)
{
  WORD *pSyg = NULL;
  
  __try{
        dwStartAddress = dwStartAddress & 0xffff0000;
        dwMinAddress = dwMinAddress & 0xffff0000;

        for(;dwStartAddress > dwMinAddress; dwStartAddress-=0x10000)
          {
           pSyg = (WORD*)dwStartAddress;
           if(!IsBadReadPtr(pSyg, sizeof(WORD)))
             {
              if(*pSyg == 'ZM')
                 break;
             }
           pSyg = NULL;
          }
       }
  __except(EXCEPTION_EXECUTE_HANDLER)
       {
        pSyg = NULL;
       }

  return (DWORD)pSyg;
}

