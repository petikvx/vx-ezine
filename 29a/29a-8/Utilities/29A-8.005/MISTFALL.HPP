
#ifndef __MISTFALL_HPP__
#define __MISTFALL_HPP__

#include "hooy.hpp"

#include "./COMMON/mz.hpp"               // MZ header
#include "./COMMON/pe.hpp"               // PE header

#define MISTFALL_VERSION        "2.00"

// input file parameters
#define MF_PHYSFILE_MIN_SIZE    1024
#define MF_PHYSFILE_MAX_SIZE    16777216
#define MF_PE_MAXSECTIONS       12
#define MF_PE_MAXIMAGESIZE      16777216

// exit codes
#define MF_ERR_SUCCESS          0
#define MF_ERR_NOMEMORY         1
#define MF_ERR_CANTOPENFILE     2
#define MF_ERR_BADFILESIZE      3
#define MF_ERR_BADMZHDR         4
#define MF_ERR_BADPEHDR         5
#define MF_ERR_NOFIXUPS         6
#define MF_ERR_BADNSECT         7
#define MF_ERR_BADSECTNAME      8
#define MF_ERR_BADOVRSIZE       9
#define MF_ERR_BADIMAGESIZE     10
#define MF_ERR_BADOBJTABLE      11
#define MF_ERR_DISASM           12
#define MF_ERR_CANTEXPAND       13
#define MF_ERR_CANTCREATEFILE   14
#define MF_ERR_NOTASSEMBLED     15
#define MF_ERR_INTERNAL1        16
#define MF_ERR_INTERNAL2        17
#define MF_ERR_BADFIXUPS        18
#define MF_ERR_CANT_REASSEMBLE  19

// Disasm() flags
#define DF_FIXUPSREQUIRED       0x00000001 // fixups required. MF_ERR_NOFIXUPS
#define DF_STDSECT              0x00000002 // standard section names only
#define DF_CODEFIRST            0x00000004 // code in first section only
#define DF_DISABLEDISASM        0x00000008 // { do not disasm opcodes
#define DF_TRY_DREF             0x00000010 //   analyze data-references
#define DF_TRY_RELREF           0x00000020 //   analyze relative references
#define DF_ENABLE_ERRDISASM     0x00000040 // } quit on disasm-error

#define NONE                    0xFFFFFFFF
#define memw                    *(WORD*)&memb
#define memd                    *(DWORD*)&memb
#define ALIGN(x,y)              (((x)+(y)-1)&(~((y)-1)))
#define MIN(x,y)                ((x)<(y)?(x):(y))
#define MAX(x,y)                ((x)>(y)?(x):(y))

// main class

class CMistfall
{
  public:
  DWORD error_count;   // if (error_count == 0) can patch || build
  DWORD can_patch;     // if (can_patch) can patch
  CHooyList HooyList;
  //
  //
  DWORD i_phys_len;           // } input file, also PE/MZ/OE/overlay is here
  BYTE* i_phys_mem;           // }
  //
  DWORD o_phys_len;           // } resulting stuff, the whole file.
  BYTE* o_phys_mem;           // }
  //
  BYTE*        edit_header;   // } This used to edit MZ/PE/OE at once,
  MZ_HEADER*   edit_mz;       // } while mutate.
  PE_HEADER*   edit_pe;       // } I.e. now there is no need to search
  PE_OBJENTRY* edit_oe;       // } within list for PE/OE entries.
  MZ_HEADER* mz;       // }
  PE_HEADER* pe;       // } ptrs to i_phys_mem, edited ONCE when aligning
  PE_OBJENTRY* oe;     // } section sizes, then read-only
  DWORD ovr_offs;             // }
  DWORD ovr_size;             // } ptr to i_phys_mem
  BYTE* memb;          // }
  DWORD* flag;         // } used while Disasm()
  DWORD* arg1;         // }
  DWORD* arg2;         // }
  HOOY** fasthooy;     // used while Asm() to faster assembly
  //
  CMistfall();
  ~CMistfall();
  //
  // ---MAIN METHODS---
  int LoadFile(char* fname);  // 1. load file into memory
  int Disasm(DWORD dflags);   // 2. disassemble file into HOOY* list  DF_XXX
  int Asm(int full);          // 3. assemble file, full: 0=patch, 1=rebuild
  int SaveFile(char* fname);  // 4. save modified file to disk
  void DumpLog(char* logfile);// dump temporary stuff
  // other stuff
  void process_import(DWORD addr);
  void process_rsrc(DWORD addr);
  void markrva(DWORD x);
  void markrvadata(DWORD x);
  void markfixup(DWORD x);
  void markdelta(DWORD x,DWORD y,DWORD z);
  HOOY* hooybyoldrva(DWORD oldrva, DWORD needflags);
  DWORD calc_pe_csum(BYTE* buf, DWORD size);
  //
}; // class CMistfall

#endif // __MISTFALL_HPP__
