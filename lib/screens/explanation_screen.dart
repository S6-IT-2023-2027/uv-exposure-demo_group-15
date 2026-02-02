import 'package:flutter/material.dart';
import '../logic/explainability.dart';
import '../logic/threshold_logic.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';

class ExplanationScreen extends StatelessWidget {
  final double cumulativeExposure;
  final int oldThreshold;
  final int feedbackIndex;

  const ExplanationScreen({
    super.key,
    required this.cumulativeExposure,
    required this.oldThreshold,
    required this.feedbackIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Generate explanation
    String explanation = ExplainabilityLogic.generateDailyReport(
      cumulativeExposure, 
      oldThreshold, 
      feedbackIndex
    );

    // Calculate new threshold
    int newThreshold = ThresholdLogic.adjustThreshold(oldThreshold, feedbackIndex);
    int diff = newThreshold - oldThreshold;
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
            const SizedBox(height: 32),
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
                  "$oldThreshold",
                  style: const TextStyle(fontSize: 24, color: Colors.grey),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                Text(
                  "$newThreshold",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
              ],
            ),
            Text(
              "($sign$diff to your daily limit)",
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
                  arguments: newThreshold
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
