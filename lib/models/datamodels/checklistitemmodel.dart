class ChecklistElementModel {
  bool checked;
  String data;

  ChecklistElementModel(this.checked, this.data);

  toMap() {
    return {
      'checked': checked ?? false,
      'data': data ?? ''
    };
  }

  factory ChecklistElementModel.fromMap(Map<String, dynamic> arg) {
    return ChecklistElementModel(arg['checked'] ?? false, arg['data'].toString());
  }
}