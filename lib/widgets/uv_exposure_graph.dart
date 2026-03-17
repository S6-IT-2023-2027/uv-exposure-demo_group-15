import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/storage_service.dart';

class UVExposureGraph extends StatelessWidget {
  const UVExposureGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box(StorageService.exposureBoxName).listenable(),
      builder: (context, box, _) {
        final rawData = StorageService().getTodayExposure();

        // Handle empty safely
        if (rawData.isEmpty) {
          return Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: const Text(
              "No UV data recorded yet today.",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Parse to FlSpot points
        List<FlSpot> spots = [];
        double minX = double.maxFinite;
        double maxX = double.minPositive;
        double minY = 0.0;
        double maxY = 15.0; // Standard severe UV upper bound to start with

        for (var i = 0; i < rawData.length; i++) {
          final data = rawData[i];
          final dtStr = data['timestamp'] as String;
          final date = DateTime.parse(dtStr);

          // Convert time to a continuous decimal (e.g., 14.5 for 2:30 PM)
          final double timeVal =
              date.hour + date.minute / 60.0 + date.second / 3600.0;
          final double uvIndex = (data['uvIndex'] as num).toDouble();

          if (timeVal < minX) minX = timeVal;
          if (timeVal > maxX) maxX = timeVal;
          if (uvIndex > maxY) maxY = uvIndex + 2.0;

          spots.add(FlSpot(timeVal, uvIndex));
        }

        // Prevent rendering errors if range is 0
        if (minX == maxX) {
          minX -= 1.0;
          maxX += 1.0;
        }
        
        // Interval calculation that won't result in zero or infinity
        double interval = (maxX - minX) / 3;
        if (interval <= 0) interval = 1.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "UV Exposure Over Time (Today)",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 5,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (value == minX || value == maxX) {
                              return const SizedBox.shrink(); // Prevent cut off
                            }
                            final int hour = value.floor();
                            final int min = ((value - hour) * 60).round();
                            final String minStr = min.toString().padLeft(2, '0');
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '$hour:$minStr',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.orange,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.orange.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
