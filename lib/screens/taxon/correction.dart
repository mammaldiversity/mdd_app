import 'package:flutter/material.dart';
import 'package:mdd/services/app_services.dart';

const _kCorrectionRequest = 'Please send any edits, corrections, '
    'or unfilled data (including full citations) to ';

const _kMammalDiversityEmail = 'mammaldiversity@gmail.com';

class CorrectionRequest extends StatelessWidget {
  const CorrectionRequest({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: RichText(
        text: TextSpan(
          text: _kCorrectionRequest,
          style: Theme.of(context).textTheme.bodySmall,
          children: [
            WidgetSpan(
              child: InkWell(
                onTap: () {
                  launchURL('mailto:$_kMammalDiversityEmail');
                },
                child: Text(
                  _kMammalDiversityEmail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
