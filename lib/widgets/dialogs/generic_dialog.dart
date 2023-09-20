import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:synchronyx/icons/custom_icons_icons.dart';
import 'package:synchronyx/providers/app_state.dart';
import 'package:synchronyx/utilities/audio_singleton.dart';
import 'package:synchronyx/utilities/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:synchronyx/widgets/dialogs/import_dialog.dart';

class GenericDialog extends StatefulWidget {
  GenericDialog(
      {super.key,
      required this.appLocalizations,
      required this.content,
      required this.dialogTitle,
      required this.icon,
      this.dialogHeader,
      this.preContent});
  final AppLocalizations appLocalizations;
  final Widget content;
  final String dialogTitle;
  final String? dialogHeader;
  final Widget? preContent; //Content before content
  final Icon icon;

  @override
  State<GenericDialog> createState() => _GenericDialogState();
}

class _GenericDialogState extends State<GenericDialog> {
  final AudioManager audioManager = AudioManager();
  Offset _offset = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final indexSelected = ValueNotifier<int>(-1);
    return GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _offset += details.delta;
          });
        },
        child: CustomDialog(
            offset: _offset,
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 2, 34, 14),
                    width: 0.2,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Constants.SIDE_BAR_COLOR,
                      Color.fromARGB(255, 33, 109, 72),
                      Color.fromARGB(255, 48, 87, 3),
                    ],
                  ),
                ),
                child: Stack(children: [
                  Positioned.fill(
                      child: Column(
                    children: [
                      AppBar(
                        backgroundColor: Constants.SIDE_BAR_COLOR,
                        elevation: 0.0,
                        toolbarHeight: 35.0,
                        titleSpacing: -20.0,
                        leading: const Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(CustomIcons.emulators,
                              color: Colors.white, size: 20),
                        ),
                        title: Text(
                          widget.dialogTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                        child: Text(
                          widget.dialogHeader ?? '',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(child: widget.preContent),
                      SizedBox(height:40),
                      Expanded(
                        child: ListView(
                          children: [
                            // El contenido de widget.content aquí
                            widget.content,
                          ],
                        ),
                      ),
                    ],
                  )),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: Color.fromARGB(255, 48, 87, 3),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              audioManager.currentUrlNotifier.value = '';
                              audioManager.isPlayingNotifier.value = false;
                              audioManager.audioPlayer.dispose;
                              audioManager.stop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.red, // Change the button color to red
                            ),
                            child: Text(widget.appLocalizations.cancel),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ]))));
  }
}