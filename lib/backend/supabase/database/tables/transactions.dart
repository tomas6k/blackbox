import '../database.dart';

class TransactionsTable extends SupabaseTable<TransactionsRow> {
  @override
  String get tableName => 'transactions';

  @override
  TransactionsRow createRow(Map<String, dynamic> data) => TransactionsRow(data);
}

class TransactionsRow extends SupabaseDataRow {
  TransactionsRow(super.data);

  @override
  SupabaseTable get table => TransactionsTable();

  DateTime get transactionDate => getField<DateTime>('transaction_date')!;
  set transactionDate(DateTime value) =>
      setField<DateTime>('transaction_date', value);

  double get transactionValue => getField<double>('transaction_value')!;
  set transactionValue(double value) =>
      setField<double>('transaction_value', value);

  String? get note => getField<String>('note');
  set note(String? value) => setField<String>('note', value);

  DateTime get createdTime => getField<DateTime>('created_time')!;
  set createdTime(DateTime value) => setField<DateTime>('created_time', value);

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  String? get transactionTo => getField<String>('transaction_to');
  set transactionTo(String? value) => setField<String>('transaction_to', value);

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  String get penalitieId => getField<String>('penalitie_id')!;
  set penalitieId(String value) => setField<String>('penalitie_id', value);

  String get saisonId => getField<String>('saison_id')!;
  set saisonId(String value) => setField<String>('saison_id', value);

  double? get statut => getField<double>('statut');
  set statut(double? value) => setField<double>('statut', value);

  bool? get blackweek => getField<bool>('blackweek');
  set blackweek(bool? value) => setField<bool>('blackweek', value);

  bool? get gameday => getField<bool>('gameday');
  set gameday(bool? value) => setField<bool>('gameday', value);

  bool? get blackpowered => getField<bool>('blackpowered');
  set blackpowered(bool? value) => setField<bool>('blackpowered', value);

  bool? get steal => getField<bool>('steal');
  set steal(bool? value) => setField<bool>('steal', value);

  bool? get contest => getField<bool>('contest');
  set contest(bool? value) => setField<bool>('contest', value);

  String? get transactionToName => getField<String>('transaction_to_name');
  set transactionToName(String? value) =>
      setField<String>('transaction_to_name', value);

  String? get transactionName => getField<String>('transaction_name');
  set transactionName(String? value) =>
      setField<String>('transaction_name', value);

  String? get transactionImg => getField<String>('transaction_img');
  set transactionImg(String? value) =>
      setField<String>('transaction_img', value);

  DateTime? get date => getField<DateTime>('date');
  set date(DateTime? value) => setField<DateTime>('date', value);

  double? get transactionAmount => getField<double>('transaction_amount');
  set transactionAmount(double? value) =>
      setField<double>('transaction_amount', value);

  String? get createdByName => getField<String>('created_by_name');
  set createdByName(String? value) =>
      setField<String>('created_by_name', value);
}
