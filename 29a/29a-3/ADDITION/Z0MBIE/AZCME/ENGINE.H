
#define OUTPUT_FILLER   0xCC

#define UNUSED          '-'
#define MARKED          'x'
#define FORNEXTPASS     'N'

byte output[max_size];
byte buf_mark[max_size];
word link_2[max_cmd];
word link_1[max_cmd];
word link_max;
word out_ip;

void mark_cmd(word ofs, word size, byte marker)
  {
    if (buf_mark[ofs] == MARKED)
      {
        printf("Alredy MARKED\n");
        return;
      }
    for (; size > 0; size--)
      buf_mark[ofs++] = marker;
  }

void store_byte(byte b)
  {
    output[out_ip++] = b;
  }

void store_word(word w)
  {
    store_byte(w & 255);
    store_byte(w >> 8);
  }


void store_link(word old_ip,
                word new_ip)
  {
    if (link_max >= max_cmd)
      {
        printf("Too many links(commands)\n");
        exit(1);
      }
    link_1[link_max] = old_ip;
    link_2[link_max] = new_ip;
    link_max++;

    printf("link #%w: %W <--> %W\n", link_max,old_ip,new_ip);
  }

void store_jmp(word to_ip)
  {
    printf("*** STORE_JMP: offs=%W\n", to_ip);

    store_link(0xFFFE, out_ip);

    store_byte(0xE9);
    store_word(to_ip);
  }

void store_jmp_output(word to_ip)
  {
    word w;
    printf("*** STORE_JMP_OUTPUT: offs=%W\n", to_ip);

    store_link(0xFFFF, out_ip);

    //store_byte(0x90);

    store_byte(0xE9);
    store_word(to_ip - (out_ip+2));

  }

word free_space(word start)
  {
    int i;

    for (i=0; (start+i)<max_size, output[start+i] == OUTPUT_FILLER ; i++) ;

    return(i);
  }

void make_new_ip(void)
  {
     word i;
     word c;

     printf("Executing NEW_IP, searching for IP...\n");

     for (c=0; c<1000; c++)
       {

         i = rnd_word_minmax(0x100+min_left, max_size-min_right);
         if ( free_space(i) > (min_left+min_right) )
           goto found;

       };

     printf("***WARNING***: No free space in output buffer\n");
     return;

found:

     i += min_left;

     printf("New IP found at %W\n", i);

     store_jmp_output(i);
     out_ip = i;

  }

void random_new_ip(void)
  {
    #ifdef USE_RANDOM_IP

    printf("Executing RANDOM_NEW_IP\n");

    if (rnd_word(USE_RANDOM_IP) == 0)
      {
        make_new_ip();
      };

    #endif
  }

byte store_inversed_jmp;

