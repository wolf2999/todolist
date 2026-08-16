// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// 用原生 <a download> 触发下载（强制下载而非浏览器渲染二进制）。
Future<void> webDownloadFile(String url) async {
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', '')
    ..target = '_blank';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

// 新标签页打开链接。
Future<void> webOpenInNewTab(String url) async {
  html.window.open(url, '_blank');
}

// 将字节数据作为文件下载（导出备份 JSON）。
Future<void> webDownloadBytes(List<int> bytes, String filename) async {
  final blob = html.Blob(<Object>[bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..target = '_blank';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

// Web 端分享：优先调用原生 navigator.share，不支持则回退到复制链接到剪贴板。
// 返回 'shared'（已调用系统分享面板）或 'copied'（已复制到剪贴板）或 'failed'。
Future<String> webShareOrCopy(String url) async {
  // 通过 dynamic 绕过 dart:html 的类型限制，运行时再探测 navigator.share 是否存在。
  final navigator = html.window.navigator as dynamic;
  if (navigator.share != null) {
    try {
      await navigator.share(
          'To-Do List', 'A clean, cross-platform todo app', url);
      return 'shared';
    } catch (_) {
      // 用户取消或不支持 -> 继续复制逻辑
    }
  }
  final clipboard = html.window.navigator.clipboard;
  if (clipboard != null) {
    await clipboard.writeText(url);
    return 'copied';
  }
  return 'failed';
}
