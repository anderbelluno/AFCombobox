{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit afcombobox;

{$warn 5023 off : no warning about unused units}
interface

uses
  uAFCombobox, AFComboboxReg, AFComboboxPropEdits, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('AFComboboxReg', @AFComboboxReg.Register);
end;

initialization
  RegisterPackage('afcombobox', @Register);
end.
