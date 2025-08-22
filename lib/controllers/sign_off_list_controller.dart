import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../models/sign_off_models/sign_off.dart';
import '../repositories/sign_off_services.dart';

class SignOffListController extends GetxController {
  final service = SignOffService(
    const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://jl-trail-gps-tracker-backend-production.up.railway.app',
    ),
  );

  var page = 1.obs;
  final pageSize = 20;
  var total = 0.obs;
  final searchCtl = TextEditingController();

  int get totalPages => (total.value / pageSize).ceil().clamp(1, 9999);

  final items = <SignOff>[].obs;

  Future<void> refreshList() async {
    // send pagination params to service
    final res = await service.list(
      page: page.value,
      pageSize: pageSize,
      search: searchCtl.text,
    );

    final list = res['items'] as List<dynamic>;
    total.value = res['total'] ?? 0;
    items.value = list.map((e) => SignOff.fromJson(e)).toList();
  }

  Future<void> deleteItem(int id) async {
    await service.remove(id);
    await refreshList();
  }

  @override
  void onInit() {
    super.onInit();
    refreshList();
  }

  void nextPage() {
    if (page.value < totalPages) {
      page.value++;
      refreshList();
    }
  }

  void prevPage() {
    if (page.value > 1) {
      page.value--;
      refreshList();
    }
  }
}
