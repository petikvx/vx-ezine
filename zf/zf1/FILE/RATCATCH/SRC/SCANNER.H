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

#ifndef _SCANER_H_
#define _SCANER_H_

#include "dir.h"
#include "stypes.h"

class Scanner
{
    BOOL    m_bReports;
protected:
    BYTE    m_nAttrib;
    WORD    m_wTime;
    WORD    m_wDate;
    DWORD   m_dwSize;

    char    m_Name     [ MAXFILE ];
    char    m_Extension[ MAXEXT  ];

    char    m_FilePath [ MAXPATH ];

    char    m_FileMask [ MAXFILE + MAXEXT ];

public:
    Scanner();
    virtual ~Scanner();

    void SetReports   ( BOOL bSet = TRUE ) { m_bReports   = bSet; }

    virtual void ScanAllDrives(); // all local hard drives '*:'
    virtual void ScanDrives( LPCTSTR lpszDrives ); // 'A: C: F:'
    virtual void ScanDrive( int drive ); // 1 = A, 2 = B, 3 = C etc...
    virtual void ScanDrive( LPCTSTR lpszDrive ); // 'A:', 'C:'
    virtual void ScanDirectory( LPCTSTR lpszDirectory ); // any directory
    virtual void ScanUsingMask( LPCTSTR lpszPathMask ); // any mask with ? and *
    virtual void ScanOneFile( LPCTSTR lpszFileName ); // exact file name

protected:
    virtual void ProcessDrive ( int nDriveNo         ) = 0;
    virtual void ProcessFile  ( LPCTSTR lpszFilePath ) = 0;

    virtual void Report() {}

protected:
    void Traverse();
    void SearchDirectories();
    void SearchFiles();

    virtual void ChangeDir( LPCTSTR lpszDir );
    virtual void ChangeDirUp ();

    virtual int PromptAnotherFloppy();

private:
    int GetMaxDrive();
    void NormalizeDir();

    int     m_nMaxDrive;

    char    m_CurDir[ MAXPATH ];
};

#endif // _SCANER_H_
