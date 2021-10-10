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

#ifndef _RAT_CATCHER_H_
#define _RAT_CATCHER_H_

enum
{
    exitOK            = 0,
    exitViruses       = 1,
    exitWarnings      = 2,
    exitAllCured      = 3,
    exitInterrupted   = 4,
    exitInternalError = 5,
};

#endif // _RAT_CATCHER_H_