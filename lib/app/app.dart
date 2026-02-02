import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import 'routes.dart';
import '../screens/onboarding_screen.dart';
import '../screens/questionnaire_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/explanation_screen.dart';

class UVApp extends StatelessWidget {
  const UVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.onboarding,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.onboarding:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          
          case AppRoutes.questionnaire:
            return MaterialPageRoute(builder: (_) => const QuestionnaireScreen());
          
          case AppRoutes.dashboard:
            // Expecting int argument for threshold
            final args = settings.arguments as int?;
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(
                initialThreshold: args ?? AppConstants.defaultThreshold,
              ),
            );
          
          case AppRoutes.feedback:
            // Expecting Map with cumulative & threshold
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => FeedbackScreen(
                cumulativeExposure: args['cumulative'] as double,
                currentThreshold: args['threshold'] as int,
              ),
            );
          
          case AppRoutes.explanation:
            // Expecting Map with cumulative, threshold, feedback
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => ExplanationScreen(
                cumulativeExposure: args['cumulative'] as double,
                oldThreshold: args['threshold'] as int,
                feedbackIndex: args['feedback'] as int,
              ),
            );
            
          default:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        }
      },
    );
  }
}
