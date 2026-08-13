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
