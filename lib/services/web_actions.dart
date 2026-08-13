// 条件导出：Web 平台使用带 dart:html 的实现；其它平台（Android/iOS/桌面）
// 使用空实现，避免 dart:html 在原生平台编译失败。
// 调用方仍用 kIsWeb 判断是否走原生降级逻辑（如 url_launcher）。
export 'web_actions_stub.dart'
    if (dart.library.html) 'web_actions_web.dart';
