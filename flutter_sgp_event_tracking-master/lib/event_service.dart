import 'package:flutter_sgp_event_tracking/event.dart';
import 'package:flutter_sgp_event_tracking/flutter_sgp_event_tracking.dart';
import 'package:flutter_sgp_event_tracking/request_utils.dart';
import 'package:queue/queue.dart';
import 'package:rxdart/subjects.dart';

class EventService {
  static EventService? _instance;
  late ReplaySubject _eventQueue;
  final _requestQueue = Queue();

  EventService._internal() {
    _instance = this;
    _eventQueue = ReplaySubject<EventTracking>(sync: false, maxSize: 100);
    _startListen();
  }

  factory EventService() => _instance ?? EventService._internal();

  void _startListen() async {
    /// 开启事件订阅
    _eventQueue.stream.where((event) => event is EventTracking).cast<EventTracking>().listen((event) {
      /// 加入请求队列
      _requestQueue.add(() {
        final extra = {'appId': event.appId, 'appSecret': event.appSecret};
        return RequestUtils()
            .post(FlutterSgpEventTracking.apiHost, event.toMap(), extra)
            .then((res) => print(res))
            .catchError((error) {
          print(error);
        });
      });
    });
  }

  void addEvent(EventTracking event) {
    _eventQueue.add(event);
  }
}
