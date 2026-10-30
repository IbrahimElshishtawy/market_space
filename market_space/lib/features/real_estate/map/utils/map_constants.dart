import 'package:latlong2/latlong.dart';

class MapConstants {
  static const String openStreetMapTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String mapAttribution = '© OpenStreetMap contributors';

  static const LatLng defaultCenter = LatLng(30.7865, 31.0004); // Tanta, Egypt
  static const double defaultZoom = 13.5;
  static const double minZoom = 5.0;
  static const double maxZoom = 18.0;
}
