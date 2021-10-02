uses crt, TPU, avp__;

type
  Pbyte_arr = ^tbyte_arr;
  tbyte_arr = array[1..65535] of byte;

{ программа НИЧЕГО ХОРОШЕГО не делает }

const
  SOURCE  : string = 'abc';
  PRODUCT : string = 'cde';

  sux_num : longint = 4;
  sux_n : array[1..16] of byte = (1,2,3,4,  0,0,0,0,0,0,0,0,0,0,0,0);

var
  cpr : array[0..128-1] of byte;
  hdr : Tavc_header;
  sux : Tsux;
  data : pbyte_arr;
  dsize : word;
  i, j : word;
  l : longint;

procedure dump;
  var
    i,j : integer;
  begin

    writeln('dump of ',source);
    writeln('  id         : ',hdr.id);
    writeln('  ver        : ',hdr.ver);
    writeln('  bits       : ',hdr.bits);

      write('  _1         : ');
    for j := $07 to $0B do
      write(hexbyte(hdr._1[j]),' ');
    writeln;

    writeln('  filesize   : ',hdr.filesize);
    writeln('  sux_offs   : $',hexword(hdr.sux_offs));
    writeln('  sux_count  : ',hdr.sux_count);

      write('  _2         : ');
    for j := $16 to $3D do
      write(hexbyte(hdr._2[j]),' ');
    writeln;

    writeln('  authcpr_cs : $',hexlong(hdr.authcpr_cs));
    writeln('  hdr_cs     : $',hexlong(hdr.hdr_cs));

    for i := 1 to hdr.sux_count do
    begin

      load(PRODUCT, hdr.sux_offs + pred(i) * sizeof(Tsux), sux, sizeof(Tsux), nil);

      writeln('dump of sux n. ',i);

      writeln('  data_size  : ',hexlong(sux.data_size));
      writeln('  real_size  : ',hexlong(sux.real_size));

      writeln('  id         : ',hexword(sux.id));
      writeln('  unk_word   : ',hexword(sux.unk_word));
      writeln('  data_offs  : ',hexlong(sux.data_offs));


        write('  _1         : ');
      for j := $10 to $17 do
        write(hexbyte(sux._1[j]),' ');
      writeln;
      writeln('  data_cs    : ',hexlong(sux.data_cs));
        write('  _2         : ');
      for j := $1C to $23 do
        write(hexbyte(sux._2[j]),' ');
      writeln;

      (*
      load(PRODUCT, sux.data_offs, mem[$B900:0], sux.data_size, NIL);
      for j := 0 to sux.data_size-1 do
        mem[$B900:j] := mem[$B900:j] xor j;
      save('xx'+fstr(i), -1, mem[$B900:0], sux.data_size);
      *)
    end;

  end;

var
  fucksize : word;
  fuck     : Pbyte_arr;

  w,t,ln : word;

procedure pack;
  begin
    dsize := 0;
    j := 0;

    inc(dsize); data^[dsize] := $FF;
    inc(dsize); data^[dsize] := $FF;
    w := $FFFF;

    i := 0;
    ln := 16;

    repeat

      w := w shr 1;
      dec(ln);

      if w = 0 then
      begin
        t := dsize;
        inc(dsize); data^[dsize] := $FF;
        inc(dsize); data^[dsize] := $FF;
        w := $FFFF;
        ln := 16;
      end;

      inc(dsize);
      inc(i);
      data^[dsize] := fuck^[i];

      if i >= fucksize then break;

    until false;

    sux.real_size := i;

    writeln('ln=',ln);

    w := $FFFF xor (1 shl (16-ln));
    inc(t); data^[t] := lo(w);
    inc(t); data^[t] := hi(w);

    inc(dsize); data^[dsize] := $00;
    inc(dsize); data^[dsize] := $00;
    inc(dsize); data^[dsize] := $00;
    inc(dsize); data^[dsize] := $00;
  end;

var
  iii : word;
  tt : text;

  make_all : boolean;
  all_max, all_ptr : longint;

begin
  if paramcount < 2 then halt;
  source  := paramstr(1);
  product := paramstr(2);
  make_all := paramstr(3) = '/ALL';

  (*
  assign(tt, 'make!!!!.cfg');
  reset(tt);
  readln(tt, sux_num);
  for iii := 1 to sux_num do
    readln(tt, sux_n[iii]);
  close(tt);
  *)

  getmem(data, 65520);
  getmem(fuck, 65520);

  inline($B8/$03/$00/$CD/$10);

  if sizeof(Tavc_header) <> $46 then error('sizeof(Tavc_header) = $' + hexbyte(sizeof(Tavc_header)));
  if sizeof(Tsux)        <>  36 then error('sizeof(Tsux) = ' + fstr(sizeof(Tsux)));

  load(source , 0, data^, 65520, @dsize);
  save(product, -1, data^, dsize);

  load(product,   0, cpr, sizeof(cpr), nil);
  load(product, $80, hdr, sizeof(hdr), nil);

  {
  dump;
  halt;
  }

  load(PRODUCT, hdr.sux_offs, sux, sizeof(Tsux), nil);
  all_ptr := sux.data_offs;
  all_max := 0;

  for iii := 1 to sux_num do
  begin

    load(PRODUCT, hdr.sux_offs + pred(sux_n[iii]) * sizeof(Tsux), sux, sizeof(Tsux), nil);

    load('output_'+fstr(iii), 0, fuck^, 65520, @fucksize);

    pack;

    { заXORиваем данные }
    for i := 1 to dsize do
      data^[i] := data^[i] xor pred(i);

    (* если sux последний или длина <= имеющемуся то   *)
    (* записываем код прямо в него, иначе - в конец файла *)

    sux.data_size := dsize;
    sux.data_cs   := calc_checksum(data^, dsize);

    if make_all then begin

      sux.data_offs := all_ptr;
      inc(all_ptr, sux.data_size);

      if all_ptr > all_max then
        all_max:= all_ptr;

    end else begin

    if sux_n[iii] < hdr.sux_count then
    if dsize > sux.data_size then
      sux.data_offs := fsize(PRODUCT);

    end;

    (*
    inc(sux._1[$10]);
    inc(sux._1[$14]);
    sux.real_size := sux.data_size + 8192;
    *)

    save(PRODUCT, hdr.sux_offs + pred(sux_n[iii]) * sizeof(Tsux), sux, sizeof(Tsux));

    save(PRODUCT, sux.data_offs, data^, sux.data_size);

    hdr.filesize := fsize(PRODUCT);
    hdr.hdr_cs   := calc_checksum(hdr, $42);

    save(PRODUCT, $80, hdr, sizeof(hdr));

  end;

  if make_all then
    save(PRODUCT, all_max, hdr,0);

  dump;
end.
