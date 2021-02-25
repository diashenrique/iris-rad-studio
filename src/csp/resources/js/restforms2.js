

  // Field types
  // adapted from: https://github.com/intersystems-community/restforms-angular/blob/develop/src/app/services/data.service.ts
  var FieldType = {
    // Implemented
    "String": '%Library.String',
    "VarString": '%Library.VarString',
    "Date": '%Library.Date',
    "Numeric": '%Library.Numeric',
    "Integer": '%Library.Integer',
    "TimeStamp": '%Library.TimeStamp',
    "Time": 'time',
    "Boolean": '%Library.Boolean',
    "Serial": 'serial',
    "Form": 'form',
    "List": 'list',
    "Array": 'array'
  }

  // adapted from: https://github.com/intersystems-community/restforms-angular/blob/develop/src/app/services/data.service.ts
  var getSimpleType = function (type) {
    switch (type) {
      case '%Library.Char':
        return FieldType.String;
      case '%Library.DateTime':
        return FieldType.TimeStamp;
      case '%Library.BigInt':
      case '%Library.SmallInt':
      case '%Library.TinyInt':
        return FieldType.Integer;
      case '%Library.Decimal':
      case '%Library.Double':
      case '%Library.Float':
      case '%Library.Currency':
        return FieldType.Numeric;
      case '%Library.Time':
      case '%Library.PosixTime':
        return FieldType.Time;
    }
    return type;
  }

  // adapted from: https://github.com/intersystems-community/restforms-angular/blob/develop/src/app/services/data.service.ts
  var getPropType = function (prop) {
    switch (prop.collection) {
      case 'array': {
        return prop.jsonreference === 'ID' ? FieldType.List : FieldType.Array;
      }
      case 'list':
        return FieldType.List;
    }

    if (prop.category.toLowerCase() === 'datatype') {
      return getSimpleType(prop.type);
    }

    if (prop.category === 'form') {
      return FieldType.Form;
    }

    if (prop.category === 'serial') {
      return FieldType.Serial;
    }

    return FieldType.String;
  }

  var getDevExtremeFieldType = function (rf2Field) {
    const fieldType = getPropType(rf2Field);
    switch (fieldType) {
      case FieldType.Integer:
      case FieldType.Numeric:
        return "number";
      case FieldType.Date:
        return "date";
      case FieldType.Time:
      case FieldType.TimeStamp:
        return "datetime";
      case FieldType.Boolean:
        return "boolean";
      case FieldType.Form:
        return "number";
      default:
        return "string";
    }
  }