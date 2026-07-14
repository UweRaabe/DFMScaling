unit DFMScalingTest.Frame.Descendant;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DFMScalingTest.Frame, Vcl.Menus, Vcl.StdCtrls;

type
  TFrame2 = class(TFrame1)
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Frame2: TFrame2;

implementation

{$R *.dfm}

end.
