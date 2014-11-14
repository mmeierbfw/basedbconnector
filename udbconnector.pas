unit udbconnector;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, uutils,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MySQL, Data.DB,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, Vcl.StdCtrls, FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI, ZAbstractTable, ZDataset, ZAbstractRODataset,
  ZAbstractDataset, ZAbstractConnection, ZConnection,
  System.Generics.collections, ubaseconstants, shellapi, Vcl.Grids, Vcl.DBGrids,
  Data.FMTBcd, Data.SqlExpr, Datasnap.DBClient, strutils;

type
  Tformdb = class(TForm)
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    DBGrid1: TDBGrid;
    Button1: TButton;
    DataSource1: TDataSource;
    queryaufträge: TZQuery;
    dsaufträge: TDataSource;
    queryableser: TZQuery;
    dsableser: TDataSource;
    queryauftraggeber: TZQuery;
    dsauftraggeber: TDataSource;
    ZConnection2: TZConnection;
    querynutzer: TZQuery;
    dsnutzer: TDataSource;
    querycount: TZQuery;
    dscount: TDataSource;
    queryupdate: TZQuery;
    dsupdate: TDataSource;
    queryanforderungen: TZQuery;
    dsanforderungen: TDataSource;
    queryunbearbeitet: TZQuery;
    dsunbearbeitet: TDataSource;
    querydelete: TZQuery;
    dsdelete: TDataSource;
    queryzwi: TZQuery;
    dszwi: TDataSource;
    dsen: TDataSource;
    queryen: TZQuery;
    querymon: TZQuery;
    dsmon: TDataSource;
    ZQuery2: TZQuery;
    dsnuter: TDataSource;
    queryrekl: TZQuery;
    dsrekl: TDataSource;
    querynuliste: TZQuery;
    dsnuliste: TDataSource;
    querykn: TZQuery;
    dskn: TDataSource;
    procedure Button1Click(Sender: TObject);

    // procedure Button1Click(Sender: TObject);
  private

    con: Tbaseconstants;
    /// <param name="startstr">
    /// Der Anfang des Mysql Aufrufs "INSERT INTO", "UPDATE", ..
    /// </param>
    /// <param name="databasex">
    /// in welche Tabelle?
    /// </param>
    /// <param name="values">
    /// Dictionary mit Key / Value Paaren
    /// </param>
    function createCloze(startstr, databasex: string;
      values: Tdictionary<string, string>): string;
    function createquery(database, wherestring: string;
      query: TStringlist): string;
    function createRunningNumerQuery(kundennummer: integer;
      table, sachbearbeiter: string): string; overload;
    function createRunningNumerQuery(kundennummer: integer;
      sachbearbeiter: string): string; overload;
    function exec(query: TStringlist): boolean; overload;
    function exec(query: string): boolean; overload;
    function exec(query: string; paramlist: Tdictionary<string, string>)
      : boolean; overload;
    function getlastid(): integer;
    function open(query, selectme: string): string;

    procedure FormCreate(Sender: TObject); overload;
  public

    procedure FormCreate(Sender: TObject; con: Tbaseconstants); overload;
    procedure doquery(zquery: TZQuery; database: string; wherestring: string;
      query: TStringlist);
    function get(database, wherestring: string; query: TStringlist)
      : Tdictionary<string, string>; overload;
    function get(zquery: TZQuery; database, wherestring: string;
      query: TStringlist): Tdictionary<string, string>; overload;
    function getfromHN(database, table, wherestring: string; list: TStringlist)
      : Tdictionary<string, string>; overload;
    function showquery(query: string): boolean;
    function connect(): boolean; overload;
    function connect(query: TZQuery): boolean; overload;
    function getno(kundennummer: integer; table, sb: string): integer;
    function insertquery(doctype: integer; databasex: string;
      values: Tdictionary<string, string>): boolean;
    function doupdate(query: string): boolean;
    procedure RunFile(const aFile, cmdLine: string; WindowState: Word);
    function disconnect: boolean;
    function count(value, table, query: string): integer;
    function update(id, table, key, value: string): boolean;
    function countdistinct(value, table, query: string): integer;
    function getmaxno(kn, sb: string): string;
    function replacequery(table: string;
      values: Tdictionary<string, string>): boolean;
    function delete(table, query: string): boolean;
    function getkundennr(kdn: string): TList<integer>;
    function insertintoauftrag(dict: Tdictionary<string, string>): boolean;
  end;

