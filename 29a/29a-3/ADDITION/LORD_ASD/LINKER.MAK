#
# Borland C++ IDE generated makefile
# Generated 26-Jul-97 at 20:08:30
#
.AUTODEPEND


#
# Borland C++ tools
#
IMPLIB  = Implib
BCC32   = Bcc32 +BccW32.cfg
BCC32I  = Bcc32i +BccW32.cfg
TLINK32 = TLink32
TLIB    = TLib
BRC32   = Brc32
TASM32  = Tasm32
#
# IDE macros
#


#
# Options
#
IDE_LinkFLAGS32 =  -L$(BCROOT)\LIB
IDE_ResFLAGS32 =
LinkerLocalOptsAtW32_winapp32dexe =  -LC:\LANG\BC\LIB -Tpe -aa -V4.0 -c -v
ResLocalOptsAtW32_winapp32dexe =
BLocalOptsAtW32_winapp32dexe =
CompInheritOptsAt_winapp32dexe = -IC:\LANG\BC\INCLUDE
LinkerInheritOptsAt_winapp32dexe = -x
LinkerOptsAt_winapp32dexe = $(LinkerLocalOptsAtW32_winapp32dexe)
ResOptsAt_winapp32dexe = $(ResLocalOptsAtW32_winapp32dexe)
BOptsAt_winapp32dexe = $(BLocalOptsAtW32_winapp32dexe)

#
# Dependency List
#
Dep_winapp32 = \
   winapp32.exe

winapp32 : BccW32.cfg $(Dep_winapp32)
  echo MakeNode

Dep_winapp32dexe = \
   winapp32.def\
   winapp32.obj\
   winapp32.res

winapp32.exe : $(Dep_winapp32dexe)
  $(TLINK32) @&&|
 /B:0x400000  /v $(IDE_LinkFLAGS32) $(LinkerOptsAt_winapp32dexe) $(LinkerInheritOptsAt_winapp32dexe) +
C:\LANG\BC\LIB\c0w32.obj+
winapp32.obj
$<,$*
C:\LANG\BC\LIB\import32.lib+
C:\LANG\BC\LIB\cw32.lib
winapp32.def
winapp32.res

|
Dep_winapp32dobj = \
   main.obj\
   misc.obj\
   diag.obj\
   winapp32.h\
   scanner.obj\
   winapp32.cpp

winapp32.obj : $(Dep_winapp32dobj)
  $(BCC32) -c @&&|
 $(CompOptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe) -o$@ winapp32.cpp
|

main.obj :  main.cpp
  $(BCC32) -c @&&|
 $(CompOptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe) -o$@ main.cpp
|

misc.obj :  misc.cpp
  $(BCC32) -c @&&|
 $(CompOptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe) -o$@ misc.cpp
|

diag.obj :  diag.cpp
  $(BCC32) -c @&&|
 $(CompOptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe) -o$@ diag.cpp
|

scanner.obj :  scanner.cpp
  $(BCC32) -c @&&|
 $(CompOptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe) -o$@ scanner.cpp
|

winapp32.res :  winapp32.rc
  $(BRC32) -R @&&|
 $(IDE_ResFLAGS32) $(ROptsAt_winapp32dexe) $(CompInheritOptsAt_winapp32dexe)  -FO$@ winapp32.rc
|
# Compiler configuration file
BccW32.cfg :
   Copy &&|
-R
-v
-vi
-H-
-3
-Od
-W
-w-
-d-
-ff-
-N
-Hc
-K
-f-
| $@


