unit DFMScaling.Scaler;

interface

uses
  System.Classes;

type
  TDfmScaling = class
  public
    class function ScaleDown(ALines: TStrings): Boolean; static;
  end;

implementation

uses
  Winapi.Windows,
  System.SysUtils,
  Vcl.Forms;

type
{$SCOPEDENUMS ON}
  TDesignType = (Form, Frame, DataModule, Other);
{$SCOPEDENUMS OFF}

function DetectDesignType(ALines: TStrings): TDesignType;
begin
  Result := TDesignType.DataModule;
  for var S in ALines do begin
    { skip first and last line }
    if not S.StartsWith('  ') then Continue;
    { abort on child components }
    if S[3] = ' ' then Break;
    var content := S.Substring(2);
    if content.StartsWith('ClientHeight') then
      Exit(TDesignType.Form);
    if content.StartsWith('TabOrder') then
      Exit(TDesignType.Frame);
  end;
end;

type
  TEventHandler = class
  private
    FEventHandler: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure FindMethod(Reader: TReader; const MethodName: string; var Address: Pointer; var Error: Boolean);
    procedure FindMethodInstance(Reader: TReader; const MethodName: string; var AMethod: TMethod; var Error: Boolean);
    procedure FindMethodName(Writer: TWriter; AMethod: TMethod; var MethodName: string);
  end;

type
  TDfmScaler = class
  private
    FEventHandler: TEventHandler;
    FInstance: TComponent;
    FLines: TStrings;
  protected
    function CreateInstance: TComponent; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadInstance;
    function Scale: Boolean; virtual; abstract;
    procedure StoreInstance;
    property EventHandler: TEventHandler read FEventHandler;
    property Instance: TComponent read FInstance;
    property Lines: TStrings read FLines write FLines;
  end;

type
  TDfmScaler<T: TComponent> = class(TDfmScaler)
  private
    function GetInstance: T;
  protected
    function CreateInstance: TComponent; override;
  public
    property Instance: T read GetInstance;
  end;

type
  TDataModuleScaler = class(TDfmScaler<TDataModule>)
  private
    procedure ScaleChildren(Child: TComponent);
  protected
  public
    function Scale: Boolean; override;
  end;

type
  TFormScaler = class(TDfmScaler<TForm>)
  private
  protected
  public
    function Scale: Boolean; override;
  end;

type
  TFrameScaler = class(TDfmScaler<TFrame>)
  private
  protected
  public
    function Scale: Boolean; override;
  end;

constructor TDfmScaler.Create;
begin
  inherited;
  FInstance := CreateInstance;
  FEventHandler := TEventHandler.Create();
end;

destructor TDfmScaler.Destroy;
begin
  FEventHandler.Free;
  FInstance.Free;
  inherited Destroy;
end;

procedure TDfmScaler.LoadInstance;
begin
  var stream := TMemoryStream.Create;
  try
    var text := TStringStream.Create;
    try
      Lines.SaveToStream(text);
      text.Position := 0;
      ObjectTextToBinary(text, stream);
    finally
      text.Free;
    end;
    stream.Position := 0;
    var Reader := TReader.Create(stream, 4096);
    try
      Reader.OnFindMethodInstance := EventHandler.FindMethodInstance;
      Reader.ReadRootComponent(Instance);
    finally
      Reader.Free;
    end;
  finally
    stream.Free;
  end;
end;

procedure TDfmScaler.StoreInstance;
begin
  var stream := TMemoryStream.Create;
  try
    var Writer := TWriter.Create(stream, 4096);
    try
      Writer.OnFindMethodName := EventHandler.FindMethodName;
      Writer.WriteDescendent(Instance, nil);
    finally
      Writer.Free;
    end;
    stream.Position := 0;
    var text := TStringStream.Create;
    try
      ObjectBinaryToText(stream, text);
      text.Position := 0;
      var firstLine := Lines[0];
      Lines.LoadFromStream(text);
      Lines[0] := firstLine;
    finally
      text.Free;
    end;
  finally
    stream.Free;
  end;
end;

