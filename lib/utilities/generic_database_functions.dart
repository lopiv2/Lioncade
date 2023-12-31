import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lioncade/models/emulators.dart';
import 'package:lioncade/models/event.dart';
import 'package:lioncade/models/global_options.dart';
import 'package:lioncade/models/responses/gameMedia_response.dart';
import 'package:lioncade/models/media.dart';
import 'package:lioncade/models/themes.dart';
import 'package:lioncade/utilities/app_directory_singleton.dart';
import '../models/api.dart';
import 'package:lioncade/utilities/constants.dart';
import '../models/game.dart';
import 'generic_functions.dart';

/* -------------------------------------------------------------------------- */
/*                             DATABASE FUNCTIONS                             */
/* -------------------------------------------------------------------------- */

Future<Database?> openExistingDatabase() async {
  if (Constants.database != null) {
    print("existe");
    return Constants.database;
  }
  var databasesPath = await getDatabasesPath();
  String path = join(databasesPath, 'lioncade.db');
  var exists = await databaseExists(path);

  // Open database if not already open
  Constants.database = await openDatabase(path);

  return Constants.database;
}

Future<Database?> createAndOpenDB() async {
  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  var databasesPath = await getDatabasesPath();
  //Ruta: Lioncade\lioncade\.dart_tool\sqflite_common_ffi\databases
  String path = join(databasesPath, 'lioncade.db');
  var exists = await databaseExists(path);

  try {
    if (!exists) {
      await Directory(dirname(path)).create(recursive: true);

      var data =
          await rootBundle.load(join('assets/database/', 'lioncade.db'));
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(path).writeAsBytes(bytes, flush: true);
    }

    Constants.database = await openDatabase(
      path,
      onConfigure: (db) {
        // Here you can perform any additional database configuration before it is opened.
      },
      onCreate: (db, version) async {
        // Create the games table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS games('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'title TEXT,'
          'description TEXT,'
          'boxColor TEXT,'
          'mediaId INTEGER,'
          'platform TEXT,'
          'platformStore TEXT,'
          'genres TEXT,'
          'maxPlayers INTEGER,'
          'developer TEXT,'
          'publisher TEXT,'
          'region TEXT,'
          'file TEXT,'
          'releaseDate TEXT,'
          'rating REAL,'
          'favorite INTEGER,'
          'installed INTEGER,'
          'owned INTEGER,'
          'playTime INTEGER,'
          'lastPlayed TEXT,'
          'tags TEXT'
          ')',
        );
        // Create the apis table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS apis('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT,'
          'url TEXT,'
          'metadataJson TEXT'
          ')',
        );
        // Create the events table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS events('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT,'
          'game TEXT,'
          'image TEXT,'
          'dismissed INTEGER,'
          'releaseDate TEXT'
          ')',
        );
        // Create the Medias table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS medias('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT,'
          'coverImageUrl TEXT,'
          'backImageUrl TEXT,'
          'diskImageUrl TEXT,'
          'backgroundImageUrl TEXT,'
          'videoUrl TEXT,'
          'marqueeUrl TEXT,'
          'musicUrl TEXT,'
          'screenshots TEXT,'
          'iconUrl TEXT,'
          'logoUrl TEXT'
          ')',
        );
        // Create the Options table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS options('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'twoDThreeDCovers INTEGER,'
          'playOSTOnSelectGame INTEGER,'
          'showLogoNameOnGrid INTEGER,'
          'showEditorOnGrid INTEGER,'
          'logoAnimation TEXT,'
          'showBackgroundImageCalendar INTEGER,'
          'hoursAdvanceNotice INTEGER,'
          'imageBackgroundFile TEXT,'
          'selectedTheme TEXT'
          ')',
        );
        await db.insert(
          'options',
          {
            'twoDThreeDCovers': 1,
            'playOSTOnSelectGame': 1,
            'showLogoNameOnGrid': 0,
            'showEditorOnGrid': 1,
            'logoAnimation': 'FadeInDown',
            'showBackgroundImageCalendar': 0,
            'hoursAdvanceNotice': 48,
            'imageBackgroundFile': '',
            'selectedTheme': 'Slime World',
          },
        );
        // Create the Emulators table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS emulators('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT,'
          'url TEXT,'
          'systems TEXT,'
          'icon TEXT,'
          'description TEXT,'
          'installed INTEGER,'
          ')',
        );
        // Create the Themes table
        await db.execute(
          'CREATE TABLE IF NOT EXISTS themes('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT,'
          'sideBarColor TEXT,'
          'backgroundStartColor TEXT,'
          'backgroundMediumColor TEXT,'
          'backgroundEndColor TEXT,'
          'backendFont TEXT'
          ')',
        );
        await db.insert(
          'themes',
          {
            'name': 'Slime World',
            'sideBarColor': colorToHex(const Color.fromARGB(255, 56, 156, 75)),
            'backgroundStartColor': colorToHex(const Color.fromARGB(255, 33, 187, 115)),
            'backgroundMediumColor': colorToHex(const Color.fromARGB(255, 33, 109, 72)),
            'backgroundEndColor': colorToHex(const Color.fromARGB(255, 5, 148, 29)),
            'backendFont': 0,
          },
        );
      },
      version: 1,
    );
    return Constants.database;
  } catch (e) {
    print('Error al abrir la base de datos: $e');
    rethrow;
  }
}

