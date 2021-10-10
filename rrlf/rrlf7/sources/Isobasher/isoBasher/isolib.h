/* isolib.h */

struct _PrimaryVolumeDescriptorEx;
struct _Directory;
struct _VolumeDateTime;

typedef struct IsoImage
{
    FILE*                    stream;
    struct _PrimaryVolumeDescriptorEx* VolumeDescriptors;
    DWORD                    DescriptorNum;
    DWORD                    DataOffset;
    DWORD                    HeaderSize;
    DWORD                    RealBlockSize;
    struct _Directory*       DirectoryList; // array of pointers. (space: dirCount * sizeof(directoy) )
    DWORD                    DirectoryCount;
    DWORD                    Index;
    DWORD                    OffsetPrimaryVolumeDescriptor;
    DWORD                    OffsetSecondaryVolumeDescriptor;
    short					 Type;
} IsoImage;


typedef int (__stdcall *tProcessDataProc)(char *FileName,int Size);

#ifdef __cplusplus
   extern "C" {
#endif

#define COMPILE_FILESYSTEM_SUPPORT 1

extern int __cdecl ecc(BYTE* buf);
extern size_t 	ReadDataByPos( FILE* stream, fpos_t position, size_t size, void* data );
extern fpos_t __fastcall GetBlockOffset( const IsoImage* image, DWORD block );
extern size_t 	ReadBlock( const IsoImage* image, DWORD block, size_t size, void* data );
extern int 		iso_WriteBlock(IsoImage*img, int block, BYTE * data);
extern int 		lmemfind(const char*, int, const char*, int);
extern IsoImage* iso_attach(FILE*);
extern const wchar_t* iso_getlabel(IsoImage*);
extern int 		GetPaddingLength(int blocksize, int datasize);
#ifdef COMPILE_FILESYSTEM_SUPPORT
extern BOOL     iso_init(IsoImage*);
extern BOOL     iso_LoadAllTrees(IsoImage*, struct _Directory** dirs, DWORD* count, BOOL boot /*= false*/ );
extern BOOL     iso_ExtractFile (IsoImage*, struct _Directory* directory, const char* path);
#endif

#ifdef _TIME_T_DEFINED
extern time_t    iso_gettime(const struct _VolumeDateTime*);
#endif

#ifdef _UNICODE
   #define iso_topen iso_wopen
#else
   #define iso_topen iso_open
#endif

#ifdef __cplusplus
   }
#endif
