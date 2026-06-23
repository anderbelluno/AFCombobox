unit AFComboboxPropEdits;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, PropEdits, uAFCombobox;

type
  TAFComboboxFieldProperty = class(TStringPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

implementation

procedure ListDataSetFields(ADataSet: TDataSet; AList: TStrings);
var
  I: Integer;
begin
  AList.Clear;
  if not Assigned(ADataSet) then
    Exit;

  if ADataSet.Fields.Count > 0 then
  begin
    ADataSet.GetFieldNames(AList);
    Exit;
  end;

  try
    ADataSet.FieldDefs.Update;
  except
    if ADataSet.FieldDefs.Count = 0 then
      Exit;
  end;

  for I := 0 to ADataSet.FieldDefs.Count - 1 do
    AList.Add(ADataSet.FieldDefs[I].Name);
end;

function TAFComboboxFieldProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;

procedure TAFComboboxFieldProperty.GetValues(Proc: TGetStrProc);
var
  Combo: TAFCombobox;
  List: TStringList;
  I: Integer;
begin
  Combo := TAFCombobox(GetComponent(0));
  List := TStringList.Create;
  try
    ListDataSetFields(Combo.DataSet, List);
    for I := 0 to List.Count - 1 do
      Proc(List[I]);
  finally
    List.Free;
  end;
end;

end.
