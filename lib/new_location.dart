import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;

class NewLocation {
  double? latitude, longitude;
  String? address;

  // Future<void> getlocation() async {
  //   bool serviceEnabled;
  //
  //   LocationPermission permission = await Geolocator.requestPermission();
  //
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.high);
  //     longitude = position.longitude;
  //     latitude = position.latitude;
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(latitude, longitude);
  //     address = placemarks[0].country.toString();
  //   } catch (e) {
  //     print("Errorrrrrrrrrrrrrrrrrrrrrrr$e");
  //   }
  // }
  Future<void> getUserLocation() async {
    try {
      loc.Location location = new loc.Location();
      location.enableBackgroundMode(enable: true);

      bool _serviceEnabled;
      loc.PermissionStatus _permissionGranted;
      loc.LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == loc.PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != loc.PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();

      latitude = _locationData.latitude;
      longitude = _locationData.longitude;

      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude!, longitude!);
      address = placemarks[0].country.toString();
      print(address!);
    } catch (e) {
      print("Errorrrrrrrrrrrrrrrrrrrrrrr$e");
    }
  }
}
