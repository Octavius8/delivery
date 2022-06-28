import 'package:flutter/material.dart';
import '_config.dart';
import 'model/_booking.dart';
import 'package:geolocator/geolocator.dart';
import '_logging.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CGoogleMap extends StatefulWidget {
  Booking? booking;

  CGoogleMap([this.booking]);

  @override
  State<StatefulWidget> createState() {
    return new CGoogleMapState();
  }
}

class CGoogleMapState extends State<CGoogleMap> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = new Set();
  Logging log = new Logging();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.3874, 28.3098),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    markers.clear();
    if (widget.booking != null) {
      log.debug(
          "CGoogleMap | build() | booking is Not Null. Drawing markers... ${widget.booking?.source_longitude.toString()}");
      //Source
      markers.add(Marker(
        //add first marker
        markerId: MarkerId("PickUp Point"),
        position: LatLng(widget.booking?.source_longitude ?? 0,
            widget.booking?.source_latitude ?? 0), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Pickup Point ',
          snippet: 'Where the driver expects to find you.',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));

      //Destination
      markers.add(Marker(
        //add first marker
        markerId: MarkerId("DropOffPoint"),
        position: LatLng(widget.booking?.destination_longitude ?? 0,
            widget.booking?.destination_latitude ?? 0), //position of marker
        infoWindow: InfoWindow(
          //popup info
          title: 'Drop Off Point ',
          snippet: 'Where the driver will drop you off.',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
    } else {
      log.debug("CGoogleMap | build() | booking is  Null. Not doing markers");
    }
    log.debug(
        "CGoogleMap | build() | Marker count is " + markers.length.toString());
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      markers: markers,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
    );
  }
}
