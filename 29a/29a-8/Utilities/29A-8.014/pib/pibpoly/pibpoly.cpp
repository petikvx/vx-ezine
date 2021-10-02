// pibpoly.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <windows.h>
#include "pibpolytbl.cpp"

// 0 = nouse, 1 = using
typedef struct _REGISTAR_TOUCH
{
	DWORD dwEAX; // 000
	DWORD dwEBX; // 011
	DWORD dwECX; // 001
	DWORD dwEDX; // 010
	DWORD dwESI; // 110
	DWORD dwEDI; // 111
	DWORD dwEBP; // 101
} REGISTAR_TOUCH, *PREGISTAR_TOUCH;

// 0 = nouse, 1 = using
typedef struct _WREGISTAR_TOUCH
{
	DWORD dwAL;
	DWORD dwAH;
	DWORD dwBL;
	DWORD dwBH;
	DWORD dwCL;
	DWORD dwCH;
	DWORD dwDL;
	DWORD dwDH;
} WREGISTAR_TOUCH, *PWREGISTAR_TOUCH;

#define SYS_DEBUG 1
#define ErrLog(a) OutputDebugString(a);
#define INSTRUC_MAX 360

DWORD dwIndexInto=0;
DWORD dwPInProg=0;
DWORD dwCheckup[5];
REGISTAR_TOUCH rt;
WREGISTAR_TOUCH wrt;
DWORD dwInstrucBlock[INSTRUC_MAX];
DWORD dwCmpAddrBlock[INSTRUC_MAX];
DWORD dwCmpCount[INSTRUC_MAX];
DWORD dwInstrucAmt;
DWORD dwIndexCountTbl;
DWORD dwIndexInstrucBlock;
DWORD wNull;
DWORD dwKeyReg;
DWORD dwAddrReg;

int _PolyErrLog(char *a)
{
	#ifdef SYS_DEBUG
		ErrLog(a)
	#endif

	return 0;
}

int _PolyCalcArrayCount()
{
	int i, x;
	x=0;

	for (i = 0; i < 0x1FE; i++)
	{
		if (bOpcodeTbl[i] == 0xFF)
		{
			return x;
		}
		x++;
	}

	return 0;
}

int _PolyGenerateIB(LPVOID lpPolyCode, BYTE b2)
{
	DWORD brand;
	BYTE bcpy;

	dwInstrucBlock[dwInstrucAmt] = ((DWORD) lpPolyCode + dwIndexInto);
	dwInstrucAmt++;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &b2, 1);
	dwIndexInto++;

	brand = rand();
	brand = brand << 24;
	brand = brand >> 24;

	bcpy = brand;
	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &bcpy, 1);
	dwIndexInto++;

	switch (b2)
	{
		case 0x3C:
		case 0x3D:
		case 0x80:
		case 0x81:
		case 0x83:
		case 0x38:
		case 0x39:
		case 0x3A:
		case 0x3B: 
			dwCmpAddrBlock[dwIndexCountTbl] = dwIndexInto;
			dwCmpCount[dwIndexCountTbl] = (dwInstrucAmt + 1);
			dwIndexInstrucBlock++;
			dwIndexCountTbl++;

			memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &wNull, 4);
			dwIndexInto += 6;
		break;
	}

	return 0;
}

int _PolyGenerateIW(LPVOID lpPolyCode, BYTE b2)
{
	DWORD brand;
	WORD wcpy;

	dwInstrucBlock[dwInstrucAmt] = ((DWORD) lpPolyCode + dwIndexInto);
	dwInstrucAmt++;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &b2, 1);
	dwIndexInto++;

	brand = rand();
	brand = brand << 16;
	brand = brand >> 16;

	wcpy = brand;
	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &wcpy, 2);
	dwIndexInto += 2;

	switch (b2)
	{
		case 0x3C:
		case 0x3D:
		case 0x80:
		case 0x81:
		case 0x83:
		case 0x38:
		case 0x39:
		case 0x3A:
		case 0x3B:
			dwCmpAddrBlock[dwIndexCountTbl] = dwIndexInto;
			dwCmpCount[dwIndexCountTbl] = (dwInstrucAmt + 1);
			dwIndexInstrucBlock++;
			dwIndexCountTbl++;

			memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &wNull, 4);
			dwIndexInto += 6;
		break;
	}

	return 0;
}

