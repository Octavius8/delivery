import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'booking_history_search.dart';
import '_config.dart';
import '_elements.dart';
import '_map.dart';
import 'model/_model.dart';
import '_logging.dart';
import 'model/_booking.dart';
import 'model/_stop.dart';
import 'model/_clocation.dart';
import 'startup.dart';
import 'signup.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:intl/intl.dart';
import 'model/_user.dart';
import 'dart:async';
import 'google_map.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Application name
      title: 'Flutter Stateful Clicker Counter',
      theme: ThemeData(
        // Application theme data, you can set the colors for the application as
        // you want
        primarySwatch: Colors.blue,
      ),
      //home: MyHomePage(title: 'Flutter Demo Clicker Counter Home Page'),
      home: MyAppSplash(),
    );
  }
}

//Splash Screen
class MyAppSplash extends StatefulWidget {
  @override
  _MyAppSplashState createState() => new _MyAppSplashState();
}

class _MyAppSplashState extends State<MyAppSplash> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      navigateAfterSeconds: new Startup(), //MyHomePage(title: "test"),
      title: new Text(
        'Busit',
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 40.0, color: Colors.white),
      ),
      image: Image(image: AssetImage('assets/img/busit_yellow_background.jpg')),
      backgroundColor: Config.COLOR_ACCENTCOLOR,
      loaderColor: Colors.white,
      photoSize: 100,
    );
  }
}
// End Splashscreen

class MyHomePage extends StatefulWidget {
  final String title = "";
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Logging log = new Logging();
  String logprefix = "Main | ";
  List<Stop> _busStopList = [];
  Future<String>? _price;
  bool _displayHamburgerMenu = false;
  User user = new User();
  int _currentScreenMode = Config.MODE_ENTRY;
  CMap cmap = new CMap();
  List<AutocompletePrediction> predictions = [];
  BookingBuilder newBookingBuilder = new BookingBuilder();
  FocusNode destinationFocusNode = new FocusNode();
  Future<String>? distance;
  String _mapLocationString = "";
  CLocation? _currentSource;
  CLocation? _currentDestination;

/*
 * initState()
 * First method that runs in the class. Setting initial screen and getting the
 * autorefresh timer started
 * 
 * @param null
 * @return null
 */
  @override
  void initState() {
    super.initState();
    displayEntryScreen();
    Timer.periodic(Duration(milliseconds: Config.DATA_REFRESH_MILLISECONDS),
        (Timer t) => dataRefresh());
  }

  /*
   * dataRefresh()
   * Updates app with latest info on the system server
   * 
   * @param null
   * @return null
  */
  void dataRefresh() async {
    Logging log = new Logging();

    log.info("Main() | refreshing data");
    if (_currentScreenMode == Config.MODE_ENTRY) getBookings();
    if (_currentScreenMode == Config.MODE_BOOKINGDETAILS) getCurrentBooking();
    setState(() {});
  }

  /*
   * displayEntryScreen()
   * Changes current app state to display the default entry screen
   * 
   * @param null
   * @return null
  */
  void displayEntryScreen() async {
    _currentScreenMode = Config.MODE_ENTRY;
    FocusManager.instance.primaryFocus?.unfocus();
    getBookings();
    log.info(logprefix +
        "getBookings complete. Length " +
        _activeBookings.length.toString());
    setState(() {});
  }

  /*
   * displayNewScreen()
   * Changes current app state to display the New Booking Screen
   * 
   * @param null
   * @return null
  */
  void displayNewBooking() async {
    //Reset form
    newBookingBuilder.reset();
    _editingDestination = false;
    _editingSource = true;

    _textControllerSource.text = "";
    _textControllerDestination.text = "";

    getStops("");

    _currentScreenMode = Config.MODE_NEWBOOKING;
    log.info(logprefix +
        "getStops complete. Length " +
        _busStopList.length.toString());
    setState(() {});
  }

