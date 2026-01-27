import 'dart:async';
import 'dart:convert';
import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_icons/weather_icons.dart'; 
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http; 
import 'package:geolocator/geolocator.dart'; 
import 'package:intl/intl.dart'; 
import 'ai_rescuer_screen.dart';

// --- LOCAL IMPORTS ---
import 'profile_screen.dart';
import 'api_key.dart'; 
import 'guidelines_screen.dart';
import 'alerts_screen.dart';
import 'disaster_map_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardScreen(),
  ));
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // VARIABLES
  String weatherDisplayLabel = "Loading..."; 
  String weatherAssetPath = "assets/weather/sunny_day.gif"; 
  String temp = "--°C";
  String aqi = "--"; 
  String locationName = "Locating..."; 
  String currentTime = "--:--";
  LatLng currentLocation = const LatLng(28.7041, 77.1025); 

  @override
  void initState() {
    super.initState();
    _startClock();
    _initializeDashboard();
  }

  void _startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          currentTime = DateFormat('hh:mm a').format(DateTime.now());
        });
      }
    });
  }

  void _initializeDashboard() async {
    await _checkPermissions();
    Position? pos = await _determinePosition();
    
    if (pos != null) {
      setState(() {
        currentLocation = LatLng(pos.latitude, pos.longitude);
      });
      _fetchLocationName(pos.latitude, pos.longitude);
      _fetchLiveWeather(pos.latitude, pos.longitude);
    } else {
      _fetchLiveWeather(28.7041, 77.1025); // Fallback
    }
  }

  Future<void> _checkPermissions() async {
    await [Permission.location, Permission.bluetooth, Permission.bluetoothScan, Permission.bluetoothConnect].request();
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchLocationName(double lat, double lng) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=10');
      final response = await http.get(url, headers: {'User-Agent': 'SahayakMeshApp/1.0'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String name = data['address']['state'] ?? data['address']['city'] ?? "Unknown Location";
        if (mounted) {
          setState(() {
            locationName = name; 
          });
        }
      }
    } catch (e) {
      debugPrint("Geocoding Error: $e");
    }
  }

  Future<void> _fetchLiveWeather(double lat, double lng) async {
    try {
      final weatherUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lng&current=temperature_2m,weather_code,is_day&timezone=auto');
      final aqiUrl = Uri.parse('https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lng&current=us_aqi');

      final results = await Future.wait([
        http.get(weatherUrl),
        http.get(aqiUrl),
      ]);

      if (results[0].statusCode == 200) {
        final wData = jsonDecode(results[0].body);
        setState(() {
          temp = "${wData['current']['temperature_2m']}°C";
          int code = wData['current']['weather_code'];
          
          int hour = DateTime.now().hour;
          bool isNight = hour < 6 || hour >= 18;

          weatherDisplayLabel = _getWeatherDescription(code); 
          weatherAssetPath = _getWeatherAsset(code, isNight);
        });
      }

      if (results[1].statusCode == 200) {
        final aData = jsonDecode(results[1].body);
        setState(() {
          aqi = "${aData['current']['us_aqi']}";
        });
      }

    } catch (e) {
      debugPrint("Weather Error: $e");
    }
  }

  String _getWeatherDescription(int code) {
    if (code == 0) return "Clear Sky";
    if (code == 1 || code == 2 || code == 3) return "Partly Cloudy";
    if (code >= 45 && code <= 48) return "Foggy";
    if (code >= 51 && code <= 67) return "Rainy";
    if (code >= 71 && code <= 77) return "Snowfall";
    if (code >= 80 && code <= 82) return "Heavy Rain";
    if (code >= 95) return "Thunderstorm";
    return "Moderate";
  }

  String _getWeatherAsset(int code, bool isNight) {
    if (code >= 51 && code <= 67) return "assets/weather/rain.gif";
    if (code >= 80 && code <= 99) return "assets/weather/rain.gif";
    if (code >= 71 && code <= 77) return "assets/weather/winter.gif";
    
    if (isNight) {
      return "assets/weather/sunny_night.gif"; 
    } else {
      return "assets/weather/sunny_day.gif";   
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      drawer: _buildSandwichDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        title: const Text("SAHAYAK MESH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
        actions: [
           IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen())),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildLocalWeatherBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // WEATHER CARD
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4), 
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.my_location, color: Colors.tealAccent, size: 20),
                                        const SizedBox(width: 5),
                                        Text(locationName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Text(currentTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                                  child: const Text("GPS Active", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(_getWeatherIcon(), color: Colors.orangeAccent, size: 30),
                                    const SizedBox(height: 5),
                                    Text(temp, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    Text(weatherDisplayLabel, style: const TextStyle(color: Colors.tealAccent)),
                                  ],
                                ),
                                Container(width: 1, height: 40, color: Colors.white24),
                                Column(
                                  children: [
                                    const Icon(Icons.air, color: Colors.white70, size: 30),
                                    const SizedBox(height: 5),
                                    Text("AQI: $aqi", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    _buildAqiStatus(),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // SPACER PUSHES CONTENT TO BOTTOM
                const Spacer(),

                // SOS BUTTON AT BOTTOM
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SosBroadcastingScreen())),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Colors.redAccent, Colors.red]),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.6), blurRadius: 20, spreadRadius: 2)],
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Text("SOS - EMERGENCY", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ),
                ),
                // PADDING TO KEEP IT OFF THE EDGE
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAqiStatus() {
    int aqiVal = int.tryParse(aqi) ?? 0;
    String status = "Good";
    Color color = Colors.greenAccent;

    if (aqiVal > 50) { status = "Moderate"; color = Colors.yellow; }
    if (aqiVal > 100) { status = "Unhealthy"; color = Colors.orange; }
    if (aqiVal > 200) { status = "Hazardous"; color = Colors.red; }

    return Text(status, style: TextStyle(color: color));
  }

  Widget _buildLocalWeatherBackground() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.black),
      child: Image.asset(
        weatherAssetPath, 
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          color: Colors.black,
          child: Center(child: Text("Missing: $weatherAssetPath", style: const TextStyle(color: Colors.red))),
        ),
      ),
    );
  }

  IconData _getWeatherIcon() {
    if (weatherDisplayLabel.contains("Rain")) return WeatherIcons.rain;
    if (weatherDisplayLabel.contains("Snow")) return WeatherIcons.snow;
    if (weatherDisplayLabel.contains("Cloud")) return WeatherIcons.cloudy;
    if (weatherAssetPath.contains("night")) return WeatherIcons.night_clear;
    return WeatherIcons.day_sunny;
  }

  Widget _buildSandwichDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[900]?.withOpacity(0.95), 
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black, 
              image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=1000&auto=format&fit=crop"), fit: BoxFit.cover)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(backgroundColor: Colors.white, radius: 30, child: Icon(Icons.person, size: 30, color: Colors.black)),
                const SizedBox(height: 10),
                const Text("Anu Singh", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10)])),
                Text(locationName, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          
          _buildDrawerItem(Icons.person, "My Profile", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProfileScreen()))),
          _buildDrawerItem(Icons.map, "Disaster Prone Map", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const DisasterMapScreen()))),
          _buildDrawerItem(Icons.library_books, "Disaster Guidelines", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const GuidelinesListScreen()))),
          _buildDrawerItem(Icons.notifications_active, "Disaster Alerts", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AlertsScreen()))),
          const Divider(color: Colors.white24),
          _buildDrawerItem(Icons.bluetooth_searching, "SOS Scanner", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SosBroadcastingScreen()))),
          _buildDrawerItem(Icons.smart_toy,"AI Rescuer", () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AiRescuerScreen()))),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.tealAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}

