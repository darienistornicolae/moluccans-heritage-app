import 'dart:convert';
import 'package:http/http.dart' as http;
import 'route_model.dart';

class MapboxService {
  final String accessToken = 
      'pk.eyJ1Ijoib3NtYW4yMDAwIiwiYSI6ImNtaXl3MHV5cTBtc2EzZXM3djdrZHJuMDAifQ.KsFzVUmVQoSJJCyNBLosMQ';

  Future<RouteModel?> getRoute(
    double startLng,
    double startLat,
    double endLng,
    double endLat,
  ) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/walking/$startLng,$startLat;$endLng,$endLat?geometries=geojson&steps=true&access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return RouteModel.fromJson(data);
      } else {
        print('API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }
}