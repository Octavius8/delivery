import '../_config.dart';
import 'package:intl/intl.dart';
import '../_logging.dart';
import 'dart:convert';

class Booking {
  Logging log = new Logging();

  //Basic booking info
  int booking_id;
  int booking_state;
  String? booking_state_description;
  double? price;
  //Source
  int source_id;
  String source_name;
  String? source_street;
  double source_longtitude;
  double source_latitude;
  //Destination
  int destination_id;
  String destination_name;
  String? destination_street;
  double destination_longtitude;
  double destination_latitude;
  //Driver
  int? driver_id;
  String? driver_name;
  double? driver_rating;
  String? driver_vehicle;
  String? driver_number_plate;
  String? driver_vehicle_class;
  String? profile_pic;
  String? scheduled_date;
  String? driver_phone_number;
  List<dynamic>? booking_history;

  Booking(
      this.booking_id,
      this.booking_state,
      this.source_id,
      this.source_name,
      this.source_street,
      this.source_longtitude,
      this.source_latitude,
      this.destination_id,
      this.destination_name,
      this.destination_street,
      this.destination_longtitude,
      this.destination_latitude,
      this.driver_id,
      this.driver_name,
      this.driver_rating,
      this.driver_vehicle,
      this.driver_number_plate,
      this.driver_vehicle_class,
      this.driver_phone_number,
      this.profile_pic,
      this.scheduled_date,
      this.booking_state_description,
      this.booking_history);
//Booking({required this.booking_id, required this.booking_state});

  Booking.fromJson(Map<String, dynamic> json)
      : booking_id = int.parse(json['booking_id']),
        booking_state = int.parse(json['state_id']),
        source_id = int.parse(json['source_id']),
        source_name = json['source_name'],
        source_street = json['source_street'],
        source_longtitude = double.parse(json['source_longtitude']),
        source_latitude = double.parse(json['source_latitude']),
        destination_id = int.parse(json['destination_id']),
        destination_name = json['destination_name'],
        destination_street = json['destination_street'],
        destination_longtitude = double.parse(json['destination_longtitude']),
        destination_latitude = double.parse(json['destination_latitude']),
        driver_id = int.parse(json['driver_id'] ?? "0"),
        driver_name = json['full_name'] ?? "",
        driver_rating = double.parse(json['driver_rating'] ?? "0"),
        driver_vehicle = json['driver_vehicle'] ?? "",
        driver_number_plate = json['driver_number_plate'] ?? "",
        driver_vehicle_class = json['driver_vehicle_class'] ?? "",
        driver_phone_number = json['driver_phone_number'] ?? "",
        profile_pic = json['profile_pic'] ?? "",
        scheduled_date = json['scheduled_date'],
        booking_state_description = "",
        price = double.parse(json['price']),
        booking_history = jsonDecode(json['booking_history']);

  String getStateNarration({int state_id = 666}) {
    if (state_id == 666) state_id = this.booking_state;
    String state = "";

    if (state_id == Config.BOOKING_PENDING)
      state = Config.BOOKING_PENDING_NARRATION;
    if (state_id == Config.BOOKING_ASSIGNED)
      state = Config.BOOKING_ASSIGNED_NARRATION;
    if (state_id == Config.BOOKING_ACTIVE)
      state = Config.BOOKING_ACTIVE_NARRATION;
    if (state_id == Config.BOOKING_ARRIVED)
      state = Config.BOOKING_ARRIVED_NARRATION;
    if (state_id == Config.BOOKING_INPROGRESS)
      state = Config.BOOKING_INPROGRESS_NARRATION;
    if (state_id == Config.BOOKING_ENDED)
      state = Config.BOOKING_TRIPEND_NARRATION;
    if (state_id == Config.BOOKING_COMPLETE)
      state = Config.BOOKING_COMPLETE_NARRATION;
    if (state_id == Config.BOOKING_CANCELLED)
      state = Config.BOOKING_CANCELLED_NARRATION;

    return state;
  }

/*
   * displayEntryScreen()
   * Changes current app state to display the default entry screen
   * 
   * @param null
   * @return null
  */
  String getUserFriendlyDate({String dateString = ""}) {
    if (dateString == "") dateString = this.scheduled_date ?? "";
    log.debug(
        "Booking | getUserFriendlyScheduledDate | Scheduled Date ${this.scheduled_date}");

    DateTime dateObject = DateTime.parse(dateString);
    String formattedDate =
        DateFormat("EEE, d MMM yyyy, hh:mm").format(dateObject);
    //String formattedDate = DateFormat.yMMMEd().format(dateObject);
    return formattedDate;
  }
}
