program DFMScalingTest;

uses
  Vcl.Forms,
  DFMScalingTest.Form in 'DFMScalingTest.Form.pas' {Form809},
  DFMScalingTest.Frame in 'DFMScalingTest.Frame.pas' {Frame1: TFrame},
  DFMScalingTest.Modul in 'DFMScalingTest.Modul.pas' {DataModule1: TDataModule},
  DFMScalingTest.Modul.Descendant in 'DFMScalingTest.Modul.Descendant.pas' {DataModule2: TDataModule},
  DFMScalingTest.Form.Descendant in 'DFMScalingTest.Form.Descendant.pas' {Form1},
  DFMScalingTest.Frame.Descendant in 'DFMScalingTest.Frame.Descendant.pas' {Frame2: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm809, Form809);
  Application.Run;
end.
