import 'package:flutter/material.dart';

class DoorLockHomePage extends StatefulWidget {
  final String deviceId;

  const DoorLockHomePage({super.key, required this.deviceId});

  @override
  State<DoorLockHomePage> createState() => _DoorLockHomePageState();
}

class _DoorLockHomePageState extends State<DoorLockHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceId),
      ),
      body: const Column(),
    );
  }
}
