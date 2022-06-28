import 'package:flutter/material.dart';
import '_config.dart';
import 'model/_booking.dart';
import 'model/_clocation.dart';
import 'package:geolocator/geolocator.dart';
import '_logging.dart';
import 'model/_clocation.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class CGoogleMap extends StatefulWidget {
  Booking? booking;
  Function(CLocation mapLocation) onChange;

  CGoogleMap({required this.onChange, this.booking});

  @override
  State<StatefulWidget> createState() {
    return new CGoogleMapState();
  }
}

class CGoogleMapState extends State<CGoogleMap> {
  Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = new Set();
  Logging log = new Logging();

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(-15.3874, 28.3098),
    zoom: 14.4746,
  );

  void getCLocation(double latitude, double longitude) async {
    //when map drag stops
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    //get place name from lat and lang
    String locationString = placemarks.first.administrativeArea.toString() +
        ", " +
        placemarks.first.street.toString();

    CLocation mapLocation = new CLocation(
        name: locationString,
        address: locationString,
        latitude: latitude,
        longitude: longitude);

    log.debug(
        "CGoogleMap | build() current location is: " + mapLocation.address);
    //Call function
    widget.onChange.call(mapLocation);
  }

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
      onCameraMove: (CameraPosition cameraPositiona) {
        _kGooglePlex = cameraPositiona; //when map is dragging
      },
      onTap: (LatLng latLng) async {
        _kGooglePlex = CameraPosition(target: latLng);
        getCLocation(latLng.latitude, latLng.longitude);
      },
      onCameraIdle: () async {
        getCLocation(
            _kGooglePlex.target.latitude, _kGooglePlex.target.longitude);
      },
    );
  }
}
