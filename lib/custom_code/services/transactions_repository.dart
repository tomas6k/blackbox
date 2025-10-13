import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRepository {
  const TransactionsRepository();

  Future<List<TransactionsRow>> fetchForPeriod({
    required String saisonId,
    required int month,
    required int year,
    String? transactionToId,
    double statut = 1.0,
  }) async {
    final startDate = functions.getBoundaryDate(month, year, 'first');
    final endDate = functions.getBoundaryDate(month, year, 'end');

    return TransactionsTable().queryRows(
      queryFn: (q) {
        var query = q
            .eq('saison_id', saisonId)
            .eq('statut', statut)
            .gte(
              'transaction_date',
              supaSerialize<DateTime>(startDate),
            )
            .lte(
              'transaction_date',
              supaSerialize<DateTime>(endDate),
            );

        if (transactionToId != null && transactionToId.isNotEmpty) {
          query = query.eq('transaction_to', transactionToId);
        }

        return query.order('transaction_date');
      },
    );
  }
}
