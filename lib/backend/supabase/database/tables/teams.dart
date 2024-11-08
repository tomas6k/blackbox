import '../database.dart';

class TeamsTable extends SupabaseTable<TeamsRow> {
  @override
  String get tableName => 'teams';

  @override
  TeamsRow createRow(Map<String, dynamic> data) => TeamsRow(data);
}

class TeamsRow extends SupabaseDataRow {
  TeamsRow(super.data);

  @override
  SupabaseTable get table => TeamsTable();

  DateTime get createdTime => getField<DateTime>('created_time')!;
  set createdTime(DateTime value) => setField<DateTime>('created_time', value);

  String get teamCode => getField<String>('team_code')!;
  set teamCode(String value) => setField<String>('team_code', value);

  String? get sport => getField<String>('sport');
  set sport(String? value) => setField<String>('sport', value);

  String? get teamImg => getField<String>('team_img');
  set teamImg(String? value) => setField<String>('team_img', value);

  String get teamName => getField<String>('team_name')!;
  set teamName(String value) => setField<String>('team_name', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get currentSaison => getField<String>('current_saison');
  set currentSaison(String? value) => setField<String>('current_saison', value);

  String? get teamOwner => getField<String>('team_owner');
  set teamOwner(String? value) => setField<String>('team_owner', value);
}
