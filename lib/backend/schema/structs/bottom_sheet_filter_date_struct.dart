// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class BottomSheetFilterDateStruct extends BaseStruct {
  BottomSheetFilterDateStruct({
    int? year,
    int? month,
  })  : _year = year,
        _month = month;

  // "year" field.
  int? _year;
  int get year => _year ?? 0;
  set year(int? val) => _year = val;

  void incrementYear(int amount) => year = year + amount;

  bool hasYear() => _year != null;

  // "month" field.
  int? _month;
  int get month => _month ?? 0;
  set month(int? val) => _month = val;

  void incrementMonth(int amount) => month = month + amount;

  bool hasMonth() => _month != null;

  static BottomSheetFilterDateStruct fromMap(Map<String, dynamic> data) =>
      BottomSheetFilterDateStruct(
        year: castToType<int>(data['year']),
        month: castToType<int>(data['month']),
      );

  static BottomSheetFilterDateStruct? maybeFromMap(dynamic data) => data is Map
      ? BottomSheetFilterDateStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'year': _year,
        'month': _month,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'year': serializeParam(
          _year,
          ParamType.int,
        ),
        'month': serializeParam(
          _month,
          ParamType.int,
        ),
      }.withoutNulls;

  static BottomSheetFilterDateStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      BottomSheetFilterDateStruct(
        year: deserializeParam(
          data['year'],
          ParamType.int,
          false,
        ),
        month: deserializeParam(
          data['month'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'BottomSheetFilterDateStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is BottomSheetFilterDateStruct &&
        year == other.year &&
        month == other.month;
  }

  @override
  int get hashCode => const ListEquality().hash([year, month]);
}

BottomSheetFilterDateStruct createBottomSheetFilterDateStruct({
  int? year,
  int? month,
}) =>
    BottomSheetFilterDateStruct(
      year: year,
      month: month,
    );
