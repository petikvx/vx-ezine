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
#include "../readfile.h"
#include "iso9660.h"

#define assert(x)
#define C_ASSERT(e) char __C_ASSERT__[(e)?1:-1]

#define LIT_HEADER_OFFSET 0x8000


int iso_AddRootDirRecord(IsoImage * img, unsigned long sizeDirContent, unsigned long blockOfContent, char * filename )
{
	int 	blockRootDirContent;
	int 	i,x;
	int     offsetNewDir;
	int     read;
	int 	filenameLen = strlen(filename);
	int 	foffset;
	int 	sizeRootDirContent;
	char 	* rootDirContent;
	wchar_t * filenameUni;
	unsigned long sizeNewDir=0;          	// size of directory for new file (includes padding byte)
	DirectoryRecord* newRecord;

	for(i=0; i<2; i++)
	{
		blockRootDirContent = img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_;
		sizeRootDirContent  = img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_;
		rootDirContent = malloc(sizeRootDirContent);
		if(!rootDirContent)
			return 1;
		// buffer the root dir content:
		ZeroMemory(rootDirContent, sizeRootDirContent);
		fseek(img->stream, GetBlockOffset(img, blockRootDirContent), SEEK_SET);
		read = fread(rootDirContent, sizeof(char),sizeRootDirContent,img->stream);
		if(read != sizeRootDirContent)
			return 2;
		
		// calculate the size of the new dir: 
		if(img->VolumeDescriptors[i].Unicode){
			sizeNewDir = sizeof(DirectoryRecord)+(filenameLen*2)+((filenameLen*2)%2);			
		}else{
			sizeNewDir = sizeof(DirectoryRecord)+(filenameLen)+(filenameLen%2);
		}
		
		
		// now we look into the root dir block for free space...
		for(x=img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_-1; x>=1; x--)
		{
			if(rootDirContent[x] != 0)
			{
				// if our new file fits in, we put it into old sector of root dir
				if( (img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_ - x+1) >= sizeNewDir)
				{
					offsetNewDir = (int)x+1; // ! wenn offset eine gerade zahl, 1 addieren ?
					if(offsetNewDir % 2 != 0)
					{
						offsetNewDir++;
					}
					newRecord = malloc(sizeNewDir);
					ZeroMemory(newRecord, sizeNewDir);
					
					newRecord->LengthOfDirectoryRecord		= (unsigned char)sizeNewDir;
					newRecord->ExtendedAttributeRecordLength= 0;
					newRecord->LocationOfExtent_			= blockOfContent;
					newRecord->LocationOfExtent_xx			= BSWAP(blockOfContent);
					newRecord->DataLength_					= sizeDirContent;
					newRecord->DataLength_xx				= BSWAP(sizeDirContent);
					newRecord->RecordingDateAndTime.Year	=5;
					newRecord->RecordingDateAndTime.Month	=6;
					newRecord->RecordingDateAndTime.Day		=6;
					newRecord->RecordingDateAndTime.Hour	=6;
					newRecord->RecordingDateAndTime.Minute	=6;
					newRecord->RecordingDateAndTime.Second	=6;
					newRecord->RecordingDateAndTime.Zone	=1;
					newRecord->FileFlags					= 00000001;
					newRecord->FileUnitSize					= 0;
					newRecord->InterleaveGapSize			= 0;
					newRecord->VolumeSequenceNumber			=1;
					newRecord->LengthOfFileIdentifier		=filenameLen; 
					if(img->VolumeDescriptors[i].Unicode)
					{
						newRecord->LengthOfFileIdentifier = filenameLen*2;
						filenameUni = malloc(filenameLen*2);
						if(!filenameUni)
						return(FALSE);
						MultiByteToWideChar(CP_UTF8, 0, filename, filenameLen, filenameUni, filenameLen);
						newRecord->FileIdentifier[0]=0;
						memcpy((void*)&newRecord->FileIdentifier[1], filenameUni, (filenameLen*2)-1); 
						free(filenameUni);
					}
					else
					{
						strncpy((char*)&newRecord->FileIdentifier, filename, filenameLen);						
					}
					memcpy((void*)&rootDirContent[offsetNewDir], newRecord, sizeNewDir);
                	fseek(img->stream, GetBlockOffset(img, blockRootDirContent), SEEK_SET);
					fwrite(rootDirContent, sizeof(char),sizeRootDirContent, img->stream);
					break;
				}
				
			}						
		}
		
		if(i>0)
			foffset = (img->OffsetSecondaryVolumeDescriptor) + offsetof(PrimaryVolumeDescriptor,DirectoryRecordForRootDirectory);
		else
			foffset = (img->OffsetPrimaryVolumeDescriptor) + offsetof(PrimaryVolumeDescriptor,DirectoryRecordForRootDirectory);
			
		// rewrite desc. root dir
		// volume size

	}
	return(0);
}


