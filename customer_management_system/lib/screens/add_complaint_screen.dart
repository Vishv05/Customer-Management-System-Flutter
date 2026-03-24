import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddComplaintScreen extends StatefulWidget {
  final String userEmail;

  const AddComplaintScreen({super.key, required this.userEmail});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Product Quality';
  String _selectedPlatform = 'Amazon';
  String _selectedProductCategory = 'Electronics';

  final List<String> _categories = [
    'Product Quality',
    'Delivery Delay',
    'Poor Customer Service',
    'Billing Issue',
    'Other',
  ];

  final List<String> _productCategories = [
    'Electronics',
    'Clothing & Fashion',
    'Home & Furniture',
    'Books & Media',
    'Sports & Outdoors',
    'Beauty & Personal Care',
    'Food & Groceries',
    'Toys & Games',
    'Health & Wellness',
    'Automotive',
    'Pet Supplies',
    'Office & Stationery',
  ];

  final List<String> _platforms = [
    'Amazon',
    'Flipkart',
    'Myntra',
    'Ajio',
    'eBay',
    'Snapdeal',
    'Meesho',
    'Nykaa',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.userEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Complaint'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Submit Complaint',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Help us improve our service',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter your address',
                  prefixIcon: const Icon(Icons.home_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Complaint Title',
                  hintText: 'Enter complaint title',
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedProductCategory,
                decoration: InputDecoration(
                  labelText: 'Product Category',
                  prefixIcon: const Icon(Icons.shopping_bag),
                  suffixIcon: const Icon(Icons.arrow_drop_down),
                  filled: true,
                  fillColor: const Color(0xFFF5F5FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _productCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductCategory = value ?? 'Electronics';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category),
                  filled: true,
                  fillColor: const Color(0xFFF5F5FF),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 'Product Quality';
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPlatform,
                decoration: InputDecoration(
                  labelText: 'Platform',
                  prefixIcon: const Icon(Icons.storefront),
                  filled: true,
                  fillColor: const Color(0xFFF5F5FF),
                ),
                items: _platforms.map((platform) {
                  return DropdownMenuItem(
                    value: platform,
                    child: Text(platform),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPlatform = value ?? 'Amazon';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter complaint description',
                  prefixIcon: const Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                      ),
                      child: const SizedBox(
                        height: 54,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final customerName = _nameController.text.trim();
                        final customerEmail = _emailController.text.trim();
                        final customerPhone = _phoneController.text.trim();
                        final customerAddress = _addressController.text.trim();
                        final title = _titleController.text.trim();
                        final description = _descriptionController.text.trim();
                        final submittedBy = customerEmail;

                        if (customerName.isEmpty ||
                            customerEmail.isEmpty ||
                            customerPhone.isEmpty ||
                            customerAddress.isEmpty ||
                            title.isEmpty ||
                            description.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields including customer details'),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                          return;
                        }

                        if (submittedBy.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'User email is missing. Please log in again.',
                              ),
                              backgroundColor: Color(0xFFFF6B6B),
                            ),
                          );
                          return;
                        }

                        // Show loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Submitting complaint...'),
                            backgroundColor: Color(0xFF6C63FF),
                          ),
                        );

                        // Call API
                        final response = await ApiService.addComplaint({
                          'title': title,
                          'productCategory': _selectedProductCategory,
                          'category': _selectedCategory,
                          'platform': _selectedPlatform,
                          'description': description,
                          'customerName': customerName,
                          'customerEmail': customerEmail,
                          'customerPhone': customerPhone,
                          'customerAddress': customerAddress,
                          'submittedBy': submittedBy,
                        });

                        if (!context.mounted) return;
                        if (response.containsKey('error')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                response['error'] ??
                                    'Failed to submit complaint',
                              ),
                              backgroundColor: const Color(0xFFFF6B6B),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Complaint submitted. Admin has been notified.',
                              ),
                              backgroundColor: Color(0xFF00C853),
                            ),
                          );
                          Navigator.pop(context, _titleController.text);
                        }
                      },
                      child: const SizedBox(
                        height: 54,
                        child: Center(
                          child: Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
