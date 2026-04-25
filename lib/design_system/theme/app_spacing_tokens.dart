import 'dart:ui';
import 'package:golf_society/design_system/design_system.dart';

class AppSpacingTokens extends ThemeExtension<AppSpacingTokens> {
  final double labelToCard;
  final double cardToLabel;
  final double fieldToField;
  final double cardToCard;
  final double cardVerticalPadding;
  final double cardHorizontalPadding;
  final double tabToContent;
  final double groupFooterToLabel;

  const AppSpacingTokens({
    required this.labelToCard,
    required this.cardToLabel,
    required this.fieldToField,
    required this.cardToCard,
    required this.cardVerticalPadding,
    required this.cardHorizontalPadding,
    required this.tabToContent,
    required this.groupFooterToLabel,
  });

  @override
  AppSpacingTokens copyWith({
    double? labelToCard,
    double? cardToLabel,
    double? fieldToField,
    double? cardToCard,
    double? cardVerticalPadding,
    double? cardHorizontalPadding,
    double? tabToContent,
    double? groupFooterToLabel,
  }) {
    return AppSpacingTokens(
      labelToCard: labelToCard ?? this.labelToCard,
      cardToLabel: cardToLabel ?? this.cardToLabel,
      fieldToField: fieldToField ?? this.fieldToField,
      cardToCard: cardToCard ?? this.cardToCard,
      cardVerticalPadding: cardVerticalPadding ?? this.cardVerticalPadding,
      cardHorizontalPadding: cardHorizontalPadding ?? this.cardHorizontalPadding,
      tabToContent: tabToContent ?? this.tabToContent,
      groupFooterToLabel: groupFooterToLabel ?? this.groupFooterToLabel,
    );
  }

  @override
  AppSpacingTokens lerp(ThemeExtension<AppSpacingTokens>? other, double t) {
    if (other is! AppSpacingTokens) return this;
    final otherTokens = other;
    
    return AppSpacingTokens(
      labelToCard: lerpDouble(labelToCard, otherTokens.labelToCard, t) ?? labelToCard,
      cardToLabel: lerpDouble(cardToLabel, otherTokens.cardToLabel, t) ?? cardToLabel,
      fieldToField: lerpDouble(fieldToField, otherTokens.fieldToField, t) ?? fieldToField,
      cardToCard: lerpDouble(cardToCard, otherTokens.cardToCard, t) ?? cardToCard,
      cardVerticalPadding: lerpDouble(cardVerticalPadding, otherTokens.cardVerticalPadding, t) ?? cardVerticalPadding,
      cardHorizontalPadding: lerpDouble(cardHorizontalPadding, otherTokens.cardHorizontalPadding, t) ?? cardHorizontalPadding,
      tabToContent: lerpDouble(tabToContent, otherTokens.tabToContent, t) ?? tabToContent,
      groupFooterToLabel: lerpDouble(groupFooterToLabel, otherTokens.groupFooterToLabel, t) ?? groupFooterToLabel,
    );
  }
}
