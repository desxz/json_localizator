import 'dart:convert';

import 'package:test/test.dart';
import 'dart:io';

import 'package:translator/translator.dart';

Future<void> main() async {
  test('Source file path should be a json file', () async {
    final inputFilePath = 'assets/json/tr-TR.json';
    expect(inputFilePath.endsWith('.json'), equals(true));
  });

  test('Source file should exist', () {
    final file = File(
        'D:/FlutterNullSafetyProject/json_localizator/assets/json/en-EN.json');

    expect(file.isAbsolute, equals(true));
  });

  test('Json file should translate', () async {
    Map<String, dynamic> testMap = {
      "Hello": "Merhaba",
      "Welcome": "Hoşgeldiniz",
    };

    final API = GoogleTranslator();
    final testMapKeys = testMap.keys.toList();
    final testMapValues = testMap.values.toList();

    var newMap = {};

    for (var i = 0; i < testMap.length; i++) {
      var translation =
          await API.translate(testMapValues[i], from: 'tr', to: 'en');
      newMap[testMapKeys[i]] = translation.text;
    }

    expect(newMap.isNotEmpty, equals(true));
    expect(testMap != newMap, equals(true));
  });
}
