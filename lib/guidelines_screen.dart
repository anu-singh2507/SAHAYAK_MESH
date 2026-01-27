import 'package:flutter/material.dart';

class GuidelinesListScreen extends StatelessWidget {
  const GuidelinesListScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      "name": "FIRE",
      "icon": Icons.local_fire_department,
      "color": Colors.orangeAccent,
      "desc": "Smoke, Burns, Evacuation"
    },
    {
      "name": "FLOOD",
      "icon": Icons.flood,
      "color": Colors.cyanAccent,
      "desc": "High Water, Electronics"
    },
    {
      "name": "EARTHQUAKE",
      "icon": Icons.landslide,
      "color": Colors.greenAccent,
      "desc": "Drop, Cover, Hold On"
    },
    {
      "name": "OTHER",
      "icon": Icons.warning_amber,
      "color": Colors.purpleAccent,
      "desc": "Medical, Crime, Accident"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // PURE DARK BACKGROUND
      appBar: AppBar(
        title: const Text("SURVIVAL MANUAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2)),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("SELECT EMERGENCY PROTOCOL", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Cards per row
                  childAspectRatio: 0.85, // Taller cards
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return _buildNeonCard(context, categories[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonCard(BuildContext context, Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => InfoDetailScreen(categoryName: item["name"]))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: item["color"].withOpacity(0.5), width: 1), // Glowing Border
          boxShadow: [
            BoxShadow(color: item["color"].withOpacity(0.1), blurRadius: 15, spreadRadius: -5) // Neon Glow
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(shape: BoxShape.circle, color: item["color"].withOpacity(0.1)),
              child: Icon(item["icon"], size: 40, color: item["color"]),
            ),
            const SizedBox(height: 15),
            Text(item["name"], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(item["desc"], textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DETAIL SCREEN (The Manual Pages)
// ==========================================
class InfoDetailScreen extends StatelessWidget {
  final String categoryName;
  const InfoDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Handle "Other" Tabs
    if (categoryName == "OTHER") {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: const Text("OTHER EMERGENCIES", style: TextStyle(color: Colors.white, fontSize: 16)),
            backgroundColor: Colors.grey[900],
            iconTheme: const IconThemeData(color: Colors.white),
            bottom: const TabBar(
              indicatorColor: Colors.purpleAccent,
              labelColor: Colors.purpleAccent,
              unselectedLabelColor: Colors.grey,
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

    // Handle Normal Categories
    Color themeColor;
    if (categoryName == "FIRE") themeColor = Colors.orangeAccent;
    else if (categoryName == "FLOOD") themeColor = Colors.cyanAccent;
    else themeColor = Colors.greenAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(categoryName, style: TextStyle(color: themeColor, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: themeColor),
        elevation: 0,
      ),
      body: ContentPage(type: categoryName),
    );
  }
}

// ==========================================
// CONTENT PAGE (DO'S AND DON'TS + IMAGES)
// ==========================================
class ContentPage extends StatelessWidget {
  final String type;
  const ContentPage({super.key, required this.type});

  // --- 1. Helper to get the correct Image ---
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
      case "FIRE": return { "dos": ["Crawl low under smoke (Air is cleaner).", "Touch doors with back of hand.", "Stop, Drop, and Roll if on fire."], "donts": ["Don't use elevators.", "Don't hide in closets/under beds.", "Don't re-enter burning building."] };
      case "FLOOD": return { "dos": ["Move to higher ground immediately.", "Turn off gas, electricity, water.", "Listen to battery-operated radio."], "donts": ["Don't walk through moving water.", "Don't drive into flooded areas.", "Don't touch electrical equipment."] };
      case "EARTHQUAKE": return { "dos": ["Drop, Cover, and Hold On.", "Stay indoors until shaking stops.", "Stay away from glass/windows."], "donts": ["Don't run outside during shaking.", "Don't stand in doorways.", "Don't use matches/lighters."] };
      case "CRIME": return { "dos": ["Run, Hide, Fight (Last resort).", "Keep hands visible to police.", "Cooperate if robbed (Money isn't worth life)."], "donts": ["Don't resist armed robbery.", "Don't make sudden moves.", "Don't stay to film the event."] };
      case "ACCIDENT": return { "dos": ["Check surroundings for danger.", "Call emergency services.", "Turn off vehicle engine."], "donts": ["Don't move injured unless necessary.", "Don't remove embedded objects.", "Don't leave the scene."] };
      case "MEDICAL": return { "dos": ["Check Airway, Breathing, Circulation.", "Apply pressure to bleeding.", "Place in recovery position if unconscious."], "donts": ["Don't give food/water to unconscious.", "Don't stop CPR until help arrives.", "Don't move head/neck if spinal injury suspected."] };
      default: return {"dos": [], "donts": []};
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = getData();
    final imagePath = _getImageAsset(); // Get the image path

    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        // --- 2. THE IMAGE HEADER ---
        Container(
          height: 180, // Made it slightly taller for better visibility
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
            image: imagePath.isNotEmpty 
              ? DecorationImage(
                  image: AssetImage(imagePath), 
                  fit: BoxFit.cover // This fills the box perfectly
                )
              : null,
          ),
          // Fallback if image is missing: Show the icon
          child: imagePath.isEmpty 
            ? Center(child: Icon(_getIcon(), size: 50, color: Colors.grey[700]))
            : null,
        ),
        
        const SizedBox(height: 30),

        // DO'S SECTION
        const Text("  TACTICAL PROTOCOLS (DO)", style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...data['dos']!.map((text) => _buildChecklistItem(text, true)),

        const SizedBox(height: 30),

        // DON'TS SECTION
        const Text("  HAZARD AVOIDANCE (DON'T)", style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...data['donts']!.map((text) => _buildChecklistItem(text, false)),
      ],
    );
  }

  IconData _getIcon() {
    if (type == "FIRE") return Icons.local_fire_department;
    if (type == "FLOOD") return Icons.flood;
    if (type == "EARTHQUAKE") return Icons.landslide;
    return Icons.warning;
  }

  Widget _buildChecklistItem(String text, bool isGood) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: isGood ? Colors.greenAccent : Colors.redAccent, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(isGood ? Icons.check_circle : Icons.cancel, color: isGood ? Colors.greenAccent : Colors.redAccent, size: 20),
          const SizedBox(width: 15),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 15))),
        ],
      ),
    );
  }
}