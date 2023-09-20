import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronyx/models/global_options.dart';
import 'package:synchronyx/models/responses/rawg_response.dart';
import 'package:synchronyx/providers/app_state.dart';
import 'package:synchronyx/utilities/audio_singleton.dart';
import 'package:synchronyx/utilities/generic_database_functions.dart'
    as database;
import 'package:synchronyx/utilities/generic_database_functions.dart';
import 'package:synchronyx/widgets/filter_info_panel.dart';
import 'package:synchronyx/widgets/filters/favorite_filter.dart';
import 'package:synchronyx/widgets/game_info_panel.dart';
import 'package:synchronyx/widgets/game_search_results_list.dart';
import 'package:synchronyx/widgets/grid_view_game_covers_wish.dart';
import 'package:synchronyx/widgets/platform_tree_view.dart';
import 'package:synchronyx/widgets/top_menu_bar.dart';
import 'widgets/buttons/arcade_box_button.dart';
import 'widgets/drop_down_filter_order_games.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:synchronyx/utilities/constants.dart';
import 'widgets/grid_view_game_covers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:synchronyx/utilities/generic_api_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Constants.initialize().then((_) {
    runApp(MultiProvider(providers: [
      //ChangeNotifierProvider(create: (_) => TrackListState()),
      ChangeNotifierProvider(create: (_) => AppState()),
    ], child: MyApp()));

    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(1024, 768);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Synchronyx";
      win.show();
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, // Esta línea elimina el banner de depuración
      title: 'Synchronyx Game Launcher',
      localizationsDelegates:
          AppLocalizations.localizationsDelegates, // Cambio aquí
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: MainGrid(context: context),
      ),
    );
  }
}

class MainGrid extends StatelessWidget {
  final BuildContext context;

  const MainGrid({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);
    final appState = Provider.of<AppState>(context);
    final AudioManager audioManager = AudioManager();
    if (appState.selectedGame == null) {
      audioManager.stop();
    }
    return Container(
      color: Constants.SIDE_BAR_COLOR,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyMenuBar(appLocalizations: appLocalizations),
              Expanded(
                flex: 2,
                child: WindowTitleBarBox(
                  child: MoveWindow(),
                ),
              ),
              const Expanded(
                flex: 1,
                child: Center(
                  // Usamos Center para centrar el ArcadeBoxButtonWidget vertical y horizontalmente
                  child: ArcadeBoxButtonWidget(),
                ),
              ),
              const WindowButtons(),
            ],
          ),
          Expanded(
            // Utiliza Expanded aquí para que el Column ocupe todo el espacio vertical disponible
            child: Row(
              children: [
                LeftSide(appLocalizations: appLocalizations),
                const CenterSide(),
                RightSide(appLocalizations: appLocalizations),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LeftSide extends StatefulWidget {
  final AppLocalizations appLocalizations;

  LeftSide({Key? key, required this.appLocalizations}) : super(key: key);

  @override
  _LeftSideState createState() => _LeftSideState();
}

class _LeftSideState extends State<LeftSide> {
  SearchParametersDropDown? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.18,
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 2, 34, 14), // Color del borde
            width: 0.2, // Ancho del borde
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Constants.SIDE_BAR_COLOR,
              Color.fromARGB(255, 33, 109, 72),
              Color.fromARGB(255, 48, 87, 3)
            ],
          ),
        ),
        child: Consumer<AppState>(builder: (context, appState, child) {
          return Column(children: [
            //Padding(padding: EdgeInsets.only(top: 10.0)),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            Container(
              height: 30,
              child: Row(
                children: <Widget>[
                  const SizedBox(width: 10), // give it width
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                      filled: true,
                      fillColor: const Color.fromARGB(127, 11, 129, 46),
                      border: const OutlineInputBorder(),
                      hintText: appState.searchGameEnabled
                          ? widget.appLocalizations.searchInternet
                          : widget.appLocalizations.searchLibrary,
                    ),
                    style: TextStyle(fontSize: 14),
                    onSubmitted: (String searchString) async {
                      if (appState.searchGameEnabled) {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Evita que el usuario cierre el diálogo
                          builder: (BuildContext context) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                        List<RawgResponse> responses = [];
                        final dio = DioClient();
                        responses = await dio.searchGamesRawg(
                            key: '68239c29cb2c49f2acfddf9703077032',
                            searchString: searchString);
                        Navigator.of(context).pop(); // Cierra el diálogo
                        if (responses.isNotEmpty) {
                          appState.showResults(responses, true);
                        } else {
                          Text("No results");
                        }
                      }
                    },
                  )),
                  SizedBox(width: 10),
                ],
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 20.0)),
            Visibility(
              visible: appState.searchGameEnabled == false,
              child: DropdownWidget(
                onChanged: (newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
              ),
            ),
            Visibility(
                visible: appState.searchGameEnabled && appState.resultsEnabled,
                child: RawgResponseListWidget(
                  rawgResponses: appState.results,
                )),
            Expanded(
              child: _buildWidgetBasedOnSelectedValue(
                  Provider.of<AppState>(context)),
            ),
            /*Container(
              height: 50, // Altura del contenedor ámbar
              color: const Color.fromARGB(101, 76, 175, 79), // Color ámbar
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Descargas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),*/
          ]);
        }));
  }

  Widget _buildWidgetBasedOnSelectedValue(AppState appState) {
    switch (selectedValue?.caseValue) {
      case 'categoryPlatform':
        return PlatformTreeView(appLocalizations: widget.appLocalizations);
      case 'favorite':
        return FavoriteFilterColumn(appLocalizations: widget.appLocalizations);
      case 'OtherCase2':
        return Text("otro2"); // Cambia YourWidget2 por el widget deseado
      // Agrega más casos según tus necesidades
      default:
        return Text(
            ""); // Cambia YourDefaultWidget por el widget predeterminado
    }
  }
}

