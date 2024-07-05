import 'package:flutter/material.dart';
import 'package:flutter_bluetooth/bluetooth_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BluetoothScreen()),
              );
            },
            child: Text('Blutooth'),
          ),
        ),
      ),
    );
  }
}
