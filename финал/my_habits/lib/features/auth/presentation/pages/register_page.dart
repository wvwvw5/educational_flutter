import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(AuthSignUpRequested(
            email: _emailController.text,
            password: _passwordController.text,
            displayName: _nameController.text.trim(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Создайте аккаунт',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'На указанный email придёт письмо для подтверждения',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _nameController,
                        label: 'Имя',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => Validators.notEmpty(v, field: 'Имя'),
                        maxLength: 30,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _emailController,
                        label: 'Email',
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
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmController,
                        label: 'Подтвердите пароль',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        validator: (v) => Validators.confirmPassword(
                            v, _passwordController.text),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: state.isLoading ? null : _submit,
                        child: const Text('Зарегистрироваться'),
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
