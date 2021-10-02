//ARMPOLY v1 Freeware (x) Vecna/29A
//
//random registers
//add/sub byte/dword encryption
//bidirectional pointer and counter
//advanced counter
//automagic pointer
//mixed order of counter/pointer generation
//mixed order of counter/pointer increase/decrease
//two loop methods
//cache fix
//
//random opcode generator
//memory reads/writes
//subroutines
//
//greetz to Ratter/29A for the infinite bugfixes

//#define ARM_FULL        //enable bizarre garbling

#define JMP_EQUAL       0
#define JMP_NEQUAL      1
#define JMP_ALWAYS      14

#define REGS            16

#define OPT_RND         P_ENCTYPE+P_PTRDIR+P_CNTDIR+P_INV1+P_INV2+P_INV3+P_INV4+P_DWORD+1

#define ARM_CACHE       1024

#define P_ENCTYPE       1
#define P_PTRDIR        2
#define P_CNTDIR        4
#define P_INV1          8
#define P_INV2          16
#define P_INV3          32
#define P_INV4          64
#define P_DWORD         128
#define P_GARBLING      256
#define P_ENDCHECK      512
#define P_ENC           1024
#define P_SUB           2048

#define random(x)       ((*ps->random)(x))

#define set(x)          (ps->opt|=x)
#define clear(x)        (ps->opt&=~x)
#define isset(x)        ((ps->opt&x)!=0)
#define isclear(x)      ((ps->opt&x)==0)

typedef unsigned long (* RANDOM)(unsigned long);

typedef struct _POLY_STRUCT{
  RANDOM random;
  unsigned long *rw_buffer,rw_size,opt;
  unsigned char *buf,*subroutine,ptr_reg,cnt_reg,tmp_reg,aux_reg;
}POLY_STRUCT;

void garble(POLY_STRUCT *ps);



unsigned char get_any_reg(POLY_STRUCT *ps){
  return (unsigned char)random(REGS);
}



unsigned char get_free_reg(POLY_STRUCT *ps){
  unsigned char aux;
  do{
    aux=get_any_reg(ps);
  }while((aux>12)||(aux==ps->ptr_reg)||(aux==ps->cnt_reg)||(aux==ps->tmp_reg)||(aux==ps->aux_reg));
  return aux;
}



void store_opcode(unsigned long opcode,POLY_STRUCT *ps){
  *ps->buf++=(unsigned char)(opcode&0xff);
  *ps->buf++=(unsigned char)((opcode>>8)&0xff);
  *ps->buf++=(unsigned char)((opcode>>16)&0xff);
  *ps->buf++=(unsigned char)((opcode>>24)&0xff);
}



unsigned long dist2ofs(unsigned char *curofs,unsigned char *newofs){
  return (((unsigned long)newofs-(unsigned long)curofs)-8)>>2;
}



void gen_branch(unsigned char *ofs,unsigned char cond,POLY_STRUCT *ps){
  store_opcode((((cond<<4)+0x0a+(isset(P_SUB)?1:random(2)))<<24)+(dist2ofs(ps->buf,ofs)&0x00ffffff),ps);
}



void gen_rw_buffer(POLY_STRUCT *ps){
  unsigned long aux;
  aux=(ps->rw_size=(random(8)+4))*4;
  gen_branch(ps->buf+aux,JMP_ALWAYS,ps);
  ps->rw_buffer=(unsigned long *)ps->buf;
  ps->rw_size--;
  aux-=4;
  while(aux--)*ps->buf++=(unsigned char)random(0xff);
}



void gen_mov(unsigned char reg,unsigned long value,POLY_STRUCT *ps){
  if(value<0x100){
    store_opcode(0xe3a00000+(reg<<12)+(value&0xff),ps);
  }else if(value>(0-0x100)){
    store_opcode(0xe3e00000+(reg<<12)+((~value)&0xff),ps);
  }else{
    if((!ps->rw_size)&&isclear(P_SUB))gen_rw_buffer(ps);
    if(ps->rw_size){
      store_opcode(0xe51f0000+(reg<<12)+(((unsigned long)ps->buf-(unsigned long)ps->rw_buffer+8)&0x0fff),ps);
      *ps->rw_buffer++=value;
      ps->rw_size--;
    }
  }
  garble(ps);
}



