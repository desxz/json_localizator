import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:translator/translator.dart';

Future<void> main() async {
  stdout.write("******************************************************\n");
  stdout.write("Welcome to Json Localizator\n");
  stdout.write("Created by desxz\n");
  stdout.write("******************************************************\n");
  stdout.write("Enter source json file path: ");
  final inputFilePath = stdin.readLineSync();
  stdout.write("Enter output folder path (Just folder): ");
  final outputFilePath = stdin.readLineSync();
  stdout.write("Enter source json file language: ");
  final sourceLanguage = stdin.readLineSync();
  stdout.write("Enter output json file languages: ");
  final translateLanguages = stdin.readLineSync();
  stdout.write("Json localization process continue...");
  File? myFile;
  final translator = GoogleTranslator();

  var translateLanguageList = translateLanguages!.split(' ');

  if (await File(inputFilePath!).exists()) {
    if (inputFilePath.endsWith('.json')) {
      myFile = File(inputFilePath);
    } else {
      stdout.write("File is not a json file");
    }
  } else {
    stdout.write('$inputFilePath is not exist.');
  }

  final jsonFileSource =
      myFile!.readAsString().then((data) => jsonDecode(data));

  Map<String, dynamic> jsonFileAsMap =
      await jsonFileSource as Map<String, dynamic>;

  Future<void> generateLocalizedJson(Map<String, dynamic> sourceJsonMap,
      String sourceLang, String translateLang, String outputPath) async {
    var file =
        File("$outputPath/$translateLang-${translateLang.toUpperCase()}.json");
    var sink = file.openWrite();
    Map<String, dynamic> localizedMap = {};
    final sourceJsonMapValues = sourceJsonMap.values.toList();
    final sourceJsonMapKeys = sourceJsonMap.keys.toList();

    for (var index = 0; index < sourceJsonMapKeys.length; index++) {
      if (sourceJsonMapValues[index] is String) {
        var translatedData = await translator.translate(
            sourceJsonMapValues[index],
            from: sourceLang,
            to: translateLang);

        var key = sourceJsonMapKeys[index];

        localizedMap[key] = translatedData.text;
      } else {
        var key = sourceJsonMapKeys[index];
        localizedMap[key] = sourceJsonMapValues[index];
      }
    }
    sink.write(jsonEncode(localizedMap));
  }

  for (var language in translateLanguageList) {
    await generateLocalizedJson(
        jsonFileAsMap, sourceLanguage!, language, outputFilePath!);
  }
  stdout.write("JSON localization process complated successfuly.\n");
}