int _PolyGenerateID(LPVOID lpPolyCode, BYTE b2)
{
	DWORD brand;
	DWORD dwcpy;

	dwInstrucBlock[dwInstrucAmt] = ((DWORD) lpPolyCode + dwIndexInto);
	dwInstrucAmt++;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &b2, 1);
	dwIndexInto++;

	brand = rand();

	dwcpy = brand;
	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &dwcpy, 4);
	dwIndexInto += 4;

	switch (b2)
	{
		case 0x3C:
		case 0x3D:
		case 0x80:
		case 0x81:
		case 0x83:
		case 0x38:
		case 0x39:
		case 0x3A:
		case 0x3B:
			dwCmpAddrBlock[dwIndexCountTbl] = dwIndexInto;
			dwCmpCount[dwIndexCountTbl] = (dwInstrucAmt + 1);
			dwIndexInstrucBlock++;
			dwIndexCountTbl++;

			memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &wNull, 4);
			dwIndexInto += 6;
		break;
	}

	return 0;
}

int _PolyGenerateR(LPVOID lpPolyCode, BYTE b2)
{
	DWORD arand, brand;
	BYTE bcpy, bwtest;

	dwInstrucBlock[dwInstrucAmt] = ((DWORD) lpPolyCode + dwIndexInto);
	dwInstrucAmt++;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &b2, 1);
	dwIndexInto++;

	RemakeArea:
	arand = (int) 7 * rand() / (RAND_MAX + 1.0);
	brand = (int) 7 * rand() / (RAND_MAX + 1.0);

	bwtest = b2;
	bwtest = bwtest << 7;
	bwtest = bwtest >> 7;

	if (bwtest == 1)
	{
		switch (arand)
		{
			case 0: // 000 (EAX)
				goto RemakeArea;
				break;

			case 1: // 001 (ECX)
				if (rt.dwECX == 1)
					goto RemakeArea;
				break;

			case 2: // 010 (EDX)
				if (rt.dwEDX == 1)
					goto RemakeArea;
				break;

			case 3: // 011 (EBX)
				if (rt.dwEBX == 1)
					goto RemakeArea;
				break;

			case 4: // 100 (ESP)
				goto RemakeArea;
				break;

			case 5: // 101 (EBP)
				if (rt.dwEBP == 1)
					goto RemakeArea;
				break;

			case 6: // 110 (ESI)
				if (rt.dwESI == 1)
					goto RemakeArea;
				break;

			case 7: // 111 (EDI)
				if (rt.dwEDI == 1)
					goto RemakeArea;
				break;

			default:
				goto RemakeArea;
				break;
		}

		switch (brand)
		{
			case 0: // 000 (EAX)
				goto RemakeArea;
				break;

			case 1: // 001 (ECX)
				if (rt.dwECX == 1)
					goto RemakeArea;
				break;

			case 2: // 010 (EDX)
				if (rt.dwEDX == 1)
					goto RemakeArea;
				break;

			case 3: // 011 (EBX)
				if (rt.dwEBX == 1)
					goto RemakeArea;
				break;

			case 4: // 100 (ESP)
				goto RemakeArea;
				break;

			case 5: // 101 (EBP)
				if (rt.dwEBP == 1)
					goto RemakeArea;
				break;

			case 6: // 110 (ESI)
				if (rt.dwESI == 1)
					goto RemakeArea;
				break;

			case 7: // 111 (EDI)
				if (rt.dwEDI == 1)
					goto RemakeArea;
				break;

			default:
				goto RemakeArea;
				break;
		}
	}
	else
	{
		switch (arand)
		{
			case 0: // 000 (AL)
				goto RemakeArea;
				break;

			case 1: // 001 (CL)
				if (wrt.dwCL == 1)
					goto RemakeArea;
				break;

			case 2: // 010 (DL)
				if (wrt.dwDL == 1)
					goto RemakeArea;
				break;

			case 3: // 011 (BL)
				if (wrt.dwBL == 1)
					goto RemakeArea;
				break;

			case 4: // 100 (AH)
				if (wrt.dwAH == 1)
					goto RemakeArea;
				break;

			case 5: // 101 (CH)
				if (wrt.dwCH == 1)
					goto RemakeArea;
				break;

			case 6: // 110 (DH)
				if (wrt.dwDH == 1)
					goto RemakeArea;
				break;

			case 7: // 111 (BH)
				if (wrt.dwBH == 1)
					goto RemakeArea;
				break;

			default:
				goto RemakeArea;
				break;
		}
		switch (brand)
		{
			case 0: // 000 (AL)
				goto RemakeArea;
				break;

			case 1: // 001 (CL)
				if (wrt.dwCL == 1)
					goto RemakeArea;
				break;

			case 2: // 010 (DL)
				if (wrt.dwDL == 1)
					goto RemakeArea;
				break;

			case 3: // 011 (BL)
				if (wrt.dwBL == 1)
					goto RemakeArea;
				break;

			case 4: // 100 (AH)
				if (wrt.dwAH == 1)
					goto RemakeArea;
				break;

			case 5: // 101 (CH)
				if (wrt.dwCH == 1)
					goto RemakeArea;
				break;

			case 6: // 110 (DH)
				if (wrt.dwDH == 1)
					goto RemakeArea;
				break;

			case 7: // 111 (BH)
				if (wrt.dwBH == 1)
					goto RemakeArea;
				break;

			default:
				goto RemakeArea;
				break;
		}
	}

	arand = arand << 3;
	arand = arand | brand;
	bcpy = 11;
	bcpy = bcpy << 6;
	bcpy = bcpy | arand;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &bcpy, 1);
	dwIndexInto++;

	switch (b2)
	{
		case 0x3C:
		case 0x3D:
		case 0x80:
		case 0x81:
		case 0x83:
		case 0x38:
		case 0x39:
		case 0x3A:
		case 0x3B:
			dwCmpAddrBlock[dwIndexCountTbl] = dwIndexInto;
			dwCmpCount[dwIndexCountTbl] = (dwInstrucAmt + 1);
			dwIndexInstrucBlock++;
			dwIndexCountTbl++;

			memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &wNull, 4);
			dwIndexInto += 6;
		break;
	}

	return 0;
}