void store_cmd(word ip, word size)
  {
    pchar p;
    tcmdrec r;
    word i;

    if (free_space(out_ip) < min_right_left)
      make_new_ip();
    else
      random_new_ip();

    printf("*** STORE_CMD: offs=%W size=%W\n", ip, size);

    store_link(ip, out_ip);

    disasm(make_ptr(_CS,ip), &r);

    if ((r.type == ct_JMP) || (r.type == ct_JCC) || (r.type == ct_CALL))
      {

        if (  (store_inversed_jmp == 1) && (r.type == ct_JCC)  )
          {
            r.jmpptr = ip-disasm_base + r.size;
            r.opcode ^= 1;
          }

        if ((r.opcode & 0xF0) == 0x80)
          {
            store_byte(0x0F);
            store_byte(r.opcode);
            store_word(r.jmpptr);
            return;
          }

        if ((r.opcode & 0xF0) == 0x70)
          {
            store_byte(0x0F);
            store_byte(r.opcode - 0x70 + 0x80);
            store_word(r.jmpptr);
            return;
          }

        if (r.opcode == 0xEB)
          {
            store_byte(0xE9);
            store_word(r.jmpptr);
            return;
          }

        if ( (r.opcode == 0xE8) || (r.opcode == 0xE9) )
          {
            store_byte(r.opcode);
            store_word(r.jmpptr);
            return;
          }

        printf("ERROR 1, X=%B\n", r.opcode);
        exit(2);
      }

    #ifdef SKIP_NOP
    if (r.opcode == 0x90)
      return;
    #endif

    #ifdef SKIP_INT3
    if (r.opcode == 0xCC)
      return;
    #endif

    #ifdef SKIP_RANDOM

    if (r.size == 2)
    if (
        (
          ((r.opcode & 0xFE) == 0x86) ||
          ((r.opcode & 0xFE) == 0x88)
        )
        &&
        (r.mod == 3)
       )
         return;

    #endif

    #ifdef CHANGE_CMD
    i = r.opcode & 0xFE;
    if (r.size == 2)
    if (r.mod == 3)
    if ( (i == 0x08) ||
         (i == 0x0A) ||
         (i == 0x20) ||
         (i == 0x22) ||
         (i == 0x84) )
      {
        i = rnd_word(5);
        if (i == 0) i = 0x08;
        if (i == 1) i = 0x0A;
        if (i == 2) i = 0x20;
        if (i == 3) i = 0x22;
        if (i == 4) i = 0x84;
        store_byte(((r.opcode & 0x01) + i));
        store_byte(r.modrm);

        return;
      };
    #endif

    for (; size>0; size--)
      {
        p = make_ptr(_CS,ip++);
        store_byte( (byte) *p );
      }

    #ifdef ADD_RANDOM
    if (rnd_word(ADD_RANDOM) == 0)
      {
        word f;
        store_byte(0x86 + rnd_word(4));
        f = (random_word() & 7);
        store_byte(0xC0 + (f << 3) + f);

      };
    #endif

  }

byte pass_action;

void process_1(word ip)
  {
    tcmdrec rec;

nextcmd:
     if ((ip <  0x0100) ||
         (ip >= max_size))
       {
         printf("IP range check error, exiting\n");
         return;
       }

     disasm(make_ptr(_CS,ip), &rec);

     printf("Marking: ");
     dump(make_ptr(_CS,ip+disasm_base), rec.size);

     if (pass_action == 2)
       {
         printf("PASS 2: Saving offset %W to LINK_2[%w]\n", ip, link_max);

         if (link_max > max_cmd*2)     // *2 becoz using 2 arrays: ..._2 & 1
           {
             printf("Too many links!!!");
             exit(3);
           };

         link_2[link_max] = ip;
         link_max++;
       }

     if (buf_mark[ip] == MARKED)
       {
         printf("Alredy marked, exiting\n");
         if (pass_action == 1)
           store_jmp(ip+disasm_base);
         return;
       };
     mark_cmd(rec.base, rec.size, MARKED);

     if (rec.type == ct_UNKNOWN)
       {
         if (pass_action == 1)
           store_cmd(ip+disasm_base, rec.size);
         ip += rec.size;
       };

     if (rec.type == ct_RET)
       {
         if (pass_action == 1)
           store_cmd(ip+disasm_base, rec.size);
         printf("[RET]  Exiting\n");
         return;
       };

     if (rec.type == ct_JMP)
       {

         if (pass_action == 1)
           {
             #ifndef SKIP_JMPS
               store_cmd(ip+disasm_base, rec.size);
             #else
               store_link(ip+disasm_base, out_ip);
               #ifdef SKIP_JMPS_BUT_ADD_NOPS
               store_byte(0x90);
               #endif
             #endif
           }

         printf("[JMP]  Changing IP to %W\n", rec.jmpptr);
         ip = rec.jmpptr;
       };

     if (rec.type == ct_CALL)
       {
         if (pass_action == 1)
           store_cmd(ip+disasm_base, rec.size);
         ip+=rec.size;
         printf("[CALL] Marking for next pass: %W\n", rec.jmpptr);
         mark_cmd(rec.jmpptr, 1, FORNEXTPASS);
       };

     if (rec.type == ct_JCC)
       {

         #ifdef RANDOM_JCC
         word rnd = rnd_word(2);
         #else
           #ifdef INVERSE_JCC
           word rnd = 1;
           #else
           word rnd = 0;
           #endif
         #endif

         if (rnd == 0)
           {

             store_inversed_jmp = 0;

             if (pass_action == 1)
               store_cmd(ip+disasm_base, rec.size);

             ip+=rec.size;

             printf("[Jcc]  Marking for next pass: %W\n", rec.jmpptr);
             mark_cmd(rec.jmpptr, 1, FORNEXTPASS);

           };

         if (rnd == 1)
           {

             store_inversed_jmp = 1;

             if (pass_action == 1)
               store_cmd(ip+disasm_base, rec.size);

             ip+=rec.size;

             printf("[Jcc] ***INVERSED***  Marking for next pass: %W\n", ip);
             mark_cmd(ip, 1, FORNEXTPASS);

             printf("Changing IP to %W\n", rec.jmpptr);
             ip = rec.jmpptr;

           };

       };

     goto nextcmd;
  }

