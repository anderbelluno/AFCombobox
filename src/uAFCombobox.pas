unit uAFCombobox;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DB, StdCtrls;

type
  TAFCombobox = class;

  TAFComboboxItemData = class(TObject)
  public
    Tag: Integer;
    TagString: string;
  end;

  TAFComboboxDataLink = class(TDataLink)
  private
    FCombo: TAFCombobox;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(ACombo: TAFCombobox);
  end;

  TAFCombobox = class(TComboBox)
  private
    FDataLink: TAFComboboxDataLink;
    FInternalDataSource: TDataSource;
    FDataSet: TDataSet;
    FTagField: string;
    FPrefixField: string;
    FDisplayField: string;
    FTagStringField: string;
    FPrefixSeparator: string;
    FSyncDataSet: Boolean;
    FRefreshing: Boolean;
    FSyncing: Boolean;
    procedure SetDataSet(const AValue: TDataSet);
    procedure SetTagField(const AValue: string);
    procedure SetPrefixField(const AValue: string);
    procedure SetDisplayField(const AValue: string);
    procedure SetTagStringField(const AValue: string);
    procedure SetPrefixSeparator(const AValue: string);
    procedure SetSyncDataSet(const AValue: Boolean);
    function GetItemData(AIndex: Integer): TAFComboboxItemData;
    function GetSelectedTag: Integer;
    function GetSelectedTagString: string;
    procedure ClearItemData;
    function BuildDisplayText(APrefix, ADisplay: TField): string;
    function IsRefreshingItems: Boolean;
    function IsDesignTime: Boolean;
    procedure SyncSelectionFromDataSet;
    procedure SyncDataSetFromSelection;
    procedure RestoreDataSetPosition(const ASavedBookmark: TBookmark;
      ASavedBookmarkValid: Boolean);
  protected
    procedure Change; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RefreshItems;
    function ItemTag(AIndex: Integer): Integer;
    function ItemTagString(AIndex: Integer): string;
    property SelectedTag: Integer read GetSelectedTag;
    property SelectedTagString: string read GetSelectedTagString;
  published
    property Align;
    property Anchors;
    property ArrowKeysTraverseList;
    property AutoComplete;
    property AutoCompleteText;
    property AutoDropDown;
    property AutoSelect;
    property AutoSize;
    property BiDiMode;
    property BorderSpacing;
    property BorderStyle;
    property CharCase;
    property Color;
    property Constraints;
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property ItemHeight;
    property ItemIndex;
    property Items;
    property ItemWidth;
    property Left;
    property MaxLength;
    property ParentBiDiMode;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property Sorted;
    property Style;
    property TabOrder;
    property TabStop;
    property Text;
    property TextHint;
    property Top;
    property Visible;
    property Width;
    property Height;
    property OnChange;
    property OnChangeBounds;
    property OnClick;
    property OnCloseUp;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEndDrag;
    property OnDropDown;
    property OnEditingDone;
    property OnEnter;
    property OnExit;
    property OnGetItems;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMeasureItem;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnSelect;
    property OnStartDrag;
    property OnUTF8KeyPress;
    property DataSet: TDataSet read FDataSet write SetDataSet;
    property SyncDataSet: Boolean read FSyncDataSet write SetSyncDataSet default False;
    property TagField: string read FTagField write SetTagField;
    property PrefixField: string read FPrefixField write SetPrefixField;
    property DisplayField: string read FDisplayField write SetDisplayField;
    property TagStringField: string read FTagStringField write SetTagStringField;
    property PrefixSeparator: string read FPrefixSeparator write SetPrefixSeparator;
  end;

implementation

{ TAFComboboxDataLink }

constructor TAFComboboxDataLink.Create(ACombo: TAFCombobox);
begin
  inherited Create;
  FCombo := ACombo;
end;

procedure TAFComboboxDataLink.ActiveChanged;
begin
  inherited ActiveChanged;
  if FCombo.IsRefreshingItems then
    Exit;
  if csDesigning in FCombo.ComponentState then
    Exit;
  if csLoading in FCombo.ComponentState then
    Exit;
  if Assigned(DataSet) and DataSet.Active then
    FCombo.RefreshItems
  else
    FCombo.ClearItemData;
end;

procedure TAFComboboxDataLink.DataSetChanged;
begin
  inherited DataSetChanged;
end;

procedure TAFComboboxDataLink.RecordChanged(Field: TField);
begin
  inherited RecordChanged(Field);
  if FCombo.IsRefreshingItems then
    Exit;
  if csDesigning in FCombo.ComponentState then
    Exit;
  FCombo.SyncSelectionFromDataSet;
end;

{ TAFCombobox }

