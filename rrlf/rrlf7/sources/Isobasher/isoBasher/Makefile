################################################################################
# GNU Makefile generated by Visual-MinGW 0.56 alpha.
# File created on Wed, Oct 19 2005 by .
# More information: http://visual-mingw.sourceforge.net/


ifeq ($(DOS), 1)
 define FixPath
  $(subst /,\,$(1))
 endef
 RM=del
else
 define FixPath
  $(subst \,/,$(1))
 endef
 RM=rm -f
endif

# Suffixes
#
.SUFFIXES:
.SUFFIXES: .c .rc .o .res

# Directories
#
top_srcdir = .
VPATH = $(top_srcdir)/\


MWINDOWS = -mwindows

# Dependency generator
#
CPP = cpp
MAKEDEPEND = $(CPP) -MM $< -MT $@ -MP $(INCLUDES) $(CPPFLAGS)


# default configuration
ifeq ($(CFG),)
CFG=Release
endif

# Configuration 1, "Debug"
#
ifeq ($(CFG),Debug)
# directories
OBJDIR = $(top_srcdir)/
DEPDIR = $(OBJDIR)
# names of programs
ifndef WINE
CC = gcc
CPP = cpp
CXX = g++
RC = windres -O COFF --use-temp-file
else
CC = winegcc
CPP = winecpp
CXX = wineg++
RC = wrc
endif
AR = ar
ARFLAGS = -cru
RANLIB = ranlib
DLLWRAP = dllwrap
# compiler flags
INCLUDES = -I. -I$(top_srcdir)/C:/Dev-Cpp/include
RCINCLUDES = --include-dir=. --include-dir=$(top_srcdir)/C:/Dev-Cpp/include
SYMBOLS = -g
OPTIMIZE =
WARNINGS = -W -Wall
CPPFLAGS = 
CFLAGS = $(SYMBOLS) $(OPTIMIZE)
ALL_CFLAGS = $(WARNINGS)  $(CFLAGS)
ALL_CXXFLAGS = $(WARNINGS)  $(CFLAGS)
# linker flags
STRIP =
LIBDIRS =
LIBS = 
LDFLAGS = $(STRIP) $(MWINDOWS) 
# target
target = $(top_srcdir)/bin/isobasher_dbg.exe
configset = yes
endif


# Configuration 2, "Release"
#
ifeq ($(CFG),Release)
# directories
OBJDIR = $(top_srcdir)/
DEPDIR = $(OBJDIR)
# names of programs
ifndef WINE
CC = gcc
CPP = cpp
CXX = g++
RC = windres -O COFF --use-temp-file
else
CC = winegcc
CPP = winecpp
CXX = wineg++
RC = wrc
endif
AR = ar
ARFLAGS = -cru
RANLIB = ranlib
DLLWRAP = dllwrap
# compiler flags
INCLUDES = -I.
RCINCLUDES = --include-dir=.
SYMBOLS =
OPTIMIZE = -O1
WARNINGS = -W -Wall
CPPFLAGS = 
CFLAGS = $(SYMBOLS) $(OPTIMIZE)
ALL_CFLAGS = $(WARNINGS)  $(CFLAGS)
ALL_CXXFLAGS = $(WARNINGS)  $(CFLAGS)
# linker flags
STRIP =
LIBDIRS =
LIBS = -lnetapi32
LDFLAGS = $(STRIP) $(MWINDOWS) -s -file-alignment=0x80 -R
# target
target = $(top_srcdir)/bin/isobasher_rel.exe
configset = yes
endif


# error, no configuration found
ifeq ($(configset),)
$(error no configuration found, usage: make CFG="MyConfig")
endif

OBJECTS = \
	functions.o \
	isolib.o \
	main.o


# Explicit rules
#
COMPILE.c = $(CC) $(INCLUDES) $(CPPFLAGS) $(ALL_CFLAGS)
COMPILE.cxx = $(CXX) $(INCLUDES) $(CPPFLAGS) $(ALL_CXXFLAGS)
LINK.c = $(CC) $(CFLAGS) $(LDFLAGS) $(LIBDIRS) $^ -o $@
LINK.cxx = $(CXX) $(CFLAGS) $(LDFLAGS) $(LIBDIRS) $^ -o $@

$(OBJDIR)/%.o : %.c
	$(MAKEDEPEND) > $(call FixPath,$(DEPDIR)/$*.Po)
	$(COMPILE.c) -c $< -o $@

$(OBJDIR)/%.res : %.rc
	$(MAKEDEPEND) > $(call FixPath,$(DEPDIR)/$*.Pr)
	$(RC) $(RCINCLUDES) $(CPPFLAGS) $< $@


# Targets
#
all:	$(target)

clean:
	$(RM) $(call FixPath,$(DEPDIR)/*.Po)
	$(RM) $(call FixPath,$(DEPDIR)/*.Pr)
	$(RM) $(call FixPath,$(target))
	$(RM) $(call FixPath,$(OBJDIR)/*.o)
	$(RM) $(call FixPath,$(OBJDIR)/*.res)

$(target): $(addprefix $(OBJDIR)/, $(OBJECTS))
	$(LINK.c) $(LIBS)


# Automatic Dependencies
#
-include $(DEPDIR)/functions.Po
-include $(DEPDIR)/isolib.Po
-include $(DEPDIR)/main.Po


