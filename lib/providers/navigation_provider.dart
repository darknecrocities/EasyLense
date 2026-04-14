import 'dart:convert';
import 'dart:math';
import 'dart:async'; // Added for Stream
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart'; // Added for LatLng
import '../models/destination.dart';

class NavigationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPermissionGranted = false;
  bool get isPermissionGranted => _isPermissionGranted;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  List<Destination> _recentDestinations = [];
  List<Destination> get recentDestinations => _recentDestinations;

  List<Destination> _searchResults = [];
  List<Destination> get searchResults => _searchResults;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  // --- New Active Navigation State ---
  bool _isNavigating = false;
  bool get isNavigating => _isNavigating;

  List<LatLng> _routePoints = [];
  List<LatLng> get routePoints => _routePoints;

  List<Map<String, dynamic>> _navigationSteps = [];
  List<Map<String, dynamic>> get navigationSteps => _navigationSteps;

  Destination? _activeDestination;
  Destination? get activeDestination => _activeDestination;

  StreamSubscription<Position>? _positionStream;

  NavigationProvider() {
    checkPermission();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> checkPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _isPermissionGranted = true;
      _getCurrentLocation();
      fetchHistory();
    } else {
      _isPermissionGranted = false;
    }
    notifyListeners();
  }

  Future<void> requestPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      _isPermissionGranted = true;
      _getCurrentLocation();
      fetchHistory();
    } else {
      _isPermissionGranted = false;
    }
    notifyListeners();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      notifyListeners();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> fetchHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('navigation_history')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      _recentDestinations = snapshot.docs
          .map((doc) => Destination.fromMap(doc.id, doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching history: $e');
    }
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Switch to Photon API (better performance and typo tolerance)
      final url = Uri.parse('https://photon.komoot.io/api/?q=$query&limit=10');
      // Added User-Agent for better API compliance
      final response = await http.get(url, headers: {'User-Agent': 'EasyLens_App/1.0'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List features = data['features'] ?? [];
        debugPrint('Photon Search returned ${features.length} results for "$query"');
        
        _searchResults = features.map((f) {
          final props = f['properties'];
          final geom = f['geometry'];
          final coords = geom['coordinates'];
          
          // Photon returns [Lon, Lat]
          final lon = coords[0].toDouble();
          final lat = coords[1].toDouble();
          
          String name = props['name'] ?? props['street'] ?? 'Unknown location';
          
          // Build refined address string
          List<String> addressParts = [];
          if (props['street'] != null) addressParts.add(props['street']);
          if (props['city'] != null) addressParts.add(props['city']);
          if (props['state'] != null && props['state'] != props['city']) addressParts.add(props['state']);
          
          String address = addressParts.isNotEmpty ? addressParts.join(', ') : (props['country'] ?? '');

          double dist = 0;
          int eta = 0;
          
          if (_currentPosition != null) {
            dist = Geolocator.distanceBetween(
              _currentPosition!.latitude, 
              _currentPosition!.longitude, 
              lat, lon
            ) / 1000;
            eta = (dist * 1.5).round() + 2; 
          }

          return Destination(
            id: props['osm_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            address: address,
            latitude: lat,
            longitude: lon,
            distanceKm: dist,
            estimatedMinutes: eta,
          );
        }).toList();
      } else {
        debugPrint('Photon API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // --- OSRM Navigation Logic ---
  Future<void> startNavigation(Destination target) async {
    if (_currentPosition == null) await _getCurrentLocation();
    if (_currentPosition == null) return;

    _isNavigating = true;
    _activeDestination = target;
    notifyListeners();

    try {
      final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${_currentPosition!.longitude},${_currentPosition!.latitude};${target.longitude},${target.latitude}?overview=full&geometries=geojson&steps=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        
        // Parse geometry
        final geometry = route['geometry']['coordinates'] as List;
        _routePoints = geometry.map((coord) => LatLng(coord[1], coord[0])).toList();

        // Parse steps
        final legs = route['legs'][0];
        _navigationSteps = (legs['steps'] as List).map((s) => {
          'instruction': s['maneuver']['instruction']?.toString() ?? 'Continue straight',
          'modifier': s['maneuver']['modifier']?.toString() ?? '',
          'distance': s['distance'] ?? 0.0,
        }).toList();

        // Start Tracking
        _startTracking();
      }
    } catch (e) {
      debugPrint('OSRM error: $e');
      _isNavigating = false;
    }
    notifyListeners();
  }

  void stopNavigation() {
    _isNavigating = false;
    _routePoints = [];
    _navigationSteps = [];
    _activeDestination = null;
    _positionStream?.cancel();
    notifyListeners();
  }

  void _startTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      _currentPosition = position;
      // Update dynamic info
      if (_activeDestination != null) {
        double dist = Geolocator.distanceBetween(
          position.latitude, position.longitude,
          _activeDestination!.latitude, _activeDestination!.longitude
        ) / 1000;
        
        _activeDestination = _activeDestination!.copyWith(
          distanceKm: dist,
          estimatedMinutes: (dist * 1.5).round() + 1,
        );
      }
      notifyListeners();
    });
  }

  Future<void> saveToHistory(Destination dest) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('navigation_history')
          .add(dest.toMap());
      
      fetchHistory();
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
}
