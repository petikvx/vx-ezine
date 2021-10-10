/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#ifndef STYPES_H
#define STYPES_H

enum
{
    FALSE   = 0,
    TRUE    = 1
};

typedef int             BOOL;
typedef far char*       LPCTSTR;

typedef char            BYTE;
typedef int             WORD;
typedef long            DWORD;

#define DELETE( p )     ( delete p, p = 0 )

// Java-like defines

#define interface       class
#define implements      public

#ifdef _DEBUG
    #define TRACE  printf
#else
    #define TRACE  _debug
#endif

inline void _debug(...) {}

#endif  // STYPES_H

