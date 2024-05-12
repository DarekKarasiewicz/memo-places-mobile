import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:memo_places_mobile/TrailRecordPageWidgets/recordMenu.dart';
import 'package:memo_places_mobile/l10n/l10n.dart';
import 'package:memo_places_mobile/trailForm.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrailRecordPage extends StatefulWidget {
  final LatLng startLocation;

  const TrailRecordPage({super.key, required this.startLocation});

  @override
  State<StatefulWidget> createState() => _TrailRecordState();
}

class _TrailRecordState extends State<TrailRecordPage> {
  late GoogleMapController mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  late LatLng currentPosition;
  late List<LatLng> trailsPoints = [];
  bool isRecording = false;
  late StreamSubscription<Position> _positionStreamSubscription;
  double totalDistanceKm = 0.0;
  Timer? _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    currentPosition = widget.startLocation;
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    _timer?.cancel();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _startLocationUpdates() {
    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        _updateUserMarker();
        if (isRecording == true) {
          trailsPoints.add(LatLng(position.latitude, position.longitude));
          _updateRecordedPolyline();
          _updateDistance();
        }
      });
    });
  }

  void _updateUserMarker() {
    Set<Marker> updatedMarkers = _markers.union({
      Marker(
        markerId: const MarkerId("user_location"),
        position: currentPosition,
        icon: BitmapDescriptor.defaultMarker,
        consumeTapEvents: true,
      ),
    });

    setState(() {
      _markers = updatedMarkers;
    });
  }

  void _updateRecordedPolyline() {
    Set<Polyline> updatedPolylines = _polylines.union({
      Polyline(
          polylineId: const PolylineId("recorded_trail_polyline"),
          visible: true,
          points: trailsPoints,
          width: 10,
          color: const Color.fromARGB(137, 33, 75, 243),
          startCap: Cap.roundCap,
          endCap: Cap.roundCap),
    });

    setState(() {
      _polylines = updatedPolylines;
    });
  }

  void _updateDistance() {
    if (trailsPoints.length > 1) {
      double distance = _calculateDistance(
          trailsPoints[trailsPoints.length - 2], trailsPoints.last);
      totalDistanceKm += distance;
    }
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371.0;

    double lat1 = start.latitude * pi / 180.0;
    double lon1 = start.longitude * pi / 180.0;
    double lat2 = end.latitude * pi / 180.0;
    double lon2 = end.longitude * pi / 180.0;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;
    return distance;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
        if (_seconds == 60) {
          _seconds = 0;
          _minutes++;
          if (_minutes == 60) {
            _minutes = 0;
            _hours++;
          }
        }
      });
    });
  }

  String _formatTime(int time) {
    return time.toString().padLeft(2, '0');
  }

  String get _formattedTime {
    return '${_formatTime(_hours)}:${_formatTime(_minutes)}:${_formatTime(_seconds)}';
  }

  void _startRecording() {
    _startTimer();
    setState(() {
      isRecording = true;
    });
  }

  void _endRecording() {
    _timer?.cancel();
    setState(() {
      isRecording = false;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => TrailForm(
                trailCoordinates: trailsPoints,
                distance: totalDistanceKm.toStringAsFixed(3),
                time: _formattedTime,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: L10n.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  initialCameraPosition:
                      CameraPosition(target: currentPosition, zoom: 16),
                ),
                RecordMenu(
                  distance: totalDistanceKm.toStringAsFixed(3),
                  isRecording: isRecording,
                  time: _formattedTime,
                  startRecording: _startRecording,
                  endRecording: _endRecording,
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.newLatLng(trailsPoints.isEmpty
                            ? widget.startLocation
                            : trailsPoints.last),
                      );
                    },
                    child: const Icon(Icons.location_searching),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
