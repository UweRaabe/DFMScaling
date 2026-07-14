unit DFMScalingTest.Frame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus;

type
  TFrame1 = class(TFrame)
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

procedure TFrame1.Button1Click(Sender: TObject);
begin
//
end;

end.