function TDfmScaler<T>.CreateInstance: TComponent;
begin
  Result := T.Create(nil);
end;

function TDfmScaler<T>.GetInstance: T;
begin
  Result := inherited Instance as T;
end;

type
  TDataModuleHack = class(TDataModule);

function TDataModuleScaler.Scale: Boolean;
begin
  Result := False;
  if instance.PixelsPerInch = 96 then Exit;

  var P := instance.DesignOffset;
  P.X := MulDiv(P.X, 96, instance.PixelsPerInch);
  P.Y := MulDiv(P.Y, 96, instance.PixelsPerInch);
  instance.DesignOffset := P;

  P := instance.DesignSize;
  P.X := MulDiv(P.X, 96, instance.PixelsPerInch);
  P.Y := MulDiv(P.Y, 96, instance.PixelsPerInch);
  instance.DesignSize := P;

  TDataModuleHack(instance).GetChildren(ScaleChildren, instance);

  instance.PixelsPerInch := 96;
  Result := True;
end;

procedure TDataModuleScaler.ScaleChildren(Child: TComponent);
begin
  var P := Child.DesignInfo;
  LongRec(P).Lo := MulDiv(LongRec(P).Lo, 96, Instance.PixelsPerInch);
  LongRec(P).Hi := MulDiv(LongRec(P).Hi, 96, Instance.PixelsPerInch);
  Child.DesignInfo := P;
end;

function TFormScaler.Scale: Boolean;
begin
  Result := False;
  if instance.PixelsPerInch = 96 then Exit;
  instance.ScaleForPPI(96);
  Result := True;
end;

type
  TFrameHack = class(TFrame);

function TFrameScaler.Scale: Boolean;
var
  FDesignForm: TForm;
begin
  Result := False;
  if instance.PixelsPerInch = 96 then Exit;
  TFrameHack(Instance).SetDesignInstance(True);
  FDesignForm := TForm.Create(nil);
  try
    FDesignForm.ScaleForPPI(Instance.PixelsPerInch);
    Instance.Parent := FDesignForm;
    FDesignForm.ScaleForPPI(96);
    Instance.Parent := nil;
  finally
    FDesignForm.Free;
  end;
  Result := True;
end;

class function TDfmScaling.ScaleDown(ALines: TStrings): Boolean;
var
  scaler: TDfmScaler;
begin
  Result := False;
  case DetectDesignType(ALines) of
    TDesignType.Form: scaler := TFormScaler.Create;
    TDesignType.Frame: scaler := TFrameScaler.Create;
    TDesignType.DataModule: scaler := TDataModuleScaler.Create;
  else
    Exit;
  end;
  try
    scaler.Lines := ALines;
    scaler.LoadInstance;
    if not scaler.Scale then Exit;
    scaler.StoreInstance;
    Result := True;
  finally
    scaler.Free;
  end;
end;

constructor TEventHandler.Create;
begin
  inherited Create;
  FEventHandler := TStringList.Create;
end;

destructor TEventHandler.Destroy;
begin
  FEventHandler.Free;
  inherited Destroy;
end;

procedure TEventHandler.Clear;
begin
  FEventHandler.Clear;
end;

procedure TEventHandler.FindMethod(Reader: TReader; const MethodName: string; var Address: Pointer; var Error: Boolean);
var
  idx: Integer;
begin
  idx := FEventHandler.IndexOf(MethodName);
  if idx < 0 then
    idx := FEventHandler.Add(MethodName);
  Address := Pointer(idx + 1); // to avoid nil
  Error := False;
end;

procedure TEventHandler.FindMethodInstance(Reader: TReader; const MethodName: string; var AMethod: TMethod; var Error: Boolean);
begin
  AMethod.Data := nil;
  FindMethod(Reader, MethodName, AMethod.Code, Error);
end;

procedure TEventHandler.FindMethodName(Writer: TWriter; AMethod: TMethod; var MethodName: string);
var
  idx: Integer;
begin
  idx := Integer(AMethod.Code) - 1;
  if (idx >= 0) and (idx < FEventHandler.Count) then
    MethodName := FEventHandler[idx];
end;

end.
