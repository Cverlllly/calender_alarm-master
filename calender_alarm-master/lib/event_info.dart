import 'package:flutter/material.dart';

class Event {
  final int id;
  final String title;
  final String description;
  final DateTime from;
  final Color backgroundColor;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.from,
    required this.backgroundColor,
  });
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['cal_id'],
      title: json['title'],
      from: DateTime.parse(json['date']),
      description: json['description'],
      backgroundColor: Colors.green,
    );
  }
}
