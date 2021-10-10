/*
	Dynamic Huffman routines

	(c)  451 2002/03
*/
#define LESS 0
#define MORE 1

typedef 	unsigned char    byte;
typedef 	unsigned short   word;
typedef 	unsigned long    dword;

struct tree_sorted
{
    word sym;
    dword count;
    word l;
    word r;
};

struct tree_node
{
    word sym;
    word l;
    word r;
};

struct hfind{
  byte hprefix[33];		//256 bits+8 for shifting
  word hsize;			//1-257
};


dword huffman_init(const byte* in_buf,struct tree_node *htree,dword size);
dword huffman_compress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size);
dword huffman_decompress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size);

int SHL33(byte* arr,dword count);
void sort(struct tree_sorted *arr,int max,int type);
int find_node(struct tree_node *arr,int root,byte nb,struct hfind *out);
void bit_print(byte code);
void clear_hfind(struct hfind *x);




///////////////////////////////////////////////////////////////////////////////
//  Init
///////////////////////////////////////////////////////////////////////////////
dword huffman_init(const byte* in_buf,struct tree_node *htree,dword size)
{
struct tree_sorted stat[256];
int hc,index=0,t;


for (word i=0;i<256;i++) {
	stat[i].count=0;											//null count
	stat[i].sym=i;
}

for (hc=0;hc<size;hc++) stat[in_buf[hc]].count++;	//get statistic

sort(stat,256,MORE);											//get null-count elemenths

hc=0;
while ((stat[hc].count!=0)&(hc<0x100))  hc++;

printf("Total elemenths: %x\n",hc);

for (;;)
{
  sort(stat,hc,LESS);

  //1-left(less) ,0 -right(more)

  htree[index].sym=stat[0].sym;
  htree[index].l=stat[0].l;
  htree[index].r=stat[0].r;

  if (hc==1) break;

  index++;

  htree[index].sym=stat[1].sym;
  htree[index].l=stat[1].l;
  htree[index].r=stat[1].r;

  t=stat[0].count+stat[1].count;

  for (int j=0;j<2;j++)
   for (int i=0;i<hc-1;i++) stat[i]=stat[i+1];

  hc--;

//add fictive node

  stat[hc-1].sym=256;                              //flag
  stat[hc-1].count=t;
  stat[hc-1].l=index-1;
  stat[hc-1].r=index;

  index++;
}

  return index;
 }

///////////////////////////////////////////////////////////////////////////////
//  Compress
///////////////////////////////////////////////////////////////////////////////

dword huffman_compress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size)
{

struct hfind hash[256]; 									//hashtable

for (int i=0;i<256;i++)
{
         clear_hfind(&hash[i]);
			find_node (htree,index,(byte)i,&hash[i]);
}

struct hfind fout;
dword pint,pmod,p=0,hmod,hint,c,x;

for (int	i=0;i<size;i++) hout[i]=0;	  					//clear first byte

	for (int i=0;i<size;i++)
		{

         fout=hash[hin[i]];

         pint=p>>3;                                //pint=p/8
         pmod=p&(0x07);                            //pmod=p%8

			hint=31-(fout.hsize>>3);
         hmod=(fout.hsize&0x07);

         x=(fout.hsize+pmod)/8+1;
			c=16-(hmod+pmod);


         SHL33(&fout.hprefix[0],c);

         for (dword i=0;i<x;i++)
    	      hout[pint+i] |= fout.hprefix[hint+i];

         p+=fout.hsize;
		}

         return p;
}

///////////////////////////////////////////////////////////////////////////////
//  Decompress
///////////////////////////////////////////////////////////////////////////////

dword huffman_decompress(struct tree_node *htree,byte* hin,byte* hout,dword index,dword size)
{

dword p=0,pout=0,pint,pmod;
word tree_index,pref_size,psym;
byte buf[33];

while (p!=size)
{
	      pint=p>>3;                                //pint=p/8
	      pmod=p&(0x07);                            //pmod=p%8

         for (int i=0;i<32;i++) buf[i]=hin[pint+i]; //copy to bufer

	      tree_index=index;
	      pref_size&=0;

	      SHL33(buf,pmod);

///////////////////////////////////////////////////////////////////////////////

while ((psym=htree[tree_index].sym)==256)
{
      if (SHL33(buf,1)==1)			       //1
              tree_index=htree[tree_index].l;
      else   			                       //0
      	      tree_index=htree[tree_index].r;

      pref_size++;
}

///////////////////////////////////////////////////////////////////////////////

      hout[pout++]=(byte)psym;
      p+=pref_size;
}

       return pout;
}



//===============================================================================

int find_node(struct tree_node *htree,int root,byte nb,struct hfind *out)
{
   hfind localfind;

   localfind=*out;									//copy struct

  if (htree[root].sym==256)  //node
   {

     SHL33(localfind.hprefix,1);
     localfind.hsize++;

     if 	(find_node(htree,htree[root].r,nb,&localfind)!=0)	//0
     	{
         *out=localfind;							//go out
      	return 1;
     	}

     localfind.hprefix[32]|=1;

     if 	(find_node(htree,htree[root].l,nb,&localfind)!=0) //1
     	{
         *out=localfind;							//go out
      	return 1;
      }
   }
   else if (htree[root].sym==nb)
     {
          *out=localfind;							//go out
          return 1;
     }

/*	  printf("%c--",arr[root].sym);
     for (int i=0;i<3;i++)  bit_print(localfind.hprefix[29+i]);
	  printf("--%i\n",localfind.hsize);*/


     return 0;
}


//===============================================================================

int SHL33(byte* arr,dword count)
{
int ret=0;

for (int j=0;j<count;j++)
	for (int i=0;i<33;i++)
      {
	  if ((!i)&&(arr[0]& 0x80)) ret=1;
        	 else  arr[i-1]|=arr[i]>>7;
	     arr[i]<<=1;
		}

  return ret;
}

//===============================================================================

void clear_hfind(struct hfind *x)
{
for (int i=0;i<33;i++) x->hprefix[i]&=0;
x->hsize&=0;
}

//===============================================================================

#define swap(x,y) {struct tree_sorted t=x;x=y;y=t;}
void sort(struct tree_sorted *arr,int max,int type)
{

//bubble sort
for (int i=0;i<max;i++)
 for (int j=max-1;j>i;j--)
  if (type==LESS)
    {if ((arr[j-1].count>arr[j].count)) swap(arr[j-1],arr[j]);}
  else if (type==MORE)
    if (arr[j-1].count<arr[j].count) swap(arr[j-1],arr[j]);
  }

