#include <windows.h>

/********************************************************************* */
void addSourceToRegistry(LPSTR pszAppname, LPSTR pszMsgDLL);
void reportAnIEvent(DWORD dwIdEvent, WORD cStrings, LPTSTR *pszStrings);
void reportAnWEvent(DWORD dwIdEvent, WORD cStrings, LPTSTR *pszStrings);
void reportAnEEvent(DWORD dwIdEvent, WORD cStrings, LPTSTR *pszStrings);

#define MAX_MSG_LENGTH 1024
#define MSG_ID_MASK 0x0000FFFF
#define MAX_INSERT_STRS 8

