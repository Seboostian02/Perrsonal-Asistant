import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Serviciul de locație este dezactivat.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permisiunea de locație a fost refuzată.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permisiunea de locație este permanent refuzată, nu se poate solicita.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
