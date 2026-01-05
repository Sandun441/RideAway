import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      "Detect accidents using phone sensors",
      "Automatic emergency alerts with location",
      "Control contacts & sensitivity",
    ];

    return Scaffold(
      body: PageView.builder(
        itemCount: pages.length,
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 100, color: Colors.blue),
                const SizedBox(height: 30),
                Text(
                  pages[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),
                if (index == 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      },
                      child: const Text("Get Started"),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
