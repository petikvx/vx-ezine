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

#ifndef _XSCANNER_H_
#define _XSCANNER_H_

#include "Scanner.h"

class ExtendedScanner : public Scanner
{
    BOOL    m_bPreserveLFN;

    char    m_LongFilePath[ 512 ];

public:
    ExtendedScanner()  {}
    ~ExtendedScanner() {}

//    void SetLFN ( BOOL bOn = TRUE );

protected:
    virtual BOOL Match( LPCTSTR lpszFilePath );
    virtual BOOL Match( int nDriveNo         );

    virtual void DriveFound ( int nDriveNo         ) = 0;
    virtual void FileFound  ( LPCTSTR lpszFilePath ) = 0;

private:
    virtual void ProcessDrive ( int nDriveNo         );
    virtual void ProcessFile  ( LPCTSTR lpszFilePath );
};

;

#endif // _XSCANNER_H_
