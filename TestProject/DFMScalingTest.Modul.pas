unit DFMScalingTest.Modul;

interface

uses
  System.SysUtils, System.Classes, Vcl.ExtCtrls, System.Actions, Vcl.ActnList;

type
  TDataModule1 = class(TDataModule)
    Timer1: TTimer;
    ActionList1: TActionList;
    Action1: TAction;
  private
  public
  end;

var
  DataModule1: TDataModule1;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
