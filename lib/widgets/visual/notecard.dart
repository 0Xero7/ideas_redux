import 'dart:math';
import 'package:ideas_redux/bloc/note_bloc.dart';
import 'package:ideas_redux/bloc_events/note_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/helpers/note_entry_decrypt_helper.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/state/selection_state.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  final NoteModel data;
  NoteCard(this.data);

  List<Widget> buildProtectedThumbnail(context) => [
    const SizedBox(height: 15),
    Opacity(
      child: Column(
        children: [
          Icon(Icons.lock),
          const SizedBox(height: 4),
          Text(
            'This note is protected',
            textAlign: TextAlign.center,
          )
        ],
      ),
      opacity: 0.6,
    ),
  ];

  // hard limit of 512 words
  List<Widget> buildThumbnail(context) {
    var res = List<Widget>();
    final int limit = 256;

    int count = 0;

    for (var i in data.data) {
      if (count >= limit) break;

      switch (i.runtimeType) {
        case TextDataModel:
          var limitedString = (i as TextDataModel).data.substring(0, min(limit - count, (i as TextDataModel).data.length));
          if (limitedString.length < (i as TextDataModel).data.length) limitedString += "...";
          
          count += limitedString.length;
          res.add(Text(
            limitedString,
            style: Theme.of(context).textTheme.subtitle2,
          ));
          break;

        case ChecklistModel:
          var t = (i as ChecklistModel);

          for (var x in t.data) {
            if (count >= limit) break;

            var limitedString = x.data.substring(0, min(limit - count, x.data.length));
            if (limitedString.length < x.data.length) limitedString += "...";

            res.add(Row(
              children: [
                Icon( x.checked ? Icons.check_box : Icons.check_box_outline_blank ),
                Text(limitedString)
              ],
            ));
          }

          break;
      }
    }
    
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectionState>(
      builder: (ctx, _state, _) => Material(
        color: Theme.of(context).bottomAppBarColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),

          side: BorderSide(
            color: _state.selecting && _state.contains(data.id) ? Colors.orange : Colors.black12, 
            width: 1
          )
        ),
        child: InkWell(
          onTap: () async {            
            if (!_state.selecting) {
              bool authed = false;

              if (data.protected) {
                var _local = LocalAuthentication();
                authed = await _local.authenticateWithBiometrics(
                  localizedReason: 'Unlock with a valid fingerprint',
                  androidAuthStrings: AndroidAuthMessages(
                    fingerprintHint: 'This note is protected',
                  )
                );
              }
              
              // decode encryptedData if note is protected
              if (authed || !data.protected) 
                await loadNoteEntryPage(context, data, '');

                // Navigator.pushNamed(context, '/editentry', arguments: data); 
              return; 
            }

            _state.toggleSelection(data.id);
          },
          onLongPress: () => _state.addToSelection(data.id),

          borderRadius: BorderRadius.circular(5),

          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Column(
              crossAxisAlignment: data.protected ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                Text('${data.title}', style: Theme.of(context).textTheme.headline6),
                const SizedBox(height: 5), 

                Column(
                  children: data.protected ? buildProtectedThumbnail(context) : buildThumbnail(context),
                )
              ],
            ),
          )
        ),
      ),
    );    
  }
}
