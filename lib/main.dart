import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'api_key.dart';
// --------------------------

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen()
  ));
}

// --- SCREEN 1: DASHBOARD ---
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> mainCategories = const [
    {"name": "FIRE", "icon": Icons.local_fire_department, "color": Color.fromARGB(255, 243, 190, 110)},
    {"name": "FLOOD", "icon": Icons.flood, "color": Color.fromARGB(255, 113, 183, 240)},
    {"name": "EARTHQUAKE", "icon": Icons.landslide, "color": Color.fromARGB(255, 125, 240, 102)},
    {"name": "OTHER EMERGENCIES", "icon": Icons.warning_amber, "color": Color.fromARGB(255, 240, 152, 200)},
  ];

  final List<Marker> mapMarkers = [
    const Marker(point: LatLng(28.7041, 77.1025), width: 40, height: 40, child: Icon(Icons.location_on, color: Colors.red)),
    const Marker(point: LatLng(19.0760, 72.8777), width: 40, height: 40, child: Icon(Icons.location_on, color: Colors.blue)),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  void _checkPermissions() async {
    // 1. Request Android Permissions
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    // 2. Check if Bluetooth is actually ON
    if (await FlutterBluePlus.adapterState.first == BluetoothAdapterState.off) {
      await FlutterBluePlus.turnOn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("SAHAYAK MESH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy, color: Colors.white),
            tooltip: "AI Rescuer",
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChatScreen(connectedEndpointId: "ai_simulator", connectedEndpointName: "Rescue AI"))),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LOCATION HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.grey[50],
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: Color.fromRGBO(76, 175, 80, 1), size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Current Location", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text("Delhi, India", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(10)),
                    child: const Text("GPS Active", style: TextStyle(color: Color.fromRGBO(76, 175, 80, 1), fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // SOS BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: SizedBox(
                height: 85, 
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 8,
                    shadowColor: Colors.redAccent.withOpacity(0.5),
                  ),
                  icon: const Icon(Icons.bluetooth_searching, color: Colors.white, size: 40),
                  label: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SOS - EMERGENCY", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text("Tap to scan for ANY device", style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SosBroadcastingScreen()));
                  },
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text("Emergency Guidelines", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, 
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: mainCategories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => InfoDetailScreen(categoryName: mainCategories[index]["name"]))),
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainCategories[index]["color"].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: mainCategories[index]["color"], width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mainCategories[index]["icon"], size: 40, color: mainCategories[index]["color"]),
                        const SizedBox(height: 5),
                        Text(mainCategories[index]["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text("Live Disaster Map", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            Container(
              height: 300,
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 30),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: FlutterMap(
                  options: const MapOptions(initialCenter: LatLng(28.7041, 77.1025), initialZoom: 10.0),
                  children: [
                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                    MarkerLayer(markers: mapMarkers),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- SCREEN 2: INFO DETAIL PAGE ---
class InfoDetailScreen extends StatelessWidget {
  final String categoryName;
  const InfoDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    if (categoryName == "OTHER EMERGENCIES") {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("OTHER EMERGENCIES"),
            backgroundColor: const Color.fromARGB(255, 151, 239, 245),
            bottom: const TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(icon: Icon(Icons.local_police), text: "CRIME"),
                Tab(icon: Icon(Icons.car_crash), text: "ACCIDENT"),
                Tab(icon: Icon(Icons.medical_services), text: "MEDICAL"),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ContentPage(type: "CRIME"),
              ContentPage(type: "ACCIDENT"),
              ContentPage(type: "MEDICAL"),
            ],
          ),
        ),
      );
    } 
    Color themeColor;
    if (categoryName == "FIRE") themeColor = const Color.fromARGB(255, 245, 191, 111);
    else if (categoryName == "FLOOD") themeColor = const Color.fromARGB(255, 114, 188, 248);
    else themeColor = const Color.fromARGB(255, 84, 228, 173);

    return Scaffold(
      appBar: AppBar(title: Text(categoryName), backgroundColor: themeColor),
      body: ContentPage(type: categoryName),
    );
  }
}

// --- REUSABLE CONTENT PAGE ---
class ContentPage extends StatelessWidget {
  final String type;
  const ContentPage({super.key, required this.type});

