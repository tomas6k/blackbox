import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/auth/supabase_auth/auth_util.dart';

DateTime? getFirstDayOfCurrentMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}

double convertCommaDotNegative(String? input) {
  // Vérifier si l'input est null ou vide
  if (input == null || input.isEmpty) {
    return 0.0;
  }

  // Supprimer tout ce qui n'est pas un chiffre, une virgule ou un point
  String cleanedString = input.replaceAll(RegExp(r'[^0-9,\.]'), '');

  // Remplacer les virgules par des points (sans toucher aux points existants)
  String formattedString = cleanedString.contains('.')
      ? cleanedString
      : cleanedString.replaceAll(',', '.');

  // Convertir la chaîne en double
  double? result = double.tryParse(formattedString);

  // Retourner 0.0 si la conversion échoue, sinon arrondir à deux décimales et rendre le résultat toujours négatif
  return result != null ? -double.parse(result.toStringAsFixed(2)).abs() : 0.0;
}

double calculatePositiveSum(List<dynamic> transactions) {
  double positiveSum = 0.0;

  // Parcourir la liste des transactions et ajouter le positive_sum de chaque joueur
  for (var transaction in transactions) {
    // Vérifier si 'positive_sum' est présent et est un nombre
    if (transaction['positive_sum'] != null &&
        transaction['positive_sum'] is num) {
      positiveSum += transaction['positive_sum'];
    }
  }

  return positiveSum;
}

DateTime? getLastDayOfCurrentMonth() {
  final now = DateTime.now();
  final nextMonth = now.month == 12 ? 1 : now.month + 1;
  final nextYear = now.month == 12 ? now.year + 1 : now.year;
  final lastDay = DateTime(nextYear, nextMonth, 0, 23, 59, 59,
      999); // 0 jours dans le mois suivant donne le dernier jour du mois actuel
  return lastDay;
}

DateTime? getFirstDayOfPreviousMonth() {
  final now = DateTime.now();
  final previousMonth = now.month == 1 ? 12 : now.month - 1;
  final previousYear = now.month == 1 ? now.year - 1 : now.year;
  return DateTime(previousYear, previousMonth, 1);
}

DateTime? getLastDayOfPreviousMonth() {
  final now = DateTime.now();
  final previousMonth = now.month == 1 ? 12 : now.month - 1;
  final previousYear = now.month == 1 ? now.year - 1 : now.year;
  final lastDayOfPreviousMonth =
      DateTime(previousYear, previousMonth + 1, 0, 23, 59, 59, 999);
  return lastDayOfPreviousMonth;
}

DateTime? getLastDayOfMonthBeforeLastMonth() {
  final now = DateTime.now();
  final twoMonthsAgo = DateTime(now.year, now.month - 2, 1);
  final lastDayOfMonthBeforeLastMonth =
      DateTime(twoMonthsAgo.year, twoMonthsAgo.month + 1, 0, 23, 59, 59, 999);
  return lastDayOfMonthBeforeLastMonth;
}

bool getBoolValue(
  String? chipValue,
  List<String>? typeSelected,
) {
  // Vérifier si l'un des arguments est null ou si la liste est vide
  if (chipValue == null || typeSelected == null || typeSelected.isEmpty) {
    return false;
  }

  // Vérifier si la valeur du chip est dans la liste des types sélectionnés
  return typeSelected.contains(chipValue);
}

String? convertDotCommaEuro(double numberDot) {
  // Arrondir la valeur à deux décimales
  double roundedNumber = double.parse(numberDot.toStringAsFixed(2));

  // Utiliser NumberFormat pour formater les nombres selon la locale
  final formatter = NumberFormat.currency(
    locale:
        'fr_FR', // Utilisez la locale françaised pour des virgules décimales
    symbol: '€', // Symbole de l'euro
    decimalDigits: 2, // Afficher 2 décimales
  );

  // Formater le nombre
  String formattedNumber = formatter.format(roundedNumber);

  // Si le nombre est arrondi à une valeur entière, supprimer les décimales
  if (formattedNumber.contains(",00")) {
    formattedNumber = formattedNumber.replaceAll(",00", "");
  }

  // Retourner le nombre formaté avec le symbole euro
  return formattedNumber;
}

double convertCommaDot(String? input) {
  // Vérifier si l'input est null ou vide
  if (input == null || input.isEmpty) {
    return 0.0;
  }

  // Supprimer tout ce qui n'est pas un chiffre, une virgule ou un point
  String cleanedString = input.replaceAll(RegExp(r'[^0-9,\.]'), '');

  // Remplacer les virgules par des points (sans toucher aux points existants)
  String formattedString = cleanedString.contains('.')
      ? cleanedString
      : cleanedString.replaceAll(',', '.');

  // Convertir la chaîne en double
  double? result = double.tryParse(formattedString);

  // Retourner 0.0 si la conversion échoue, sinon arrondir à deux décimales
  return result != null ? double.parse(result.toStringAsFixed(2)) : 0.0;
}

bool showSearchResult(
  String textSearchFor,
  String textSearchIn,
) {
  return textSearchIn.toLowerCase().contains(textSearchFor.toLowerCase());
}

bool isNewDate(
  List<TransactionsRow> transactions,
  int currentIndex,
) {
  if (currentIndex == 0) return true;

  // Obtenez la date actuelle et la date précédente
  DateTime currentDate = transactions[currentIndex].transactionDate!;
  DateTime previousDate = transactions[currentIndex - 1].transactionDate!;

  // Comparez les dates
  return currentDate.day != previousDate.day ||
      currentDate.month != previousDate.month ||
      currentDate.year != previousDate.year;
}

