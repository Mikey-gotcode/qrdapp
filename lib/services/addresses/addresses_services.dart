import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qrdapp/models/location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class AddressService {
  static final _baseUrl = dotenv.env['BASE_URL'] ?? 'http://192.168.100.42:8080';

  static Future<void> addLocation(LocationModel loc) async {
    final uri = Uri.parse('$_baseUrl/locations');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loc.toJson()),
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to add location');
    }
  }

  static Future<List<LocationModel>> getLocations(int merchantId) async {
    final response =
        await http.get(Uri.parse('$_baseUrl/merchant/$merchantId/locations'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Assuming response looks like: { "locations": [ { ID: ..., Name: ..., ... }, ... ] }
      final List<dynamic> locationsJson = data['locations'];

      return locationsJson.map((json) => LocationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load locations');
    }
  }

  // New function to get all locations
  static Future<List<LocationModel>> getAllLocations() async {
    final response =
        await http.get(Uri.parse('$_baseUrl/locations')); // Corrected URL

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Assuming the response is directly a list of locations
      final List<dynamic> locationsJson =
          data; //Changed from data['locations'] to data
      return locationsJson.map((json) => LocationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load all locations');
    }
  }

  static Future<void> updateLocation(LocationModel loc) async {
    final uri = Uri.parse('$_baseUrl/location/${loc.id}');
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loc.toJson()),
    );
    if (resp.statusCode != 200) throw Exception('Failed to update');
  }

  static Future<void> deleteLocation(int locationId) async {
    final response =
        await http.delete(Uri.parse('$_baseUrl/location/$locationId'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete location');
    }
  }
}
