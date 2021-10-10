#include <windows.h>
#include <time.h>
#include <sys/utime.h>
#include <stddef.h>
#include <stdio.h>
#include <io.h>
//#include "functions.h"

#ifndef _countof
   #define _countof(array) (sizeof(array)/sizeof((array)[0]))
#endif

#define BSWAP(x) (((x)>>24)|              \
                  (((x)&0x00FF0000)>>8)|  \
                  (((x)&0x0000FF00)<<8)|  \
                  ((x)<<24))

#include "iso.h"
#include "isolib.h"


#include "iso9660.h"

#define assert(x)
#define C_ASSERT(e) char __C_ASSERT__[(e)?1:-1]



extern void myDebugString(char*);

C_ASSERT(sizeof(VolumeDateTime) == 7);

C_ASSERT(sizeof(struct iso_primary_descriptor  ) == 2048);
C_ASSERT(sizeof(PrimaryVolumeDescriptor        ) == 2048);

C_ASSERT(sizeof(struct iso_path_table          ) ==    9);
C_ASSERT(sizeof(PathTableRecord                ) ==    9);

C_ASSERT(sizeof(DirectoryRecord                ) ==   34);
C_ASSERT(sizeof(struct iso_directory_record_new) ==   34);

C_ASSERT(sizeof(BootRecordVolumeDescriptor     ) == 2048);
C_ASSERT(sizeof(struct iso_volume_descriptor   ) == 2048);

// static const char CDSignature[5] = LIT_CDSignature; gives overflow error :/
static const char CDSignature[6] = LIT_CDSignature;
static const char TORITO[]       = LIT_BootSignature;

#define LIT_HEADER_OFFSET 0x8000

// Function: 
// GetPaddingSize2

// Description: 
// returns size of padding to align an array to a specific length. 
// parameter 1: blocksize in bytes
// parameter 2: size of data in bytes

int GetPaddingLength(int blocksize, int datasize)
{
	int rest;	
	return( (int)blocksize - ( ( rest = datasize % blocksize ) ? rest : blocksize  ) ); 
}


fpos_t __fastcall GetBlockOffset( const IsoImage* image, DWORD block )
{
    //GetBlockOffset( image, block )
    // returns the offset of a block
    /*
    ARGS: 
        image: ptr to iso image struct
        block: which block to calculate with...
        Returns the byte offset of the specified block.    
    */
    // if HeaderSize == TRUE
    // block * BlockSize + HeaderSize
    // else
    // block * BlockSize + DataOffset
    return (fpos_t)(DWORD)block * (WORD)image->RealBlockSize + (image->HeaderSize ? image->HeaderSize : image->DataOffset);
    
}

int lmemfind( const char* ptr1, int len1, const char* ptr2, int len2 )
{
  // finds a string in memory and returns the offset.
  // when string is not found, -1 is returned
  /*
  ARGS:
    ptr1: points to the buffer that shall be searched through 
    len1: sizeof(buffer)
    ptr2: CDSignature (Identfies Primary Volume Descriptor)
    len2: length of cd signatur (typical: 5)  
  */
    register int i, j;
    int size = len1 - len2;  // size stops the loop before accessing wrong mem
    if( len1 < len2 )              // always a good idea ;)
        return -1;
    for( i = 0; i <= size; i++ )   // run through the buf, i is the offset
    {
        BOOL equal = TRUE;
        for( j = 0; j < len2; j++ )// run through the signature
        {
            if( ptr1[i + j] != ptr2[j] ) // 
            {
                equal = FALSE;     // found char not contained in signature.
                break;             // step to the next signature disposition
            }
        }    
        if( equal )
            return i;
    }

    return -1;                     // nothing was found :(
}

static int lstrcmpn( const char* str1, const char* str2, int len, BOOL casesensitive /*= TRUE*/ )
{
    return casesensitive ? strncmp( str1, str2, len) : strnicmp( str1, str2, len);
}

