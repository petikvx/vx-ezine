{1999 (c) by RedArc}
{Демонстрация кодогенератора VCG для языка Borland Pascal}

PROGRAM HLL_VCG;

USES CG16;

var
   f : File;
   Wb : Byte;
   Ww : Word;
   We : Word;
   Cw : Word;
   Re : Byte;

procedure WriteB;
begin
     BlockWrite (f, Wb, SizeOf (Wb), Cw);
end;

procedure WriteW;
begin
     BlockWrite (f, Ww, SizeOf (Ww), Cw);
end;

procedure WriteBW;
begin
     BlockWrite (f, Wb, SizeOf (Wb), Cw);
     BlockWrite (f, Ww, SizeOf (Ww), Cw);
end;

procedure Write2W;
begin
     BlockWrite (f, Ww, SizeOf (Ww), Cw);
     BlockWrite (f, We, SizeOf (We), Cw);
end;

procedure StackGenerat (V : Word);
begin
     Re := CaseReg16 (4);
     Mov_Reg16_Value16 (Wb, Ww, Re, V);
     WriteBW;
     Wb := PushReg16 (Re);
     WriteB;
end;

BEGIN
     Assign (f, 'TEST.COM');
     ReWrite (f, 1);
     StackGenerat ($240d);
     StackGenerat ($0a63);
     StackGenerat ($7241);
     StackGenerat ($6465);
     StackGenerat ($5220);
     StackGenerat ($7962);
     StackGenerat ($2039);
     StackGenerat ($3939);
     StackGenerat ($3120);
     StackGenerat ($2963);
     StackGenerat ($2820);
     StackGenerat ($4743);
     StackGenerat ($562e);
     StackGenerat ($4c4c);
     StackGenerat ($4820);
     StackGenerat ($7473);
     StackGenerat ($6554);
     Ww := Mov_Reg1_Reg2_16 (rDX, rSP);
     WriteW;
     Mov_Reg16_Value16 (Wb, Ww, rAX, $0900);
     WriteBW;
     Ww := Inth ($21);
     WriteW;
     Mov_Reg16_Value16 (Wb, Ww, rAX, $4c00);
     WriteBW;
     Ww := Inth ($21);
     WriteW;

     Wb := PushReg16 (rAX);
     WriteB;
     Wb := PopReg16 (rAX);
     WriteB;
     Add_Reg16_Value16 (Ww, We, rAX, Rnd16);
     Write2W;
     Sub_Reg16_Value16 (Ww, We, rAX, Rnd16);
     Write2W;
     Add_Reg16_Value8 (Wb, Ww, rAX, Rnd8 ($ff));
     WriteBW;
     Ww := Add_Reg1_Reg2_16 (rAX,rDX);
     WriteW;
     Ww := Sub_Reg1_Reg2_16 (rCX,rDX);
     WriteW;
     Ww := Xor_Reg1_Reg2_16 (rDX, rBX);
     WriteW;
     Xor_Reg16_Value8 (Wb, Ww, rAX, Rnd8 ($ff));
     WriteBW;
     Xor_Reg16_Value16 (Ww, We, rAX, Rnd16);
     Write2W;
     Ww := Mov_Reg1_Reg2_16 (rAX, rBX);
     WriteW;
     Mov_Reg16_Value16 (Wb, Ww, rDX, Rnd16);
     WriteBW;
     Ww := Xchg_Reg1_Reg2_16 (rAX, rSP);
     WriteW;
     Wb := Inc_Reg16 (rBP);
     WriteB;
     Wb := Dec_Reg16 (rBP);
     WriteB;
     Or_Reg16_Value8 (Wb, Ww, rAX, Rnd8 ($ff));
     WriteBW;
     Or_Reg16_Value16 (Ww, We, rAX, Rnd16);
     Write2W;
     Ww := Or_Reg1_Reg2_16 (rAX, rDX);
     WriteW;

     Close (f);
END.
