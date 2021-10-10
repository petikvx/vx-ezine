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

#ifndef _MEMORY_SCAN_
#define _MEMORY_SCAN_

#include "stypes.h"

class MemoryScanner
{
    BOOL    m_bHeuristic;
public:
    MemoryScanner  ( );
    ~MemoryScanner ( );

// Attributes

    void SetHeuristic ( BOOL bSet = TRUE ) { m_bHeuristic = bSet; }

// Operations

    int Scan(); // 0 = may continue, -1 = abort

    virtual int  Test      ();
    virtual int  Cure      ( int code );
    virtual void Heuristic ();

    void ReportVirus( int nCode );
};

#endif // _MEMORY_SCAN_