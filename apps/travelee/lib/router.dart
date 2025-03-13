import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/first_screen.dart';
import 'package:travelee/screen/input/destination_screen.dart';
import 'package:travelee/screen/input/date_screen.dart';
import 'package:travelee/screen/input/travel_detail_screen.dart';
import 'package:travelee/screen/input/schedule_detail_screen.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:travelee/screen/schedule_screen.dart';
import 'package:travelee/screen/write_screen.dart';

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
        GoRoute(
          name: TravelDetailScreen.routeName,
          path: TravelDetailScreen.routePath,
          builder: (context, state) => const TravelDetailScreen(),
        ),
        GoRoute(
          name: ScheduleDetailScreen.routeName,
          path: ScheduleDetailScreen.routePath,
          builder: (context, state) {
            final params = state.extra as List<dynamic>;
            return ScheduleDetailScreen(
              date: params[0] as DateTime,
              dayNumber: params[1] as int,
            );
          },
        ),
        GoRoute(
          name: LocationSearchScreen.routeName,
          path: LocationSearchScreen.routePath,
          builder: (context, state) {
            final initialLocation = state.extra as String;
            return LocationSearchScreen(
              initialLocation: initialLocation,
            );
          },
        ),
      ],
    );
  },
);
