import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../models/customer.dart';
import '../../data/repositories/customer_repository_impl.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(DatabaseHelper.instance);
});

final customersProvider = FutureProvider<List<Customer>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomers();
});

final customerProvider = FutureProvider.family<Customer?, String>((ref, id) {
  final repository = ref.watch(customerRepositoryProvider);
  return repository.getCustomerById(id);
});

abstract class CustomerRepository {
  Future<List<Customer>> getCustomers();
  Future<Customer?> getCustomerById(String id);
  Future<void> createCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
}
