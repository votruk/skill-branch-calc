import 'dart:io';

import 'package:calc_skill_branch/data/model/calculation.dart';
import 'package:calc_skill_branch/view/calc/calculations_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    final Directory docsDir = await getApplicationDocumentsDirectory();
    Hive.init(docsDir.path);
  }
  Hive.registerAdapter(CalculationAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalculationsPage(),
    );
  }
}
