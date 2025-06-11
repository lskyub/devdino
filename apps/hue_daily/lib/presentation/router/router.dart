import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/inspiration_list_screen.dart';

/// 앱의 라우팅을 관리하는 Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/inspirations',
        builder: (context, state) => const InspirationListScreen(),
      ),
      // TODO: 팔레트 관련 라우트 추가
      // GoRoute(
      //   path: '/palettes',
      //   builder: (context, state) => const HuePaletteListScreen(),
      // ),
      // GoRoute(
      //   path: '/create-palette',
      //   builder: (context, state) => const CreatePaletteScreen(),
      // ),
    ],
  );
}); 