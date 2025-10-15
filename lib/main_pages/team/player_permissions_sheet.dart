import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerPermissionsSheet extends StatefulWidget {
  const PlayerPermissionsSheet({
    super.key,
    required this.userTeamId,
    required this.displayName,
  });

  final String userTeamId;
  final String displayName;

  @override
  State<PlayerPermissionsSheet> createState() => _PlayerPermissionsSheetState();
}

class _PlayerPermissionsSheetState extends State<PlayerPermissionsSheet> {
  bool _loading = true;
  bool _eco = false;
  bool _blacktax = false;
  bool _isUpdatingEco = false;
  bool _isUpdatingBlacktax = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final result = await UserTeamsTable().querySingleRow(
        queryFn: (rows) => rows.eq('id', widget.userTeamId),
      );
      final row = result.isNotEmpty ? result.first : null;
      if (!mounted) {
        return;
      }
      setState(() {
        _eco = row?.eco ?? false;
        _blacktax = row?.blacktax ?? false;
        _loading = false;
        _errorMessage = row == null
            ? 'Impossible de charger les informations du joueur.'
            : null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Impossible de charger les informations du joueur.';
      });
    }
  }

  Future<void> _updateFlag({
    required String fieldName,
    required bool value,
  }) async {
    final previousValue = fieldName == 'eco' ? _eco : _blacktax;

    setState(() {
      if (fieldName == 'eco') {
        _eco = value;
        _isUpdatingEco = true;
      } else {
        _blacktax = value;
        _isUpdatingBlacktax = true;
      }
      _errorMessage = null;
    });

    HapticFeedback.selectionClick();

    try {
      await UserTeamsTable().update(
        data: {fieldName: value},
        matchingRows: (rows) => rows.eq('id', widget.userTeamId),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        if (fieldName == 'eco') {
          _isUpdatingEco = false;
        } else {
          _isUpdatingBlacktax = false;
        }
      });

      final confirmation = fieldName == 'eco'
          ? 'Éco ${value ? 'activée' : 'désactivée'} pour ${widget.displayName}.'
          : 'Blacktax ${value ? 'activée' : 'désactivée'} pour ${widget.displayName}.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(confirmation),
          backgroundColor: FlutterFlowTheme.of(context).primary,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (fieldName == 'eco') {
          _eco = previousValue;
          _isUpdatingEco = false;
        } else {
          _blacktax = previousValue;
          _isUpdatingBlacktax = false;
        }
        _errorMessage = 'La mise à jour a échoué. Réessayez.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Une erreur est survenue lors de la mise à jour.'),
          backgroundColor: FlutterFlowTheme.of(context).error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: Material(
        color: Colors.transparent,
        elevation: 6.0,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: theme.primaryBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: theme.secondaryText.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    widget.displayName,
                    style: theme.headlineSmall.override(
                      fontFamily: 'Manrope',
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Gestion des privilèges',
                    style: theme.labelMedium.override(
                      fontFamily: 'Manrope',
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Visible uniquement par le propriétaire de l’équipe.',
                    style: theme.bodySmall.override(
                      fontFamily: 'Manrope',
                      color: theme.secondaryText,
                      letterSpacing: 0.0,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (_loading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primary,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          _errorMessage!,
                          style: theme.bodyMedium.override(
                            fontFamily: 'Manrope',
                            color: theme.error,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    SwitchListTile.adaptive(
                      value: _eco,
                      onChanged: _isUpdatingEco
                          ? null
                          : (value) => _updateFlag(
                                fieldName: 'eco',
                                value: value,
                              ),
                      title: Text(
                        'Éligible Éco',
                        style: theme.titleMedium.override(
                          fontFamily: 'Manrope',
                          letterSpacing: 0.0,
                        ),
                      ),
                      subtitle: Text(
                        'Active les avantages Éco pour ce joueur.',
                        style: theme.bodySmall.override(
                          fontFamily: 'Manrope',
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      activeColor: theme.primary,
                      activeTrackColor: theme.primary.withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                    ),
                    SwitchListTile.adaptive(
                      value: _blacktax,
                      onChanged: _isUpdatingBlacktax
                          ? null
                          : (value) => _updateFlag(
                                fieldName: 'blacktax',
                                value: value,
                              ),
                      title: Text(
                        'Blacktax',
                        style: theme.titleMedium.override(
                          fontFamily: 'Manrope',
                          letterSpacing: 0.0,
                        ),
                      ),
                      subtitle: Text(
                        'Soumet ce joueur à la blacktax.',
                        style: theme.bodySmall.override(
                          fontFamily: 'Manrope',
                          color: theme.secondaryText,
                          letterSpacing: 0.0,
                        ),
                      ),
                      activeColor: theme.primary,
                      activeTrackColor: theme.primary.withOpacity(0.4),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
