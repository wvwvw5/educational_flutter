import 'package:flutter/material.dart';
import '../../domain/entities/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(habit.colorValue);
    final isDone = habit.isCompletedToday;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDone ? color : Colors.grey.shade200,
          width: isDone ? 1.5 : 1,
        ),
        boxShadow: [
          if (isDone)
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconData(habit.iconCodePoint,
                        fontFamily: 'MaterialIcons'),
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: isDone ? Colors.grey.shade600 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.local_fire_department_rounded,
                              size: 14, color: Colors.orange.shade700),
                          const SizedBox(width: 4),
                          Text(
                            '${habit.currentStreak} дн.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          if (habit.reminderEnabled) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.notifications_active_outlined,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 2),
                            Text(
                              '${habit.reminderHour.toString().padLeft(2, '0')}'
                              ':'
                              '${habit.reminderMinute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDone ? color : Colors.transparent,
                      border: Border.all(color: color, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: isDone
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
