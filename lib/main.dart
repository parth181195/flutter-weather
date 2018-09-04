import 'dart:async';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:weather/no_connecion_page.dart';
import 'package:weather/no_location_page.dart';
import 'package:weather/home_page.dart';

void main() => runApp(new WeatherApp());

enum AppStatus { ok, noInternet, noLocation, undefined }

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new WeatherRoot(title: 'Flutter Demo Home Page'),
    );
  }
}

class WeatherRoot extends StatefulWidget {
  WeatherRoot({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WeatherRootState createState() => new _WeatherRootState();
}

class _WeatherRootState extends State<WeatherRoot> {
  AppStatus appStatus = AppStatus.undefined;
  // connectvity
  bool _connectionStatus;
  final Connectivity _connectivity = new Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  // location
  Location _location = new Location();
   Map<String, double> location;
  bool _hasLocation;

  setAppstatus() {
    setState(() {
      print('location : $_hasLocation');
      print('internet : $_connectionStatus');
      if (_connectionStatus != null && _hasLocation != null) {
        appStatus = _hasLocation && _connectionStatus
            ? AppStatus.ok
            : _connectionStatus ? AppStatus.noLocation : AppStatus.noInternet;
      }
    });
  }

  Future<Null> getLocation() async {
    bool _permission;
    try {
      _permission = await _location.hasPermission();
      location = await _location.getLocation();
    } on PlatformException catch (e) {
      print(e.code);
      location = null;
    }
    _hasLocation = location != null ? true : false;
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        if (result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi) {
          _connectionStatus = true;
        } else {
          _connectionStatus = false;
        }
        setAppstatus();
      });
    });
    getLocation().whenComplete(() {
      setAppstatus();
    });
  }

  Widget getPage() {
    Widget page;
    switch (appStatus) {
      case AppStatus.noLocation:
        page = WeatherNoLocation();
        break;
      case AppStatus.noInternet:
        page = WeatherNoConnectvity();
        break;
      case AppStatus.ok:
        page = WeatherHome(location: location,);
        break;
      case AppStatus.undefined:
        page = new Text('loading');
        break;
    }
    return page;
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RootPage(
      child: getPage(),
      isConnectedToNet: _connectionStatus != null ? _connectionStatus : false,
      hasLocationAccess: _hasLocation != null ? _hasLocation : false,
    );
  }
}

class RootPage extends InheritedWidget {
  final bool hasLocationAccess;
  final bool isConnectedToNet;
  RootPage(
      {Key key,
      this.child,
      @required this.isConnectedToNet,
      @required this.hasLocationAccess})
      : super(key: key, child: child);

  final Widget child;

  static RootPage of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(RootPage) as RootPage);
  }

  @override
  bool updateShouldNotify(RootPage oldWidget) {
    return isConnectedToNet &&
        hasLocationAccess != oldWidget.isConnectedToNet &&
        oldWidget.hasLocationAccess;
  }
}