var
  formdb: Tformdb;
  sei   : TShellExecuteInfo;

implementation

{$R *.dfm}

uses umain;
{ TForm1 }

procedure Tformdb.RunFile(const aFile, cmdLine: string; WindowState: Word);
begin
  FillChar(sei, SizeOf(sei), 0);
  sei.cbSize       := SizeOf(sei);
  sei.fMask        := SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  sei.lpVerb       := 'open';
  sei.lpFile       := PChar(aFile);
  sei.lpDirectory  := PChar(ExtractFileDir(aFile));
  sei.lpParameters := PChar(cmdLine);
  sei.nShow        := WindowState;

  if not ShellExecuteEx(@sei) then RaiseLastOSError;
  if sei.hProcess <> 0 then begin
    while WaitForSingleObject(sei.hProcess, 50) = WAIT_TIMEOUT do
        Application.ProcessMessages;
    CloseHandle(sei.hProcess);
  end;
end;

function Tformdb.connect(): boolean;
begin
  Result := connect(ZQuery1);
end;

{ erzeuge einen Lückentext, um möglichst dynamische Abfragen gestalten zu können }
procedure Tformdb.Button1Click(Sender: TObject);
begin
  ZQuery1.SQL.Text :=
    'Select Eintragsdatum, Liegenschaft from Auftragsanforderung;';
  ZQuery1.open;
end;

function Tformdb.connect(query: TZQuery): boolean;

var
  res    : boolean;
  exename: string;
  cons   : Tbaseconstants;
  DB     : string;
begin
  cons := Tbaseconstants.Create;
  try
    DB := cons.database;

    // if not Assigned(query) then query := TZQuery.Create(nil);
    if query = nil then query := TZQuery.Create(nil);

    // exename := IncludeTrailingPathDelimiter(ExtractFilePath(Application.exename))
    // + 'plink.exe';
    // RunFile(exename,
    // '-ssh 148.251.138.2 -l tiffy  -L 7777:127.0.0.1:3306 -pw maunze01',
    // sw_hide);
    ZConnection1.LibraryLocation := ExtractFilePath(Application.exename) +
      'libmysql.dll';
    if not Assigned(ZConnection1) then
        ZConnection1                      := TZConnection.Create(self);
    if not Assigned(ZQuery1) then ZQuery1 := TZQuery.Create(self);
    try
      ZConnection1.user     := 'tiffy';
      ZConnection1.Password := 'maunze01';
      ZConnection1.port     := 7777;
      ZConnection1.hostname := '127.0.0.1';
      ZConnection1.database := cons.database;

      if not ZConnection1.Connected then ZConnection1.connect;
      query.Connection := ZConnection1;
      res              := query.Connection.Connected;
      Result           := res;
    except
      on e: exception do begin
        showmessage(e.message);
        OutputDebugString
          (PChar('es kann keine Verbindung zur Datenbank hergestellt werden'));

      end;
    end;
  finally cons.Free;

  end;

end;
// --------------------------------------------------------------

function Tformdb.countdistinct(value, table, query: string): integer;
begin
  value  := 'DISTINCT ' + value;
  Result := count(value, table, query);
end;

// -----------------------------------------------------

function Tformdb.count(value, table, query: string): integer;
var
  SQL: string;
begin
  SQL := 'SELECT COUNT( ' + value + ')   AS val FROM ' + table + ' ' + query;
  querycount.SQL.Text := SQL;
  querycount.open;
  Result := querycount.FieldByName('val').AsInteger;
end;

function Tformdb.createCloze(startstr, databasex: string;
  values: Tdictionary<string, string>): string;
var
  str      : string;
  cnt, size: integer;
  key      : string;
  cons     : Tbaseconstants;
begin
  cons := Tbaseconstants.Create;
  try
    with cons do begin
      Result := Format(insertBegin, [startstr, databasex]);
      // keine Werte, also keine Klammer öffnen
      if (values.count = 0) then begin
        // Result := copy(Result, 1, length(Result) - 1);
        Result := Result + ') VALUES();';
        exit;
      end;
      for key in values.Keys do begin
        Result := Result + key + ', ';
      end;
      Result := copy(Result, 1, length(Result) - 2);
      // das letzte Komma wieder löschen
      Result := Result + insertMiddle;
      for key in values.Keys do begin
        Result := Result + QuotedStr(values.Items[key]) + ', ';
      end;
      Result := copy(Result, 1, length(Result) - 2);
      // das letzte Komma wieder löschen

      Result := Result + insertEnd;
    end;
  finally cons.Free;
  end;
