import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mix/mix.dart';
import 'package:design_systems/dino/foundations/theme.dart';
import 'package:travelee/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:country_picker/country_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:travelee/core/config/supabase_config.dart';
import 'package:travelee/core/config/firebase_config.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // 광고 초기화
  await MobileAds.instance.initialize();
  
  // 수파베이스 초기화
  await SupabaseConfig.initialize();
  
  // Firebase 초기화
  await FirebaseConfig.initialize();
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 3), () {
      FlutterNativeSplash.remove();
    });
    return MixTheme(
      data: dinoTheme,
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: ref.read(routerProvider),
        builder: (context, child) => child!,
      ),
    );
  }
}
