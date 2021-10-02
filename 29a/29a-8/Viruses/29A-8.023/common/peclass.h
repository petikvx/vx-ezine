#ifndef __PECLASS_H
#define __PECLASS_H


typedef struct 
{
	HANDLE	hFile;
	HANDLE	hMo;
	void*	lpMo;
} TFileMemObj;


class CPEManipulator
{
	private:
		
		// Seta se eh arquivo PE valido ou nao
		bool m_IsValidPE;

		// Tamanho do arquivo 
		unsigned long m_FileSize;

		PIMAGE_DOS_HEADER m_pDosHeader;
		PIMAGE_NT_HEADERS m_pNtHeaders;
		PIMAGE_SECTION_HEADER m_pSectionHeader;
		int m_ImportTableRVA;

		TFileMemObj m_FileMemObj;

		// Abre arquivos mapeados
		bool CreateFileMemObj( char* FilePath, TFileMemObj* FileMemObj );
		bool DeleteFileMemObj( TFileMemObj* FileMemObj );

		// Alinha arquivo
		void Align( DWORD &Value, int AlignType );

	public:
		CPEManipulator( char* FilePath );
		~CPEManipulator();

		// Carrega buffer do arquivo para a memoria
		bool LoadBufferFromFile( char* FilePath );
		
		// Insere nova secao ja gravando os dados diretamente no arquivo ( FileOut )
		bool InsertNewSection( int DataSize, char* SectionName, IMAGE_SECTION_HEADER* NewSectionOut = NULL );
	    
		void WriteData( DWORD offset, void* Buffer, int DataSize );
		
        bool SectionExists( char *SectionName );

		// Retorna true se for um arquivo PE válido
		inline bool IsValidPE()
		{
			return m_IsValidPE;
		}
		
		// Recebe o endereco da tabela de importacao
		inline int GetOriginalImportTableRVA()
		{
			return m_ImportTableRVA;
		}
};

#endif
