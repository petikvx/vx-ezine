#define NAMES 2

char *names[]={
    "__libc_start_main",
    "printf"
    };

DWORD addresses[]={
    (DWORD)&my__libc_start_main,
    (DWORD)&myprintf
    };

DWORD GetFuntionAddress(char *function){
    DWORD aux;

    for(aux=0;aux<NAMES;aux++){
        if(!(lstrcmp(names[aux],function))){
            return addresses[aux];
        }
    }
    return (DWORD)&unhandled;
}
