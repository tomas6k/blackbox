// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GetSoldStruct extends BaseStruct {
  GetSoldStruct({
    String? userId,
    String? userName,
    String? userImg,
    double? positiveSum,
    double? negativeSum,
    double? totalSum,
    double? positiveSumExcludeThismonth,
    double? negativeSumExcludeThismonth,
    double? totalSumExcludeThismonth,
    double? totalDueSum,
    String? teamId,
    String? teamName,
    String? teamImg,
    String? teamGoal,
  })  : _userId = userId,
        _userName = userName,
        _userImg = userImg,
        _positiveSum = positiveSum,
        _negativeSum = negativeSum,
        _totalSum = totalSum,
        _positiveSumExcludeThismonth = positiveSumExcludeThismonth,
        _negativeSumExcludeThismonth = negativeSumExcludeThismonth,
        _totalSumExcludeThismonth = totalSumExcludeThismonth,
        _totalDueSum = totalDueSum,
        _teamId = teamId,
        _teamName = teamName,
        _teamImg = teamImg,
        _teamGoal = teamGoal;

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  set userId(String? val) => _userId = val;

  bool hasUserId() => _userId != null;

  // "user_name" field.
  String? _userName;
  String get userName => _userName ?? '';
  set userName(String? val) => _userName = val;

  bool hasUserName() => _userName != null;

  // "user_img" field.
  String? _userImg;
  String get userImg => _userImg ?? '';
  set userImg(String? val) => _userImg = val;

  bool hasUserImg() => _userImg != null;

  // "positive_sum" field.
  double? _positiveSum;
  double get positiveSum => _positiveSum ?? 0.0;
  set positiveSum(double? val) => _positiveSum = val;

  void incrementPositiveSum(double amount) =>
      positiveSum = positiveSum + amount;

  bool hasPositiveSum() => _positiveSum != null;

  // "negative_sum" field.
  double? _negativeSum;
  double get negativeSum => _negativeSum ?? 0.0;
  set negativeSum(double? val) => _negativeSum = val;

  void incrementNegativeSum(double amount) =>
      negativeSum = negativeSum + amount;

  bool hasNegativeSum() => _negativeSum != null;

  // "total_sum" field.
  double? _totalSum;
  double get totalSum => _totalSum ?? 0.0;
  set totalSum(double? val) => _totalSum = val;

  void incrementTotalSum(double amount) => totalSum = totalSum + amount;

  bool hasTotalSum() => _totalSum != null;

  // "positive_sum_exclude_thismonth" field.
  double? _positiveSumExcludeThismonth;
  double get positiveSumExcludeThismonth => _positiveSumExcludeThismonth ?? 0.0;
  set positiveSumExcludeThismonth(double? val) =>
      _positiveSumExcludeThismonth = val;

  void incrementPositiveSumExcludeThismonth(double amount) =>
      positiveSumExcludeThismonth = positiveSumExcludeThismonth + amount;

  bool hasPositiveSumExcludeThismonth() => _positiveSumExcludeThismonth != null;

  // "negative_sum_exclude_thismonth" field.
  double? _negativeSumExcludeThismonth;
  double get negativeSumExcludeThismonth => _negativeSumExcludeThismonth ?? 0.0;
  set negativeSumExcludeThismonth(double? val) =>
      _negativeSumExcludeThismonth = val;

  void incrementNegativeSumExcludeThismonth(double amount) =>
      negativeSumExcludeThismonth = negativeSumExcludeThismonth + amount;

  bool hasNegativeSumExcludeThismonth() => _negativeSumExcludeThismonth != null;

  // "total_sum_exclude_thismonth" field.
  double? _totalSumExcludeThismonth;
  double get totalSumExcludeThismonth => _totalSumExcludeThismonth ?? 0.0;
  set totalSumExcludeThismonth(double? val) => _totalSumExcludeThismonth = val;

  void incrementTotalSumExcludeThismonth(double amount) =>
      totalSumExcludeThismonth = totalSumExcludeThismonth + amount;

  bool hasTotalSumExcludeThismonth() => _totalSumExcludeThismonth != null;

  // "total_due_sum" field.
  double? _totalDueSum;
  double get totalDueSum => _totalDueSum ?? 0.0;
  set totalDueSum(double? val) => _totalDueSum = val;

  void incrementTotalDueSum(double amount) =>
      totalDueSum = totalDueSum + amount;

  bool hasTotalDueSum() => _totalDueSum != null;

  // "team_id" field.
  String? _teamId;
  String get teamId => _teamId ?? '';
  set teamId(String? val) => _teamId = val;

  bool hasTeamId() => _teamId != null;

  // "team_name" field.
  String? _teamName;
  String get teamName => _teamName ?? '';
  set teamName(String? val) => _teamName = val;

  bool hasTeamName() => _teamName != null;

  // "team_img" field.
  String? _teamImg;
  String get teamImg => _teamImg ?? '';
  set teamImg(String? val) => _teamImg = val;

  bool hasTeamImg() => _teamImg != null;

  // "team_goal" field.
  String? _teamGoal;
  String get teamGoal => _teamGoal ?? '';
  set teamGoal(String? val) => _teamGoal = val;

  bool hasTeamGoal() => _teamGoal != null;

  static GetSoldStruct fromMap(Map<String, dynamic> data) => GetSoldStruct(
        userId: data['user_id'] as String?,
        userName: data['user_name'] as String?,
        userImg: data['user_img'] as String?,
        positiveSum: castToType<double>(data['positive_sum']),
        negativeSum: castToType<double>(data['negative_sum']),
        totalSum: castToType<double>(data['total_sum']),
        positiveSumExcludeThismonth:
            castToType<double>(data['positive_sum_exclude_thismonth']),
        negativeSumExcludeThismonth:
            castToType<double>(data['negative_sum_exclude_thismonth']),
        totalSumExcludeThismonth:
            castToType<double>(data['total_sum_exclude_thismonth']),
        totalDueSum: castToType<double>(data['total_due_sum']),
        teamId: data['team_id'] as String?,
        teamName: data['team_name'] as String?,
        teamImg: data['team_img'] as String?,
        teamGoal: data['team_goal'] as String?,
      );

  static GetSoldStruct? maybeFromMap(dynamic data) =>
      data is Map ? GetSoldStruct.fromMap(data.cast<String, dynamic>()) : null;

  Map<String, dynamic> toMap() => {
        'user_id': _userId,
        'user_name': _userName,
        'user_img': _userImg,
        'positive_sum': _positiveSum,
        'negative_sum': _negativeSum,
        'total_sum': _totalSum,
        'positive_sum_exclude_thismonth': _positiveSumExcludeThismonth,
        'negative_sum_exclude_thismonth': _negativeSumExcludeThismonth,
        'total_sum_exclude_thismonth': _totalSumExcludeThismonth,
        'total_due_sum': _totalDueSum,
        'team_id': _teamId,
        'team_name': _teamName,
        'team_img': _teamImg,
        'team_goal': _teamGoal,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'user_id': serializeParam(
          _userId,
          ParamType.String,
        ),
        'user_name': serializeParam(
          _userName,
          ParamType.String,
        ),
        'user_img': serializeParam(
          _userImg,
          ParamType.String,
        ),
        'positive_sum': serializeParam(
          _positiveSum,
          ParamType.double,
        ),
        'negative_sum': serializeParam(
          _negativeSum,
          ParamType.double,
        ),
        'total_sum': serializeParam(
          _totalSum,
          ParamType.double,
        ),
        'positive_sum_exclude_thismonth': serializeParam(
          _positiveSumExcludeThismonth,
          ParamType.double,
        ),
        'negative_sum_exclude_thismonth': serializeParam(
          _negativeSumExcludeThismonth,
          ParamType.double,
        ),
        'total_sum_exclude_thismonth': serializeParam(
          _totalSumExcludeThismonth,
          ParamType.double,
        ),
        'total_due_sum': serializeParam(
          _totalDueSum,
          ParamType.double,
        ),
        'team_id': serializeParam(
          _teamId,
          ParamType.String,
        ),
        'team_name': serializeParam(
          _teamName,
          ParamType.String,
        ),
        'team_img': serializeParam(
          _teamImg,
          ParamType.String,
        ),
        'team_goal': serializeParam(
          _teamGoal,
          ParamType.String,
        ),
      }.withoutNulls;

  static GetSoldStruct fromSerializableMap(Map<String, dynamic> data) =>
      GetSoldStruct(
        userId: deserializeParam(
          data['user_id'],
          ParamType.String,
          false,
        ),
        userName: deserializeParam(
          data['user_name'],
          ParamType.String,
          false,
        ),
        userImg: deserializeParam(
          data['user_img'],
          ParamType.String,
          false,
        ),
        positiveSum: deserializeParam(
          data['positive_sum'],
          ParamType.double,
          false,
        ),
        negativeSum: deserializeParam(
          data['negative_sum'],
          ParamType.double,
          false,
        ),
        totalSum: deserializeParam(
          data['total_sum'],
          ParamType.double,
          false,
        ),
        positiveSumExcludeThismonth: deserializeParam(
          data['positive_sum_exclude_thismonth'],
          ParamType.double,
          false,
        ),
        negativeSumExcludeThismonth: deserializeParam(
          data['negative_sum_exclude_thismonth'],
          ParamType.double,
          false,
        ),
        totalSumExcludeThismonth: deserializeParam(
          data['total_sum_exclude_thismonth'],
          ParamType.double,
          false,
        ),
        totalDueSum: deserializeParam(
          data['total_due_sum'],
          ParamType.double,
          false,
        ),
        teamId: deserializeParam(
          data['team_id'],
          ParamType.String,
          false,
        ),
        teamName: deserializeParam(
          data['team_name'],
          ParamType.String,
          false,
        ),
        teamImg: deserializeParam(
          data['team_img'],
          ParamType.String,
          false,
        ),
        teamGoal: deserializeParam(
          data['team_goal'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GetSoldStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GetSoldStruct &&
        userId == other.userId &&
        userName == other.userName &&
        userImg == other.userImg &&
        positiveSum == other.positiveSum &&
        negativeSum == other.negativeSum &&
        totalSum == other.totalSum &&
        positiveSumExcludeThismonth == other.positiveSumExcludeThismonth &&
        negativeSumExcludeThismonth == other.negativeSumExcludeThismonth &&
        totalSumExcludeThismonth == other.totalSumExcludeThismonth &&
        totalDueSum == other.totalDueSum &&
        teamId == other.teamId &&
        teamName == other.teamName &&
        teamImg == other.teamImg &&
        teamGoal == other.teamGoal;
  }

  @override
  int get hashCode => const ListEquality().hash([
        userId,
        userName,
        userImg,
        positiveSum,
        negativeSum,
        totalSum,
        positiveSumExcludeThismonth,
        negativeSumExcludeThismonth,
        totalSumExcludeThismonth,
        totalDueSum,
        teamId,
        teamName,
        teamImg,
        teamGoal
      ]);
}

GetSoldStruct createGetSoldStruct({
  String? userId,
  String? userName,
  String? userImg,
  double? positiveSum,
  double? negativeSum,
  double? totalSum,
  double? positiveSumExcludeThismonth,
  double? negativeSumExcludeThismonth,
  double? totalSumExcludeThismonth,
  double? totalDueSum,
  String? teamId,
  String? teamName,
  String? teamImg,
  String? teamGoal,
}) =>
    GetSoldStruct(
      userId: userId,
      userName: userName,
      userImg: userImg,
      positiveSum: positiveSum,
      negativeSum: negativeSum,
      totalSum: totalSum,
      positiveSumExcludeThismonth: positiveSumExcludeThismonth,
      negativeSumExcludeThismonth: negativeSumExcludeThismonth,
      totalSumExcludeThismonth: totalSumExcludeThismonth,
      totalDueSum: totalDueSum,
      teamId: teamId,
      teamName: teamName,
      teamImg: teamImg,
      teamGoal: teamGoal,
    );