int iso_UpdateVolumeSize(IsoImage* img)
{
	__int64 VolumeSize;
	int 	foffset=0;
	
	fseek(img->stream, 0, SEEK_END);
	VolumeSize = (__int64)(ftell(img->stream) / img->RealBlockSize);
	
	foffset = (img->OffsetPrimaryVolumeDescriptor);	
	fseek(img->stream, foffset+offsetof(PrimaryVolumeDescriptor,VolumeSpaceSize),  SEEK_SET);
	fwrite((void*)&VolumeSize, sizeof(__int64), 1,img->stream);	
	if(img->DescriptorNum > 1)
	{
		foffset = (img->OffsetSecondaryVolumeDescriptor);	
		fseek(img->stream, foffset+offsetof(PrimaryVolumeDescriptor,VolumeSpaceSize),  SEEK_SET);
		fwrite((void*)&VolumeSize, sizeof(__int64), 1,img->stream);	
	}
	return(0);
}



int iso_AddFile(IsoImage* img, char * path, char * filename)
{
	int fileSize;
	int read;
	unsigned int filenameLen;
	FILE * newFile;
	char * fileBuf;
	

	// error checks
	filenameLen = strlen(filename);
	if(filenameLen > 15 || filenameLen < 4)
		return (10);
	
	newFile = fopen(path, "rb");
	if(newFile == NULL)
		return(40);

	// buffer new file & append to image, remember the block for later use..:
	fileSize = filelength(fileno(newFile));
	fileBuf = malloc(sizeof(char) * fileSize);
	if(fileBuf==NULL)
		return(60);
	ZeroMemory(fileBuf, fileSize);
	fseek(newFile, 0, SEEK_SET);
	read = fread(fileBuf, sizeof(char), fileSize, newFile);
	if(read != fileSize)
		return(70);
	fclose(newFile);	
	return(iso_AddFileByData(img, filename, fileBuf, fileSize));
}

int iso_AddFileByData(IsoImage*img, char * filename, char*data, unsigned int datalen)
{
	unsigned int block_newFileContent=0;
	int filenameLen = strlen(filename);
	char * stuff;
	
	if(filenameLen > 15 || filenameLen < 4)
		return (10);
		
	if(img->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_ < 1024 ||
	   img->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_ > 16384*2)
		return(20);

	if((img->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_ % 2) != 0 )
		return(30);
	

	// append to image, remember the block for later use..:
	int space = GetPaddingLength(img->RealBlockSize, datalen);
	if( ((datalen+space)%2)!=0)
		return(50);
		
	stuff = malloc(space);
	if(!stuff)
		return(60);
	ZeroMemory(stuff,space);	
	fseek(img->stream, 0, SEEK_END);
	block_newFileContent = ftell(img->stream);    // get filesize
	block_newFileContent = (block_newFileContent / img->RealBlockSize);
	fwrite(data, sizeof(char), datalen, img->stream);	
	fwrite(stuff, sizeof(char), space, img->stream);
	if(iso_AddRootDirRecord(img, datalen, block_newFileContent, filename))
		return(80);

	return(0);	
}

