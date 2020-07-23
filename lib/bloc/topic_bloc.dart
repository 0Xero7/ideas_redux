
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ideas_redux/bloc_events/topic_event.dart';
import 'package:ideas_redux/state/topic_state.dart';

class TopicBloc extends Bloc<TopicEvent, TopicState> {
  TopicBloc(TopicState initialState) : super(initialState) {
    initialState = TopicState();
  }

  @override
  Stream<TopicState> mapEventToState(TopicEvent event) async* {
    switch (event.type) {
      case TopicEventType.add:
        TopicState newState = TopicState.from(state);
        event.topic.id = Random.secure().nextInt(1000);
        
        newState.addTopic(event.topic);
        yield newState;
        break;
      
      case TopicEventType.delete:
        TopicState newState = TopicState.from(state);
        newState.deleteTopic(event.topic);
        yield newState;
        break;

      case TopicEventType.update:
        TopicState newState = TopicState.from(state);
        newState.updateTopic(event.topic);
        yield newState;
        break;

      default: 
        throw Exception('TopicEvent ${event.toString()} not found.');
    }
  }
  
}