  String _getImageAsset() {
    switch (type) {
      case "FIRE": return "assets/images/fire.png";
      case "FLOOD": return "assets/images/flood.png";
      case "EARTHQUAKE": return "assets/images/earthquake.png";
      case "CRIME": return "assets/images/crime.png";
      case "ACCIDENT": return "assets/images/accident.png";
      case "MEDICAL": return "assets/images/medical.png";
      default: return "";
    }
  }

  Map<String, List<String>> getData() {
    switch (type) {
      case "FIRE": return { "dos": ["Crawl low under smoke.", "Touch doors before opening.", "Stop, Drop, and Roll."], "donts": ["Don't use elevators.", "Don't hide in closets.", "Don't re-enter building."] };
      case "FLOOD": return { "dos": ["Move to higher ground.", "Turn off utilities.", "Listen to emergency radio."], "donts": ["Don't walk through water.", "Don't drive into floods.", "Don't touch electrics."] };
      case "EARTHQUAKE": return { "dos": ["Drop, Cover, Hold On.", "Stay indoors till safe.", "Move away from glass."], "donts": ["Don't run outside.", "Don't stand in doorways.", "Don't use matches."] };
      case "CRIME": return { "dos": ["Run, Hide, Fight.", "Keep hands visible.", "Cooperate if robbed."], "donts": ["Don't resist armed robbery.", "Don't make sudden moves.", "Don't stay to film."] };
      case "ACCIDENT": return { "dos": ["Check for danger.", "Call emergency services.", "Turn off engine."], "donts": ["Don't move injured.", "Don't remove objects.", "Don't leave scene."] };
      case "MEDICAL": return { "dos": ["Check Airway/Breathing.", "Apply pressure to bleeds.", "Recovery position."], "donts": ["Don't give food/water.", "Don't stop CPR.", "Don't induce vomiting."] };
      default: return {"dos": [], "donts": []};
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = getData();
    final imageAsset = _getImageAsset();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[100], border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
            child: Image.asset(imageAsset, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(5)), child: Text("✅ DO'S", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green[800]))),
                const SizedBox(height: 10),
                ...data['dos']!.map((text) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 16)))]))),
                const SizedBox(height: 25),
                Container(padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10), decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(5)), child: Text("❌ DON'TS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[800]))),
                const SizedBox(height: 10),
                ...data['donts']!.map((text) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.cancel, color: Colors.red, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 16)))]))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- SCREEN 3: UNIVERSAL SOS SCANNER (SHOWS *ALL* DEVICES - NO CONNECT BUTTON) ---
class SosBroadcastingScreen extends StatefulWidget {
  const SosBroadcastingScreen({super.key});

  @override
  State<SosBroadcastingScreen> createState() => _SosBroadcastingScreenState();
}

class _SosBroadcastingScreenState extends State<SosBroadcastingScreen> with TickerProviderStateMixin {
  bool isScanning = false;
  late AnimationController _pulseController;
  late AnimationController _radarController;

