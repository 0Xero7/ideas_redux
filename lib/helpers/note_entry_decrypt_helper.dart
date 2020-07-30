import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ideas_redux/crypto/crypto.dart';
import 'package:ideas_redux/models/notemodel.dart';


// load note entry page after decoding if necessary
Future loadNoteEntryPage(BuildContext context, NoteModel model, String decodeToken) async {
  assert(model.encryptedData != null || model.data != null);

  if (model.protected) {
    FlutterSecureStorage secureStorage = FlutterSecureStorage();
    // load the key and iv
    String _key = await secureStorage.read(key: '${model.randomId}_key');
    String _iv = await secureStorage.read(key: '${model.randomId}_iv');


    var rawJson = decryptAES(model.encryptedData, _key, _iv);
    model.addDataFromList( jsonDecode(rawJson) );
    model.encryptedData = "";
  }

  Navigator.pushNamed(context, '/editentry', arguments: model);
}