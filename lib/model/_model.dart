import 'package:flutter/foundation.dart';
import '_booking.dart';
import '_stop.dart';
import 'dart:convert';
import 'dart:async';
import '../_logging.dart';
import '../_config.dart';
import 'package:http/http.dart' as http;
import '_user.dart';

class Model {
  Logging log;
  User user = new User();
  Model({required this.log});

/*
 * getBooking()
 * Get booking information from the server and return a bookinb object
 *
 * @param booking_id the ID of the booking entry .
 * @return Booking
*/
  Future<Booking?> getBooking(int booking_id) async {
    Booking? booking;
    try {
      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'booking_id': booking_id.toString(),
          'method': 'getBooking'
        }),
      );

      log.info("Model | getBooking() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);

      booking = Booking.fromJson(responseMap["data"]);
      log.info(
          "Model | getBooking() | created booking object. ${booking.source_name} -> ${booking.destination_name}");
    } catch (ex) {
      log.error("Model | getBooking() | ERROR |" + ex.toString());
    }
    return booking;
  }

//Get Price between two points
  Future<String> getPrice(
      int source_id, int destination_id, String scheduledDate) async {
    String price = "";
    try {
      String payload = jsonEncode(<String, String>{
        'source_id': source_id.toString(),
        'destination_id': destination_id.toString(),
        'scheduled_date': scheduledDate,
        'method': 'getPrice'
      });
      log.info("Model | getPrice() | Payload is :" + payload);
      var response = await http.post(Uri.parse(Config.API_URL),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: payload);

      log.info("Model | getPrice() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);

      price = responseMap["data"]["price"].toString();
      log.info("Model | getPrice() | received Price. ${price}");
    } catch (ex) {
      log.error("Model | getPrice() | ERROR |" + ex.toString());
    }
    return price;
  }

  Future<List<Booking>> getActiveBookings(String user_id) async {
    List<Booking> bookings = [];
    try {
      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'user_id': user_id,
          'method': 'getActiveBookings'
        }),
      );

      log.info("Model | getBookings() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      log.info("Model | getBookings() | data size is " +
          responseMap["data"].length.toString());

      responseMap["data"].forEach((value) {
        Booking booking = Booking.fromJson(value);
        log.info(
            "Model | getBookings() | created booking object. ${booking.source_name} -> ${booking.destination_name}");
        bookings.add(booking);
      });
    } catch (ex) {
      log.error("Model | getBookings() | ERROR |" + ex.toString());
    }
    return bookings;
  }

/*
 * getBookingHistory()
 * Get the users booking information from the server.
 *
 * @param user_id the ID of the user .
 * @return List<Booking>
*/
  Future<List<Booking>> getBookingHistory(int user_id) async {
    List<Booking> bookings = [];
    try {
      String parameters = jsonEncode(<String, String>{
        'user_id': user_id.toString(),
        'method': 'getBookingHistory'
      });

      log.debug("Model | getBookingHistory() | parameters are :" + parameters);

      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: parameters,
      );

      log.debug("Model | getBookingHistory() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      log.info("Model | getBookingHistory() | data size is " +
          responseMap["data"].length.toString());

      responseMap["data"].forEach((value) {
        Booking booking = Booking.fromJson(value);
        log.info(
            "Model | getBookingHistory() | created booking object. ${booking.source_name} -> ${booking.destination_name}");
        bookings.add(booking);
      });
    } catch (ex) {
      log.error("Model | getBookingHistory() | ERROR |" + ex.toString());
    }
    return bookings;
  }
  //

  //Get all Drop off and Pick up points
  Future<List<Stop>> getStops(String searchString) async {
    List<Stop> stops = [];
    try {
      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'method': 'getStops',
          'searchString': '${searchString}',
        }),
      );

      log.info("Model | getStops() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      log.info("Model | getStops() | data size is " +
          responseMap["data"].length.toString());

      responseMap["data"].forEach((value) {
        Stop stop = Stop.fromJson(value);
        log.info(
            "Model | getStops() | created stop object. ${stop.stop_name} :: ${stop.stop_street}");
        stops.add(stop);
      });
    } catch (ex) {
      log.error("Model | getStops() | ERROR |" + ex.toString());
    }
    return stops;
  }

