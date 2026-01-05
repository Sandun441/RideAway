import 'package:flutter/material.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Ride History"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Filter
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: "All Rides",
                        items: const [
                          DropdownMenuItem(
                              value: "All Rides", child: Text("All Rides")),
                          DropdownMenuItem(
                              value: "Safe", child: Text("Safe")),
                          DropdownMenuItem(
                              value: "Alert", child: Text("Alert")),
                          DropdownMenuItem(
                              value: "Incident", child: Text("Incident")),
                        ],
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Monthly Summary
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "This Month Summary",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _SummaryStat(
                          value: "12",
                          label: "Total Rides",
                          color: Colors.blue),
                      _SummaryStat(
                          value: "156.3",
                          label: "km Traveled",
                          color: Colors.green),
                      _SummaryStat(
                          value: "1",
                          label: "Alert Sent",
                          color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Ride Cards
            _rideCard(
              title: "Downtown Park Trail",
              date: "Today • 2:15 PM",
              status: "Safe",
              statusColor: Colors.green,
              duration: "1h 23m",
              distance: "15.2 km",
              speed: "11.2 mph",
            ),

            _rideCard(
              title: "River Path",
              date: "Yesterday • 6:30 AM",
              status: "Alert",
              statusColor: Colors.orange,
              duration: "45m",
              distance: "8.7 km",
              speed: "11.6 mph",
              warning:
              "Potential incident detected but cancelled by user",
            ),

            _rideCard(
              title: "Mountain Trail Loop",
              date: "Sep 20 • 3:45 PM",
              status: "Safe",
              statusColor: Colors.green,
              duration: "2h 5m",
              distance: "23.1 km",
              speed: "11.1 mph",
            ),

            _rideCard(
              title: "City Commute",
              date: "Sep 19 • 7:15 AM",
              status: "Incident",
              statusColor: Colors.red,
              duration: "1h 12m",
              distance: "12.8 km",
              speed: "10.7 mph",
              warning:
              "Emergency alert was sent to your contacts at 7:41 PM",
            ),

            _rideCard(
              title: "Coastal Route",
              date: "Sep 18 • 5:20 PM",
              status: "Safe",
              statusColor: Colors.green,
              duration: "55m",
              distance: "9.3 km",
              speed: "10.1 mph",
            ),

            const SizedBox(height: 10),

            /// Load More
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Load More Rides"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Ride Card
  Widget _rideCard({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required String duration,
    required String distance,
    required String speed,
    String? warning,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(date,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
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
              _rideStat("Duration", duration),
              _rideStat("Distance", distance),
              _rideStat("Avg Speed", speed),
            ],
          ),

          if (warning != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                warning,
                style:
                const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rideStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Card
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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

/// Summary Stat
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
