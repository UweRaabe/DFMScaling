unit DFMScaling.Main;

interface

uses
  ToolsAPI;

type
  TMagician = class
  strict private
  class var
    FInstance: TMagician;
  private
    FPackageNotifierID: Integer;
    function GetOTAServices: IOTAServices;
  public
    constructor Create;
    destructor Destroy; override;
    class procedure CreateInstance;
    class procedure DestroyInstance;
    property OTAServices: IOTAServices read GetOTAServices;
  end;

procedure Register;

implementation

uses
  System.IOUtils, System.Classes, System.SysUtils,
  DFMScaling.Scaler;

type
  TFormModuleNotifier = class(TNotifierObject, IOTANotifier, IOTAModuleNotifier)
  private
    FFileName: string;
  public
    constructor Create(const AFileName: string);
    procedure AfterSave;
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
    property FileName: string read FFileName;
  end;

function TFormModuleNotifier.CheckOverwrite: Boolean;
begin
  result := True;
end;

constructor TFormModuleNotifier.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
end;

procedure TFormModuleNotifier.ModuleRenamed(const NewName: string);
begin
  FFileName := TPath.ChangeExtension(NewName, '.dfm');
end;

procedure TFormModuleNotifier.AfterSave;
var
  lst: TStringList;
begin
  lst := TStringList.Create();
  try
    lst.LoadFromFile(FileName);
    if not TDfmScaling.ScaleDown(lst) then Exit;
    var lastWrite := TFile.GetLastWriteTime(FileName);
    lst.SaveToFile(FileName);
    TFile.SetLastWriteTime(FileName, lastWrite);
  finally
    lst.Free;
  end;
end;

type
  TMagicianNotifier = class(TNotifierObject, IOTAIDENotifier)
  private
    procedure CheckModule(const FileName: string);
    function GetOTAModuleServices: IOTAModuleServices;
  protected
  public
    procedure AfterCompile(Succeeded: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    property OTAModuleServices: IOTAModuleServices read GetOTAModuleServices;
  end;

constructor TMagician.Create;
begin
  inherited;
  FPackageNotifierID := OTAServices.AddNotifier(TMagicianNotifier.Create);
end;

destructor TMagician.Destroy;
begin
  if FPackageNotifierID > 0 then begin
    OTAServices.RemoveNotifier(FPackageNotifierID);
  end;
  inherited;
end;

class procedure TMagician.CreateInstance;
begin
  FInstance := TMagician.Create;
end;

class procedure TMagician.DestroyInstance;
begin
  FInstance.Free;
end;

function TMagician.GetOTAServices: IOTAServices;
begin
  BorlandIDEServices.GetService(IOTAServices, Result);
end;

procedure TMagicianNotifier.AfterCompile(Succeeded: Boolean);
begin
end;

procedure TMagicianNotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
end;

procedure TMagicianNotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel:
    Boolean);
begin
  case NotifyCode of
    ofnFileOpened: begin
      CheckModule(FileName);
    end;
  end;
end;

function TMagicianNotifier.GetOTAModuleServices: IOTAModuleServices;
begin
  BorlandIDEServices.GetService(IOTAModuleServices, Result);
end;

procedure TMagicianNotifier.CheckModule(const FileName: string);
var
  module: IOTAModule;
  I: Integer;
  modEditor: IOTAEditor;
begin
  module := OTAModuleServices.FindModule(FileName);
  if module <> nil then begin
    for I := 0 to module.ModuleFileCount - 1 do begin
      modEditor := module.ModuleFileEditors[I];
      if SameText(TPath.GetExtension(modEditor.FileName), '.dfm') then begin
        module.AddNotifier(TFormModuleNotifier.Create(modEditor.FileName));
      end;
    end;
  end;
end;

procedure Register;
begin
  TMagician.CreateInstance;
end;

initialization
finalization
  TMagician.DestroyInstance;
end.
