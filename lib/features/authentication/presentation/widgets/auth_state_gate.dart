import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../widgets/common/loading_screen.dart';
import '../../domain/auth_constants.dart';

/// Widget that controls navigation based on authentication state
class AuthStateGate extends ConsumerWidget {
  final Widget child;
  final bool requireAuth;

  const AuthStateGate({
    super.key,
    required this.child,
    this.requireAuth = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) => _handleAuthState(context, ref, authState),
      loading: () => const LoadingScreen(message: 'Checking authentication...'),
      error: (error, stack) => _buildErrorScreen(context, error.toString()),
    );
  }

  Widget _handleAuthState(
      BuildContext context, WidgetRef ref, AuthState authState) {
    switch (authState) {
      case AuthStateLoading():
        return const LoadingScreen(message: 'Loading...');

      case AuthStateAuthenticated():
        // User is authenticated, check if profile is complete for new users
        return ref.watch(userProfileProvider(authState.user.uid)).when(
              data: (profile) {
                if (profile != null && !profile.isProfileComplete) {
                  // Profile incomplete, redirect to profile setup
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted &&
                        GoRouterState.of(context).matchedLocation !=
                            AuthConstants.profileSetupRoute) {
                      context.go(AuthConstants.profileSetupRoute);
                    }
                  });
                  return child;
                }

                // Profile complete or no profile data, show requested content
                return child;
              },
              loading: () => const LoadingScreen(message: 'Loading profile...'),
              error: (error, stack) =>
                  child, // Show content even if profile loading fails
            );

      case AuthStateUnauthenticated():
        if (requireAuth) {
          // Authentication required but user is not authenticated
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted &&
                GoRouterState.of(context).matchedLocation !=
                    AuthConstants.authEntryRoute) {
              context.go(AuthConstants.authEntryRoute);
            }
          });
        }
        return child;

      case AuthStateError():
        return _buildErrorScreen(context, authState.message);
    }
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AuthConstants.homeRoute),
                child: const Text('Continue to App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Convenience widget for pages that require authentication
class AuthenticatedPage extends ConsumerWidget {
  final Widget child;

  const AuthenticatedPage({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthStateGate(
      requireAuth: true,
      child: child,
    );
  }
}

/// Widget to show current authentication status for debugging
class AuthStatusDebugWidget extends ConsumerWidget {
  const AuthStatusDebugWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        String status;
        Color color;

        switch (state) {
          case AuthStateLoading():
            status = 'Loading...';
            color = Colors.orange;
            break;
          case AuthStateAuthenticated():
            final user = state.user;
            status =
                'Authenticated: ${user.phoneNumber ?? user.email ?? user.uid}';
            color = Colors.green;
            break;
          case AuthStateUnauthenticated():
            status = 'Not authenticated';
            color = Colors.grey;
            break;
          case AuthStateError():
            status = 'Error: ${state.message}';
            color = Colors.red;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: color),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange),
        ),
        child: const Text(
          'Auth Loading...',
          style: TextStyle(
            color: Colors.orange,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          'Auth Error: $error',
          style: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