constructor TAFCombobox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FInternalDataSource := TDataSource.Create(Self);
  FDataLink := TAFComboboxDataLink.Create(Self);
  FTagField := '';
  FPrefixField := '';
  FDisplayField := '';
  FTagStringField := '';
  FPrefixSeparator := ' | ';
  Style := csDropDownList;
end;

destructor TAFCombobox.Destroy;
begin
  ClearItemData;
  FDataLink.Free;
  inherited Destroy;
end;

procedure TAFCombobox.Loaded;
begin
  inherited Loaded;
  if csDesigning in ComponentState then
    Exit;
  if Assigned(FDataSet) and FDataSet.Active then
    RefreshItems;
end;

function TAFCombobox.IsRefreshingItems: Boolean;
begin
  Result := FRefreshing;
end;

function TAFCombobox.IsDesignTime: Boolean;
begin
  Result := csDesigning in ComponentState;
end;

procedure TAFCombobox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSet) then
    DataSet := nil;
end;

procedure TAFCombobox.ClearItemData;
var
  I: Integer;
begin
  for I := 0 to Items.Count - 1 do
    Items.Objects[I].Free;
  Items.Clear;
  ItemIndex := -1;
end;

procedure TAFCombobox.SetDataSet(const AValue: TDataSet);
begin
  if FDataSet = AValue then
    Exit;

  if Assigned(FDataSet) then
    FDataSet.RemoveFreeNotification(Self);

  FDataSet := AValue;
  FInternalDataSource.DataSet := AValue;
  FDataLink.DataSource := FInternalDataSource;

  if Assigned(FDataSet) then
    FDataSet.FreeNotification(Self);

  if not (Assigned(FDataSet) and FDataSet.Active) then
    ClearItemData;
end;

procedure TAFCombobox.SetTagField(const AValue: string);
begin
  if SameText(FTagField, AValue) then
    Exit;
  FTagField := AValue;
  if not IsDesignTime then
    RefreshItems;
end;

procedure TAFCombobox.SetPrefixField(const AValue: string);
begin
  if SameText(FPrefixField, AValue) then
    Exit;
  FPrefixField := AValue;
  if not IsDesignTime then
    RefreshItems;
end;

procedure TAFCombobox.SetDisplayField(const AValue: string);
begin
  if SameText(FDisplayField, AValue) then
    Exit;
  FDisplayField := AValue;
  if not IsDesignTime then
    RefreshItems;
end;

procedure TAFCombobox.SetTagStringField(const AValue: string);
begin
  if SameText(FTagStringField, AValue) then
    Exit;
  FTagStringField := AValue;
  if not IsDesignTime then
    RefreshItems;
end;

procedure TAFCombobox.SetPrefixSeparator(const AValue: string);
begin
  if FPrefixSeparator = AValue then
    Exit;
  FPrefixSeparator := AValue;
  if not IsDesignTime then
    RefreshItems;
end;

procedure TAFCombobox.SetSyncDataSet(const AValue: Boolean);
begin
  if FSyncDataSet = AValue then
    Exit;
  FSyncDataSet := AValue;
  if FSyncDataSet and not IsDesignTime then
    SyncSelectionFromDataSet;
end;

procedure TAFCombobox.Change;
begin
  inherited Change;
  if FSyncing then
    Exit;
  SyncDataSetFromSelection;
end;

procedure TAFCombobox.SyncSelectionFromDataSet;
var
  I, TagValue: Integer;
  FldTag: TField;
begin
  if not FSyncDataSet then
    Exit;
  if FSyncing or FRefreshing then
    Exit;
  if IsDesignTime then
    Exit;
  if not Assigned(FDataSet) or not FDataSet.Active then
    Exit;
  if FTagField = '' then
    Exit;

  FldTag := FDataSet.FindField(FTagField);
  if not Assigned(FldTag) then
    Exit;

  TagValue := FldTag.AsInteger;
  for I := 0 to Items.Count - 1 do
  begin
    if ItemTag(I) = TagValue then
    begin
      if ItemIndex <> I then
      begin
        FSyncing := True;
        try
          ItemIndex := I;
        finally
          FSyncing := False;
        end;
      end;
      Exit;
    end;
  end;
end;

procedure TAFCombobox.SyncDataSetFromSelection;
begin
  if not FSyncDataSet then
    Exit;
  if FSyncing or FRefreshing then
    Exit;
  if IsDesignTime then
    Exit;
  if not Assigned(FDataSet) or not FDataSet.Active then
    Exit;
  if (ItemIndex < 0) or (FTagField = '') then
    Exit;

  FSyncing := True;
  try
    FDataSet.Locate(FTagField, SelectedTag, []);
  finally
    FSyncing := False;
  end;
end;

