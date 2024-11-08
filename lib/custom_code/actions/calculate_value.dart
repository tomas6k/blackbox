// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<double> calculateValue(
  List<String> type, // Le chip sélecteur multiple nommé "type"
  double
      targetPenalitieValue, // La Local Page State Variable nommée "targetPenalitieValue"
  int quantity, // Le multiplicateur provenant du widget CountController nommé "quantity"
) async {
  // Vérifier si "Gameday" ou "BlackWeek" est sélectionné dans "type"
  double gameday = (type.contains('Gameday')) ? 2.0 : 1.0;
  double blackweek = (type.contains('BlackWeek')) ? 2.0 : 1.0;

  // Calcul initial du transactionValue basé sur "Gameday" et "BlackWeek"
  double transactionValue = gameday * blackweek;

  // Appliquer la valeur de targetPenalitieValue
  transactionValue *= targetPenalitieValue;

  // Appliquer le multiplicateur quantity
  transactionValue *= quantity;

  // Retourner la valeur calculée en tant que double
  return transactionValue;
}
