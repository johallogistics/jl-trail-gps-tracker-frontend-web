// lib/controllers/sign_off_list_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../repositories/sign_off_services.dart';

class SignOffListController extends GetxController {
  final service = SignOffService(const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000'));
  var items = <Map<String, dynamic>>[].obs;
  var page = 1.obs;
  final pageSize = 20;
  var total = 0.obs;
  final searchCtl = TextEditingController();

  int get totalPages => (total.value / pageSize).ceil().clamp(1, 9999);

  @override
  void onInit() {
    super.onInit();
    refreshList();
  }

  Future<void> refreshList() async {
    final data = await service.list(page: page.value, pageSize: pageSize, search: searchCtl.text.trim().isEmpty ? null : searchCtl.text.trim());
    items.value = List<Map<String, dynamic>>.from(data['items']);
    total.value = data['total'];
  }

  void nextPage() { if (page.value < totalPages) { page.value++; refreshList(); } }
  void prevPage() { if (page.value > 1) { page.value--; refreshList(); } }

  Future<void> deleteItem(int id) async { await service.remove(id); await refreshList(); }
}