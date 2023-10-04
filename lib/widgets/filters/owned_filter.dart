import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synchronyx/providers/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:synchronyx/widgets/buttons/text_button_colored.dart';
import 'package:synchronyx/widgets/grid_view_game_covers.dart';

class OwnedFilterColumn extends StatelessWidget {
  const OwnedFilterColumn({required this.appLocalizations, super.key});

  final AppLocalizations appLocalizations;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Consumer<AppState>(builder: (context, appState, child) {
      return Container(
          padding: const EdgeInsets.all(10.0), // Padding del contenedor
          child: ListView(
            children: <Widget>[
              TextButtonHoverColored(
                text: appLocalizations.yes,
                key: const ValueKey(2),
                onPressed: (() => {
                      appState.updateFilters('owned', 'yes'),
                      appState.updateButtonClickedKey(ValueKey(1)),
                      appState.refreshGridView()
                    }),
              ),
              TextButtonHoverColored(
                text: appLocalizations.no,
                key: const ValueKey(3),
                onPressed: (() => {
                      appState.updateFilters('owned', 'no'),
                      appState.updateButtonClickedKey(ValueKey(2)),
                      appState.refreshGridView()
                    }),
              ),
            ],
          ));
    });
  }
}
