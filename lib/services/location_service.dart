import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Serviciul de locație este dezactivat.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permisiunea de locație a fost refuzată.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permisiunea de locație este permanent refuzată.';
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<List<Location>> getLocationFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      throw 'Nu s-a putut obține locația pentru adresa: $address';
    }
  }
}
