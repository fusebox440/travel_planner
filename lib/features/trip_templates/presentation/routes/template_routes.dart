import 'package:go_router/go_router.dart';
import '../screens/template_gallery_screen.dart';
import '../screens/template_detail_screen.dart';
import '../screens/create_template_screen.dart';

final tripTemplateRoutes = [
  GoRoute(
    path: '/templates',
    builder: (context, state) => const TemplateGalleryScreen(),
  ),
  GoRoute(
    path: '/templates/detail',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      final templateId = args?['templateId'] as String? ?? '';
      return TemplateDetailScreen(templateId: templateId);
    },
  ),
  GoRoute(
    path: '/templates/create',
    builder: (context, state) {
      final args = state.extra as Map<String, dynamic>?;
      final fromTripId = args?['fromTripId'] as String?;
      return CreateTemplateScreen(fromTripId: fromTripId);
    },
  ),
];
