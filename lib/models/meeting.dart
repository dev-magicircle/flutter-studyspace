import 'dart:ui';

class Meeting {
  Meeting(this.planetName, this.eventName, this.from, this.to, this.background, this.isAllDay);

  String planetName;
  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}