/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// VScanner : the pattern virus scanner
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <io.h>
#include <dos.h>
#include <fcntl.h>

#include "VScanner.h"

typedef char TExt3 [ 3 ];

TExt3 StdExt [] =
{
    "EXE",
    "COM",
    "OVL",
    "OVR",
    "SYS",
    "DRV",
    "BIN",
};

TExt3 ExtExt [] =
{
    "386",
    "BAT",
};

TExt3 NonStdExt [] =
{
    "DOC",
    "DOT",
};

TExt3 ArchivesExt [] =
{
    "ZIP",
    "ARJ",
    "RAR",
};

//////////////////////////////////////////////////////////////////////
//  Class  'VirusScanner'

VirusScanner::VirusScanner () :
    ExtendedScanner(),
    m_bAllFiles  ( FALSE ),
    m_bCure      ( FALSE ),
    m_bHeuristic ( FALSE ),
    m_bShowOK    ( FALSE )
{
}

VirusScanner::~VirusScanner ()
{
}

BOOL VirusScanner::Match( LPCTSTR lpszFilePath )
{
    if( m_bAllFiles ) return TRUE;

    int exts = sizeof( StdExt ) / sizeof( TExt3 );
    for( int i = 0; i < exts; i ++ )
    {
//        printf( "%c%c%c - %d", StdExt[ i ][0],StdExt[ i ][1],StdExt[ i ][2], i );
        if( ! memcmp( m_Extension, StdExt[ i ], 3 ) )
            return TRUE;
    }

    return FALSE;
}

BOOL VirusScanner::Match( int nDriveNo )
{
    return TRUE;
}

void VirusScanner::FileFound( LPCTSTR fileName )
{
    PrintFileName( fileName );
    m_Currents.nFiles ++;

    int leave = Test( fileName, fileName );
    if( leave )
    {
        cprintf( "\n\r" );
    }
    else
    {
        cprintf( "\r" ); clreol ();
    }
}

void VirusScanner::PrintFileName( LPCTSTR fileName )
{
    int len = strlen( fileName );

    if( len < 36 )
    {
        cprintf( fileName );
        return;
    }

    char newName[ MAXPATH ];

    strcpy( newName, fileName );
    newName [ 3 ] = 0;
    strcat( newName, "..." );
    strcat( newName, fileName + len - 30 );

    cprintf( newName );
}

void VirusScanner::Report()
{
    ReportStatistics ();
    ResetStatistics  ();
}

int VirusScanner::Test( LPCTSTR fileName, LPCTSTR displayName )
{
    FileTest test;
    int      leave = 0;

    if( test.Open( fileName ) )
    {

        int nCode = Test( test );
        BOOL bHealthy = ( nCode == 0 );
        leave = nCode;

        if( ! bHealthy )
        {
            ReportVirus( nCode );
            m_Currents.nInfected ++;

            if( m_bCure )
            {
                if( test.Reopen() )
                {
                    do
                    {
                        if( ! Cure( test, nCode ) )
                        {
                            nCode = 0;
                            break;
                        }
                        test.ReadPages();
                        nCode = Test( test );
                    }
                    while( nCode );
                }
                else
                {
                    cprintf( " can't open for writing" );
                }
            }
            if( nCode )
            {
                cprintf( " !" );
            }
            else
            {
                m_Currents.nCured ++;
            }
        }
        else
        {
            if( m_bShowOK )
            {
                cprintf( " - ok" );
                leave = -1;
            }
        }

        if( m_bHeuristic )
        {
            Heuristic( test );
        }
/*
        int pack = IsPacked( test );
        if( pack )
        {
            CheckPacked( fileName, pack );
        }
*/
        test.Close();
    }
    else
    {
        cprintf( "- error opening..." );
        leave = -1;
    }
    return leave;
}

void VirusScanner::DriveFound( int driveNo )
{
    cprintf( "*** Drive : %c\n", '@' + driveNo );
}

BYTE sign[] = "\xB8\x02\x3D\xCD\x21\x93\xB8\x20\x00";

