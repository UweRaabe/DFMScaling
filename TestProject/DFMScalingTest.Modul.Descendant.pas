unit DFMScalingTest.Modul.Descendant;

interface

uses
  System.SysUtils, System.Classes, DFMScalingTest.Modul, System.Actions, Vcl.ActnList, Vcl.ExtCtrls;

type
  TDataModule2 = class(TDataModule1)
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  DataModule2: TDataModule2;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
