import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/firstscreen.dart';
import 'package:travelee/screen/input/destinationscreen.dart';
import 'package:travelee/screen/input/datescreen.dart';
import 'package:travelee/screen/schedulescreen.dart';
import 'package:travelee/screen/writescreen.dart';

GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();
final routerProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: FirstScreen.routePath,
      debugLogDiagnostics: true,
      navigatorKey: mainNavigatorKey,
      observers: [],
      routes: [
        GoRoute(
          name: FirstScreen.routeName,
          path: FirstScreen.routePath,
          builder: (context, state) => const FirstScreen(),
        ),
        GoRoute(
          name: WriteScreen.routeName,
          path: WriteScreen.routePath,
          builder: (context, state) => const WriteScreen(),
        ),
        GoRoute(
          name: ScheduleScreen.routeName,
          path: ScheduleScreen.routePath,
          builder: (context, state) => const ScheduleScreen(),
        ),
        GoRoute(
          name: DestinationScreen.routeName,
          path: DestinationScreen.routePath,
          builder: (context, state) => const DestinationScreen(),
        ),
        GoRoute(
          name: DateScreen.routeName,
          path: DateScreen.routePath,
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const DateScreen(),
          ),
        ),
      ],
    );
  },
);
