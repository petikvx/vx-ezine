
#pragma optimize("g",on)

#define bbPutBit(x)                             \
{                                               \
  if (t_bitcount == 32)                         \
  {                                             \
    t_bitset   = (unsigned long*)t_outptr;      \
    t_outptr += 4;                              \
    *t_bitset  = 0;                             \
    t_bitcount = 0;                             \
  }                                             \
  *t_bitset = ((*t_bitset) << 1) | ((x)&1);     \
  t_bitcount++;                                 \
}

#define code_prefix_ss11(a)                     \
{                                               \
    e = a;                                      \
    if (e >= 2)                                 \
    {                                           \
        u = 4;                                  \
        e += 2;                                 \
        do {                                    \
            u <<= 1;                            \
        } while (e >= u);                       \
        u >>= 1;                                \
        do {                                    \
            u >>= 1;                            \
            bbPutBit((e & u) ? 1 : 0);          \
            bbPutBit(0);                        \
        } while (u > 2);                        \
    }                                           \
    bbPutBit(e & 1);                            \
    bbPutBit(1);                                \
}

#define code_prefix_ss12(a)                     \
{                                               \
    e = a;                                      \
    if (e >= 2)                                 \
    {                                           \
        u = 2;                                  \
        do {                                    \
            e -= u;                             \
            u <<= 2;                            \
        } while (e >= u);                       \
        do {                                    \
            u >>= 1;                            \
            bbPutBit((e & u) ? 1 : 0);          \
            bbPutBit(0);                        \
            u >>= 1;                            \
            bbPutBit((e & u) ? 1 : 0);          \
        } while (u > 2);                        \
    }                                           \
    bbPutBit(e & 1);                            \
    bbPutBit(1);                                \
}

#define FOLLOW(src,dst,bitpaklen,lmo,off,len)                                 \
        {                                                                     \
          n = ctx->c_pak[src] + (bitpaklen);                                  \
          if ( (ctx->c_pak[dst] == 0) ||                                      \
               (  ctx->c_pak[dst] > n )  )                                    \
          {                                                                   \
            ctx->c_pak[dst] = n;                                              \
            ctx->c_lmo[dst] = lmo;                                            \
            ctx->c_off[dst] = off;                                            \
            ctx->c_len[dst] = len;                                            \
            ctx->c_prv[dst] = src;                                            \
          }                                                                   \
        }

