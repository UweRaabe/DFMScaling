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
    FPluginInfoID: Integer;
    function GetOTAAboutBoxServices: IOTAAboutBoxServices;
    function GetOTAServices: IOTAServices;
  public
    constructor Create;
    destructor Destroy; override;
    class procedure CreateInstance;
    class procedure DestroyInstance;
    property OTAAboutBoxServices: IOTAAboutBoxServices read GetOTAAboutBoxServices;
    property OTAServices: IOTAServices read GetOTAServices;
  end;

procedure Register;

implementation

uses
  System.IOUtils, System.Classes, System.SysUtils,
  DFMScaling.Scaler, DFMScaling.Images, DFMScaling.Tools;

const
  cIconName = 'DFMScaling';
  cTitle = 'DFM Scaling Magician';
  cVersion = 'V1.0.0';
  cCopyright = 'Copyrightę 2023 by Uwe Raabe';

resourcestring
  SDescription = 'Automates some tasks with projects.';

type
  TFormModuleNotifier = class(TNotifierObject, IOTANotifier, IOTAModuleNotifier)
  private
    FClassGroup: TPersistentClass;
    FFileName: string;
  public
    constructor Create(const AFileName: string; AClassGroup: TPersistentClass);
    procedure AfterSave;
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
    property ClassGroup: TPersistentClass read FClassGroup;
    property FileName: string read FFileName;
  end;

function TFormModuleNotifier.CheckOverwrite: Boolean;
begin
  result := True;
end;

constructor TFormModuleNotifier.Create(const AFileName: string; AClassGroup: TPersistentClass);
begin
  inherited Create;
  FFileName := AFileName;
  FClassGroup := AClassGroup;
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
    if not TDfmScaling.ScaleDown(lst, ClassGroup) then Exit;
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
  dmImages := TdmImages.Create(nil);
  SplashScreenServices.AddPluginBitmap(TTools.Title, dmImages.ImageArray[cIconName]);
  FPluginInfoID := OTAAboutBoxServices.AddPluginInfo(TTools.Title, TTools.Description, dmImages.ImageArray[cIconName]);
  FPackageNotifierID := OTAServices.AddNotifier(TMagicianNotifier.Create);
end;

destructor TMagician.Destroy;
begin
  if FPluginInfoID > 0 then begin
    OTAAboutBoxServices.RemovePluginInfo(FPluginInfoID);
  end;
  if FPackageNotifierID > 0 then begin
    OTAServices.RemoveNotifier(FPackageNotifierID);
  end;
  dmImages.Free;
  dmImages := nil;
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

function TMagician.GetOTAAboutBoxServices: IOTAAboutBoxServices;
begin
  BorlandIDEServices.GetService(IOTAAboutBoxServices, Result);
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
  formEditor: IOTAFormEditor;
  module: IOTAModule;
  I: Integer;
begin
  module := OTAModuleServices.FindModule(FileName);
  if module <> nil then begin
    for I := 0 to module.ModuleFileCount - 1 do begin
      if not Supports(module.ModuleFileEditors[I], IOTAFormEditor, formEditor) then Continue;
      if not SameText(TPath.GetExtension(formEditor.FileName), '.dfm') then Continue;
      var designer := (formEditor as INTAFormEditor).FormDesigner;
      module.AddNotifier(TFormModuleNotifier.Create(formEditor.FileName, designer.ActiveClassGroup));
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
