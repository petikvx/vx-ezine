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

#ifndef _VSCANNER_H_
#define _VSCANNER_H_

#include "XScanner.h"
#include "SysDos.h"

class VirusScanner : public ExtendedScanner
{
    BOOL    m_bAllFiles;
    BOOL    m_bCure;
    BOOL    m_bHeuristic;
    BOOL    m_bShowOK;

    struct FileTest;

public:
    VirusScanner  () ;
    ~VirusScanner () ;

// Attributes
    void SetAllFiles  ( BOOL bSet = TRUE ) { m_bAllFiles  = bSet; }
    void SetCure      ( BOOL bSet = TRUE ) { m_bCure      = bSet; }
    void SetHeuristic ( BOOL bSet = TRUE ) { m_bHeuristic = bSet; }
    void SetShowOK    ( BOOL bSet = TRUE ) { m_bShowOK    = bSet; }

    BOOL VirusesFound () { return ( m_Totals.nInfected != 0 );              }
    BOOL AllCured     () { return ( m_Totals.nInfected == m_Totals.nCured ); }

// Operations
    void ReportFinalStatistics ();

protected:
    virtual BOOL Match( LPCTSTR lpszFilePath );
    virtual BOOL Match( int nDriveNo         );

    virtual void DriveFound ( int nDriveNo         );
    virtual void FileFound  ( LPCTSTR lpszFilePath );

    virtual void Report();

    virtual int  Test  ( LPCTSTR lpszFilePath, LPCTSTR lpszDisplayFile );

    virtual int  Test      ( FileTest& t );
    virtual int  Cure      ( FileTest& t, int code );
    virtual void Heuristic ( FileTest& t );
    virtual void ResetAttributes ( FileTest& t );

    void ReportVirus( int nCode );

    void ResetStatistics       ();
    void ReportStatistics      ();

// Helpers

    virtual void PrintFileName( LPCTSTR fileName );

// Helper classes

    class FilePage
    {
        BYTE*  m_pData;
        int    m_nSize;
        int    m_nDataSize;

    public:
        FilePage( int sz = 0x200 )
        {
            m_pData = new BYTE [ m_nSize = sz ];
        }
        ~FilePage()
        {
            delete m_pData;
        }

//        int   operator int   () { return m_Size;  }
//        BYTE* operator BYTE* () { return &m_Data; }

        int   GetSize     ()      { return m_nSize;      }
        int   GetDataSize ()      { return m_nDataSize;  }
        BYTE* GetBuffer   ()      { return m_pData;      }

        BYTE  GetByteAt ( int ofs ) { return *(          ( m_pData + ofs ) ); }
        WORD  GetWordAt ( int ofs ) { return *( (WORD*)  ( m_pData + ofs ) ); }
        DWORD GetDwordAt( int ofs ) { return *( (DWORD*) ( m_pData + ofs ) ); }

        void Read( int handle );
    };

    struct FileTest
    {
        int     m_nHandle;
        LPCTSTR m_pFileName;

        FileTest ();

        BOOL   Open   ( LPCTSTR fileName );
        BOOL   Reopen ();
        BOOL   Close  ();

        BOOL   ReadAt  ( DWORD pos, BYTE* buf, WORD len );
        BOOL   WriteAt ( DWORD pos, BYTE* buf, WORD len );
        BOOL   CutAtEnd( DWORD pos );

        void ReadPages();
        // === Pages ====
        FilePage PageStart;

        FilePage PageEntry;
        enum {
             entPlain, entEXE, entJMP, entRET, entSYS, entJMP2JMP
        }        m_Entry;
        DWORD    m_dwEntry;

        // === ===== ====
        EXEHDRPTR m_pExeHdr;
        BOOL      IsExe() { return ( m_pExeHdr != NULL ); }

    };

protected:
// Statistics
    struct info
    {
        info();

        int     nFiles;
        int     nInfected;
        int     nDamaged;
        int     nBoot;
        int     nInfectedBoot;
        int     nCured;
        int     nDeleted;
        int     nSuspicious;

        info& operator +=( const struct info& i );

        void output();
        void reset();
    };

    struct info m_Currents, m_Totals;
};

#endif // _VSCANNER_H_