procedure TAFCombobox.RestoreDataSetPosition(const ASavedBookmark: TBookmark;
  ASavedBookmarkValid: Boolean);
begin
  if not Assigned(FDataSet) or not FDataSet.Active then
    Exit;
  if ASavedBookmarkValid and FDataSet.BookmarkValid(ASavedBookmark) then
    FDataSet.GotoBookmark(ASavedBookmark);
  if ASavedBookmarkValid then
    FDataSet.FreeBookmark(ASavedBookmark);
end;

function TAFCombobox.GetItemData(AIndex: Integer): TAFComboboxItemData;
begin
  if (AIndex < 0) or (AIndex >= Items.Count) then
    Exit(nil);
  Result := TAFComboboxItemData(Items.Objects[AIndex]);
end;

function TAFCombobox.ItemTag(AIndex: Integer): Integer;
var
  ItemData: TAFComboboxItemData;
begin
  ItemData := GetItemData(AIndex);
  if Assigned(ItemData) then
    Result := ItemData.Tag
  else
    Result := 0;
end;

function TAFCombobox.ItemTagString(AIndex: Integer): string;
var
  ItemData: TAFComboboxItemData;
begin
  ItemData := GetItemData(AIndex);
  if Assigned(ItemData) then
    Result := ItemData.TagString
  else
    Result := '';
end;

function TAFCombobox.GetSelectedTag: Integer;
begin
  Result := ItemTag(ItemIndex);
end;

function TAFCombobox.GetSelectedTagString: string;
begin
  Result := ItemTagString(ItemIndex);
end;

function TAFCombobox.BuildDisplayText(APrefix, ADisplay: TField): string;
begin
  if Assigned(APrefix) and Assigned(ADisplay) then
  begin
    if FPrefixSeparator <> '' then
      Result := APrefix.AsString + FPrefixSeparator + ADisplay.AsString
    else
      Result := APrefix.AsString + ' ' + ADisplay.AsString;
  end
  else if Assigned(ADisplay) then
    Result := ADisplay.AsString
  else
    Result := '';
end;

procedure TAFCombobox.RefreshItems;
var
  ItemData: TAFComboboxItemData;
  DisplayText: string;
  FldTag, FldPrefix, FldDisplay, FldTagString: TField;
  SavedDataSource: TDataSource;
  SavedBookmark: TBookmark;
  SavedBookmarkValid: Boolean;
begin
  if FRefreshing then
    Exit;

  if IsDesignTime then
    Exit;

  if not Assigned(FDataSet) or not FDataSet.Active then
  begin
    ClearItemData;
    Exit;
  end;

  FldTag := nil;
  FldPrefix := nil;
  FldDisplay := nil;
  FldTagString := nil;

  if FTagField <> '' then
    FldTag := FDataSet.FindField(FTagField);
  if FPrefixField <> '' then
    FldPrefix := FDataSet.FindField(FPrefixField);
  if FDisplayField <> '' then
    FldDisplay := FDataSet.FindField(FDisplayField);
  if FTagStringField <> '' then
    FldTagString := FDataSet.FindField(FTagStringField);

  if not Assigned(FldTag) or not Assigned(FldDisplay) then
  begin
    ClearItemData;
    Exit;
  end;

  SavedBookmark := FDataSet.GetBookmark;
  SavedBookmarkValid := FDataSet.BookmarkValid(SavedBookmark);
  if not SavedBookmarkValid then
  begin
    FDataSet.FreeBookmark(SavedBookmark);
    SavedBookmark := nil;
  end;

  SavedDataSource := FDataLink.DataSource;
  FDataLink.DataSource := nil;
  FRefreshing := True;
  ClearItemData;
  Items.BeginUpdate;
  try
    FDataSet.DisableControls;
    try
      FDataSet.First;
      while not FDataSet.Eof do
      begin
        ItemData := TAFComboboxItemData.Create;
        ItemData.Tag := FldTag.AsInteger;
        if Assigned(FldTagString) then
          ItemData.TagString := FldTagString.AsString;

        DisplayText := BuildDisplayText(FldPrefix, FldDisplay);
        Items.AddObject(DisplayText, ItemData);
        FDataSet.Next;
      end;
    finally
      FDataSet.EnableControls;
    end;
  finally
    Items.EndUpdate;
    FDataLink.DataSource := SavedDataSource;
    FRefreshing := False;
  end;

  if Items.Count > 0 then
  begin
    FSyncing := True;
    try
      ItemIndex := 0;
    finally
      FSyncing := False;
    end;
  end;

  if FSyncDataSet then
    SyncDataSetFromSelection
  else
    RestoreDataSetPosition(SavedBookmark, SavedBookmarkValid);
end;

end.
