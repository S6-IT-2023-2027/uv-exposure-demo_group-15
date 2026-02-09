import 'package:flutter/material.dart';
import '../services/xai_service.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';

class ExplanationScreen extends StatelessWidget {
  final double cumulativeExposure;
  final double currentUV;
  final double threshold; // New threshold
  final double previousThreshold;
  final String feedback;

  const ExplanationScreen({
    super.key,
    required this.cumulativeExposure,
    required this.currentUV,
    required this.threshold,
    required this.previousThreshold,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    // Generate explanation using XAI Service
    final xaiService = XAIService();
    String explanation = xaiService.generateExplanation(
      currentUV: currentUV,
      cumulativeUV: cumulativeExposure,
      threshold: threshold,
      feedback: feedback,
      previousThreshold: previousThreshold,
    );

    double diff = threshold - previousThreshold;
    String sign = diff >= 0 ? "+" : "";

    return Scaffold(
      appBar: AppBar(title: const Text("Analysis")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.insights, size: 80, color: Colors.indigo),
            const SizedBox(height: 24),
            Text(
              "Daily Summary",
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                explanation,
                style: const TextStyle(fontSize: 16, height: 1.5),
                textAlign: TextAlign.justify,
              ),
            ),
            
            const SizedBox(height: 10),
            Text(
              "This system learns from your feedback over time.",
              style: TextStyle(color: Colors.grey[500], fontSize: 12, fontStyle: FontStyle.italic),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
            
            Text(
              "Adaptive Adjustment",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  previousThreshold.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Text(
                  threshold.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            Text(
              "($sign${diff.toStringAsFixed(0)} to your daily limit)",
              style: TextStyle(
                color: diff >= 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold
              ),
            ),
            const Spacer(),
            PrimaryButton(
              text: "Back to Home",
              onPressed: () {
                // Return to dashboard with new threshold
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  AppRoutes.dashboard, 
                  (route) => false,
                  arguments: threshold.toInt() // integer strictly for backward compat if needed, though we use service mostly
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
