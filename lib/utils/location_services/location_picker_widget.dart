// utils/location_services/location_picker_widget.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;
import 'package:geocoding/geocoding.dart' as geo;

/// Use your Android-restricted key here (same as in AndroidManifest).
const String kAndroidMapsPlacesKey = "AIzaSyB0cKjbrIcwL8l6oXIsRkESnjnQA1WmGzw";

class LocationPicker extends StatefulWidget {
  final maps.LatLng? initial;
  final String? hint;
  const LocationPicker({super.key, this.initial, this.hint});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  maps.GoogleMapController? _mapController;

  // Current selection
  maps.LatLng _picked = const maps.LatLng(13.0827, 80.2707); // Chennai default
  String _pickedAddress = "Move map or search to pick location";

  // Places SDK
  late final places.FlutterGooglePlacesSdk _places;

  // UI state for suggestions
  Timer? _debounce;
  final Duration _debounceDuration = const Duration(milliseconds: 300);
  List<places.AutocompletePrediction> _suggestions = <places.AutocompletePrediction>[];
  bool _loadingSuggestions = false;

  @override
  void initState() {
    super.initState();

    // Init Places SDK with the Android key
    _places = places.FlutterGooglePlacesSdk(kAndroidMapsPlacesKey);

    if (widget.initial != null) _picked = widget.initial!;
    _reverseGeocodeLocal(_picked);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // ---- Reverse geocoding (device geocoder; no web calls) ----
  Future<void> _reverseGeocodeLocal(maps.LatLng pos) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final address = [
          if ((p.name ?? '').isNotEmpty) p.name,
          if ((p.subLocality ?? '').isNotEmpty) p.subLocality,
          if ((p.locality ?? '').isNotEmpty) p.locality,
          if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
          if ((p.postalCode ?? '').isNotEmpty) p.postalCode,
        ].where((x) => x != null && x.toString().trim().isNotEmpty).join(", ");

        setState(() {
          _pickedAddress = address.isNotEmpty
              ? address
              : "Pinned: ${pos.latitude}, ${pos.longitude}";
        });
      } else {
        setState(() {
          _pickedAddress = "Pinned: ${pos.latitude}, ${pos.longitude}";
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pickedAddress = "Pinned: ${pos.latitude}, ${pos.longitude}";
      });
    }
  }

  // ---- Places SDK: Autocomplete ----
  Future<List<places.AutocompletePrediction>> _sdkAutocomplete(String input) async {
    if (input.trim().isEmpty) return [];
    try {
      final response = await _places.findAutocompletePredictions(
        input,
        countries: const ['IN'], // Bias to India; remove if you want global
        origin: places.LatLng(lat: _picked.latitude, lng: _picked.longitude), // <-- correct type
      );
      return response.predictions;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Places error: $e")),
        );
      }
      return [];
    }
  }

  // ---- Places SDK: Details ----
  Future<places.Place?> _sdkPlaceDetails(String placeId) async {
    try {
      final response = await _places.fetchPlace(
        placeId,
        fields: const [
          places.PlaceField.Location,
          places.PlaceField.Address,
          places.PlaceField.Name,
        ],
      );
      return response.place;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Place details error: $e")),
        );
      }
      return null;
    }
  }

  // ---- Map helpers ----
  void _moveCamera(maps.LatLng target, {double zoom = 16}) {
    _mapController?.animateCamera(
      maps.CameraUpdate.newCameraPosition(
        maps.CameraPosition(target: target, zoom: zoom),
      ),
    );
  }

  void _select(maps.LatLng pos, String address) {
    setState(() {
      _picked = pos;
      _pickedAddress = address;
    });
  }

  // ---- Search input handlers ----
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () async {
      if (!mounted) return;
      if (value.trim().isEmpty) {
        setState(() {
          _suggestions = [];
          _loadingSuggestions = false;
        });
        return;
      }
      setState(() => _loadingSuggestions = true);
      final results = await _sdkAutocomplete(value);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _loadingSuggestions = false;
      });
    });
  }

  Future<void> _usePrediction(places.AutocompletePrediction prediction) async {
    FocusScope.of(context).unfocus();
    setState(() => _loadingSuggestions = true);

    final place = await _sdkPlaceDetails(prediction.placeId);
    if (place != null && place.latLng != null) {
      final latLng = maps.LatLng(
        place.latLng!.lat,
        place.latLng!.lng,
      );

      final addr = (place.address?.isNotEmpty ?? false)
          ? place.address!
          : (place.name?.isNotEmpty ?? false)
          ? place.name!
          : "${latLng.latitude}, ${latLng.longitude}";

      _select(latLng, addr);
      _moveCamera(latLng);
    }

    if (mounted) {
      setState(() {
        _suggestions = [];
        _loadingSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = {
      maps.Marker(
        markerId: const maps.MarkerId("picked"),
        position: _picked,
        infoWindow: maps.InfoWindow(title: "Selected", snippet: _pickedAddress),
        draggable: true,
        onDragEnd: (p) {
          _select(p, "Pinned: ${p.latitude}, ${p.longitude}");
          _reverseGeocodeLocal(p);
        },
      )
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Pick a Location")),
      body: Stack(
        children: [
          maps.GoogleMap(
            initialCameraPosition:
            maps.CameraPosition(target: _picked, zoom: 14),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: markers,
            onMapCreated: (c) => _mapController = c,
            onTap: (pos) {
              _select(pos, "Pinned: ${pos.latitude}, ${pos.longitude}");
              _reverseGeocodeLocal(pos);
              setState(() => _suggestions = []);
            },
          ),

          // Search, suggestions & address chip
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 3,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? "Search place...",
                      contentPadding: const EdgeInsets.all(12),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _suggestions = []);
                        },
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                if (_loadingSuggestions)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),

                if (_suggestions.isNotEmpty)
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(top: 6),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final s = _suggestions[index];
                          final mainText =
                          (s.primaryText != null && s.primaryText!.isNotEmpty)
                              ? s.primaryText!
                              : (s.fullText ?? "");
                          final secondaryText = s.secondaryText ?? "";
                          return ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(mainText),
                            subtitle: secondaryText.isNotEmpty
                                ? Text(secondaryText)
                                : null,
                            onTap: () => _usePrediction(s),
                          );
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 4,
                        spreadRadius: 1,
                        color: Colors.black12,
                      )
                    ],
                  ),
                  child: Text(
                    _pickedAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text("Use this location"),
        onPressed: () {
          Navigator.pop<Map<String, dynamic>>(context, {
            "latLng": _picked,
            "address": _pickedAddress,
          });
        },
      ),
    );
  }
}
