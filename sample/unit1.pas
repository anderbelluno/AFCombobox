unit Unit1;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  uAFCombobox, ZConnection, ZDataset;

type

  { TForm1 }

  TForm1 = class(TForm)
    AFCombobox1: TAFCombobox;
    Button1: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ZConnection1: TZConnection;
    ZQuery1: TZQuery;
    procedure AFCombobox1CloseUp(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    function DemoDatabasePath: string;
    procedure OpenDemoData;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

function TForm1.DemoDatabasePath: string;
const
  DBFileName = 'demo.sqlite';
var
  Dir: string;
begin
  Dir  := IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'data' + PathDelim;

  Result := Dir + DBFileName;

  if FileExists(Result) then
    Exit
  else
    raise Exception.CreateFmt('DB not fount: %s', [DBFileName]);
end;

procedure TForm1.OpenDemoData;
begin
  if ZQuery1.Active then
    ZQuery1.Close;
  if ZConnection1.Connected then
    ZConnection1.Disconnect;
  ZConnection1.Connect;
  ZQuery1.Open;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ZConnection1.Database := DemoDatabasePath;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  OpenDemoData;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenDemoData;
end;

procedure TForm1.AFCombobox1CloseUp(Sender: TObject);
begin
  Label3.Caption:= AFCombobox1.SelectedTag.ToString;
  Label4.Caption:= AFCombobox1.SelectedTagString;
end;

end.
