// 条件导出：Web 平台使用带 dart:html 的实现移除 index.html 的 splash；
// 其它平台（Android/iOS/桌面）使用空实现，避免 dart:html 在原生平台编译失败。
export 'splash_stub.dart'
    if (dart.library.html) 'splash_web.dart';
