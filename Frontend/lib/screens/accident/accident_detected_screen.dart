import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AccidentDetectedScreen extends StatelessWidget {
  const AccidentDetectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              "Accident Detected!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, AppRoutes.alertSent);
              },
              child: const Text("Send Alert"),
            ),
          ],
        ),
      ),
    );
  }
}
