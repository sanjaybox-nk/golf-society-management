String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String toSentenceCase(String text) {
  if (text.isEmpty) return text;
  final lower = text.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

String cleanGuestName(String name) {
  return name.replaceAll(RegExp(r'\((g|guest|G|Guest)\)'), '').trim();
}

String extractInitials(String name) {
  if (name.isEmpty) return '?';
  final cleanName = cleanGuestName(name);
  final parts = cleanName.split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0][0].toUpperCase();
  return (parts[0][0] + parts.last[0]).toUpperCase();
}
