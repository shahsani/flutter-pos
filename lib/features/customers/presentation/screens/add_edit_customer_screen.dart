import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/customer.dart';
import '../../domain/repositories/customer_repository.dart';

class AddEditCustomerScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const AddEditCustomerScreen({super.key, this.customerId});

  @override
  ConsumerState<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends ConsumerState<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);
    try {
      final customer = await ref.read(customerRepositoryProvider).getCustomerById(widget.customerId!);
      if (customer != null) {
        _nameController.text = customer.name;
        _phoneController.text = customer.phone ?? '';
        _emailController.text = customer.email ?? '';
        _addressController.text = customer.address ?? '';
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customerId == null ? 'Add Customer' : 'Edit Customer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveCustomer,
                      child: Text(widget.customerId == null ? 'Create Customer' : 'Update Customer'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customer = Customer(
        id: widget.customerId ?? const Uuid().v4(),
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        address: _addressController.text.isEmpty ? null : _addressController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ref.read(customerRepositoryProvider);
      
      if (widget.customerId == null) {
        await repository.createCustomer(customer);
      } else {
        await repository.updateCustomer(customer);
      }

      if (mounted) {
        ref.refresh(customersProvider);
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
