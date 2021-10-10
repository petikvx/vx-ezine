program gluer;

uses
  Forms,
  Main in 'Main.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Gluer';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