void mark_unused(void)
  {
    int i;

    fillchar(buf_mark, max_size, UNUSED);
    link_max = 0;

    printf("Marking entry point(s)\n");

    process_1(0x0100);

cycle:
    printf("Searching for FORNEXTPASS mark(s)\n");

    for (i = 0; i < max_size; i++)
      if (buf_mark[i] == FORNEXTPASS)
        {
          printf("Found at %W\n", i);
          process_1(i);
          goto cycle;
        }

    printf("No FORNEXTPASS-mark(s) found\n");
  }

void run_engine(void)
  {
    handle h;
    word i;
    word j;
    word k;
    word w;
    word q;
    word e;
    pchar p;
    tcmdrec r1;
    tcmdrec r2;
    tcmdrec r3;

    printf("Engine!\n  {\n");

    fillchar(output, max_size, OUTPUT_FILLER);
    out_ip = 0x100;

    disasm_base = 0;
    pass_action = 1;
    printf("Marking UNUSED commands (1)\n");
    mark_unused();

    #ifndef SKIP_DEBUGFILES

    printf("Writing file(s)\n");

    h = createfile("buf_mark.1");
    writefile(h, buf_mark, max_size);
    closefile(h);
    h = createfile("link_1.1");
    writefile(h, link_1, link_max * 2);
    closefile(h);
    h = createfile("link_2.1");
    writefile(h, link_2, link_max * 2);
    closefile(h);

    h = createfile("output.1");
    writefile(h, &output[0x100], max_size-0x100);
    closefile(h);

    #endif

    printf("Updating JMPs...\n");

    fillchar(buf_mark, max_size, UNUSED);

    for (i=0; i<link_max; i++)
      if (link_1[i] != 0xFFFF)
      {
        for (j=0; j<link_max; j++)
          if (i != j)
            if (link_2[i] == link_2[j])
              if (link_1[j] == 0xFFFF)
                goto skip_cycle;

        printf("DEBUG: &out[...]=%W, ...=%W i=%w link_1[i]=%W \n", (word) &output[link_2[i]], link_2[i], i, link_1[i]);

        p = &output[link_2[i]];
        disasm(p, &r);

        if (
           (r.type == ct_JMP) ||
           (r.type == ct_JCC) ||
           (r.type == ct_CALL)
           )
         {
            printf("Command to update found at %W\n", link_2[i]);

            if (buf_mark[link_2[i]] == MARKED)
              printf("Alredy updated");
            else
            {
                buf_mark[link_2[i]] = MARKED;

                if ( (r.opcode == 0xE9) || (r.opcode == 0xE8) )
                  k=1;
                else
                  k=2;

                printf("k=%w\n",k);

                w = r.data.w[0];

                printf("Points to %W\n",w);

                q = 0;
                for (j=0; j<link_max; j++)
                  if (link_1[j] == w)
                    {
                      printf("Link to (replacing with) %W, j=%w, patch at %W+, link_1[j]=%W\n", link_2[j], j, link_2[i], link_1[j]);

                      e = (int) link_2[j] - (link_2[i] + r.size);

                      output[link_2[i]+k  ] = e & 255;
                      output[link_2[i]+k+1] = ((word) e) >> 8;

                      q++;
                    }

                if (q != 1)
                  {
                    printf("ERROR 2, q=%w\n",q);
                    exit(4);
                  }

            };

         };
skip_cycle:
      };

    disasm_base = ((word) &output[0x0100]) - 0x100;
    pass_action = 2;
    printf("Marking UNUSED commands (2)\n");
    mark_unused();

    #ifndef SKIP_DEBUGFILES

    printf("Writing file(s)\n");

    h = createfile("buf_mark.2");
    writefile(h, buf_mark, max_size);
    closefile(h);
    h = createfile("link_1.2");
    writefile(h, link_1, link_max * 2);
    closefile(h);
    h = createfile("link_2.2");
    writefile(h, link_2, link_max * 2);
    closefile(h);

    #endif

    #ifdef KILL_J2J

    printf("Searching for Jxx-JMP, CALL-JMP, CALL-RET situations\n");

    for (i=0; i<link_max; i++)
      {
        disasm(make_ptr(_CS,link_2[i]), &r1);

        if ( (r1.type == ct_CALL) && (r1.opcode == 0xE8) )
          {
            disasm(make_ptr(_CS, r1.jmpptr), &r2);

            if (r2.opcode == 0xC3)
              {
                printf("CALL-RET found at %W, points to %W\n", r1.base, r1.jmpptr);

                j=r1.base;
                output[j  ] = 0x87; // xchg ax, ax
                output[j+1] = 0xC0;
                output[j+2] = 0x90; // nop
              };
          };

        if (
           (r1.type == ct_JCC ) ||
           (r1.type == ct_CALL) ||
           (r1.type == ct_JMP)
           )
          {
            printf("Jxx-JMP or CALL-JMP found at %W, points to %W\n", r1.base, r1.jmpptr);

            disasm(make_ptr(_CS, r1.jmpptr), &r2);
            if (r2.type != ct_JMP)
              printf("Suxx...\n");
            else
              {

cycle:          printf("Points to %W\n", r2.jmpptr);

                disasm(make_ptr(_CS, r2.jmpptr), &r3);
                if (r3.type == ct_JMP)
                  {
                    move(&r3, &r2, sizeof(tcmdrec));
                    goto cycle;
                  };

                printf("Updating: cmd at %W, jmpptr=%W -> %W \n", r1.base, r1.jmpptr, r2.jmpptr );

                j=r1.base;
                if ((r1.flags & cf_is0F) != 0) j++;  // 0F
                j++;  // opcode

                w = r2.jmpptr - (j+2);
                output[j  ] = w & 255;
                output[j+1] = w >> 8;

              };

          };

      };

    printf("Marking UNUSED commands (3)\n");
    mark_unused();

    #endif

    #ifdef MAKE_SHORT_JMPS

    printf("Searching for Jxx/JMPs\n");

    for (i=0; i<link_max; i++)
      {
        disasm(make_ptr(_CS,link_2[i]), &r1);


        if (r1.type == ct_JCC)
          {
            w = r1.jmpptr - (r1.base+2);
            if ( ((short) (w & 255)) == w)
              {
                 printf("Changing JCC at %W, r1.data.w[0]=%W\n", r1.base, r1.data.w[0]);

                 output[r1.base+0] = r1.opcode - 0x10;
                 output[r1.base+1] = w & 255;
                 output[r1.base+2] = 0x87;    // xchg ax, ax
                 output[r1.base+3] = 0xC0;    //
              };
          };


        if (r1.type == ct_JMP)
          {
            w = r1.jmpptr - (r1.base+2);
            if ( ((short) (w & 255)) == w)
              {
                 printf("Changing JMP at %W, r1.data.w[0]=%W\n", r1.base, r1.data.w[0]);

                 output[r1.base+0] = 0xEB;
                 output[r1.base+1] = w & 255;
                 buf_mark[r1.base+2] = UNUSED;
              };
          };

      };

    #endif

    #ifdef FILL_UNUSED_CC
    printf("Filling UNUSED space with 0xCC\n");
    for (i=0; i<max_size; i++)
      if (buf_mark[i] == UNUSED)
        output[i] = 0xCC;
    #endif

    #ifdef FILL_UNUSED_RANDOM
    printf("Filling UNUSED space with RANDOM bytes\n");
    for (i=0; i<max_size; i++)
      if (buf_mark[i] == UNUSED)
        output[i] = random_word();
    #endif

    printf("Writing 1.COM\n");

    h = openfile("1.com");
    writefile(h, &output[0x100], max_size-0x100);
    closefile(h);

    printf("  }\nEngine terminated.\n");
  }

