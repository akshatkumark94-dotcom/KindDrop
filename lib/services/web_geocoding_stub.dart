class Placemark {
  final String? locality;
  final String? administrativeArea;
  Placemark({this.locality, this.administrativeArea});
}

Future<List<Placemark>> placemarkFromCoordinates(double lat, double lng) async {
  return [];
}
