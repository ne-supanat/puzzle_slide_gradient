import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'layout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gradient Slide Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const ResponsiveLayout());
  }
}