end;

// #################################################
function Tformdb.createquery(database, wherestring: string;
  query: TStringlist): string;
var
  querystring: string;
  attr       : string;
begin
  querystring                      := 'SELECT ';
  for attr in query do querystring := querystring + attr + ', ';
  querystring := copy(querystring, 1, length(querystring) - 2)
  // das letzte Komma löschen
    + ' FROM ' + database + ' ' + wherestring + ';';
  Result := querystring;
end;

function Tformdb.createRunningNumerQuery(kundennummer: integer;
  sachbearbeiter: string): string;
var
  query    : string;
  cnt, size: integer;
  f        : textfile;
  list     : TStringlist;
begin
  Result := Format
    ('SELECT Dokumentid.dokumentid FROM Dokumentid WHERE sachbearbeiter = %d',
    [strtoint(sachbearbeiter)]);
end;

function Tformdb.createRunningNumerQuery(kundennummer: integer;
  table, sachbearbeiter: string): string;
var
  query    : string;
  cnt, size: integer;
  f        : textfile;
begin
  query := Format
    ('SELECT MAX(dokumentid) AS max FROM %s WHERE kundennummer = %d AND sachbearbeiter = %s ',
    [table, kundennummer, sachbearbeiter]);
  Result := query;

end;

function Tformdb.delete(table, query: string): boolean;
var
  SQL: string;
begin
  if not connect then Begin
    OutputDebugString('keine Datenbankverbindung möglich');
    exit;
  End;
  try
    SQL := Format('DELETE FROM %S WHERE %S;', [table, query]);
    querydelete.SQL.Clear;
    querydelete.SQL.Add(SQL);
    querydelete.ExecSQL;
    Result := true;
  except
    on e: exception do begin
      showmessage(e.message);
      Result := false;
    end;
  end;
end;

function Tformdb.disconnect: boolean;
begin
  try
    // TerminateProcess(sei.hProcess, 0);
      ZConnection1.disconnect;
  except OutputDebugString('Verbindung kann nicht geschlossen werden');
  end;
end;

procedure Tformdb.doquery(zquery: TZQuery; database: string;
  wherestring: string; query: TStringlist);

var
  Ds         : tdataset;
  res        : Tdictionary<string, string>;
  attr, value: string;
  count      : integer;
  SQL        : string;
  datasource : TDataSource;
begin
  try

    if not connect(zquery) then begin
      OutputDebugString('keine Datenbankverbindung möglich');
      exit;
    end;
    try
      SQL             := createquery(database, wherestring, query);
      zquery.Filtered := false;
      zquery.filter   := '';
      zquery.SQL.Clear;
      zquery.SQL.Add(SQL);
      zquery.open;
    except
      on e: exception do begin
        showmessage(e.message);
      end;

    end;
  finally
  end;
end;

function Tformdb.doupdate(query: string): boolean;

var
  help: integer;
begin
  try
    if not connect then exit;
    try
      ZQuery1.SQL.Add
        ('update Auftragsanforderung set Auftragsanforderung.AnforderungAbgeschlossen=1 where id=1');
      ZQuery1.ExecSQL;
      // DBGrid1.DataSource.DataSet.open;
      // help := ZQuery1.RecordCount;
      // showmessage(inttostr(help) + ' ergebnisse');
      // DBGrid1.DataSource := ZQuery1.DataSource;
      // formdb.Show;
      Result := true;
    except
      on e: exception do begin
        OutputDebugString(PChar(e.message));

        Result := false;
      end;
    end;

  finally

  end;
end;

function Tformdb.exec(query: string): boolean;
begin
  with con do begin
    Result        := false;
    screen.cursor := crhourglass;
    try
      with ZQuery1 do begin
        SQL.Clear;
        SQL.Add(query);
        try ExecSQL;
        except
          on e: exception do showmessage(e.message);

        end;
      end;
    finally
      screen.cursor := crdefault;
      ZQuery1.SQL.Clear;
    end;
  end;
end;

