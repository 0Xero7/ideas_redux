class TopicModel {
  int id;
  String topicName;

  TopicModel(this.id, this.topicName);

  factory TopicModel.fromMap(arg) => TopicModel(arg['id'], arg['name']);

  Map<String, dynamic> toMap() => { 'name': topicName };
}