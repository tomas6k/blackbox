import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';
import 'transactions_repository.dart';

/// Encapsulates the shared month/year filtering logic used by transaction lists.
class TransactionsFeedController {
  TransactionsFeedController({TransactionsRepository? repository})
      : _repository = repository ?? const TransactionsRepository();

  final TransactionsRepository _repository;

  int? _month;
  int? _year;
  UserTeamsRow? _selectedPlayer;
  List<TransactionsRow> _transactions = [];

  int? get month => _month;
  set month(int? value) => _month = value;

  int? get year => _year;
  set year(int? value) => _year = value;

  UserTeamsRow? get selectedPlayer => _selectedPlayer;
  set selectedPlayer(UserTeamsRow? value) => _selectedPlayer = value;

  List<TransactionsRow> get transactions => _transactions;
  set transactions(List<TransactionsRow> value) => _transactions = List.of(value);

  /// Fetches transactions for the requested period, updating the local cache.
  Future<void> refresh({
    required String saisonId,
    int? monthOverride,
    int? yearOverride,
    UserTeamsRow? player,
    bool overridePlayer = false,
    String? transactionToId,
  }) async {
    final currentMonth =
        _month ?? functions.extractDateDetails(getCurrentTimestamp, 'month');
    final currentYear =
        _year ?? functions.extractDateDetails(getCurrentTimestamp, 'year');

    final resolvedMonth = monthOverride ?? currentMonth;
    final resolvedYear = yearOverride ?? currentYear;
    final resolvedPlayer =
        overridePlayer ? player : (player ?? _selectedPlayer);

    final resolvedTransactionToId = transactionToId ?? resolvedPlayer?.id;

    final result = await _repository.fetchForPeriod(
      saisonId: saisonId,
      month: resolvedMonth,
      year: resolvedYear,
      transactionToId: resolvedTransactionToId,
    );

    _month = resolvedMonth;
    _year = resolvedYear;
    _selectedPlayer = resolvedPlayer;
    _transactions = List.of(result);
  }
}
