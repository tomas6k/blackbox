import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class GetSoldCall {
  static Future<ApiCallResponse> call({
    String? whitchSaison = 'aec046ab-4f29-4892-af65-f47725fba452',
    String? whitchUser = '',
    String? statutParam = '1',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getSold',
      apiUrl:
          'https://dnrinnvsfrbmrlmcxiij.supabase.co/rest/v1/rpc/calculate_user_sold',
      callType: ApiCallType.GET,
      headers: {
        'apikey':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRucmlubnZzZnJibXJsbWN4aWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyNTE1ODUsImV4cCI6MjAzNzgyNzU4NX0.pQ4yOOl4OLnHnG4Cx9JUC8KD0SSUHVsR0Q2_6DZdUyU',
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRucmlubnZzZnJibXJsbWN4aWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjIyNTE1ODUsImV4cCI6MjAzNzgyNzU4NX0.pQ4yOOl4OLnHnG4Cx9JUC8KD0SSUHVsR0Q2_6DZdUyU',
      },
      params: {
        'season_uid': whitchSaison,
        'user_uid': whitchUser,
        'statut_param': statutParam,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
