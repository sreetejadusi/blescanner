import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

class DeviceControl extends StatelessWidget {
  const DeviceControl(
      {super.key,
      required this.name,
      required this.macAddress,
      required this.toConnectDevice});
  final String? name;
  final String? macAddress;
  final Device toConnectDevice;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name ?? 'Device Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Device Name: $name'),
            Text('MAC Address: $macAddress'),
            ElevatedButton(
              onPressed: () {
                // Add your connection logic here
                toConnectDevice.connect();
                Timer.periodic(Duration(seconds: 1), (timer) {
                  print(toConnectDevice.state);
                });
              },
              child: const Text('Connect'),
            ),
          ],
        ),
      ),
    );
  }
}
