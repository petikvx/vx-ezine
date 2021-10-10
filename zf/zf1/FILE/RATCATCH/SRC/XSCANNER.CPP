/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// XScanner : file scanner with extra capabilities
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <io.h>

#include "XScanner.h"

BOOL ExtendedScanner::Match( LPCTSTR lpszFilePath ) { return TRUE; }
BOOL ExtendedScanner::Match( int nDriveNo         ) { return TRUE; }

void ExtendedScanner::ProcessFile( LPCTSTR fileName )
{
    if( Match( fileName ) )
    {
        FileFound( fileName );
    }
}

void ExtendedScanner::ProcessDrive( int driveNo )
{
    if( Match( driveNo ) )
    {
        DriveFound( driveNo );
    }
}

