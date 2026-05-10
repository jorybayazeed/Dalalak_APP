// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<bool> openExternalUrl(String url) async {
  final win = html.window.open(url, '_blank');
  if (win.closed == true) {
    final anchor = html.AnchorElement(href: url)
      ..target = '_blank'
      ..rel = 'noopener'
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
  }
  return true;
}