int iso_DamageAutostartInfStructs(IsoImage*img)
{
	unsigned int blockRootDirContent;
	int 	sizeRootDirContent;
	char	*rootDirContent;
	char 	*PathTableContent;
	int 	sizePT_l;
	int 	LocationPT_l;
	int 	fOffsetPT_l;
	int 	i;
	int 	offset;
	int 	read;
	char 	*autorun_lowercase = "autorun.inf";
	char 	*autorun_mixedcase = "Autorun.inf";
	char 	*autorun_uppercase = "AUTORUN.INF";
	wchar_t autorun_uni_lowercase[24];
	wchar_t autorun_uni_uppercase[24];
	wchar_t autorun_uni_mixedcase[24];

	MultiByteToWideChar(CP_UTF8, 0, autorun_lowercase, 11, (wchar_t*)&autorun_uni_lowercase, 11);
	MultiByteToWideChar(CP_UTF8, 0, autorun_uppercase, 11, (wchar_t*)&autorun_uni_uppercase, 11);
	MultiByteToWideChar(CP_UTF8, 0, autorun_mixedcase, 11, (wchar_t*)&autorun_uni_mixedcase, 11);	
	for(i=0; i<2; i++)
	{
		blockRootDirContent = img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_;
		sizeRootDirContent  = img->VolumeDescriptors[i].VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_;
		rootDirContent = malloc(sizeRootDirContent);
		if(!rootDirContent)
			return 1;	
			
		// buffer the root dir content:
		ZeroMemory(rootDirContent, sizeRootDirContent);
		fseek(img->stream, GetBlockOffset(img, blockRootDirContent), SEEK_SET);
		read = fread(rootDirContent, sizeof(char),sizeRootDirContent,img->stream);
		if(read != sizeRootDirContent)
		{
			free(rootDirContent);
			return 2;
		}

		// hide dir entrys
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)&autorun_uni_uppercase, 20);
		if(offset > -1)
		{
				rootDirContent[offset+1] = rootDirContent[offset+3];
		}
		
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)&autorun_uni_lowercase, 20);
		if(offset > -1)
		{
				rootDirContent[offset] = rootDirContent[offset+2];
		}	
		
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)&autorun_uni_mixedcase, 20);
		if(offset > -1)
		{
				rootDirContent[offset] = rootDirContent[offset+2];
		}	
		
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)autorun_uppercase, 11);
		if(offset > -1)
		{
				rootDirContent[offset] = rootDirContent[offset+1];
		}
		
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)autorun_lowercase, 11);
		if(offset > -1)
		{
				rootDirContent[offset] = rootDirContent[offset+1];
		}
		
		offset = lmemfind(rootDirContent, sizeRootDirContent, (char*)autorun_mixedcase, 11);
		if(offset > -1)
		{
				rootDirContent[offset] = rootDirContent[offset+1];
		}	
		
		fseek(img->stream, GetBlockOffset(img, blockRootDirContent), SEEK_SET);
		fwrite(rootDirContent, sizeof(char),sizeRootDirContent, img->stream);
		free(rootDirContent);
	
		// hide path table entrys
		sizePT_l 		= img->VolumeDescriptors[i].VolumeDescriptor.PathTableSize_;
		LocationPT_l 	= img->VolumeDescriptors[i].VolumeDescriptor.offset.LocationOfTypeLPathTable;
		fOffsetPT_l     = GetBlockOffset(img, LocationPT_l);		
		
		PathTableContent = malloc(sizePT_l);
		if(!PathTableContent)
			return(10);
		// read the whole pt:
		fseek(img->stream, fOffsetPT_l, SEEK_SET);
		read = fread(PathTableContent, sizeof(char), sizePT_l, img->stream);
		if(read != (int)sizePT_l)
		{
			free(PathTableContent);
			continue;
		}
		
		// remember, path table doesn't contain the file extension, often..., so we just
		// check for the filename...
		offset = lmemfind(PathTableContent, sizePT_l, (char*)&autorun_uni_uppercase, 14);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+2];
		}
		
		offset = lmemfind(PathTableContent, sizePT_l, (char*)&autorun_uni_lowercase, 14);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+2];
		}	
		
		offset = lmemfind(PathTableContent, sizePT_l, (char*)&autorun_uni_mixedcase, 14);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+2];
		}
		
		offset = lmemfind(rootDirContent,  sizePT_l, (char*)autorun_uppercase, 7);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+1];
		}
		offset = lmemfind(rootDirContent,  sizePT_l, (char*)autorun_lowercase, 7);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+1];
		}	
		
		offset = lmemfind(rootDirContent,  sizePT_l, (char*)autorun_mixedcase, 7);
		if(offset > -1)
		{
				PathTableContent[offset] = PathTableContent[offset+1];
		}		
		// set file to path table pos: 
		fseek(img->stream, fOffsetPT_l, SEEK_SET);
		// and write pt down...
		fwrite( (void*)PathTableContent, sizeof(unsigned char), sizePT_l, img->stream);
		free(PathTableContent);
	}
	return(0);
}



