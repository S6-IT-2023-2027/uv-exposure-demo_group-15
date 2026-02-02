import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';

class FeedbackScreen extends StatefulWidget {
  final double cumulativeExposure;
  final int currentThreshold;

  const FeedbackScreen({
    super.key, 
    required this.cumulativeExposure,
    required this.currentThreshold,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  int _selectedFeedback = -1;
  final List<String> _options = [
    "None (No redness/pain)",
    "Mild (Slight pinkness)",
    "Moderate (Visible burn)",
    "Severe (Painful burn)"
  ];

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
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: _selectedFeedback == index ? Colors.teal[50] : Colors.white,
                  child: ListTile(
                    title: Text(_options[index]),
                    leading: Radio<int>(
                      value: index,
                      groupValue: _selectedFeedback,
                      onChanged: (val) {
                        setState(() {
                          _selectedFeedback = val!;
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        _selectedFeedback = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: "See Analysis",
              onPressed: _selectedFeedback != -1
                  ? () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.explanation,
                        arguments: {
                          'cumulative': widget.cumulativeExposure,
                          'threshold': widget.currentThreshold,
                          'feedback': _selectedFeedback,
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
