// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class CustomCurrencyInput extends StatefulWidget {
  const CustomCurrencyInput({
    super.key,
    this.width,
    this.height,
    this.showNegativeSign =
        false, // Paramètre pour afficher ou non le signe "-"
  });

  final double? width;
  final double? height;
  final bool showNegativeSign; // Paramètre pour afficher ou non le signe "-"

  @override
  State<CustomCurrencyInput> createState() => _CustomCurrencyInputState();
}

class _CustomCurrencyInputState extends State<CustomCurrencyInput> {
  TextEditingController _controller = TextEditingController();
  double _textWidth = 50.0; // Largeur initiale du texte

  @override
  void initState() {
    super.initState();
    _controller.addListener(_calculateTextWidth);
  }

  void _calculateTextWidth() {
    final text = _controller.text;

    // Calculer la largeur du texte en fonction du contenu
    final textPainter = TextPainter(
        text: TextSpan(text: text, style: TextStyle(fontSize: 24)),
        maxLines: 1,
        textDirection: ui.TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);

    setState(() {
      _textWidth = textPainter.size.width + 10; // Ajouter un peu de marge
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width, // Utilisation de la largeur passée en paramètre
      height: widget.height, // Utilisation de la hauteur passée en paramètre
      child: Row(
        children: [
          // Afficher ou non le symbole "-" à gauche
          if (widget.showNegativeSign)
            Text(
              '-',
              style: TextStyle(fontSize: 24),
            ),
          // Le TextField pour entrer la valeur avec une largeur qui s'adapte
          Container(
            width: _textWidth,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              inputFormatters: [
                // Filtre pour permettre uniquement les chiffres et le point
                FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*\.?[0-9]*$')),
              ],
              style: TextStyle(fontSize: 24),
            ),
          ),
          // Le symbole "€" à droite
          Text(
            '€',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_calculateTextWidth);
    _controller.dispose();
    super.dispose();
  }
}
