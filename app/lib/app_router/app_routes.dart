
import 'package:flutter/material.dart';
import 'package:garment_generator/garment_generator.dart';
import 'package:go_router/go_router.dart';

sealed class AppRoutes {
  static const String generator = '/';

  static List<GoRoute> get routes => <GoRoute>[
        GoRoute(
          path: AppRoutes.generator,
          name: 'generator',
          pageBuilder: (BuildContext context, GoRouterState state) {
            return GarmentGeneratorFlow.page;
          },
        ),
      ];
}
