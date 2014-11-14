program dbconnector;

uses
  Vcl.Forms,
  udbconnector in 'udbconnector.pas' {formdb},
  uutils in '..\sources2208\uutils.pas',
  uConstants in '..\scanohnethread\uConstants.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(Tformdb, formdb);
  Application.Run;
end.
