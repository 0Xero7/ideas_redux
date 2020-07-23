import 'package:ideas_redux/models/notemodel.dart';
import 'package:ideas_redux/models/topicmodel.dart';

class TestNoteData {

  static List<NoteModel> notes = [
    NoteModel.fromMap(
      {
        'title': 'Test Title',
        'id': 2,
        'data' : [
          {
            'type': 'text',
            'data': "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum",
          },
          {
            'type': 'checklist',
            'data': [
              {
                'checked': true,
                'data': 'test data'
              },
              {
                'checked': true,
                'data': 'test data'
              },
            ]
          },
        ]
      }
    )
  ];

  static List<TopicModel> topics = [
    TopicModel.fromMap({
      'id': 1,
      'name': 'Home'
    }),
    TopicModel.fromMap({
      'id': 2,
      'name': 'Work'
    }),
    TopicModel.fromMap({
      'id': 3,
      'name': 'Others'
    }),
  ];

}