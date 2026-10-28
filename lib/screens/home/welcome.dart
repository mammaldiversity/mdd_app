import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdd/services/providers/settings.dart';

const String _welcomeText =
    'A comprehensive, constantly updated resource for '
    'the classification and nomenclature of living and recently extinct '
    '(i.e., since ~1500 CE) species and higher taxa of mammals.';

/// The welcome blurb shown under the hero title, with an inline "Hide"
/// link. Follows the "Show Welcome Text" setting, which can bring it back.
class HeroWelcomeText extends ConsumerWidget {
  const HeroWelcomeText({super.key, this.topSpacing = 16});

  /// Gap between the hero title and the text, only applied when shown.
  final double topSpacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stay hidden while the setting loads so the hero doesn't flash a
    // spinner; the text slides in once the preference is known.
    final bool showWelcome = ref.watch(showWelcomeTextProvider).value ?? false;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: !showWelcome
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: EdgeInsets.only(top: topSpacing),
              child: Text.rich(
                TextSpan(
                  text: '$_welcomeText ',
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _HideLink(
                        onTap: () => ref
                            .read(showWelcomeTextProvider.notifier)
                            .toggle(false),
                      ),
                    ),
                  ],
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
    );
  }
}

class _HideLink extends StatelessWidget {
  const _HideLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: 'Hide welcome text. Turn it back on in Settings.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hide',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.close, size: 14, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
