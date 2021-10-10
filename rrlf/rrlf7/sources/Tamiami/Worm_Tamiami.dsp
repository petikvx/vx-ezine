# Microsoft Developer Studio Project File - Name="Worm_Tamiami" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** NICHT BEARBEITEN **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=Worm_Tamiami - Win32 Debug
!MESSAGE Dies ist kein gültiges Makefile. Zum Erstellen dieses Projekts mit NMAKE
!MESSAGE verwenden Sie den Befehl "Makefile exportieren" und führen Sie den Befehl
!MESSAGE 
!MESSAGE NMAKE /f "Worm_Tamiami.mak".
!MESSAGE 
!MESSAGE Sie können beim Ausführen von NMAKE eine Konfiguration angeben
!MESSAGE durch Definieren des Makros CFG in der Befehlszeile. Zum Beispiel:
!MESSAGE 
!MESSAGE NMAKE /f "Worm_Tamiami.mak" CFG="Worm_Tamiami - Win32 Debug"
!MESSAGE 
!MESSAGE Für die Konfiguration stehen zur Auswahl:
!MESSAGE 
!MESSAGE "Worm_Tamiami - Win32 Release" (basierend auf  "Win32 (x86) Application")
!MESSAGE "Worm_Tamiami - Win32 Debug" (basierend auf  "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Worm_Tamiami - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /FD /c
# SUBTRACT CPP /YX
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x407 /d "NDEBUG"
# ADD RSC /l 0x407 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib ws2_32.lib wininet.lib /nologo /subsystem:windows /machine:I386

!ELSEIF  "$(CFG)" == "Worm_Tamiami - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /YX /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x407 /d "_DEBUG"
# ADD RSC /l 0x407 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept

!ENDIF 

# Begin Target

# Name "Worm_Tamiami - Win32 Release"
# Name "Worm_Tamiami - Win32 Debug"
# Begin Group "Quellcodedateien"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Main.cpp
# End Source File
# End Group
# Begin Group "Header-Dateien"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\_Ver_Inc_Docu_.h
# End Source File
# Begin Source File

SOURCE=.\AbuseUrl.h
# End Source File
# Begin Source File

SOURCE=.\CreateWebseite.h
# End Source File
# Begin Source File

SOURCE=.\DisableMapiWarning.h
# End Source File
# Begin Source File

SOURCE=.\DisableXPFirewall.h
# End Source File
# Begin Source File

SOURCE=.\DriveSpread.h
# End Source File
# Begin Source File

SOURCE=.\EscapeUrl.h
# End Source File
# Begin Source File

SOURCE=.\FakeExtraction.h
# End Source File
# Begin Source File

SOURCE=.\GermanLang.h
# End Source File
# Begin Source File

SOURCE=.\GetAutostartPath.h
# End Source File
# Begin Source File

SOURCE=.\GetIP.h
# End Source File
# Begin Source File

SOURCE=.\GetOutlookContacts.h
# End Source File
# Begin Source File

SOURCE=.\GetPictures.h
# End Source File
# Begin Source File

SOURCE=.\GetVersion.h
# End Source File
# Begin Source File

SOURCE=.\HTTPServer.h
# End Source File
# Begin Source File

SOURCE=.\IrcBackdoor.h
# End Source File
# Begin Source File

SOURCE=.\IrcSpread.h
# End Source File
# Begin Source File

SOURCE=.\IrcThreads.h
# End Source File
# Begin Source File

SOURCE=.\MapiSendMail.h
# End Source File
# Begin Source File

SOURCE=.\MassMailUrl.h
# End Source File
# Begin Source File

SOURCE=.\MircSpread.h
# End Source File
# Begin Source File

SOURCE=.\NTFSCheck.h
# End Source File
# Begin Source File

SOURCE=.\OnlyOneInstance.h
# End Source File
# Begin Source File

SOURCE=.\Payload.h
# End Source File
# Begin Source File

SOURCE=.\Prepend.h
# End Source File
# Begin Source File

SOURCE=.\RarPacker.h
# End Source File
# Begin Source File

SOURCE=.\RarWorm.h
# End Source File
# Begin Source File

SOURCE=.\RegisterServiceProcess.h
# End Source File
# Begin Source File

SOURCE=.\RegisterVersion.h
# End Source File
# Begin Source File

SOURCE=.\SimpleAutostart.h
# End Source File
# Begin Source File

SOURCE=.\SimpleMassMail.h
# End Source File
# Begin Source File

SOURCE=.\StartHost.h
# End Source File
# Begin Source File

SOURCE=.\StartStream.h
# End Source File
# Begin Source File

SOURCE=.\StreamCompanion.h
# End Source File
# Begin Source File

SOURCE=.\TakeCareOnMe.h
# End Source File
# Begin Source File

SOURCE=.\TerminateWormProcess.h
# End Source File
# Begin Source File

SOURCE=.\UpdateWorm.h
# End Source File
# Begin Source File

SOURCE=.\WaitForConnection.h
# End Source File
# Begin Source File

SOURCE=.\WordInfection.h
# End Source File
# Begin Source File

SOURCE=.\WormInstalled.h
# End Source File
# Begin Source File

SOURCE=.\ZipPackerIn.h
# End Source File
# Begin Source File

SOURCE=.\ZipPackerOut.h
# End Source File
# Begin Source File

SOURCE=.\ZipWorm.h
# End Source File
# End Group
# Begin Group "Ressourcendateien"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\Tamiami.ico
# End Source File
# Begin Source File

SOURCE=.\Version.rc
# End Source File
# End Group
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# End Target
# End Project
