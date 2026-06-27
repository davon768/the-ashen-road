import 'package:flutter/material.dart';
import 'colors.dart';

/// Core content panel. Left accent border + warm-to-dark horizontal gradient.
class ParchmentPanel extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const ParchmentPanel({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(14),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AshenColors.inkRed;
    return Container(
      margin: margin,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AshenColors.parchmentWarm, AshenColors.surface],
          stops: [0.0, 0.3],
        ),
        border: Border(
          left:   BorderSide(color: accent, width: 3),
          top:    const BorderSide(color: AshenColors.border, width: 0.5),
          right:  const BorderSide(color: AshenColors.border, width: 0.5),
          bottom: const BorderSide(color: AshenColors.border, width: 0.5),
        ),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Fading sepia ink rule. Replaces plain Divider in the parchment theme.
class InkRule extends StatelessWidget {
  final double verticalPadding;
  const InkRule({super.key, this.verticalPadding = 12});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: 0.5,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AshenColors.sepiaLine, Colors.transparent],
          ),
        ),
      ),
    );
  }
}

/// Section heading with a short fading copper underline.
class SectionHeading extends StatelessWidget {
  final String text;
  const SectionHeading(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text, style: AshenText.heading),
        const SizedBox(height: 4),
        Container(
          height: 1,
          width: 72,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AshenColors.copper, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
