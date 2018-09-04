import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:weather/key.dart';
import 'package:flutter/services.dart';

class WeatherHome extends StatefulWidget {
  final Map<String, double> location;
  WeatherHome({this.location});
  @override
  WeatherHomeState createState() => new WeatherHomeState();
}

class WeatherHomeState extends State<WeatherHome> {
  Location _location = new Location();
  Map<String, dynamic> location;
  Map<String, dynamic> weatherCurrently;
  Map<String, dynamic> weatherDaily = {
    'today': {},
    'tomorow': {},
    'whatever': {},
  };
  String lat;
  String lon;
  String city;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location = widget.location;
    lat = location["latitude"].toString();
    lon = location["longitude"].toString();
    print('lat: $lat');
    print('lon: $lon');
    getWeatherandCity();
  }

  getWeatherandCity() async {
    final http.Client _client = http.Client();
    String _urlDarkSky =
        'https://api.darksky.net/forecast/$api_key_darksky/$lat,$lon';
    String _urlPlaces =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&result_type=administrative_area_level_2&key=$api_key_places';
    print(_urlDarkSky);
    await _client
        .get(Uri.parse(_urlDarkSky))
        .then((res) => res.body)
        .then(json.decode)
        .then((res) {
      print(res['hourly']['data'].length);
      setState(() {
        weatherDaily['today'] = res['daily']['data'][0];
        weatherDaily['tomorow'] = res['daily']['data'][1];
        weatherDaily['whatever'] = res['daily']['data'][2];
      });
      print(weatherDaily);
    });
    await _client
        .get(Uri.parse(_urlPlaces))
        .then((res) => res.body)
        .then(json.decode)
        .then((json) => json['results'])
        .then((res) {
      setState(() {
        city = res[0]['address_components'][0]['types']
                .contains('administrative_area_level_2')
            ? res[0]['address_components'][0]['long_name']
            : '';
      });
      print(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('lat: $lat'),
            Text('lon: $lon'),
            Text('city: $city')
          ],
        ),
      ),
    );
  }
}
