unit AFComboboxReg;

{$mode objfpc}{$H+}

interface

procedure Register;

implementation

uses
  Classes, TypInfo, PropEdits, uAFCombobox, AFComboboxPropEdits;

const
  AFComponentsPalette = 'AF';

procedure Register;
begin
  RegisterComponents(AFComponentsPalette, [TAFCombobox]);

  RegisterPropertyEditor(TypeInfo(string), TAFCombobox, 'TagField', TAFComboboxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TAFCombobox, 'PrefixField', TAFComboboxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TAFCombobox, 'DisplayField', TAFComboboxFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TAFCombobox, 'TagStringField', TAFComboboxFieldProperty);
end;

end.