  /*
   * displayEntryScreen()
   * Changes current app state to display the Delete Booking screen.
   * 
   * @param null
   * @return null
  */
  void displayDeleteBooking() async {
    _currentScreenMode = Config.MODE_DELETEBOOKING;
    setState(() {});
  }

  /*
   * toggleHamburgerMenu()
   * Changes current app state to display the side HamburgerMenu.
   * 
   * @param null
   * @return null
  */
  void toggleHamburgerMenu() async {
    if (_displayHamburgerMenu)
      _displayHamburgerMenu = false;
    else
      _displayHamburgerMenu = true;

    setState(() {});
  }

  void cancelBooking(Booking? booking) async {
    Model model = new Model(log: log);
    model.cancelBooking(booking?.booking_id ?? 0);
    toast(Config.NARRATION_CANCELBOOKINGTOAST);
    displayEntryScreen();
  }

  void toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  //Bookings
  bool _editingSource = false;
  bool _editingDestination = false;
  bool _editingDateTime = false;

  List<Booking> _activeBookings = [];
  Booking? _currentBooking;
  String? _scheduledDate;

  TextEditingController _textControllerSource = new TextEditingController();
  TextEditingController _textControllerDestination =
      new TextEditingController();

  void createBooking() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd hh:mm').format(now);

