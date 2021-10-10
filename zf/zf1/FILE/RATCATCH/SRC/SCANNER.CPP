/////////////////////////////////////////////////////////////////////////////
// RatCatcher Beta
// Version 1.0
// ==========================================================================
// Copyright (c) 1997, Andrew "ReCoder" Kondrashov
// ==========================================================================
// Scanner : simple file scanner
//
// Programmer : Andrew Kondrashow
// ==========================================================================
// Started at : August, 1997
/////////////////////////////////////////////////////////////////////////////

#include <dos.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include "scanner.h"

#include "sysdos.h"

Scanner::Scanner() :
    m_bReports( FALSE )
{
    m_nMaxDrive = GetMaxDrive();

    strcpy( m_FileMask, "*.*" );
}

Scanner::~Scanner()
{
}

void Scanner::ScanAllDrives()
{
    for( int nDrive = 3; nDrive <= m_nMaxDrive; nDrive++ )
    {
        ProcessDrive( nDrive );

        char strRoot[ 8 ] = "@:\\";

        strRoot[ 0 ] += nDrive;
        strcpy( m_CurDir, strRoot );

        Traverse();
    }
}

void Scanner::ScanDrives( LPCTSTR lpszDrives )
{
    int len = strlen( lpszDrives );

    for( int i = 1; i < len; i ++ )
    {
        if( lpszDrives [ i ] == ':' )
        {
            char drivechar = toupper( lpszDrives [ i - 1 ] );

            ScanDrive( drivechar - 'A' + 1 );
        }
    }
}

void Scanner::ScanDrive( int drive )
{
    if( drive > m_nMaxDrive )
        return;

    char DrivePath[] = "@:";

    DrivePath[ 0 ] += drive;
    ScanDrive( DrivePath );
}

void Scanner::ScanDrive( LPCTSTR lpszDrive )
{
    strupr( lpszDrive );
    do
    {
        strcpy( m_CurDir, lpszDrive );
        NormalizeDir();
        Traverse();

        if( m_bReports )
        {
            Report();
        }

    } while( ( lpszDrive[ 0 ] == 'A' || lpszDrive[ 0 ] == 'B' ) &&
             ( PromptAnotherFloppy() != 0 ) );
}

int Scanner::PromptAnotherFloppy()
{
    int answer = 0;
    cprintf( "Do you want to scan another floppy ? [Y/N] " );
    while( 1 )
    {
        char c = getch();
        if( toupper( c ) == 'Y' )
        {
            cprintf( "Yes" );
            answer = 1;
            break;
        }
        if( toupper( c ) == 'N' )
        {
            cprintf( "No" );
            answer = 0;
            break;
        }
    }
    cprintf( "\r\n" );
    return answer;
}

void Scanner::ScanDirectory( LPCTSTR lpszDirectory )
{
    strcpy( m_CurDir, lpszDirectory );
    NormalizeDir();
    Traverse();

    if( m_bReports )
    {
        Report();
    }
}

void Scanner::ScanUsingMask( LPCTSTR lpszPathMask )
{
    char path[ MAXPATH ];

    strcpy( path, lpszPathMask );

    char* p = strrchr( path, '\\' );
    if( p )
    {
        strcpy( m_FileMask, p + 1 );
        *p = 0;

        ScanDirectory( path );
    }
    else
    {
        p = strrchr( path, ':' );

        if( p )
        {
            strcpy( m_FileMask, p + 1 );
            *( p + 1 ) = 0;

            ScanDrives( path );
        }
        else
        {
            strcpy( m_FileMask, path );
            getcurdir( 0, m_CurDir );
            strcpy( path, "@:\\" );
            path[ 0 ] += _getdrive();
            strcat( path, m_CurDir );

            ScanDirectory( path );
        }
    }
    if( m_bReports )
    {
        Report();
    }
}

void Scanner::ScanOneFile( LPCTSTR lpszFileName )
{
    char drive [ MAXDRIVE ];
    char dir   [ MAXDIR   ];
    char file  [ MAXFILE  ];
    char ext   [ MAXEXT   ];

    fnsplit( lpszFileName, drive, dir, file, ext );

    fnmerge ( m_CurDir,   drive, dir, NULL, NULL );
    fnmerge ( m_FileMask, NULL, NULL, file, ext  );

    SearchFiles();

    if( m_bReports )
    {
        Report();
    }
}

void Scanner::Traverse()
{
    SearchDirectories();
    SearchFiles();
}

void Scanner::SearchDirectories()
{
    char search_path[ MAXPATH ];
    struct ffblk fb;

    fnmerge( search_path, "", m_CurDir, "*", ".*" );

    if( ! findfirst(
        search_path, &fb,
        FA_RDONLY | FA_HIDDEN | FA_DIREC | FA_ARCH | FA_SYSTEM )
    )
    {
        do
        {
            if( fb.ff_attrib & FA_DIREC )
            {
                if( fb.ff_name[ 0 ] != '.' )
                {
                    ChangeDir( fb.ff_name );
                    Traverse();
                    ChangeDirUp ();
                }
            }
        } while( ! findnext( &fb ) );
    }
}

void Scanner::SearchFiles()
{
    char search_path[ MAXPATH ];
    struct ffblk fb;

    fnmerge( search_path, "", m_CurDir, m_FileMask, 0 );

    if( ! findfirst(
        search_path, &fb,
        FA_RDONLY | FA_HIDDEN | FA_ARCH | FA_SYSTEM )
    )
    {
        do
        {
// Get full file name
            fnmerge( m_FilePath, "", m_CurDir, fb.ff_name, "" );
// Fill information fields
            char ext[ MAXEXT ];
            fnsplit( m_FilePath, NULL, NULL, m_Name, ext );
            strcpy( m_Extension, ext + 1 );

            m_nAttrib = fb.ff_attrib;
            m_wTime   = fb.ff_ftime;
            m_wDate   = fb.ff_fdate;
            m_dwSize  = fb.ff_fsize;

// Handle the file
            ProcessFile( m_FilePath );

        } while( ! findnext( &fb ) );
    }
}

int Scanner::GetMaxDrive()
{
    CVTPTR p = CVT::GetCVT();

    int i = p->num_bdev;

    return i;
}

void Scanner::NormalizeDir()
{
    int nPos = strlen( m_CurDir );
    if( nPos )
    {
        if( m_CurDir[ nPos ] != '\\' )
        {
            m_CurDir[ nPos++ ] = '\\';
            m_CurDir[ nPos++ ] = '\0';
        }
    }
}

void Scanner::ChangeDir( LPCTSTR lpszDir )
{
    strcat( strcat( m_CurDir, lpszDir ), "\\" );
}

void Scanner::ChangeDirUp ()
{
    char *p;

    m_CurDir [ strlen( m_CurDir ) - 1 ] = '\0';
    p = strrchr( m_CurDir, '\\' );
    *( ++p ) = '\0';
}