{ function Tformdb.exec(query: string;
  paramlist: Tdictionary<string, string>): boolean;

  query: ein Suchstring mit Parametern (:parameter)
  paramlist: die Liste mit Key-Value Paaren, die der query braucht.
  Aufruf wird erzeugt und ausgeführt
}
function Tformdb.exec(query: string;
  paramlist: Tdictionary<string, string>): boolean;
var
  key: string;
begin
  with con do begin
    Result        := false;
    screen.cursor := crhourglass;
    try
      with ZQuery1 do begin
        SQL.Clear;
        SQL.Add(query);
        for key in paramlist.Keys do begin
          ParamByName(key).AsString := paramlist.Items[key];
        end;
        ExecSQL;
      end;
    finally screen.cursor := crdefault;
    end;
  end;

end;

{ function Tformdb.exec(query: TStringlist): boolean;
  Eine Reihe von Aufrufen wird ausgeführt }
function Tformdb.exec(query: TStringlist): boolean;
var
  line: string;
begin
  with con do begin
    Result := false;
    try
      screen.cursor := crhourglass;
      OutputDebugString(PChar(query));
      if not connect then exit;
      try
        ZQuery1.SQL.Clear;

        for line in query do begin

          ZQuery1.SQL.Add(line);
        end;

        OutputDebugString(PChar(ZQuery1.SQL.Text));
        ZQuery1.ExecSQL;
        Result := true;
      except
        on e: exception do showmessage(PChar(e.message));
      end;

    finally screen.cursor := crdefault;
    end;
  end;
end;

procedure Tformdb.FormCreate(Sender: TObject; con: Tbaseconstants);
begin
  self.con := con;
end;

function Tformdb.get(zquery: TZQuery; database, wherestring: string;
  query: TStringlist): Tdictionary<string, string>;
var
  res        : Tdictionary<string, string>;
  attr, value: string;
  count      : integer;
  datasource : TDataSource;
  field      : string;
begin
  res := Tdictionary<string, string>.Create();
  try
    if not connect then exit;
    zquery.SQL.Text := createquery(database, wherestring, query);
    try zquery.open;
    except
      on e: exception do showmessage(e.message);

    end;
    count := zquery.RecordCount;
    if count = 0 then exit;
    for attr in query do begin
      if strcontains('.', attr) then begin
        field := getlast('.', attr);
      end
      else field := attr;

      value := zquery.FieldByName(field).AsString;
      res.Add(field, value);
    end;
  finally Result := res;
  end;
end;

function Tformdb.getfromHN(database, table, wherestring: string;
  list: TStringlist): Tdictionary<string, string>;
var
  res        : Tdictionary<string, string>;
  attr, value: string;
begin
  try
    OutputDebugString(PChar(database));
    res                          := Tdictionary<string, string>.Create();
    ZConnection2.LibraryLocation := ExtractFilePath(Application.exename) +
      'sqlite3.dll';
    ZConnection2.database := database;
    if ZConnection2.Connected then ZConnection2.disconnect;

    if not ZConnection2.Connected then ZConnection2.connect;
    if not ZConnection2.Connected then exit;

    querynutzer.SQL.Clear;
    querynutzer.SQL.Text   := createquery(table, wherestring, list);
    querynutzer.Connection := ZConnection2;
    querynutzer.open;
    for attr in list do begin
      value := querynutzer.FieldByName(attr).AsString;
      res.Add(attr, value);
    end;
  finally
    // ZConnection2.disconnect;
      Result := res;
  end;
end;

function Tformdb.getkundennr(kdn: string): TList<integer>;
var
  query: TStringlist;
begin
  Result := TList<integer>.Create;
  query  := TStringlist.Create;
  query.Add(Format('SELECT ordner_id FROM kunden WHERE kdn = %s', [kdn]));
  try

    exec(query);
    with ZQuery1 do begin
      // SQL.Clear;
      // SQL.Add('SELECT ordner_id FROM kunden WHERE kdn = :kdn');
      // ParamByName('kdn').AsString := kdn;
      // Open;
      while not Eof do begin
        Result.Add(FieldByName('ordner_id').AsInteger);
        next;
      end;
    end;

  except
    on e: exception do begin
      showmessage(e.message);
    end;

  end;
end;

function Tformdb.getlastid: integer;
begin
  try
    Result := -1;
    with ZQuery1 do begin
      SQL.Clear;
      SQL.Add('SELECT LAST_INSERT_ID() as ID;');
      open;
    end;
    Result := ZQuery1.FieldByName('ID').AsInteger;
  except
    on e: exception do showmessage(e.message);
  end;
