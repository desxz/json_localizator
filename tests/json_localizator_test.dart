import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:translator/translator.dart';
import 'dart:io' as io;

import '../bin/json_localizator.dart';

Future<void> main() async {
  test('should json file localize', () async {
    final localizator = JsonLocalizator(GoogleTranslator());
    final sourceFile = io.File('tests/dummy-data/dummy-data.json');
    final expectedPath = 'tests/dummy-data/fr-FR.json';
    final jsonFileSource =
        sourceFile.readAsString().then((data) => jsonDecode(data));
    final jsonFileData = await jsonFileSource as Map<String, dynamic>;

    await localizator.generateLocalizedJson(
        jsonFileData, 'en', 'fr', 'tests/dummy-data');

    expect(true, await io.File(expectedPath).exists());
    expect(
        true,
        await io.File(expectedPath)
            .readAsString()
            .then((value) => value.isNotEmpty));
    await io.File(expectedPath).delete();
  });
}
