import 'package:flutter/material.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final RideService _rideService = RideService();
  String _selectedFilter = 'All Rides';
  Map<String, dynamic> _summary = {
    'totalRides': 0,
    'totalKm': '0.0',
    'incidents': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final summary = await _rideService.getMonthlySummary();
    if (mounted) setState(() => _summary = summary);
  }

  Stream<List<RideModel>> get _ridesStream {
    switch (_selectedFilter) {
      case 'Safe':
        return _rideService.getRidesByStatus(RideStatus.safe);
      case 'Alert':
        return _rideService.getRidesByStatus(RideStatus.alert);
      case 'Incident':
        return _rideService.getRidesByStatus(RideStatus.incident);
      default:
        return _rideService.getRides();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ride History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Filter Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  dropdownColor: theme.cardColor,
                  items: const [
                    DropdownMenuItem(
                        value: 'All Rides', child: Text('All Rides')),
                    DropdownMenuItem(value: 'Safe', child: Text('Safe')),
                    DropdownMenuItem(value: 'Alert', child: Text('Alert')),
                    DropdownMenuItem(
                        value: 'Incident', child: Text('Incident')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedFilter = value);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Monthly Summary
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Month Summary',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryStat(
                          value: '${_summary['totalRides']}',
                          label: 'Total Rides',
                          color: Colors.blue),
                      _SummaryStat(
                          value: '${_summary['totalKm']}',
                          label: 'km Traveled',
                          color: Colors.green),
                      _SummaryStat(
                          value: '${_summary['incidents']}',
                          label: 'Incidents',
                          color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Ride List from Firestore
            StreamBuilder<List<RideModel>>(
              stream: _ridesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading rides',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final rides = snapshot.data ?? [];

                if (rides.isEmpty) {
                  return _card(
                    context,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Icon(
                          Icons.directions_bike_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No rides recorded yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start monitoring a ride and it will appear here',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }

                return Column(
                  children: rides
                      .map((ride) => _rideCard(context, ride: ride))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rideDay = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(rideDay).inDays;

    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $period';

    if (diff == 0) return 'Today • $timeStr';
    if (diff == 1) return 'Yesterday • $timeStr';
    return '${dt.day} ${_monthName(dt.month)} • $timeStr';
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  Widget _rideCard(BuildContext context, {required RideModel ride}) {
    final theme = Theme.of(context);

    Color statusColor;
    String statusLabel;
    switch (ride.status) {
      case RideStatus.incident:
        statusColor = Colors.red;
        statusLabel = 'Incident';
        break;
      case RideStatus.alert:
        statusColor = Colors.orange;
        statusLabel = 'Alert';
        break;
      case RideStatus.safe:
        statusColor = Colors.green;
        statusLabel = 'Safe';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.title,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(ride.startTime),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _rideStat(context, 'Duration', ride.durationLabel),
              _rideStat(context, 'Distance',
                  '${ride.distanceKm.toStringAsFixed(1)} km'),
              _rideStat(context, 'Avg Speed',
                  '${ride.avgSpeedKmh.toStringAsFixed(1)} km/h'),
            ],
          ),

          if (ride.alertNote != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                ride.alertNote!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rideStat(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style:
                theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Summary Stat Widget
class _SummaryStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SummaryStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
