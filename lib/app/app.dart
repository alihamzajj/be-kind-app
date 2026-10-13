import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/settings/app_settings.dart';
import 'router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class BeKindApp extends ConsumerStatefulWidget {
  const BeKindApp({super.key});

  @override
  ConsumerState<BeKindApp> createState() => _BeKindAppState();
}

class _BeKindAppState extends ConsumerState<BeKindApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Follow the phone's light/dark switch when the theme is "Automatic".
  @override
  void didChangePlatformBrightness() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final platform =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final dark =
        mode == ThemeMode.dark ||
        (mode == ThemeMode.system && platform == Brightness.dark);
    AppColors.use(dark ? AppPalette.dark : AppPalette.light);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: AppColors.surface,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
      ),
      // Colours are read when widgets build, so rebuild the whole tree
      // (the router keeps the current screen) when the palette flips.
      child: MaterialApp.router(
        key: ValueKey(dark),
        title: 'Be Kind',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
