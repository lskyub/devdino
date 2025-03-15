import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travelee/screen/first_screen.dart';
import 'package:travelee/screen/input/destination_screen.dart';
import 'package:travelee/screen/input/date_screen.dart';
import 'package:travelee/screen/travel_detail_screen.dart';
import 'package:travelee/screen/input/schedule_detail_screen.dart';
import 'package:travelee/screen/input/location_search_screen.dart';
import 'package:travelee/screen/saved_travels_screen.dart';

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
          path: TravelDetailScreen.routePath,
          builder: (context, state) {
            final travelId = state.pathParameters['id'] ?? '';
            return TravelDetailScreen(travelId: travelId);
          },
        ),
        GoRoute(
          name: ScheduleDetailScreen.routeName,
          path: ScheduleDetailScreen.routePath,
          builder: (context, state) {
            final Map<String, dynamic> extraData = state.extra as Map<String, dynamic>;
            final date = extraData['date'] as DateTime;
            final dayNumber = extraData['dayNumber'] as int;
            
            return ScheduleDetailScreen(
              date: date,
              dayNumber: dayNumber,
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
        GoRoute(
          name: SavedTravelsScreen.routeName,
          path: SavedTravelsScreen.routePath,
          builder: (context, state) => const SavedTravelsScreen(),
        ),
      ],
    );
  },
);