void gen_add(unsigned char reg,unsigned char reg2,unsigned char val,unsigned long s,POLY_STRUCT *ps){
  unsigned long aux;
  aux=(reg2<<16)+(reg<<12);
  store_opcode(0xe2800000+aux+(s<<20)+(val&0xff),ps);
  garble(ps);
}



void gen_sub(unsigned char reg,unsigned char reg2,unsigned char val,unsigned long s,POLY_STRUCT *ps){
  unsigned long aux;
  aux=(reg2<<16)+(reg<<12);
  store_opcode(0xe2400000+aux+(s<<20)+(val&0xff),ps);
  garble(ps);
}



void gen_subroutine(POLY_STRUCT *ps){
  unsigned char *tmp_subroutine,save_opt;
  unsigned long aux;
  save_opt=ps->opt;
  clear(P_GARBLING);
  set(P_SUB);
  aux=random(8)+4;
  gen_branch(ps->buf+(aux*4),JMP_ALWAYS,ps);
  tmp_subroutine=ps->buf;
  ps->subroutine=0;
  while(((tmp_subroutine+(aux*4))-ps->buf)>8)garble(ps);
  store_opcode(0xe1a0f00e,ps);
  ps->subroutine=tmp_subroutine;
  ps->opt=save_opt;
}



void gen_ptr(unsigned char *buffer,unsigned long bsize,POLY_STRUCT *ps){
  unsigned long value,size,rmd,shift,mlt;
  value=size=(((ps->buf+8)-buffer)-(isset(P_PTRDIR)?0:bsize));
  shift=1;
  rmd=mlt=0;
  while(value>0xfe){
    mlt--;
    shift++;
    rmd=(size&((1<<(shift*2))-1));
    value=(size>>(shift*2));
  }
  if(mlt)mlt--;
  store_opcode(0xe24f0000+(ps->ptr_reg<<12)+((mlt&0xf)<<8)+value,ps);
  garble(ps);
  if(isclear(P_PTRDIR))rmd+=(isset(P_DWORD)?4:1);
  if(rmd)gen_sub(ps->ptr_reg,ps->ptr_reg,(unsigned char)rmd,0,ps);
  garble(ps);
}



void zero_reg(unsigned char reg,POLY_STRUCT *ps){
  store_opcode((JMP_ALWAYS<<28)+
    (((random(2)?2:4)+random(2))<<20)+
    (reg<<16)+
    (reg<<12)+
    reg,ps);
}



void garble(POLY_STRUCT *ps){
  unsigned long aux;
  unsigned char tmp,kind,opcode;
return;
  if(isclear(P_GARBLING)){
    set(P_GARBLING);
    for(aux=(isset(P_SUB)?1:((random(8)+1)<<1));aux;aux--){
      tmp=(unsigned char)random(0xff)+1;
      switch (random(8)+(isset(P_SUB)?1:0)){
        case 0:
          (ps->rw_size<3)?gen_rw_buffer(ps):gen_subroutine(ps);
          break;
        case 1:
          if(isclear(P_SUB)&&isclear(P_ENDCHECK)&&(ps->subroutine)){
            set(P_SUB);
            gen_branch(ps->subroutine,(unsigned char)random(15),ps);
            clear(P_SUB);
          }
          break;
        case 2:
        case 3:
          gen_mov(get_free_reg(ps),random(2)?tmp:random(0xffffffff),ps);
          break;
        case 4:
        case 5:
          if((!ps->rw_size)&&isclear(P_SUB))gen_rw_buffer(ps);
          if(ps->rw_size){
            store_opcode(0xe50f0000+(get_any_reg(ps)<<12)+((((unsigned long)ps->buf-(unsigned long)ps->rw_buffer++)+8)&0x0fff),ps);
            ps->rw_size--;
          }
          break;
        default:
#ifdef ARM_FULL
          kind=random(2);
          opcode=random(16);
          if(isset(P_ENDCHECK)&&(opcode>7)&&(opcode<12))opcode|=4;
          store_opcode(
            ((random(2)?
                JMP_ALWAYS:
                (random(2)?
                  JMP_ALWAYS:
                  random(15)
                )
             )<<28
            )+
            (kind<<25)+
            (opcode<<21)+
            ((isset(P_ENDCHECK)?
              0:
              random(2)
             )<<20
            )+
            (get_any_reg(ps)<<16)+
            (get_free_reg(ps)<<12)+
            (kind?
              (tmp+((random(2)?
                0:
                (random(2)?
                  0:
                  random(16)
                )
              )<<8)):
              (get_any_reg(ps)+((random(2)?
                0:
                (random(2)?
                  0:
                  (random(2)?
                    ((get_free_reg(ps)<<4)+(random(4)<<1)+1):
                    ((tmp<<1)&0xfff)
                  )
                )
              )<<4))
            ),
          ps);
#endif
          break;
      }
    }
    clear(P_GARBLING);
  }
}



