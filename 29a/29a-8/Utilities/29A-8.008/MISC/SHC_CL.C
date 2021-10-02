
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <assert.h>
#pragma hdrstop

#include "../ENGINE/shge.h"
#include "../ENGINE/prof.h"

int main(int argc, char* argv[])
{
  struct SHGE_OPTIONS opt;
  int shge_res;
  FILE*f;
  static char out_bin[262144];
  static char out_src[262144];
  static char out_hpp[262144];
  static char out_struct[262144];
  char* fn_profile;
  char* outf;
  char fn_bin[1024];
  char fn_src[1024];
  char fn_hpp[1024];
  char fn_struct[1024];

  printf("win32 Shellcode Constructor (engine version %s) cmdline interface\n", get_version());

  if (argc != 3)
  {
    printf("syntax:\n");
    printf("  shc_cl <infile.shp> <outfile>\n");
    printf("    # 1. read shellcode profile from file infile.shp,\n");
    printf("    # 2. generate outfile.bin, outfile.asm, outfile.hpp\n");
    exit(0);
  }

  fn_profile = argv[1];
  outf       = argv[2];

  printf("+ loading profile: %s\n", fn_profile);

  if (load_profile(&opt, fn_profile) == 0)
  {
    printf("ERROR: cant load profile: %s\n", fn_profile);
    exit(0);
  }

  opt.out_bin                 = out_bin;
  opt.out_bin_maxsize         = sizeof(out_bin);
  opt.out_src                 = out_src;
  opt.out_src_maxsize         = sizeof(out_src);
  opt.out_hpp                 = out_hpp;
  opt.out_hpp_maxsize         = sizeof(out_hpp);
  opt.out_struct              = out_struct;
  opt.out_struct_maxsize      = sizeof(out_struct);

  printf("+ generating shellcode\n");

  shge_res = shge(&opt, sizeof(opt));

  if (shge_res != SHGE_RES_OK)
  {
    printf("ERROR: shce() error '%s'\n", get_error(shge_res));
    exit(0);
  }

  sprintf(fn_bin, "%s.bin", outf);
  sprintf(fn_src, "%s.asm", outf);
  sprintf(fn_hpp, "%s.hpp", outf);
  sprintf(fn_struct, "%s.txt", outf);

  printf("+ writing binary: %s, %d bytes\n", fn_bin, opt.out_bin_size);

  f=fopen(fn_bin,"wb");
  if (f==NULL)
  {
    printf("ERROR: cant write file: %s\n", fn_bin);
    exit(0);
  }
  fwrite(opt.out_bin, 1,opt.out_bin_size, f);
  fclose(f);

  printf("+ writing source: %s, %d bytes\n", fn_src, opt.out_src_size);

  f=fopen(fn_src,"wb");
  if (f==NULL)
  {
    printf("ERROR: cant write file: %s\n", fn_src);
    exit(0);
  }
  fwrite(opt.out_src, 1,opt.out_src_size, f);
  fclose(f);

  printf("+ writing hpp: %s, %d bytes\n", fn_hpp, opt.out_hpp_size);

  f=fopen(fn_hpp,"wb");
  if (f==NULL)
  {
    printf("ERROR: cant write file: %s\n", fn_hpp);
    exit(0);
  }
  fwrite(opt.out_hpp, 1,opt.out_hpp_size, f);
  fclose(f);

  printf("+ writing structure: %s, %d bytes\n", fn_struct, opt.out_struct_size);

  f=fopen(fn_struct,"wb");
  if (f==NULL)
  {
    printf("ERROR: cant write file: %s\n", fn_struct);
    exit(0);
  }
  fwrite(opt.out_struct, 1,opt.out_struct_size, f);
  fclose(f);

  printf("All OK\n");

} /* main */

/* EOF */