end;

function Tformdb.getmaxno(kn, sb: string): string;
var
  res          : string;
  doctypestring: string;
  query        : string;
begin
  try
    if connect() then begin
      query := createRunningNumerQuery(strtoint(kn), sb);
      OutputDebugString(PChar(query));
      ZQuery1.SQL.Text := query;
      try
        ZQuery1.open;
        res      := ZQuery1.FieldByName('Dokumentid').AsString;
      except res := '0';
      end;
    end else begin
      res := '0';
      OutputDebugString
        ('es kann keine Verbindung zur Datenbank hergestellt werden');
    end;
  finally
    screen.cursor := crdefault;
    // disconnect;
    ZQuery1.Close;
    if res = '' then res := '0';

    Result := inttostr(strtoint(res) + 1);
  end;
end;

function Tformdb.get(database, wherestring: string; query: TStringlist)
  : Tdictionary<string, string>;
var
  res        : Tdictionary<string, string>;
  attr, value: string;
  count      : integer;
  datasource : TDataSource;
begin
  res := Tdictionary<string, string>.Create();
  try
    if not connect then exit;
    ZQuery1.SQL.Text := createquery(database, wherestring, query);
    try ZQuery1.open;
    except
      on e: exception do begin
        showmessage(e.message);
      end;

    end;
    count := ZQuery1.RecordCount;
    if count = 0 then exit;
    for attr in query do begin
      value := ZQuery1.FieldByName(attr).AsString;
      res.Add(attr, value);
    end;
  finally Result := res;
  end;
end;

function Tformdb.getno(kundennummer: integer; table, sb: string): integer;
var
  res          : string;
  doctypestring: string;
  query        : string;
begin
  try
    Application.ProcessMessages;
    if connect() then begin
      query := createRunningNumerQuery(kundennummer, table, sb);
      OutputDebugString(PChar(query));
      ZQuery1.SQL.Text := query;
      try
        ZQuery1.open;
        res      := ZQuery1.FieldByName('max').AsString;
      except res := '0';
      end;
    end else begin
      res := '0';
      OutputDebugString
        ('es kann keine Verbindung zur Datenbank hergestellt werden');
    end;
  finally
    screen.cursor := crdefault;
    // disconnect;
    ZQuery1.Close;
    Result := strtoint(res) + 1;
  end;
end;

function Tformdb.insertintoauftrag(dict: Tdictionary<string, string>): boolean;
var
  dokid, sp_id, type_id, termin_id, monteur_id: string;
  cons                                        : Tbaseconstants;
