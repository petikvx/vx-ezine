    "SPREAD" infect all .EXE files in all hard drives in the computer.
    
    They make a new section ".senna" in .EXE file, change IAT (Import
Address Table) and insert a "SPREADLL.DLL" dependency.
    Only one ".senna" section is allowed, if this section exists SPREAD.EXE
dont infect again.

    If the user remove "SPREADLL.DLL", the .EXE dont work any more, because
inside this .DLL, the IAT are rebuilded.

    After run an infected .EXE file, the DLL are loaded and "PayLoad" 
function (inside .DLL) is executed...  Do you can change this function and
insert any action ;-)

    This program are compiled in "MS-Visual C++ 6.0" and tested in 
Windows 2000 and XP... and works fine.

    Open project "SPREAD.DSW" in MS-Visual C++ 6.0 and choose the option
"Build" and "Rebuil all"... this compiles .DLL and .EXE files (the .DLL file
is automaticly inserted inside .EXE resource)...

    I make a #define only for tests.  With this #define, the .EXE files
aren't infected... only display a MessageBox with the filename.
    For change this feature, open the "SPREAD.H" file and comment the line:
"#define  _TEST  1" and recompile again.


    Thanks to SkBeta, #virus, #vxers and 29a...
