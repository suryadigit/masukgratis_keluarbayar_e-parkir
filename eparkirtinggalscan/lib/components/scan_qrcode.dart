// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ParkingApp extends StatefulWidget {
  const ParkingApp({super.key});

  @override
  _ParkingAppState createState() => _ParkingAppState();
}

class _ParkingAppState extends State<ParkingApp> {
  CameraController? cameraController;
  bool isScanning = false;
  String? plateNumber;
  DateTime? entryTime;
  DateTime? exitTime;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras.first, ResolutionPreset.high);
    await cameraController?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  Future<void> scanPlate() async {
    if (cameraController == null ||
        !cameraController!.value.isInitialized ||
        isScanning) {
      return;
    }
    setState(() {
      isScanning = true;
    });

    final image = await cameraController!.takePicture();
    final imagePath = image.path;

    final plate = await recognizePlate(imagePath);

    if (plate != null) {
      setState(() {
        plateNumber = plate;
        if (entryTime == null) {
          entryTime = DateTime.now();
        } else {
          exitTime = DateTime.now();
        }
      });
    }

    setState(() {
      isScanning = false;
    });
  }

  Future<String?> recognizePlate(String imagePath) async {
    final apiKey = 'YOUR_API_KEY'; // Ganti dengan API key kamu
    final url = Uri.parse(
        'https://api.openalpr.com/v3/recognize_bytes?recognize_vehicle=1&country=us&secret_key=$apiKey');

    final bytes = File(imagePath).readAsBytesSync();
    final response = await http.post(url, body: bytes);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data['results'][0]['plate'];
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parking App'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: <Widget>[
          if (cameraController != null && cameraController!.value.isInitialized)
            Expanded(
              flex: 5,
              child: CameraPreview(cameraController!),
            ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (plateNumber != null) ...[
                    Text('Plate Number: $plateNumber'),
                    if (entryTime != null)
                      Text(
                          'Entry Time: ${entryTime!.toLocal().toString().split(' ')[1]}'),
                    if (exitTime != null)
                      Text(
                          'Exit Time: ${exitTime!.toLocal().toString().split(' ')[1]}'),
                  ],
                  ElevatedButton(
                    onPressed: scanPlate,
                    child: Text(isScanning ? 'Scanning...' : 'Scan Plate'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
