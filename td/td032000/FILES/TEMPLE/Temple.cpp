//---------------------------------------------------------------------------
#include <vcl.h>
#include <string.h>
#pragma hdrstop
USEFORM("Main.cpp", Form1);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR cmd, int)
{
 extern String cmdline;
    try
    {
        cmdline=cmd;
        Application->Initialize();
        Application->CreateForm(__classid(TForm1), &Form1);
                 }
    catch (Exception &exception)
    {
        Application->ShowException(&exception);
    }
    return 0;
}
//---------------------------------------------------------------------------