/*
 * createBooking()
 * Create New Booking on system server.
 *
 * @param user_id the ID of the user.
 * @param source_id the Pickup bus stop.
 * @param destination_id the Drop off bus stop.
 * 
 * @return List<Booking>
*/
  Future<bool> createBooking(int user_id, int source_id, int destination_id,
      String scheduled_date) async {
    bool status = false;
    try {
      String parameters = jsonEncode(<String, String>{
        'method': 'createBooking',
        'user_id': user_id.toString(),
        'source_id': source_id.toString(),
        'destination_id': destination_id.toString(),
        'price': '17',
        'scheduled_date': scheduled_date,
      });

      log.info("Model | createBooking() | parameters are :" + parameters);

      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: parameters,
      );

      log.info("Model | createBooking() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      log.info("Model | createBooking() | data size is " +
          responseMap["data"].length.toString());
    } catch (ex) {
      log.error("Model | createBooking() | ERROR |" + ex.toString());
    }
    return status;
  }

  Future<bool> cancelBooking(int bookingID) async {
    bool status = false;
    try {
      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'method': 'cancelBooking',
          'booking_id': bookingID.toString(),
        }),
      );

      log.info("Model | cancelBooking() | response is :" + response.body);
    } catch (ex) {
      log.error("Model | cancelBooking() | ERROR |" + ex.toString());
    }
    return status;
  }

/*
 * sendSignUpRequest()
 * Create New Booking on system server.
 *
 * @param user_id the ID of the user.
 * @param source_id the Pickup bus stop.
 * @param destination_id the Drop off bus stop.
 * 
 * @return List<Booking>
*/
  Future<bool> sendSignUpRequest(
      String firstname, String lastname, String phoneNumber) async {
    bool status = false;
    try {
      String parameters = jsonEncode(<String, String>{
        'method': 'createUser',
        'fullname': firstname + " " + lastname,
        'msisdn': phoneNumber
      });

      log.info("Model | sendSignUpRequest() | parameters are :" + parameters);

      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: parameters,
      );

      log.info("Model | sendSignUpRequest() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      status = true;
    } catch (ex) {
      log.error("Model | sendSignUpRequest() | ERROR |" + ex.toString());
    }
    return status;
  }

  /*
 * validateOTP()
 * Send users entered OTP to server for validation
 *
 * @param firstname 
 * @param lastname
 * @param phoneNumber
 * @param otp
 * 
 * @return bool success or failure
*/
  Future<bool> validateOTP(
      String firstname, String lastname, String phoneNumber, String otp) async {
    bool status = false;
    try {
      String parameters = jsonEncode(<String, String>{
        'method': 'validateOTP',
        'fullname': firstname + " " + lastname,
        'msisdn': phoneNumber,
        'otp': otp,
      });

      log.info("Model | validateOTP() | parameters are :" + parameters);

      var response = await http.post(
        Uri.parse(Config.API_URL),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: parameters,
      );

      log.info("Model | validateOTP() | response is :" + response.body);

      Map<String, dynamic> responseMap = jsonDecode(response.body);
      status = responseMap['data']["valid_otp"] == "true" ? true : false;
      if (status) {
        var info =
            await user.setUserId(int.parse(responseMap['data']["user_id"]));

        var info2 =
            await user.setRating(int.parse(responseMap['data']["user_rating"]));

        var info3 = await user.setLoggedInStatus(true);
      }
    } catch (ex) {
      log.error("Model | validateOTP() | ERROR |" + ex.toString());
      status = false;
    }
    return status;
  }
}