begin
  cons := Tbaseconstants.Create;
  try
    with cons do begin
      try

        with ZQuery1 do begin
          // Dokument eintragen
          if not connect(ZQuery1) then exit;
          SQL.Clear;
          SQL.Add('INSERT INTO test.dokument(dateiname) VALUES(:dateiname);');
          // ParamByName('tabellenname').AsString   := table_dok;
          // ParamByName('dateinameconst').AsString := 'dateiname';
          ParamByName('dateiname').AsString := dict.Items[Dateiname];
          ExecSQL;
          SQL.Clear;
          SQL.Add('SELECT LAST_INSERT_ID()');
          open;

          // DOkument-ID ausgeben lassen
          dokid := FieldByName('LAST_INSERT_ID()').AsString;
          SQL.Clear;

          SQL.Add('INSERT INTO test.termin(ausführungstermin, von, bis) VALUES(:ausführungstermin, :von,:bis);');
          ParamByName('ausführungstermin').AsString :=
            dict.Items[ausführungsdatum];
          ParamByName('von').AsString := dict.Items[ausführungsstart];
          ParamByName('bis').AsString := dict.Items[ausführungsende];
          ExecSQL;
          SQL.Clear;
          SQL.Add('SELECT ID FROM verwaltung.ableser WHERE Name1 = :name');
          ParamByName('name').AsString := dict.Items[Monteur];
          open;
          monteur_id := FieldByName('ID').AsString;
          SQL.Clear;
          // Auftragsid ausgeben lassen;
          SQL.Add('SELECT LAST_INSERT_ID()');
          open;
          sp_id := FieldByName('LAST_INSERT_ID()').AsString;

          SQL.Clear;
          SQL.Add('SELECT LAST_INSERT_ID()');
          open;
          termin_id := FieldByName('LAST_INSERT_ID()').AsString;
          SQL.Clear;
          // Details in Auftragstabelle
          SQL.Add('INSERT INTO test.auftrag(informiert,  auftragstyp_id, auftragsnr, erreicht,  monteur_id, termin_id) VALUES'
            + '(:informiert, :auftragstyp_id, :auftragsnr,:erreicht,  :monteur_id,  :termin_id) ');
          ParamByName(informiert).AsString        := dict.Items[informiert];
          ParamByName('auftragstyp_id').AsInteger := 3;
          ParamByName('auftragsnr').AsString := dict.Items[Auftragsnummer];
          ParamByName('erreicht').AsString   := dict.Items[erreicht];
          ParamByName('termin_id').AsString  := termin_id;
          ParamByName('monteur_id').AsString := monteur_id;
          OutputDebugString(PChar(SQL.Text));
          ExecSQL;

          SQL.Clear;

          // Typen-id ausgeben lassen
          SQL.Add('SELECT typen_id FROM test.typen WHERE typen_name = :ty_id');
          ParamByName('ty_id').AsString := 'ausgang';
          open;

          type_id := FieldByName('typen_id').AsString;
          SQL.Clear;

          SQL.Add('SET foreign_key_checks = 0;');
          ExecSQL;
          SQL.Clear;
          SQL.Add('INSERT INTO test.commontab(liegenschaft, posteingang, kundennummer, abrechnungsende, notizen, sachbearbeiter_id, abrechnungsrelevant, dokument_id, dokumenttyp_id, sp_id) VALUES  '
            + '(:liegenschaft, :posteingang, :kundennummer, :abrechnungsende, :notizen, :sachbearbeiter,:abrechnungsrelevant,:dokid,:dokumenttyp_id,:sp_id)');
          ParamByName('liegenschaft').AsString    := dict.Items[liegenschaft];
          ParamByName('posteingang').AsString     := dict.Items[Posteingang];
          ParamByName('kundennummer').AsString    := dict.Items[kundennummer];
          ParamByName('abrechnungsende').AsString :=
            dict.Items[abrechnungsende];
          ParamByName('notizen').AsString        := dict.Items[Notizen];
          ParamByName('sachbearbeiter').AsString := dict.Items[sachbearbeiter];
          ParamByName('abrechnungsrelevant').AsString := '1';
          ParamByName('dokid').AsString          := dokid;
          ParamByName('dokumenttyp_id').AsString := type_id;
          ParamByName('sp_id').AsString          := sp_id;
          ExecSQL;
          SQL.Clear;
          SQL.Add('SET foreign_key_checks = 1;');
          ExecSQL;
          SQL.Clear;
          Result := true;
        end;
      except
        on e: exception do begin
          OutputDebugString(PChar(e.message));
          Result := false;
        end;
      end;
    end;
  finally cons.Free;
  end;
end;

function Tformdb.insertquery(doctype: integer; databasex: string;
  values: Tdictionary<string, string>): boolean;
var
  query                 : TStringlist;
  insert                : string;
  inserts               : Tdictionary<string, string>;
  sp_id, doktype, dok_id: integer;
  email_id              : integer;
  ordner_id             : integer;
  ordner                : string;
  typstr                : string;
  helper                : string;
  auftrags_typ          : integer;
  monteur_id            : integer;
  aufttyp               : integer;
