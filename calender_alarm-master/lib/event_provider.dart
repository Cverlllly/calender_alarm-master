import 'dart:convert';
import 'package:calender_alarm/event_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  EventProvider() {
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(DateTime dateTime, String title) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test',
      'test',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      title,
      'Event reminder',
      tz.TZDateTime.from(dateTime, tz.local),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void addEvent(Event event) {
    final data = {
      'date': event.from.toString(),
      'user_id': '1',
      'title': event.title,
      'description': event.description
    };
    final url = Uri.parse('http://10.0.2.2/InsertDate.php');
    http
        .post(url, body: data)
        .then((response) => print(response.body))
        .catchError((error) => print(error));
    _events.add(event);
    scheduleNotification(event.from, event.title); // Schedule the notification
    notifyListeners();
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
      'description': newEvent.description
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

  Future<void> fetchEvents() async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2/GetAllDate.php'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      _events = data.map((e) => Event.fromJson(e)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to fetch events');
    }
  }
}
