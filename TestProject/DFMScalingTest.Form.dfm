object Form809: TForm809
  Tag = 1
  Left = 4182
  Top = 342
  Caption = 'Form809'
  ClientHeight = 400
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Button1: TButton
    Tag = 1
    Left = 100
    Top = 40
    Width = 75
    Height = 25
    Action = Action1
    TabOrder = 0
  end
  object Button2: TButton
    Tag = 1
    Left = 100
    Top = 96
    Width = 75
    Height = 25
    Action = DataModule1.Action1
    TabOrder = 1
  end
  object Button3: TButton
    Left = 320
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 2
    OnClick = Button3Click
  end
  object ActionList1: TActionList
    Left = 34
    Top = 24
    object Action1: TAction
      Caption = 'Action1'
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 104
  end
end
