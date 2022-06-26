import 'package:flutter/material.dart';
import 'model/_model.dart';
import 'model/_booking.dart';
import 'model/_user.dart';
import '_logging.dart';
import 'dart:async';

class OrderHistory extends StatefulWidget {
  OrderHistory({Key? key}) : super(key: key);

  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
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
    bookings = await model.getBookingHistory(user.getUserId());
  }

  List<Row> getBookingRows() {
    List<Row> rowList = [];
    bookings?.forEach((booking) {
      rowList.add(Row(children: [
        Text(booking.scheduled_date ?? ""),
        Text(booking.source_name + "->" + booking.destination_name),
        Text(booking.getStateNarration()),
      ]));
    });
    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Booking History'),
        ),
        body: Container(
            child: Column(children: [
          Text("Booking History"),
          Column(children: getBookingRows()),
        ])));
  }
}
