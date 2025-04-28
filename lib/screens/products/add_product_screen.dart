import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qrdapp/services/addresses/addresses_services.dart';
import 'package:qrdapp/models/location.dart';
import 'package:qrdapp/widgets/input_field_widget.dart';
import 'package:qrdapp/services/products/products_service.dart';
import 'package:qrdapp/services/categories/categories_service.dart'; // Import CategoryService
import 'package:qrdapp/services/auth/auth_storage.dart'; // Import for merchant ID
import 'dart:convert'; // Import for JSON encoding

class AddProductScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  List<String> _selectedSalesLocations = [];
  List<LocationModel> _locations = [];
  bool _isLoading = false;
  int? _categoryId;
  List<Map<String, dynamic>> _categories = []; // To store fetched categories.
  int? _merchantId; // To store the merchant ID
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    print("AddProductScreen initState called");
    _loadData(); // Load both locations and categories
    // Initialize controllers with product data if editing
    if (widget.product != null) {
      print("Editing existing product");
      _itemNameController.text = widget.product!['name'] ?? '';
      _itemPriceController.text =
          widget.product!['price']?.toString() ?? '';
      _itemDescriptionController.text =
          widget.product!['description'] ?? '';
      if (widget.product!['locations'] != null) {
        // Directly assign if it's already a List<String>
        if (widget.product!['locations'] is List) {
          _selectedSalesLocations = (widget.product!['locations'] as List).cast<String>();
        } else if (widget.product!['locations'] is String) {
          // If it's a JSON string, decode it
          try {
            _selectedSalesLocations = (jsonDecode(widget.product!['locations']) as List).cast<String>();
          } catch (e) {
            print("Error decoding locations: $e");
            _selectedSalesLocations = [];
          }
        }
      }
      _categoryId = widget.product!['category_id'];
      print("Initial _categoryId (editing): $_categoryId");
      print("Initial _selectedSalesLocations (editing): $_selectedSalesLocations");
    } else {
      print("Adding a new product");
    }
  }

  Future<void> _loadData() async {
    if (_disposed) {
      print("_loadData aborted: widget is disposed");
      return; // Don't proceed if widget is disposed
    }
    setState(() {
      _isLoading = true;
      print("_loadData: _isLoading set to true");
    });
    try {
      // Load merchant ID first
      _merchantId = await SecureStorageService.getUserId();
      print("_loadData: _merchantId fetched: $_merchantId");
      if (_merchantId == null) {
        throw Exception("Merchant ID is null"); // Handle the null case appropriately
      }

      // Load locations
      _locations =
          await AddressService.getLocations(_merchantId!); // Use merchant ID
      print("_loadData: _locations fetched: ${_locations.map((l) => l.name).toList()}");

      // Load categories
      _categories = await CategoryService
          .fetchCategoriesByMerchantId(); // Use merchant ID
      print("_loadData: _categories fetched: $_categories");
      if (_categories.isNotEmpty && _categoryId == null && widget.product == null) {
        if (_disposed) {
          print("_loadData (categories): widget is disposed");
          return;
        }
        setState(() {
          _categoryId = _categories[0]['ID']; // Access 'ID' from the response
          print("_loadData: _categoryId set to: $_categoryId");
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted && !_disposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted && !_disposed) {
        setState(() {
          _isLoading = false;
          print("_loadData: _isLoading set to false");
        });
      }
    }
  }

  void _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final itemName = _itemNameController.text;
      final itemPrice = double.tryParse(_itemPriceController.text) ?? 0.0;
      final itemDescription = _itemDescriptionController.text;
      final locations = _selectedSalesLocations;

      setState(() {
        _isLoading = true;
        print("_addProduct: _isLoading set to true");
      });
      try {
        if (widget.product == null) {
          // Add new product
          await ProductService.addProduct(
            name: itemName,
            description: itemDescription,
            price: itemPrice,
            categoryId: _categoryId!, // Ensure categoryId is not null
            location: jsonEncode(locations), // Send as JSON array string
          );
          if (mounted && !_disposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product added successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Edit existing product
          await ProductService.updateProduct(
            productId: widget.product!['id'],
            name: itemName,
            description: itemDescription,
            price: itemPrice,
            categoryId: _categoryId!,
            location: jsonEncode(locations), // Send as JSON array string
          );
          if (mounted && !_disposed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Product updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }

        // Return to previous screen and indicate success
        if (mounted && !_disposed) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        // Show error message
        if (mounted && !_disposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add/update product: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
          Navigator.of(context).pop(false); // Return failure
        }
      } finally {
        if (mounted && !_disposed) {
          setState(() {
            _isLoading = false;
            print("_addProduct: _isLoading set to false");
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    print("AddProductScreen disposed");
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("AddProductScreen build called with _categories: $_categories, _categoryId: $_categoryId, _locations: ${_locations.map((l) => l.name).toList()}, _selectedSalesLocations: $_selectedSalesLocations");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Item Name
              InputFieldWidget(
                controller: _itemNameController,
                label: 'Item Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price
              InputFieldWidget(
                controller: _itemPriceController,
                label: 'Price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Invalid price format';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              InputFieldWidget(
                controller: _itemDescriptionController,
                label: 'Description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<int>(
                value: _categoryId,
                onChanged: (newValue) {
                  setState(() {
                    _categoryId = newValue;
                    print("Category dropdown changed to: $_categoryId");
                  });
                },
                items: _categories.map((category) {
                  print("Mapping category: ${category['name']} with ID: ${category['ID']}");
                  return DropdownMenuItem<int>(
                    value: category['ID'], // Use 'ID' from the response
                    child: Text(category['name'] ?? 'No Name'),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
              ),
              const SizedBox(height: 16),

              // Multi-Location Selection
              const Text(
                'Sales Locations',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedSalesLocations.map((locationName) {
                  return Chip(
                    label: Text(locationName),
                    onDeleted: () {
                      setState(() {
                        _selectedSalesLocations.remove(locationName);
                      });
                    },
                    deleteIcon: const Icon(Icons.cancel),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: null, //  start with null
                onChanged: (newValue) {
                  setState(() {
                    if (newValue != null &&
                        !_selectedSalesLocations.contains(newValue)) {
                      _selectedSalesLocations.add(newValue);
                    }
                  });
                },
                items: _locations.map((location) {
                  final isSelected = _selectedSalesLocations.contains(location.name); // Check if selected
                  print("Mapping location: ${location.name}, isSelected: $isSelected");
                  return DropdownMenuItem<String>(
                    value: location.name,
                    enabled: !isSelected, // Disable already selected locations
                    child: Text(location.name ?? ''),
                  );
                }).toList(),
                validator: (value) {
                  if (_selectedSalesLocations.isEmpty) {
                    return 'Please select at least one sales location';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Add Location',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
              ),
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.product == null
                              ? 'Add Product'
                              : 'Update Product',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Update ProductService signatures to accept List<String>:
// static Future<void> addProduct({
//   required String name,
//   required String description,
//   required double price,
//   required int categoryId,
//   required String location, // Changed to List<String?> or handle JSON encoding here
// }) async { ... }

// static Future<void> updateProduct({
//   required int productId,
//   required String name,
//   required String description,
//   required double price,
//   required int categoryId,
//   required String location, // Changed to List<String?> or handle JSON encoding here
// }) async { ... }