  // Store scan results
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    
    // Start Scanning Immediately
    startScan(); 
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    _scanSubscription.cancel();
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  void startScan() async {
    setState(() { isScanning = true; });
    _pulseController.repeat(reverse: false);
    _radarController.repeat();

    // LISTEN TO EVERYTHING (NO FILTERS)
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          // SORT: Devices with names first, then by signal strength
          results.sort((a, b) {
            if (a.device.platformName.isNotEmpty && b.device.platformName.isEmpty) return -1;
            if (a.device.platformName.isEmpty && b.device.platformName.isNotEmpty) return 1;
            return b.rssi.compareTo(a.rssi); // Stronger signal first
          });
          _scanResults = results;
        });
      }
    });

    try {
      // Start the scan (allow duplicates to update signal strength)
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: true);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scan Error: $e")));
    }

    // Stop animation after timeout
    Future.delayed(const Duration(seconds: 15), () {
      if(mounted) setState(() { isScanning = false; });
      _pulseController.stop();
      _radarController.stop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], 
      appBar: AppBar(title: const Text("SOS-EMERGENCY SCANNER"), backgroundColor: Colors.redAccent),
      body: Column(
        children: [
          // --- TOP: ANIMATION AREA ---
          Expanded(
            flex: 3,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: isScanning ? null : startScan,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isScanning) ...[
                            RippleAnimation(controller: _pulseController, delay: 0.0, size: 280),
                            RippleAnimation(controller: _pulseController, delay: 0.5, size: 280),
                          ],
                          Container(
                            width: 180, height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, 
                              color: isScanning ? Colors.red : Colors.grey[800],
                              boxShadow: isScanning ? [const BoxShadow(color: Colors.redAccent, blurRadius: 20, spreadRadius: 5)] : [],
                            ),
                            child: Center(
                              child: Text(
                                isScanning ? "SCANNING" : "RE-SCAN", 
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)
                              )
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (isScanning)
                      Column(
                        children: [
                          const Text("SEARCHING FOR ALL DEVICES...", style: TextStyle(color: Colors.greenAccent, letterSpacing: 2, fontSize: 14)),
                          const SizedBox(height: 15),
                          SizedBox(
                            width: 120, height: 120,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                 Container(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent.withOpacity(0.3)))),
                                 Container(width: 80, height: 80, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.greenAccent.withOpacity(0.3)))),
                                 RotationTransition(
                                   turns: _radarController,
                                   child: Container(
                                     decoration: BoxDecoration(
                                       shape: BoxShape.circle,
                                       gradient: SweepGradient(
                                         colors: [Colors.transparent, Colors.greenAccent.withOpacity(0.5)],
                                         stops: const [0.8, 1.0],
                                       ),
                                     ),
                                   ),
                                 ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      const Text("Tap button to refresh list", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM: FOUND DEVICES LIST ---
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("FOUND DEVICES (${_scanResults.length})", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                        if(isScanning) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _scanResults.isEmpty
                      ? const Center(child: Text("No devices found yet...", style: TextStyle(color: Colors.grey)))
                      : ListView.separated(
                          itemCount: _scanResults.length,
                          separatorBuilder: (c, i) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = _scanResults[index];
                            final name = result.device.platformName.isNotEmpty ? result.device.platformName : "Unknown Device";
                            final id = result.device.remoteId.toString();
                            final rssi = result.rssi;
                            
                            return ListTile(
                              leading: Icon(
                                name == "Unknown Device" ? Icons.bluetooth_disabled : Icons.phone_android, 
                                color: name == "Unknown Device" ? Colors.grey : Colors.blue
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), 
                              subtitle: Text("ID: $id\nSignal: $rssi dBm"),
                              isThreeLine: true,
                              trailing: const Icon(Icons.signal_cellular_alt, color: Colors.green),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- HELPER CLASSES ---
class RippleAnimation extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final double size;

  const RippleAnimation({super.key, required this.controller, required this.delay, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double progress = (controller.value + delay) % 1.0;
        final double currentSize = size * progress;
        final double opacity = 1.0 - progress;

        return Container(
          width: currentSize,
          height: currentSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.redAccent.withOpacity(opacity), width: 4),
          ),
        );
      },
    );
  }
}

// --- SCREEN 4: CHAT SCREEN ---
class ChatScreen extends StatefulWidget {
  final String connectedEndpointId;
  final String connectedEndpointName;
  const ChatScreen({super.key, required this.connectedEndpointId, required this.connectedEndpointName});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, String>> messages = [];
  TextEditingController msgController = TextEditingController();
  late GenerativeModel _aiModel;
  late ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    if (widget.connectedEndpointId == "ai_simulator") {
      _aiModel = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: GEMINI_API_KEY);
      _chatSession = _aiModel.startChat();
      messages.add({"sender": "rescuer", "text": "Rescue Control here. What is your emergency?"});
    }
  }

  void sendMessage(String message) async {
    setState(() { messages.add({"sender": "me", "text": message}); });
    msgController.clear();
    if (widget.connectedEndpointId == "ai_simulator") {
      try {
        final response = await _chatSession.sendMessage(Content.text(message));
        setState(() { messages.add({"sender": "rescuer", "text": response.text ?? "..."}); });
      } catch (e) { setState(() { messages.add({"sender": "rescuer", "text": "Error: $e"}); }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.connectedEndpointName), backgroundColor: Colors.teal),
      body: Column(
        children: [
          Expanded(child: ListView.builder(itemCount: messages.length, itemBuilder: (c, i) {
             bool isMe = messages[i]["sender"] == "me";
             return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.all(5), decoration: BoxDecoration(color: isMe ? Colors.blue[100] : Colors.grey[300], borderRadius: BorderRadius.circular(10)), child: Text(messages[i]["text"]!)));
          })),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(controller: msgController, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Type message..."), onSubmitted: sendMessage),
          ),
        ],
      ),
    );
  }
}