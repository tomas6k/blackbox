import '../database.dart';

class UserTeamsTable extends SupabaseTable<UserTeamsRow> {
  @override
  String get tableName => 'user_teams';

  @override
  UserTeamsRow createRow(Map<String, dynamic> data) => UserTeamsRow(data);
}

class UserTeamsRow extends SupabaseDataRow {
  UserTeamsRow(super.data);

  @override
  SupabaseTable get table => UserTeamsTable();

  String? get role => getField<String>('role');
  set role(String? value) => setField<String>('role', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get teamId => getField<String>('team_id')!;
  set teamId(String value) => setField<String>('team_id', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get displayImg => getField<String>('display_img');
  set displayImg(String? value) => setField<String>('display_img', value);

  bool? get eco => getField<bool>('eco');
  set eco(bool? value) => setField<bool>('eco', value);

  bool? get blacktax => getField<bool>('blacktax');
  set blacktax(bool? value) => setField<bool>('blacktax', value);

  double? get agio => getField<double>('agio');
  set agio(double? value) => setField<double>('agio', value);

  bool? get away => getField<bool>('away');
  set away(bool? value) => setField<bool>('away', value);
}