int _PolyGenerateSingle(LPVOID lpPolyCode)
{
	return 0;
}

int _PolyFixCMPJMP(LPVOID lpPolyCode)
{
	int i;
	int xrand;
	int lrand;
	DWORD dwAddrJMP;
	DWORD dwNewAddr;
	DWORD dwRandX;
	DWORD dwdelta;
	DWORD dwhold;
	BYTE bcpy;
	BYTE bdelta;

	for (i = 0; i < dwIndexCountTbl; i++)
	{
		dwAddrJMP = dwCmpAddrBlock[i];
		dwAddrJMP += (DWORD) lpPolyCode;

		// printf("dwAddrJMP = %x\n", dwAddrJMP);

		dwRandX = dwCmpCount[i];
		dwhold = dwRandX;
		dwRandX = (dwInstrucAmt - dwRandX);

		xrand = (int) dwRandX * rand() / (RAND_MAX + 1.0);
		dwhold += xrand;
		dwNewAddr = dwInstrucBlock[dwhold];
		// printf("dwNewAddr = %x\n", dwNewAddr);

		dwdelta = dwNewAddr - (dwAddrJMP + 6);

		if (dwdelta == 0)
			dwdelta = 6;

		bcpy = 0x0F;
		memcpy( (void *) dwAddrJMP, &bcpy, 1);
		dwAddrJMP++;

		lrand = (int) 16 * rand() / (RAND_MAX + 1.0);

		bcpy = bJmpTable[lrand];
		memcpy( (void *) dwAddrJMP, &bcpy, 1);
		dwAddrJMP++;
		memcpy( (void *) dwAddrJMP, &dwdelta, 4);
	}

	return 0;
}

