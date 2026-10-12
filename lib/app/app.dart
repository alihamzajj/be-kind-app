import 'package:flutter/material.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class BeKindApp extends StatelessWidget {
  const BeKindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Be Kind',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