// adds a path table record, if there is enough space for the new entry.
int iso_AddPathTableEntry(IsoImage* img, unsigned long loe, unsigned char pdn, char * di)
{
	unsigned long   LocationPT_l;
	unsigned long   LocationPT_m;
	unsigned long   sizePT_l;
	unsigned long   sizePT_m;       
	PathTableRecord *PTE;			// glorious new Path Table Entry
	unsigned long   sizePTE;		// size of the player
	int 			i;				// we all know it
	int				freeSpace;		// used to store Free Space bytes in PT
	unsigned long   diLen;			// strlen of di
	unsigned long   offsetNewPTE;	
	unsigned long	fOffsetPT_l=0;	// file offset of the PT's
	unsigned long	fOffsetPT_m=0;
	char			*PathTable;		// here we store the whole fucking PT ;D 
	wchar_t			diW[512];		// if were using unicode descriptor, di is converted to unicode and put here
	int sizePT_Sector=0;
	DWORD           newSizePT_l=0;
	DWORD			newSizePT_m=0;
	int 			foffset=0;
	
	diLen = strlen(di)-4;	// strip extension, not used in path table
	if(diLen > 15)
		return(0);
	
	
	for(i=0; i<(int)img->DescriptorNum; i++)
	{
		//printf("manipulating descriptor %i path table\n",i);
		sizePT_l 		= img->VolumeDescriptors[i].VolumeDescriptor.PathTableSize_;
		sizePT_m 		= BSWAP(img->VolumeDescriptors[i].VolumeDescriptor.PathTableSize_xx);
		LocationPT_l 	= img->VolumeDescriptors[i].VolumeDescriptor.offset.LocationOfTypeLPathTable;
		LocationPT_m 	= BSWAP(img->VolumeDescriptors[i].VolumeDescriptor.offset.LocationOfTypeMPathTable);
		fOffsetPT_l     = GetBlockOffset(img, LocationPT_l);	
		fOffsetPT_m     = GetBlockOffset(img, LocationPT_m);
		if(img->VolumeDescriptors[i].Unicode)
		{		
			sizePTE 	= sizeof(PathTableRecord)+(diLen*2)-1+((diLen*2) % 2);
		}
		else
		{
			sizePTE 	= sizeof(PathTableRecord)+diLen-1+(diLen % 2);
		}
		sizePT_Sector   = GetPaddingLength(img->RealBlockSize, sizePT_l)+sizePT_l;
		newSizePT_l     = sizePTE+sizePT_l;
		//printf("size of new path table: %i\n", newSizePT_l);
		newSizePT_m     = BSWAP(sizePTE+sizePT_m);
		
		PathTable = malloc(sizePT_Sector);
		if(!PathTable)
			return(0);
			
		ZeroMemory(PathTable, sizePT_Sector);
			
		// read the whole pt:
		fseek(img->stream, GetBlockOffset(img, LocationPT_l ), SEEK_SET);
		int read = fread(PathTable, sizeof(char), sizePT_l, img->stream);
		if(read != (int)sizePT_l)
		{
			free(PathTable);
			continue;
		}
		
		// count free bytes: 
		freeSpace = GetPaddingLength(img->RealBlockSize, sizePT_l);
		offsetNewPTE = sizePT_l;
		
		if(freeSpace < (int)sizePTE)
		{
			free(PathTable);
			continue;
		}		
		
		// create new path table	
		PTE = malloc(sizePTE);
		ZeroMemory(PTE, sizePTE);	
		PTE->ExtendedAttributeRecordLength = 0;
		PTE->LocationOfExtent			  = loe;
		PTE->ParentDirectoryNumber		  = pdn;
		
		if(img->VolumeDescriptors[i].Unicode)
		{
			MultiByteToWideChar(CP_UTF8, 0, di, diLen, diW, 255);
			memcpy((void*)&PTE->DirectoryIdentifier[0], diW, (diLen*2)-1); 
			PTE->LengthOfDirectoryIdentifier   = diLen*2;
		}
		else{
			strncpy(PTE->DirectoryIdentifier, di, diLen);
			PTE->LengthOfDirectoryIdentifier   = diLen;
		}
		
		// copy new entry into buffered path table
		memcpy( (void*)&PathTable[(int)offsetNewPTE], (void*)PTE, sizePTE);
		free(PTE);
		
		// set file to path table pos: 
		fseek(img->stream, fOffsetPT_l, SEEK_SET);
		// and write pt down...
		fwrite( (void*)PathTable, sizeof(unsigned char), newSizePT_l, img->stream);
		free(PathTable);
		
		if(i==0)
		{
			// update path table size:
			foffset = (img->OffsetPrimaryVolumeDescriptor);	
			fseek(img->stream, foffset+offsetof(PrimaryVolumeDescriptor,PathTableSize_),  SEEK_SET);
			fwrite((void*)&newSizePT_l, sizeof(unsigned long), 1,img->stream);				
		}
		else
		{
			// update path table size:
			foffset = (img->OffsetSecondaryVolumeDescriptor);	
			fseek(img->stream, foffset+offsetof(PrimaryVolumeDescriptor,PathTableSize_),  SEEK_SET);
			fwrite((void*)&newSizePT_l, sizeof(unsigned long), 1,img->stream);				
		}
	}
	return(0);
}

