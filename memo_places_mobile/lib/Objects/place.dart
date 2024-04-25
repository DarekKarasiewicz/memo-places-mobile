class Place {
  final int id;
  final String placeName;
  final String description;
  final String creationDate;
  final String foundDate;
  final double lng;
  final double lat;
  final int user;
  final String username;
  final int sortof;
  final int type;
  final int period;
  final String topicLink;
  final String wikiLink;
  final String img;

  const Place(
      {required this.id,
      required this.placeName,
      required this.description,
      required this.creationDate,
      required this.foundDate,
      required this.lng,
      required this.lat,
      required this.user,
      required this.username,
      required this.sortof,
      required this.type,
      required this.period,
      this.topicLink = '',
      this.wikiLink = '',
      this.img = ''});

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int,
      placeName: json['place_name'] as String,
      description: json['description'] as String,
      creationDate: json['creation_date'] as String,
      foundDate: json['found_date'] as String,
      lng: json['lng'] as double,
      lat: json['lat'] as double,
      user: json['user'] as int,
      username: json['username'] as String,
      sortof: json['sortof'] as int,
      type: json['type'] as int,
      period: json['period'] as int,
      topicLink: json['topic_link'] as String? ?? '',
      wikiLink: json['wiki_link'] as String? ?? '',
      img: json['img'] as String? ?? '',
    );
  }
}
