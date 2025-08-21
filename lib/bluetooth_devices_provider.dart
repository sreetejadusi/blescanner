import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothDevicesProvider with ChangeNotifier {
  bool _scanning = false;
  bool get scanning => _scanning;

  SharedPreferences? _prefs;
  SharedPreferences? get prefs => _prefs;

  BluetoothDevice? _connectedDevice;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  String _deviceName = '';
  String get deviceName => _deviceName;

  StreamSubscription<List<ScanResult>>? _scanSubscription;

  List<ScanResult> _scanResultList = [];
  List<ScanResult> get scanResultList => _scanResultList;

  Future<void> scan(BuildContext context) async {
    try {
      if (_scanning) return;
      print('\t\t\t\t\t\t\t\t\t\t\n\n\nCALLED SCAN\n\n\n');
      _scanning = true;
      notifyListeners();
      _scanResultList = [];

      final savedDevice = prefs?.getString('device') ?? 'ROVE';

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.onScanResults.listen((results) {
        if (results.isNotEmpty) {
          for (var result in results) {
            // Avoid duplicates
            if (!_scanResultList
                .any((e) => e.device.remoteId == result.device.remoteId)) {
              _scanResultList.insert(0, result);
              print(_scanResultList
                  .map((e) => e.advertisementData.advName)
                  .toList());
              notifyListeners();
            }

            if (result.advertisementData.advName == savedDevice) {
              connectDevice(result);
            }
          }
        }
      });

      await FlutterBluePlus.startScan(
        withNames: [],
        timeout: Duration(seconds: 7),
      ).then((value){
         _scanning = false;
        notifyListeners();
      });
    } catch (e) {
      _scanning = false;
      scan(context);
      notifyListeners();
      print('Scan failed: $e');
    }
  }

  void disconnectDevice() {
    _connectedDevice?.disconnect();
    notifyListeners();
  }

  Future<void> connectDevice(ScanResult result) async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice?.disconnect();
      }

      _connectedDevice = result.device;
      await _connectedDevice?.connect();
      _deviceName = result.advertisementData.advName ?? 'Undefined';

      _scanResultList.removeWhere(
          (element) => element.device.remoteId == result.device.remoteId);

      notifyListeners();
    } catch (e) {
      print('Connection failed: $e');
    }
  }

  Future<void> reconnectDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice?.connect();
    }
    notifyListeners();
  }

  void changeConnectedDevice(BluetoothDevice device, String name) {
    _connectedDevice = device;
    _deviceName = name;
    notifyListeners();
  }

  void setPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }
}
