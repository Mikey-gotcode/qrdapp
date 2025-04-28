import 'package:flutter/material.dart';
import 'package:qrdapp/widgets/input_field_widget.dart';
import 'package:qrdapp/services/categories/categories_service.dart';
import 'package:qrdapp/services/addresses/addresses_services.dart';
import 'package:qrdapp/models/location.dart';
import 'dart:convert'; // Import for JSON encoding

class AddCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category; // category for editing
  final int merchantId;

  const AddCategoryScreen({super.key, this.category, required this.merchantId});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  List<LocationModel> _locations = [];
  List<String> _selectedLocations = [];
  bool _locationsLoading = true;
  String? _locationsError;

  @override
  void initState() {
    super.initState();
    print("AddCategoryScreen initState");
    // populate fields if editing
    if (widget.category != null) {
      _nameController.text = widget.category!['name'] ?? '';
      _descController.text = widget.category!['description'] ?? '';
      if (widget.category!['location'] != null) {
        // Directly assign if it's already a List<String>
        if (widget.category!['location'] is List) {
          _selectedLocations = (widget.category!['location'] as List).cast<String>();
        } else if (widget.category!['location'] is String) {
          // If it's a JSON string, decode it
          try {
            _selectedLocations = (jsonDecode(widget.category!['location']) as List).cast<String>();
          } catch (e) {
            print("Error decoding locations: $e");
            // Handle the error appropriately, maybe set _selectedLocations to empty
            _selectedLocations = [];
          }
        }
      }
    }
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final locs = await AddressService.getLocations(widget.merchantId);
      if (!mounted) return;
      setState(() {
        _locations = locs;
        _locationsLoading = false;
        // Preselect if editing
        if (widget.category != null && widget.category!['location'] != null) {
          if (widget.category!['location'] is List) {
            _selectedLocations = (widget.category!['location'] as List).cast<String>();
          } else if (widget.category!['location'] is String) {
            try {
              _selectedLocations = (jsonDecode(widget.category!['location']) as List).cast<String>();
            } catch (e) {
              print("Error decoding locations: $e");
              _selectedLocations = [];
            }
          }
        } else if (_locations.isNotEmpty && _selectedLocations.isEmpty) {
          final firstLocationName = _locations.first.name;
          if (firstLocationName != null) {
            _selectedLocations.add(firstLocationName);
          }
        }
      });
    } catch (e) {
      setState(() {
        _locationsError = 'Failed to load locations';
        _locationsLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load locations')),
        );
      }
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one location')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final name = _nameController.text;
    final desc = _descController.text;

    // Prepare the locations array
    final List<String?> selectedLocationNames = _selectedLocations;

    try {
      if (widget.category == null) {
        await CategoryService.addCategory(
          name: name,
          description: desc,
          location: selectedLocationNames, // Pass the array of location names
        );
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Category added successfully'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'))
              ],
            ),
          );
        }
      } else {
        //update category
        await CategoryService.updateCategory(
          categoryId: widget.category!['id'],
          name: name,
          description: desc,
          location: selectedLocationNames, // Pass the array of location names
        );
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Category updated successfully'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'))
              ],
            ),
          );
        }
      }
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.category == null ? 'Add Category' : 'Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _locationsLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    InputFieldWidget(
                      controller: _nameController,
                      label: 'Category Name',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter name' : null,
                    ),
                    const SizedBox(height: 12),
                    InputFieldWidget(
                      controller: _descController,
                      label: 'Description',
                      maxLines: 3,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Enter description' : null,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Locations',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedLocations.map((locationName) {
                        return Chip(
                          label: Text(locationName),
                          onDeleted: () {
                            setState(() {
                              _selectedLocations.remove(locationName);
                            });
                          },
                          deleteIcon: const Icon(Icons.cancel),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: null,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null &&
                              !_selectedLocations.contains(newValue)) {
                            _selectedLocations.add(newValue);
                          }
                        });
                      },
                      items: _locations.map((loc) {
                        final isSelected = _selectedLocations.contains(loc.name);
                        return DropdownMenuItem(
                          value: loc.name,
                          enabled: !isSelected,
                          child: Text(loc.name ?? 'Unnamed'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (_selectedLocations.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCategory,
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : Text(widget.category == null
                              ? 'Add Category'
                              : 'Update Category'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// Update CategoryService signatures to accept List<String>:
// static Future<void> addCategory({required String name, required String description, required List<String?> location})
// static Future<void> updateCategory({required int categoryId, required String name, required String description, required List<String?> location});