static wchar_t* litoa( int num, int digits /*= 1*/ )
{
    static wchar_t buffer[100];
    int i;
    for( i = 0; i < (int)_countof( buffer ); i++ )
        buffer[i] = '0';
    for( i = 0; num > 0; i++, num /= 10 )
        buffer[_countof( buffer ) - 1 - i] = (wchar_t)((num % 10) + '0');
    return buffer + _countof( buffer ) - max( i, digits );
}


size_t ReadDataByPos( FILE* stream, fpos_t position, size_t size, void* data )
{
    // reads data of speciefied len from specified offset
    /* ARGS;
        stream   - stream from which to read
        position - from where to read 
        size     - how many bytes to read ?
        data     - where to save the data ?
    */
    size_t read = 0;
    if (0 == fsetpos(stream, &position))
    {
       read = fread(data, 1, size, stream);
    }
    return read;
}

static size_t WriteDataByPos(FILE* stream, fpos_t position, size_t size, BYTE * data )
{
    size_t write = 0;

        
    if (0 == fsetpos(stream, &position))
    {
       write = fwrite(data, 1, size, stream);
    }
    return write;    
}


int iso_WriteBlock(IsoImage*img, int block, BYTE * data)
{
    // todo::: !!!
    // volumeSpaceSize muß um 1 erhöht werden.
    //if (img->RealBlockSize == 2352)    
    //ecc(data);
    BYTE * temp = malloc(img->RealBlockSize);
	if(!temp)
		return(FALSE);
	ZeroMemory(temp, img->RealBlockSize);
	memcpy((void*)temp, (void*) data, img->RealBlockSize);
    if(WriteDataByPos(img->stream, GetBlockOffset( img, block ), img->RealBlockSize, temp )
        != img->RealBlockSize){
            return(FALSE);
        }
        return(TRUE);
}



size_t ReadBlock( const IsoImage* image, DWORD block, size_t size, void* data )
{
    //DebugString( "ReadBlock" );
    /*
    ARGS:
        image: ptr to iso image struct
        block: which block to read ?
        size:  size of block
        data:  where to put the block ?
    */
    if(!image || !size || !data)
	{
		return( (size_t)NULL );
	}

    return ReadDataByPos( image->stream, GetBlockOffset( image, block ), size, data );
}

const char ZipHeader[] = {'p', 'k'};
const char RarHeader[] = {'r', 'a', 'r'};

static DWORD GetVolumeDescriptor( const IsoImage* image, PrimaryVolumeDescriptorEx* descriptor, DWORD startblk /*= 0*/ )
{
    DWORD i; 
    assert( descriptor );
    assert( image );

    ZeroMemory( descriptor, sizeof( *descriptor ) );
    for( i = startblk;ReadBlock(image,i,sizeof(descriptor->VolumeDescriptor),&descriptor->VolumeDescriptor ) == sizeof( descriptor->VolumeDescriptor );i++ )
    {
        if( lstrcmpn( (char*)descriptor->VolumeDescriptor.StandardIdentifier, CDSignature, sizeof( CDSignature )-1, TRUE ) == 0 &&
            (descriptor->VolumeDescriptor.VolumeDescriptorType == 1 || descriptor->VolumeDescriptor.VolumeDescriptorType == 2) )
        {
            DWORD block = i;
            char* buffer;
            // Found it!
            // trying to read root directory
			if(descriptor->VolumeDescriptor.VolumeDescriptorType ==  0xFF )
			{
				return(0);
			}
            buffer = (char*)malloc( descriptor->VolumeDescriptor.LogicalBlockSize_ );
            if( buffer && descriptor->VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_ &&descriptor->VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_ )
            {
                if( ReadBlock( image, descriptor->VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_,
                               descriptor->VolumeDescriptor.LogicalBlockSize_, buffer ) !=
                               descriptor->VolumeDescriptor.LogicalBlockSize_ )
                {
                    free( buffer );
                    continue;
                }
				//myDebugString("Root Directory found & buffered\r\n");
                // ok, we can read root directory...
				if( descriptor->VolumeDescriptor.VolumeDescriptorType == 2 )
					{
						descriptor->Unicode = TRUE;
						//myDebugString("image.Unicode = TRUE\n");
					}
                free( buffer );
				return(block);
            }


			   return(0);
        }
    }

    return 0;
}