// ==========================================
// SOS SCREEN
// ==========================================
class SosBroadcastingScreen extends StatefulWidget {
  const SosBroadcastingScreen({super.key});
  @override
  State<SosBroadcastingScreen> createState() => _SosBroadcastingScreenState();
}

class _SosBroadcastingScreenState extends State<SosBroadcastingScreen> with TickerProviderStateMixin {
  bool isScanning = false;
  late AnimationController _pulseController;
  late AnimationController _radarController;
  List<ScanResult> _scanResults = [];
  late StreamSubscription<List<ScanResult>> _scanSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _radarController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    startScan(); 
  }

  @override
  void dispose() {
    try { _scanSubscription.cancel(); } catch(e) {}
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  void startScan() async {
    setState(() { isScanning = true; });
    _pulseController.repeat(reverse: false);
    _radarController.repeat();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          results.sort((a, b) {
            if (a.device.platformName.isNotEmpty && b.device.platformName.isEmpty) return -1;
            if (a.device.platformName.isEmpty && b.device.platformName.isNotEmpty) return 1;
            return b.rssi.compareTo(a.rssi); 
          });
          _scanResults = results;
        });
      }
    });

    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15), androidUsesFineLocation: true);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Scan Error: $e")));
    }

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

// ==========================================
// CHAT SCREEN
// ==========================================
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
// ==========================================
// PASTE THIS AT THE VERY BOTTOM OF main.dart
// ==========================================

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