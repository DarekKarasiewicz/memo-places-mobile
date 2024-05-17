import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memo_places_mobile/AppNavigation/addingButton.dart';
import 'package:memo_places_mobile/MainPageWidgets/previewPlace.dart';
import 'package:memo_places_mobile/MainPageWidgets/prewiewTrail.dart';
import 'package:memo_places_mobile/Objects/currnetObject.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/Theme/theme.dart';
import 'package:memo_places_mobile/Theme/themeProvider.dart';
import 'package:memo_places_mobile/translations/locale_keys.g.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State {
  late GoogleMapController mapController;
  late String _mapStyleString;
  String? _access;
  late LatLng _position = const LatLng(0.0, 0.0);
  bool isLoading = true;
  bool isSelectedPlace = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<Place> _places = [];
  List<Trail> _trails = [];
  late CurrentObject selectedObject;
  late StreamSubscription<Position> _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _loadCounter('access').then((value) => _access = value);
    _getCurrentLocation().then((location) => {
          setState(() {
            _position = LatLng(location.latitude, location.longitude);
          }),
          _startLocationUpdates(),
          _fetchPlaces(),
          _fetchTrails(),
          setState(() {
            isLoading = false;
          })
        });
    Provider.of<ThemeProvider>(context, listen: false)
        .addListener(_loadMapStyle);
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    mapController.dispose();
    Provider.of<ThemeProvider>(context, listen: false)
        .removeListener(_loadMapStyle);

    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    String stylePath =
        Provider.of<ThemeProvider>(context, listen: false).themeData ==
                lightTheme
            ? 'lib/assets/map_styles/light_map_style.json'
            : 'lib/assets/map_styles/dark_map_style.json';
    _mapStyleString =
        await DefaultAssetBundle.of(context).loadString(stylePath);
    setState(() {});
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _startLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _position = LatLng(position.latitude, position.longitude);
        _updateUserMarker();
      });
    });
  }

  void _updateUserMarker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('lib/assets/markers/user_marker.PNG', 80);

    Set<Marker> updatedMarkers = _markers.union({
      Marker(
        markerId: const MarkerId("user_location"),
        position: _position,
        icon: BitmapDescriptor.fromBytes(markerIcon),
      ),
    });

    setState(() {
      _markers = updatedMarkers;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _setObject(Place? place, Trail? trail) {
    setState(() {
      isSelectedPlace = true;
      if (place == null) {
        selectedObject = CurrentObject(null, trail);
      } else {
        selectedObject = CurrentObject(place, null);
      }
    });
  }

  void closePreview() {
    setState(() {
      isSelectedPlace = false;
    });
  }

  Future<void> _fetchPlaces() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/memo_places/places/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _places = jsonData.map((data) => Place.fromJson(data)).toList();
        _markers.addAll(_places.map((place) {
          return Marker(
            markerId: MarkerId(place.id.toString()),
            position: LatLng(place.lat, place.lng),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            consumeTapEvents: true,
            onTap: () => _setObject(place, null),
          );
        }).toSet());
      });
    } else {
      throw Exception(LocaleKeys.failed_load_places.tr());
    }
  }

  Future<void> _fetchTrails() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/memo_places/path/'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      setState(() {
        _trails = jsonData.map((data) => Trail.fromJson(data)).toList();
        _polylines.addAll(_trails.map((trail) {
          return Polyline(
            polylineId: PolylineId(trail.id.toString()),
            visible: true,
            points: trail.coordinates,
            width: 10,
            color: const Color.fromARGB(137, 33, 75, 243),
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            consumeTapEvents: true,
            onTap: () => _setObject(null, trail),
          );
        }).toSet());
      });
    } else {
      throw Exception(LocaleKeys.failed_load_trails.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget signInAccess = const SizedBox();

    if (_access != null) {
      signInAccess = AddingButton(_position);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.scrim),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) {
                        mapController = controller;
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition:
                          CameraPosition(target: _position, zoom: 12.0),
                      markers: _markers,
                      polylines: _polylines,
                      style: _mapStyleString,
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: FloatingActionButton(
                        heroTag: 'locateMe',
                        onPressed: () {
                          mapController.animateCamera(
                            CameraUpdate.newLatLng(_position),
                          );
                        },
                        child: const Icon(Icons.location_searching),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: FloatingActionButton(
                        heroTag: 'toggleTheme',
                        onPressed: () {
                          Provider.of<ThemeProvider>(context, listen: false)
                              .toggleTheme();
                        },
                        child: Icon(
                            Provider.of<ThemeProvider>(context, listen: false)
                                        .themeData ==
                                    lightTheme
                                ? Icons.light_mode
                                : Icons.dark_mode),
                      ),
                    ),
                    isSelectedPlace
                        ? Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: selectedObject.place == null
                                ? PreviewTrail(
                                    closePreview, selectedObject.trail!)
                                : PreviewPlace(
                                    closePreview, selectedObject.place!))
                        : signInAccess,
                  ],
                ),
        ),
      ),
    );
  }
}
