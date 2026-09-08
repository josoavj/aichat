import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/stats_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<StatsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasksData = statsProvider.getTasksPerDay();
        final focusData = statsProvider.getFocusMinutesPerDay();

        return RefreshIndicator(
          onRefresh: () => statsProvider.loadStats(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSummaryCards(statsProvider, theme),
              const SizedBox(height: 24),
              _buildChartSection(
                title: 'Tâches terminées (7 jours)',
                chart: _TasksBarChart(data: tasksData, color: theme.primaryColor),
                theme: theme,
              ),
              const SizedBox(height: 24),
              _buildChartSection(
                title: 'Minutes de Focus (7 jours)',
                chart: _FocusLineChart(data: focusData, color: theme.primaryColor),
                theme: theme,
              ),
              const SizedBox(height: 100), // Espace pour la barre de navigation
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(StatsProvider stats, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total Tâches',
            value: stats.completedTasks.length.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Sessions Focus',
            value: stats.focusSessions.length.toString(),
            icon: Icons.timer_outlined,
            color: theme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection({required String title, required Widget chart, required ThemeData theme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 250,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: chart,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _TasksBarChart extends StatelessWidget {
  final Map<DateTime, int> data;
  final Color color;

  const _TasksBarChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.keys.toList()..sort();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (data.values.fold(0, (prev, curr) => curr > prev ? curr : prev) + 1).toDouble(),
        barGroups: List.generate(sortedKeys.length, (index) {
          final date = sortedKeys[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[date]!.toDouble(),
                color: color,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = sortedKeys[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

class _FocusLineChart extends StatelessWidget {
  final Map<DateTime, int> data;
  final Color color;

  const _FocusLineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.keys.toList()..sort();
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value % 1 != 0) return const SizedBox();
                final index = value.toInt();
                if (index < 0 || index >= sortedKeys.length) return const SizedBox();
                final date = sortedKeys[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${date.day}/${date.month}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(sortedKeys.length, (index) {
              return FlSpot(index.toDouble(), data[sortedKeys[index]]!.toDouble());
            }),
            isCurved: true,
            color: color,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
