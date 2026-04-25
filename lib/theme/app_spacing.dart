/// Fairway Design System v3.1 Spacing Scale (8pt grid)
class AppSpacing {
  // Radical Spacing Consolidation (v4.0) - 4 Tier Scale
  static const double atomic = 8.0;   // Internal element gaps
  static const double standard = 16.0; // Card / Page padding
  static const double large = 24.0;    // Enhanced Card Padding
  static const double section = 32.0;  // Section gaps
  static const double hero = 64.0;     // Large structural breaks

  // Legacy Mapping (Snapped to nearest tier)
  static const double xs = 4.0;  // Kept for micro-nudges
  static const double sm = atomic; 
  static const double md = atomic; 
  static const double lg = standard; 
  static const double xl = standard; 
  static const double x2l = standard; 
  static const double x3l = section; 
  static const double x4l = section; 
  static const double x5l = section; 
  static const double x6l = hero; 

  // Semantic Spacing Keys
  static const double pagePadding = standard;
  static const double cardPadding = standard;
  static const double elementGap = atomic;
  static const double sectionGap = section;
  static const double labelToCard = atomic;    // Close proximity to content (8.0)
  static const double cardToLabel = standard;   // Breathing room after a card (16.0)
  static const double tabToContent = standard;  // [Design 4.x] Spacing between Tabs and Content (16.0)
  static const double groupFooterToLabel = standard; // [Design 4.x] Spacing between footer pill and label (16.0)
  static const double sectionTitleTop = standard; // Spacing above title (16.0)
  static const double pageBottom = 120.0;
}
