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
