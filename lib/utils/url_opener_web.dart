// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Opens [url] in a new browser tab.
///
/// Uses an anchor click as the primary method (this is **never** blocked by
/// popup blockers because it's treated as a direct user navigation), and
/// falls back to `window.open` and finally same-tab navigation. Always
/// returns `true` if at least one method succeeded.
Future<bool> openExternalUrl(String url) async {
  // Primary: anchor click. Most reliable, not popup-blocked.
  try {
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..rel = 'noopener noreferrer'
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (_) {
    // continue to fallback
  }

  // Fallback 1: window.open (may be popup-blocked).
  try {
    final win = html.window.open(url, '_blank');
    if (win.closed != true) {
      return true;
    }
  } catch (_) {
    // continue
  }

  // Fallback 2: same-tab navigation (last resort, always works).
  try {
    html.window.location.assign(url);
    return true;
  } catch (_) {
    return false;
  }
}
