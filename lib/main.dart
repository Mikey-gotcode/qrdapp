import 'package:flutter/material.dart';
import 'package:qrdapp/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
   // ensure everything is ready
  WidgetsFlutterBinding.ensureInitialized();

   await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}
