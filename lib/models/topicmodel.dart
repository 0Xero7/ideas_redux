class TopicModel {
  int id;
  String topicName;
  int order;

  TopicModel(this.id, this.topicName, this.order);

  factory TopicModel.fromMap(arg) => TopicModel(arg['id'], arg['name'], arg['order']);

  TopicModel withOrder(int order) => TopicModel(this.id, this.topicName, order);

  Map<String, dynamic> toMap() => { 'name': topicName, 'order': order };
}