void pack_init(struct SHGE_CONTEXT* ctx,
               unsigned char* inptr,
               unsigned long ilen)
{
  unsigned long i,j,q,t,sz,w, *newptr1, *newptr2;
  int r,c;

  sz = (ilen+1) << 2;

  ctx->ss11_len = (unsigned long*)my_malloc(ctx,sz);
  ctx->ss12_len = (unsigned long*)my_malloc(ctx,sz);

  for(q=0; q<=ilen; q++)
  {
    //
    i = q;
    r = 0;
    if (i >= 2)
    {
      t = 4;
      i += 2;
      do {
        t <<= 1;
      } while (i >= t);
      t >>= 1;
      do {
        t >>= 1;
        r += 2;
      } while (t > 2);
    }
    ctx->ss11_len[q] = r+2;
    //
    i = q;
    r = 0;
    if (i >= 2)
    {
      t = 2;
      do {
        i -= t;
        t <<= 2;
      } while (i >= t);
      do {
        t >>= 2;
        r += 3;
      } while (t > 2);
    }
    ctx->ss12_len[q] = r+2;
  }


  ctx->mem1 = (unsigned char*)my_malloc(ctx,sz*6);

  ctx->c_off = (unsigned long*)(ctx->mem1);
  ctx->c_len = (unsigned long*)(ctx->mem1+sz);
  ctx->c_pak = (unsigned long*)(ctx->mem1+sz*2);
  ctx->c_lmo = (unsigned long*)(ctx->mem1+sz*3);
  ctx->c_prv = (unsigned long*)(ctx->mem1+sz*4);
  ctx->c_nxt = (unsigned long*)(ctx->mem1+sz*5);

  if (ctx->opt->BEST && ctx->opt->BEST2)
  {


    ctx->mem2 = (unsigned char*)my_malloc(ctx,sz*4);
    //assert(ctx->mem2);
    memset(ctx->mem2, 0x00, sz*4);

    ctx->c_hash_max = (unsigned long* )(ctx->mem2);
    ctx->c_hash_cnt = (unsigned long* )(ctx->mem2+sz);
    ctx->c_hash_ptr = (unsigned long**)(ctx->mem2+sz*2);
    ctx->c_hash_len = (unsigned long**)(ctx->mem2+sz*3);

    for(i=0; i<ilen-1; i++)
    {
      w = *(unsigned short*)&inptr[i];
      for(j=0; j<i; j++)
      if (w == *(unsigned short*)&inptr[j])
      {
        c = 2;
        while((i+c<ilen)&&(inptr[i+c]==inptr[j+c])) c++;

        if (ctx->c_hash_cnt[i] == ctx->c_hash_max[i])
        {
          if (ctx->c_hash_max[i] == 0)
            ctx->c_hash_max[i] = 256;
          else
            ctx->c_hash_max[i] += 256;
          newptr1 = (unsigned long*)my_malloc(ctx,ctx->c_hash_max[i] << 2);
          newptr2 = (unsigned long*)my_malloc(ctx,ctx->c_hash_max[i] << 2);
          if (ctx->c_hash_ptr[i] != NULL)
          {
            memcpy(newptr1, ctx->c_hash_ptr[i], ctx->c_hash_cnt[i] << 2);
            memcpy(newptr2, ctx->c_hash_len[i], ctx->c_hash_cnt[i] << 2);
            my_free(ctx,(void*)ctx->c_hash_ptr[i]);
            my_free(ctx,(void*)ctx->c_hash_len[i]);
          }
          ctx->c_hash_ptr[i] = newptr1;
          ctx->c_hash_len[i] = newptr2;
        }

        ctx->c_hash_ptr[i][ctx->c_hash_cnt[i]] = j;
        ctx->c_hash_len[i][ctx->c_hash_cnt[i]] = c;
        ctx->c_hash_cnt[i]++;

      }//for j

    }//for i

  }
  else // BEST2 == 1
  {

    ctx->mem2 = (unsigned char*)my_malloc(ctx,65536*4*3);
    memset(ctx->mem2, 0x00, 65536*4*3);

    ctx->c_hash_max = (unsigned long*)(ctx->mem2);
    ctx->c_hash_cnt = (unsigned long*)(ctx->mem2+65536*4*1);
    ctx->c_hash_ptr = (unsigned long**)(ctx->mem2+65536*4*2);

    for(i=0; i<ilen-1; i++)
    {
      w = *(unsigned short*)&inptr[i];
      if (ctx->c_hash_cnt[w] == ctx->c_hash_max[w])
      {
        if (ctx->c_hash_max[w] == 0)
          ctx->c_hash_max[w] = 1024;
        else
          ctx->c_hash_max[w] <<= 1;
        newptr1 = (unsigned long*)my_malloc(ctx,ctx->c_hash_max[w] << 2);
        if (ctx->c_hash_ptr[w] != NULL)
        {
          memcpy(newptr1, ctx->c_hash_ptr[w], ctx->c_hash_cnt[w] << 2);
          my_free(ctx,(void*)ctx->c_hash_ptr[w]);
        }
        ctx->c_hash_ptr[w] = newptr1;
      }

      ctx->c_hash_ptr[w][ctx->c_hash_cnt[w]++] = i;

    }//for i

  } // BEST2

} // pack_init

