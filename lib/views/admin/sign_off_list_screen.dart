// lib/admin/sign_off_list_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/sign_off_list_controller.dart';
import '../../models/sign_off_models/sign_off.dart';
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: c.searchCtl,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by customer name'),
                onSubmitted: (_) => c.refreshList(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: c.refreshList, child: const Text('Search')),
          ]),
        ),
        Expanded(
          child: Obx(() {
            final items = c.items;
            if (items.isEmpty) {
              return const Center(child: Text('No sign-offs found'));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
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
                      DataCell(Text('${it.id ?? ''}')),
                      DataCell(Text(it.customerName ?? '')),
                      DataCell(Text(it.customerVehicleDetails?.vehicleNo ?? '')),
                      DataCell(Text(it.customerVehicleDetails?.saleDate ?? '')),
                      DataCell(Text(it.afterTrialsFE?.toString() ?? '')),
                      DataCell(Row(children: [
                        IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          tooltip: 'View details',
                          onPressed: () => _showDetailDialog(context, it),
                        ),
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => Get.to(() => SignOffEditScreen(id: it.id))),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => c.deleteItem(it.id!)),
                      ])),
                    ])
                ]),
              ),
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

  void _showDetailDialog(BuildContext context, SignOff s) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('SignOff #${s.id ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Basic info
                        _sectionTitle('Basic Info'),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _kv('Customer', s.customerName),
                            _kv('Expected FE', s.customerExpectedFE?.toString()),
                            _kv('Before FE', s.beforeTrialsFE?.toString()),
                            _kv('After FE', s.afterTrialsFE?.toString()),
                            _kv('Driver ID', s.driverId),
                            _kv('Created By Role', s.createdByRole),
                            _kv('Is Submitted', s.isSubmitted?.toString()),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Vehicle details
                        _sectionTitle('Customer Vehicle Details'),
                        if (s.customerVehicleDetails != null) ...[
                          Wrap(spacing: 12, runSpacing: 6, children: [
                            _kv('Model', s.customerVehicleDetails?.model),
                            _kv('Road Type', s.customerVehicleDetails?.roadType),
                            _kv('Sale Date', s.customerVehicleDetails?.saleDate),
                            _kv('Trip Route', s.customerVehicleDetails?.tripRoute),
                            _kv('Vehicle No', s.customerVehicleDetails?.vehicleNo),
                            _kv('Application', s.customerVehicleDetails?.application),
                            _kv('Trip Duration', s.customerVehicleDetails?.tripDuration),
                            _kv('Customer Verbatim', s.customerVehicleDetails?.customerVerbatim),
                            _kv('Vehicle Check Date', s.customerVehicleDetails?.vehicleCheckDate),
                            _kv('Issues Found', s.customerVehicleDetails?.issuesFoundOnVehicleCheck),
                          ]),
                        ] else
                          const Text('No vehicle details'),

                        const SizedBox(height: 12),

                        // Trip details (list)
                        _sectionTitle('Trip Details'),
                        if (s.tripDetails.isEmpty)
                          const Text('No trips')
                        else
                          Column(
                            children: s.tripDetails.map((td) {
                              return Card(
                                elevation: 1,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Trip #${td.tripNo} (id: ${td.id ?? ''})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Wrap(spacing: 12, runSpacing: 6, children: [
                                        _kv('Route', td.tripRoute),
                                        _kv('Start', td.tripStartDate),
                                        _kv('End', td.tripEndDate),
                                        _kv('Start Km', td.startKm?.toString()),
                                        _kv('End Km', td.endKm?.toString()),
                                        _kv('Trip Km', td.tripKm?.toString()),
                                        _kv('Max Speed', td.maxSpeed?.toString()),
                                        _kv('Weight GVW', td.weightGVW?.toString()),
                                        _kv('Diesel Ltrs', td.actualDieselLtrs?.toString()),
                                        _kv('Total Trip Km', td.totalTripKm?.toString()),
                                        _kv('Actual FE', td.actualFE?.toString()),
                                      ]),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 12),

                        // Participants
                        _sectionTitle('Participants'),
                        if (s.participants.isEmpty)
                          const Text('No participants')
                        else
                          Column(
                            children: s.participants.map((p) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(p.role),
                                subtitle: Text('${p.name ?? ''}${p.signatureUrl != null ? ' — signature available' : ''}'),
                                leading: const Icon(Icons.person),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 12),

                        // Photos
                        _sectionTitle('Photos'),
                        if (s.photos.isEmpty)
                          const Text('No photos')
                        else
                          Column(
                            children: s.photos.map((ph) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.photo),
                                title: Text(ph.caption ?? ph.fileUrl),
                                subtitle: Text(ph.fileUrl),
                                onTap: () {
                                  // optionally open in browser or image viewer
                                },
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // dialog actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String? v) => SizedBox(
    width: 260,
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87),
        children: [
          TextSpan(text: '$k: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: '${v ?? ''}'),
        ],
      ),
    ),
  );

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
  );
}
