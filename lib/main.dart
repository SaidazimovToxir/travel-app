import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lesson72/services/firebase_options.dart';
import 'package:lesson72/views/screens/homepage.dart';
import 'package:permission_handler/permission_handler.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PermissionStatus cameraPermission = await Permission.camera.status;
  PermissionStatus locationPermission = await Permission.location.status;

  if (cameraPermission != PermissionStatus.granted) {
    cameraPermission = await Permission.camera.request();
  }

  if (locationPermission != PermissionStatus.granted) {
    locationPermission = await Permission.location.request();
  }

  if (!(await Permission.camera.request().isGranted) ||
      !(await Permission.location.request().isGranted)) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
    ].request();

    print(statuses);
  }

  runApp(const MainRunner());
}

class MainRunner extends StatelessWidget {
  const MainRunner({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Homepage(),
    );
  }
}
