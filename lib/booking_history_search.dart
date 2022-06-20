import 'package:flutter/material.dart';
import 'model/_model.dart';
import 'model/_booking.dart';
import 'model/_user.dart';
import 'booking_history.dart';
import '_config.dart';
import '_logging.dart';
import 'dart:async';

class BookingHistorySearch extends StatefulWidget {
  User user;

  BookingHistorySearch({required this.user, Key? key}) : super(key: key);

  @override
  _BookingHistorySearchState createState() => _BookingHistorySearchState();
}

class _BookingHistorySearchState extends State<BookingHistorySearch> {
  List<Booking>? bookings;
  Logging log = new Logging();
  User user = new User();

  @override
  void initState() {
    super.initState();
    getBookingHistory();
  }

  void getBookingHistory() async {
    Model model = new Model(log: log);
    bookings = await model.getBookingHistory(widget.user.getUserId());
    setState(() {});
  }

/*
 * getBookingRows()
 * Build row for each booking.
 * 
 * @param null
 * @return List<Widget>
 */
  List<Widget> getBookingRows() {
    List<Widget> widgetList = [];
    bookings?.forEach((booking) {
      widgetList.add(GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookingHistory(booking: booking)),
            ).then((data) {
              setState(() {});
            });
          },
          child: Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Time and State
                    Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Text(booking.getUserFriendlyDate() + " - "),
                          Text(booking.getStateNarration(),
                              style: TextStyle(fontWeight: FontWeight.bold))
                        ])),

                    //Source And Destination
                    Text(booking.source_name +
                        " -> " +
                        booking.destination_name),
                    Divider(),
                  ]))));
    });
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Config.COLOR_ACCENTCOLOR,
          title: const Text('Booking History'),
        ),
        body: Container(
            child: SingleChildScrollView(
                child: Column(children: [
          Column(children: getBookingRows()),
        ]))));
  }
}
