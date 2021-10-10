/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// RatCatch : the skeleton for a simple antivirus scanner
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <io.h>
//#include <dos.h>
//#include <sys/stat.h>

#include "RatCatch.h"

#include "cmdline.h"

#include "SysDOS.h"
#include "Memory.h"
#include "VScanner.h"

void ShowHelp()
{
    cprintf(
 " ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±º RatCatcher ş Version 1.0 beta  º°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±º ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ  º°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±º ş August'97 ş 1 virus ş :-) ş  º°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±º      (c) 1997 by ReCoder       º°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±±±°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 " ±±RatCatcher - the antivirus. Written for the Antivirus Contest at August'97±±\r\n"
 " ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±\r\n"
 "\r\n"
 " Usage : RatCatch path [path2 [path3...]] [/switch1 [/switch2...]]\r\n"
 " Available switches:\r\n"
 "\r\n"
 "    /A - test all files\r\n"
 "    /F - cure infected\r\n"
 "    /D - delete dead files\r\n"
 "    /M - no memory test\r\n"
 "    /$ - show healthy files\r\n"
 "\r\n"
    );
}

int main ( int argc, char * argv [] )
{
// Collect command line information
    CommandLine cmdline( argc, argv );

    if( cmdline.IsEmpty() || cmdline.IsSwitch( "/?" ) )
    { // No switches - just show help and quit
        ShowHelp();
        return 0;
    }

    printf( "ş RatCatcher ş Version 1.0 beta ş (c) 1997 by ReCoder ş August'97 ş\n\n" );

    // Gather switch settings
    BOOL bCure      = cmdline.IsSwitch( "/F" );
    BOOL bDelete    = cmdline.IsSwitch( "/D" );
    BOOL bAllFiles  = cmdline.IsSwitch( "/A" );
    BOOL bShowAll   = cmdline.IsSwitch( "/$" );
    BOOL bNoBoot    = cmdline.IsSwitch( "/B" );
    BOOL bNoMemory  = cmdline.IsSwitch( "/M" );
    BOOL bVerbose   = cmdline.IsSwitch( "/V" );
    BOOL bLoadCyr   = cmdline.IsSwitch( "/1" );
    BOOL bHeuristic = cmdline.IsSwitch( "/H" );

    // Gather system information
    // TODO : ...

    // Check memory
    MemoryScanner m;

    if( ! bNoMemory )
    {
        if( m.Scan() != 0 )
        {
            return -1;
        }
    }

    // Check disk content
    VirusScanner s;

    // Set switches
    s.SetAllFiles  ( bAllFiles  );
    s.SetCure      ( bCure      );
    s.SetHeuristic ( bHeuristic );
    s.SetShowOK    ( bShowAll );

    // Do the scan
    for( int nmask = 0; nmask < cmdline.GetArgQuantity(); nmask++ )
    { // iterate through given paths
        char strWhere[ MAXPATH ];
        strcpy( strWhere, cmdline.GetArg( nmask ) );

        if( !strcmp( strWhere, "*:" ) )
        { // all drives mask '*:'
            TRACE( "Scanning all drives...\n" );
            s.ScanAllDrives ();
        }
        else if( strWhere[ 1 ] == ':' && strWhere[ 2 ] == '\0' )
        { // one drive mask ('C:','D:',etc.)
            TRACE( "Scanning drive...\n" );
            s.ScanDrive( strWhere );
        }
        else if( access( strWhere, 0x6 ) == -1 )
        { // other masks ('C:\*.exe', 'F:\UTILS\*.*', 'C???.*', etc.)
            TRACE( "Scanning mask...\n" );
            s.ScanUsingMask( strWhere );
        }
        else if( !IsFile( strWhere ) )
        { // one directory ('C:\WIN95\COMMAND', 'E:\', etc.);
            TRACE( "Scanning directory...\n" );
            s.ScanDirectory( strWhere );
        }
        else
        { // just one file ('C:\COMMAND.COM', 'G:\DOOM2\SERSETUP.EXE', etc.)
            TRACE( "Scanning one file...\n" );
            s.ScanOneFile( strWhere );
        }
    }

    s.ReportFinalStatistics ();

    if( s.VirusesFound() )
    {
        return exitViruses;
    }

    return 0;
}
