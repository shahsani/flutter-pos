import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../domain/repositories/customer_repository.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Customers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/customers/add'),
        child: const Icon(Icons.add),
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return const Center(child: Text('No customers found', style: TextStyle(fontSize: 16)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(customer.name[0].toUpperCase()),
                  ),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(customer.phone ?? customer.email ?? 'No contact info'),
                  onTap: () => context.push('/customers/edit/${customer.id}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
