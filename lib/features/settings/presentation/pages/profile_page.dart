import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../injection_container.dart';
import '../../../vocabulary/presentation/providers/vocabulary_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final streakAsync = ref.watch(streakProvider);
    final totalLearnedAsync = ref.watch(totalLearnedCountProvider);
    final totalSaved = ref.watch(totalSavedCountProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset('assets/logo/bp_logo.png'),
          ),
        ),
        title: const Text(AppStrings.profilePageTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        children: [
          // ── Stats row ────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: streakAsync.when(
                  data: (s) => _StatCard(
                    label: 'Streak',
                    value: '${s.current}',
                    suffix: s.current == 1 ? 'day' : 'days',
                    emoji: '🔥',
                    color: const Color(0xFFEB5757),
                  ),
                  loading: () => const _StatCardSkeleton(),
                  error: (_, __) => const _StatCard(
                      label: 'Streak',
                      value: '0',
                      suffix: 'days',
                      emoji: '🔥',
                      color: Color(0xFFEB5757)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: totalLearnedAsync.when(
                  data: (c) => _StatCard(
                    label: 'Learned',
                    value: '$c',
                    suffix: 'words',
                    emoji: '📖',
                    color: const Color(0xFF2F80ED),
                  ),
                  loading: () => const _StatCardSkeleton(),
                  error: (_, __) => const _StatCard(
                      label: 'Learned',
                      value: '0',
                      suffix: 'words',
                      emoji: '📖',
                      color: Color(0xFF2F80ED)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Saved',
                  value: '$totalSaved',
                  suffix: 'words',
                  emoji: '🔖',
                  color: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Settings section ──────────────────────────────────────────
          _SectionLabel('Learning Settings'),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.bar_chart,
            label: AppStrings.difficultyLevelLabel,
            value: settings.difficulty[0].toUpperCase() +
                settings.difficulty.substring(1),
            onTap: () => _showDifficultyPicker(context, ref, settings.difficulty),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.flag,
            label: AppStrings.dailyGoalLabel,
            value: '${settings.dailyGoal} words',
            onTap: () => _showGoalPicker(context, ref, settings.dailyGoal),
          ),

          const SizedBox(height: 24),
          _SectionLabel('Notifications'),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.notifications,
            label: AppStrings.reminderLabel,
            value: settings.reminderEnabled ? 'On' : 'Off',
            onTap: () => _showReminderPicker(context, ref, settings),
          ),
          if (settings.reminderEnabled) ...[
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.access_time,
              label: AppStrings.reminderTimeLabel,
              value: _formatTime(settings.reminderHour, settings.reminderMinute),
              onTap: () => _showTimePicker(context, ref, settings),
            ),
          ],

          const SizedBox(height: 24),
          _SectionLabel('App Info'),
          const SizedBox(height: 12),

          _SettingsTile(
            icon: Icons.info_outline,
            label: AppStrings.appVersionLabel,
            value: AppConstants.appVersion,
            showArrow: false,
          ),

          const SizedBox(height: 28),

          // ── Reset ─────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEB5757).withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: const Color(0xFFEB5757).withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const Icon(Icons.restart_alt,
                  color: Color(0xFFEB5757)),
              title: const Text(
                AppStrings.resetProgressLabel,
                style: TextStyle(
                  color: Color(0xFFEB5757),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _confirmReset(context, ref),
            ),
          ),

          const SizedBox(height: 20),

          // Banner Ad placeholder
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5F2),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('Ad',
                style: TextStyle(color: Color(0xFFCCC8C0), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ─── Pickers ──────────────────────────────────────────────────────────────

  void _showDifficultyPicker(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Difficulty Level',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222))),
            const SizedBox(height: 20),
            ...['easy', 'medium', 'hard'].map((d) => ListTile(
                  leading: Icon(
                    d == current ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: const Color(0xFF2F80ED),
                  ),
                  title: Text(
                    d[0].toUpperCase() + d.substring(1),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222)),
                  ),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setDifficulty(d);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Goal',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222))),
            const SizedBox(height: 20),
            ...AppConstants.dailyGoalOptions.map((g) => ListTile(
                  leading: Icon(
                    g == current ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: const Color(0xFF2F80ED),
                  ),
                  title: Text('$g words',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222))),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setDailyGoal(g);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showReminderPicker(
      BuildContext context, WidgetRef ref, SettingsState settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Reminder',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222222))),
            const SizedBox(height: 20),
            ...[true, false].map((v) => ListTile(
                  leading: Icon(
                    v == settings.reminderEnabled
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: const Color(0xFF2F80ED),
                  ),
                  title: Text(v ? 'On' : 'Off',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222222))),
                  onTap: () {
                    ref.read(settingsProvider.notifier).setReminder(
                          v,
                          settings.reminderHour,
                          settings.reminderMinute,
                        );
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _showTimePicker(
      BuildContext context, WidgetRef ref, SettingsState settings) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: settings.reminderHour, minute: settings.reminderMinute),
    );
    if (picked != null) {
      ref.read(settingsProvider.notifier).setReminder(
            settings.reminderEnabled,
            picked.hour,
            picked.minute,
          );
    }
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.resetConfirmTitle),
        content: const Text(AppStrings.resetConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.btnCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(vocabularyRepositoryProvider);
              await repo.resetProgress();
              final streakRepo = ref.read(streakRepositoryProvider);
              await streakRepo.resetStreak();
              ref.invalidate(wordQueueProvider);
              ref.invalidate(todayProgressProvider);
              ref.invalidate(savedWordsProvider);
              ref.invalidate(streakProvider);
              ref.invalidate(totalLearnedCountProvider);
            },
            child: const Text(
              AppStrings.btnReset,
              style: TextStyle(color: Color(0xFFEB5757)),
            ),
          ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Color(0xFF666666),
        letterSpacing: 0.8,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.suffix,
    required this.emoji,
    required this.color,
  });
  final String label, value, suffix, emoji;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(suffix,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE7E2DA),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.showArrow = true,
  });
  final IconData icon;
  final String label, value;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7E2DA)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2F80ED)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: Color(0xFF222222))),
            ),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF666666))),
            if (showArrow) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  color: Color(0xFF666666), size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
