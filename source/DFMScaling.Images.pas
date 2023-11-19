unit DFMScaling.Images;

interface

uses
  System.SysUtils, System.Classes,
  Vcl.BaseImageCollection, Vcl.ImageCollection, Vcl.Graphics;

type
  TdmImages = class(TDataModule)
    MainImageCollection: TImageCollection;
  private
    function GetImageArray(const AImageName: string): TGraphicArray;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    property ImageArray[const AImageName: string]: TGraphicArray read GetImageArray;
  end;

var
  dmImages: TdmImages;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

constructor TdmImages.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  Dummy := -1;
  inherited;
end;

function TdmImages.GetImageArray(const AImageName: string): TGraphicArray;
var
  idx: Integer;
  item: TImageCollectionItem;
  I: Integer;
begin
  idx := MainImageCollection.GetIndexByName(AImageName);
  if idx < 0 then
    Exit(nil);
  item := MainImageCollection.Images[idx];
  SetLength(Result, item.SourceImages.Count);
  for I := 0 to item.SourceImages.Count - 1 do
    Result[I] := item.SourceImages[I].Image;
end;

end.
