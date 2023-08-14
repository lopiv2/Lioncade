import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:synchronyx/models/media.dart';
import 'package:synchronyx/utilities/constants.dart';
import '../models/game.dart';
import 'package:synchronyx/utilities/generic_database_functions.dart'
    as databaseFunctions;

/* ------ Download and Save Image from URL, custom filename and folder ------ */
Future<void> downloadAndSaveImage(
    String imageUrl, String fileName, String folder) async {
  try {
    var response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      Directory appDocumentsDirectory =
          await getApplicationDocumentsDirectory();
      Directory imageFolder = Directory('${appDocumentsDirectory.path}$folder');

      // Create the directory if it doesn't exist
      if (!imageFolder.existsSync()) {
        imageFolder.createSync(recursive: true);
      }

      final file = File('${imageFolder.path}$fileName');
      await file.writeAsBytes(response.bodyBytes);
      print('Imagen guardada en: ${file.path}');
    } else {
      print('Error al descargar la imagen: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

/* ----------------- Generates a random alphanumeric string ----------------- */
String generateRandomAlphanumeric() {
  final random = Random();
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';

  String randomString = '';
  for (int i = 0; i < 6; i++) {
    int randomIndex = random.nextInt(characters.length);
    randomString += characters[randomIndex];
  }

  return randomString;
}