begin

  screen.cursor := crhourglass;
  try
    if not Assigned(ZQuery1) then ZQuery1 := TZQuery.Create(self);

    // if ZQuery1.Connection.Connected then ZQuery1.Connection.disconnect;
    if not connect(ZQuery1) then exit;
    inserts := Tdictionary<string, string>.Create();
    with con do begin

      case doctype of
        ZwischenablsgINT:
          // in Zwischenablesung;
          begin

            typstr := zwischenablesung;
            // in Zwischenablesungstabelle einfügen

            inserts.Add(Vertragsbeginn, values.Items[Vertragsbeginn]);
            inserts.Add(Ablesedatum, values.Items[Ablesedatum]);
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            inserts.Add(nutzername, values.Items[nutzername]);
            insert := createCloze('INSERT INTO ', formmain.aufcon.table_zwi_neu, inserts);

          end;
        MontageINT: begin
            typstr := montage;
            // in montage
            inserts.Add(Montagedatum, values.Items[Montagedatum]);
            // inserts.Add(Gueltigkeitsdatum, values.Items[Gueltigkeitsdatum]);
            // inserts.Add(Montagedatum, values.tr);
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            insert := createCloze('INSERT INTO ', table_mon_neu, inserts);
          end;
        ReklamationINT: begin
            typstr := 'reklamation';
            inserts.Add(Montagedatum, values.Items[Montagedatum]);
            // inserts.Add(Gueltigkeitsdatum, values.Items[Gueltigkeitsdatum]);
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            insert := createCloze('INSERT INTO ', table_rekl_neu, inserts);
          end;
        EnergieausweisINT: begin
            typstr := 'energieausweis';
            inserts.Add(pseudoliegenschaft, values.Items[pseudoliegenschaft]);
            // inserts.Add('wiedervorlage', values.Items[);
            inserts.Add(strasse, values.Items[strasse]);
            inserts.Add(plz, values.Items[plz]);
            inserts.Add(ort, values.Items[ort]);
            insert := createCloze('INSERT INTO ', table_en_neu, inserts);
          end;
        KostenINT: begin;
            typstr := 'kostenermittlung';
            insert := createCloze('INSERT INTO ', table_kos_neu, inserts);
          end;

        Nutzerint: begin
            typstr := 'nutzerliste';
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            insert := createCloze('INSERT INTO ', table_nut_neu, inserts);
          end;
        SonstigesInt: begin
            typstr := 'sonstiges';
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            insert := createCloze('INSERT INTO ', table_sonst_neu, inserts);
          end;
        Vertragsint: begin
            typstr       := 'vertrag';
            helper       := values.Items[vertragstyp];
            auftrags_typ :=
              strtoint(open
              ('SELECT vertragstyp_id FROM test.vertragstyp WHERE bezeichnung = '
              + QuotedStr(helper), 'vertragstyp_id'));
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            inserts.Add('vertragtyp_id', inttostr(auftrags_typ));
            insert := createCloze('INSERT INTO ', table_vert_neu, inserts);
          end;
        Angebotsint: begin
            typstr := 'angebotsanfrage';
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            insert := createCloze('INSERT INTO ', table_ang_neu, inserts);
          end;
        Auftragsint: begin
            typstr  := 'auftragsanforderung';
            helper  := values.Items[auftragstyp];
            aufttyp :=
              strtoint(open
              ('SELECT typen_id FROM test.typen WHERE typen_name = ' +
              QuotedStr(helper), 'typen_id'));
            // inserts.Add(Monteur, values.Items[Monteur]);
            // monteur_id :=
            // strtoint(open('SELECT ID FROM verwaltung.ableser WHERE name1 = ' +
            // QuotedStr(helper), 'ID'));
            inserts.Clear;
            inserts.Add(Nutzernummer, values.Items[Nutzernummer]);
            // inserts.Add('monteur_id', inttostr(monteur_id));
            insert := createCloze('INSERT INTO ', table_auf_neu, inserts);
          end;

      end;
      // vordefinierte Abfrage wird ausgeführt
      exec(insert);
      sp_id := getlastid;

      // Dokumenttyp_id einfügen
      inserts.Clear;
      inserts.Add(typ_name, QuotedStr(typstr));
      doktype :=
        strtoint(open('SELECT typen_id FROM test.typen WHERE typen_name=' +
        QuotedStr(typstr), 'typen_id'));

      // Dokument einfügen
      inserts.Clear;
      inserts.Add(Dateiname, values.Items[Dateiname]);
      if values.ContainsKey('Dokumentid') then
          inserts.Add('Dokumentid', values.Items['Dokumentid']);
      insert := createCloze('INSERT INTO ', table_dok, inserts);
      exec(insert);
      dok_id := getlastid;
      // ist es eine Email?
      if values.ContainsKey(Empfängername) then begin
        inserts.Clear;
        inserts.Add(Empfängername, values.Items[Empfängername]);
        inserts.Add(Empfängeradresse, values.Items[Empfängeradresse]);
        inserts.Add(Absendername, values.Items[Absendername]);
        inserts.Add(Absenderadresse, values.Items[Absenderadresse]);
        inserts.Add(betref, values.Items[betref]);

        insert := createCloze('INSERT INTO ', table_email, inserts);
        exec(insert);
        email_id := getlastid;
      end;
      // Posteingang, Ausgang oder Telefonnotiz?
      inserts.Clear;
      case strtoint(values.Items[sammelordner]) of
        0: ordner := 'eingang';
        // open('SELECT typen_id FROM test.typen WHERE typen_name=eingang');
        1: ordner := 'ausgang';
        2: ordner := 'telefonisch';
      else ordner := '';
      end;
      ordner_id :=
        strtoint(open('SELECT typen_id FROM test.typen WHERE typen_name=' +
        QuotedStr(ordner), 'typen_id'));
      // commontab immer gleich...
      inserts.Clear;
      inserts.Add(liegenschaft, values.Items[liegenschaft]);
      inserts.Add(Posteingang, values.Items[Posteingang]);
      inserts.Add(kundennummer, values.Items[kundennummer]);
      inserts.Add('sachbearbeiter_id', values.Items[sachbearbeiter]);
      inserts.Add(abrechnungsende, values.Items[abrechnungsende]);
      inserts.Add(Notizen, values.Items[Notizen]);
      // inserts.add(abrechnungsrelevant, values.items[abrechnungsrelevant]);
      // inserts.add(wiedervorlage, values.items[wiedervorlage]);d
      inserts.Add('sp_id', inttostr(sp_id));
      inserts.Add('dokumenttyp_id', inttostr(doktype));
      inserts.Add('dokument_id', inttostr(dok_id));
      inserts.Add('ordner_id', inttostr(ordner_id));
      try inserts.Add('email_id', inttostr(email_id));
      except
      end;
      insert := createCloze('INSERT INTO ', table_common, inserts);
      exec('SET FOREIGN_KEY_CHECKS=0;');
      exec(insert);
      exec('SET FOREIGN_KEY_CHECKS=1;');
      Result := true;
    end;
  except

      Result := false;
  end;
