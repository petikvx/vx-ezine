unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls;

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    SpeedButton1: TSpeedButton;
    EditN: TEdit;
    EditS: TEdit;
    EditF: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel2: TPanel;
    SpeedButton2: TSpeedButton;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    CheckBox3: TCheckBox;
    OpenDialog1: TOpenDialog;
    OpenDialog2: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Label7: TLabel;
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.SpeedButton2Click(Sender: TObject);
const SizeOfDropper=12288{—жатый UPX'ом};
var
    f:file;
    Dropper:array[0..28000] of byte;
    bufF:array[0..500000]of byte;
    bufS:array[0..500000]of byte;
    Param:array[1..16]of byte;
    Fsize,Ssize,i:integer;
    Open1,open2,sSsize,sFsize:string;
begin
    filemode:=0;
    assignfile(f,paramstr(0));
    reset(f,1);
    seek(f,filesize(f)-SizeOfDropper);
    BlockRead(f,Dropper,SizeOfDropper);
    closefile(f);

    assignfile(f,EditF.text);
    reset(f,1);
    BlockRead(f,bufF,filesize(f));
    Fsize:=filesize(f);
    closefile(f);

    assignfile(f,EditS.text);
    reset(f,1);
    BlockRead(f,bufS,filesize(f));
    Ssize:=filesize(f);
    closefile(f);

    if CheckBox1.Checked=true then Open1:='y'
                              else Open1:='n';

    if CheckBox2.Checked=true then Open2:='y'
                              else Open2:='n';
    sFsize:=IntTostr(Fsize);
    sSsize:=IntTostr(Ssize);
    for i:=1 to 6 do
        begin
            Param[i]:=Ord(sFsize[i]);
        end;
    for i:=1 to 6 do
        begin
            Param[i+6]:=Ord(sSsize[i]);
        end;
    Param[13]:=Ord(Open1[1]);
    Param[14]:=Ord(Open2[1]);
    if CheckBox3.Checked=true then Param[15]:=Ord('y')
                              else Param[15]:=Ord('n');
    if RadioButton1.Checked=true then Param[16]:=Ord('w');
    if RadioButton2.Checked=true then Param[16]:=Ord('c');
    if RadioButton3.Checked=true then Param[16]:=Ord('t');

    filemode:=1;

    AssignFile(f,EditN.Text);
    rewrite(f,1);
    BlockWrite(f,Dropper,SizeOfDropper);
    BlockWrite(f,bufF,Fsize);
    BlockWrite(f,bufS,Ssize);
    BlockWrite(f,Param,16);
    closefile(f);
end;

procedure TFormMain.SpeedButton4Click(Sender: TObject);
begin
    OpenDialog1.Execute;
    EditF.Text:=OpenDialog1.FileName;
end;

procedure TFormMain.SpeedButton3Click(Sender: TObject);
begin
    OpenDialog2.Execute;
    EditS.Text:=OpenDialog2.FileName;
end;

procedure TFormMain.SpeedButton1Click(Sender: TObject);
begin
    SaveDialog1.Execute;
    EditN.Text:=SaveDialog1.FileName;
end;

end.
