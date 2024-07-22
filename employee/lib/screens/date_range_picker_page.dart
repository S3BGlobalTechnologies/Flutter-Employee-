// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import 'adminscreen.dart';

// class DateRangePickerPage extends StatefulWidget {
//   final DateTimeRange? initialDateRange;

//   DateRangePickerPage({this.initialDateRange});

//   @override
//   _DateRangePickerPageState createState() => _DateRangePickerPageState();
// }

// class _DateRangePickerPageState extends State<DateRangePickerPage> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _selectedDay = DateTime.now();
//   DateTime? _startDate;
//   DateTime? _endDate;
  
//   @override
//   void initState() {
//     super.initState();
//     _startDate = widget.initialDateRange?.start;
//     _endDate = widget.initialDateRange?.end;
//   }

//   void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
//     setState(() {
//       _selectedDay = selectedDay;
//       if (_startDate == null) {
//         _startDate = selectedDay;
//       } else if (_endDate == null) {
//         _endDate = selectedDay;
//         if (_startDate!.isAfter(_endDate!)) {
//           final tempDate = _startDate;
//           _startDate = _endDate;
//           _endDate = tempDate;
//         }
//       } else {
//         _startDate = selectedDay;
//         _endDate = null;
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Select Date Range'),
//         backgroundColor: Colors.deepPurple,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TableCalendar(
//               // ... (Calendar configuration is similar to HolidayRequestPage)
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Selected Dates: ${_startDate != null ? DateFormat('dd MMM yyyy').format(_startDate!) : '-'} - ${_endDate != null ? DateFormat('dd MMM yyyy').format(_endDate!) : '-'}',
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(
//                     context,
//                     _startDate != null && _endDate != null
//                         ? DateTimeRange(
//                             start: _startDate!,
//                             end: _endDate!,
//                           )
//                         : null);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.deepPurple,
//                 padding: EdgeInsets.symmetric(vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//               ),
//               child: Text(
//                 'Save',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
