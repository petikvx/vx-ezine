/*-----------------------------------------------------------------*/
/* (C) by Hard Wisdom "OPTLINKer UnPacker" 26-Oct-1998y v1.0       */
/*                                                                 */
/*          Especially for ACCEL EDA (CAD software)                */
/*                                                                 */
/*-----------------------------------------------------------------*/

/* TCC.EXE -ml -eUNOPT UNOPT.C UNOPTRIP.ASM                        */

#include <alloc.h>
#include <mem.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern unsigned short OptLink_UnPack(void far *Inp,
                                     void far *Outp,
                                     unsigned short far *W3);

/*-----------------------------------------------------------------*/
/*                      P R O C E S S I N G                        */
/*-----------------------------------------------------------------*/
void DoRoll(void) {
 /* static int i=0; char s[]="|/-\\"; putchar(s[i++]); putchar('\b'); i&=3; */
}

/*-----------------------------------------------------------------*/
void SayError(char* Msg) {
 printf("\nError: %s !\n",Msg); exit(-1);
}

/*-----------------------------------------------------------------*/
unsigned long Align(unsigned long Data, int Border) {
 volatile unsigned long l=Data,ll=Border,q=-1;
 q=~(q << ll)+1; return (l+q-1)/q*q;
}


/*-----------------------------------------------------------------*/
int UnPackFile2File(char *Inp, char *Outp) {
 FILE *InF, *OutF; char Buf[0x4000]; int e,i,j,jj,q,qq,qf;
 unsigned long NewExe,l,ll,l2,ll2; unsigned short SegPos,SegSh,SegCnt,w,w2,w3;
 struct { unsigned short SectorNum,FileArea,Flags,MemArea; } SegT[0x100];
 struct { unsigned short ResSh, ResLen, Flags, Id; unsigned long DD; } ResItem;
 struct { unsigned short Id, Num; unsigned long DD; } ResDir;
 unsigned char *p,*pp,*p2,*p22; char RT[4]={0,2,3,5};

 if ((InF=fopen(Inp,"rb"))==NULL) SayError("Unable to open input file");
 if ((OutF=fopen(Outp,"w+b"))==NULL) SayError("Unable to create output file");

 if (!fread(Buf,0x40,1,InF)) SayError("Unable to read file header");
 if (memcmp(Buf,"MZ",2) && memcmp(Buf,"ZM",2)) SayError("Bad EXE signature");
 memcpy(&NewExe,&Buf[0x3C],sizeof(NewExe));
 if (!NewExe) SayError("Input file is non New EXE file");

 printf(" þ NEW EXE Position= %.8lXh\n",NewExe); fseek(InF,NewExe,SEEK_SET);
 if (!fread(Buf,0x40,1,InF)) SayError("Unable to read New EXE file header");

 if (memcmp(Buf,"NE",2)) SayError("This is a non NE-EXE file");
 memcpy(&SegPos,&Buf[0x22],2);
 memcpy(&SegCnt,&Buf[0x1C],2);
 memcpy(&SegSh,&Buf[0x32],2);
 printf(" þ Segment table at: %.4Xh (%u Items)\n",SegPos,SegCnt);
 if (SegCnt>0x100) SayError("Too much segments, unable to proceed");
 fseek(InF,SegPos+NewExe,SEEK_SET);
 if (fread(SegT,8,SegCnt,InF)!=SegCnt)
  SayError("Unable to read segments table");

 l=SegT[0].SectorNum; l<<=SegSh; fseek(InF,l+0x17F,SEEK_SET);
 if (!fread(Buf,0x100,1,InF)) SayError("Unable to read loader signature");
 if (memcmp(Buf,"OPTLOADER",9)) SayError("This is non OPTLINK packed file");
 printf("\n'%s'\n\n",Buf); ll=Align(l,9);
 if (SegSh>9) SayError("Unsupported Seg.shift value");
 if (ll>sizeof(Buf)) SayError("STUB + Headers too large, unable to proceed");
 memset(Buf,'*',ll); fseek(InF,0,SEEK_SET);
 e=fread(Buf,l,1,InF); e+=fwrite(Buf,ll,1,OutF);
 if (e!=2) SayError("Unable to transfer file headers");

 printf(" þ Processing segments. . .\n"); p=malloc(0xFFFF); pp=malloc(0xFFFF);
 if (!p || !pp) SayError("No memory for temporary buffers");
 for (i=0;i<SegCnt;i++) { l2=SegT[i].SectorNum; l2<<=SegSh;
  if (i==SegCnt-1) { fseek(InF,0,SEEK_END); ll2=ftell(InF); }
  else { ll2=SegT[i+1].SectorNum; ll2<<=SegSh; }
  printf("    Segment %u %.8lXh - %.8lXh > ",i,l2,ll2);
  if ((ll2-l2)>0xFFFF) SayError("Segment too large");
  fseek(InF,l2,SEEK_SET); e=fread(p,ll2-l2,1,InF);
  memset(pp,'*',0xFFFF);
  if (i==0) { memcpy(pp,p,ll2-l2); ll2-=l2;
  } else { memcpy(&w,p,2); w2=OptLink_UnPack(p,pp,&w3); memcpy(pp+w2,&w,2);
   printf("(%.4Xh) ",w); if (w) SegT[i].Flags|=0x100; ll2=w2+w*8+2;
   p2=p+w3+2; p22=pp+w2+2; jj=w; SegT[i].Flags&=0xFFF7;
   while (jj>0) { j=(unsigned char)(*(p2+1)); jj-=j;
    if (jj<0) SayError("Relo-subcounter too big");
    if (j<=0) SayError("Relo-subcounter too small");
    q=(unsigned char)(*p2); p2+=2;

    switch (q >> 3) {
     case 0: qq=*(unsigned char*)p2; p2++; break;
     case 1: case 2: case 3: memcpy(&qq,p2,2); p2+=2; break;
     case 0x1E: break;
     default: SayError("Invalid relo-type");
    }

    qf=q >> 3; qf=(qf==0x1E)?0:qf; if ((q & 7)>3) qf|=4;
    while (j--) { DoRoll();
     switch (q >> 3) {
      case 0: case 1: case2: *p22++=RT[q&3]; *p22++=qf;
              memcpy(p22,p2,2); memcpy(p22+2,&qq,2); memcpy(p22+4,p2+2,2);
              p22+=6; p2+=4; break;
      case 3: *p22++=RT[q&3]; *p22++=qf;
              memcpy(p22,p2,2); memcpy(p22+2,&qq,2); memset(p22+4,0,2);
              p22+=6; p2+=2; break;
      case 0x1E: *p22++=2; *p22++=qf; memcpy(p22,p2+1,2); p22+=2;
                 *p22++=*p2; *p22++=0; *p22++=0; *p22++=0; p2+=3; break;
     }
    }/*subrelo*/

   } SegT[i].FileArea=w2;
  } l2=ftell(OutF); ll2=Align(l2+ll2,9);
  printf("%.8lXh - %.8lXh ... ",l2,ll2); e+=fwrite(pp,ll2-l2,1,OutF);
  if (e!=2) SayError("I/O error during transferring segment");
  SegT[i].SectorNum=l2/0x200; printf("Ok.\n");
 } free(p); free(pp);

 fseek(InF,NewExe,SEEK_SET); e=fread(Buf,0x40,1,InF);
 memcpy(&w2,&Buf[0x24],2); Buf[0x32]=9; Buf[0xD]&=0xF7;
 fseek(OutF,NewExe,SEEK_SET); e+=fwrite(Buf,0x40,1,OutF);
 if (e!=2) SayError("Unable to store header");

 printf(" þ Resources directoryes...\n");
 l=NewExe+w2; fseek(InF,l,SEEK_SET); e=fread(&w3,2,1,InF);
 do { if (fread(&ResDir,sizeof(ResDir),1,InF)!=1)
         SayError("Unable to read res.directory");
  if (!ResDir.Id) break;
  printf("    Directory ID %.4Xh (%u items)\n",ResDir.Id,ResDir.Num);
  while (ResDir.Num--) {
   ll=ftell(InF); if (!fread(&ResItem,sizeof(ResItem),1,InF))
                    SayError("Unable to read res.item");
   ll2=ftell(InF); l2=ResItem.ResSh; l2<<=w3; fseek(InF,l2,SEEK_SET);
   w=ResItem.ResLen; w<<=w3;
   printf("     Resource ID %.4Xh %.8lXh - %.8lXh > ",
                                         ResItem.Id,l2,l2+w);
   if (w>sizeof(Buf)) SayError("Resource too large");
   memset(Buf,'*',Align(ResItem.ResLen,9));
   e=fread(Buf,w,1,InF); fseek(OutF,0,SEEK_END);
   l2=ftell(OutF)/0x200; ResItem.ResSh=l2;
   printf("%.8lXh - %.8lXh ... ",l2,Align(l2+w,9));
   e+=fwrite(Buf,Align(w,9),1,OutF);
   if (e!=2) SayError("Unable to transfer resource");
   ResItem.ResLen=Align(w,9)/0x200;
   fseek(OutF,ll,SEEK_SET); if (!fwrite(&ResItem,sizeof(ResItem),1,OutF))
                               SayError("Unable to store res.item header");
   fseek(InF,ll2,SEEK_SET);
   printf("Ok.\n");
  }
 } while(1);
 fseek(OutF,l,SEEK_SET); w3=9;
 if (!fwrite(&w3,2,1,OutF)) SayError("Unable to change res. alignment");

 fseek(OutF,NewExe+SegPos,SEEK_SET);
 if (fwrite(SegT,8,SegCnt,OutF)!=SegCnt)
  SayError("Unable to store segments table");

 fclose(InF); fclose(OutF);
 if (!ferror(InF) && !ferror(OutF)) puts(" û Well Done!");
 else SayError("Files processing error");
}

/*-----------------------------------------------------------------*/
/*                      E N T R Y   P O I N T                      */
/*-----------------------------------------------------------------*/
void main(int argc, char* argv[]) {
 char s[256],ss[256];

 printf("(C) 26-Oct-1998y by Hard Wisdom 'OPTLINKer UnPacker' v1.0\n");
 printf("                                ~~~~~~~~~~~~~~~~~~~~\n");

 if (argc<=1) SayError("Where parameters ?   Nothing to do");
 strcpy(s,argv[1]); strcpy(ss,s);
 if (!strrchr(ss,'.')) strcat(ss,".OPT");
 else strcpy(strrchr(ss,'.'),".OPT");

 UnPackFile2File(s,ss); printf("\n û '%s' ---> '%s'\n",s,ss);
}
/*-----------------------------------------------------------------*/