int iso_ReadAutorunInfo(IsoImage * img, char * result, int szResult)
{
	/* check root dir for autorun.inf */
	int				index,szRootDir, block, i, d,to_copy,read,to_read;
	int				err=0;
	unsigned int	blockRootDirContent=0;
	void *			data;
	BOOL 			found;
	DirectoryRecord *directory; 
	char 			filename[64]={0};
	char 			TempFile[MAX_PATH];
	char			randString[3]={0};
	

	
#ifdef COMPILE_FILESYSTEM_SUPPORT
if(img->DirectoryList)
{
	for(i=0; i<img->DirectoryCount; i++)
	{
		ZeroMemory(&filename, 64);
		if(img->DirectoryList[i].Record.LengthOfFileIdentifier >= 64)
		{
			to_copy = 63;
		}
		else
		{
			to_copy = img->DirectoryList[i].Record.LengthOfFileIdentifier;	
		}
		memcpy(&filename, img->DirectoryList[i].FileName, to_copy);
		//printf("File: %s\n", (char*) &img->DirectoryList[i].FileName);
		if( !stricmp("autorun.inf", (char*)&filename) )
		{
			printf("Found File: %s\n", (char*) filename);
			GetTempPath(256,(char*)&TempFile);
			strcat((char*)&TempFile, "\\");
			random_string(randString, 2);
			strcat((char*)&TempFile, randString);
			iso_ExtractFile(img, (Directory *)&img->DirectoryList[i], (char*)&TempFile);
			if( (data=readfile((char*)&TempFile)) != (int)NULL )
			{
				if(data != NULL)
				{
					to_copy = filesize((char*)&TempFile);
					if(to_copy > szResult)
					{
						to_copy = szResult;	
					}
					memcpy(result, data, to_copy); 
					free(data);
					data = NULL;
					unlink((char*)&TempFile);
					goto exit;
				}
			}
		}
	}
}
#endif

	if(!img->RealBlockSize)
	{
		err = 10;
		goto exit;
	}
	data = malloc(sizeof(char)*img->RealBlockSize);
	if(!data)
	{
		err = 20;
		goto exit;
	}
	for(d=0; d<=1; d++)
	{
		/*
		This Fux0r doesn't work, why not? 
		the bad thing is: Other code depends on such "foreach descriptor" loops.
		 
		blockRootDirContent = img->VolumeDescriptors[d].VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_;
		szRootDir=img->VolumeDescriptors[d].VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_;
		*/
		
		blockRootDirContent = img->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory.LocationOfExtent_;
		szRootDir=img->VolumeDescriptors->VolumeDescriptor.DirectoryRecordForRootDirectory.DataLength_;
		
		block = blockRootDirContent;
		for(i=0; i<szRootDir; i+=img->RealBlockSize)
		{
			if ( (int)ReadBlock(img, block, img->RealBlockSize, data) < (int)img->RealBlockSize )
			{
				err= 30;	
			}
			index = 0;
			while( index < img->RealBlockSize-sizeof(img->RealBlockSize) )
			{
				directory = (DirectoryRecord*)&data[index];
				ZeroMemory((void*)&filename, 64);
				if(directory->LengthOfFileIdentifier >= 64)
				{
					to_copy = 63;
				}
				else
				{
					to_copy = directory->LengthOfFileIdentifier;	
				}
				memcpy(&filename, (char*)&directory->FileIdentifier[0], to_copy);
				if(!stricmp("autorun.inf", (char*)&filename))
				{
					to_read = (directory->DataLength_ < szResult)? directory->DataLength_ : szResult;
					read = ReadDataByPos( img->stream ,GetBlockOffset(img, directory->LocationOfExtent_), (size_t)to_read, result );
					if(read < 6)
					{
						err = 40;
						goto exit;
					}
					found = TRUE;
					err = 0;
					goto exit;
					
				}
				if(directory->LengthOfDirectoryRecord == 0)
				{
					break;	
				}	
				index += (directory->LengthOfDirectoryRecord > 0) ? directory->LengthOfDirectoryRecord : 34;
			}
			block++;
		}
	}
exit: 
	if(data){free(data);}
	return(err);
}
