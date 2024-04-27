import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Trail {
  final int id;
  final String trailName;
  final String description;
  final String creationDate;
  final String foundDate;
  final List<LatLng> coordinates;
  final int user;
  final String username;
  final int type;
  final int period;
  final String topicLink;
  final String wikiLink;
  final String img;

  const Trail(
      {required this.id,
      required this.trailName,
      required this.description,
      required this.creationDate,
      required this.foundDate,
      required this.coordinates,
      required this.user,
      required this.username,
      required this.type,
      required this.period,
      this.topicLink = '',
      this.wikiLink = '',
      this.img = ''});

  factory Trail.fromJson(Map<String, dynamic> json) {
    List<dynamic> coordinatesJson = jsonDecode(json['coordinates']);
    List<LatLng> coordinates = coordinatesJson.map((coord) {
      double lat = coord['lat'];
      double lng = coord['lng'];
      return LatLng(lat, lng);
    }).toList();

    return Trail(
      id: json['id'] as int,
      trailName: json['path_name'] as String,
      description: json['description'] as String,
      creationDate: json['creation_date'] as String? ?? '',
      foundDate: json['found_date'] as String,
      coordinates: coordinates,
      user: json['user'] as int,
      username: json['username'] as String,
      type: json['type'] as int,
      period: json['period'] as int,
      topicLink: json['topic_link'] as String? ?? '',
      wikiLink: json['wiki_link'] as String? ?? '',
      img: json['img'] as String? ?? '',
    );
  }
}