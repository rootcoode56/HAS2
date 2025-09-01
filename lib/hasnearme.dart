import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class HasNearMe extends StatefulWidget {
  const HasNearMe({super.key});

  @override
  State<HasNearMe> createState() => _HasNearMeState();
}

class _HasNearMeState extends State<HasNearMe> {
  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _currentPosition = const LatLng(23.8103, 90.4125); // Default: Dhaka

  // Google Maps API key from environment variables
  static const String _googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.requestPermission();

    if (!serviceEnabled || permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 18),
    );
    _fetchNearbyHospitals(_currentPosition);
  }

  Future<void> _fetchNearbyHospitals(LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=3000&type=hospital&key=$_googleMapsApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] != 'OK') {
      print('❌ Places API error: ${data['status']}');
      return;
    }

    final results = data['results'];

    _markers.clear();

    for (final hospital in data['results']) {
      final lat = hospital['geometry']['location']['lat'];
      final lng = hospital['geometry']['location']['lng'];
      final name = hospital['name'];

      _markers.add(
        Marker(
          markerId: MarkerId(name),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(title: name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {});

    if (results.isNotEmpty) {
      final firstHospital = results[0];
      final lat = firstHospital['geometry']['location']['lat'];
      final lng = firstHospital['geometry']['location']['lng'];

      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 18),
      );
    }
  }

  Future<void> _searchLocation(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=${Uri.encodeComponent(query)}&key=$_googleMapsApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['results'] != null && data['results'].isNotEmpty) {
      final first = data['results'][0];
      final lat = first['geometry']['location']['lat'];
      final lng = first['geometry']['location']['lng'];
      final newLocation = LatLng(lat, lng);

      setState(() {
        _currentPosition = newLocation;
      });

      _mapController.animateCamera(CameraUpdate.newLatLngZoom(newLocation, 18));
      _fetchNearbyHospitals(newLocation);
    }
  }

  void _handleMapTap(LatLng point) {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(point, 18));
    _fetchNearbyHospitals(point);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 14,
              ),
              myLocationEnabled: true,
              markers: _markers,
              onTap: _handleMapTap,
            ),
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
            Positioned(
              bottom: 30,
              left: 20,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('Go Back'),
              ),
            ),
          ],
        ),
      );
}
