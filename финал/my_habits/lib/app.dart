import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/verify_email_page.dart';
import 'features/habits/presentation/bloc/habits_bloc.dart';
import 'features/habits/presentation/pages/home_page.dart';

class MyHabitsApp extends StatelessWidget {
  const MyHabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
        ),
        BlocProvider<HabitsBloc>(
          create: (_) => getIt<HabitsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'MyHabits',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        home: const _AuthGate(),
        builder: (context, child) {
          // Global error widget — prevents red screen crashes in production.
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Material(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Что-то пошло не так',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Попробуйте перезапустить экран',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        final habitsBloc = context.read<HabitsBloc>();
        if (state.status == AuthStatus.authenticated && state.user != null) {
          habitsBloc.add(HabitsSubscriptionRequested(state.user!.id));
        } else if (state.status == AuthStatus.unauthenticated) {
          habitsBloc.add(const HabitsCleared());
        }
      },
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const SplashPage();
          case AuthStatus.unauthenticated:
            return const LoginPage();
          case AuthStatus.authenticatedUnverified:
            return const VerifyEmailPage();
          case AuthStatus.authenticated:
            return const HomePage();
        }
      },
    );
  }
}
