import "package:golf_society/design_system/design_system.dart";
class BoxyHoleSelector extends StatelessWidget {
  final int currentHole;
  final Map<int, int> scores;
  final ValueChanged<int> onHoleChanged;
  final double height;

  const BoxyHoleSelector({
    super.key,
    required this.currentHole,
    required this.scores,
    required this.onHoleChanged,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey, size: 28),
            onPressed: currentHole > 1 ? () => onHoleChanged(currentHole - 1) : null,
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 18,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                final holeNum = index + 1;
                final isSelected = holeNum == currentHole;
                final hasScore = scores.containsKey(holeNum);
                return _buildHoleItem(context, holeNum, isSelected, hasScore);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
            onPressed: currentHole < 18 ? () => onHoleChanged(currentHole + 1) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildHoleItem(BuildContext context, int holeNum, bool isSelected, bool hasScore) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onHoleChanged(holeNum),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$holeNum',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.white : (theme.brightness == Brightness.dark ? Colors.white : Colors.black87),
              ),
            ),
            if (hasScore)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
