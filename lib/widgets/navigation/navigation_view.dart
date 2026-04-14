import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../providers/navigation_provider.dart';
import '../../models/destination.dart';
import '../map/map_widgets.dart';

class NavigationView extends StatefulWidget {
  const NavigationView({super.key});

  @override
  State<NavigationView> createState() => _NavigationViewState();
}

class _NavigationViewState extends State<NavigationView> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchResults = false;
  Destination? _selectedDestination;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    if (!nav.isPermissionGranted) {
      return _buildPermissionLayout(nav);
    }

    if (nav.isNavigating) {
      return _buildActiveNavigationLayout(nav);
    }

    if (_showSearchResults || _selectedDestination != null) {
      return _buildSearchMapLayout(nav);
    }

    return _buildDashboardLayout(nav);
  }

  // --- New Image-Driven Active Navigation Layout ---
  Widget _buildActiveNavigationLayout(NavigationProvider nav) {
    final curPos = nav.currentPosition != null 
        ? LatLng(nav.currentPosition!.latitude, nav.currentPosition!.longitude) 
        : null;

    final targetMarkers = nav.activeDestination != null 
        ? [LatLng(nav.activeDestination!.latitude, nav.activeDestination!.longitude)] 
        : <LatLng>[];

    return Stack(
      children: [
        // Background Full Map (Image 1 backdrop)
        Positioned.fill(
          child: SmartMapWidget(
            center: curPos,
            markers: targetMarkers,
            polylinePoints: nav.routePoints,
          ),
        ),

        // Minimize Map Overlay (Image 1)
        Positioned(
          bottom: 120, // Above navigation bar
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFF08209A), borderRadius: BorderRadius.circular(20)),
            child: const Row(
              children: [
                Text('Minimize Map', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Icon(Icons.remove_circle_outline, size: 16, color: Colors.white),
              ],
            ),
          ),
        ),

        // Draggable Sheet (Image 1, 2, 3)
        DraggableScrollableSheet(
          initialChildSize: 0.15,
          minChildSize: 0.15,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: const [0.15, 0.4, 0.9],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Grab Handle
                    Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    
                    // Header (Always visible - Image 1/2)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60, height: 60,
                                decoration: const BoxDecoration(color: Color(0xFF08209A), shape: BoxShape.circle),
                                child: const Icon(Icons.navigation, color: Colors.white, size: 30),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Navigating to', style: TextStyle(fontFamily: 'DescriptionFont', fontSize: 14, color: Colors.black54)),
                                    Text(
                                      nav.activeDestination?.name ?? 'Unknown Destination', 
                                      style: const TextStyle(fontFamily: 'HeaderFont', fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0D1724)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Stats (Visible in mid/expanded - Image 3)
                          _buildStatRow('Distance Remaining', '${nav.activeDestination?.distanceKm?.toStringAsFixed(1) ?? "0.0"} km'),
                          const SizedBox(height: 15),
                          _buildStatRow('Estimated Time', '${nav.activeDestination?.estimatedMinutes ?? "0"} minutes'),
                          
                          const SizedBox(height: 30),
                          
                          // Step Instruction Card (Image 3)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.subdirectory_arrow_right, color: Color(0xFF08209A), size: 40),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.trending_flat, color: Color(0xFF08209A), size: 24),
                                          SizedBox(width: 10),
                                          Text('Turn Right', style: TextStyle(fontFamily: 'HeaderFont', fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        nav.navigationSteps.isNotEmpty 
                                          ? nav.navigationSteps.first['instruction']?.toString() ?? 'Continue straight'
                                          : 'In 50 meters, turn right onto Main Street',
                                        style: const TextStyle(fontFamily: 'DescriptionFont', fontSize: 16, color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Cancel Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: OutlinedButton(
                              onPressed: () => nav.stopNavigation(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF08209A), width: 2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Cancel Navigation', style: TextStyle(color: Color(0xFF08209A), fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.navigation, color: Color(0xFF08209A), size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(fontFamily: 'DescriptionFont', fontSize: 16, color: Colors.black54), overflow: TextOverflow.ellipsis),
        ),
        Text(value, style: const TextStyle(fontFamily: 'HeaderFont', fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }

  // --- Image 1: Permission Layout ---
  Widget _buildPermissionLayout(NavigationProvider nav) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Map with Path
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFF08209A),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/icons/navigation-icons/navigation-icon.png',
                color: Colors.white,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 50),
            const Text(
              'Enable location permissions in your device settings to use the navigation feature.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'HeaderFont',
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => nav.requestPermission(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF08209A),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('Enable Location', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- Image 2: Dashboard Layout ---
  Widget _buildDashboardLayout(NavigationProvider nav) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Navigation',
            style: TextStyle(
              fontFamily: 'HeaderFont',
              fontWeight: FontWeight.w900,
              fontSize: 34,
              color: Color(0xFF0D1724),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Get turn-by-turn directions\nwith audio guidance',
            style: TextStyle(
              fontFamily: 'DescriptionFont',
              fontSize: 16,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 35),
          
          // Search Bar
          GestureDetector(
            onTap: () => setState(() => _showSearchResults = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.location_on, color: Color(0xFF08209A), size: 28),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Where do you want to go?',
                      style: TextStyle(fontFamily: 'DescriptionFont', fontSize: 18, color: Colors.black38),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 35),
          const Row(
            children: [
              Icon(Icons.access_time, color: Color(0xFF08209A), size: 22),
              SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Recent Destinations',
                      style: TextStyle(fontFamily: 'HeaderFont', fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0D1724)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // History List
          ...nav.recentDestinations.take(3).map((dest) => _buildDestinationCard(dest)),
          
          const SizedBox(height: 30),
          
          SizedBox(
            width: double.infinity,
            height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (nav.recentDestinations.isNotEmpty) {
                    nav.startNavigation(nav.recentDestinations.first);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF08209A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 5,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Start Navigation', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(width: 10),
                    Icon(Icons.navigation, color: Colors.white, size: 20),
                  ],
                ),
              ),
          ),
        ],
      ),
    );
  }

  // --- Image 3: Search/Map Layout ---
  Widget _buildSearchMapLayout(NavigationProvider nav) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Navigation',
                  style: TextStyle(fontFamily: 'HeaderFont', fontWeight: FontWeight.w900, fontSize: 34),
                ),
                const SizedBox(height: 35),
                
                // Active Search Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (val) => nav.search(val),
                    style: const TextStyle(color: Color(0xFF08209A), fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on, color: Color(0xFF08209A), size: 28),
                      border: InputBorder.none,
                      hintText: 'Search destination...',
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                if (nav.isSearching) 
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),

                // Results or Selection
                if (_selectedDestination == null) 
                  ...nav.searchResults.map((res) => _buildDestinationCard(res, isSearchResult: true))
                else 
                  _buildDestinationCard(_selectedDestination!, isSelected: true),
                
                const SizedBox(height: 20),
                
                if (_selectedDestination != null)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                         nav.saveToHistory(_selectedDestination!);
                         nav.startNavigation(_selectedDestination!);
                         _selectedDestination = null;
                         _showSearchResults = false;
                         _searchController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF08209A), width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Flexible(
                            child: Text(
                              'Confirm Destination', 
                              style: TextStyle(color: Color(0xFF08209A), fontSize: 16, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.navigation, color: Color(0xFF08209A), size: 18),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Map Section (Image 3 Bottom)
        if (_selectedDestination != null || _showSearchResults)
          Container(
            height: 220,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  SmartMapWidget(
                    center: _selectedDestination != null 
                        ? LatLng(_selectedDestination!.latitude, _selectedDestination!.longitude)
                        : null,
                    markers: _selectedDestination != null 
                        ? [LatLng(_selectedDestination!.latitude, _selectedDestination!.longitude)]
                        : [],
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Text('Zoom Map', style: TextStyle(color: Color(0xFF08209A), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(width: 5),
                          Icon(Icons.zoom_in, size: 16, color: Color(0xFF08209A)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDestinationCard(Destination dest, {bool isSearchResult = false, bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: isSelected ? Border.all(color: const Color(0xFF08209A), width: 1.5) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        onTap: () {
          setState(() {
            _selectedDestination = dest;
            _searchController.text = dest.name;
          });
        },
        leading: Container(
          width: 50, height: 50,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(color: Color(0xFF08209A), shape: BoxShape.circle),
          child: const Icon(Icons.route, color: Colors.white, size: 24),
        ),
        title: Text(
          dest.name,
          style: const TextStyle(fontFamily: 'HeaderFont', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dest.address,
          style: const TextStyle(fontFamily: 'DescriptionFont', fontSize: 12, color: Colors.black45),
          maxLines: 1, overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.navigation, color: Color(0xFF08209A), size: 24),
      ),
    );
  }
}
