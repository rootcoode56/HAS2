import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class HasNearMe extends StatefulWidget {
  const HasNearMe({super.key});

  @override
  State<HasNearMe> createState() => _HasNearMeState();
}

class _HasNearMeState extends State<HasNearMe> with WidgetsBindingObserver {
  static const platform = MethodChannel('com.example.has/api_key');
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _controller = Completer();

  final Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(23.8103, 90.4125); // Default: Dhaka
  String? _apiKey;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _getApiKey();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _getApiKey() async {
    try {
      final String result = await platform.invokeMethod('getApiKey');
      _apiKey = result;
    } on PlatformException catch (e) {
      print("Failed to get API key: '${e.message}'.");
    }
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled.');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          '❌ Location permissions are permanently denied, cannot request permissions.');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final controller = await _controller.future;
      await controller
          .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 16));

      await _fetchNearbyHospitals(_currentPosition);
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  Future<void> _fetchNearbyHospitals(LatLng location) async {
    if (_apiKey == null) {
      print('❌ API key not available yet');
      return;
    }

    const radius = 3000;
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=$radius&type=hospital&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        print(
            '❌ Places API error: ${data['status']} - ${data['error_message'] ?? ''}');
        if (data['status'] == 'REQUEST_DENIED') {
          print('   Check if Places API is enabled and API key is correct');
        }
        return;
      }

      final results = data['results'] as List;
      _markers
        ..clear()

        // Add current location marker
        ..add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentPosition,
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );

      // Add hospitals (default Google 'H' markers)
      for (final hospital in results) {
        final lat = hospital['geometry']['location']['lat']?.toDouble();
        final lng = hospital['geometry']['location']['lng']?.toDouble();
        final name = hospital['name'] ?? 'Hospital';

        if (lat != null && lng != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(hospital['place_id'] ?? name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(title: name),
              // No custom icon: use default 'H' marker
            ),
          );
        }
      }

      setState(() {});
      print('✅ Found ${results.length} hospitals nearby');
    } catch (e) {
      print('❌ Error fetching hospitals: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (_apiKey == null || query.trim().isEmpty) return;

    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        print(
            '❌ Search API error: ${data['status']} - ${data['error_message'] ?? ''}');
        return;
      }

      if (data['results'] != null && data['results'].isNotEmpty) {
        final first = data['results'][0];
        final lat = first['geometry']['location']['lat']?.toDouble();
        final lng = first['geometry']['location']['lng']?.toDouble();

        if (lat != null && lng != null) {
          final newLocation = LatLng(lat, lng);
          setState(() => _currentPosition = newLocation);

          final controller = await _controller.future;
          await controller
              .animateCamera(CameraUpdate.newLatLngZoom(newLocation, 16));
          await _fetchNearbyHospitals(newLocation);
        }
      } else {
        print('❌ No results found for: $query');
      }
    } catch (e) {
      print('❌ Error searching location: $e');
    }
  }

  void _handleMapTap(LatLng point) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _handleMapTapDebounced(point);
    });
  }

  Future<void> _handleMapTapDebounced(LatLng point) async {
    setState(() => _currentPosition = point);
    final controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(point, 16));
    await _fetchNearbyHospitals(point);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _controller.complete,
              initialCameraPosition:
                  CameraPosition(target: _currentPosition, zoom: 14),
              myLocationButtonEnabled: false,
              markers: _markers,
              onTap: _handleMapTap,
              compassEnabled: false,
              rotateGesturesEnabled: false,
              tiltGesturesEnabled: false,
              zoomControlsEnabled: false,
            ),
            // Search Bar
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: _searchLocation,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search location or tap map...',
                        hintStyle: TextStyle(color: Colors.white),
                        icon: Icon(Icons.search, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Current Location Button
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
            // Zoom In/Out Buttons
            Positioned(
              bottom: 180,
              right: 20,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: 'zoom_in',
                    mini: true,
                    onPressed: () async {
                      final controller = await _controller.future;
                      final currentZoom = await controller.getZoomLevel();
                      await controller
                          .animateCamera(CameraUpdate.zoomTo(currentZoom + 1));
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    onPressed: () async {
                      final controller = await _controller.future;
                      final currentZoom = await controller.getZoomLevel();
                      await controller
                          .animateCamera(CameraUpdate.zoomTo(currentZoom - 1));
                    },
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ],
              ),
            ),
            // Go Back Button
            Positioned(
              bottom: 30,
              left: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      );
}
