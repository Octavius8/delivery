import 'package:flutter/material.dart';

class Config {
  //FRONT END CONFIGURATIONS

  //System Color Pallete
  static final Color COLOR_MIDGRAY = Color(0xFF555555);
  static final Color COLOR_LIGHTGRAY = Color(0xFF888888);
  static final Color COLOR_OFFWHITE = Color(0xFFdfdfdf);
  static final Color COLOR_ACCENTCOLOR = Color(0xFFFEDD36); //Color(0xFFFFC000);
  static final Color COLOR_DANGER = Color(0xFFFFC000);
  static final Color COLOR_PENDING = Color(0xFFFFC000);
  static final Color COLOR_MAPSOURCEMARKER =
      Colors.orange; //Map, color of pickup point icon
  static final Color COLOR_MAPDESTINATIONMARKER =
      Colors.green; // Map, color of drop off point icon
  static final Color COLOR_MAPCURRENTMARKER =
      Colors.purple; //Map, color of users current position icon

  //Prompts and Narrations
  static final String NARRATION_CANCELBOOKINGPROMPT =
      "Are you sure you would like to Cancel this booking?";
  static final String NARRATION_CANCELBOOKINGTOAST = "Booking Cancelled!";
  static final String NARRATION_MANDATORYFIELDS =
      "Please fill in all mandatory data!";

  static final String BOOKING_PENDING_NARRATION = "Assigning Driver";
  static final String BOOKING_ASSIGNED_NARRATION = "Driver Assigned";
  static final String BOOKING_ACTIVE_NARRATION = "Driver On Their Way";
  static final String BOOKING_ARRIVED_NARRATION = "Driver has Arrived";
  static final String BOOKING_INPROGRESS_NARRATION = "Trip in Progress";
  static final String BOOKING_TRIPEND_NARRATION = "Trip has ended";
  static final String BOOKING_COMPLETE_NARRATION = "Trip Concluded";
  static final String BOOKING_CANCELLED_NARRATION = "Trip Cancelled";

  //SYSTEM CONFIGURATIONS

  //Main Screen Display Configurations
  static final int MODE_ENTRY = 1;
  static final int MODE_NEWBOOKING = 2;
  static final int MODE_BOOKINGDETAILS = 3;
  static final int MODE_DELETEBOOKING = 4;
  static final int MODE_BOOKINGHISTORY = 5;
  static final int MODE_MAPLOCATIONPICKER = 6;

  //Bookings
  static final int BOOKING_PENDING = 0;
  static final int BOOKING_ASSIGNED = 1;
  static final int BOOKING_ACTIVE = 2;
  static final int BOOKING_ARRIVED = 3;
  static final int BOOKING_INPROGRESS = 4;
  static final int BOOKING_ENDED = 5;
  static final int BOOKING_COMPLETE = 6;
  static final int BOOKING_CANCELLED = 7;

  static final int USER_USERID = 1;
  static final int USER_DEFAULTRATING = 4;

  //API DETAILS
  static final String API_URL = "https://busit.ovidware.com/";
  //static final String API_URL = "http://192.168.43.59/busit/";

  //DATA Refresh
  static final int DATA_REFRESH_MILLISECONDS = 3000;

  //Currency
  static final String CURRENCY = "ZMW";

  //Google Services
  static final String MAP_GOOGLEMAPSKEY = "";
  static final String MAP_GOOGLECOUNTRYCODE = "zm";
  static final String MAP_GOOGLECOUNTRYCOMPONENT = "country";
}
