// lib/screens/merchant/addresses/map_create_tab.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:qrdapp/services/addresses/addresses_services.dart';
import 'package:qrdapp/models/location.dart';

class MapCreateTab extends StatefulWidget {
  final int merchantId;
  const MapCreateTab({super.key, required this.merchantId});

  @override
  State<MapCreateTab> createState() => _MapCreateTabState();
}

class _MapCreateTabState extends State<MapCreateTab> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  String? _locationName;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _adding = false;

  static const _nominatimUrl = 'https://nominatim.openstreetmap.org/search';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() => _isSearching = true);
    final uri = Uri.parse(_nominatimUrl).replace(queryParameters: {
      'q': query,
      'format': 'json',
      'addressdetails': '1',
      'limit': '5',
    });
    try {
      final resp = await http.get(uri, headers: {
        'User-Agent': 'qrdapp',
      });
      if (resp.statusCode == 200) {
        final List data = jsonDecode(resp.body);
        setState(() {
          _searchResults = data
              .map((e) => {
                    'name': e['display_name'],
                    'lat': double.parse(e['lat']),
                    'lon': double.parse(e['lon']),
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lon = result['lon'] as double;
    final displayName = result['name'] as String;
    final pos = LatLng(lat, lon);
    _mapController.move(pos, 15);

    // Split the display_name by comma and take the first few parts
    final addressParts = displayName.split(',');
    String conciseLocationName = '';
    if (addressParts.isNotEmpty) {
      conciseLocationName += addressParts[0].trim(); // First part (e.g., street)
      if (addressParts.length > 1) {
        conciseLocationName += ', ${addressParts[1].trim()}'; // Second part (e.g., neighborhood/city)
      }
      if (addressParts.length > 2 && conciseLocationName.split(',').length < 2) {
        conciseLocationName += ', ${addressParts[2].trim()}'; // Third part, if needed and not redundant
      }
    } else {
      conciseLocationName = displayName; // Fallback to the full name if splitting fails
    }

    setState(() {
      _selectedLocation = pos;
      _locationName = conciseLocationName;
      _searchResults = [];
      _searchController.text = displayName; // Keep the full name in the search bar
    });
  }

  Future<void> _addLocation() async {
    if (_selectedLocation == null || _locationName == null) return;
    setState(() => _adding = true);
    final loc = LocationModel(
      merchantId: widget.merchantId,
      name: _locationName!,
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
    );
    try {
      await AddressService.addLocation(loc);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location added')));
      setState(() {
        _selectedLocation = null;
        _locationName = null;
        _searchController.clear();
      });
    } catch (e) {
      debugPrint('Add failed: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add failed')));
    } finally {
      setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(-1.286389, 36.817223),
            zoom: 13,
            onTap: (tap, latlng) => setState(() {
              _selectedLocation = latlng;
              _locationName = null;
            }),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 50,
                    height: 50,
                    builder: (_) => const Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            children: [
              _buildSearchField(),
              if (_isSearching) const LinearProgressIndicator(),
              if (_searchResults.isNotEmpty) _buildResultList(),
            ],
          ),
        ),
        if (_selectedLocation != null && _locationName != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationName!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _adding ? null : _addLocation,
                      icon: const Icon(Icons.add_location),
                      label: Text(_adding ? 'Adding…' : 'Add Location'),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField() => Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: TextField(
          controller: _searchController,
          onSubmitted: _searchLocation,
          decoration: InputDecoration(
            hintText: 'Search location…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchLocation(_searchController.text),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      );

  Widget _buildResultList() => Container(
        margin: const EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _searchResults.length,
          itemBuilder: (ctx, i) {
            final r = _searchResults[i];
            return ListTile(
              title: Text(r['name']),
              subtitle: Text('Lat: ${r['lat']}, Lon: ${r['lon']}'),
              onTap: () => _selectResult(r),
            );
          },
        ),
      );
}
