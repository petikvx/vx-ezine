#include "SenShiro.h"


int CheckIfSameString(char *string1, char *string2){

int i_count = 1;
int i_result;
int length_str1, length_str2;

	while(string1[i_count] != 0){i_count++;}
	length_str1 = i_count;

	i_count = 1;
	while(string2[i_count] != 0){i_count++;}
	length_str2 = i_count;

	if (length_str1 != length_str2){return(1);}

	i_count = 1;

	while(i_count <= length_str1){

		if (string1[i_count] != string2[i_count]){
			return(1);}
		i_count++;

	}

	return(0);
}

QWORD LookUpKernel(QWORD LocalAddressKernel, char *D_ApiSearched){

PIMAGE_DOS_HEADER KernelDOSStub;
PIMAGE_NT_HEADERS64 KernelPEheader;
PIMAGE_OPTIONAL_HEADER64 KernelOptPEheader;
PIMAGE_EXPORT_DIRECTORY ImgExpDir;

DWORD KernelExportDirectory, dwFileImageExport, NbExpbyKernel;
DWORD *ArrayofExportNames, *ArrayofExportFunction;
int index;
SHORT *ArrayofOrdinals;
char *AddrFunctionName;
QWORD AddressOfSearchedLib;
BOOL bFunctionFound = FALSE;


	KernelDOSStub = (PIMAGE_DOS_HEADER)LocalAddressKernel;
	KernelPEheader = (PIMAGE_NT_HEADERS64)((DWORD)KernelDOSStub + KernelDOSStub->e_lfanew);
	KernelOptPEheader = (PIMAGE_OPTIONAL_HEADER64)&KernelPEheader->OptionalHeader;
	KernelExportDirectory = KernelOptPEheader->DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;

	ImgExpDir = (PIMAGE_EXPORT_DIRECTORY)(LocalAddressKernel + (QWORD)KernelExportDirectory);
	NbExpbyKernel = ImgExpDir->NumberOfNames;

	ArrayofExportNames = (DWORD *)(ImgExpDir->AddressOfNames + LocalAddressKernel);
	ArrayofOrdinals = (SHORT *)(ImgExpDir->AddressOfNameOrdinals + LocalAddressKernel);
	ArrayofExportFunction = (DWORD *)(ImgExpDir->AddressOfFunctions + LocalAddressKernel);

	for (index = 0; index <= NbExpbyKernel; index++){
		
		AddrFunctionName = (char *)(ArrayofExportNames[index] + LocalAddressKernel);
		if (!CheckIfSameString(AddrFunctionName, D_ApiSearched)){
			AddressOfSearchedLib =  ArrayofExportFunction[ArrayofOrdinals[index]] + LocalAddressKernel;
			bFunctionFound = TRUE;
			break;}
	}
	if (bFunctionFound)return (AddressOfSearchedLib);
	else return(0);

}
QWORD Virtual2Offset(PIMAGE_NT_HEADERS lPEheader, QWORD dw_va){

PIMAGE_FILE_HEADER ImgFileHdr;
PIMAGE_SECTION_HEADER ImgSectionHdr1, ImgSectionHdr2;

WORD NbSections;
int index;
DWORD dwFileOffset;
BOOL bOffsetFound = FALSE;

	//First we get the number of sections
	ImgFileHdr = (PIMAGE_FILE_HEADER)&lPEheader->FileHeader;
	NbSections = ImgFileHdr->NumberOfSections;

	for (index = 0; index < NbSections; index++){
		ImgSectionHdr1 = (PIMAGE_SECTION_HEADER)((DWORD)lPEheader + sizeof(IMAGE_NT_HEADERS) + 
			index*sizeof(IMAGE_SECTION_HEADER));
		ImgSectionHdr2 = (PIMAGE_SECTION_HEADER)((DWORD)lPEheader + sizeof(IMAGE_NT_HEADERS) + 
			(index+1)*sizeof(IMAGE_SECTION_HEADER));
		if (ImgSectionHdr2->VirtualAddress > dw_va && ImgSectionHdr1->VirtualAddress <= dw_va){
			bOffsetFound = TRUE;
			break;
		}
	}

	if (bOffsetFound){
		dwFileOffset = dw_va - ImgSectionHdr1->VirtualAddress + ImgSectionHdr1->PointerToRawData;
		return dwFileOffset;}

	else {
		ImgSectionHdr1 = (PIMAGE_SECTION_HEADER)((DWORD)lPEheader + sizeof(IMAGE_NT_HEADERS) + 
			(NbSections-1)*sizeof(IMAGE_SECTION_HEADER));
		dwFileOffset = dw_va - ImgSectionHdr1->VirtualAddress + ImgSectionHdr1->PointerToRawData;
		return dwFileOffset;}

}