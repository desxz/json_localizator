import 'dart:convert';
import 'dart:io';

import 'package:translator/translator.dart';

abstract class Localizator {
  final GoogleTranslator translator;

  Localizator(this.translator);

  Future<Map<String, dynamic>> localizeJson(List<String> keyList,
      List<dynamic> valueList, String sourceLang, String translateLang);
  IOSink? createFile(String translateLang, String outputPath);
  Future<void> generateLocalizedJson(Map<String, dynamic> sourceJsonMap,
      String sourceLang, String translateLang, String outputPath);
}

class JsonLocalizator extends Localizator {
  JsonLocalizator(GoogleTranslator translator) : super(translator);

// We will use the map function to get values of the json file
  // And then we will use the forEach function to translate each value
  @override
  Future<Map<String, dynamic>> localizeJson(List<String> keyList,
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
          final newLocalizedMap = await localizeJson(
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
  @override
  IOSink? createFile(String translateLang, String outputPath) {
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
    final ioSink = createFile(translateLang, outputPath);

    // If the ioSink is not null
    // If file is generated successfully
    if (ioSink != null) {
      // Define the keys and values of the converted json file
      // We will use the keys to translate the values
      final sourceJsonMapValues = sourceJsonMap.values.toList();
      final sourceJsonMapKeys = sourceJsonMap.keys.toList();

      // Call the function to translate the values
      final localizedMap = await localizeJson(
          sourceJsonMapKeys, sourceJsonMapValues, sourceLang, translateLang);

      // Write the translated values to the file
      // Using the jsonEncode function
      ioSink.write(jsonEncode(localizedMap));
    }
  }
}
