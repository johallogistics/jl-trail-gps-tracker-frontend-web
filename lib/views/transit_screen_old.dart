import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_place/google_place.dart';

class TransitScreenOld extends StatefulWidget {
  @override
  _TransitScreenOldState createState() => _TransitScreenOldState();
}

class _TransitScreenOldState extends State<TransitScreenOld> {
  LatLng? currentLocation;
  LatLng? destinationLocation;
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();
  final googlePlace = GooglePlace('AIzaSyDNT2-yLg1nS_M5vNLEEbDtNUOgb3sXQt0');


  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions().then((_) => _getCurrentLocation());
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _saveTransitDetails() async {
    if (currentLocation == null || destinationLocation == null) {
      Get.snackbar('Error', 'Please select both locations',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Save to Firestore
    await FirebaseFirestore.instance.collection('transits').add({
      'currentLocation': {
        'lat': currentLocation!.latitude,
        'lng': currentLocation!.longitude,
      },
      'destinationLocation': {
        'lat': destinationLocation!.latitude,
        'lng': destinationLocation!.longitude,
      },
      'status': 'In Progress',
      'timestamp': DateTime.now(),
    });

    Get.snackbar('Success', 'Transit details saved',
        backgroundColor: Colors.green, colorText: Colors.white);

    // Navigate or perform other actions
  }

  void _onMapTap(LatLng position) {
    setState(() {
      destinationLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Start Transit'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: currentLocation == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: currentLocation!,
                zoom: 14,
              ),
              markers: {
                if (destinationLocation != null)
                  Marker(
                    markerId: MarkerId('destination'),
                    position: destinationLocation!,
                  ),
              },
              onTap: _onMapTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search destination',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        var predictions = await googlePlace.autocomplete.get(
                          searchController.text,
                        );
                        if (predictions != null &&
                            predictions.predictions != null &&
                            predictions.predictions!.isNotEmpty) {
                          var firstPrediction = predictions.predictions!.first;
                          var details = await googlePlace.details.get(firstPrediction.placeId!);
                          if (details != null && details.result != null) {
                            setState(() {
                              destinationLocation = LatLng(
                                details.result!.geometry!.location!.lat!,
                                details.result!.geometry!.location!.lng!,
                              );
                              mapController?.animateCamera(
                                CameraUpdate.newLatLng(destinationLocation!),
                              );
                            });
                          }
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveTransitDetails,
                  child: Text('Save Transit Details'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
