import 'package:flutter/material.dart';
import 'map_create_tab.dart';
import 'manage_locations_tabs.dart';

class MapScreen extends StatefulWidget {
  final int merchantId; // pass merchant ID

  const MapScreen({super.key, required this.merchantId});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Serviceable Areas"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Create Location"),
            Tab(text: "Manage Locations"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MapCreateTab(merchantId: widget.merchantId),
          ManageLocationsTab(merchantId: widget.merchantId),
        ],
      ),
    );
  }
}
