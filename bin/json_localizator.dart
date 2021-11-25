import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:translator/translator.dart';

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
  final translator = GoogleTranslator();

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

  // We will use the map function to get values of the json file
  // And then we will use the forEach function to translate each value
  Future<Map<String, dynamic>> jsonLocalizationFunction(List<String> keyList,
      List<dynamic> valueList, String sourceLang, String translateLang) async {
    // Define a new map to store the translated values
    Map<String, dynamic> localizedMap = {};

    // If translateLang string is valid and not empty
    // We will translate the values
    if (translateLang.length >= 2 && sourceLang.length >= 2) {
      // We will translate the values
      // And store the translated values in the new map
      // And then return the new map
      // We are visiting all the keys in the json file that we have converted to Map, one by one, with a fro loop.
      for (var index = 0; index < keyList.length; index++) {
        // If keyList[index] is a String
        // We will translate the value
        // And store the translated value in the new map
        if (valueList[index] is String) {
          var translatedData = await translator.translate(valueList[index],
              from: sourceLang, to: translateLang);

          var key = keyList[index];

          localizedMap[key] = translatedData.text;
          // If keyList[index] is a Map
          // We will call the function again (recursion)
          // And store the translated value in the new map
        } else if (valueList[index] is Map) {
          // Define new keyList and valueList
          final newMAP = valueList[index] as Map<String, dynamic>;
          final newMapValues = newMAP.values.toList();
          final newMapKeys = newMAP.keys.toList();

          var key = keyList[index];

          // Call the function again
          final newLocalizedMap = await jsonLocalizationFunction(
              newMapKeys, newMapValues, sourceLang, translateLang);

          // Store the translated value in the new map
          localizedMap[key] = newLocalizedMap;
        } else {
          // If keyList[index] is not a String or a Map
          // We don't need to translate it
          // So we will store the value in the new map directly
          var key = keyList[index];
          localizedMap[key] = valueList[index];
        }
      }
      // Return the new map
      return localizedMap;
    }
    // If translateLang string is not valid
    // We will return the empty map
    return {};
  }

  // Call the funtion to generate the localized json file
  // And open it to write
  IOSink? fileGenerator(String translateLang, String outputPath) {
    if (outputPath.length >= 2) {
      // Generate the file name
      // And open the file to write
      // Example:
      // outputPath = 'output'
      // translateLang = 'en'
      // output file path 'output/en-EN.json'.
      final file = File(
          "$outputPath/$translateLang-${translateLang.toUpperCase()}.json");
      final sink = file.openWrite();
      // Return the file to write
      return sink;
    }
    // If the outputPath is not valid
    // We will return null
    return null;
  }

  // Call the funtion to generate the localized json file
  // And write the translated values to the file
  // Using the jsonEncode function
  Future<void> generateLocalizedJson(Map<String, dynamic> sourceJsonMap,
      String sourceLang, String translateLang, String outputPath) async {
    // Call the function to generate the file
    final ioSink = fileGenerator(translateLang, outputPath);

    // If the ioSink is not null
    // If file is generated successfully
    if (ioSink != null) {
      // Define the keys and values of the converted json file
      // We will use the keys to translate the values
      final sourceJsonMapValues = sourceJsonMap.values.toList();
      final sourceJsonMapKeys = sourceJsonMap.keys.toList();

      // Call the function to translate the values
      final localizedMap = await jsonLocalizationFunction(
          sourceJsonMapKeys, sourceJsonMapValues, sourceLang, translateLang);

      // Write the translated values to the file
      // Using the jsonEncode function
      ioSink.write(jsonEncode(localizedMap));
    }
  }

  // For each language in the translateLanguageList
  // Call the funtion to generate the localized json file
  for (var language in translateLanguageList) {
    await generateLocalizedJson(
        jsonFileAsMap, sourceLanguage!, language, outputFilePath!);
  }
  // If the localization process ends successfully
  // We will show the use a success message
  stdout.write('JSON localization process completed successfully.\n');
}
