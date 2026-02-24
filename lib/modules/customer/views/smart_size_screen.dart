import 'package:flutter/material.dart';
import 'package:pvp_traders/core/constants/app_colors.dart';

class SmartSizeScreen extends StatefulWidget {
  const SmartSizeScreen({super.key});

  @override
  State<SmartSizeScreen> createState() => _SmartSizeScreenState();
}

class _SmartSizeScreenState extends State<SmartSizeScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _recommendedSize;

  void _calculateSize() {
    // Dummy logic for demonstration
    final height = double.tryParse(_heightController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      setState(() {
        if (weight < 50) {
          _recommendedSize = "S";
        } else if (weight < 65) {
          _recommendedSize = "M";
        } else if (weight < 80) {
          _recommendedSize = "L";
        } else {
          _recommendedSize = "XL";
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Smart Size Recommender")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Find your perfect fit instantly with AI!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight_outlined),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _calculateSize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Calculate My Size", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
            if (_recommendedSize != null) ...[
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  children: [
                    const Text("Recommended Size", style: TextStyle(color: Colors.black54)),
                    Text(
                      _recommendedSize!,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