int _PolyGenerateOrdinary(LPVOID lpPolyCode)
{
	int xrand, xlook;
	BYTE b1, b2;

	xrand = _PolyCalcArrayCount() / 2;
	xrand = (int) xrand * rand() / (RAND_MAX + 1.0);

	if ( (xrand % 2) != 0)
		return 0;

	b1 = bOpcodeTbl[xrand];
	xrand++;
	b2 = bOpcodeTbl[xrand];

	switch (b1)
	{
		case 0:
		// printf("Generating /R Instruction Type\n");
		_PolyGenerateR(lpPolyCode, b2);
		break;

		case 1:
		// printf("Generating IB Instruction Type\n");
		_PolyGenerateIB(lpPolyCode, b2);
		break;

		case 2:
		// printf("Generating IW Instruction Type\n");
		_PolyGenerateIW(lpPolyCode, b2);
		break;

		case 3:
		// printf("Generating ID Instruction Type\n");
		_PolyGenerateID(lpPolyCode, b2);
	}

	return 0;
}

int _PolyFixed(LPVOID lpPolyCode, int xrand)
{
	BYTE bcpy, bmem;
	int crand;

	RefreshRnd:
	bmem = xrand;
	crand = (int) 5 * rand() / (RAND_MAX + 1.0);

	switch (crand)
	{
		case 0:
			bcpy = 8; // INC
			break;

		case 1:
			bcpy = 9; // DEC
			break;

		case 2:
			if (dwPInProg == 1)
				return 0;
			else
			{
				bcpy = 10; // PUSH
				dwPInProg = 1;
			}
			break;

		case 3:
			if (dwPInProg == 1)
			{
				bcpy = 11; // POP
				dwPInProg = 0;
			}
			else
				return 0;
			break;

		default:
			goto RefreshRnd;
	}

	bcpy = bcpy << 3;
	bcpy = bcpy | bmem;

	dwInstrucBlock[dwInstrucAmt] = ((DWORD) lpPolyCode + dwIndexInto);
	dwInstrucAmt++;

	memcpy( (void *) ( (DWORD) lpPolyCode + dwIndexInto), &bcpy, 1);
	dwIndexInto++;

	return 0;
}

int _PolyGenerateFixed(LPVOID lpPolyCode)
{
	int xrand;
	char szFoo[256];

	rt.dwECX = 1;
	rt.dwESI = 1;
	rt.dwEDX = 1;

	wrt.dwCH = 1;
	wrt.dwCL = 1;
	wrt.dwDH = 1;
	wrt.dwDL = 1;
	
	if (rt.dwEAX == 1)
	{
		OutputDebugString("EAX = VALID");
	}
	
	if (rt.dwEBX == 1)
	{
		OutputDebugString("EBX = VALID");
	}

	if (rt.dwECX == 1)
	{
		OutputDebugString("ECX = VALID");
	}

	if (rt.dwEDX == 1)
	{
		OutputDebugString("EDX = VALID");
	}

	if (rt.dwEBP == 1)
	{
		OutputDebugString("EBP = VALID");
	}

	if (rt.dwESI == 1)
	{
		OutputDebugString("ESI = VALID");
	}

	if (rt.dwEDI == 1)
	{
		OutputDebugString("EDI = VALID");
	}

	RepFix:
	xrand = (int) 8 * rand() / (RAND_MAX + 1.0);

	switch (xrand)
	{
		case 0: // 000 (EAX)
			if (rt.dwEAX == 1)
				goto RepFix;
			if ( (wrt.dwAH == 1) || (wrt.dwAL == 1))
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;
		
		case 1: // 001 (ECX)
			if (rt.dwECX == 1)
				goto RepFix;
			if ( (wrt.dwCH == 1) || (wrt.dwCL == 1))
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;

		case 2: // 010 (EDX)
			if (rt.dwEDX == 1)
				goto RepFix;
			if ( (wrt.dwDH == 1) || (wrt.dwDL == 1))
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;
		
		case 3: // 011 (EBX)
			if (rt.dwEBX == 1)
				goto RepFix;
			if ( (wrt.dwBH == 1) || (wrt.dwBL == 1))
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;

		case 4: // 100 (ESP)
			goto RepFix;

		case 5: // 101 (EBP)
			if (rt.dwEBP == 1)
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;

		case 6: // 110 (ESI)
			if (rt.dwESI == 1)
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;

		case 7: // 111 (EDI)
			if (rt.dwEDI == 1)
				goto RepFix;
			_PolyFixed(lpPolyCode, xrand);
			break;

		default:
			goto RepFix;
	}

	wsprintf(szFoo, "Value: %d", xrand);
	OutputDebugString(szFoo);

	return 0;
}

