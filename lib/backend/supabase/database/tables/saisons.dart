import '../database.dart';

class SaisonsTable extends SupabaseTable<SaisonsRow> {
  @override
  String get tableName => 'saisons';

  @override
  SaisonsRow createRow(Map<String, dynamic> data) => SaisonsRow(data);
}

class SaisonsRow extends SupabaseDataRow {
  SaisonsRow(super.data);

  @override
  SupabaseTable get table => SaisonsTable();

  DateTime get createdTime => getField<DateTime>('created_time')!;
  set createdTime(DateTime value) => setField<DateTime>('created_time', value);

  String get saisonName => getField<String>('saison_name')!;
  set saisonName(String value) => setField<String>('saison_name', value);

  String? get goal => getField<String>('goal');
  set goal(String? value) => setField<String>('goal', value);

  bool? get active => getField<bool>('active');
  set active(bool? value) => setField<bool>('active', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get teamId => getField<String>('team_id');
  set teamId(String? value) => setField<String>('team_id', value);

  double get blacktax => getField<double>('blacktax')!;
  set blacktax(double value) => setField<double>('blacktax', value);

  double get eco => getField<double>('eco')!;
  set eco(double value) => setField<double>('eco', value);

  bool get agio => getField<bool>('agio')!;
  set agio(bool value) => setField<bool>('agio', value);

  double get agioStep1 => getField<double>('agio_step1')!;
  set agioStep1(double value) => setField<double>('agio_step1', value);

  double get agioStep2 => getField<double>('agio_step2')!;
  set agioStep2(double value) => setField<double>('agio_step2', value);

  double get agioStep3 => getField<double>('agio_step3')!;
  set agioStep3(double value) => setField<double>('agio_step3', value);

  bool get away => getField<bool>('away')!;
  set away(bool value) => setField<bool>('away', value);

  bool get fees => getField<bool>('fees')!;
  set fees(bool value) => setField<bool>('fees', value);

  bool? get opening => getField<bool>('opening');
  set opening(bool? value) => setField<bool>('opening', value);
}
