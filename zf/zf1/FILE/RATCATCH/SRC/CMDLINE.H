/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// CmdLine : helper class for working with command line
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#ifndef _CMDLINE_H_
#define _CMDLINE_H_

#include "stypes.h"

class CommandLine
{
    char     m_strSwitches[ 512 ];

    int      m_nArgs;
    LPCTSTR  m_strArgs    [ 64  ];

public:
    CommandLine( int argc, char* argv[] );
    CommandLine( LPCTSTR lpszLine );
    ~CommandLine() {}

    BOOL  IsEmpty(); // no switches
    BOOL  IsSwitch( char* option ); // if the switch present
    char* GetSwitchValue( char* option ); // get the value
    // e.g. for /P:file.log the value is ':file.log'

    int     GetArgQuantity();
    LPCTSTR GetArg( int argn );
};

#endif // _CMDLINE_H_
