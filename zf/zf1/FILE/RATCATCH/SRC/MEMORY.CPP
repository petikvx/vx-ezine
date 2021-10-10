/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// Memory : memory scanner
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <mem.h>
#include <dos.h>
#include <conio.h>

#include "Memory.h"

MemoryScanner::MemoryScanner () :
    m_bHeuristic ( FALSE )
{

}

MemoryScanner::~MemoryScanner ()
{

}

int MemoryScanner::Scan()
{
    cprintf( "Checking memory..." );

    int nCode = Test();
    BOOL bClean = ( nCode == 0 );

    if( ! bClean )
    {
        ReportVirus( nCode );

        do
        {
            if( ! Cure( nCode ) )
            {
                nCode = 0;
                break;
            }
            nCode = Test();
        }
        while( nCode );
    }

    if( m_bHeuristic )
    {
        Heuristic();
    }

    if( bClean )
    {
        cprintf( " ok." );
    }
    cprintf( "\r\n" );

    return nCode;
}

BYTE* pSign = "\x80\xFC\x4B\x74\x03\xE9\xDD\x00\x60\x1E";

int MemoryScanner::Test ()
{
    BYTE far* pS = MK_FP( 0x0, 0x0 );

    if( ! memcmp( pS + 0x206, pSign, 10 ) )
    {
        return 1;
    }

    return 0;
}

int MemoryScanner::Cure ( int code )
{
    BYTE far* pS = MK_FP( 0x0, 0x0 );

// replacing
//    cmp ah, 4Bh
//    je  infect
//    jmp orginal_int21h
// with
//    nop
//    nop
//    nop
//    nop
//    nop
//    jmp orginal_int21h

    memset( pS + 0x206, 0x90, 5 ); // 5 nops

    cprintf( " cured." );
}

void MemoryScanner::Heuristic ()
{
}

void MemoryScanner::ReportVirus( int nCode )
{
    cprintf( " %s ", "[Suburbs/SLAM]" );
}
