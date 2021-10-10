
/**
***
**/

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <io.h>

#include "mz.hpp"
#include "pe.hpp"

#ifdef _MSC_VER
#  define bzero(ptr, size) memset((ptr), 0, (size))
#endif /* _MSC_VER */

#ifdef _MSC_VER
#  pragma warning(push)
#  pragma warning(disable: 4003) // not enough actual parameters for macro 'GET_PREFIX'
#endif /* _MSC_VER */

#include "yad.h"
#include "yad.c"

#ifdef _MSC_VER
#pragma warning(pop)
#endif /* _MSC_VER */

#ifdef LOGGING
#  define log printf
#else
#  define log
#endif /* LOGGING */

#define IMAGE_SIZEOF_SHORT_NAME	8
typedef struct _IMAGE_SECTION_HEADER {
	uint8_t	Name[IMAGE_SIZEOF_SHORT_NAME];
	union {
		uint32_t	PhysicalAddress;
		uint32_t	VirtualSize;
	} Misc;
	uint32_t	VirtualAddress;
	uint32_t	SizeOfRawData;
	uint32_t	PointerToRawData;
	uint32_t	PointerToRelocations;
	uint32_t	PointerToLinenumbers;
	uint16_t	NumberOfRelocations;
	uint16_t	NumberOfLinenumbers;
	uint32_t	Characteristics;
} IMAGE_SECTION_HEADER;

uint32_t rva_to_offset(PE_HEADER *pe, uint32_t rva)
{
	int i;
	IMAGE_SECTION_HEADER *shdr = (IMAGE_SECTION_HEADER*)((char*)pe + sizeof(PE_HEADER));
	for (i = 0; i < pe->pe_numofobjects; i++) {
		if (rva >= shdr[i].VirtualAddress && rva < shdr[i].VirtualAddress + shdr[i].Misc.VirtualSize)
			return rva - shdr[i].VirtualAddress + shdr[i].PointerToRawData;
	}
	return 0;
}

void process_buffer(uint8_t *buffer) {
  MZ_HEADER *mz;
  PE_HEADER *pe;
  uint8_t *opcode;
  yad_t diza;
  int retval, i;

  mz = (MZ_HEADER*)buffer;
  //assert(mz->mz_id == MZ_ID);
  if (mz->mz_id != MZ_ID) return; /* skip old formats */
  if (mz->mz_neptr == 0) return; /* skip ms-dos, ne-files */
  pe = (PE_HEADER*)&buffer[mz->mz_neptr];
  assert(pe->pe_id == PE_ID);

  if (pe->pe_entrypointrva == 0) return;
  log("  \xfe EP: %08X\n", pe->pe_entrypointrva);
  printf("%d %d\n", pe->pe_ntheadersize + 0x18, sizeof(PE_HEADER));
  opcode = (char*)buffer + rva_to_offset(pe, pe->pe_entrypointrva);
  for (retval = 0;;) {
    retval = yad(opcode, &diza);
    if (retval == 0) {
      printf("  \xfe abort at %p\n", opcode);
      printf("  \xfe bytes: %02X %02X %02X %02X %02X %02X %02X %02X\n\n", 
        *(opcode + 0), *(opcode + 1), *(opcode + 2), *(opcode + 3), 
        *(opcode + 4), *(opcode + 5), *(opcode + 6), *(opcode + 7));
      break;
    }
#ifdef LOGGING
    log(("  \xfe "));
    for (i = 0; i < retval; ++i) {
      log("%02X ", *(opcode + i));
    }
    log(("\n"));
#endif /* LOGGING */
    if (diza.opcode == 0xc3 || diza.opcode == 0xc2) { /* ret/retn */
      break;
    }
    opcode += retval;
    if (opcode > (buffer + pe->pe_imagesize - 16)) break;
  }
}

void process_file(const char *fname) {
  FILE *fp;
  printf("\xfe processing '%s'... \n", fname);
  fp = fopen(fname, "rb");
  if (fp != NULL) {  
    uint8_t *buffer;
    size_t filelen;
    filelen = filelength(fileno(fp));
    buffer = (uint8_t *)malloc(filelen); 
    if (buffer != NULL) {  
      fread(buffer, 1, filelen, fp);
      process_buffer(buffer);
      free(buffer);
    }
    fclose(fp);
  }
}

void process_dir(const char *dir, char **fmask, size_t count) {
  intptr_t fh;
  char path[260];
  struct _finddata_t wfd;

  _snprintf(path, sizeof(path), "%s\\*.*", dir);
  memset(&wfd, 0, sizeof(wfd));
  fh = _findfirst(path, &wfd);
  if (fh > 0) {
    do {
      if (wfd.attrib & _A_SUBDIR) {
        if (strcmp(wfd.name, ".") && strcmp(wfd.name, "..")) {
          _snprintf(path, sizeof(path), "%s\\%s", dir, wfd.name);
          process_dir(path, fmask, count);
        }
      } else {
        const char *p = &wfd.name[strlen(wfd.name) - 1];
        for (; p > wfd.name && *p != '.'; --p) ;
        if (p > wfd.name && *p == '.') {
          size_t i = 0;
          for (; i < count; ++i) {
            if (!stricmp(p, fmask[i])) {
              _snprintf(path, sizeof(path), "%s\\%s", dir, wfd.name);
              process_file(path);
              break;
            }
          }
        }
      }
    } while (!_findnext(fh, &wfd));
    _findclose(fh);
  }
}

int main(int argc, char **argv) {
  char *fmask[] = { ".exe", ".dll", ".drv", ".sys" };
  process_file(argv[1]);
//  process_dir("C:\\WINDOWS\\system32", fmask, sizeof(fmask) / sizeof(fmask[0]));
  return EXIT_SUCCESS;
}

/* [EOF] */