    //Check if all details have been filled
    if (newBookingBuilder.source != null &&
        newBookingBuilder.destination != null) {
      //All details present

      //Check if user is logged in
      log.info("Main | createBooking() | status is " +
          user.getIsLoggedInStatus().toString());
      if (user.getIsLoggedInStatus()) {
        Model model = new Model(log: log);
        newBookingBuilder.scheduled_date = _scheduledDate ?? formattedDate;
        newBookingBuilder.user_id = user.getUserId();
        newBookingBuilder.createBooking();

        displayEntryScreen();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUp(user: user)),
        );
      }
    } else {
      //Some details haven't been filled
      toast(Config.NARRATION_MANDATORYFIELDS);

      if (newBookingBuilder.destination == null) {
        _editingDestination = true;
        _editingSource = false;
      }
      if (newBookingBuilder.source == null) {
        _editingSource = true;
        _editingDestination = false;
      }
    }

    setState(() {});
  }

  void getPrice() {
    Model model = new Model(log: log);
    /*if (_currentSource != null && _currentDestination != null) {
      _price = model.getPrice(_currentSource?.stop_id ?? 0,
          _currentDestination?.stop_id ?? 0, _scheduledDate ?? "");
    } else {
      _price = null;
    }*/
  }

  void getCurrentBooking() async {
    Model model = new Model(log: this.log);
    Logging log = new Logging();
    if (_currentBooking != null) {
      log.info(
          "Main() | Current booking is not null. ID is ${_currentBooking?.booking_id}");
      _currentBooking =
          await model.getBooking(_currentBooking?.booking_id ?? 0);
      setState(() {});
    } else {
      log.info("Main() | Current booking is null.");
    }
  }

  void getBookings() async {
    Model model = new Model(log: this.log);
    _activeBookings =
        await model.getActiveBookings(user.getUserId().toString());
    setState(() {});
  }

  void getStops(String text) async {
    Model model = new Model(log: this.log);
    _busStopList = await model.getStops(text);
    setState(() {});
  }

  void getGooglePlace(String text) async {
    var googlePlace = GooglePlace(Config.MAP_GOOGLEMAPSKEY);

    //Restrict Country
    Component countryComponent = new Component(
        Config.MAP_GOOGLECOUNTRYCOMPONENT, Config.MAP_GOOGLECOUNTRYCODE);
    List<Component> componentList = [];
    componentList.add(countryComponent);

    //User location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLon userLocation = LatLon(position.latitude, position.longitude);

    //Send Reqeust
    var result = await googlePlace.autocomplete
        .get(text, components: componentList, origin: userLocation);
    if (result != null) {
      setState(() {
        log.debug("results:" + result.predictions!.length.toString());
        predictions = result.predictions ?? [];
      });
    } else {
      log.debug("results are null." + googlePlace.apiKEY);
    }
  }

  void setLocation(AutocompletePrediction prediction) async {
    var googlePlace = GooglePlace(Config.MAP_GOOGLEMAPSKEY);
    var result = await googlePlace.details.get(prediction.placeId ?? "");
    double lat = result!.result!.geometry!.location!.lat ?? 0;
    double lng = result.result!.geometry!.location!.lng ?? 0;
    CLocation tempLocation = new CLocation(
        address: result.result!.addressComponents![1].toString(),
        name: prediction.description ?? "",
        latitude: lat,
        longitude: lng);

    //Destination
    if (_editingDestination) {
      _currentDestination = tempLocation;
      newBookingBuilder.destination = _currentDestination;

      _textControllerDestination.text = prediction.description ?? "";
      _editingSource = false;
      _editingDestination = false;
      _editingDateTime = true;
    }

    //Source
    if (_editingSource) {
      _currentSource = tempLocation;
      newBookingBuilder.source = _currentSource;

      _textControllerSource.text = prediction.description ?? "";
      _editingSource = false;
      _editingDestination = true;
      destinationFocusNode.requestFocus();
      _editingDateTime = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Stack(children: [
                  //Map
                  Container(
                    decoration: BoxDecoration(color: Config.COLOR_MIDGRAY),
                  ),
                  //CMap(_currentBooking),
                  CGoogleMap(
                    booking: _currentBooking,
                    onChange: (mapLocation) {
                      _mapLocationString = mapLocation.name;
                    },
                  ),
                  Center(
                      child: Container(
                          margin: EdgeInsets.only(bottom: 80),
                          child: Icon(Icons.location_on, size: 50))),

                  //Job card
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 500),
                      top: _currentScreenMode == Config.MODE_ENTRY
                          ? MediaQuery.of(context).size.height.toDouble() -
                              (_activeBookings.length > 0 ? 300 : 200)
                          : MediaQuery.of(context).size.height.toDouble(),
                      child:
                          //Data
                          Container(
                        width: MediaQuery.of(context).size.width,
                        height: _activeBookings.length > 0 ? 300 : 200,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40))),
                        child: Column(children: [
                          //Heading
                          Row(children: [
                            Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                    "Your Bookings (${_activeBookings.length.toString()})",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)))
                          ]),
                          Expanded(

                              //LIst of Active Bookings

                              child: _activeBookings.length > 0
                                  ? ListView.separated(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: _activeBookings.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                          //height: 50,
                                          child: Center(
                                              child: GestureDetector(
                                                  onTap: () {
                                                    _currentBooking =
                                                        _activeBookings[index];
                                                    _currentScreenMode = Config
                                                        .MODE_BOOKINGDETAILS;
                                                    setState(() {});
                                                  },
                                                  child: Row(children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(9),
                                                        child: Icon(
                                                            Icons
                                                                .radio_button_on,
                                                            color: Config
                                                                .COLOR_ACCENTCOLOR)),
                                                    Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(children: [
                                                            Text(
                                                                '${_activeBookings[index].getUserFriendlyDate()} - '),
                                                            Text(
                                                                '${_activeBookings[index].getStateNarration()}',
                                                                style: TextStyle(
                                                                    color: Config
                                                                        .COLOR_PENDING,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                          ]),
                                                          Text(
                                                              "${_activeBookings[index].source_name}  ->  ${_activeBookings[index].destination_name}",
                                                              style: TextStyle(
                                                                  color: Config
                                                                      .COLOR_LIGHTGRAY)),
                                                          //Divider(),
                                                        ])
                                                  ]))),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              const Divider(),
                                    )
                                  : Container(
                                      child: Text("(No Active Bookings)",
                                          style: TextStyle(
                                              color: Config.COLOR_OFFWHITE)))),

                          //New Booking Button
                          Container(
                              margin: EdgeInsets.all(20),
                              child: CPrimaryButton(
                                  title: "New Booking",
                                  action: () {
                                    displayNewBooking();
                                    setState(() {});
                                  })),
                        ]),
                      )),

                  //New Booking
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 500),
                      top: _currentScreenMode == Config.MODE_NEWBOOKING
                          ? 50
                          : MediaQuery.of(context).size.height.toDouble(),
                      child:
                          //Data
                          Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(30),
                                topLeft: Radius.circular(30))),
                        height:
                            MediaQuery.of(context).size.height.toDouble() - 50,
                        child: Column(children: [
                          GestureDetector(
                              onTap: () {
                                displayEntryScreen();
                                setState(() {});
                              },
                              //Open and Close Panel
                              child: Container(
                                margin: EdgeInsets.only(top: 5),
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Color(0xFFbbbbbb),
                                    borderRadius: BorderRadius.circular(10)),
                              )),

                          //Source/Destination Panel
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(
                                top: 0, left: 5, right: 5, bottom: 15),
                            padding: EdgeInsets.only(
                                left: 12, right: 12, bottom: 18),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color(0xFFf8f8f8),
                                      blurRadius: 4,
                                      offset: Offset(0, 8))
                                ]),
                            child: Column(children: [
                              //Source
                              Row(children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 0, right: 10),
                                  child: _editingSource
                                      ? Icon(Icons.search,
                                          size: 20, color: Colors.red)
                                      : Icon(Icons.radio_button_on_sharp,
                                          size: 20,
                                          color: Config.COLOR_MIDGRAY),
                                ),
                                Expanded(
                                    child: TextField(
                                        decoration: InputDecoration(
                                            hintText: ("Pick up point")),
                                        controller: _textControllerSource,
                                        autofocus: _currentScreenMode ==
                                                Config.MODE_NEWBOOKING
                                            ? true
                                            : false,
                                        onTap: () {
                                          _editingSource = true;
                                          _editingDateTime = false;
                                          _editingDestination = false;
                                          setState(() {});
                                        },
                                        onChanged: (text) {
                                          //getStops(text);
                                          getGooglePlace(text);
                                          newBookingBuilder.source = null;
                                          _currentSource = null;
                                          //setState(() {});
                                        })),
                                _editingSource
                                    ? GestureDetector(
                                        onTap: () {
                                          newBookingBuilder.source = null;
                                          _currentSource = null;
                                          _textControllerSource.text = "";
                                          getPrice();
                                        },
                                        child: Icon(Icons.clear, size: 20))
                                    : Text(""),
                                VerticalDivider(
                                    thickness: 2, color: Colors.black),
                                _editingSource
                                    ? Padding(
                                        padding: EdgeInsets.all(5),
                                        child: GestureDetector(
                                            onTap: () {
                                              _currentScreenMode =
                                                  Config.MODE_MAPLOCATIONPICKER;
                                              setState(() {});
                                            },
                                            child: Text("Map")))
                                    : Text(""),
                              ]),
                              //Destination
                              Row(children: [
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 0, right: 10),
                                    child: _editingDestination
                                        ? Icon(Icons.search,
                                            size: 20, color: Colors.red)
                                        : Icon(Icons.radio_button_on_sharp,
                                            size: 20,
                                            color: Config.COLOR_MIDGRAY)),
                                Expanded(
                                    child: TextField(
                                        focusNode: destinationFocusNode,
                                        decoration: InputDecoration(
                                            hintText: "Drop off point"),
                                        controller: _textControllerDestination,
                                        onTap: () {
                                          _editingDateTime = false;
                                          _editingDestination = true;
                                          _editingSource = false;
                                          setState(() {});
                                        },
                                        onChanged: (text) {
                                          getGooglePlace(text);
                                          newBookingBuilder.destination = null;
                                          _currentDestination = null;
                                        })),
                                !_editingSource
                                    ? GestureDetector(
                                        onTap: () {
                                          newBookingBuilder.destination = null;
                                          _currentDestination = null;

                                          _textControllerDestination.text = "";
                                          getPrice();
                                        },
                                        child: Icon(Icons.clear, size: 20))
                                    : Text(""),
                                VerticalDivider(
                                    thickness: 2, color: Colors.black),
                                !_editingSource
                                    ? Padding(
                                        padding: EdgeInsets.all(5),
                                        child: GestureDetector(
                                            onTap: () {
                                              _currentScreenMode =
                                                  Config.MODE_MAPLOCATIONPICKER;
                                              setState(() {});
                                            },
                                            child: Text("Map")))
                                    : Text("")
                              ]),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FutureBuilder(
                                        future: distance,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.connectionState ==
                                                  ConnectionState.done)
                                            return Text(
                                                snapshot.data.toString());

                                          return Text("");
                                        }),
                                    Expanded(flex: 1, child: Text("")),
                                    Expanded(
                                        flex: 3,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 100,
                                          ),
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Logging log = new Logging();
                                                Model model =
                                                    new Model(log: log);
                                                LatLng source = LatLng(
                                                    newBookingBuilder
                                                            .source?.latitude ??
                                                        0,
                                                    newBookingBuilder.source
                                                            ?.longitude ??
                                                        0);
                                                LatLng destination = LatLng(
                                                    newBookingBuilder
                                                            .destination
                                                            ?.latitude ??
                                                        0,
                                                    newBookingBuilder
                                                            .destination
                                                            ?.longitude ??
                                                        0);
                                                distance =
                                                    model.getGoogleDistance(
                                                        source, destination);
                                              },
                                              child: Text("Next"),
                                              style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Config
                                                              .COLOR_ACCENTCOLOR))),
                                        )),
                                    Expanded(flex: 1, child: Text("")),
                                  ]),

                              //Date Time of Pickup
                              /*DateTimePicker(
                                type: DateTimePickerType.dateTimeSeparate,
                                dateMask: 'd MMM, yyyy',
                                initialValue: DateTime.now().toString(),
                                firstDate: DateTime(2022),
                                lastDate: DateTime(2100),
                                icon: Icon(Icons.event,
                                    color: Config.COLOR_MIDGRAY, size: 20),
                                dateLabelText: 'Date',
                                timeLabelText: "Time",
                                selectableDayPredicate: (date) {
                                  return true;
                                },
                                onChanged: (val) {
                                  _scheduledDate = val;
                                  print(val);
                                },
                                validator: (val) {
                                  _scheduledDate = val;
                                  print(val);
                                  return null;
                                },
                                onSaved: (val) {
                                  _scheduledDate = val;
                                  print(val);
                                },
                              ),*/

                              //Packages
                              /*Container(
                                  child: SingleChildScrollView(
                                      child: Row(children: [
                                Container(
                                    width: 50, height: 50, color: Colors.green),
                              ]))),*/

                              /*Row(children: [
                                //Price
                                FutureBuilder(
                                  future: _price,
                                  builder: (ctx, snapshot) {
                                    // Checking if future is resolved or not
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      // If we got an error
                                      if (snapshot.hasError) {
                                        return Text(
                                          "",
                                          style: TextStyle(fontSize: 18),
                                        );

                                        // if we got our data
                                      } else if (snapshot.hasData) {
                                        // Extracting data from snapshot object
                                        final data = snapshot.data as String;
                                        return Text(
                                            Config.CURRENCY + " " + data,
                                            style: TextStyle(
                                                /*fontWeight: FontWeight.bold,*/ fontSize:
                                                    16,
                                                color:
                                                    Config.COLOR_ACCENTCOLOR));
                                      }
                                    }

                                    // Displaying LoadingSpinner to indicate waiting state
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },

                                  // Future that needs to be resolved
                                  // inorder to display something on the Canvas
                                ),
                                
                                //-- End Price

                                Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.all(20),
                                        child: SizedBox(
                                            height: 40,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  shape: MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0))),
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Config
                                                              .COLOR_ACCENTCOLOR)),
                                              child: Text("Confirm Order"),
                                              onPressed: () {
                                                createBooking();
                                              },
                                            )))),
                              ]),*/
                            ]),
                          ),

                          //List oF Predictions
                          Expanded(
                              child: ListView.separated(
                                  itemCount: predictions.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          setLocation(predictions[index]);
                                        },
                                        child: Row(children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 12,
                                                right: 12,
                                                top: 7,
                                                bottom: 7),
                                            child: Icon(
                                                Icons.radio_button_on_sharp,
                                                color: Config.COLOR_LIGHTGRAY,
                                                size: 20),
                                          ),
                                          Expanded(
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                Text(
                                                    predictions[index]
                                                            .description ??
                                                        "",
                                                    style: TextStyle(
                                                        fontSize: 16)),
                                                Text(
                                                    ((predictions[index].distanceMeters ??
                                                                    1) /
                                                                1000)
                                                            .toStringAsFixed(
                                                                2) +
                                                        " km",
                                                    style: TextStyle(
                                                        color: Config
                                                            .COLOR_LIGHTGRAY))
                                              ]))
                                        ]));
                                  },
                                  separatorBuilder: (context, index) =>
                                      const Divider()))
                        ]),
                      )),

                  //Booking Details
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 400),
                      top: _currentScreenMode == Config.MODE_BOOKINGDETAILS ||
                              _currentScreenMode == Config.MODE_DELETEBOOKING
                          ? 35
                          : -170,
                      child:
                          //Data
                          Container(
                        height: 150,
                        margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width - 20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40)),
                        child: Column(children: [
                          //Closing Tab
                          GestureDetector(
                              onTap: () {
                                displayEntryScreen();
                                setState(() {});
                              },
                              //Open and Close Panel
                              child: Container(
                                margin: EdgeInsets.only(top: 5),
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Color(0xFFbbbbbb),
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                          //Heading
                          Row(children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10, top: 5),
                                child: Text("Booking Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10, top: 5),
                                child: Text(
                                    "${_currentBooking?.getUserFriendlyDate()}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ]),

                          //Source && Destination
                          Column(children: [
                            Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Icon(Icons.radio_button_checked,
                                      size: 20, color: Config.COLOR_LIGHTGRAY)),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                      "${_currentBooking?.source_name}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    /*Text("${_currentBooking?.source_street}",
                                        style: TextStyle(
                                            color: Config.COLOR_LIGHTGRAY))*/
                                  ])),
                            ]),
                            Padding(
                                padding: EdgeInsets.only(left: 40, right: 40),
                                child: Divider()),
                            Row(children: [
                              Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Icon(Icons.radio_button_checked,
                                      size: 20, color: Config.COLOR_LIGHTGRAY)),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                      "${_currentBooking?.destination_name}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                        "${_currentBooking?.destination_address}",
                                        style: TextStyle(
                                            color: Config.COLOR_LIGHTGRAY))
                                  ])),
                            ])
                          ]),
                        ]),
                      )),

                  //Driver Details
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 400),
                      bottom: 10,
                      left: _currentScreenMode == Config.MODE_BOOKINGDETAILS
                          ? 0
                          : MediaQuery.of(context).size.width,
                      child:
                          //Data
                          Container(
                        height: 170,
                        margin: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width - 20,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)),
                        child: Column(children: [
                          //Closing Tab
                          GestureDetector(
                              onTap: () {
                                displayEntryScreen();
                                setState(() {});
                              },
                              //Open and Close Panel
                              child: Container(
                                margin: EdgeInsets.only(top: 5),
                                width: 30,
                                height: 5,
                                decoration: BoxDecoration(
                                    color: Color(0xFFbbbbbb),
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                          //Heading
                          Row(children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, bottom: 10, top: 10),
                                child: Text(
                                    _currentBooking?.getStateNarration() ?? "",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Config.COLOR_DANGER))),
                            Expanded(child: Text("")),
                            Padding(
                                padding: EdgeInsets.only(right: 20),
                                child: _currentBooking?.booking_state !=
                                            Config.BOOKING_COMPLETE &&
                                        _currentBooking?.booking_state !=
                                            Config.BOOKING_CANCELLED
                                    ? GestureDetector(
                                        onTap: () {
                                          displayDeleteBooking();
                                        },
                                        child: Text("Cancel Booking",
                                            style: TextStyle(
                                                color: Config.COLOR_DANGER)))
                                    : _currentBooking?.booking_state ==
                                            Config.BOOKING_COMPLETE
                                        ? GestureDetector(
                                            onTap: () {},
                                            child: Text(
                                                "Amount Due: " +
                                                    Config.CURRENCY +
                                                    " " +
                                                    (_currentBooking?.price.toString() ??
                                                        ""),
                                                style: TextStyle(
                                                    color:
                                                        Config.COLOR_DANGER)))
                                        : GestureDetector(
                                            onTap: () {
                                              displayEntryScreen();
                                            },
                                            child: Text("Back",
                                                style: TextStyle(
                                                    color: Config.COLOR_DANGER))))
                          ]),

                          //Driver Details

                          AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              child: _currentBooking != null &&
                                      _currentBooking?.booking_state !=
                                          Config.BOOKING_PENDING
                                  ? Row(children: [
                                      Container(
                                          margin: EdgeInsets.all(10),
                                          child: CircleAvatar(
                                              radius: 30,
                                              backgroundImage: NetworkImage(
                                                  '${_currentBooking?.profile_pic}'))),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(
                                                "${_currentBooking?.driver_name}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                "${_currentBooking?.driver_vehicle}",
                                                style: TextStyle(fontSize: 11)),
                                            Text(
                                                "${_currentBooking?.driver_number_plate}",
                                                style: TextStyle(fontSize: 11)),
                                            Text(
                                                "Class: ${_currentBooking?.driver_vehicle_class}",
                                                style: TextStyle(fontSize: 11)),
                                          ])),
                                      Expanded(
                                          child: Column(
                                        children: [
                                          Text(
                                              "Rating: ${_currentBooking?.driver_rating}"),
                                          Container(
                                              margin: EdgeInsets.all(7),
                                              child: RatingBar.builder(
                                                initialRating: _currentBooking
                                                        ?.driver_rating ??
                                                    0,
                                                minRating: 1,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemSize: 10.0,
                                                itemPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 4.0),
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {
                                                  print(rating);
                                                },
                                              )),
                                        ],
                                      )),
                                    ])
                                  :
                                  //Booking in Pending State
                                  Column(children: [
                                      Padding(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: Text(
                                              "Waiting for a driver to be assigned")),
                                      CircularProgressIndicator(
                                          color: Config.COLOR_ACCENTCOLOR),
                                    ]))
                        ]),
                      )),

                  //Delete Booking
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 400),
                      bottom: 10,
                      right: _currentScreenMode == Config.MODE_DELETEBOOKING
                          ? 0
                          : MediaQuery.of(context).size.width,
                      child:
                          //Data
                          Container(
                              height: 170,
                              margin: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width - 20,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(children: [
                                //Closing Tab
                                GestureDetector(
                                    onTap: () {
                                      displayEntryScreen();
                                      setState(() {});
                                    },
                                    //Open and Close Panel
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: 30,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFbbbbbb),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    )),
                                //Heading
                                Row(children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 10,
                                          top: 10),
                                      child: Text("Delete Booking",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(child: Text("")),
                                ]),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, bottom: 10),
                                    child: Text(
                                        Config.NARRATION_CANCELBOOKINGPROMPT,
                                        textAlign: TextAlign.center)),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: CPrimaryButton(
                                        title: "Cancel Booking",
                                        action: () {
                                          cancelBooking(_currentBooking);
                                        }))
                              ]))),

                  //Map Location Picker
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 400),
                      bottom: 10,
                      right: _currentScreenMode == Config.MODE_MAPLOCATIONPICKER
                          ? 0
                          : MediaQuery.of(context).size.width,
                      child:
                          //Data
                          Container(
                              height: 170,
                              margin: EdgeInsets.all(10),
                              width: MediaQuery.of(context).size.width - 20,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Column(children: [
                                //Closing Tab
                                GestureDetector(
                                    onTap: () {
                                      displayEntryScreen();
                                      setState(() {});
                                    },
                                    //Open and Close Panel
                                    child: Container(
                                      margin: EdgeInsets.only(top: 5),
                                      width: 30,
                                      height: 5,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFbbbbbb),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    )),
                                //Heading
                                Row(children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          bottom: 10,
                                          top: 10),
                                      child: Text("Pick Location",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  Expanded(child: Text("")),
                                ]),
                                Padding(
                                    padding: EdgeInsets.only(
                                        left: 20, right: 20, bottom: 10),
                                    child: Text(_mapLocationString,
                                        textAlign: TextAlign.center)),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 20, right: 20),
                                    child: CPrimaryButton(
                                        title: "OK",
                                        action: () {
                                          cancelBooking(_currentBooking);
                                        }))
                              ]))),

                  //Hamburger Menu
                  Positioned(
                      top: 25,
                      left: 16,
                      child: GestureDetector(
                          onTap: () {
                            toggleHamburgerMenu();
                          },
                          child: Icon(Icons.menu_rounded))),

                  //Screen
                  Positioned(
                      left: _displayHamburgerMenu
                          ? 0
                          : MediaQuery.of(context).size.width,
                      child: GestureDetector(
                          onTap: () {
                            toggleHamburgerMenu();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                                color: _displayHamburgerMenu
                                    ? Color(0xAA000000)
                                    : Color(0x00000000)),
                          ))),

                  AnimatedPositioned(
                      duration: Duration(milliseconds: 500),
                      left: _displayHamburgerMenu
                          ? 0
                          : -MediaQuery.of(context).size.width,
                      child: Container(
                          decoration: BoxDecoration(color: Colors.white),
                          width: MediaQuery.of(context).size.width / 2,
                          height: MediaQuery.of(context).size.height,
                          child: Column(children: [
                            //Cancel Icon
                            Container(
                                padding: EdgeInsets.only(top: 30),
                                child: Row(children: [
                                  Expanded(child: Text("")),
                                  GestureDetector(
                                      onTap: () {
                                        toggleHamburgerMenu();
                                      },
                                      child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Icon(Icons.clear, size: 15)))
                                ])),
                            //User Details
                            user.getIsLoggedInStatus()
                                ? Container(
                                    height: 50,
                                    child: Column(children: [
                                      Text(user.getFullName()),
                                      Text(user.getPhoneNumber(),
                                          style: TextStyle(
                                              color: Config.COLOR_LIGHTGRAY)),
                                    ]))
                                : Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Container(
                                        height: 50,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                primary: Colors.green,
                                                minimumSize:
                                                    Size.fromHeight(50)),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SignUp(user: user)),
                                              );
                                            },
                                            child: Text("Sign Up")))),

                            Divider(),

                            GestureDetector(
                              onTap: () {
                                _currentScreenMode = Config.MODE_BOOKINGHISTORY;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BookingHistorySearch(user: user)),
                                ).then((completion) {
                                  _displayHamburgerMenu = false;
                                  displayEntryScreen();
                                });
                              },
                              child: Container(
                                height: 50,
                                child: Center(child: Text("Booking History")),
                              ),
                            ),

                            Divider(),
                          ]))),

                  //
                  //-- Delete Booking
                ]))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
