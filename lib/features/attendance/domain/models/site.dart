class Site {
  final String? siteName;
  final int? radius;
  final Location? location;

  Site({this.siteName, this.radius, this.location});

  Map<String, dynamic> toJson() {
    return {
      "site_name": this.siteName,
      "radius": this.radius,
      "location": this.location?.toJson(),
    };
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
        siteName: json["site_name"],
        radius:json["radius"],
        location: Location.fromJson(json["location"]));
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  Map<String, dynamic> toJson() {
    return {
      "lat": this.lat,
      "lng": this.lng,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: double.parse(json["lat"].toString()),
      lng: double.parse(json["lng"].toString()),
    );
  }
}
