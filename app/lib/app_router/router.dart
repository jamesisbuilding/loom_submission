import 'package:go_router/go_router.dart';
import 'package:loom_test/app_router/app_routes.dart';

sealed class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.generator,
    routes: AppRoutes.routes,
  );
}
