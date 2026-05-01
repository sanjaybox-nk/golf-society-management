import 'package:golf_society/design_system/design_system.dart';

class BoxyArtHandicapTrend extends StatelessWidget {
  final List<double> history;
  final double height;

  const BoxyArtHandicapTrend({
    super.key,
    required this.history,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HANDICAP TREND',
              style: AppTypography.micro.copyWith(
                fontWeight: AppTypography.weightBold,
                letterSpacing: 1.0,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: AppColors.opacityHigh),
              ),
            ),
            if (history.length > 1)
              Text(
                _getTrendLabel(),
                style: AppTypography.micro.copyWith(
                  color: _getTrendColor(),
                  fontWeight: AppTypography.weightHeavy,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(
            painter: _SparklinePainter(
              data: history,
              lineColor: primary,
              fillColor: primary.withValues(alpha: 0.1),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${history.first.toStringAsFixed(1)} ST',
              style: AppTypography.micro.copyWith(color: AppColors.dark400),
            ),
            Text(
              'NOW: ${history.last.toStringAsFixed(1)}',
              style: AppTypography.micro.copyWith(
                color: isDark ? AppColors.pureWhite : AppColors.dark500,
                fontWeight: AppTypography.weightBold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getTrendLabel() {
    final diff = history.last - history.first;
    if (diff == 0) return 'STABLE';
    if (diff < 0) return 'DOWN ${diff.abs().toStringAsFixed(1)}';
    return 'UP ${diff.toStringAsFixed(1)}';
  }

  Color _getTrendColor() {
    final diff = history.last - history.first;
    if (diff < 0) return AppColors.lime500;
    if (diff > 0) return AppColors.coral500;
    return AppColors.dark400;
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final Color fillColor;

  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    
    // Add some padding to the range
    final displayMin = minVal - (range * 0.2);
    final displayMax = maxVal + (range * 0.2);
    final displayRange = displayMax - displayMin;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] - displayMin) / displayRange * size.height);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == data.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