const DWORD SearchSize = 0x100000; 


IsoImage* iso_attach(FILE* stream)
{
    IsoImage image;
    IsoImage* pimage;
    DWORD read;
    char ArcHeaderBuf[0x20];
    PrimaryVolumeDescriptor descriptor;
    char buffer[10000];
    PrimaryVolumeDescriptorEx descriptorex;
    DWORD fblock = 0;

    //myDebugString( "GetImage, searching VolumeDescripter CDSignature offset... ");

    ZeroMemory( &image, sizeof( image ) );
    
    image.stream = stream;
    image.DirectoryList = NULL;

    assert( sizeof( PrimaryVolumeDescriptor ) == 0x800 ); // check for size of descriptor
    
    // check for zip or rar archives
    if( 
        ReadDataByPos( image.stream, 0, sizeof( ArcHeaderBuf ), ArcHeaderBuf ) != sizeof( ArcHeaderBuf ) ||
        !lstrcmpn( ZipHeader, ArcHeaderBuf, sizeof( ZipHeader ), FALSE ) ||
        !lstrcmpn( RarHeader, ArcHeaderBuf, sizeof( RarHeader ), FALSE ) )
    {
        //myDebugString( "hmmm, this image can't be readed or it has zip or rar signature..." );
        return 0;
    }
    
    // Read the VolumeDescriptor (2k) until we find it, but only up to to 1MB
    
    for( ; image.DataOffset < SearchSize + sizeof( PrimaryVolumeDescriptor ); image.DataOffset += sizeof( PrimaryVolumeDescriptor ) )
    {
        char buffer[sizeof( PrimaryVolumeDescriptor ) + strlen(CDSignature)];
        int sig_offset ;

        if(ReadDataByPos( image.stream, LIT_HEADER_OFFSET + image.DataOffset,sizeof( buffer ), buffer ) != sizeof( buffer ) )
        {
            // Something went wrong, probably EOF?
            //myDebugString("Could not read complete VolumeDescriptor block");
         // CloseHandle( image.hFile ); TROELS: handled in iso_open
            return 0;
        }
        //  here we gonna have some problem (solved :))
        sig_offset = lmemfind( buffer, sizeof( buffer ), CDSignature, strlen(CDSignature));
        if( sig_offset >= 0 )
        {
            image.DataOffset += sig_offset-1;
            //myDebugString("OK\r\n");
           image.OffsetPrimaryVolumeDescriptor = (DWORD)(sig_offset+LIT_HEADER_OFFSET)-1;
        }    
        else
        {
            if( image.DataOffset >= SearchSize )
            {
                // Just to make sure we don't read in a too big file, stop after 1MB.
                //myDebugString("Reached 1MB without descriptor");
            //  CloseHandle( image.hFile ); TROELS: handled in iso_open
                return 0;
            }
            continue;
        }
         
        //myDebugString("Validating VolumeDescriptor... ");
        // Try to read a block
        read = ReadDataByPos( image.stream, LIT_HEADER_OFFSET + image.DataOffset, sizeof( descriptor ), &descriptor );
        
        if( read != sizeof( descriptor ) )
        {
            // Something went wrong, probably EOF?
            //myDebugString("Error: Could not read complete VolumeDescriptor block");
         // CloseHandle( image.hFile ); TROELS: handled in iso_open
            return 0;
        }

        if( lstrcmpn( (char*)descriptor.StandardIdentifier, CDSignature, sizeof( CDSignature )-1, TRUE) == 0 
            && descriptor.VolumeDescriptorType == 1 )
        {
            // Found it!
            image.Type = IMAGE_ISO9660;
            //myDebugString("OK. Volume Descriptor Validated.\r\n");
            break;
        }
   }

    if( image.DataOffset >= SearchSize )
    {
        // Just to make sure we don't read in a too big file.
        return 0;
    }

    image.RealBlockSize = descriptor.LogicalBlockSize_;

    //myDebugString("detecting next VolumeDescriptor CDSignature... ");
    // detect for next signature CDOO1
    if( ReadDataByPos( image.stream, LIT_HEADER_OFFSET + image.DataOffset + 6, sizeof( buffer ), buffer ) )
    {
        int pos = lmemfind( buffer, sizeof( buffer ), CDSignature, strlen(CDSignature));
        if( pos >= 0 )
        {
        //myDebugString("Found second VolumeDescriptor CDSignature.\r\n");
        image.RealBlockSize = pos +sizeof( CDSignature )-1; 
        image.HeaderSize = (LIT_HEADER_OFFSET + image.DataOffset) % image.RealBlockSize;
        image.OffsetSecondaryVolumeDescriptor = pos+LIT_HEADER_OFFSET+5;
        image.Type = IMAGE_JOILET;
        }
        else
        {
        //myDebugString("Error. No second VolumeDescriptor CDSignature was found.\r\n");    
        }        
    }

    // check for strange nero format
    if( image.DataOffset + LIT_HEADER_OFFSET == image.RealBlockSize * 0xa6 + image.HeaderSize )
    {
        //myDebugString("\r\nNero Format detected.");
        image.HeaderSize += image.RealBlockSize * 0x96;
        image.OffsetSecondaryVolumeDescriptor = image.DataOffset+LIT_HEADER_OFFSET+5;
        image.Type = IMAGE_NERO;
    }    
    else if( image.HeaderSize > 0xff )
    {
        image.HeaderSize = 0;
    } 

    ZeroMemory( &descriptorex, sizeof( descriptorex ) );

    //myDebugString("Buffering Volume Descriptors... ");
	fblock=16;
    for( image.DescriptorNum = 0; (fblock = GetVolumeDescriptor( &image, &descriptorex, fblock )) != 0 && image.DescriptorNum < 3;
         image.DescriptorNum++ )
    {
        //int a = sizeof(BootRecordVolumeDescriptor);
        image.VolumeDescriptors = (PrimaryVolumeDescriptorEx*)realloc( image.VolumeDescriptors,
            (image.DescriptorNum + 1) * sizeof( *image.VolumeDescriptors ) );
        image.VolumeDescriptors[image.DescriptorNum] = descriptorex;
        ZeroMemory( &descriptorex, sizeof( descriptorex ) );
		fblock++;
    }

    pimage = (IsoImage*)malloc( sizeof( *pimage ) );
    assert( pimage );
    *pimage = image;

    return pimage;
}