double? calculateNegativeSum(
  List<TransactionsRow> transactions,
  DateTime? date,
) {
  double sum = 0.0;

  // Vérifier que la date n'est pas nulle
  if (date == null) {
    return 0.0;
  }

  // Parcourir toutes les transactions et calculer la somme des transactions négatives pour la date donnée
  for (var transaction in transactions) {
    if (transaction.transactionDate?.year == date.year &&
        transaction.transactionDate?.month == date.month &&
        transaction.transactionDate?.day == date.day &&
        (transaction.transactionValue ?? 0) < 0) {
      sum += transaction.transactionValue ?? 0;
    }
  }

  return sum;
}

double calculateTotalDueSum(List<dynamic> transactions) {
  double totalDueSum = 0.0;

  // Parcourir la liste des transactions et ajouter uniquement les total_due_sum négatifs
  for (var transaction in transactions) {
    // Vérifier si 'total_due_sum' est présent, est un nombre et est négatif
    if (transaction['total_due_sum'] != null &&
        transaction['total_due_sum'] is num) {
      double value = transaction['total_due_sum'];
      if (value < 0) {
        totalDueSum += value;
      }
    }
  }

  return totalDueSum;
}

List<dynamic> generateMonthsWithFuture(int? year) {
  // Utiliser l'année courante par défaut si aucune année n'est donnée
  int targetYear = year ?? DateTime.now().year;
  List<dynamic> monthsList = [];
  DateTime now = DateTime.now();

  // Liste des noms des mois en français
  List<String> frenchMonths = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
  ];

  for (int month = 1; month <= 12; month++) {
    DateTime date = DateTime(targetYear, month);
    bool isFuture = date.isAfter(now); // Vérifier si le mois est dans le futur

    // Ajouter à la liste un tableau [nom_du_mois, numéro_du_mois, année, estDansLeFutur]
    monthsList.add([frenchMonths[month - 1], month, targetYear, isFuture]);
  }

  return monthsList;
}

bool? isMonthActive(
  int monthNumber,
  int monthActive,
) {
  return monthNumber == monthActive;
}

int? convertToInt(String? input) {
  if (input == null) {
    return null;
  }

  // Try to convert the input to an integer
  return int.tryParse(input.toString());
}

List<dynamic> generateLastYears(int? numberOfYears) {
  // Obtenir l'année actuelle
  int currentYear = DateTime.now().year;

  // Utiliser 5 ans comme valeur par défaut si aucun paramètre n'est fourni
  int yearsToGenerate = numberOfYears ?? 5;

  List<dynamic> yearsList = [];

  // Générer les années en fonction du paramètre ou des 5 dernières années par défaut
  for (int i = 0; i < yearsToGenerate; i++) {
    int year = currentYear - i;

    // Ajouter à la liste un tableau [année, estAnnéeActuelle]
    yearsList.add([year, year == currentYear]);
  }

  return yearsList;
}

int extractDateDetails(
  DateTime? date,
  String? detail,
) {
  // Vérifier que la date n'est pas nulle
  if (date == null) {
    return 0; // Si la date est nulle, retourner 0
  }

  // Vérifier la valeur de "detail" et retourner le bon résultat
  switch (detail) {
    case 'day':
      return date.day; // Retourne le chiffre du jour
    case 'month':
      return date.month; // Retourne le chiffre du mois
    case 'year':
      return date.year; // Retourne l'année
    default:
      return 0; // Si le paramètre n'est pas valide, retourner 0
  }
}

DateTime? getBoundaryDate(
  int? month,
  int? year,
  String? dateType,
) {
  // Si month ou year sont null, utiliser la date actuelle
  DateTime now = DateTime.now();
  int targetMonth = month ?? now.month; // Par défaut : mois courant
  int targetYear = year ?? now.year; // Par défaut : année courante
  String targetDateType = (dateType == null || dateType.isEmpty)
      ? 'first'
      : dateType; // Par défaut : "first"

  // Vérifier si les valeurs sont valides
  if (targetMonth < 1 || targetMonth > 12 || targetYear < 0) {
    return null; // Retourner null si les paramètres sont invalides
  }

  if (targetDateType == 'first') {
    // Retourner la première date du mois à minuit
    return DateTime(targetYear, targetMonth, 1, 0, 0, 0);
  } else if (targetDateType == 'end') {
    // Retourner la dernière date du mois
    DateTime lastDayOfMonth =
        DateTime(targetYear, targetMonth + 1, 0, 23, 59, 59);

    // Retourner la dernière date du mois à 23:59:59
    return lastDayOfMonth;
  }

  return null; // Si le paramètre dateType est incorrect
}

bool? convertToBool(String? input) {
  if (input == null || input.isEmpty) {
    return null;
  }

  // Convertir l'entrée en minuscules pour standardiser la comparaison
  String normalizedInput = input.toLowerCase();

  // Retourner true si l'entrée est "true" ou "1", sinon false pour "false" ou "0"
  if (normalizedInput == 'true' || normalizedInput == '1') {
    return true;
  } else if (normalizedInput == 'false' || normalizedInput == '0') {
    return false;
  }

  // Si l'entrée ne correspond pas à un booléen valide, retourner null
  return null;
}