int _PolyGenerate(LPVOID lpPolyCode)
{
	int xrand, yrand, zrand, brand;
	int x, i, z;
	int abil;
	int abilfix;

	srand((unsigned)time(NULL));

	zrand = (int) INSTRUC_MAX * rand() / (RAND_MAX + 1.0);
	abil = 0;
	abilfix = 0;
	dwInstrucAmt = 0;
	dwIndexCountTbl = 0;

	for (z = 0; z < zrand; z++)
	{
		yrand = (int) 3 * rand() / (RAND_MAX + 1.0);

		switch (yrand)
		{
			case 0:
			if (abil == 0)
				_PolyGenerateSingle(lpPolyCode);
			break;

			case 1:
			_PolyGenerateOrdinary(lpPolyCode);
			abil++;

			if (abil == 5)
				abil = 0;
			break;

			case 2:
				if (abilfix == 3)
				{
					abilfix = 0;
					break;
				}

			// printf("Generating Fixed Instruction\n");
			_PolyGenerateFixed(lpPolyCode);
			abilfix++;
		}
	}

	_PolyFixCMPJMP(lpPolyCode);

	return 0;
}

int _PolyGenerateREG()
{
	int arand;
	int brand;

	arand = (int) 6 * rand() / (RAND_MAX + 1.0);
	brand = (int) 6 * rand() / (RAND_MAX + 1.0);

	rt.dwEAX = 1;
	wrt.dwAH = 1;
	wrt.dwAL = 1;

	switch (arand)
	{
		case 0:
			dwKeyReg = 0;
			rt.dwEBX = 1;
			wrt.dwBH = 1;
			wrt.dwBL = 1;
			break;

		case 1:
			dwKeyReg = 1;
			rt.dwECX = 1;
			wrt.dwCH = 1;
			wrt.dwCL = 1;
			break;
		
		case 2:
			dwKeyReg = 2;
			rt.dwEDX = 1;
			wrt.dwDH = 1;
			wrt.dwDL = 1;
			break;

		case 3:
			dwKeyReg = 3;
			rt.dwESI = 1;
			break;

		case 4:
			dwKeyReg = 4;
			rt.dwEDI = 1;
			break;

		case 5:
			dwKeyReg = 5;
			rt.dwEBP = 1;
			break;
	}

	if (brand == arand)
	{
		xrandagn:
		brand = (int) 6 * rand() / (RAND_MAX + 1.0);

		if (brand == arand)
			goto xrandagn;
	}

	switch (brand)
	{
		case 0:
			dwAddrReg = 0;
			rt.dwEBX = 1;
			wrt.dwBH = 1;
			wrt.dwBL = 1;
			break;

		case 1:
			dwAddrReg = 1;
			rt.dwECX = 1;
			wrt.dwCH = 1;
			wrt.dwCL = 1;
			break;
		
		case 2:
			dwAddrReg = 2;
			rt.dwEDX = 1;
			wrt.dwDH = 1;
			wrt.dwDL = 1;
			break;

		case 3:
			dwAddrReg = 3;
			rt.dwESI = 1;
			break;

		case 4:
			dwAddrReg = 4;
			rt.dwEDI = 1;
			break;

		case 5:
			dwAddrReg = 5;
			rt.dwEBP = 1;
			break;
	}

	return 0;
}