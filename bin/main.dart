import 'dart:convert';
import 'dart:io';
import 'package:translator/translator.dart';

import 'json_localizator.dart';

Future<void> main() async {
  // This script is created to translate a json file from one language to another.
  // When using this script
  // You need to provide the source json file and it's path
  // An output folder to localized json files
  // The language you want to translate from
  // And the language you want to translate to.

  // Take the necessary arguments
  // From user in the terminal

  // Get the source file json path
  stdout.write("Enter source json file path: ");
  final inputFilePath = stdin.readLineSync();

  // Get the output folder path
  stdout.write("Enter output folder path (Just folder): ");
  final outputFilePath = stdin.readLineSync();

  // Get the language you want to translate from
  stdout.write("Enter source json file language: ");
  final sourceLanguage = stdin.readLineSync();

  // Get the language you want to translate to
  stdout.write("Enter output json file languages: ");
  final translateLanguages = stdin.readLineSync();
  stdout.write("Json localization process continue...\n");

  // Define a file reading and writing operations
  File? myFile;

  // Our translator function
  // It's translator package from Pub.dev
  // It is basicly using the Google Translate API
  // But don't need to worry about the API key
  // It is just a simple function to use it.
  // https://github.com/gabrielpacheco23/google-translator
  // https://pub.dev/packages/translator
  final translator = JsonLocalizator(GoogleTranslator());

  // Split output languages and convert it to a list
  var translateLanguageList = translateLanguages!.split(' ');

  // Checking if the file exists
  // Checking if the file is a json file
  if (await File(inputFilePath!).exists()) {
    if (inputFilePath.endsWith('.json')) {
      myFile = File(inputFilePath);
    } else {
      // If the file is not a json file
      // We will exit the program
      // And show the use an error message
      stdout.write("The file is not a json file\n");
    }
  } else {
    // If the file doesn't exist
    // We will exit the program
    // And show the use an error message
    stdout.write('$inputFilePath is not exist\n');
  }

  // If the file is exist
  // We will read the file in here with the jsonDecode function
  final jsonFileSource =
      myFile!.readAsString().then((data) => jsonDecode(data));

  // Cast the jsonFileSource to Map<String, dynamic>
  // Because the jsonFileSource is a Future<dynamic>
  // We need to cast it to Map<String, dynamic>
  // So we can use the map function
  final jsonFileAsMap = await jsonFileSource as Map<String, dynamic>;

  // For each language in the translateLanguageList
  // Call the funtion to generate the localized json file
  for (var language in translateLanguageList) {
    await translator.generateLocalizedJson(
        jsonFileAsMap, sourceLanguage!, language, outputFilePath!);
  }
  // If the localization process ends successfully
  // We will show the use a success message
  stdout.write('JSON localization process completed successfully.\n');
}