int VirusScanner::Test( FileTest& t )
{
    BYTE* s = t.PageEntry.GetBuffer()+0x20;

    if( t.m_Entry != FileTest::entJMP ) return 0;

    if( ! memcmp( s, sign, 9 ) )
    {
        return 1;
    }

    return 0;
}

void VirusScanner::ReportVirus( int nCode )
{
    cprintf( " infected by %s", "[Suburbs/SLAM]" );
}

int VirusScanner::Cure( FileTest& t, int code )
{
//    cprintf( " - can't cure" );
    BYTE SavedBytes [ 3 ];

    if( ! t.ReadAt( t.m_dwEntry + 0x174, SavedBytes, 3 ) )
    {
        cprintf( " - can't cure" );
        return 0;
    }

    SavedBytes[ 0 ] ^= '\x21';
    SavedBytes[ 1 ] ^= '\x85';
    SavedBytes[ 2 ] ^= '\x2D';

    if( ! t.WriteAt( 0, SavedBytes, 3 ) )
    {
        cprintf( " - can't cure" );
        return 0;
    }

    t.CutAtEnd( 0x189 );

    cprintf( " cured" );
    return 0xFFFF;
}

void VirusScanner::Heuristic( FileTest& t )
{
    int nConfidence = 0;
/*
    for( int i = 0; i < max_heur; i++ )
    {
        int nChance = TestHeuristic( i );

        nConfidence = ...;
    }

    if( nConfidence > m_nHeurTreshold )
    {
        printf( " possibly infected, chance is %d%%\n" );
    }
*/
    return;
}

void VirusScanner::ResetAttributes( FileTest& t )
{
    _dos_setftime( t.m_nHandle, m_wDate, m_wTime );
    _dos_setfileattr( m_FilePath, m_nAttrib );
}

//////////////////////////////////////////////////////////////////////
//  Class  'FileTest'

VirusScanner::FileTest::FileTest ()
{
    m_nHandle = -1;
    m_pExeHdr = NULL;
}

BOOL VirusScanner::FileTest::Open( LPCTSTR fileName )
{
    m_pFileName = fileName;
    m_nHandle   = _open( m_pFileName, O_RDONLY );
    if( m_nHandle == -1 )
        return FALSE;

    ReadPages();

    return TRUE;
}

BOOL VirusScanner::FileTest::Reopen()
{
    _close( m_nHandle );

    _dos_setfileattr( m_pFileName, 0 );

    m_nHandle   = _open( m_pFileName, O_RDWR );
    if( m_nHandle == -1 )
    {
        Open( m_pFileName );
        return FALSE;
    }

    return TRUE;
}

BOOL VirusScanner::FileTest::Close()
{
    if( ! _close( m_nHandle ) )
    {
        m_nHandle = -1;
    }

    return( m_nHandle == -1 );
}

BOOL VirusScanner::FileTest::ReadAt( DWORD pos, BYTE* buf, WORD len )
{
    if( lseek( m_nHandle, pos, 0 ) == -1 )
        return FALSE;
    if( _read( m_nHandle, buf, len ) != len )
        return FALSE;

    return TRUE;
}

BOOL VirusScanner::FileTest::WriteAt( DWORD pos, BYTE* buf, WORD len )
{
    if( lseek( m_nHandle, pos, 0 ) == -1 )
        return FALSE;
    if( _write( m_nHandle, buf, len ) != len )
        return FALSE;

    return TRUE;
}

BOOL VirusScanner::FileTest::CutAtEnd( DWORD pos )
{
    DWORD dwPos = lseek( m_nHandle, -pos, 2 );
    if( dwPos == -1 )
        return FALSE;

    if( chsize( m_nHandle, dwPos ) != 0 )
        return FALSE;

    return TRUE;
}

