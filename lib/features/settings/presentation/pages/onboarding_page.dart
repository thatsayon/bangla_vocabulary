import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../injection_container.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _controller = PageController();
  int _currentStep = 0;

  // Local state
  String _difficulty = AppConstants.difficultyMedium;
  int _dailyGoal = 10;
  int? _customGoal;
  bool _reminderEnabled = false;
  int _reminderHour = 8;
  int _reminderMinute = 0;

  final _customGoalController = TextEditingController();

  void _next() {
    if (_currentStep < 4) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final storage = ref.read(storageServiceProvider);
    await storage.setDifficultyLevel(_difficulty);
    await storage.setDailyGoal(_dailyGoal);
    await storage.setReminderEnabled(_reminderEnabled);
    await storage.setReminderHour(_reminderHour);
    await storage.setReminderMinute(_reminderMinute);
    await storage.setOnboardingCompleted(true);

    if (_reminderEnabled) {
      final notif = ref.read(notificationServiceProvider);
      await notif.scheduleDaily(_reminderHour, _reminderMinute);
    }

    if (mounted) {
      context.go('/learn');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _customGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _StepWelcome(onNext: _next),
                  _StepDifficulty(
                    selected: _difficulty,
                    onSelect: (d) => setState(() => _difficulty = d),
                    onNext: _next,
                  ),
                  _StepDailyGoal(
                    selected: _dailyGoal,
                    customController: _customGoalController,
                    onSelect: (g) => setState(() => _dailyGoal = g),
                    onNext: _next,
                  ),
                  _StepReminder(
                    enabled: _reminderEnabled,
                    hour: _reminderHour,
                    minute: _reminderMinute,
                    onToggle: (v) => setState(() => _reminderEnabled = v),
                    onTimeChanged: (h, m) => setState(() {
                      _reminderHour = h;
                      _reminderMinute = m;
                    }),
                    onNext: _next,
                  ),
                  _StepFinish(
                    difficulty: _difficulty,
                    dailyGoal: _dailyGoal,
                    reminderEnabled: _reminderEnabled,
                    reminderHour: _reminderHour,
                    reminderMinute: _reminderMinute,
                    onStart: _finish,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(5, (i) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: i <= _currentStep
                    ? const Color(0xFF2F80ED)
                    : const Color(0xFFE7E2DA),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Step 1: Welcome ──────────────────────────────────────────────────────────

class _StepWelcome extends StatelessWidget {
  const _StepWelcome({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF2F80ED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/logo/bp_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppStrings.onboardingWelcomeTitle,
            style: theme.textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.onboardingWelcomeDesc,
            style: theme.textTheme.bodyLarge,
          ),
          const Spacer(),
          AppButton(label: AppStrings.btnContinue, onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Step 2: Difficulty ────────────────────────────────────────────────────────

class _StepDifficulty extends StatelessWidget {
  const _StepDifficulty({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.onboardingDifficultyTitle,
              style: theme.textTheme.headlineLarge),
          const SizedBox(height: 32),
          _DifficultyCard(
            title: AppStrings.difficultyEasyTitle,
            desc: AppStrings.difficultyEasyDesc,
            icon: Icons.sentiment_very_satisfied,
            value: AppConstants.difficultyEasy,
            selected: selected,
            onTap: () => onSelect(AppConstants.difficultyEasy),
          ),
          const SizedBox(height: 12),
          _DifficultyCard(
            title: AppStrings.difficultyMediumTitle,
            desc: AppStrings.difficultyMediumDesc,
            icon: Icons.emoji_emotions,
            value: AppConstants.difficultyMedium,
            selected: selected,
            onTap: () => onSelect(AppConstants.difficultyMedium),
          ),
          const SizedBox(height: 12),
          _DifficultyCard(
            title: AppStrings.difficultyHardTitle,
            desc: AppStrings.difficultyHardDesc,
            icon: Icons.local_fire_department,
            value: AppConstants.difficultyHard,
            selected: selected,
            onTap: () => onSelect(AppConstants.difficultyHard),
          ),
          const Spacer(),
          AppButton(label: AppStrings.btnContinue, onPressed: onNext),
        ],
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final String title, desc, value;
  final IconData icon;
  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F80ED).withOpacity(0.06)
              : Colors.white,
          border: Border.all(
            color:
                isSelected ? const Color(0xFF2F80ED) : const Color(0xFFE7E2DA),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2F80ED).withOpacity(0.1)
                    : const Color(0xFFF7F5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? const Color(0xFF2F80ED)
                      : const Color(0xFF666666)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF222222))),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF666666))),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF2F80ED), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Step 3: Daily Goal ────────────────────────────────────────────────────────

class _StepDailyGoal extends StatefulWidget {
  const _StepDailyGoal({
    required this.selected,
    required this.customController,
    required this.onSelect,
    required this.onNext,
  });
  final int selected;
  final TextEditingController customController;
  final void Function(int) onSelect;
  final VoidCallback onNext;

  @override
  State<_StepDailyGoal> createState() => _StepDailyGoalState();
}

class _StepDailyGoalState extends State<_StepDailyGoal> {
  bool _showCustom = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.onboardingGoalTitle,
              style: theme.textTheme.headlineLarge),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ...AppConstants.dailyGoalOptions.map((g) => _GoalChip(
                    label: '$g words',
                    isSelected:
                        widget.selected == g && !_showCustom,
                    onTap: () {
                      setState(() => _showCustom = false);
                      widget.onSelect(g);
                    },
                  )),
              _GoalChip(
                label: 'Custom',
                isSelected: _showCustom,
                onTap: () => setState(() => _showCustom = true),
              ),
            ],
          ),
          if (_showCustom) ...[
            const SizedBox(height: 20),
            TextField(
              controller: widget.customController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter daily goal',
                hintText: 'e.g. 15',
                suffixText: 'words',
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null && parsed > 0) {
                  widget.onSelect(parsed);
                }
              },
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFF27AE60).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF27AE60), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Completing your daily goal keeps your streak alive! 🔥',
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF27AE60),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(label: AppStrings.btnContinue, onPressed: widget.onNext),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F80ED)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F80ED)
                : const Color(0xFFE7E2DA),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? Colors.white : const Color(0xFF222222),
          ),
        ),
      ),
    );
  }
}

