import 'package:flutter/material.dart';
import '../core/dummy_data.dart';
import '../models/uv_model.dart';
import '../widgets/uv_card.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/primary_button.dart';
import '../app/routes.dart';

class DashboardScreen extends StatefulWidget {
  final int initialThreshold;

  const DashboardScreen({super.key, required this.initialThreshold});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DummyDataService _dataService = DummyDataService();
  double _currentCumulative = 0.0;
  
  @override
  void initState() {
    super.initState();
    _dataService.startSimulation();
  }

  @override
  void dispose() {
    _dataService.stopSimulation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UV Dashboard"),
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<UVModel>(
        stream: _dataService.uvStream,
        builder: (context, snapshot) {
          double currentUV = 0.0;
          if (snapshot.hasData) {
            currentUV = snapshot.data!.uvIndex;
            _currentCumulative = snapshot.data!.cumulativeExposure;
          }

          bool warning = _currentCumulative >= widget.initialThreshold;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (warning)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning_amber_rounded, color: Colors.red),
                        SizedBox(width: 10),
                        Expanded(child: Text("Limit Reached! Seek shade immediately.", style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                
                UVProgressIndicator(
                  current: _currentCumulative,
                  total: widget.initialThreshold.toDouble(),
                  label: "Exposure",
                ),
                
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: UVInfoCard(
                        title: "Current UV",
                        value: currentUV.toStringAsFixed(1),
                        subtitle: "Index Level",
                        accentColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: UVInfoCard(
                        title: "Max Limit",
                        value: widget.initialThreshold.toString(),
                        subtitle: "Daily Budget",
                        accentColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                Text(
                  "Monitoring Active...", 
                  style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)
                ),
                
                const SizedBox(height: 20),
                
                PrimaryButton(
                  text: "End Day & Give Feedback",
                  onPressed: () {
                     Navigator.pushNamed(
                        context, 
                        AppRoutes.feedback, 
                        arguments: {
                          'cumulative': _currentCumulative,
                          'threshold': widget.initialThreshold,
                        }
                      );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
