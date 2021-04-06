import 'package:flutter/cupertino.dart';
import 'package:ideas_redux/models/datamodels/basedatamodel.dart';
import 'package:ideas_redux/models/datamodels/checklistmodel.dart';
import 'package:ideas_redux/models/datamodels/imagedatamodel.dart';
import 'package:ideas_redux/models/datamodels/textdatamodel.dart';
import 'package:ideas_redux/models/notemodel.dart';

class NoteEditState {
  NoteModel model;

  List<List<TextEditingController>> editControllers;
  List<List<FocusNode>> focusNodes;

  int get length => model.data?.length ?? 0;
  List<BaseDataModel> get data => model.data;

  NoteEditState(this.model) {
    editControllers = [];
    focusNodes = [];

    for (var i in model.data)
      add(i);      
  }

  void add(BaseDataModel model) {
    switch (model.runtimeType) {
      case ImageDataModel:
        editControllers.add(null);
        focusNodes.add(null);
        break;
      
      case TextDataModel:
        var temp = model as TextDataModel;
        editControllers.add( [ TextEditingController(text: temp.data) ] );
        focusNodes.add( [ FocusNode() ] );
        break;

      case ChecklistModel:
        var temp = model as ChecklistModel;

        List<TextEditingController> _editControllers = [];
        List<FocusNode> _focusNodes = [];

        for (int i = 0; i < temp.data.length; ++i) {
          _editControllers.add( TextEditingController(text: temp.data[i].data) );
          _focusNodes.add( FocusNode() );
        }

        editControllers.add( _editControllers );
        focusNodes.add( _focusNodes );
        break;
    }
  }

  FocusNode addEmptyTextModel() {
    editControllers.add( [ TextEditingController() ] );
    focusNodes.add( [ FocusNode() ] );
    return focusNodes.last[0];
  }

  FocusNode addEmptyChecklist() {
    editControllers.add( [ TextEditingController() ] );
    focusNodes.add( [ FocusNode() ] );
    return focusNodes.last[0];
  }

  FocusNode addEmpty() {
    editControllers.add( [null] );
    focusNodes.add( [null] );
    return null;
  }
}