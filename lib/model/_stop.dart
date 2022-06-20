class Stop {
  int stop_id;
  String stop_name;
  String stop_street;
  double longtitude;
  double latitude;

  Stop(this.stop_id, this.stop_name, this.stop_street, this.longtitude, this.latitude);

  Stop.fromJson(Map<String, dynamic> json)
      : stop_id = int.parse(json['stop_id']),
        stop_name = json['stop_name'],
        stop_street = json['street'],
        longtitude = double.parse(json['longtitude']),
        latitude = double.parse(json['latitude']);
}
