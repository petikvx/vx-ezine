# Microsoft Developer Studio Project File - Name="Poetry" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=Poetry - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Poetry.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Poetry.mak" CFG="Poetry - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Poetry - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE "Poetry - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/Poetry", BAAAAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Poetry - Win32 Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /Gz /MDd /W3 /Gm /Gi /GR /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR /YX"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o /win32 "NUL"
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o /win32 "NUL"
# ADD BASE RSC /l 0x40c /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 DNSResolverLibrary/debug/DNSResolverLibrary.lib /nologo /version:1.0 /subsystem:windows /debug /machine:I386
# SUBTRACT LINK32 /pdb:none

!ELSEIF  "$(CFG)" == "Poetry - Win32 Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Ignore_Export_Lib 0
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /Gi /GR /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR /YX"stdafx.h" /FD /c
# ADD CPP /nologo /Gz /MD /W3 /GR /GX /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR"Release/" /YX"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o /win32 "NUL"
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o /win32 "NUL"
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 DNSResolverLibrary/debug/DNSResolverLibraryd.lib /nologo /version:1.0 /subsystem:windows /debug /machine:I386
# SUBTRACT BASE LINK32 /profile /incremental:no /nodefaultlib
# ADD LINK32 DNSResolverLibrary/release/DNSResolverLibrary.lib /nologo /version:1.0 /subsystem:windows /pdb:none /machine:I386 /out:"Release/Poetry.exe"
# SUBTRACT LINK32 /profile /debug /nodefaultlib

!ENDIF 

# Begin Target

# Name "Poetry - Win32 Debug"
# Name "Poetry - Win32 Release"
# Begin Group "source"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\smtp\AppOctetStream.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\Base64.cpp
# End Source File
# Begin Source File

SOURCE=.\EmailAdr.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\MailMessage.cpp
# End Source File
# Begin Source File

SOURCE=.\MainFrm.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMECode.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMEContentAgent.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMEMessage.cpp
# End Source File
# Begin Source File

SOURCE=.\Poetry.rc
# End Source File
# Begin Source File

SOURCE=.\PoetryApp.cpp
# End Source File
# Begin Source File

SOURCE=.\SendMessage.cpp
# End Source File
# Begin Source File

SOURCE=.\smtp\SMTP.cpp
# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\smtp\TextPlain.cpp
# End Source File
# Begin Source File

SOURCE=.\WebBrowse.cpp
# End Source File
# End Group
# Begin Group "headers"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\smtp\AppOctetStream.h
# End Source File
# Begin Source File

SOURCE=.\smtp\Base64.h
# End Source File
# Begin Source File

SOURCE=.\HtmlParser\Cfifpars.h
# End Source File
# Begin Source File

SOURCE=.\HtmlParser\Cookies.h
# End Source File
# Begin Source File

SOURCE=.\EmailAdr.h
# End Source File
# Begin Source File

SOURCE=.\smtp\MailMessage.h
# End Source File
# Begin Source File

SOURCE=.\MainFrm.h
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMECode.h
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMEContentAgent.h
# End Source File
# Begin Source File

SOURCE=.\smtp\MIMEMessage.h
# End Source File
# Begin Source File

SOURCE=.\PoetryApp.h
# End Source File
# Begin Source File

SOURCE=.\QueriesManager.h
# End Source File
# Begin Source File

SOURCE=.\Resource.h
# End Source File
# Begin Source File

SOURCE=.\SendMessage.h
# End Source File
# Begin Source File

SOURCE=.\Smtp.h
# End Source File
# Begin Source File

SOURCE=.\smtp\SMTP.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# Begin Source File

SOURCE=.\HtmlParser\TemplateVariables.h
# End Source File
# Begin Source File

SOURCE=.\smtp\TextPlain.h
# End Source File
# Begin Source File

SOURCE=.\WebBrowse.h
# End Source File
# End Group
# Begin Group "ressources"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\res\Poetry.ico
# End Source File
# Begin Source File

SOURCE=.\res\Poetry.rc2
# End Source File
# Begin Source File

SOURCE=.\ReadMe.txt
# End Source File
# End Group
# End Target
# End Project
