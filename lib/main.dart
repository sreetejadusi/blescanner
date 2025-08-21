import 'package:connectiondebug/bluetooth_provider.dart';
import 'package:connectiondebug/bluetooth_devices_provider.dart';
import 'package:connectiondebug/devices_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BluetoothProvider()),
        ChangeNotifierProvider(create: (_) => BluetoothDevicesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetoothDevicesProvider = context.read<BluetoothDevicesProvider>();
    final bluetoothProvider = context.read<BluetoothProvider>();
    bluetoothProvider.check(context);
    SharedPreferences.getInstance().then((prefs) {
      bluetoothDevicesProvider.setPreferences(prefs);
      if (prefs.getString('device') == null) {
        prefs.setString('device', 'ROVE');
      }
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Connect',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DevicesScreen(),
    );
  }
}
