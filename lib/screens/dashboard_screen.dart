import 'package:flutter/material.dart';
import '../services/uv_data_service.dart';
import '../services/ml_service.dart';
import '../app/routes.dart';

class DashboardScreen extends StatefulWidget {
  // We no longer strictly need initialThreshold passed in if we fetch from service,
  // but we can keep it for initialization or ignore it.
  // For now, let's keep the constructor signature to avoid breaking previous routes immediately,
  // but we'll prefer the service's value.
  final int initialThreshold;

  const DashboardScreen({super.key, required this.initialThreshold});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UVDataService _uvService = UVDataService();
  final AdaptiveThresholdService _mlService = AdaptiveThresholdService();
  
  // We use ValueNotifier or local state for the threshold to ensure it updates if changed
  late double _currentThreshold;

  @override
  void initState() {
    super.initState();
    _currentThreshold = _mlService.dailySafeExposureLimit;
    _uvService.startService();
  }

  @override
  void dispose() {
    // Service disposal might be handled globally or here.
    // For single screen demo, stopping here is fine, but usually services persist.
    // _uvService.stopService(); // Uncomment if we want to stop simulation on exit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text("UV Dashboard"),
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Image.asset(
              'assets/logo/uv_sense_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.wb_sunny_rounded, color: Colors.orange),
            ),
            const SizedBox(width: 10),
            const Text(
              "UV Sense", 
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
            ),
          ],
        ),
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<double>(
        stream: _uvService.uvStream,
        builder: (context, uvSnapshot) {
          return StreamBuilder<double>(
            stream: _uvService.cumulativeStream,
            builder: (context, cumulativeSnapshot) {
              
              double currentUV = uvSnapshot.data ?? 0.0;
              double currentCumulative = cumulativeSnapshot.data ?? 0.0;
              
              // Recalculate warning
              bool warning = currentCumulative >= _currentThreshold;
              double progress = (currentCumulative / _currentThreshold).clamp(0.0, 1.0);

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
                    
                    // Custom Progress Indicator reused or inline
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Exposure", style: Theme.of(context).textTheme.titleMedium),
                            Text("${(progress * 100).toInt()}%", style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(
                            warning ? Colors.red : Colors.orange,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            title: "Current UV",
                            value: currentUV.toStringAsFixed(1),
                            subtitle: "Index",
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            title: "Limit",
                            value: _currentThreshold.toStringAsFixed(0),
                            subtitle: "Daily Budget",
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            title: "Used",
                            value: currentCumulative.toStringAsFixed(0),
                            subtitle: "Accumulated",
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      "Monitoring Active... (Updates every 5s)", 
                      style: TextStyle(color: Colors.grey[500], fontStyle: FontStyle.italic)
                    ),
                    
                    const SizedBox(height: 20),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Give Feedback / End Day"),
                        onPressed: () {
                           Navigator.pushNamed(
                              context, 
                              AppRoutes.feedback, 
                              arguments: {
                                'cumulative': currentCumulative,
                                'threshold': _currentThreshold,
                                'currentUV': currentUV, 
                              }
                            );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title, 
    required String value, 
    required String subtitle, 
    required Color color
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value, 
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: color,
            )
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }
}
