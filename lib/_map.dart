import 'package:flutter/material.dart';
import '_config.dart';
import 'model/_booking.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import '_logging.dart';

class CMap extends StatefulWidget {
  Booking? booking;

  CMap([this.booking]);

  @override
  State<StatefulWidget> createState() {
    return new CMapState();
  }
}

class CMapState extends State<CMap> {
  Booking? _currentBooking;
  double currentLat = 0;
  double currentLong = 0;
  LocationPermission? permission;
  String comment = "";

  void getLastKnownPosition() async {
    Logging log = new Logging();
    if (permission == null || permission == "denied") {
      log.info("CMap() | Location Permissions are denied.");
      //LocationPermission permission = await Geolocator.requestPermission();
    } else {
      Position? position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentLat = position.latitude;
      currentLong = position.longitude;
      comment = currentLat.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    getLastKnownPosition();
    List<Marker> markers = [];
    if (widget.booking != null) {
      double source_longtitude = widget.booking?.source_longitude ?? 0;
      double source_latitude = widget.booking?.source_latitude ?? 0;
      double destination_longtitude =
          widget.booking?.destination_longitude ?? 0;
      double destination_latitude = widget.booking?.destination_latitude ?? 0;
      markers.add(
        Marker(
          width: 100.0,
          height: 100.0,
          point: LatLng(source_longtitude, source_latitude),
          builder: (ctx) => Container(
              child: Icon(Icons.location_on,
                  color: Config.COLOR_MAPSOURCEMARKER,
                  size: 50) //FlutterLogo(),
              ),
        ),
      );
      markers.add(
        Marker(
          width: 100.0,
          height: 100.0,
          point: LatLng(destination_longtitude, destination_latitude),
          builder: (ctx) => Container(
              child: Icon(Icons.location_on,
                  color: Config.COLOR_MAPDESTINATIONMARKER,
                  size: 50) //FlutterLogo(),
              ),
        ),
      );
      markers.add(
        Marker(
          width: 150.0,
          height: 150.0,
          point: LatLng(currentLat, currentLong),
          builder: (ctx) => Container(
              child: Icon(Icons.location_history,
                  color: Config.COLOR_MAPCURRENTMARKER,
                  size: 50) //FlutterLogo(),
              ),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        center: LatLng(-15.38, 28.32),
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          attributionBuilder: (_) {
            return Text("© Ovidware Solutions");
          },
        ),
        MarkerLayerOptions(
          markers: markers,
        ),
      ],
    );
  }
}
