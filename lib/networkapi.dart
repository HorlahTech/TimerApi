import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:untitled1/new_location.dart';

class NetworkHelper {
  var url;
  NetworkHelper(this.url);

  Future<dynamic> postData() async {
    var locationValue = NewLocation();
    await locationValue.getUserLocation();

    var apiBody = {
      'AttendanceId': 1153,
      'UserId': 9,
      'Latitude': locationValue.latitude,
      'Longitude': locationValue.longitude,
      'ReturnMessage': 1234,
      'Location': locationValue.address,
    };
    var setHeaders = {
      'Content-type': ' application/json ',
      'Accept': ' application/json ',
    };
    try {
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(apiBody), headers: setHeaders);
      if (response.statusCode == 200) {
        print("${response.body}");
        return response.body;
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print("ernnnnnror: $e");
    }
  }
}