void VirusScanner::FileTest::ReadPages()
{
    lseek( m_nHandle, 0, 0 );
    PageStart.Read( m_nHandle );

// check if it's EXE file
    WORD mz = *( ( WORD* ) PageStart.GetBuffer() );
    if( mz == 'MZ' || mz == 'ZM' )
    {
        m_pExeHdr = (EXEHDRPTR) PageStart.GetBuffer();
        TRACE( "<EXE>" );
    }
// read entry page
    m_Entry = entPlain; // means Entry page == Start page
    m_dwEntry = 0;
    if( IsExe() )
    {
        m_dwEntry = m_pExeHdr->GetEntryPoint();
        m_Entry = entEXE;
    }
    else
    {
        if( * PageStart.GetBuffer() == '\xE8' ||
            * PageStart.GetBuffer() == '\xE9' )
        {
            m_dwEntry = PageStart.GetWordAt( 1 ) + 3;
            m_Entry = entJMP;
            TRACE( "<JMP>" );
        }
        else if( PageStart.GetByteAt( 4 )        == '\xC3' ||
                 PageStart.GetByteAt( 4 ) & 0xF0 == '\x50' )
        {
            m_dwEntry = (DWORD)PageStart.GetByteAt( 2 ) << 8 +
                               PageStart.GetByteAt( 1 ) - 0x100;
            m_Entry = entRET;
            TRACE( "<RET>" );
        }
        else if( PageStart.GetDwordAt( 0 ) == 0xFFFFFFFF )
        {
            m_Entry = entSYS;
            TRACE( "<SYS>" );
        }

    }
    if( m_dwEntry )
    {
        lseek( m_nHandle, m_dwEntry, 0 );
        PageEntry.Read( m_nHandle );
    }
}

void VirusScanner::ResetStatistics ()
{
    m_Totals += m_Currents;
    m_Currents.reset();
}

void VirusScanner::ReportStatistics ()
{
    m_Currents.output();
}

void VirusScanner::ReportFinalStatistics ()
{
    ResetStatistics ();
    m_Totals.output();
}

//////////////////////////////////////////////////////////////////////
//  Class  'info'

void VirusScanner::info::info() :
    nFiles          ( 0 ),
    nInfected       ( 0 ),
    nDamaged        ( 0 ),
    nBoot           ( 0 ),
    nInfectedBoot   ( 0 ),
    nCured          ( 0 ),
    nDeleted        ( 0 ),
    nSuspicious     ( 0 )
{
}

void VirusScanner::info::reset()
{
    nFiles          = 0 ;
    nInfected       = 0 ;
    nDamaged        = 0 ;
    nBoot           = 0 ;
    nInfectedBoot   = 0 ;
    nCured          = 0 ;
    nDeleted        = 0 ;
    nSuspicious     = 0 ;
}

VirusScanner::info& VirusScanner::info::operator +=( const VirusScanner::info& i )
{
    nFiles      +=  i.nFiles      ;
    nInfected   +=  i.nInfected   ;
    nDamaged    +=  i.nDamaged    ;
    nBoot       +=  i.nBoot       ;
    nInfectedBoot += i.nInfectedBoot ;
    nCured      +=  i.nCured      ;
    nDeleted    +=  i.nDeleted    ;
    nSuspicious +=  i.nSuspicious ;

    return ( *this );
}

void VirusScanner::info::output()
{
    cprintf(
        "컴컴컴컴컴컴컴컴컴컴컴\r\n"
        "  Found    : %6d\r\n"
        "  Infected : %6d\r\n"
        "  Dead     : %6d\r\n"
        "  Cured    : %6d\r\n"
        "  Deleted  : %6d\r\n"
        "컴컴컴컴컴컴컴컴컴컴컴 \/\/ Yours, RatCatcher\r\n"

        ,
        nFiles,
        nInfected,
        nDamaged,
//      nBoot,
//      nInfectedBoot,
        nCured,
        nDeleted
//        nSuspicious
         );
}

//////////////////////////////////////////////////////////////////////
//  Class  'FilePage'

void VirusScanner::FilePage::Read( int handle )
{
    m_nDataSize = _read( handle, m_pData, m_nSize );
}