/* -------------------------------------------------------------------------- */
/*                                GET FUNCTIONS                               */
/* -------------------------------------------------------------------------- */

/* ----------------------- Get all available emulators ---------------------- */
Future<List<Emulators>> getAllEmulators() async {
  // Get a reference to the database.
  final db = Constants.database;

  List<Map<String, dynamic>> maps = List.empty(growable: true);

  if (db != null) {
    // Query the table for all The Emulators.
    maps = await db.query('emulators');
  }

  return maps.map((map) => Emulators.fromMap(map)).toList();
}

/* ------- A method that retrieves all the events from the events table. ------ */
Future<List<Event>> getAllEvents() async {
  // Get a reference to the database.
  final db = Constants.database;

  List<Map<String, dynamic>> maps = List.empty(growable: true);

  if (db != null) {
    // Query the table for all The Events.
    maps = await db.query('events');
  }

  return maps.map((map) => Event.fromMap(map)).toList();
}

/* ------- A method that retrieves all the games from the games table. ------ */
Future<List<Game>> getAllGames() async {
  // Get a reference to the database.
  final db = Constants.database;

  List<Map<String, dynamic>> maps = List.empty(growable: true);

  if (db != null) {
    // Query the table for all The Games.
    maps = await db.query('games');
  }

  return maps.map((map) => Game.fromMap(map)).toList();
}

/* ------- A method that retrieves all the games filtered from the games table. ------ */
Future<List<Game>> getAllGamesWithFilter(String filter, String value) async {
  // Get a reference to the database.
  final db = Constants.database;
  List<Map<String, dynamic>> maps = List.empty(growable: true);
  if (db != null) {
    switch (filter) {
      case 'all':
        maps = await db.query('games');
        break;
      case 'favorite':
        if (value == 'yes') {
          maps = await db.query('games', where: 'favorite = ?', whereArgs: [1]);
        }
        if (value == 'no') {
          maps = await db.query('games', where: 'favorite = ?', whereArgs: [0]);
        }
        if (value == 'all') {
          maps = maps = await db.query('games');
        }
        break;
      case 'owned':
        if (value == 'yes') {
          maps = await db.query('games', where: 'owned = ?', whereArgs: [1]);
        }
        if (value == 'no') {
          maps = await db.query('games', where: 'owned = ?', whereArgs: [0]);
        }
        break;
      case 'search':
        if (value != '') {
          maps = await db
              .query('games', where: 'title LIKE ?', whereArgs: ['%$value%']);
        } else {
          maps = await db.query('games', where: 'owned = ?', whereArgs: [1]);
        }
        break;
      default:
        maps = await db.query('games');
    }
  }

  return maps.map((map) => Game.fromMap(map)).toList();
}

/* ------- A method that retrieves all the Themes from the themes table. ------ */
Future<List<Themes>> getAllThemes() async {
  // Get a reference to the database.
  final db = Constants.database;

  List<Map<String, dynamic>> maps = List.empty(growable: true);

  if (db != null) {
    // Query the table for all The Themes.
    maps = await db.query('themes');
  }

  return maps.map((map) => Themes.fromMap(map)).toList();
}

