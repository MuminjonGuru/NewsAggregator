program NewsAggregator;

uses
  System.StartUpCopy,
  FMX.Forms,
  NewsAggregator.UnitMain in 'NewsAggregator.UnitMain.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
