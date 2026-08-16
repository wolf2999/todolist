// 非 Web 平台的空实现占位（原生平台不会调用这些分支，仅保证编译通过）。
Future<void> webDownloadFile(String url) async {}
Future<void> webOpenInNewTab(String url) async {}
Future<void> webDownloadBytes(List<int> bytes, String filename) async {}
Future<String> webShareOrCopy(String url) async => 'failed';
