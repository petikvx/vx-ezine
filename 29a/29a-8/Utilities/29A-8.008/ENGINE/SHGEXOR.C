
int xorit(struct SHGE_CONTEXT* ctx)
{
  char* temp_buf;
  int temp_len, k, i, j, q, c;
  unsigned long xordword, d;

  // copy bin --> temp

  temp_buf= (char*) my_malloc( ctx,ctx->opt->out_bin_size+16 );
  temp_len = ctx->opt->out_bin_size;
  memcpy(temp_buf, ctx->opt->out_bin, temp_len);

  // re-init

  ctx->v_stack_size = 0;        // re-init stack/local vars
  freelines(ctx);               // empty src lines, ctx->l_count <-- 0

  // padd with nop's

  while(temp_len%4) temp_buf[temp_len++] = 0x90;

  // find xordword

  xordword = 0;
  for(k=0; k<=3; k++)
  {
    q = 0;
#define IS_CHAR_OK(x)   ((!strchr("\x0D\x0A"/*includes \0*/,(x)))&&(!strchr((char*)ctx->opt->HIDE,(x))))
    for(i=255; i!=0; i--)
    if (IS_CHAR_OK(i))
    {
      c = 0;
      for(j=0; j<temp_len; j+=4)
        if (!IS_CHAR_OK(temp_buf[j+k] ^ i))
        {
          c++;
          break;
        }
      if (c==0)
      {
        q = i;
        break;
      }
    }
    if (q==0)
    {
      my_free(ctx,(void*)temp_buf );
      return SHGE_ERR_XOR;
    }
    xordword |= q << (k<<3);
  }//k=0..3

  // generate unxor layer

  add(ctx,"685EFFE690|push 90E6FF5Eh;push 'pop esi; jmp esi; nop'");
  add(ctx,"FFD4|call esp");
  add(ctx,"%s:", ctx->l___unxor_pop_esi__);
  // !!!       __ HARDCODED !!!
  add(ctx,"83C613|add esi, %s - %s;ESI = data offs", ctx->l___unxor_data__, ctx->l___unxor_pop_esi__);
  // !!!       ~~ HARDCODED !!!
  if (ctx->opt->SYNTAX == 0)
    add(ctx,"B9%08X|mov ecx, not (%d / 4);ECX = data size", DD(~(temp_len/4)), temp_len);
  else
    add(ctx,"B9%08X|mov ecx, ~(%d / 4);ECX = data size", DD(~(temp_len/4)), temp_len);
  add(ctx,"F7D1|not ecx");
  add(ctx,"%s:", ctx->l___unxor_cycle__);
  add(ctx,"8136%08X|xor $DP [esi],%s;decrypt",DD(xordword), hex_num(ctx,xordword,8));
  add(ctx,"AD|lodsd;ESI += 4");
//  add(ctx,"49|dec ecx");
//  add(ctx,"jnz %s", ctx->l___unxor_cycle__);
  add(ctx,"loop %s", ctx->l___unxor_cycle__);
  add(ctx,"%s:", ctx->l___unxor_data__);

  // generate xored data

  add(ctx,";%d bytes, %d dwords", temp_len, temp_len/4);
  for(i=0; i<temp_len; i+=4)
  {
    d = *(unsigned long*)&temp_buf[i] ^ xordword;
    add(ctx,"%08X|dd %s",DD(d),hex_num(ctx,d,9));
  }

  // free temp buf & return

  my_free(ctx,(void*)temp_buf);

  return SHGE_RES_OK;

} // xorit

/* EOF */
