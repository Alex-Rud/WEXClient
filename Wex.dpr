program Wex;

uses
  System.StartUpCopy,
  FMX.Forms,
  uPairs in 'uPairs.pas',
  uMain in 'uMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
