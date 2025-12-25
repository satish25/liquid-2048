import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/liquid_glass_container.dart';
import '../providers/game_provider.dart';

/// Game control buttons (restart, undo)
class GameControls extends ConsumerWidget {
  const GameControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUndo = ref.watch(canUndoProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LiquidGlassIconButton(
          icon: Icons.undo_rounded,
          onPressed: canUndo 
              ? () => ref.read(gameProvider.notifier).undo()
              : null,
          color: LiquidColors.neonPurple,
          size: 52,
        ),
        const SizedBox(width: 20),
        LiquidGlassIconButton(
          icon: Icons.refresh_rounded,
          onPressed: () => _showRestartConfirmation(context, ref),
          color: LiquidColors.neonCyan,
          size: 52,
        ),
      ],
    );
  }

  void _showRestartConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidGlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Restart Game?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your current progress will be lost.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LiquidGlassButton(
                    onPressed: () => Navigator.of(context).pop(),
                    accentColor: LiquidColors.neonPink,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  LiquidGlassButton(
                    onPressed: () {
                      ref.read(gameProvider.notifier).restart();
                      Navigator.of(context).pop();
                    },
                    accentColor: LiquidColors.neonCyan,
                    child: const Text('Restart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

