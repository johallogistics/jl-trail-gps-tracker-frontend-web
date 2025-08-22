// lib/admin/sign_off_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sign_off_list_controller.dart';
import 'sign_off_edit_screen.dart';

class SignOffListScreen extends StatelessWidget {
  const SignOffListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(SignOffListController());
    c.refreshList();

    return Scaffold(
      appBar: AppBar(title: const Text('Admin – Sign Offs')),
      body: Column(children: [
        // Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Row(children: [
        //     SizedBox(
        //       width: 260,
        //       child: TextField(
        //         controller: c.searchCtl,
        //         decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by customer name'),
        //         onSubmitted: (_) => c.refreshList(),
        //       ),
        //     ),
        //     const SizedBox(width: 8),
        //     ElevatedButton(onPressed: c.refreshList, child: const Text('Search')),
        //   ]),
        // ),
        Expanded(
          child: Obx(() {
            final items = c.items;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Customer')),
                DataColumn(label: Text('Vehicle No')),
                DataColumn(label: Text('Sale Date')),
                DataColumn(label: Text('After FE')),
                DataColumn(label: Text('Actions')),
              ], rows: [
                for (final it in items)
                  DataRow(cells: [
                    DataCell(Text('${it.id}')),
                    DataCell(Text(it.customerName ?? '')),
                    DataCell(Text(it.customerVehicleDetails?.vehicleNo ?? '')),
                    DataCell(Text(it.customerVehicleDetails?.saleDate ?? '')),
                    DataCell(Text(it.afterTrialsFE.toString() ?? '')),
                    DataCell(Row(children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => Get.to(() => SignOffEditScreen(id: it.id))),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => c.deleteItem(it.id!)),
                    ])),
                  ])
              ])
              ,
            );
          }),
        ),
        Obx(() => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            Text('Page ${c.page.value} / ${c.totalPages}'),
            IconButton(onPressed: c.prevPage, icon: const Icon(Icons.chevron_left)),
            IconButton(onPressed: c.nextPage, icon: const Icon(Icons.chevron_right)),
          ]),
        )),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const SignOffEditScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