void pack_done(struct SHGE_CONTEXT* ctx, int ilen)
{
  int i;

  if (ctx->opt->BEST && ctx->opt->BEST2)
  {
    for(i=0; i<ilen; i++)
      if (ctx->c_hash_ptr[i])
      {
        my_free(ctx,(void*)ctx->c_hash_ptr[i]);
        my_free(ctx,(void*)ctx->c_hash_len[i]);
      }

  }
  else // BEST2
  {

    for(i=0; i<65536; i++)
      if (ctx->c_hash_ptr[i])
        my_free(ctx,(void*)ctx->c_hash_ptr[i]);

  } // BEST2

  my_free(ctx,(void*)ctx->mem1);
  my_free(ctx,(void*)ctx->mem2);

  my_free(ctx,(void*)ctx->ss11_len);
  my_free(ctx,(void*)ctx->ss12_len);

} // pack_done

int pack( struct SHGE_CONTEXT* ctx,
          unsigned char* inptr,
          unsigned long  ilen,
          int P1,
          int P2,
          int P3,
          int P4,
          int P5 )
{
  unsigned char* t_outptr_0, *t_outptr;
  unsigned long sz, t_bitcount, *t_bitset, e, u, last_m_off, k, npass,
                i, t, n, w, cnt, c, z, t_off, t_len, x, y, l, m_off,
                m_len, t_len1;
  int res;

  t_outptr_0 = (unsigned char*)my_malloc( ctx, ilen*2+256 );
  t_outptr   = t_outptr_0;

  // empty temporary arrays

  sz = (ilen+1) << 2;
  memset(ctx->mem1, 0x00, sz*6);

  // pack 1/2

  ctx->c_lmo[0] = 1;

  if (ctx->opt->BEST && ctx->opt->BEST2)
  {

#define NPASS 8

    for(npass=1; npass<=NPASS; npass++)
    {

      ctx->c_lmo[0] = 1;

      for(i=0; i<ilen; i++)
      {
        //if ((i&255)==0) printf("%8d\x08\x08\x08\x08\x08\x08\x08\x08",i);

#define FOLLOW_B2(src,dst,bitpaklen,lmo,off,len)                                 \
          {                                                                     \
            int n = ctx->c_pak[src] + (bitpaklen);                                   \
            if ( (ctx->c_pak[dst] == 0) ||                                           \
                 (ctx->c_pak[dst] >  n) ||                                           \
                 ( (ctx->c_pak[dst] >= n-(NPASS-npass)) &&                           \
                   (lmo == ctx->c_lmo[ctx->c_nxt[dst]])                                   \
                 )                                                              \
               )                                                                \
            {                                                                   \
              ctx->c_pak[dst] = n;                                                   \
              ctx->c_lmo[dst] = lmo;                                                 \
              ctx->c_off[dst] = off;                                                 \
              ctx->c_len[dst] = len;                                                 \
              ctx->c_prv[dst] = src;                                                 \
            }                                                                   \
          }

        FOLLOW_B2(i,i+1,9,ctx->c_lmo[i],0,0)

        {

          cnt = ctx->c_hash_cnt[i];
          for(c=0; c<cnt; c++)
          {

            t_off  = i - ctx->c_hash_ptr[i][c];
            t_len1 = ctx->c_hash_len[i][c];

            for(t_len=2; t_len <= t_len1; t_len++)
            //for(DWORD t_len=t_len1; t_len >= 2; t_len--)
            {
              //assert(inptr[i+t_len-1]==inptr[i-t_off+t_len-1]);

              if ( (P1==0) ||
                   (t_len > 2) ||
                   ( (t_len == 2) && (t_off <= (P4&1?0xd00:0x500)) )
                 )
              {

                int l;
                l = 1;
                if (t_off == ctx->c_lmo[i])
                  l += 2;
                else
                {
                  if (P4&1)
                    l += ctx->ss11_len[1 + ((t_off - (P5?1:0)) >> P2)];
                  else
                    l += ctx->ss12_len[1 + ((t_off - (P5?1:0)) >> P2)];
                  l += P2;
                }
                t = t_len - 1 - (t_off > (P4&1?0xd00:0x500));
                if ((P1 != 0)&&(t < (1<<P1)))
                  l += P1;
                else
                {
                  l += P1 + P3;

                  if (P4&2)
                    l += ctx->ss11_len[(t - (1<<P1)) >> P3];
                  else
                    l += ctx->ss12_len[(t - (1<<P1)) >> P3];
                }

                if (l < (t_len << 3))
                  FOLLOW_B2(i,i+t_len,l,t_off, t_off,t_len)
              }

            }//for t_len

          }// for c

        }

      }//for i

      // yyyyyyyy

      x = ilen;
      for(;;)
      {
        y = ctx->c_prv[x];
        ctx->c_nxt[y] = x;
        x = y;
        if (x == 0) break;
      }

    } // for npass

  }
  else
  if (ctx->opt->BEST)
  {

    for(i=0; i<ilen; i++)
    {

      FOLLOW(i,i+1,9,ctx->c_lmo[i],0,0)

      if (i < ilen-1)
      {
        w = *(unsigned short*)&inptr[i];
        cnt = ctx->c_hash_cnt[w];
        for(c=0; c<cnt; c++)
        {
          z = ctx->c_hash_ptr[w][c];
          if (z >= i) break;

          t_off = i - z;
          t_len = 1;
          while((i+t_len<ilen)&&(inptr[i+t_len] == inptr[z+t_len]))
          {
            t_len++;

            if ((P1==0)||(((t_len > 2) || ((t_len == 2) && (t_off <= (P4&1?0xd00:0x500))))))
            {

              l = 1;
              if (t_off == ctx->c_lmo[i])
                l += 2;
              else
              {
                if (P4&1)
                  l += ctx->ss11_len[1 + ((t_off - (P5?1:0)) >> P2)];
                else
                  l += ctx->ss12_len[1 + ((t_off - (P5?1:0)) >> P2)];
                l += P2;
              }
              t = t_len - 1 - (t_off > (P4&1?0xd00:0x500));
              if ((P1 != 0)&&(t < (1<<P1)))
                l += P1;
              else
              {
                l += P1 + P3;

                if (P4&2)
                  l += ctx->ss11_len[(t - (1<<P1)) >> P3];
                else
                  l += ctx->ss12_len[(t - (1<<P1)) >> P3];
              }

              if (l < (t_len << 3))
                FOLLOW(i,i+t_len,l,t_off, t_off,t_len)
            }

          }

        }
      }

    }//for i

    // pack 2/2

    x = ilen;
    for(;;)
    {
      y = ctx->c_prv[x];
      ctx->c_nxt[y] = x;
      x = y;
      if (x == 0) break;
    }

  }
  else // !BEST
  {

    for(i=0; i<ilen; i++)
    {

      FOLLOW(i,i+1,9,ctx->c_lmo[i],0,0)

      if (i < ilen-1)
      {
        w = *(unsigned short*)&inptr[i];
        cnt = ctx->c_hash_cnt[w];
        for(c=0; c<cnt; c++)
        {
          z = ctx->c_hash_ptr[w][c];
          if (z >= i) break;

          t_off = i - z;
          t_len = 2;
          while((i+t_len<ilen)&&(inptr[i+t_len] == inptr[z+t_len]))
          {
            t_len++;
          }

            if ((P1==0)||(((t_len > 2) || ((t_len == 2) && (t_off <= (P4&1?0xd00:0x500))))))
            {

              l = 1;
              if (t_off == ctx->c_lmo[i])
                l += 2;
              else
              {
                if (P4&1)
                  l += ctx->ss11_len[1 + ((t_off - (P5?1:0)) >> P2)];
                else
                  l += ctx->ss12_len[1 + ((t_off - (P5?1:0)) >> P2)];
                l += P2;
              }
              t = t_len - 1 - (t_off > (P4&1?0xd00:0x500));
              if ((P1 != 0)&&(t < (1<<P1)))
                l += P1;
              else
              {
                l += P1 + P3;

                if (P4&2)
                  l += ctx->ss11_len[(t - (1<<P1)) >> P3];
                else
                  l += ctx->ss12_len[(t - (1<<P1)) >> P3];
              }

              if (l < (t_len << 3))
                FOLLOW(i,i+t_len,l,t_off, t_off,t_len)
            }

        }
      }

    }//for i

    // pack 2/2

    x = ilen;
    for(;;)
    {
      y = ctx->c_prv[x];
      ctx->c_nxt[y] = x;
      x = y;
      if (x == 0) break;
    }

  } // !BEST

  *t_outptr++ = *inptr++;

  t_bitset   = (unsigned long*)t_outptr;
  t_outptr   += 4;
  *t_bitset  = 0;
  t_bitcount = 0;

  last_m_off = 1;

  x = 0;
  while(1)
  {
    y = ctx->c_nxt[x];
    if (y == 0) break;

    m_off = ctx->c_off[y];
    m_len = ctx->c_len[y];

    if (m_len == 0)
    {
      if (x != 0)
      {
        bbPutBit(1);
        *t_outptr++ = *inptr++;
      }
      //ilen--;
    }
    else
    {
      inptr += m_len;
      //ilen  -= m_len;

      m_len = m_len - 1 - (m_off > (P4&1?0xd00:0x500));
      //
      bbPutBit(0);
      if (m_off == last_m_off)
      {
          bbPutBit(0);
          bbPutBit(1);
      }
      else
      {
          last_m_off  = m_off;

          if (P5) m_off--;

          if (P4&1)
            code_prefix_ss11(1 + (m_off >> P2))
          else
            code_prefix_ss12(1 + (m_off >> P2));
          if (P2==8)
            *t_outptr++ = m_off;
          else
          for(k=0; k<P2; k++)
            bbPutBit(m_off >> (P2-k-1));
      }
      if ((P1!=0)&&(m_len < (1<<P1)))
      {
          //assert(m_len!=0);
          for(k=0; k<P1; k++)
            bbPutBit(m_len >> (P1-k-1));
      }
      else
      {
          for(k=0; k<P1; k++)
            bbPutBit(0);
          m_len -= 1<<P1;
          //
          if (P4&2)
            code_prefix_ss11(m_len >> P3)
          else
            code_prefix_ss12(m_len >> P3);

          for(k=0; k<P3; k++)
            bbPutBit(m_len >> (P3-k-1));
      }
      //
    }

    x = y;
  }


  bbPutBit(0);
  m_off = 0;
  if (P5) m_off--;
  if (P4&1)
    code_prefix_ss11(1 + (m_off >> P2))
  else
    code_prefix_ss12(1 + (m_off >> P2));
  if (P2==8)
    *t_outptr++ = m_off;
  else
  for(k=0; k<P2; k++)
    bbPutBit(m_off >> (P2-k-1));

  while(t_bitcount != 32)
    bbPutBit(0);

  t_len = t_outptr - t_outptr_0;

  // re-init

  ctx->v_stack_size = 0;        // re-init stack/local vars
  freelines(ctx);               // empty src lines, ctx->l_count <-- 0

  // build decompressor code

  add(ctx,";generic decryptor, parameters: P1=%d,P2=%d,P3=%d,P4=%d,P5=%d",P1,P2,P3,P4,P5);
  add(ctx,"call %s", ctx->l___pop_packed__);

  // store compressed data

  add(ctx,";%d bytes", t_len);
  for(i=0; i<(t_len&(~3)); i+=4)
  {
    k = *(unsigned long*)&t_outptr_0[ i ];
    add(ctx,"%08X|dd %s",DD(k),hex_num(ctx,k,9));
  }
  for(i = (t_len&(~3)); i<t_len; i++)
  {
    add(ctx,"%02X|db %s",DB(t_outptr_0[i]),hex_num(ctx,t_outptr_0[i],2));
  }

  add(ctx,"%s:", ctx->l___pop_packed__);
  add(ctx,"5E|pop esi;ESI = packed");

  add(ctx,"81EC%08X|sub esp, %d;alloc decompr. buffer on the stack",
    DD( ((ilen+3)&(~3)) ),
    ((ilen+3)&(~3)) );

  add(ctx,"89E7|mov edi,esp;EDI = ESP = unpacked");

  add(ctx,"6AFF|push -1");
  add(ctx,"5D|pop ebp;EBP = -1");

  add(ctx,"call %s", ctx->l___pop_getbit__);
  add(ctx,"01DB|add ebx,ebx");
  add(ctx,"jnz %s", ctx->l___x1__);
  add(ctx,"8B1E|mov ebx,[esi]");
  add(ctx,"83EEFC|sub esi,-4");
  add(ctx,"13DB|adc ebx,ebx");
  add(ctx,"%s:", ctx->l___x1__);
  add(ctx,"C3|retn");
  add(ctx,"%s:", ctx->l___pop_getbit__);

  add(ctx,"31DB|xor ebx,ebx");

  add(ctx,"%s:", ctx->l___decompr_literals_n2b__);
  add(ctx,"A4|movsb");
  add(ctx,"%s:", ctx->l___decompr_loop_n2b__);
  add(ctx,"FF1424|call $DP [esp];getbit");
  add(ctx,"jc %s", ctx->l___decompr_literals_n2b__);

  add(ctx,"33C0|xor eax,eax");
  add(ctx,"40|inc eax");
  add(ctx,"%s:", ctx->l___loop1_n2b__);

  if (P4&1) // s11
  {
    add(ctx,";(P4&1)==1, s11");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax, eax");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"jnc %s", ctx->l___loop1_n2b__);
  }
  else // s12
  {
    add(ctx,";(P4&1)==0, s12");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax,eax");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"jc %s", ctx->l___loopend1_n2d__);
    add(ctx,"48|dec eax");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax, eax");
    add(ctx,"jmp %s", ctx->l___loop1_n2b__);
    add(ctx,"%s:", ctx->l___loopend1_n2d__);
  }

  add(ctx,"31C9|xor ecx,ecx");

  add(ctx,"83E803|sub eax, 3");
  add(ctx,"jc %s", ctx->l___decompr_ebpeax_n2b__);

  add(ctx,";P2=%d",P2);

  if (P2==0)
  {
  }
  else
  if (P2==1)
  {
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax, eax");
  }
  else
  if (P2==8)
  {
    add(ctx,"C1E008|shl eax,8");
    add(ctx,"AC|lodsb");
  }
  else
  {
    add(ctx,"B1%02X|mov cl,%d;P2",DB(P2),P2);
    add(ctx,"%s:", ctx->l___q1__);
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax, eax");
//    add(ctx,"49|dec ecx");
//    add(ctx,"jnz %s", ctx->l___q1__);
    add(ctx,"loop %s", ctx->l___q1__);
  }

  if (!P5)
  {
    add(ctx,"48|dec eax;!P5");
  }

  add(ctx,"83F0FF|xor eax,-1");
  add(ctx,"jz %s", ctx->l___decompr_end_n2b__);

  add(ctx,"95|xchg ebp,eax");

  add(ctx,"%s:", ctx->l___decompr_ebpeax_n2b__);

  add(ctx,";P1=%d",P1);
  if (P1==0)
  {
  }
  else
  if (P1==1)
  {
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"jnz %s", ctx->l___decompr_got_mlen_n2b__);
  }
  else
  if (P1==2)
  {
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"jnz %s", ctx->l___decompr_got_mlen_n2b__);
  }
  else
  {
    add(ctx,"33C0|xor eax,eax");
    add(ctx,"B1%02X|mov cl,%d;P1",DB(P1),P1);
    add(ctx,"__q2:");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C0|adc eax, eax");
//    add(ctx,"49|dec ecx");
//    add(ctx,"jnz __q2");
    add(ctx,"loop __q2");
    add(ctx,"11C1|adc ecx,eax");
    add(ctx,"jnz %s", ctx->l___decompr_got_mlen_n2b__);
  }

  add(ctx,"41|inc ecx");
  add(ctx,"%s:", ctx->l___loop2_n2b__);
  if (P4&2) // s11
  {
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"jnc %s", ctx->l___loop2_n2b__);
  }
  else
  {
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"jc %s", ctx->l___loop2end__);
    add(ctx,"48|dec ecx");
    add(ctx,"FF1424|call $DP [esp];getbit");
    add(ctx,"11C9|adc ecx,ecx");
    add(ctx,"jmp %s", ctx->l___loop2_n2b__);
    add(ctx,"%s:", ctx->l___loop2end__);
  }

  add(ctx,";P3=%d",P3);
  if (P3)
  {
    add(ctx,"49|dec ecx");
    add(ctx,"49|dec ecx");

    if (P3==1)
    {
      add(ctx,"FF1424|call $DP [esp];getbit");
      add(ctx,"11C9|adc ecx,ecx");
    }
    else
    if (P3==2)
    {
      add(ctx,"FF1424|call $DP [esp];getbit");
      add(ctx,"11C9|adc ecx,ecx");
      add(ctx,"FF1424|call $DP [esp];getbit");
      add(ctx,"11C9|adc ecx,ecx");
    }
    else // P3 >= 3
    {
      add(ctx,"6A%02X|push %d;P3",DB(P3),P3);
      add(ctx,"58|pop eax");
      add(ctx,"%s:", ctx->l___q3__);
      add(ctx,"FF1424|call $DP [esp];getbit");
      add(ctx,"11C9|adc ecx,ecx");
      add(ctx,"48|dec eax");
      add(ctx,"jnz %s", ctx->l___q3__);
    }

    add(ctx,";P1=%d",P1);
    if (P1==0)
    {
      add(ctx,"41|inc ecx");
    }
    else
    if (P1==1)
    {
      add(ctx,"41|inc ecx");
      add(ctx,"41|inc ecx");
    }
    else // P1>=2
    if (P1<=6)
    {
      add(ctx,"83C1%02X|add ecx, 1 %s %d;P1",DB(1<<P1),ctx->opt->SYNTAX==0?"shl":"<<",P1);
    }
    else // P1>=7
    {
      add(ctx,"83C1%08X|add ecx, 1 %s %d;P1",DD(1<<P1),ctx->opt->SYNTAX==0?"shl":"<<",P1);
    }
  }
  else
  {
    add(ctx,";P1=%d",P1);
    if (P1==0)
    {
      add(ctx,"49|dec ecx");
    }
    else
    if (P1==1)
    {
    }
    else
    if (P1==2)
    {
      add(ctx,"41|inc ecx");
      add(ctx,"41|inc ecx");
    }
    else // P1=3..7
    if (P1<=7)
    {
      add(ctx,"83C1%02X|add ecx, (1 %s %d) - 2;P1",DB(1<<P1),ctx->opt->SYNTAX==0?"shl":"<<",P1);
    }
    else // P1>=8
    {
      add(ctx,"81C1%08X|add ecx, (1 %s %d) - 2;P1",DD((1<<P1)-2),ctx->opt->SYNTAX==0?"shl":"<<",P1);
    }
  }

  add(ctx,"%s:", ctx->l___decompr_got_mlen_n2b__);

  add(ctx,"81FD%08X|cmp ebp, -%s",
    DD( ((P4&1?-0xd00:-0x500)) ),
        hex_num(ctx,(P4&1? 0xd00: 0x500),4) );
  add(ctx,"83D101|adc ecx,1");
  add(ctx,"56|push esi");
  add(ctx,"8D342F|lea esi,[edi+ebp]");
  add(ctx,"F3A4|rep movsb");
  add(ctx,"5E|pop esi");
  add(ctx,"jmp %s", ctx->l___decompr_loop_n2b__);

  add(ctx,"%s:", ctx->l___decompr_end_n2b__);
  add(ctx,"59|pop ecx;free ptr to getbit");

  add(ctx,"FFE4|jmp esp;jmp <decompressed_data>");

  // free temp buf

  my_free(ctx,(void*)t_outptr_0);

  // re-link

  link(ctx);

  // re-build out_bin

  res = build_bin(ctx);
  if (res != SHGE_RES_OK)
    return res;

  ctx->opt->out_bin_c_plain   = ilen;
  ctx->opt->out_bin_c_comp    = t_len;
  ctx->opt->out_bin_c_decompr = ctx->opt->out_bin_size - t_len;

  return SHGE_RES_OK;

} // pack

