# AFCombobox

A data-aware `TComboBox` for **Lazarus / Free Pascal** that fills its list from any open `TDataSet`, keeps a stable integer key and an optional string payload per item, and can stay in sync with the underlying dataset cursor.

Drop it on a form, point it at a query, map a few fields, and you get readable labels in the list with structured values behind each row — without manual `Items.Add` loops.

---

## Features

- Populate items automatically from an active `TDataSet`
- Map dataset fields to **tag**, **display text**, optional **prefix**, and optional **string tag**
- Built-in **two-way sync** with the dataset current record (`SyncDataSet`)
- Readable list entries with a configurable prefix separator (default: ` | `)
- Design-time field pickers in the Object Inspector for all field properties
- Inherits the full `TComboBox` API, layout properties, and events
- Cross-platform (Windows, Linux, macOS) via LCL

---

## Requirements

- [Lazarus](https://www.lazarus-ide.org/) with FPC
- LCL and FCL (included with Lazarus)

The included **sample project** also uses:

- [ZeosLib](https://sourceforge.net/projects/zeoslib/) (`zcomponent`) for SQLite access

---

## Installation

1. Open `src/afcombobox.lpk` in the Lazarus Package Manager.
2. Click **Compile**.
3. Click **Use → Install**.
4. Restart the IDE if prompted.

The component appears on the component palette under **AF** as `TAFCombobox`.

---

## Properties

### Data binding

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `DataSet` | `TDataSet` | — | Source dataset. Must be **active** before items are loaded. |
| `TagField` | `string` | `''` | **Required.** Integer field used as the item key (`SelectedTag`, `ItemTag`). |
| `DisplayField` | `string` | `''` | **Required.** Field shown as the main label text. |
| `PrefixField` | `string` | `''` | Optional field prepended to the display text (e.g. employee code). |
| `TagStringField` | `string` | `''` | Optional string field exposed as `SelectedTagString` / `ItemTagString`. |
| `PrefixSeparator` | `string` | `' \| '` | Text between prefix and display. If empty, a single space is used. |
| `SyncDataSet` | `Boolean` | `False` | When `True`, changing the combo selection moves the dataset cursor, and dataset navigation updates the selected item. |

### Runtime API

| Member | Description |
|--------|-------------|
| `RefreshItems` | Clears and reloads all items from `DataSet`. Call after reopening a query or changing filters. |
| `SelectedTag` | Integer value of the currently selected item (`TagField`). |
| `SelectedTagString` | String value of the currently selected item (`TagStringField`). |
| `ItemTag(Index)` | Integer tag for item at `Index`. |
| `ItemTagString(Index)` | String tag for item at `Index`. |

All standard `TComboBox` properties (`Style`, `Items`, `ItemIndex`, `OnChange`, layout, etc.) remain available.

---

## How items are built

For each record in the dataset:

```
[PrefixField] + PrefixSeparator + [DisplayField]   →  visible list text
[TagField]                                         →  stored integer tag
[TagStringField]                                   →  stored string tag (if mapped)
```

**Examples**

| Prefix | Separator | Display | Result |
|--------|-----------|---------|--------|
| `E002` | ` \| ` | `Bob Smith` | `E002 \| Bob Smith` |
| `IT` | *(empty)* | `Engineering` | `IT Engineering` |
| — | — | `Alice Johnson` | `Alice Johnson` |

Only `TagField` and `DisplayField` are mandatory. Optional fields are ignored when the property is empty or the field does not exist in the dataset.

---

## SyncDataSet

With `SyncDataSet = True`:

- **Combo → dataset:** when the user picks an item, the component calls `DataSet.Locate(TagField, SelectedTag, [])`.
- **Dataset → combo:** when the current record changes, the matching item is selected automatically.

With `SyncDataSet = False`, the combo acts as a standalone picker: items are loaded from the dataset, but navigation does not move the cursor.

`RefreshItems` reloads the list from scratch. With sync enabled it positions the dataset on the first item after refresh; otherwise it tries to restore the previous bookmark.

---

## Basic usage

```pascal
// 1. Open your dataset
QueryEmployees.Open;

// 2. Configure the combo (Object Inspector or code)
AFCombobox1.DataSet         := QueryEmployees;
AFCombobox1.TagField        := 'id';
AFCombobox1.PrefixField     := 'emp_no';
AFCombobox1.DisplayField    := 'full_name';
AFCombobox1.TagStringField  := 'email';
AFCombobox1.SyncDataSet     := True;

// 3. Reload when data changes
AFCombobox1.RefreshItems;

// 4. Read the selected values
ShowMessage(IntToStr(AFCombobox1.SelectedTag) + ' — ' + AFCombobox1.SelectedTagString);
```

**Tips**

- Use `Style = csDropDownList` for a read-only picker (recommended).
- The dataset must be open before `RefreshItems` runs; the component also refreshes automatically when the linked dataset becomes active at runtime.
- At design time the list is not populated — run the application to see data.

---

## Sample project

The `sample/` folder contains a ready-to-run demo:

```
sample/
├── project1.lpi          # Lazarus project
├── unit1.pas / unit1.lfm # Demo form
└── data/
    ├── demo.sqlite       # SQLite database (employees & departments)
    └── schema.sql        # SQL script to recreate the database
```

### What the demo shows

- `TAFCombobox` bound to a Zeos `TZQuery` over SQLite
- `SyncDataSet` keeping the combo and `TDBGrid` in sync
- Live display of `SelectedTag` and `SelectedTagString` after each selection
- A **Reload** button that reconnects and reopens the query

### Sample field mapping

| Component property | Dataset field |
|--------------------|---------------|
| `TagField` | `id` |
| `PrefixField` | `emp_no` |
| `DisplayField` | `full_name` |
| `TagStringField` | `email` |

### Running the sample

1. Install the **afcombobox** package (see above).
2. Install **ZeosLib** and compile `zcomponent`.
3. Open `sample/project1.lpi` and build (F9).
4. Ensure `sample/data/demo.sqlite` is reachable from the executable output folder.

The sample resolves the database path as `data/demo.sqlite` relative to the executable directory. When Lazarus builds into `sample/lib/<cpu>-<os>/`, copy the `data` folder there or adjust `DemoDatabasePath` in `unit1.pas`.

### Recreate the database

```bash
sqlite3 sample/data/demo.sqlite < sample/data/schema.sql
```

### Test data

The SQLite database uses a small classic schema:

- **`departments`** — `id`, `dept_code`, `name`
- **`employees`** — `id`, `emp_no`, `first_name`, `last_name`, `email`, `department_id`, `job_title`, `hired_date`, `active`

Ten active and two inactive employees are included. The sample query lists only active employees ordered by `emp_no`.

---

## Project layout

```
AFCombobox/
├── src/
│   ├── afcombobox.lpk          # Lazarus package
│   ├── uAFCombobox.pas         # Component implementation
│   ├── AFComboboxReg.pas       # Palette registration
│   └── AFComboboxPropEdits.pas # Object Inspector field editors
├── sample/                     # Demo application + SQLite data
└── README.md
```

---

## 💬 Telegram

Join our community on Telegram: [https://t.me/badgerbrasil](https://t.me/badgerbrasil)

---

## License

MIT License — Copyright (c) 2026 Anderson Fiori. See [LICENSE](LICENSE).
