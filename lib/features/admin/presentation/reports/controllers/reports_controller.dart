import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golf_society/features/admin/application/admin_action_service.dart';

class ReportsController extends Notifier<void> {
  @override
  void build() {}

  Future<void> exportReport({
    required String type,
    required String format,
    required void Function() onSuccess,
  }) async {
    final service = ref.read(adminActionServiceProvider);
    
    await service.exportData(
      format: format,
      reportType: type,
    );

    onSuccess();
  }
}

final reportsControllerProvider = NotifierProvider.autoDispose<ReportsController, void>(
  ReportsController.new,
);
