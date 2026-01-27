import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../models/report_models.dart';
import '../../data/repositories/report_repository_impl.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.value?.id;
  if (userId == null) {
    throw Exception('User not authenticated');
  }
  return ReportRepositoryImpl(DatabaseHelper.instance, userId);
});

final salesReportProvider = FutureProvider.family<SalesReport, ReportDateRange>(
  (ref, range) {
    final repository = ref.watch(reportRepositoryProvider);
    return repository.getSalesReport(range.start, range.end);
  },
);

final topSellingItemsProvider =
    FutureProvider.family<List<TopSellingItem>, ReportDateRange>((ref, range) {
      final repository = ref.watch(reportRepositoryProvider);
      return repository.getTopSellingItems(range.start, range.end);
    });

// Helper for date ranges
class ReportDateRange extends Equatable {
  final DateTime start;
  final DateTime end;
  const ReportDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

abstract class ReportRepository {
  Future<SalesReport> getSalesReport(DateTime start, DateTime end);
  Future<List<TopSellingItem>> getTopSellingItems(DateTime start, DateTime end);
}
