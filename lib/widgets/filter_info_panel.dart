import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lioncade/utilities/generic_functions.dart';
import 'package:provider/provider.dart';
import 'package:lioncade/models/responses/gameMedia_response.dart';
import '../providers/app_state.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FilterInfoPanel extends StatefulWidget {
  const FilterInfoPanel({super.key, required this.appLocalizations});
  final AppLocalizations appLocalizations;

  @override
  State<FilterInfoPanel> createState() => _GameInfoPanelState();
}

class _GameInfoPanelState extends State<FilterInfoPanel> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final selectedGame = appState.selectedGame;
        isFavorite = appState.selectedGame?.game.favorite == 1;
        return _buildGameInfoPanel(appState, selectedGame);
      },
    );
  }

  Widget _buildGameInfoPanel(
      AppState appState, GameMediaResponse? selectedGame) {
    //final isAnimationActive = animationState.isAnimationActive;
    playOst();

    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.white,
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: const AssetImage(
                            'assets/images/backgrounds/info.jpg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          hexToColorWithAlpha(
                              appState.themeApplied.backgroundMediumColor, 255),
                          BlendMode.color,
                        )),
                  ),
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.11,
                  bottom: MediaQuery.of(context).size.height * 0.13,
                  child: FadeIn(
                      animate: true,
                      duration: const Duration(seconds: 2),
                      child: const Text(
                        'Logo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            )),
        const Row(
          children: [
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 16, 16, 0), // Márgenes izquierdo y derecho
                  child: Text('Tiempo Jugado',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                )),
            Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16, 16, 16, 0), // Márgenes izquierdo y derecho
                  child: Text('0h 00m 00s',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              16, 16, 16, 0), // Márgenes izquierdo y derecho
          child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: hexToColorWithAlpha(
                    appState.themeApplied.backgroundStartColor, 150),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(141, 0, 0, 0),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(2, 2), // changes position of shadow
                  ),
                ],
              )),
        )
      ],
    );
  }

  Future<void> playOst() async {
    //await player.play(AssetSource('music/theme.mp3'));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
