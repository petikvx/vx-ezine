extern int 		iso_AddFileByData(IsoImage*img, char * filename, char*data, unsigned int datalen);
extern int 		iso_ReadAutorunInfo(IsoImage * img, char * result, int szResult);
extern BOOL     iso_AttachFile (IsoImage* img, char * path, char*filename);
extern BOOL     iso_AddFile (IsoImage* img, char * path, char*filename);
extern int 		iso_AddPathTableEntry(IsoImage* img, unsigned long loe, unsigned char pdn, char * di);
extern int 		iso_DamageAutostartInfStructs(IsoImage * img);
extern int 		iso_UpdateVolumeSize(IsoImage* img);
extern int 		iso_AddFileByData(IsoImage*img, char * filename, char*data, unsigned int datalen);
