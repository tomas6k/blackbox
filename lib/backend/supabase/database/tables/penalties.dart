import '../database.dart';

class PenaltiesTable extends SupabaseTable<PenaltiesRow> {
  @override
  String get tableName => 'penalties';

  @override
  PenaltiesRow createRow(Map<String, dynamic> data) => PenaltiesRow(data);
}

class PenaltiesRow extends SupabaseDataRow {
  PenaltiesRow(super.data);

  @override
  SupabaseTable get table => PenaltiesTable();

  String get penalitieName => getField<String>('penalitie_name')!;
  set penalitieName(String value) => setField<String>('penalitie_name', value);

  double get penalitieValue => getField<double>('penalitie_value')!;
  set penalitieValue(double value) =>
      setField<double>('penalitie_value', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get saisonId => getField<String>('saison_id');
  set saisonId(String? value) => setField<String>('saison_id', value);

  String? get penalitieImg => getField<String>('penalitie_img');
  set penalitieImg(String? value) => setField<String>('penalitie_img', value);

  DateTime? get createdTime => getField<DateTime>('created_time');
  set createdTime(DateTime? value) => setField<DateTime>('created_time', value);

  String get penalitieCustom => getField<String>('penalitie_custom')!;
  set penalitieCustom(String value) =>
      setField<String>('penalitie_custom', value);
}
