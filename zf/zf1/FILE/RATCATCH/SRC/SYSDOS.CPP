/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// SysDos : access to system DOS areas and structures
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <dos.h>
#include <io.h>
#include <fcntl.h>

#include "stypes.h"
#include "sysdos.h"

CVTPTR CVT::GetCVT () {
    union  REGS  regs;
    struct SREGS sregs;

    regs.h.ah = 0x52;
    intdosx( &regs, &regs, &sregs );
    CVTPTR p = (CVTPTR) MK_FP (sregs.es,regs.x.bx - 2);
    return p;
}

BOOL IsFile( LPCTSTR lpszFileName )
{
    int h = _open( lpszFileName, O_RDONLY );

    if( h == -1 )
        return FALSE;

    _close( h );

    return TRUE;
}

long EXEHDR::GetEntryPoint()
{
    return ( ( (DWORD) cs_reg   ) << 4 + (DWORD) ip_reg ) & 0xFFFFF +
           (   (DWORD) hdr_size ) << 4;
}
