
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/database/topicsdb.dart';
import 'package:ideas_redux/state/topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  TopicBloc(TopicState initialState) : super(initialState) {
    initialState = TopicState();
  }

  @override
  Stream<TopicState> mapEventToState(TopicEvent event) async* {
    switch (event.type) {
      case TopicEventType.add:
        await TopicsDB.addTopic(event.topic);

        TopicState newState = TopicState.from(state);
        
        newState.addTopic(event.topic);
        yield newState;
        break;
      
      case TopicEventType.delete:
        await TopicsDB.deleteTopicWithID(event.topidId);

        TopicState newState = TopicState.from(state);
        newState.deleteTopic(event.topidId);
        yield newState;
        break;

      case TopicEventType.update:
        await TopicsDB.updateTopic(event.topic);

        TopicState newState = TopicState.from(state);
        newState.updateTopic(event.topic);
        yield newState;
        break;

      default: 
        throw Exception('TopicEvent ${event.toString()} not found.');
    }
  }
  
}