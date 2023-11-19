unit DFMScaling.Tools;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.Graphics;

type
  TTools = class
  private
  class var
    FVersion: string;
    class function GetDescription: string; static;
    class function GetTitle: string; static;
    class function GetVersion: string; static;
  public
    class function CreateFromIconResource(const AName: string; ASize: Integer): TBitmap; overload;
    class function AppVersion: string; static;
    class function FindHelpFile: string;
    class procedure LoadFromIconResource(Target: TIcon; const AName: string); overload;
    class procedure OpenLocalFile(Path: String);
    class procedure ShowTopicHelp(const Topic, HelpFile: String);
    class property Description: string read GetDescription;
    class property Title: string read GetTitle;
    class property Version: string read GetVersion;
  end;

implementation

uses
  Winapi.ShellAPI,
  System.Win.Registry,
  System.IOUtils, System.SysUtils,
  Vcl.Forms,
  DFMScaling.Consts;

{$IF RTLVersion < 30.0 Seattle}
function GetProductVersion(const AFileName: string; var AMajor, AMinor, ABuild: Cardinal): Boolean;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := False;
  // GetFileVersionInfo modifies the filename parameter data while parsing.
  // Copy the string const into a local variable to create a writeable copy.
  FileName := AFileName;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
        begin
          AMajor := HiWord(FI.dwProductVersionMS);
          AMinor := LoWord(FI.dwProductVersionMS);
          ABuild := HiWord(FI.dwProductVersionLS);
          Result:= True;
        end;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;
{$IFEND}

class function TTools.CreateFromIconResource(const AName: string; ASize: Integer): TBitmap;
var
  icon: TIcon;
begin
  Result := TBitmap.Create;
  icon := TIcon.Create;
  try
    icon.SetSize(ASize, ASize);
    LoadFromIconResource(icon, AName);
    Result.Assign(icon);
  finally
    icon.Free;
  end;
end;

class function TTools.AppVersion: string;
var
  build: Cardinal;
  major: Cardinal;
  minor: Cardinal;
begin
  if GetProductVersion(GetModuleName(HInstance), major, minor, build) then begin
    Result := Format('V%d.%d.%d', [major, minor, build]); // do not localize
  end
  else begin
    Result := cVersion;
  end;
end;

class function TTools.FindHelpFile: string;
const
  cKeys: array[0..1] of HKEY = (HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE);
var
  reg: TRegistry;
  rKey: HKEY;
  S: string;
begin
  reg := TRegistry.Create(KEY_READ);
  try
    for rKey in cKeys do begin
      reg.RootKey := rKey;
      if reg.OpenKeyReadOnly(cRegKey) then begin
        S := reg.ReadString(cRegItemHelp);
        if (S > '') and FileExists(S) then Exit(S);
      end;
    end;
  finally
    reg.Free;
  end;
  Result := '';
end;

class function TTools.GetDescription: string;
begin
  Result := SDescription + sLineBreak + sLineBreak + cCopyRight;
end;

class function TTools.GetTitle: string;
begin
  Result := cTitle + ' ' + Version;
end;

class function TTools.GetVersion: string;
begin
  if FVersion = '' then begin
    FVersion := AppVersion;
  end;
  Result := FVersion;
end;

class procedure TTools.LoadFromIconResource(Target: TIcon; const AName: string);
begin
  Target.Handle := LoadImage(HInstance, PChar(AName), IMAGE_ICON, Target.Width, Target.Height, 0);
end;

class procedure TTools.OpenLocalFile(Path: String);
var
  SEInfo: TShellExecuteInfo;
begin
  if (Path > '') and FileExists(Path) then begin
    FillChar(SEInfo, SizeOf(SEInfo), 0);
    SEInfo.cbSize := SizeOf(TShellExecuteInfo);
    SEInfo.Wnd := 0;
    SEInfo.lpFile := PChar(Path);
    SEInfo.lpParameters := nil;
    SEInfo.nShow := SW_SHOWDEFAULT;
    SEInfo.lpVerb := 'open';
    SEInfo.lpDirectory := PChar(ExtractFileDir(Path));
    ShellExecuteEx(@SEInfo);
  end;
end;

class procedure TTools.ShowTopicHelp(const Topic, HelpFile: String);
begin
  if (Topic > '') and (Application.HelpSystem <> nil) then begin
    Application.HelpSystem.ShowTopicHelp(Topic, HelpFile);
  end
  else begin
    OpenLocalFile(HelpFile);
  end;
end;

end.

