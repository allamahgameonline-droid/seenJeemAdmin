import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_data_table.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';
import 'package:intl/intl.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  CategoryModel? _editingCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showCategoryDialog([CategoryModel? category]) {
    _editingCategory = category;
    if (category != null) {
      _nameController.text = category.name;
      _descriptionController.text = category.description;
    } else {
      _nameController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Name',
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CustomButton(
            text: 'Save',
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final categoryModel = CategoryModel(
                  id: _editingCategory?.id ?? '',
                  name: _nameController.text,
                  description: _descriptionController.text,
                  isActive: _editingCategory?.isActive ?? true,
                  createdAt: _editingCategory?.createdAt ?? DateTime.now(),
                );

                if (_editingCategory == null) {
                  await _firestoreService.addCategory(categoryModel);
                } else {
                  await _firestoreService.updateCategory(_editingCategory!.id, categoryModel);
                }

                if (mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                CustomButton(
                  text: 'Add Category',
                  icon: Icons.add,
                  onPressed: () => _showCategoryDialog(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: StreamBuilder<List<CategoryModel>>(
                stream: _firestoreService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];
                  
                  if (categories.isEmpty) {
                    return EmptyState(
                      icon: Icons.category_outlined,
                      title: 'No Categories',
                      message: 'Get started by adding your first category.',
                      action: CustomButton(
                        text: 'Add Category',
                        icon: Icons.add,
                        onPressed: () => _showCategoryDialog(),
                      ),
                    );
                  }

                  final rows = categories.map((category) {
                    return [
                      category.name,
                      category.description,
                      category.isActive ? 'Active' : 'Inactive',
                      DateFormat('MMM dd, yyyy').format(category.createdAt),
                    ];
                  }).toList();

                  return CustomDataTable(
                    columns: const ['Name', 'Description', 'Status', 'Created At'],
                    rows: rows,
                    onEdit: (index) => _showCategoryDialog(categories[index]),
                    onDelete: (index) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Category'),
                          content: const Text('Are you sure you want to delete this category?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _firestoreService.deleteCategory(categories[index].id);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
