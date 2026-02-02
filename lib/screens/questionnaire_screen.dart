import 'package:flutter/material.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';
import '../logic/threshold_logic.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _selectedIndex = -1;

  final List<String> _options = [
    "Always burns, never tans",
    "Burns easily, tans minimally",
    "Sometimes burns, tans gradually",
    "Rarely burns, tans well",
    "Never burns, tans profusely",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Skin Sensitivity")),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "How does your skin react to the sun without protection?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _options.length,
              separatorBuilder: (ctx, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return RadioListTile<int>(
                  activeColor: Colors.teal,
                  title: Text(_options[index]),
                  value: index,
                  groupValue: _selectedIndex,
                  onChanged: (val) {
                    setState(() {
                      _selectedIndex = val!;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: PrimaryButton(
              text: "Continue To Dashboard",
              onPressed: _selectedIndex != -1
                  ? () {
                      int initialThreshold = ThresholdLogic.getInitialThreshold(_selectedIndex);
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.dashboard, 
                        arguments: initialThreshold
                      );
                    }
                  : () {}, // Disabled state is handled visually by button style usually, but here just no-op
            ),
          ),
        ],
      ),
    );
  }
}
