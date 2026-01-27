import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  UserProfile _user = UserProfile();
  
  // STATE: Are we viewing or editing?
  bool _isEditing = true; 

  // Controllers
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _iceNameCtrl = TextEditingController();
  final _icePhoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _langCtrl = TextEditingController();
  
  // Medical Controllers
  final _allergiesCtrl = TextEditingController();
  final _conditionsCtrl = TextEditingController();
  final _medsCtrl = TextEditingController();
  final _implantsCtrl = TextEditingController();
  final _mobilityCtrl = TextEditingController();
  final _pregnancyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() async {
    UserProfile data = await ProfileService.getProfile();
    setState(() {
      _user = data;
      // Populate Text Controllers
      _nameCtrl.text = _user.name;
      _dobCtrl.text = _user.dob;
      _phoneCtrl.text = _user.phone;
      _iceNameCtrl.text = _user.iceName;
      _icePhoneCtrl.text = _user.icePhone;
      _addressCtrl.text = _user.address;
      _langCtrl.text = _user.languages;
      
      _allergiesCtrl.text = _user.allergies;
      _conditionsCtrl.text = _user.conditions;
      _medsCtrl.text = _user.medications;
      _implantsCtrl.text = _user.implants;
      _mobilityCtrl.text = _user.mobilityStatus;
      _pregnancyCtrl.text = _user.pregnancyStatus;

      // LOGIC: If name exists, show Summary View (Read-Only) first
      if (_user.name.isNotEmpty) {
        _isEditing = false; 
      }
    });
  }

  Future<void> _pickImage() async {
    if (!_isEditing) return; // Disable clicking if not editing
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _user.imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (!_isEditing) return;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          // Dark Date Picker Theme
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Colors.tealAccent, onPrimary: Colors.black, surface: Colors.grey),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
        _user.dob = _dobCtrl.text;
      });
    }
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      // Update User Object
      _user.name = _nameCtrl.text;
      _user.phone = _phoneCtrl.text;
      _user.iceName = _iceNameCtrl.text;
      _user.icePhone = _icePhoneCtrl.text;
      _user.address = _addressCtrl.text;
      _user.languages = _langCtrl.text;
      
      _user.allergies = _allergiesCtrl.text;
      _user.conditions = _conditionsCtrl.text;
      _user.medications = _medsCtrl.text;
      _user.implants = _implantsCtrl.text;
      _user.mobilityStatus = _mobilityCtrl.text;
      _user.pregnancyStatus = _pregnancyCtrl.text;

      await ProfileService.saveProfile(_user);
      
      setState(() {
        _isEditing = false; // Switch back to Summary View
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile Saved! Switching to View Mode."), backgroundColor: Colors.teal),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // DARK BACKGROUND
      appBar: AppBar(
        title: Text(_isEditing ? "Edit Profile" : "My ID Card", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        actions: [
          // EDIT BUTTON (Only visible when NOT editing)
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.tealAccent),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.tealAccent,
          labelColor: Colors.tealAccent,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "PERSONAL"),
            Tab(icon: Icon(Icons.medical_services), text: "MEDICAL"),
          ],
        ),
      ),
      body: _isEditing 
        ? _buildEditForm() // SHOW FORM
        : _buildSummaryView(), // SHOW SUMMARY
        
      floatingActionButton: _isEditing 
        ? FloatingActionButton.extended(
            onPressed: _saveData,
            backgroundColor: Colors.tealAccent,
            icon: const Icon(Icons.save, color: Colors.black),
            label: const Text("SAVE PROFILE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        : null, // No Save button in View mode
    );
  }

  // ==========================================
  // VIEW MODE: SUMMARY DISPLAY (DARK)
  // ==========================================
  Widget _buildSummaryView() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Personal Summary
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildSummaryCard("Identity", [
                "Full Name: ${_user.name}",
                "DOB: ${_user.dob}",
                "Gender: ${_user.gender}",
                "Languages: ${_user.languages}",
              ], Icons.badge),
              _buildSummaryCard("Contact Info", [
                "Phone: ${_user.phone}",
                "Address: ${_user.address}",
              ], Icons.home),
              _buildSummaryCard("Emergency Contact (ICE)", [
                "Name: ${_user.iceName}",
                "Phone: ${_user.icePhone}",
              ], Icons.phone_callback, isEmergency: true),
            ],
          ),
        ),
        // Medical Summary
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildSummaryCard("Critical Specs", [
                "Blood Group: ${_user.bloodGroup}",
                "Pregnancy Status: ${_user.pregnancyStatus}",
                "Mobility: ${_user.mobilityStatus}",
              ], Icons.monitor_heart),
              _buildSummaryCard("Medical Conditions", [
                "Allergies: ${_user.allergies}",
                "Conditions: ${_user.conditions}",
                "Medications: ${_user.medications}",
                "Implants: ${_user.implants}",
              ], Icons.medical_services, isEmergency: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[800],
          backgroundImage: _user.imagePath.isNotEmpty ? FileImage(File(_user.imagePath)) : null,
          child: _user.imagePath.isEmpty ? const Icon(Icons.person, size: 60, color: Colors.white24) : null,
        ),
        const SizedBox(height: 15),
        Text(_user.name.isEmpty ? "No Name" : _user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(_user.bloodGroup.isEmpty ? "Blood: N/A" : "Blood Type: ${_user.bloodGroup}", style: const TextStyle(fontSize: 16, color: Colors.redAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSummaryCard(String title, List<String> lines, IconData icon, {bool isEmergency = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[800], // Dark Card Background
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isEmergency ? Colors.redAccent.withOpacity(0.5) : Colors.transparent),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: isEmergency ? Colors.redAccent : Colors.tealAccent), const SizedBox(width: 10), Text(title, style: TextStyle(color: isEmergency ? Colors.redAccent : Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16))]),
          const Divider(color: Colors.white24),
          ...lines.map((line) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(line, style: const TextStyle(color: Colors.white70, fontSize: 15)))),
        ],
      ),
    );
  }

  // ==========================================
  // EDIT MODE: FORM DISPLAY (DARK)
  // ==========================================
  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalTab(),
          _buildMedicalTab(),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[800],
              backgroundImage: _user.imagePath.isNotEmpty ? FileImage(File(_user.imagePath)) : null,
              child: _user.imagePath.isEmpty ? const Icon(Icons.camera_alt, size: 40, color: Colors.white54) : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(child: Text("Tap to upload photo", style: TextStyle(color: Colors.white38))),
        const SizedBox(height: 20),

        _buildSectionHeader("Identity"),
        _buildTextField("Full Name", Icons.person, _nameCtrl),
        _buildTextField("Date of Birth", Icons.calendar_today, _dobCtrl, readOnly: true, onTap: () => _selectDate(context)),
        _buildDropdown("Gender", ["Male", "Female", "Non-Binary", "Other"], _user.gender, (val) => setState(() => _user.gender = val!)),

        _buildSectionHeader("Contact & Address"),
        _buildTextField("Phone Number", Icons.phone, _phoneCtrl, isNumber: true),
        _buildTextField("Residential Address", Icons.home, _addressCtrl, maxLines: 2),
        _buildTextField("Spoken Languages", Icons.language, _langCtrl),

        _buildSectionHeader("ICE (In Case of Emergency)"),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
          child: Column(
            children: [
              _buildTextField("Emergency Contact Name", Icons.person_add, _iceNameCtrl),
              _buildTextField("Emergency Contact Phone", Icons.phone_in_talk, _icePhoneCtrl, isNumber: true),
            ],
          ),
        ),
        const SizedBox(height: 80), 
      ],
    );
  }

  Widget _buildMedicalTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.tealAccent),
              SizedBox(width: 10),
              Expanded(child: Text("This data will be shared with rescuers during an SOS. Please be accurate.", style: TextStyle(color: Colors.tealAccent))),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSectionHeader("Critical Specs"),
        _buildDropdown("Blood Group", ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "Unknown"], _user.bloodGroup, (val) => setState(() => _user.bloodGroup = val!)),
        _buildDropdown("Pregnancy Status", ["No", "Yes", "1st Trimester", "2nd Trimester", "3rd Trimester"], _user.pregnancyStatus, (val) => setState(() => _user.pregnancyStatus = val!)),
        _buildDropdown("Mobility Status", ["Normal", "Wheelchair User", "Crutches", "Bedridden", "Visually Impaired"], _user.mobilityStatus, (val) => setState(() => _user.mobilityStatus = val!)),

        _buildSectionHeader("Medical Conditions"),
        _buildTextField("Severe Allergies (e.g., Peanuts, Penicillin)", Icons.warning, _allergiesCtrl),
        _buildTextField("Chronic Conditions (e.g., Diabetes, Asthma)", Icons.healing, _conditionsCtrl),
        _buildTextField("Current Medications", Icons.medication, _medsCtrl),
        _buildTextField("Implants (e.g., Pacemaker)", Icons.battery_charging_full, _implantsCtrl),
        
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController ctrl, {bool isNumber = false, int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white), // White Text
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.tealAccent.withOpacity(0.7)),
          filled: true,
          fillColor: Colors.grey[800], // Dark Fill
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: items.contains(currentValue) ? currentValue : null,
        dropdownColor: Colors.grey[800], // Dark Dropdown Menu
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.tealAccent),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}