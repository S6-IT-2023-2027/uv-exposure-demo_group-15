import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(Icons.wb_sunny_rounded, size: 100, color: Colors.orangeAccent),
              const SizedBox(height: 32),
              Text(
                AppConstants.onboardingTitle,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppConstants.onboardingDesc,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                text: AppConstants.startSetup,
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.questionnaire);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
