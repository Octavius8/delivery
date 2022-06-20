import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '_config.dart';
import 'main.dart';
import 'dart:io';

class Startup extends StatefulWidget {
  @override
  StartupState createState() => new StartupState();
}

class StartupState extends State<Startup> {
  Future<bool>? status;
  String user_message = "";

  @override
  void initState() {
    super.initState();
    checkPermissions();
  }

  void checkPermissions() async {
    bool finalStatus = false;
    status = adequatePermission();
    setState(() {});
  }

/*
 * methodName()
 * Check if location permissions have been enabled by the user
 * 
 * @param null
 * @return bool
*/
  Future<bool> adequatePermission() async {
    bool finalStatus = false;
    bool serviceEnabled;
    LocationPermission permission;

    //Location Permissions
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      user_message = "Please turn on Location services on your device.";
      return false;
    } else {
      user_message = "Location Services enabled :)";
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        user_message =
            "This App not allowed to access your location. Please enable.";
        return false;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    ).then((data) {
      exit(0);
    });
    user_message = "Everything Looks Good :)";
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: FutureBuilder(
                future: status,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    //Response received
                    if (status == false) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_pin, size: 50),
                            Divider(),
                            Text(user_message),
                            ElevatedButton(
                              onPressed: () {
                                checkPermissions();
                              },
                              child: Text(
                                "Try Again",
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Config.COLOR_DANGER),
                            )
                          ]);
                    } else {
                      //Everything is fine

                      return Text("");
                    }
                  } else if (snapshot.hasError) {
                    //Something Went Wrong
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Something Went Wrong."),
                          ElevatedButton(
                              onPressed: () {
                                status = adequatePermission();
                              },
                              child: Text("Try Again"))
                        ]);
                  }
                  return CircularProgressIndicator(
                      color: Config.COLOR_ACCENTCOLOR);
                },
              ),
            )));
  }
}
