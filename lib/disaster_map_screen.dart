import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DisasterMapScreen extends StatefulWidget {
  const DisasterMapScreen({super.key});

  @override
  State<DisasterMapScreen> createState() => _DisasterMapScreenState();
}

class _DisasterMapScreenState extends State<DisasterMapScreen> {
  // DATA: Mock Disaster Zones
  final List<DisasterZone> zones = [
    DisasterZone("Ring of Fire (Japan)", const LatLng(36.2048, 138.2529), Colors.redAccent, Icons.landslide, "High Earthquake Risk"),
    DisasterZone("California (USA)", const LatLng(36.7783, -119.4179), Colors.orangeAccent, Icons.local_fire_department, "Wildfire Prone"),
    DisasterZone("Bangladesh Delta", const LatLng(23.6850, 90.3563), Colors.blueAccent, Icons.flood, "Severe Flood Risk"),
    DisasterZone("Himalayan Belt (India)", const LatLng(30.0668, 79.0193), Colors.redAccent, Icons.landslide, "Seismic Zone V"),
    DisasterZone("Amazon Rainforest", const LatLng(-3.4653, -62.2159), Colors.orangeAccent, Icons.forest, "Deforestation & Fire"),
    DisasterZone("Florida Coast", const LatLng(27.6648, -81.5158), Colors.tealAccent, Icons.storm, "Hurricane Pathway"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // PURE DARK BACKGROUND
      appBar: AppBar(
        title: const Text("Global Hazard Map", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // 1. THE DARK MAP
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(20.0, 0.0), // Center of World
              initialZoom: 2.5,
            ),
            children: [
              // Dark Mode Map Tiles (CartoDB Dark Matter)
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              // The Colored Circles
              CircleLayer(
                circles: zones.map((zone) => CircleMarker(
                  point: zone.location,
                  radius: 20, // Size of the danger zone
                  useRadiusInMeter: false,
                  color: zone.color.withOpacity(0.5), // Transparent fill
                  borderColor: zone.color,
                  borderStrokeWidth: 2,
                )).toList(),
              ),
              // Icons on top of circles
              MarkerLayer(
                markers: zones.map((zone) => Marker(
                  point: zone.location,
                  width: 30,
                  height: 30,
                  child: Icon(zone.icon, color: Colors.white, size: 20),
                )).toList(),
              ),
            ],
          ),

          // 2. BOTTOM LEGEND / LIST
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900]?.withOpacity(0.95), // Glassy Dark Panel
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                border: Border.all(color: Colors.white24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      width: 40, height: 5,
                      decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Text("Active High-Risk Zones", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: zones.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 15),
                      itemBuilder: (context, index) {
                        final zone = zones[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.black, // Black cards
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: zone.color.withOpacity(0.5)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: zone.color.withOpacity(0.2),
                                child: Icon(zone.icon, color: zone.color),
                              ),
                              const Spacer(),
                              Text(zone.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 5),
                              Text(zone.desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Data Model
class DisasterZone {
  final String name;
  final LatLng location;
  final Color color;
  final IconData icon;
  final String desc;

  DisasterZone(this.name, this.location, this.color, this.icon, this.desc);
}