import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good morning, Alex",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Stay safe on your ride",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.profile);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.primaryContainer,
                          child: Icon(
                            Icons.person,
                            size: 18,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// SAFETY STATUS
              _card(
                context,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Safety Status",
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        _statusChip("Inactive", colors),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: colors.primary.withOpacity(0.15),
                      child: Icon(
                        Icons.shield_outlined,
                        size: 38,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.accident);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start Monitoring"),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// LAST RIDE SUMMARY
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Last Ride Summary",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _SummaryItem(
                          icon: Icons.timer,
                          label: "Duration",
                          value: "1h 23m",
                        ),
                        _SummaryItem(
                          icon: Icons.location_on,
                          label: "Distance",
                          value: "15.2 km",
                        ),
                        _SummaryItem(
                          icon: Icons.favorite,
                          label: "Status",
                          value: "Safe",
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// QUICK ACTIONS
              _card(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Actions",
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _quickButton(
                          context,
                          icon: Icons.people_outline,
                          label: "Contacts",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.contacts);
                          },
                        ),
                        const SizedBox(width: 12),
                        _quickButton(
                          context,
                          icon: Icons.history,
                          label: "History",
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.history);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// EMERGENCY INFO
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Emergency: Press and hold the power button 3 times for immediate help.",
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// STATUS CHIP
  Widget _statusChip(String text, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// QUICK BUTTON
  Widget _quickButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// SUMMARY ITEM
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: colors.primary.withOpacity(0.15),
          child: Icon(icon, color: colors.primary),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style:
              theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