/* ---------------------------- Get event to dismiss --------------------------- */
Future<void> getEventAndDismiss(String name) async {
  // Verify if the database is open before continuing
  if (Constants.database != null) {
    await Constants.database?.update(
      'events',
      {'dismissed': 1}, // Valores a actualizar
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}

/* ------------------------- Get options from table ------------------------- */
Future<GlobalOptions?> getOptions() async {
  // Get a reference to the database.
  final db = Constants.database;

  GlobalOptions? options;

  if (db != null) {
    // Query the table for the first (and only) result.
    final List<Map<String, dynamic>> maps = await db.query(
      'options',
      limit: 1, // Limitar la consulta a un solo resultado.
    );

    // Si se encontró un resultado, convierte el mapa en un objeto GlobalOptions.
    if (maps.isNotEmpty) {
      options = GlobalOptions.fromMap(maps.first);
    }
  }

  return options;
}

/* ---------------------------- Check Api by name --------------------------- */
Future<Api?> checkApiByName(String name) async {
  //print('Base de datos abierta en:${Constants.database}');
  // Verify if the database is open before continuing
  if (Constants.database != null) {
    var apis = await Constants.database
        ?.query('apis', where: 'name = ?', whereArgs: [name]);
    if (apis!.isNotEmpty) {
      // Return the first API found (assuming 'name' is unique in the database)
      //print(apis.first);
      return Api.fromMap(apis.first);
    } else {
      return null; // Return null if no matching API is found
    }
  }
  return null;
}

/* ----------- Gets game from database with title parameter ---------- */
Future<Game?> getGameByTitle(String name) async {
  //print('Base de datos abierta en:${Constants.database}');
  // Verify if the database is open before continuing
  name = name.toLowerCase();
  if (Constants.database != null) {
    var game = await Constants.database
        ?.query('games', where: 'LOWER(title) = ?', whereArgs: [name]);
    if (game!.isNotEmpty) {
      // Return the first API found (assuming 'name' is unique in the database)
      return Game.fromMap(game.first);
    } else {
      return null; // Return null if no matching API is found
    }
  }
  return null;
}

/* ----------- Gets media record from database with name parameter ---------- */
Future<Media?> getMediaByName(String name) async {
  //print('Base de datos abierta en:${Constants.database}');
  // Verify if the database is open before continuing
  if (Constants.database != null) {
    var media = await Constants.database
        ?.query('medias', where: 'name = ?', whereArgs: [name]);
    if (media!.isNotEmpty) {
      // Return the first API found (assuming 'name' is unique in the database)
      //print(apis.first);
      return Media.fromMap(media.first);
    } else {
      return null; // Return null if no matching API is found
    }
  }
  return null;
}

/* ----------- Gets media record from database with id parameter ---------- */
Future<Media?> getMediaById(int id) async {
  // Verify if the database is open before continuing
  if (Constants.database != null) {
    var media = await Constants.database
        ?.query('medias', where: 'id = ?', whereArgs: [id]);
    if (media!.isNotEmpty) {
      return Media.fromMap(media.first);
    } else {
      return null; // Return null if no matching API is found
    }
  }
  return null;
}

Future<Themes?> getThemeByName(String name) async {
  final db = Constants.database;
  if (db != null) {
    final maps = await db.query(
      'themes',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (maps.isNotEmpty) {
      return Themes.fromMap(maps.first);
    }
  }
  return null; // Returns null if the subject is not found in the database.
}

/* -------------------------------------------------------------------------- */
/*                              DELETE FUNCTIONS                              */
/* -------------------------------------------------------------------------- */

/* ------------------- ///Deletes a game from the database ------------------ */
Future<void> deleteGame(int id) async {
  // Get a reference to the database.
  final db = await Constants.database;

  // Remove the Game from the database.
  await db!.delete(
    'games',
    // Use a `where` clause to delete a specific game.
    where: 'id = ?',
    // Pass the Game's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> deleteMediaByName(GameMediaResponse game) async {
  // Get a reference to the database.
  final db = Constants.database;
  deleteFile(game.media.coverImageUrl);
  deleteFile(game.media.backgroundImageUrl);
  deleteFile(game.media.marqueeUrl);
  deleteFile(game.media.logoUrl);
  deleteFile(game.media.iconUrl);
  //Deleting screenshots folder
  List<String> fileNames = game.media.screenshots.split(',');
  String id = fileNames[0].split('_')[0]; //Game ID according to Steam
  String folder = '\\Lioncade\\media\\screenshots\\$id\\';
  String aFolder = '\\Lioncade\\media\\audio\\$id\\';
  String screenFolder =
      '${AppDirectories.instance.appDocumentsDirectory.path}$folder';
  String audioFolder =
      '${AppDirectories.instance.appDocumentsDirectory.path}$aFolder';
  deleteDirectory(screenFolder);
  deleteDirectory(audioFolder);
  // Remove the Game from the database.
  await db!.delete(
    'medias',
    // Use a `where` clause to delete a specific game.
    where: 'name = ?',
    // Pass the Game's id as a whereArg to prevent SQL injection.
    whereArgs: [game.game.title],
  );
}

/* -------------------------------------------------------------------------- */
/*                              INSERT FUNCTIONS                              */
/* -------------------------------------------------------------------------- */

/* ---------------------- ///Inserts an API in database --------------------- */
Future<void> insertApi(Api api) async {
  //var database = await createAndOpenDB();
  await Constants.database?.insert(
    'apis',
    api.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );

  //await Constants.database?.close();
}

/* ---------------------- ///Inserts an Event in database --------------------- */
Future<void> insertEvent(Event event) async {
  //var database = await createAndOpenDB();
  await Constants.database?.insert(
    'events',
    event.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );

  //await Constants.database?.close();
}

/* ---------------------- Inserts a game in database --------------------- */
Future<void> insertGame(Game game) async {
  final db = Constants.database;

  // Verificar si el juego ya existe en la base de datos
  final existingGames = await db?.query(
    'games',
    where: 'title = ? AND platformStore = ?',
    whereArgs: [game.title, game.platformStore],
  );

  if (existingGames != null && existingGames.isNotEmpty) {
    // El juego ya existe en la base de datos, reemplazarlo
    await db?.update(
      'games',
      game.toMap(),
      where: 'title = ? AND platformStore = ?',
      whereArgs: [game.title, game.platformStore],
    );
  } else {
    // El juego no existe en la base de datos, agregarlo como nuevo registro
    await db?.insert(
      'games',
      game.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Opción ignore para evitar reemplazo
    );
  }
}

/* ------------------------ Inserts media in database ----------------------- */
Future<void> insertMedia(Media media, Game game) async {
  final db = Constants.database;

  // Verificar si el juego ya existe en la base de datos
  final existingGames = await db?.query(
    'games',
    where: 'title = ? AND platformStore = ?',
    whereArgs: [game.title, game.platformStore],
  );

  if (existingGames != null && existingGames.isNotEmpty) {
    //Obtengo el id de insercion para agregarselo al juego
    final id = await db?.insert(
      'medias',
      media.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await db?.update(
      'games',
      {'mediaId': id},
      where: 'title = ? AND platformStore = ?',
      whereArgs: [game.title, game.platformStore],
    );
  }
}

/* ---------------------- Inserts emulators in database --------------------- */
Future<void> insertEmulators(List<Emulators> emulatorsList) async {
  final db = Constants.database;

  for (var emulator in emulatorsList) {
    await db?.insert(
      'emulators',
      emulator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                              UPDATE FUNCTIONS                              */
/* -------------------------------------------------------------------------- */

/* ---------------------- ///Update a game in database by ID ---------------- */
Future<void> updateGameById(Game game) async {
  await Constants.database
      ?.update('games', game.toMap(), where: 'id = ?', whereArgs: [game.id]);

  // Now you can close the database after the update.
  //await Constants.database?.close();
}

/* ---------------------------- Favorites a game ---------------------------- */
Future<void> favoriteGameById(Game? game) async {
  bool favoriteState = convertIntBool(game?.favorite);
  favoriteState = !favoriteState;
  await Constants.database?.update(
    'games',
    {'favorite': convertBoolInt(favoriteState)},
    where: 'id = ?',
    whereArgs: [game?.id],
  );

  // Now you can close the database after the update.
  //await Constants.database?.close();
}

/* ---------------------- ///Update a game in database by ID ---------------- */
Future<void> updateGameByName(Game game) async {
  await Constants.database?.update('games', game.toMap(),
      where: 'title = ?', whereArgs: [game.title]);

  // Now you can close the database after the update.
  //await Constants.database?.close();
}

/* --------------------- Update audioUrl in Media Table --------------------- */
Future<void> updateOstInMedia(String audioName, int? id) async {
  await Constants.database?.update(
    'medias',
    {'musicUrl': audioName},
    where: 'id = ?',
    whereArgs: [id],
  );

  // Now you can close the database after the update.
  //await Constants.database?.close();
}

/* ----------------------------- Update Options ----------------------------- */
Future<void> updateOptions(GlobalOptions globalOptions) async {
  await Constants.database?.update('options', globalOptions.toMap(),
      where: 'id = ?', whereArgs: [globalOptions.id]);

  // Now you can close the database after the update.
  //await Constants.database?.close();
}
