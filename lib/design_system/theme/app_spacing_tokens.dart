import 'dart:ui';
import 'package:golf_society/design_system/design_system.dart';

class AppSpacingTokens extends ThemeExtension<AppSpacingTokens> {
  final double labelToCard;
  final double cardToLabel;
  final double cardToCard;
  final double cardVerticalPadding;
  final double cardHorizontalPadding;

  const AppSpacingTokens({
    required this.labelToCard,
    required this.cardToLabel,
    required this.cardToCard,
    required this.cardVerticalPadding,
    required this.cardHorizontalPadding,
  });

  @override
  AppSpacingTokens copyWith({
    double? labelToCard,
    double? cardToLabel,
    double? cardToCard,
    double? cardVerticalPadding,
    double? cardHorizontalPadding,
  }) {
    return AppSpacingTokens(
      labelToCard: labelToCard ?? this.labelToCard,
      cardToLabel: cardToLabel ?? this.cardToLabel,
      cardToCard: cardToCard ?? this.cardToCard,
      cardVerticalPadding: cardVerticalPadding ?? this.cardVerticalPadding,
      cardHorizontalPadding: cardHorizontalPadding ?? this.cardHorizontalPadding,
    );
  }

  @override
  AppSpacingTokens lerp(ThemeExtension<AppSpacingTokens>? other, double t) {
    if (other is! AppSpacingTokens) return this;
    final otherTokens = other;
    
    return AppSpacingTokens(
      labelToCard: lerpDouble(labelToCard, otherTokens.labelToCard, t) ?? labelToCard,
      cardToLabel: lerpDouble(cardToLabel, otherTokens.cardToLabel, t) ?? cardToLabel,
      cardToCard: lerpDouble(cardToCard, otherTokens.cardToCard, t) ?? cardToCard,
      cardVerticalPadding: lerpDouble(cardVerticalPadding, otherTokens.cardVerticalPadding, t) ?? cardVerticalPadding,
      cardHorizontalPadding: lerpDouble(cardHorizontalPadding, otherTokens.cardHorizontalPadding, t) ?? cardHorizontalPadding,
    );
  }
}
