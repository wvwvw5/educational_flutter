import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context
          .read<AuthBloc>()
          .add(AuthResetPasswordRequested(_emailController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сброс пароля')),
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
              ..showSnackBar(SnackBar(
                content: Text(state.infoMessage!),
                backgroundColor: Colors.green.shade700,
              ));
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.of(context).pop();
            });
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state.isLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      const Icon(Icons.lock_reset_rounded,
                          size: 72, color: Colors.deepPurple),
                      const SizedBox(height: 16),
                      Text(
                        'Забыли пароль?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Укажите email — мы отправим ссылку для сброса пароля',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.isLoading ? null : _submit,
                        child: const Text('Отправить письмо'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
