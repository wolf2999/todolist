import 'package:url_launcher/url_launcher.dart';

// 非 Web 平台的空实现占位（原生平台不会调用这些分支，仅保证编译通过）。
Future<void> webDownloadFile(String url) async {}
Future<void> webOpenInNewTab(String url) async {}
Future<void> webDownloadBytes(List<int> bytes, String filename) async {}
Future<String> webShareOrCopy(String url) async => 'failed';

// 原生平台：用 url_launcher 调用系统浏览器打开外部链接（如留言板页面）。
// 留言板等页面是 Web 托管，原生 App 无法直接渲染，必须跳系统浏览器。
Future<void> launchExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('无法打开链接: $url');
  }
}