class CenterSide extends StatefulWidget {
  const CenterSide({Key? key}) : super(key: key);

  @override
  _CenterSideState createState() => _CenterSideState();
}

class _CenterSideState extends State<CenterSide>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _previousTabIndex = 0;

  void _handleTabSelection() {
    final appState = Provider.of<AppState>(context, listen: false);

    if (_tabController.index != _previousTabIndex) {
      // Verifica si el índice ha cambiado
      _previousTabIndex = _tabController.index; // Actualiza el índice anterior

      if (_tabController.index == 0) {
        appState.toggleGameSearch(false);
        print('Pestaña seleccionada: Biblioteca');
      } else if (_tabController.index == 1) {
        appState.toggleGameSearch(true);
        print('Pestaña seleccionada: Lista');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // 2 tabs (library and list)
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return FutureBuilder<Database?>(
      future: database.createAndOpenDB(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.data == null) {
          return Text('La base de datos no se inicializó correctamente.');
        } else {
          Constants.database = snapshot.data;
          Future<GlobalOptions?> optionsFuture = getOptions().then((value) {
            if (value != null) {
              appState.selectedOptions = value;
              appState.optionsResponse = GlobalOptions.copy(value);
            }
          });

          return Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Constants.BACKGROUND_START_COLOR,
                    Constants.BACKGROUND_END_COLOR,
                    Color.fromARGB(255, 48, 87, 3)
                  ],
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'Biblioteca'),
                      Tab(text: 'Lista'),
                    ],
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                          width: 4.0,
                          color: Colors.blue), // Grosor y color del indicador
                      insets: EdgeInsets.symmetric(
                          horizontal: 16.0), // Ancho del indicador
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Consumer<AppState>(
                          builder: (context, appState, child) {
                            return GridViewGameCovers(); // Contenido de la pestaña 'Biblioteca'
                          },
                        ),
                        Consumer<AppState>(
                          builder: (context, appState, child) {
                            return GridViewGameCoversWished(); // Contenido de la pestaña 'Biblioteca'
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

class RightSide extends StatefulWidget {
  final AppLocalizations appLocalizations;
  RightSide({Key? key, required this.appLocalizations}) : super(key: key);

  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.28,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 2, 34, 14), // Color del borde
          width: 0.2, // Ancho del borde
        ),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Constants.SIDE_BAR_COLOR,
            Color.fromARGB(255, 33, 109, 72),
            Color.fromARGB(255, 48, 87, 3)
          ],
        ),
      ),
      child: provider.Consumer<AppState>(
        builder: (context, appState, child) {
          return appState.selectedGame != null
              ? GameInfoPanel(
                  appLocalizations: widget.appLocalizations,
                )
              : FilterInfoPanel(appLocalizations: widget.appLocalizations);
        },
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      MinimizeWindowButton(),
      MaximizeWindowButton(),
      CloseWindowButton()
    ]);
  }
}
