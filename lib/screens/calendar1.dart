import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_core/core.dart';
import '../models/meeting.dart';



class calendar1 extends StatefulWidget {
  calendar1({Key key, this.meetings}) : super(key: key);
  List<Meeting> meetings;
  @override
  _calendar1State createState() => _calendar1State(meetings:meetings);
}

class _calendar1State extends State<calendar1>  with TickerProviderStateMixin {
  _calendar1State({this.meetings});
  List<Meeting> meetings;
  final FirebaseAuth _auth = FirebaseAuth.instance;//firebase인증

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Hexcolor('#205A79'),
          title: Text('복습 일정', style: TextStyle(fontSize: 14.0)),
          centerTitle: true,
          actions: [
//                IconButton(icon: Icon(Icons.alarm_on), onPressed: null),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
               // Navigator.push(
                 // context,
                 // MaterialPageRoute(builder: (context) => (MyPage())),
               // );
              },
            )
          ],
        ),
        body: SfCalendar(
          //onTap: print('d'),
          view: CalendarView.schedule,
          dataSource: MeetingDataSource(meetings),
          // by default the month appointment display mode set as Indicator, we can
          // change the display mode as appointment using the appointment display mode
          // property
          monthViewSettings: MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        ));
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments[index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments[index].to;
  }

  @override
  String getSubject(int index) {
    return appointments[index].eventName;
  }
  @override
  String getLocation(int index) {
    return appointments[index].planetName;
  }

  @override
  Color getColor(int index) {
    return appointments[index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].isAllDay;
  }
}

/*class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}*/