#ifdef COMPILE_FILESYSTEM_SUPPORT
BOOL iso_init(IsoImage* image)
{
   // Loads the direcotry tree into structures.
   // image ptr must be a valid iso image ptr.
   BOOL bOK = (image->DirectoryList != NULL);
   if(!bOK)
   {
      DWORD count = 0;
      bOK = iso_LoadAllTrees( image, 0, &count, TRUE ) && count;
      if(bOK && count )
      {
         image->DirectoryList = (Directory*)malloc( sizeof( Directory ) * count );
         bOK = iso_LoadAllTrees( image, &image->DirectoryList, &image->DirectoryCount, TRUE )  && image->DirectoryCount;
      }
   }
   if (bOK)
   {
      image->Index = 0;
   }
   return bOK;
}

static BOOL LoadTree( IsoImage* image, PrimaryVolumeDescriptorEx* desc, const wchar_t* path, DirectoryRecord* root,
                      Directory** dirs, DWORD* count, BOOL boot )
{
    DWORD block = root->LocationOfExtent_;
    DWORD size = root->DataLength_;
    DWORD i, k;
    char* data;
    DWORD position = 0;
    BOOL result = TRUE;
    
    DWORD offset = 0;
    DWORD num = 0;

    //myDebugString( "\r\nLoadTree...\r\n" );
    assert( image && root && count && desc );

    if( !block || !count )
        return TRUE;

    if( size > 10 * 1024 * 1020 )
        return FALSE;

    data = (char*)malloc( size );
    assert( data );
    if( !data )
        return FALSE;

    for( k = 0; position < size; position += desc->VolumeDescriptor.LogicalBlockSize_, k++ )
    {
        DWORD s = min( size - position, desc->VolumeDescriptor.LogicalBlockSize_ );
        if( ReadBlock( image, block + k, s, data + position ) != s )
        {
            free( data );
            return FALSE;
        }
    }
    
    while( offset < (size - 0x21) )
    {
        DirectoryRecord* record;
        Directory directory;
        while( (!data[offset]) && (offset < (size - 0x21)) )
            offset++;

        if( offset >= (size - 0x21) )
            break;

        record = (DirectoryRecord*)(data + offset);
        ZeroMemory( &directory, sizeof( directory ) );
        directory.Record = *record;
        directory.VolumeDescriptor = desc;
		
		// schauen ob gefundener record + angegebene Length Of File Identifier+1 == angegegebene Length of Directory Record+1 ist.
		// wer hat sich diese scheiss zeile ausgedacht???
		// <--- wie konnte ich nur diesen Kommentar schreiben???
		// Wenn man die Dateistruktur kennt, ist es nur klar das man das
		// so macht !!!
        if( (((int)record->LengthOfDirectoryRecord + 1) & ~1) <
            ((((int)sizeof( *record ) - (int)sizeof( *record->FileIdentifier ) + (int)record->LengthOfFileIdentifier) + 1) & ~1) )
            break;

// here we have the problem that no if is choosen ! (solved)
        if( (desc->Unicode && record->LengthOfFileIdentifier > 1) && (num > 1) )
        {
            UINT codepage = CP_UTF8;
            int i;
            
            for( i = 0; i < record->LengthOfFileIdentifier; i++ )
            {
                if( record->FileIdentifier[i] < 32 )
                {
                    WCHAR* uname = (WCHAR*)record->FileIdentifier;
                    //int length = record->LengthOfFileIdentifier / 2;
                    //codepage = CP_ACP;
                    codepage = GetACP();
                    for( i = 0; i < (record->LengthOfFileIdentifier / 2); i++ )
                        uname[i] = (WORD)((uname[i] >> 8) + (uname[i] << 8));

                    wcscpy(directory.FileName, (WCHAR*)record->FileIdentifier);

                    break;
                }
            }

            if( wcsrchr( directory.FileName, ';' ) )
                *wcsrchr( directory.FileName, ';' ) = 0;

            wcscat( wcscat( wcscpy( directory.FilePath, path ), (path[0]) ? L"\\" : L"" ), directory.FileName );

            if( dirs ) (*dirs)[*count] = directory;
            (*count)++;

            if( directory.Record.FileFlags & FATTR_DIRECTORY )
            {
                if( !LoadTree( image, desc, directory.FilePath, &directory.Record, dirs, count, FALSE ) )
                    result = FALSE;
            }
        }
        else if( !desc->Unicode && record->LengthOfFileIdentifier > 0 && num > 1 )
        {
            wcsncpy( directory.FileName, (wchar_t*)record->FileIdentifier, record->LengthOfFileIdentifier + 1);

            if( wcsrchr( directory.FileName, ';' ) )
                *wcsrchr( directory.FileName, ';' ) = 0;

            wcscat( wcscat( wcscpy( directory.FilePath, path ), path[0] ? L"\\" : L"" ), directory.FileName );

            if( dirs ) (*dirs)[*count] = directory;
            (*count)++;

            if( directory.Record.FileFlags & FATTR_DIRECTORY )
            {
                //( !LoadTree( image, directory.FilePath, &directory.Record, dirs, count ) )
                //{
                //    free( data );
                //    return FALSE;
                //}
                if( !LoadTree( image, desc, directory.FilePath, &directory.Record, dirs, count, FALSE ) )
                    result = FALSE;
            }
        }
        offset += record->LengthOfDirectoryRecord;
        num++;
    }
    if( desc->BootImageEntries && boot )
    {
        if( dirs )
        {
            Directory* dir = (*dirs) + (*count);
            ZeroMemory( dir, sizeof( *dir ) );
            if( wcslen( path ) )
            {
                wcscpy( dir->FilePath, wcscpy( dir->FileName, path ) );
                wcscat( dir->FilePath, L"\\" );
                wcscat( dir->FileName, L"\\" );
            }
            wcscat( dir->FilePath, L"boot.images" );
            wcscat( dir->FileName, L"boot.images" );
            dir->Record.FileFlags = 3;
        }
        (*count)++;
    }

    for( i = 0; i < desc->BootImageEntries && boot; i++ )
    {
        //myDebugString( "reading boot images" );
        if( dirs )
        {
            Directory* dir = (*dirs) + (*count);
            CatalogEntry* BootEntry = &desc->BootCatalog->Entry[i];
            wchar_t number[4] = L"00";
            wchar_t mediaType[50];
            const wchar_t* floppy = L"floppy";
            const wchar_t* harddisk  = L"harddisk";
            const wchar_t* no_emul = L"no_emul";
            const wchar_t* img = L".";
            //const char* img = ".img";
            
            ZeroMemory( dir, sizeof( *dir ) );
            number[1] = (char)((i % 10) + '0');
            number[0] = (char)(((i / 10) % 10) + '0');
            

            switch( BootEntry->Entry.BootMediaType )
            {
            case 0:
                wcscat( wcscat( wcscpy( dir->FileName, no_emul ), img ), number);
                dir->Record.DataLength_ = BootEntry->Entry.SectorCount * 0x200;
                break;
            case 1:
                wcscat( wcscat( wcscpy( dir->FileName, floppy ), L"_1.20."), number );
                dir->Record.DataLength_ = 0x50 * 0x2 * 0x0f * 0x200;
                break;
            case 2:
                wcscat( wcscat( wcscpy( dir->FileName, floppy ), L"_1.44."), number );
                dir->Record.DataLength_ = 0x50 * 0x2 * 0x12 * 0x200;
                break;
            case 3:
                wcscat( wcscat( wcscpy( dir->FileName, floppy ), L"_2.88."), number );
                dir->Record.DataLength_ = 0x50 * 0x2 * 0x24 * 0x200;
                break;
            case 4:
                {
                    MBR mbr;
                    wcscat( wcscat( wcscpy( dir->FileName, harddisk ), img ), number );
                    if( ReadBlock( image, BootEntry->Entry.LoadRBA, 0x200, &mbr ) )
                        if( mbr.Signature == (unsigned short)0xaa55 )
                            dir->Record.DataLength_ = (mbr.Partition[0].start_sect + mbr.Partition[0].nr_sects) * 0x200;
                        else
                        {
                            //myDebugString( "hard disk signature doesn't match" );
                            dir->Record.DataLength_ = BootEntry->Entry.SectorCount * 0x200;
                        }
                    else
                    {
                        //myDebugString( "can't read MBR for hard disk emulation" );
                        dir->Record.DataLength_ = BootEntry->Entry.SectorCount * 0x200;
                    }
                }
                break;
            default:
                wcscpy( mediaType, L".unknown" );
                dir->Record.DataLength_ = BootEntry->Entry.SectorCount * 0x200;
                break;
            }
            if( wcslen( path ) )
                wcscat( wcscat( wcscpy( dir->FilePath, path ), L"\\boot.images\\" ), dir->FileName );
            else
                wcscat( wcscpy( dir->FilePath, L"boot.images\\" ), dir->FileName );

            dir->Record.LocationOfExtent_ = BootEntry->Entry.LoadRBA;
            dir->VolumeDescriptor = desc;
        }
        (*count)++;
    }

    free( data );

    return result;
}