end;

function Tformdb.open(query, selectme: string): string;
var
  key  : string;
  value: string;
begin
  Result := '';
  // key    := query.Keys.ToArray[0];
  // value  := query.Items[key];
  With ZQuery1 do begin
    SQL.Clear;
    SQL.Add(query);
    OutputDebugString(PChar(SQL.Text));
    try open;
    except
      on e: exception do showmessage(e.message);

    end;

    Result := FieldByName(selectme).AsString;
  end;
end;

function Tformdb.replacequery(table: string;
  values: Tdictionary<string, string>): boolean;
var
  query: TStringlist;
begin
  query := TStringlist.Create;
  query.Add(createCloze('REPLACE INTO', table, values));
  Result := exec(query);
end;

function Tformdb.showquery(query: string): boolean;
var
  help: integer;
begin
  try
    if not connect then exit;
    try
      ZQuery1.SQL.Text := query;
      ZQuery1.open;
      // DBGrid1.DataSource.DataSet.open;
      help := ZQuery1.RecordCount;
      // showmessage(inttostr(help) + ' ergebnisse');
      // DBGrid1.DataSource := ZQuery1.DataSource;
      formdb.Show;
      Result := true;
    except
      OutputDebugString
        ('es kann keine Verbindung zur Datenbank hergestellt werden');
      Result := false;
    end;
  finally
    // ZQuery1.Close;
    // DBGrid1.DataSource.DataSet.Close;
    // disconnect;
  end;
end;

function Tformdb.update(id, table, key, value: string): boolean;
var
  query: string;
begin
  try
    queryupdate.SQL.Clear;
    queryupdate.SQL.Text := 'UPDATE ' + table + ' SET ' + key +
      ' = :value WHERE id = :id';
    queryupdate.ParamByName('value').AsString := value;
    queryupdate.ParamByName('id').AsInteger   := strtoint(id);
    queryupdate.ExecSQL;
    Result := true;
  except
    on e: exception do begin
      OutputDebugString(PChar(e.message));
      Result := false;

    end;
  end;
  // query := 'UPDATE ' + table + ' SET ' + key + ' = ' + QuotedStr(value) +
  // ' WHERE id = ' + id;
  /// /  showmessage(SQL);
  // queryupdate.SQL.Clear;
  // queryupdate.SQL.Text := query;
  // try
  // queryaufträge.ExecSQL;
  // REsult := true;
  // except
  // Result := false;
  // end;
end;

end.
