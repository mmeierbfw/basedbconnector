object formdb: Tformdb
  Left = 0
  Top = 0
  Caption = 'formdb'
  ClientHeight = 646
  ClientWidth = 1141
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object DBGrid1: TDBGrid
    AlignWithMargins = True
    Left = 2
    Top = 2
    Width = 1137
    Height = 642
    Margins.Left = 2
    Margins.Top = 2
    Margins.Right = 2
    Margins.Bottom = 2
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    DataSource = DataSource1
    FixedColor = 16706255
    GradientEndColor = clWhite
    GradientStartColor = clGray
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgMultiSelect, dgTitleClick, dgTitleHotTrack]
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 712
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ZConnection1: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    DesignConnection = True
    TestMode = 0
    HostName = '127.0.0.1'
    Port = 7777
    Database = 'scandokumente'
    User = 'tiffy'
    Password = 'maunze01'
    Protocol = 'mysql'
    Left = 312
    Top = 152
  end
  object ZQuery1: TZQuery
    Connection = ZConnection1
    SQL.Strings = (
      '')
    Params = <>
    Left = 64
    Top = 80
  end
  object DataSource1: TDataSource
    DataSet = ZQuery1
    Left = 56
    Top = 136
  end
  object queryaufträge: TZQuery
    Connection = ZConnection1
    SQL.Strings = (
      '')
    Params = <>
    Left = 480
    Top = 368
  end
  object dsaufträge: TDataSource
    DataSet = queryaufträge
    Left = 480
    Top = 424
  end
  object queryableser: TZQuery
    Connection = ZConnection1
    SQL.Strings = (
      '')
    Params = <>
    Left = 184
    Top = 352
  end
  object dsableser: TDataSource
    DataSet = queryableser
    Left = 176
    Top = 408
  end
  object queryauftraggeber: TZQuery
    Connection = ZConnection1
    SQL.Strings = (
      '')
    Params = <>
    Left = 336
    Top = 352
  end
  object dsauftraggeber: TDataSource
    DataSet = queryauftraggeber
    Left = 336
    Top = 408
  end
  object ZConnection2: TZConnection
    ControlsCodePage = cCP_UTF16
    Catalog = ''
    TestMode = 0
    HostName = ''
    Port = 0
    Database = 'WO_TYP'
    User = 'jovani'
    Password = 'maunze01'
    Protocol = 'sqlite-3'
    Left = 1000
    Top = 40
  end
  object querynutzer: TZQuery
    Connection = ZConnection2
    Params = <>
    Left = 1008
    Top = 104
  end
  object dsnutzer: TDataSource
    DataSet = querynutzer
    Left = 1008
    Top = 168
  end
  object querycount: TZQuery
    Connection = ZConnection1
    Params = <>
    DataSource = DataSource1
    Left = 1032
    Top = 352
  end
  object dscount: TDataSource
    DataSet = querycount
    Left = 1024
    Top = 416
  end
  object queryupdate: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 576
    Top = 48
  end
  object dsupdate: TDataSource
    DataSet = queryupdate
    Left = 576
    Top = 112
  end
  object queryanforderungen: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 648
    Top = 368
  end
  object dsanforderungen: TDataSource
    DataSet = queryanforderungen
    Left = 648
    Top = 424
  end
  object queryunbearbeitet: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 792
    Top = 368
  end
  object dsunbearbeitet: TDataSource
    DataSet = queryunbearbeitet
    Left = 792
    Top = 424
  end
  object querydelete: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 784
    Top = 128
  end
  object dsdelete: TDataSource
    DataSet = querydelete
    Left = 784
    Top = 184
  end
  object queryzwi: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 448
    Top = 32
  end
  object dszwi: TDataSource
    DataSet = queryzwi
    Left = 448
    Top = 96
  end
  object dsen: TDataSource
    DataSet = queryen
    Left = 296
    Top = 104
  end
  object queryen: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 296
    Top = 40
  end
  object querymon: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 192
    Top = 40
  end
  object dsmon: TDataSource
    DataSet = querymon
    Left = 192
    Top = 104
  end
  object ZQuery2: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 144
    Top = 184
  end
  object dsnuter: TDataSource
    DataSet = ZQuery2
    Left = 144
    Top = 248
  end
  object queryrekl: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 248
    Top = 200
  end
  object dsrekl: TDataSource
    DataSet = queryrekl
    Left = 248
    Top = 264
  end
  object querynuliste: TZQuery
    Connection = ZConnection1
    Params = <>
    Left = 456
    Top = 168
  end
  object dsnuliste: TDataSource
    DataSet = querynuliste
    Left = 456
    Top = 232
  end
  object querykn: TZQuery
    Connection = ZConnection1
    SQL.Strings = (
      '')
    Params = <>
    Left = 56
    Top = 360
  end
  object dskn: TDataSource
    DataSet = querykn
    Left = 48
    Top = 416
  end
end
