import 'dart:ui'; // Required for the glass blur effect
import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // PURE DARK THEME
      appBar: AppBar(
        title: const Text("LIVE DISASTER ALERTS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.tealAccent),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Refreshing Alerts...")));
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // SECTION 1: CRITICAL
          _buildSectionTitle("CRITICAL THREATS (2)"),
          _buildAlertCard(
            context,
            type: "EARTHQUAKE WARNING",
            location: "New Delhi, India (4.5 Magnitude)",
            time: "2 mins ago",
            severityColor: Colors.redAccent,
            icon: Icons.landslide,
            description: "Seismographs have detected tremors in North India. \n\nACTION REQUIRED:\n1. Drop, Cover, and Hold On.\n2. Stay away from glass windows.\n3. Do not use elevators.",
          ),
          _buildAlertCard(
            context,
            type: "FLASH FLOOD ALERT",
            location: "Yamuna River Bank",
            time: "15 mins ago",
            severityColor: Colors.redAccent,
            icon: Icons.flood,
            description: "Water levels have crossed the danger mark (205.33m). \n\nACTION REQUIRED:\n1. Evacuate low-lying areas immediately.\n2. Move to upper floors if trapped.\n3. Do not walk through flowing water.",
          ),

          const SizedBox(height: 25),

          // SECTION 2: ADVISORIES
          _buildSectionTitle("ENVIRONMENTAL ADVISORIES"),
          _buildAlertCard(
            context,
            type: "HAZARDOUS AIR QUALITY",
            location: "Anand Vihar, Delhi",
            time: "1 hour ago",
            severityColor: Colors.orange,
            icon: Icons.cloud_off, 
            description: "AQI has reached 450 (Severe). \n\nADVICE:\n1. Avoid outdoor cardio.\n2. Wear N95 masks if travelling.\n3. Use air purifiers indoors.",
          ),
          _buildAlertCard(
            context,
            type: "HEATWAVE WARNING",
            location: "Rajasthan & NCR Region",
            time: "3 hours ago",
            severityColor: Colors.amber,
            icon: Icons.sunny,
            description: "Temperatures expected to cross 47°C. \n\nADVICE:\n1. Stay hydrated.\n2. Cover head when outside.\n3. Look out for signs of heatstroke.",
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey[400], fontSize: 13, letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String type,
    required String location,
    required String time,
    required Color severityColor,
    required IconData icon,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Dark Card Background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: severityColor.withOpacity(0.5), width: 1), // Glowing Border
        boxShadow: [
          BoxShadow(color: severityColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ExpansionTile(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: severityColor.withOpacity(0.2),
              ),
              child: Icon(icon, color: severityColor, size: 24),
            ),
            title: Text(
              type,
              style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(location, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
              ],
            ),
            childrenPadding: const EdgeInsets.all(15),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Colors.white24),
              Text(
                description,
                style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: severityColor.withOpacity(0.2),
                    foregroundColor: severityColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: severityColor),
                  ),
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text("SHARE ALERT"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Alert Shared to Contacts")));
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}