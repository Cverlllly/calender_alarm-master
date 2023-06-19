import 'dart:convert';
import 'package:calender_alarm/event_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:isolate';
import 'login.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  late StreamSubscription<DateTime> _subscription;
  late Isolate _isolate;
  late ReceivePort _receivePort;

  LoginPage lp = new LoginPage();

  void start() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_run, _receivePort.sendPort);
    _receivePort.listen((message) {
      if (message is List<Event>) {
        _events = message;
        for (var item in _events) {
          DateTime dateTime = DateTime.parse(item.from.toString());
          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
          bool isToday =
              formattedDate == DateFormat('yyyy-MM-dd').format(today);
          if (isToday) {
            int hours = dateTime.hour;
            int minutes = dateTime.minute;
            FlutterAlarmClock.createAlarm(hours, minutes,
                title: item.title.toString());
          }
        }
      }
    });
  }

  static void _run(SendPort sendPort) async {
    String idd = id.toString();
    try {
      final url = Uri.parse('http://10.0.2.2/GetAllDate.php?id=' + idd);
      final response = await http.get(url);
      print(response.body);
      final data = jsonDecode(response.body) as List<dynamic>;
      final events = data.map((item) => Event.fromJson(item)).toList();
      sendPort.send(events);
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void addEvent(Event event) {
    final data = {
      'date': event.from.toString(),
      'user_id': id.toString(),
      'title': event.title,
      'description': event.description
    };
    final url = Uri.parse('http://10.0.2.2/InsertDate.php');
    http
        .post(url, body: data)
        .then((response) => print(response.body))
        .catchError((error) => print(error));
    _events.add(event);
    notifyListeners();

    DateTime dateTime = DateTime.parse(event.from.toString());
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    bool isToday = formattedDate == DateFormat('yyyy-MM-dd').format(today);

    if (isToday) {
      print('Alarm set');
      int hours = dateTime.hour;
      int minutes = dateTime.minute;
      FlutterAlarmClock.createAlarm(hours, minutes);
    }
  }

  void deleteEvent(Event event) {
    final data = {
      'date': event.from.toString(),
      'cal_id': event.id.toString(),
      'title': event.title,
      'description': event.description
    };
    final url = Uri.parse('http://10.0.2.2/UpdateDate.php');
    http
        .post(url, body: data)
        .then((response) => print(response.body))
        .catchError((error) => print(error));

    _events.remove(event);
    notifyListeners();
  }

  void editEvent(Event newEvent, Event oldEvent) {
    final data = {
      'cal_id': oldEvent.id.toString(),
      'date': newEvent.from.toString(),
      'cal_id': newEvent.id.toString(),
      'title': newEvent.title,
      'description': newEvent.description,
      'user_id': id.toString(),
    };
    final url = Uri.parse('http://10.0.2.2/UpdateDate.php');
    http
        .post(url, body: data)
        .then((response) => print(response.body))
        .catchError((error) => print(error));

    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;
    notifyListeners();
  }
}
