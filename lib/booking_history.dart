import 'package:flutter/material.dart';
import 'model/_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'model/_booking.dart';
import 'model/_user.dart';
import '_config.dart';
import '_logging.dart';
import 'dart:async';

class BookingHistory extends StatefulWidget {
  Booking booking;
  BookingHistory({required this.booking, Key? key}) : super(key: key);

  @override
  _BookingHistoryState createState() => _BookingHistoryState();
}

class _BookingHistoryState extends State<BookingHistory> {
  Logging log = new Logging();
  User user = new User();

  @override
  void initState() {
    super.initState();
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
    widget.booking.booking_history?.forEach((history_entry) {
      widgetList.add(Container(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //Time and State
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(widget.booking
                  .getStateNarration(state_id: history_entry["state"])),
            ),

            //Source And Destination
            Text(
                widget.booking.getUserFriendlyDate(
                    dateString: history_entry["date"].toString()),
                style: TextStyle(fontWeight: FontWeight.bold)),
            Divider(),
          ])));
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
          //Booking Summary
          Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(widget.booking.source_name,
                          style: TextStyle(color: Config.COLOR_MIDGRAY)),
                      Icon(Icons.arrow_right),
                      Text(widget.booking.destination_name,
                          style: TextStyle(color: Config.COLOR_MIDGRAY))
                    ]),
                    Text(widget.booking.getUserFriendlyDate())
                  ])),

          Divider(),

          //Driver Details
          widget.booking.driver_id != 0
              ? Container(
                  child: Column(children: [
                  Row(children: [
                    Container(
                        margin: EdgeInsets.all(10),
                        child: CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                NetworkImage('${widget.booking.profile_pic}'))),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text("Driver: ${widget.booking.driver_name}",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("${widget.booking.driver_vehicle}",
                              style: TextStyle(fontSize: 11)),
                          Text("${widget.booking.driver_number_plate}",
                              style: TextStyle(fontSize: 11)),
                          Text("Class: ${widget.booking.driver_vehicle_class}",
                              style: TextStyle(fontSize: 11)),
                        ])),
                    Expanded(
                        child: Column(
                      children: [
                        Text("Rating: ${widget.booking.driver_rating}",
                            style: TextStyle(fontSize: 10)),
                        Container(
                            margin: EdgeInsets.all(5),
                            child: RatingBar.builder(
                              initialRating: widget.booking.driver_rating ?? 0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 10.0,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            )),

                        //Call Icon

                        Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: Text(
                                widget.booking.driver_phone_number ?? "",
                                style: TextStyle(fontSize: 10))),
                        GestureDetector(
                            onTap: () async {
                              Uri _url = Uri.parse(
                                  "tel://${widget.booking.driver_phone_number}");
                              if (!await launchUrl(_url))
                                throw 'Could not launch $_url';
                            },
                            child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Icon(Icons.call, color: Colors.green),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green)))),
                      ],
                    )),
                  ])
                ]))
              : SizedBox.shrink(),
          widget.booking.driver_id != 0 ? Divider() : SizedBox.shrink(),
          Column(children: getBookingRows()),
        ]))));
  }
}
