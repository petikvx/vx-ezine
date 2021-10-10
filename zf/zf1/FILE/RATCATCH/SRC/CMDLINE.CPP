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

#include "string.h"

#include "cmdline.h"

CommandLine::CommandLine( int argc, char* argv[] )
{
    m_strSwitches[ 0 ] = '\0' ;
    m_nArgs            = 0;

    for( int i = 1; i < argc; i ++ )
    {
        if( argv[ i ][ 0 ] != '\/' )
        {
            m_strArgs[ m_nArgs++ ] = argv[ i ];
        }
        else
        {
            strcat( m_strSwitches, argv[ i ] );
            strcat( m_strSwitches, " " );
        }
    }
    strupr( m_strSwitches ); // switches are case-insensitive
}

CommandLine::CommandLine( LPCTSTR lpszLine )
{
    for(;;);
}

BOOL CommandLine::IsEmpty()
{
    return ( m_strSwitches[ 0 ] == '\0' && m_nArgs == 0 );
}

BOOL CommandLine::IsSwitch( char* option )
{
    return ( strstr( m_strSwitches, option ) != NULL );
}

char* CommandLine::GetSwitchValue( char* option )
{
    char* pPtr = strstr( m_strSwitches, option );

    if( pPtr )
    {
        pPtr += strlen( option );
    }

    return pPtr;
}

int CommandLine::GetArgQuantity()
{
    return m_nArgs;
}

LPCTSTR CommandLine::GetArg( int argn )
{
    return m_strArgs[ argn ];
}
