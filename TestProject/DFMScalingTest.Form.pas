unit DFMScalingTest.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Actions, Vcl.ActnList, Vcl.Menus;

type
  TForm809 = class(TForm)
    Button1: TButton;
    ActionList1: TActionList;
    Action1: TAction;
    Button2: TButton;
    Button3: TButton;
    PopupMenu1: TPopupMenu;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form809: TForm809;

implementation

{$R *.dfm}

uses
  DFMScalingTest.Modul;

procedure TForm809.Button1Click(Sender: TObject);
begin
//
end;

procedure TForm809.Button3Click(Sender: TObject);
begin
//
end;

procedure TForm809.FormCreate(Sender: TObject);
begin
//  Hurz
end;

end.
