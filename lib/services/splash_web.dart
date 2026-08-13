// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// Web 平台：首帧渲染后移除 index.html 中的 #loading 占位。
// 由 _Bootstrap 在 postFrameCallback 中调用，确保 splash 盖住字体/资源
// 加载等待期，避免手机白屏。
void removeHtmlSplash() {
  final el = html.document.getElementById('loading');
  el?.remove();
}
