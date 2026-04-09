import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignInRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
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
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 80,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'С возвращением!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Войдите, чтобы продолжить отслеживать привычки',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 32),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'your@email.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Пароль',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscure,
                            validator: Validators.password,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => const ForgotPasswordPage(),
                                ));
                              },
                              child: const Text('Забыли пароль?'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: state.isLoading ? null : _submit,
                            child: const Text('Войти'),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Нет аккаунта? '),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage()),
                                  );
                                },
                                child: const Text('Зарегистрироваться'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
