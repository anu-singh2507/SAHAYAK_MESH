import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'api_key.dart'; // Ensure this file has your GEMINI_API_KEY

class AiRescuerScreen extends StatefulWidget {
  const AiRescuerScreen({super.key});

  @override
  State<AiRescuerScreen> createState() => _AiRescuerScreenState();
}

class _AiRescuerScreenState extends State<AiRescuerScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Chat History
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  late GenerativeModel _model;
  late ChatSession _chat;

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  void _initializeAI() {
    // 1. Setup the Model
    // Note: Ensure your API Key is valid!
    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite', 
      apiKey: GEMINI_API_KEY,
    );

    // 2. Define the Persona
    _chat = _model.startChat(history: [
      Content.text("ACT AS A HUMAN RESCUE COORDINATOR named 'Control'. "
          "Do NOT talk like an AI. Be calm, concise, and practical. "
          "Ask for location and status immediately. Keep answers short."),
      Content.model([TextPart("Copy that. Control online. Standing by for distress calls.")]),
    ]);

    // 3. Add the Welcome Message
    setState(() {
      _messages.add({
        "isUser": false,
        "text": "This is Rescue Control. I am receiving your signal. What is your status and location?"
      });
    });
  }

  void _sendMessage() async {
    if (_textController.text.isEmpty) return;

    String userText = _textController.text;
    setState(() {
      _messages.add({"isUser": true, "text": userText});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      var response = await _chat.sendMessage(Content.text(userText));
      
      setState(() {
        _isLoading = false;
        _messages.add({
          "isUser": false,
          "text": response.text ?? "Signal lost... repeat message."
        });
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add({"isUser": false, "text": "Connection Error: ${e.toString()}"});
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // FORCE DARK THEME to ensure text is white by default
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("RESCUE COMMAND", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              Text("● LIVE CONNECTION", style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
            ],
          ),
        ),
        body: Column(
          children: [
            // 1. CHAT AREA
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg["text"] ?? "", msg["isUser"]);
                },
              ),
            ),

            // 2. TYPING INDICATOR
            if (_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Control is typing...",
                  style: TextStyle(color: Colors.greenAccent, fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ),

            // 3. INPUT AREA
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // --- FIXED CHAT BUBBLE ---
  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width * 0.7, 
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1A237E) : const Color(0xFF212121), // Deep Blue vs Dark Grey
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(5),
            topRight: const Radius.circular(5),
            bottomLeft: isUser ? const Radius.circular(5) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(5),
          ),
          border: Border.all(
            color: isUser ? Colors.cyanAccent : Colors.greenAccent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prevents collapsing
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUser ? "YOU" : "RESCUE CONTROL",
              style: TextStyle(
                color: isUser ? Colors.cyanAccent : Colors.greenAccent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white, // FORCED WHITE COLOR
                fontSize: 16, 
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Type message...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: Colors.cyanAccent,
              child: Icon(Icons.send, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}