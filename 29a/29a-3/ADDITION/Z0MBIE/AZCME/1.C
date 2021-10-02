
//  Advanced ZCME
//  Permutating Engine Research

//  Copyright (C) 1997, 1998 Z0MBiE/29A
//
//  *** NOT FOR [RE]PUBLISHING/DISASM IN VX-ZINES, EXCEPT 29A ***

//  Internal version: 0.04
//  Last modified: 18-07-98

#include "params.h"

char ZERO_FILL_ARRAY[max_size-0x1300] = {0};

#include "system.h"
#include "crt.h"
#include "fileio.h"
#include "random.h"

#include "disasm.h"
#include "engine.h"

void main(void)
  {
    pchar p;

    #ifdef SKIP_PRINTF
    asm
__1:    lea     di, printf
        mov     al, 0xC3
        stosb
        lea     di, __1
        mov     cx, __2 - __1
        mov     al, 0x90
        rep     stosb
    end;
    #endif

    clrscr(3);
    asm
__2:end;

    printf("Startup code executed\n");

    run_engine();

    printf("Terminating\n");

    exit(0);
  }


