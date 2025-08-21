import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/new_trail_controller.dart';
import '../../models/trial_form_new_model.dart';

class ParticipantsPhotosForm extends StatelessWidget {
  final controller = Get.find<TrialFormController>();

  ParticipantsPhotosForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Participants', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildParticipantFields(),

          const SizedBox(height: 24),
          Text('Vehicle Photos', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _buildPhotoFields(),
        ],
      ),
    );
  }

  Widget _buildParticipantFields() {
    final roles = ['CSM', 'PC', 'Driver', 'Customer'];

    return Obx(() {
      final participants = controller.form.value.participants ?? [];

      return Column(
        children: roles.map((role) {
          final existing = participants.firstWhereOrNull((p) => p.role == role);
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(role)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: existing?.name ?? ''),
                      onChanged: (v) {
                        _updateParticipant(role, name: v, sign: existing?.sign);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Sign',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: existing?.sign ?? ''),
                      onChanged: (v) {
                        _updateParticipant(role, name: existing?.name, sign: v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  void _updateParticipant(String role, {String? name, String? sign}) {
    final existing = controller.form.value.participants
        ?.firstWhereOrNull((p) => p.role == role);

    final participant = ParticipantOld(
      role: role,
      name: name ?? existing?.name ?? '',
      sign: sign ?? existing?.sign ?? '',
    );

    if (existing != null) {
      final index = controller.form.value.participants!.indexOf(existing);
      controller.form.update((f) {
        f?.participants![index] = participant;
      });
    } else {
      controller.addParticipant(participant);
    }
  }

  Widget _buildPhotoFields() {
    return Obx(() {
      final photos = controller.form.value.photos ?? [];

      return Column(
        children: [
          ...photos.asMap().entries.map((entry) {
            final index = entry.key;
            final photo = entry.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(photo.url ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    controller.form.update((f) {
                      f?.photos?.removeAt(index);
                    });
                  },
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              _showAddPhotoDialog(Get.context!);
            },
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photo URL'),
          ),
        ],
      );
    });
  }

  void _showAddPhotoDialog(BuildContext context) {
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Vehicle Photo URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: 'Photo URL'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                controller.addPhoto(urlController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
