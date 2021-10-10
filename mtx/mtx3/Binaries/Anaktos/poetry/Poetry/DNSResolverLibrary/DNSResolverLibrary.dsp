# Microsoft Developer Studio Project File - Name="DNSResolverLibrary" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Static Library" 0x0104

CFG=DNSResolverLibrary - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "DNSResolverLibrary.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "DNSResolverLibrary.mak" CFG="DNSResolverLibrary - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "DNSResolverLibrary - Win32 Release" (based on "Win32 (x86) Static Library")
!MESSAGE "DNSResolverLibrary - Win32 Debug" (based on "Win32 (x86) Static Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /Gz /MD /W3 /GR /GX /O1 /I "." /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "WINNT" /D "USE_OPTIONS_H" /D "i386" /YX"stdafx.h" /FD /c
# ADD BASE RSC /l 0x409 /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /fo"Messages.res" /d "NDEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# PROP BASE Use_MFC 2
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "DNSResolverLibrary___Win32_Debug"
# PROP BASE Intermediate_Dir "DNSResolverLibrary___Win32_Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 2
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /Gz /MDd /W3 /Gm /Gi /GR /GX /ZI /Od /I "." /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /D "DEBUG" /D "WINNT" /D "USE_OPTIONS_H" /D "i386" /YX"stdafx.h" /FD /GZ /c
# ADD BASE RSC /l 0x409 /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x409 /fo"Messages.res" /d "_DEBUG" /d "_AFXDLL"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LIB32=link.exe -lib
# ADD BASE LIB32 /nologo
# ADD LIB32 /nologo

!ENDIF 

# Begin Target

# Name "DNSResolverLibrary - Win32 Release"
# Name "DNSResolverLibrary - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\base64.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gethnamaddr.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\getnetbyaddr.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\getnetbyname.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\getnetent.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\getnetnamadr.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\gettimeofday.c
# End Source File
# Begin Source File

SOURCE=.\herror.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\hostnamelen.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_addr.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_net_ntop.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_net_pton.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_neta.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_ntop.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\inet_pton.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\log.c
# End Source File
# Begin Source File

SOURCE=.\nsap_addr.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\ntmisc.c
# End Source File
# Begin Source File

SOURCE=.\res_comp.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_data.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_debug.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_init.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_mkquery.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_nt_misc.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_query.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\res_send.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\sethostent.c

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# ADD CPP /YX"stdafx.h"

!ENDIF 

# End Source File
# Begin Source File

SOURCE=.\StdAfx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# Begin Source File

SOURCE=.\writev.c
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\bitypes.h
# End Source File
# Begin Source File

SOURCE=.\cdefs.h
# End Source File
# Begin Source File

SOURCE=.\inet.h
# End Source File
# Begin Source File

SOURCE=.\log.h
# End Source File
# Begin Source File

SOURCE=.\messages.h
# End Source File
# Begin Source File

SOURCE=.\nameser.h
# End Source File
# Begin Source File

SOURCE=.\netdb.h
# End Source File
# Begin Source File

SOURCE=.\options.h
# End Source File
# Begin Source File

SOURCE=.\portability.h
# End Source File
# Begin Source File

SOURCE=.\resolv.h
# End Source File
# Begin Source File

SOURCE=.\StdAfx.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "*.rc;*.rc2;*.ico;*.mc"
# Begin Source File

SOURCE=.\messages.mc

!IF  "$(CFG)" == "DNSResolverLibrary - Win32 Release"

# Begin Custom Build - Building Event Log Messages
InputPath=.\messages.mc
InputName=messages

BuildCmds= \
	mc -v -w $(InputName)

"messages.h" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"messages.rc" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ELSEIF  "$(CFG)" == "DNSResolverLibrary - Win32 Debug"

# Begin Custom Build - Building Event Log Messages
InputPath=.\messages.mc
InputName=messages

BuildCmds= \
	mc -v -w $(InputName)

"messages.h" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"messages.rc" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ENDIF 

# End Source File
# End Group
# Begin Source File

SOURCE=.\Readme.txt
# End Source File
# End Target
# End Project