// ─── Step 4: Reminder ─────────────────────────────────────────────────────────

class _StepReminder extends StatelessWidget {
  const _StepReminder({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.onToggle,
    required this.onTimeChanged,
    required this.onNext,
  });
  final bool enabled;
  final int hour, minute;
  final void Function(bool) onToggle;
  final void Function(int, int) onTimeChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.onboardingReminderTitle,
              style: theme.textTheme.headlineLarge),
          const SizedBox(height: 32),
          _ReminderOption(
            label: 'Yes, remind me daily',
            isSelected: enabled,
            onTap: () => onToggle(true),
          ),
          const SizedBox(height: 12),
          _ReminderOption(
            label: 'No, I\'ll open it myself',
            isSelected: !enabled,
            onTap: () => onToggle(false),
          ),
          if (enabled) ...[
            const SizedBox(height: 28),
            Text('Reminder Time', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: hour, minute: minute),
                );
                if (picked != null) {
                  onTimeChanged(picked.hour, picked.minute);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE7E2DA)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time,
                        color: Color(0xFF2F80ED)),
                    const SizedBox(width: 12),
                    Text(
                      _formatTime(hour, minute),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222)),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF666666)),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          AppButton(label: AppStrings.btnContinue, onPressed: onNext),
        ],
      ),
    );
  }

  String _formatTime(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayHour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }
}

class _ReminderOption extends StatelessWidget {
  const _ReminderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F80ED).withOpacity(0.06)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2F80ED)
                : const Color(0xFFE7E2DA),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isSelected
                        ? const Color(0xFF2F80ED)
                        : const Color(0xFF222222)),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF2F80ED), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Step 5: Finish ────────────────────────────────────────────────────────────

class _StepFinish extends StatelessWidget {
  const _StepFinish({
    required this.difficulty,
    required this.dailyGoal,
    required this.reminderEnabled,
    required this.reminderHour,
    required this.reminderMinute,
    required this.onStart,
  });
  final String difficulty;
  final int dailyGoal;
  final bool reminderEnabled;
  final int reminderHour, reminderMinute;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.check_circle,
                size: 38, color: Color(0xFF27AE60)),
          ),
          const SizedBox(height: 28),
          Text(AppStrings.onboardingFinishTitle,
              style: theme.textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(AppStrings.onboardingFinishDesc,
              style: theme.textTheme.bodyLarge),
          const SizedBox(height: 32),
          _SummaryRow(
            icon: Icons.bar_chart,
            label: 'Difficulty',
            value: difficulty[0].toUpperCase() + difficulty.substring(1),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.flag,
            label: 'Daily Goal',
            value: '$dailyGoal words',
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.notifications,
            label: 'Reminder',
            value: reminderEnabled
                ? _formatTime(reminderHour, reminderMinute)
                : 'Off',
          ),
          const Spacer(),
          AppButton(label: AppStrings.btnStartLearning, onPressed: onStart),
        ],
      ),
    );
  }

  String _formatTime(int h, int m) {
    final period = h < 12 ? 'AM' : 'PM';
    final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${displayHour.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E2DA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F80ED), size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                  fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF222222),
                  fontWeight: FontWeight.w700,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
