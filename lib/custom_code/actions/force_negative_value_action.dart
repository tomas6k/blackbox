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

Future<String> forceNegativeValueAction(String? inputValue) async {
  // Add your function code here!
  if (inputValue == null || inputValue.isEmpty) {
    return "0";
  }

  // Convertir la valeur en double
  double? value = double.tryParse(inputValue);

  // Vérifier si la conversion a échoué
  if (value == null) {
    return "0";
  }

  // Forcer la valeur à être négative
  if (value > 0) {
    value = -value;
  }

  // Retourner la valeur négative sous forme de chaîne de caractères
  return value.toString();
}
