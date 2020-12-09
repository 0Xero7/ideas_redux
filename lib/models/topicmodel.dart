class TopicModel {
  int id;
  String topicName;
  int order;

  TopicModel(this.id, this.topicName, this.order);

  factory TopicModel.fromMap(arg) => TopicModel(arg['id'], arg['name'], arg['order']);

  Map<String, dynamic> toMap() => { 'name': topicName, 'order': order };
}