import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

class DailyReportScreen extends StatefulWidget {
  final Map<String, String> employeeData;
  const DailyReportScreen({super.key, required this.employeeData});

  @override
  _DailyReportScreenState createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _shiftController = TextEditingController();
  final TextEditingController _otHoursController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _inTimeController = TextEditingController();
  final TextEditingController _outTimeController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController();
  final TextEditingController _startingKmController = TextEditingController();
  final TextEditingController _endingKmController = TextEditingController();
  final TextEditingController _totalKmController = TextEditingController();
  final TextEditingController _fromPlaceController = TextEditingController();
  final TextEditingController _toPlaceController = TextEditingController();
  final TextEditingController _fuelAvgController = TextEditingController();
  final TextEditingController _coDriverNameController = TextEditingController();
  final TextEditingController _coDriverPhoneController = TextEditingController();
  final TextEditingController _inchargeSignController = TextEditingController();

  // For default date
  String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report Form'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display employee details
            Text('Employee Name: ${widget.employeeData['name']}'),
            Text('Employee Phone: ${widget.employeeData['phone']}'),
            Text('Employee Code: ${widget.employeeData['code']}'),
            Text('Month: ${widget.employeeData['month']}'),
            Text('Year: ${widget.employeeData['year']}'),
            Text('DICV Incharge Name: ${widget.employeeData['inchargeName']}'),
            Text('Incharge Phone: ${widget.employeeData['inchargePhone']}'),
            const SizedBox(height: 20),

            // Form for daily report
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _date,
                    enabled: false,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _shiftController,
                    decoration: const InputDecoration(
                      labelText: 'Shift',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _otHoursController,
                    decoration: const InputDecoration(
                      labelText: 'OT Hours',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _vehicleModelController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Model',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _regNoController,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Reg. No.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _inTimeController,
                    decoration: const InputDecoration(
                      labelText: 'IN Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _outTimeController,
                    decoration: const InputDecoration(
                      labelText: 'OUT Time',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _workingHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Working Hours',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _startingKmController,
                    decoration: const InputDecoration(
                      labelText: 'Starting KM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _endingKmController,
                    decoration: const InputDecoration(
                      labelText: 'Ending KM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _totalKmController,
                    decoration: const InputDecoration(
                      labelText: 'Total KM',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fromPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'From Place',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _toPlaceController,
                    decoration: const InputDecoration(
                      labelText: 'To Place',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fuelAvgController,
                    decoration: const InputDecoration(
                      labelText: 'Fuel Avg.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _coDriverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Co Driver Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _coDriverPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Co Driver Phone No.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _inchargeSignController,
                    decoration: const InputDecoration(
                      labelText: 'Incharge Sign',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Handle form submission logic
                        print('Form Submitted');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue, // White text color
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30), // Custom padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18, // Larger text for better readability
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    child: const Text('Submit Report'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
