import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/habit.dart';
import '../bloc/habits_bloc.dart';

class CreateHabitPage extends StatefulWidget {
  final Habit? existing;
  const CreateHabitPage({super.key, this.existing});

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Color _color = AppColors.habitColors.first;
  IconData _icon = Icons.fitness_center;
  bool _reminderEnabled = true;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  static const List<IconData> _icons = [
    Icons.fitness_center,
    Icons.self_improvement,
    Icons.local_drink,
    Icons.book,
    Icons.directions_run,
    Icons.bed,
    Icons.restaurant,
    Icons.brush,
    Icons.code,
    Icons.music_note,
    Icons.spa,
    Icons.pets,
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _descController.text = e.description ?? '';
      _color = Color(e.colorValue);
      _icon = IconData(e.iconCodePoint, fontFamily: 'MaterialIcons');
      _reminderEnabled = e.reminderEnabled;
      _time = TimeOfDay(hour: e.reminderHour, minute: e.reminderMinute);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final existing = widget.existing;
    final habit = Habit(
      id: existing?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      // ignore: deprecated_member_use
      colorValue: _color.value,
      iconCodePoint: _icon.codePoint,
      reminderHour: _time.hour,
      reminderMinute: _time.minute,
      reminderEnabled: _reminderEnabled,
      createdAt: existing?.createdAt ?? DateTime.now(),
      completedDates: existing?.completedDates ?? const [],
    );
    if (existing == null) {
      context.read<HabitsBloc>().add(HabitCreated(habit));
    } else {
      context.read<HabitsBloc>().add(HabitUpdated(habit));
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Редактировать' : 'Новая привычка'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: _titleController,
                  label: 'Название',
                  prefixIcon: Icons.edit_outlined,
                  validator: Validators.habitTitle,
                  maxLength: 50,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: _descController,
                  label: 'Описание (необязательно)',
                  prefixIcon: Icons.notes_outlined,
                  maxLength: 200,
                ),
                const SizedBox(height: 16),
                _sectionTitle(context, 'Цвет'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppColors.habitColors.map((c) {
                    // ignore: deprecated_member_use
                    final selected = c.value == _color.value;
                    return GestureDetector(
                      onTap: () => setState(() => _color = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Иконка'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _icons.map((icon) {
                    final selected = icon.codePoint == _icon.codePoint;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = icon),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? _color.withOpacity(0.2)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? _color : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon,
                            color: selected ? _color : Colors.grey.shade700),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Напоминание'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _reminderEnabled,
                        onChanged: (v) =>
                            setState(() => _reminderEnabled = v),
                        title: const Text('Включить напоминание'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_reminderEnabled)
                        ListTile(
                          onTap: _pickTime,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.access_time),
                          title: const Text('Время'),
                          trailing: Text(
                            '${_time.hour.toString().padLeft(2, '0')}:'
                            '${_time.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: _color),
                  onPressed: _submit,
                  icon: const Icon(Icons.save),
                  label: Text(isEdit ? 'Сохранить' : 'Создать'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
