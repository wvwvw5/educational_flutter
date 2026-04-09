import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final user = state.user;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: Text(
                          (user?.displayName?.isNotEmpty == true
                                  ? user!.displayName!
                                  : (user?.email ?? '?'))[0]
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Пользователь',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _tile(
                  context,
                  icon: Icons.lock_reset,
                  title: 'Сбросить пароль',
                  subtitle: 'Письмо придёт на ваш email',
                  onTap: () {
                    final email = user?.email;
                    if (email != null) {
                      context
                          .read<AuthBloc>()
                          .add(AuthResetPasswordRequested(email));
                    }
                  },
                ),
                _tile(
                  context,
                  icon: Icons.info_outline,
                  title: 'О приложении',
                  subtitle: 'MyHabits v1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'MyHabits',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.local_fire_department,
                        color: Colors.deepPurple,
                        size: 40,
                      ),
                      children: const [
                        Text('Трекер привычек с Firebase и Clean Architecture'),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                _tile(
                  context,
                  icon: Icons.logout,
                  title: 'Выйти',
                  color: Colors.red,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Выйти?'),
                        content: const Text(
                            'Вы действительно хотите выйти из аккаунта?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Выйти'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context
                          .read<AuthBloc>()
                          .add(const AuthSignOutRequested());
                    }
                  },
                ),
                _tile(
                  context,
                  icon: Icons.delete_forever,
                  title: 'Удалить аккаунт',
                  color: Colors.red,
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Удалить аккаунт?'),
                        content: const Text(
                            'Все данные будут безвозвратно удалены'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      context
                          .read<AuthBloc>()
                          .add(const AuthDeleteAccountRequested());
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
