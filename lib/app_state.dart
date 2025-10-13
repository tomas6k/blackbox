import 'package:flutter/material.dart';
import 'flutter_flow/request_manager.dart';
import '/backend/api_requests/api_manager.dart';
import 'backend/supabase/supabase.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = const FlutterSecureStorage();
    await _safeInitAsync(() async {
      _teamSetup = await secureStorage.getString('ff_teamSetup') ?? _teamSetup;
    });
    await _safeInitAsync(() async {
      _userSetup = await secureStorage.getString('ff_userSetup') ?? _userSetup;
    });
    await _safeInitAsync(() async {
      _saisonSetup =
          await secureStorage.getString('ff_saisonSetup') ?? _saisonSetup;
    });
    await _safeInitAsync(() async {
      _roleSetup = await secureStorage.getString('ff_roleSetup') ?? _roleSetup;
    });
    await _safeInitAsync(() async {
      final storedRecentPenalties =
          await secureStorage.getString('ff_recent_penalties');
      if (storedRecentPenalties != null && storedRecentPenalties.isNotEmpty) {
        _recentPenaltyIds =
            storedRecentPenalties.split(',').where((id) => id.isNotEmpty).toList();
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  String _teamSetup = '';
  String get teamSetup => _teamSetup;
  set teamSetup(String value) {
    _teamSetup = value;
    secureStorage.setString('ff_teamSetup', value);
  }

  void deleteTeamSetup() {
    secureStorage.delete(key: 'ff_teamSetup');
  }

  String _userSetup = '';
  String get userSetup => _userSetup;
  set userSetup(String value) {
    _userSetup = value;
    secureStorage.setString('ff_userSetup', value);
  }

  void deleteUserSetup() {
    secureStorage.delete(key: 'ff_userSetup');
  }

  String _saisonSetup = '';
  String get saisonSetup => _saisonSetup;
  set saisonSetup(String value) {
    _saisonSetup = value;
    secureStorage.setString('ff_saisonSetup', value);
  }

  void deleteSaisonSetup() {
    secureStorage.delete(key: 'ff_saisonSetup');
  }

  String _roleSetup = '';
  String get roleSetup => _roleSetup;
  set roleSetup(String value) {
    _roleSetup = value;
    secureStorage.setString('ff_roleSetup', value);
  }

  void deleteRoleSetup() {
    secureStorage.delete(key: 'ff_roleSetup');
  }

  List<dynamic> _teamSoldQuerry = [];
  List<dynamic> get teamSoldQuerry => _teamSoldQuerry;
  set teamSoldQuerry(List<dynamic> value) {
    _teamSoldQuerry = value;
  }

  void addToTeamSoldQuerry(dynamic value) {
    teamSoldQuerry.add(value);
  }

  void removeFromTeamSoldQuerry(dynamic value) {
    teamSoldQuerry.remove(value);
  }

  void removeAtIndexFromTeamSoldQuerry(int index) {
    teamSoldQuerry.removeAt(index);
  }

  void updateTeamSoldQuerryAtIndex(
    int index,
    dynamic Function(dynamic) updateFn,
  ) {
    teamSoldQuerry[index] = updateFn(_teamSoldQuerry[index]);
  }

  void insertAtIndexInTeamSoldQuerry(int index, dynamic value) {
    teamSoldQuerry.insert(index, value);
  }

  List<String> _recentPenaltyIds = [];
  List<String> get recentPenaltyIds => _recentPenaltyIds;
  set recentPenaltyIds(List<String> value) {
    _recentPenaltyIds = value;
    secureStorage.setString('ff_recent_penalties', value.join(','));
  }

  void addRecentPenaltyId(String value) {
    if (value.isEmpty) {
      return;
    }
    _recentPenaltyIds.remove(value);
    _recentPenaltyIds.insert(0, value);
    if (_recentPenaltyIds.length > 8) {
      _recentPenaltyIds = _recentPenaltyIds.sublist(0, 8);
    }
    secureStorage.setString('ff_recent_penalties', _recentPenaltyIds.join(','));
  }

  final _teamInfoManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> teamInfo({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _teamInfoManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearTeamInfoCache() => _teamInfoManager.clear();
  void clearTeamInfoCacheKey(String? uniqueKey) =>
      _teamInfoManager.clearRequest(uniqueKey);

  final _dashboardTransactionManager =
      FutureRequestManager<List<TransactionsRow>>();
  Future<List<TransactionsRow>> dashboardTransaction({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<TransactionsRow>> Function() requestFn,
  }) =>
      _dashboardTransactionManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearDashboardTransactionCache() => _dashboardTransactionManager.clear();
  void clearDashboardTransactionCacheKey(String? uniqueKey) =>
      _dashboardTransactionManager.clearRequest(uniqueKey);

  final _penalitiesDefaultManager = FutureRequestManager<List<PenaltiesRow>>();
  Future<List<PenaltiesRow>> penalitiesDefault({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<PenaltiesRow>> Function() requestFn,
  }) =>
      _penalitiesDefaultManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPenalitiesDefaultCache() => _penalitiesDefaultManager.clear();
  void clearPenalitiesDefaultCacheKey(String? uniqueKey) =>
      _penalitiesDefaultManager.clearRequest(uniqueKey);

  final _teamMemberInfoManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> teamMemberInfo({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _teamMemberInfoManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearTeamMemberInfoCache() => _teamMemberInfoManager.clear();
  void clearTeamMemberInfoCacheKey(String? uniqueKey) =>
      _teamMemberInfoManager.clearRequest(uniqueKey);

  final _userSoldManager = FutureRequestManager<ApiCallResponse>();
  Future<ApiCallResponse> userSold({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<ApiCallResponse> Function() requestFn,
  }) =>
      _userSoldManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearUserSoldCache() => _userSoldManager.clear();
  void clearUserSoldCacheKey(String? uniqueKey) =>
      _userSoldManager.clearRequest(uniqueKey);

  final _dashboardMyPaymentManager =
      FutureRequestManager<List<TransactionsRow>>();
  Future<List<TransactionsRow>> dashboardMyPayment({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<TransactionsRow>> Function() requestFn,
  }) =>
      _dashboardMyPaymentManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearDashboardMyPaymentCache() => _dashboardMyPaymentManager.clear();
  void clearDashboardMyPaymentCacheKey(String? uniqueKey) =>
      _dashboardMyPaymentManager.clearRequest(uniqueKey);

  final _paymentPendingManager = FutureRequestManager<List<TransactionsRow>>();
  Future<List<TransactionsRow>> paymentPending({
    String? uniqueQueryKey,
    bool? overrideCache,
    required Future<List<TransactionsRow>> Function() requestFn,
  }) =>
      _paymentPendingManager.performRequest(
        uniqueQueryKey: uniqueQueryKey,
        overrideCache: overrideCache,
        requestFn: requestFn,
      );
  void clearPaymentPendingCache() => _paymentPendingManager.clear();
  void clearPaymentPendingCacheKey(String? uniqueKey) =>
      _paymentPendingManager.clearRequest(uniqueKey);
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return const CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: const ListToCsvConverter().convert([value]));
}
