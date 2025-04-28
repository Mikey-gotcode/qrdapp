import 'package:flutter/material.dart';
import 'package:qrdapp/models/location.dart';
import 'package:qrdapp/services/addresses/addresses_services.dart';

class ManageLocationsTab extends StatefulWidget {
  final int merchantId;

  const ManageLocationsTab({super.key, required this.merchantId});

  @override
  State<ManageLocationsTab> createState() => _ManageLocationsTabState();
}

class _ManageLocationsTabState extends State<ManageLocationsTab> {
  List<LocationModel> locations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final data = await AddressService.getLocations(widget.merchantId);
      setState(() {
        locations = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> deleteLocation(int locationId) async {
    try {
      await AddressService.deleteLocation(locationId);
      setState(() {
        locations.removeWhere((loc) => loc.id == locationId);
      });
    } catch (e) {
      print('Error deleting location: $e');
    }
  }

  void editLocation(LocationModel location) {
    // Implement edit logic or navigation to edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit not implemented yet for ${location.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : locations.isEmpty
            ? const Center(child: Text("No locations added yet."))
            : ListView.builder(
                itemCount: locations.length,
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.deepPurple),
                      title: Text(location.name ?? 'Unnamed'),
                      subtitle: Text('Lat: ${location.latitude}, Lng: ${location.longitude}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => editLocation(location),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteLocation(location.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
