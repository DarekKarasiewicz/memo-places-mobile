import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memo_places_mobile/AppNavigation/addingButton.dart';
import 'package:memo_places_mobile/MainPageWidgets/previewPlace.dart';
import 'package:memo_places_mobile/MainPageWidgets/prewiewTrail.dart';
import 'package:memo_places_mobile/Objects/currnetObject.dart';
import 'package:memo_places_mobile/Objects/place.dart';
import 'package:memo_places_mobile/Objects/trail.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State {
  late GoogleMapController mapController;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? _access;
  late LatLng _position;
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
  }

  Future<String?> _loadCounter(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  void _incrementCounter(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
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

  void _updateUserMarker() {
    Set<Marker> updatedMarkers = _markers.union({
      Marker(
        markerId: const MarkerId("user_location"),
        position: _position,
        icon: BitmapDescriptor.defaultMarker,
      ),
    });

    setState(() {
      _markers = updatedMarkers;
    });
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
      throw Exception(AppLocalizations.of(context)!.failedLoadPlaces);
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
      throw Exception(AppLocalizations.of(context)!.failedLoadTrails);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: _onMapCreated,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      initialCameraPosition:
                          CameraPosition(target: _position, zoom: 12.0),
                      markers: _markers,
                      polylines: _polylines,
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
                        : AddingButton(_position),
                  ],
                ),
        ),
      ),
    );
  }
}
