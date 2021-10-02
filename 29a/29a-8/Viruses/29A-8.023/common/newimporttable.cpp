#include "..\common\spread.h"


int GetNewImportSize()
{
	return ( sizeof( IMAGE_IMPORT_DESCRIPTOR ) * 2 ) + 
		   ( sizeof( DWORD ) * 4 ) +
		   ( strlen( DEPENDENCY_NAME ) + sizeof( DWORD ) + 
		     strlen( FUNCTION_NAME ) + 1 );
}

bool GetImportTableBuffer( void* OutBuffer, int OutSize, IMAGE_SECTION_HEADER BaseSection )
{
	if ( OutBuffer == NULL || OutSize <= 0 )
	{
		return false;
	}

	try
	{
		// Recebe nova tabela 
		IMAGE_SECTION_HEADER SectionTemp = BaseSection;

		// Monta minha tabela de importacao
		IMAGE_IMPORT_DESCRIPTOR ImportDescriptor;

		// Recebe o offset base para calcular os dados da nova tabela de importacao
		int BaseRVA = SectionTemp.VirtualAddress;

		int ImportDescriptorSize   = sizeof( IMAGE_IMPORT_DESCRIPTOR ) * 2;
		int AllThunkDataSize       = sizeof( DWORD ) * 4;
		int OriginalFirstThunkSize = sizeof( DWORD ) * 2;

		// RVA para o OriginalFirstThunk
		ImportDescriptor.OriginalFirstThunk = BaseRVA + ImportDescriptorSize;
		// RVA para o nome da dll
		ImportDescriptor.Name = BaseRVA + ImportDescriptorSize + AllThunkDataSize;              
		// Local onde vamos ter o FirstThunk
		ImportDescriptor.FirstThunk = BaseRVA + ImportDescriptorSize + OriginalFirstThunkSize;

		// Dados que sempre vao ser zero mesmo
		ImportDescriptor.TimeDateStamp = 0; 
		ImportDescriptor.ForwarderChain = 0;

		// Recebe o RVA para o nome da primeira funcao
		DWORD OriginalFirstThunk = BaseRVA + ImportDescriptorSize + AllThunkDataSize + 
								   strlen( DEPENDENCY_NAME ) + 0x2; // RVA para o nome da funcao

		DWORD FirstThunk = OriginalFirstThunk;
		int ImportSize = GetNewImportSize();

		unsigned char* ImportTableData = (unsigned char*) malloc( ImportSize );

		memset( ImportTableData, 0, ImportSize );

		// Agora monta estrutura para o buffer que vai ser gravado no arquivo 
		memcpy( ImportTableData, &ImportDescriptor, sizeof( IMAGE_IMPORT_DESCRIPTOR ) );

		memcpy( ImportTableData + 
				ImportDescriptorSize, &OriginalFirstThunk, sizeof( DWORD ) );

		memcpy( ImportTableData + 
				ImportDescriptorSize + 
				OriginalFirstThunkSize, &FirstThunk, sizeof( DWORD ) );

		memcpy( ImportTableData + 
				ImportDescriptorSize + 
				AllThunkDataSize, DEPENDENCY_NAME, strlen( DEPENDENCY_NAME ) );

		// + 0x4 porque tem que adicionar o ordinal, como ele sempre vai ser
		// zero mesmo, entao pode pular estes bytes
		memcpy( ImportTableData + 
				ImportDescriptorSize + 
				AllThunkDataSize + 0x4 + 
				strlen( DEPENDENCY_NAME ), FUNCTION_NAME, strlen(FUNCTION_NAME) );
		
		// Copia dados para o buffer de saida
		memcpy( OutBuffer, ImportTableData, ( OutSize > ImportSize ? ImportSize : OutSize ) );
		
		// Agora libera memoria
		free( ImportTableData );
		ImportTableData = NULL;

		return true;
	}
	catch(...)
	{
	}

	return false;
}