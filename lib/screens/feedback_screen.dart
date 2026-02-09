import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import '../services/ml_service.dart';
import '../app/routes.dart';

class FeedbackScreen extends StatefulWidget {
  final double cumulativeExposure;
  final double currentThreshold; // Changed from int to double
  final double currentUV;

  const FeedbackScreen({
    super.key, 
    required this.cumulativeExposure,
    required this.currentThreshold,
    required this.currentUV,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedFeedback = -1;
  final List<String> _options = [
    "None",
    "Mild",
    "Moderate",
    "Severe"
  ];
  
  final List<String> _descriptions = [
    "(No redness or pain)",
    "(Slight pinkness)",
    "(Visible burn)",
    "(Painful burn / Blistering)"
  ];
  
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daily Check-in")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Did you experience any skin discomfort today?",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedFeedback == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFeedback = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.teal : Colors.grey.shade300,
                        width: isSelected ? 2 : 1
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(_options[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(_descriptions[index]),
                      trailing: isSelected 
                        ? const Icon(Icons.check_circle, color: Colors.teal)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: _isUpdating ? "Updating..." : "Submit & Analyze",
              onPressed: (_selectedFeedback != -1 && !_isUpdating)
                  ? () async {
                      setState(() {
                        _isUpdating = true;
                      });

                      // 1. Update Threshold (ML)
                      final mlService = AdaptiveThresholdService();
                      String feedbackLabel = _options[_selectedFeedback];
                      
                      // Store old threshold for comparison
                      double previousThreshold = widget.currentThreshold;
                      
                      await mlService.updateThreshold(feedbackLabel);
                      
                      // Get new threshold
                      double newThreshold = mlService.dailySafeExposureLimit;

                      if (!mounted) return;

                      // 2. Navigate to Explanation
                      Navigator.pushNamed(
                        context,
                        AppRoutes.explanation,
                        arguments: {
                          'cumulative': widget.cumulativeExposure,
                          'currentUV': widget.currentUV,
                          'threshold': newThreshold, // The NEW adapted threshold
                          'previousThreshold': previousThreshold,
                          'feedback': feedbackLabel,
                        },
                      );
                    }
                  : () {},
            ),
          ),
        ],
      ),
    );
  }
}
