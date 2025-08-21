import 'dart:async';
import 'package:connectiondebug/bluetooth_devices_provider.dart';
import 'package:connectiondebug/bluetooth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  @override
  void initState() {
    final bluetoothDevicesProvider = context.read<BluetoothDevicesProvider>();

    Timer.periodic(Duration(seconds: 15), (timer) {
      bluetoothDevicesProvider.scan(context);
    });

    Timer.periodic(Duration(seconds: 10), (timer) async {
      if (bluetoothDevicesProvider.connectedDevice == null ||
          !(await bluetoothDevicesProvider.connectedDevice?.isConnected ??
              false)) {
        bluetoothDevicesProvider.reconnectDevice();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = context.watch<BluetoothProvider>();
    final bluetoothDevicesProvider = context.watch<BluetoothDevicesProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Devices'),
        actions: [
          TextButton.icon(
            label: Text(
              bluetoothDevicesProvider.prefs?.getString('device') ?? 'ROVE',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => _showDeviceNameDialog(context),
            icon: const Icon(Icons.edit, size: 16),
          ),
          Icon(
            bluetoothProvider.bluetoothPermission
                ? Icons.bluetooth
                : Icons.bluetooth_disabled,
            color: !bluetoothProvider.bluetoothPermission
                ? Colors.black
                : bluetoothProvider.bluetoothOn
                    ? Colors.green
                    : Colors.red,
          ),
          // SizedBox(width: 10),
          // Icon(
          //   bluetoothProvider.gpsPermission
          //       ? Icons.location_on
          //       : Icons.location_off,
          //   color: !bluetoothProvider.gpsPermission
          //       ? Colors.black
          //       : bluetoothProvider.gpsOn
          //           ? Colors.green
          //           : Colors.red,
          // ),
          SizedBox(width: 10),
        ],
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor:
            bluetoothDevicesProvider.scanning ? Colors.green : Colors.brown,
        onPressed: () => bluetoothDevicesProvider.scan(context),
        label: Text(
          bluetoothDevicesProvider.scanning ? 'Scanning...' : 'Scan',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bluetoothDevicesProvider.connectedDevice != null) ...[
              const Text(
                'Connected Device',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              StreamBuilder<BluetoothConnectionState>(
                stream:
                    bluetoothDevicesProvider.connectedDevice?.connectionState,
                initialData: BluetoothConnectionState.disconnected,
                builder: (context, snapshot) {
                  final state =
                      snapshot.data ?? BluetoothConnectionState.disconnected;
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(bluetoothDevicesProvider.deviceName),
                    subtitle:
                        Text(state.toString().split('.').last.toUpperCase()),
                    trailing: TextButton(
                      onPressed: () {
                        if (state == BluetoothConnectionState.connected) {
                          bluetoothDevicesProvider.disconnectDevice();
                        } else {
                          bluetoothDevicesProvider.reconnectDevice();
                        }
                      },
                      child: Text(
                        state == BluetoothConnectionState.connected
                            ? 'Disconnect'
                            : 'Connect',
                      ),
                    ),
                  );
                },
              ),
            ],
            const Text('Available Devices',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                )),
            Expanded(
              child: ListView.separated(
                itemCount: bluetoothDevicesProvider.scanResultList.length,
                itemBuilder: (context, index) {
                  final result = bluetoothDevicesProvider.scanResultList[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(result.advertisementData.advName.isEmpty
                        ? 'Undefined'
                        : result.advertisementData.advName),
                    subtitle: Text(result.device.remoteId.toString()),
                  );
                },
                separatorBuilder: (context, index) =>
                    const Divider(height: 1, color: Colors.black12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceNameDialog(BuildContext context) {
    final bluetoothDevicesProvider = context.read<BluetoothDevicesProvider>();
    final controller = TextEditingController(
      text: bluetoothDevicesProvider.prefs?.getString('device') ?? 'ROVE',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Default Device'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter Device Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              bluetoothDevicesProvider.prefs?.setString(
                'device',
                controller.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
