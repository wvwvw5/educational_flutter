import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../bloc/auth_bloc.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Auto-check verification every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<AuthBloc>().add(const AuthRefreshRequested());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage ||
            p.infoMessage != c.infoMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ));
          } else if (state.infoMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.infoMessage!)));
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.mark_email_read_outlined,
                        size: 96, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    Text(
                      'Подтвердите email',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'На адрес ${state.user?.email ?? ''} отправлено '
                      'письмо со ссылкой для подтверждения. Откройте письмо '
                      'и перейдите по ссылке.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(const AuthRefreshRequested()),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Я подтвердил email'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: state.isLoading
                          ? null
                          : () => context
                              .read<AuthBloc>()
                              .add(const AuthResendVerificationRequested()),
                      icon: const Icon(Icons.send_outlined),
                      label: const Text('Отправить письмо повторно'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested()),
                      icon: const Icon(Icons.logout),
                      label: const Text('Выйти'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
