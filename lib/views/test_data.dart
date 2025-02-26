import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trail_tracker/controllers/auth_controller.dart';

class TestData extends StatelessWidget {
  TestData({super.key});

  final StudentController _controller = Get.put(StudentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Center(
            child: Text(
          "This is my title",
          textAlign: TextAlign.center,
        )),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Obx(() => Visibility(
                visible: _controller.name.isNotEmpty,
                replacement: const Text("No Name Available to Show"),
                child: Text("This is my name ${_controller.name}"))),
            ElevatedButton(
              onPressed: () {
                _controller.changeData();
              },
              child: const Text("Update Data"),
            ),
            ElevatedButton(
                onPressed: () => _controller.clearData(),
                child: const Text("Clear Data")),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          height: 100,
          color: Colors.yellow,
          child: const Center(
              child: Text(
            "This is bottom bar",
            textAlign: TextAlign.center,
          ))),
    );
  }
}
