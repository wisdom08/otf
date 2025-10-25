import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'presentation/pages/home/home_page.dart';

void main() {
  runApp(const OTFApp());
}

class OTFApp extends StatelessWidget {
  const OTFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'OTF',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
          home: const HomePage(),
        );
      },
    );
  }
}
