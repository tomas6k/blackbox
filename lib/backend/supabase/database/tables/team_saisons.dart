import '../database.dart';

class TeamSaisonsTable extends SupabaseTable<TeamSaisonsRow> {
  @override
  String get tableName => 'team_saisons';

  @override
  TeamSaisonsRow createRow(Map<String, dynamic> data) => TeamSaisonsRow(data);
}

class TeamSaisonsRow extends SupabaseDataRow {
  TeamSaisonsRow(super.data);

  @override
  SupabaseTable get table => TeamSaisonsTable();

  String get teamId => getField<String>('team_id')!;
  set teamId(String value) => setField<String>('team_id', value);

  String get saisonId => getField<String>('saison_id')!;
  set saisonId(String value) => setField<String>('saison_id', value);
}
