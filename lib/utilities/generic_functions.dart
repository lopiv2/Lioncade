import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'Constants.dart';

/* ------------------------- Delete a file per name ------------------------- */
Future<void> deleteFile(String fileName) async {
  try {
    final file = File(fileName);
    if (await file.exists()) {
      await file.delete();
      //print('Archivo $fileName eliminado correctamente.');
    } else {
      print('El archivo $fileName no existe.');
    }
  } catch (e) {
    print('Error al eliminar el archivo: $e');
  }
}

/* ----------------------- Check if asset loads or not ---------------------- */
Future<void> checkAssetLoading(String assetPath) async {
  //const assetPath = 'assets/image.png'; // Reemplaza con la ruta de tu asset

  try {
    // Intenta cargar el asset utilizando el método rootBundle.load
    final ByteData data = await rootBundle.load(assetPath);
    if (data.buffer.asUint8List().isEmpty) {
      print('El asset no se cargó correctamente.');
    } else {
      print('El asset se cargó correctamente.');
    }
  } catch (error) {
    print('Error al cargar el asset: $error');
  }
}

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
      //print('Imagen guardada en: ${file.path}');
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

String getTranslatedValue(
    SearchParametersDropDown parameter, BuildContext context) {
  switch (parameter) {
    case SearchParametersDropDown.AddDate:
      return AppLocalizations.of(context)?.addDate ?? 'AddDate';
    case SearchParametersDropDown.Developer:
      return AppLocalizations.of(context)?.developer ?? 'Max Players';
    case SearchParametersDropDown.Favorite:
      return AppLocalizations.of(context)?.favorite ?? 'Favorite';
    default:
      return '';
  }
}

String getTranslatedValueFromKey(String key, BuildContext context) {
  final keyWithoutPrefix =
      key.split('.').last; // Esto quita el prefijo del enum
  switch (keyWithoutPrefix) {
    case 'AddDate':
      return AppLocalizations.of(context)?.addDate ?? 'AddDate';
    case 'Developer':
      return AppLocalizations.of(context)?.developer ?? 'Max Players';
    case 'Favorite':
      return AppLocalizations.of(context)?.favorite ?? 'Favorite';
    // Agrega los casos restantes para los otros valores del enum
    default:
      return '';
  }
}