int compress(struct SHGE_CONTEXT* ctx)
{
  unsigned char* temp_buf;
  int temp_len, res;
  int P1,P2,P3,P4,P5;
  int min_olen,min_P1,min_P2,min_P3,min_P4,min_P5;

  // copy bin --> temp

  temp_buf = (char*) my_malloc( ctx,ctx->opt->out_bin_size+16 );
  temp_len = ctx->opt->out_bin_size;
  memcpy(temp_buf, ctx->opt->out_bin, temp_len);

  // init compression context, hashs, etc.

  pack_init(ctx, temp_buf, temp_len);

  // compress

  if (ctx->opt->BEST)
  {

    min_olen = -1;

    for(P1=0; P1<= 8; P1++)
    for(P2=0; P2<=12; P2++)
    for(P3=0; P3<= 8; P3++)
    for(P4=0; P4<= 3; P4++)
    for(P5=0; P5<= 1; P5++)
    {
      if (P5 && (P2<=1)) continue; // incompatible options

      res = pack(ctx, temp_buf, temp_len, P1,P2,P3,P4,P5);
      if (res != SHGE_RES_OK)
      {
        pack_done(ctx, temp_len);
        my_free(ctx,(void*)temp_buf);
        return res;
      }

      if ((min_olen == -1) || (min_olen > ctx->opt->out_bin_size))
      {
        min_olen = ctx->opt->out_bin_size;
        min_P1   = P1;
        min_P2   = P2;
        min_P3   = P3;
        min_P4   = P4;
        min_P5   = P5;
      }
    }

    // compress with best parameters

    res = pack(ctx, temp_buf, temp_len, min_P1,min_P2,min_P3,min_P4,min_P5);
    if (res != SHGE_RES_OK)
    {
      pack_done(ctx, temp_len);
      my_free(ctx,(void*)temp_buf);
      return res;
    }

    ctx->opt->best_P1 = min_P1;
    ctx->opt->best_P2 = min_P2;
    ctx->opt->best_P3 = min_P3;
    ctx->opt->best_P4 = min_P4;
    ctx->opt->best_P5 = min_P5;

  }
  else // !best
  {

    res = pack(ctx, temp_buf, temp_len,
      ctx->opt->P1,
      ctx->opt->P2,
      ctx->opt->P3,
      ctx->opt->P4,
      ctx->opt->P5);

    if (res != SHGE_RES_OK)
    {
      pack_done(ctx, temp_len);
      my_free(ctx,(void*)temp_buf);
      return res;
    }

  }

  // free memory used in compression,
  // free temp buf & return

  pack_done(ctx, temp_len);
  my_free(ctx,(void*)temp_buf);

  return SHGE_RES_OK;

} // compress

/* EOF */
