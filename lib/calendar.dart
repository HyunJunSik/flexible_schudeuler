import 'dart:math' as math;
import 'todo.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class calendar extends StatelessWidget {
  final List<dynamic> todos;
  const calendar(this.todos);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SfCalendar(
      view: CalendarView.month,
      firstDayOfWeek: 6,
      initialDisplayDate: DateTime.now(),
      initialSelectedDate: DateTime.now(),
      todayHighlightColor: Colors.black,
      cellBorderColor: Colors.transparent,
      appointmentTextStyle: TextStyle(
        fontSize: 10,
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      dataSource: MeetingDateSource(getAppointment()),
      backgroundColor: Colors.blueGrey,
      monthViewSettings: MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        showAgenda: true,
        agendaItemHeight: 60,
        agendaStyle: AgendaStyle(backgroundColor: Colors.indigo),
      ),
    ));
  }

  List<Appointment> getAppointment() {
    List<Appointment> meetings = <Appointment>[];
    for (Todo t in todos) {
      meetings.add(Appointment(
        startTime: t.from,
        endTime: t.to,
        subject: t.title,
        color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
            .withOpacity(1.0),
      ));
    }
    return meetings;
  }
}

class MeetingDateSource extends CalendarDataSource {
  MeetingDateSource(List<Appointment> source) {
    appointments = source;
  }
}
