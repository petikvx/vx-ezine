
typedef void __pascal rsp(int,int);

void do_hide()
{
    FARPROC x = GetProcAddress(GetModuleHandle("KERNEL32.DLL"), "RegisterServiceProcess");
    if (x) (*(rsp*)&x) (1, 0); //0 instead of GetCurrentProcessId();
}