unsigned long poly(unsigned char *buffer,unsigned char *host,unsigned long size,unsigned long entry,unsigned long *newentry,POLY_STRUCT *ps){
  unsigned long aux,tmp,enc_val;
  unsigned char *buf_entry,*buf_oentry,*buf_label,*jmp_to_second_part;
  unsigned char step,step2;
  buf_oentry=buffer+entry;
  ps->buf=buffer;
  ps->rw_size=0;
  ps->subroutine=0;
  ps->opt=random(OPT_RND);
  ps->tmp_reg=ps->aux_reg=ps->ptr_reg=ps->cnt_reg=-1;
  enc_val=((random(-1)<<16)|(random(-1)+1));
  step=random(0xff)+1;
  step2=(isset(P_DWORD)?4:1);
  aux=(step2>>2)?(size>>2):size;
  tmp=(isset(P_ENCTYPE)?enc_val:-enc_val);
  while(aux--){
    if(isset(P_DWORD)){
      *(unsigned long *)ps->buf=*(unsigned long *)host+tmp;
      ps->buf+=4;
      host+=4;
    }else *ps->buf++=(*host++)+(unsigned char)tmp;
  }
  buf_entry=ps->buf;
  garble(ps);
  garble(ps);
  ps->subroutine=0;
  ps->tmp_reg=ps->ptr_reg=get_free_reg(ps);
  ps->aux_reg=ps->cnt_reg=get_free_reg(ps);
  aux=(((step2>>2)?(size>>2):size)*step);
  if(isset(P_CNTDIR))aux=(~aux)+1;
  if(isset(P_INV1)){
    gen_ptr(buffer,size,ps);
    gen_mov(ps->cnt_reg,aux,ps);
  }else{
    gen_mov(ps->cnt_reg,aux,ps);
    gen_ptr(buffer,size,ps);
  }
  buf_label=ps->buf;
  garble(ps);
  ps->subroutine=0;
  set(P_ENC);
  ps->tmp_reg=get_free_reg(ps);
  ps->aux_reg=get_free_reg(ps);
  aux=(ps->ptr_reg<<16)+(ps->tmp_reg<<12);
  store_opcode(0xe5900000+(isclear(P_DWORD)?(1<<22):0)+aux,ps);
  garble(ps);
  if(isset(P_DWORD)){
    gen_mov(ps->aux_reg,enc_val,ps);
    store_opcode(0xe0000000+((isclear(P_ENCTYPE)?8:4)<<20)+(ps->tmp_reg<<16)+(ps->tmp_reg<<12)+ps->aux_reg,ps);
  }else isclear(P_ENCTYPE)?
    gen_add(ps->tmp_reg,ps->tmp_reg,(unsigned char)enc_val,random(2),ps):
    gen_sub(ps->tmp_reg,ps->tmp_reg,(unsigned char)enc_val,random(2),ps);
  garble(ps);
  store_opcode(0xe5800000+(isclear(P_DWORD)?(1<<22):0)+aux,ps);
  ps->aux_reg=ps->cnt_reg;
  ps->tmp_reg=ps->ptr_reg;
  clear(P_ENC);
  garble(ps);
  set(P_ENDCHECK);
  if(isset(P_INV2)){
    isset(P_CNTDIR)?gen_add(ps->cnt_reg,ps->cnt_reg,step,1,ps):gen_sub(ps->cnt_reg,ps->cnt_reg,step,1,ps);
    jmp_to_second_part=ps->buf;
    ps->buf+=4;
    garble(ps);
    isset(P_PTRDIR)?gen_add(ps->ptr_reg,ps->ptr_reg,step2,random(2),ps):gen_sub(ps->ptr_reg,ps->ptr_reg,step2,random(2),ps);
    gen_branch(buf_label,JMP_ALWAYS,ps);
  }else{
    isset(P_PTRDIR)?gen_add(ps->ptr_reg,ps->ptr_reg,step2,random(2),ps):gen_sub(ps->ptr_reg,ps->ptr_reg,step2,random(2),ps);
    garble(ps);
    isset(P_CNTDIR)?gen_add(ps->cnt_reg,ps->cnt_reg,step,1,ps):gen_sub(ps->cnt_reg,ps->cnt_reg,step,1,ps);
    gen_branch(buf_label,JMP_NEQUAL,ps);
  }
  clear(P_ENDCHECK);
  garble(ps);
  if(isset(P_INV2)){
    (unsigned long)jmp_to_second_part^=(unsigned long)ps->buf;
    (unsigned long)ps->buf^=(unsigned long)jmp_to_second_part;
    (unsigned long)jmp_to_second_part^=(unsigned long)ps->buf;
    gen_branch(jmp_to_second_part,JMP_EQUAL,ps);
    ps->buf=jmp_to_second_part;
  }
  garble(ps);
  ps->tmp_reg=ps->aux_reg=ps->ptr_reg=ps->cnt_reg=-1;
  ps->subroutine=0;
  ps->tmp_reg=ps->ptr_reg=get_free_reg(ps);
  ps->aux_reg=ps->cnt_reg=get_free_reg(ps);
  if(isclear(P_INV4)){
    if(random(2))gen_mov(ps->ptr_reg,0,ps);
      else zero_reg(ps->ptr_reg,ps);
#if ARM_CACHE == 1024
    if(random(2))gen_mov(ps->cnt_reg,ARM_CACHE,ps);
      else store_opcode(0xE3A00B01+(ps->cnt_reg<<12),ps);
#else
    gen_mov(ps->cnt_reg,ARM_CACHE,ps);
#endif
  }else{
#if ARM_CACHE == 1024
    if(random(2))gen_mov(ps->cnt_reg,ARM_CACHE,ps);
      else store_opcode(0xE3A00B01+(ps->cnt_reg<<12),ps);
#else
    gen_mov(ps->cnt_reg,ARM_CACHE,ps);
#endif
    if(random(2))gen_mov(ps->ptr_reg,0,ps);
      else zero_reg(ps->ptr_reg,ps);
  }
  buf_label=ps->buf;
  store_opcode(0xEE070FB2+(ps->ptr_reg<<12),ps);
  gen_add(ps->ptr_reg,ps->ptr_reg,0x20,random(2),ps);
  set(P_ENDCHECK);
  gen_sub(ps->cnt_reg,ps->cnt_reg,1,1,ps);
  if(isset(P_INV3)){
    gen_branch(buf_label,JMP_NEQUAL,ps);
    clear(P_ENDCHECK);
    garble(ps);
  }else{
    gen_branch(buf_oentry,JMP_EQUAL,ps);
    clear(P_ENDCHECK);
    garble(ps);
    buf_oentry=buf_label;
  }
  gen_branch(buf_oentry,JMP_ALWAYS,ps);
  garble(ps);
  *newentry=(unsigned long)(buf_entry-buffer);
  return (unsigned long)(ps->buf-buffer);
}
