import 'package:flutter/material.dart';
import 'package:qrdapp/screens/categories/add_categories_screen.dart'; // Import the AddCategoryScreen
import 'package:qrdapp/services/categories/categories_service.dart'; // Import the category service
import 'package:qrdapp/services/auth/auth_storage.dart';
// --- category_management_screen.dart ---
class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  final ScrollController _scrollController = ScrollController();
  late int _merchantId; // Use late to initialize in initState

  @override
  void initState() {
    super.initState();
    _loadMerchantIdAndCategories(); // Load merchant ID first
  }

  Future<void> _loadMerchantIdAndCategories() async {
    try {
      final int? merchantId =
          await SecureStorageService.getUserId(); // Initialize _merchantId
      if (merchantId == null) {
        throw Exception("Merchant ID is null");
      }
      _merchantId =
          merchantId; // Assign the non-nullable value after null check.
      _loadCategories(); // Then load categories
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load merchant ID: $e";
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await CategoryService.fetchCategories();
      if (!mounted) return;
      // Ensure it's a List<Map<String, dynamic>>
      _categories = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int categoryId) async {
    try {
      await CategoryService.deleteCategory(
          categoryId:
              categoryId); // Pass the categoryId to the service method.
      await _loadCategories(); // Refresh the list
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category deleted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddCategoryScreen(merchantId: _merchantId, category: category),
      ),
    ).then((result) {
      if (result == true && mounted) {
        _loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Manage Categories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddCategoryScreen(
                          merchantId: _merchantId,
                        ),
                      ),
                    ).then((result) {
                      if (result == true && mounted) {
                        _loadCategories();
                      }
                    });
                  },
                  child: const Text('+ Add a category'),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Center(child: Text('Error: $_errorMessage'))
                else if (_categories.isEmpty)
                  const Center(child: Text('No categories found.'))
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return _buildCategoryItem(context, category);
                    },
                  ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryListScreen(
                              categories: _categories), // Corrected class name
                        ),
                      );
                    },
                    child: const Text('See More'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
      BuildContext context, Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailScreen(
                category: category), // Corrected class name
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.category, size: 60, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              category['name'] ?? 'No Name',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editCategory(category),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCategory(
                      category['id']), // Assuming 'id' is the key
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Category Detail Screen.
class CategoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category['name'] ?? 'Category Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${category['name'] ?? 'N/A'}'),
            Text('Description: ${category['description'] ?? 'N/A'}'),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}

//  Category List Screen.
class CategoryListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  const CategoryListScreen({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['name'] ?? 'N/A'),
            subtitle: Text(category['description'] ?? 'N/A'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryDetailScreen(category: category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}