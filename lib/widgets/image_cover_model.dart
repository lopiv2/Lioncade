import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:synchronyx/utilities/generic_api_functions.dart';
import '../models/game.dart';
import '../models/responses/gameMedia_response.dart';
import '../models/media.dart';
import '../providers/app_state.dart';

class ImageCoverModel extends StatefulWidget {
  final Game game;
  final Media gameMedia;
  final int index;
  final Function(int) onGameClick;

  const ImageCoverModel(
      {super.key,
      required this.game,
      required this.gameMedia,
      required this.index,
      required this.onGameClick});

  @override
  _ImageCoverModel createState() => _ImageCoverModel();
}

class _ImageCoverModel extends State<ImageCoverModel>
    with SingleTickerProviderStateMixin {
  bool isMouseOver = false;
  DioClient dioClient = DioClient();
  late AnimationController _animationController;
  bool isRotated = false;
  bool rotatedCover = false;
  bool showAdditionalOverlay =
      false; // Variable para controlar la visibilidad de la imagen overlay adicional

  void toggleCoverAnimation(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.toggleCover();
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    //Compruebo para que solo rote el elemento con indice clickado
  }

  void createGameFromTitle(GameMediaResponse game) {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.updateSelectedGame(game);
    //print(appState.selectedGame);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    ImageProvider<Object> logoWidgetMarquee;
    logoWidgetMarquee = FileImage(File(widget.gameMedia.logoUrl));
    if (widget.index == appState.clickedElementIndex) {
      //Si la animacion del elemento esta activada para realizarse
      if (Provider.of<AppState>(context, listen: false)
          .elementsAnimations[widget.index]) {
        _animationController.forward();
        _animationController.addListener(() {
          // Detectar cuando la animación ha finalizado y cambiar el estado de showAdditionalOverlay
          if (_animationController.value > 0.5) {
            setState(() {
              showAdditionalOverlay = true;
            });
          } else if (_animationController.status == AnimationStatus.dismissed) {
            setState(() {
              showAdditionalOverlay = false;
            });
          }
          if (_animationController.status == AnimationStatus.completed) {
            //_animationController.reverse();
            appState.elementsAnimations[widget.index] = false;
          }
        });
      }
    } else {
      _animationController.stop();
    }

    ImageProvider<Object> imageWidgetFront;
    if (widget.gameMedia.coverImageUrl.isNotEmpty) {
      imageWidgetFront = FileImage(File(widget.gameMedia.coverImageUrl));
    } else {
      imageWidgetFront = const AssetImage('assets/images/noImage.png');
    }

    return Stack(children: [
      AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018) // Aplicar una perspectiva 3D
              ..rotateX(0.2) // Rotación en el eje x
              ..rotateY(widget.index == appState.clickedElementIndex &&
                      appState.elementsAnimations[widget.index]
                  ? _animationController.value * 3.45
                  : 0.4), // Rotación en el eje y (45 grados si el ratón está sobre el widget, 0 grados si no)
            child: Stack(
              children: [
                Image.asset(
                  'assets/models/PS2WII.png',
                  //color: Colors.red,
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 1,
                  fit: BoxFit.contain,
                ),
                Positioned.fill(
                  left: 0,
                  bottom: 0,
                  child: Transform.scale(
                    scale: 0.395,
                    child: Container(
                      height: 100,
                      width: 3000,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(8.0),
                        textColor: Colors.white,
                        splashColor: Colors.red,
                        elevation: 8.0,
                        onPressed: () {
                          widget.onGameClick(widget.game.id!);
                          GameMediaResponse gameMediaResponse =
                              GameMediaResponse.fromGameAndMedia(
                                  widget.game, widget.gameMedia);
                          createGameFromTitle(gameMediaResponse);
                        },
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(3, 2,
                                0.0018) // Aplicar una perspectiva 3D adicional a la imagen overlay
                            ..rotateX(
                                0) // Rotación en el eje x de la imagen overlay (15 grados si el ratón está sobre el widget, 0 grados si no)
                            ..rotateY(
                                0), // Rotación en el eje y de la imagen overlay (60 grados si el ratón está sobre el widget, 0 grados si no)
                          alignment: Alignment.center,
                          child: AspectRatio(
                            aspectRatio: 8.5 / 12,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageWidgetFront,
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Visibility(
                    visible: showAdditionalOverlay,
                    child: Transform.scale(
                      scale:
                          0.395, // Ajusta el tamaño del botón (50% en este ejemplo)
                      child: Container(
                        height: 100, //height of button
                        width:
                            3000, // Ancho deseado del botón (puedes ajustarlo según tus necesidades)
                        child: MaterialButton(
                          padding: const EdgeInsets.all(8.0),
                          textColor: Colors.white,
                          splashColor: Colors.red,
                          elevation: 8.0,
                          onPressed: () {},
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2,
                                  0.0018) // Aplicar una perspectiva 3D adicional a la imagen overlay
                              ..rotateX(
                                  0) // Rotación en el eje x de la imagen overlay (15 grados si el ratón está sobre el widget, 0 grados si no)
                              ..rotateY(
                                  pi), // Rotación en el eje y de la imagen overlay (60 grados si el ratón está sobre el widget, 0 grados si no)
                            alignment: Alignment.center,
                            child: AspectRatio(
                              aspectRatio: 8 / 12,
                              child: Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/backcover.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: SizedBox(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      appState.selectedOptions.showLogoNameOnGrid == 0
          ? Positioned(
              top: MediaQuery.of(context).size.width * 0.093,
              left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.05,
                child: Text(
                  widget.game.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 6.0,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            )
          : Positioned(
              bottom: MediaQuery.of(context).size.width * 0.02,
              left: MediaQuery.of(context).size.width * 0.05,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.03,
                height:MediaQuery.of(context).size.height * 0.03,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: logoWidgetMarquee,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
            ),
    ]);
  }
}