BOOL iso_LoadAllTrees( IsoImage* image, Directory** dirs, DWORD* count, BOOL boot )
{
    if( image->DescriptorNum < 2 )
        return LoadTree( image, image->VolumeDescriptors, L"",
                         &image->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory,
                         dirs, count, boot );
    else
    {
        BOOL result = FALSE;
        DWORD i;
        for( i = 0; i < image->DescriptorNum; i++ )
        {
            wchar_t session[50] = L"session";
            wcscat( session, litoa( i + 1, 1 ) );
            result |= LoadTree( image, image->VolumeDescriptors + i, session,
                                &image->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory,
                                dirs, count, boot );
        }
        return result;
    }
}

BOOL iso_ExtractFile( IsoImage* image, Directory* directory, const TCHAR* path)
{
    // extracts the specified file
    
    //ARGS:
    //    image:     ptr to iso image structure.
    //    directory: ptr to directory structure
    //    path:      where to save the stuff
    
	HANDLE 	file = NULL;
    DWORD 	size = directory->Record.DataLength_;
    DWORD 	block = directory->Record.LocationOfExtent_;
    DWORD 	sector = directory->VolumeDescriptor->VolumeDescriptor.LogicalBlockSize_;
	char* 	buffer = (char*)malloc( sector );
    int 	i;
	
    assert( image && directory && path );
	
    if( !buffer )
    {
        return FALSE;
    }
    //myDebugString("iso_ExtractFile:\r\n");
    for(i=0 ; (int)size >= 0; size -= sector , block++ )// subtract sector num from size, increment block
    {
        DWORD cur_size = min( sector, size );           // wenn sector kleiner size, sector zuweisen
        if( cur_size && ReadBlock( image, block, cur_size, buffer ) != cur_size )
        {
            // (( wenn cur_size == !0 )) &&  ReadBlock(size) == true.
            //myDebugString( "can't read data" );
            if( file )
                CloseHandle( file );
            free( buffer );
            return FALSE;
        }

        if( !file )
        {
            file = CreateFile( path, GENERIC_WRITE, FILE_SHARE_READ, 0, CREATE_ALWAYS,
                               FILE_ATTRIBUTE_ARCHIVE, 0 );

            if( !file || file == INVALID_HANDLE_VALUE )
            {
                //myDebugString( "can't create file" );
                return FALSE;
            }
        }

        if( cur_size )
        {
            DWORD write;
            WriteFile( file, buffer, cur_size, &write, 0 );
            if( write != min( sector, size ) )
            {
                //myDebugString( "can't write file" );
                if( file )
                    CloseHandle( file );
                free( buffer );
                return FALSE;
            }
        }        
    }

    if( file )
    {
        struct _utimbuf tbuf;
        //SetFileTime( file, &dtime, &dtime, &dtime ); 
        //timestamping open file doesn't work on all filesystem types. TROELS
        CloseHandle( file );

        tbuf.actime = tbuf.modtime = iso_gettime(&directory->Record.RecordingDateAndTime);
        _utime(path, &tbuf );
    }
    free( buffer );

    return TRUE;
}
#endif

time_t iso_gettime(const VolumeDateTime* src)
{
   struct tm tm;
   tm.tm_year = src->Year;
   tm.tm_mon  = src->Month-1;
   tm.tm_mday = src->Day;
   tm.tm_hour = src->Hour;
   tm.tm_min  = src->Minute;
   tm.tm_sec  = src->Second;
   return mktime(&tm);
}

const wchar_t* iso_getlabel(IsoImage* handle)
{
   return (const wchar_t*)handle->VolumeDescriptors->VolumeDescriptor.VolumeIdentifier;
}
