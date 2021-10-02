int myprintf(const char *fmt, ...){
    printf(fmt);
    return 0;
}

void my__libc_start_main(DWORD entry){
    asm mov eax,entry;
    asm call eax;
    ExitProcess(0);
}

void unhandled(char *function){
    printf("UNIMPLEMENTED FUNCTION <%s> CALLED\n",function);
    ExitProcess(-1);
}