import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

import '../../models/constants.dart';
import '../../utils/colors.dart';

/// Blue gradient header shown on the home screen (UI1 1:1 还原).
/// Shows the title, a short subtitle, the completion stats, and a settings
/// action button on the right.
class AppHeader extends StatelessWidget {
  final int total;
  final int done;
  final int remaining;
  final VoidCallback onSettings;

  const AppHeader({
    super.key,
    required this.total,
    required this.done,
    required this.remaining,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ToDoColors.primary, ToDoColors.primaryDark],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'todayTasks'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'todaySubtitle'.tr(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 下载入口：仅 Web / 桌面端可见（移动端本身就在 App 内，无需下载）
                  if (kIsWeb ||
                      defaultTargetPlatform == TargetPlatform.linux ||
                      defaultTargetPlatform == TargetPlatform.windows ||
                      defaultTargetPlatform == TargetPlatform.macOS)
                    _DownloadButton(),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onSettings,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _StatChip(label: 'all'.tr(), value: total),
              const SizedBox(width: 10),
              _StatChip(label: 'completed'.tr(), value: done),
              const SizedBox(width: 10),
              _StatChip(label: 'pending'.tr(), value: remaining),
            ],
          ),
        ],
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.download_outlined, color: Colors.white, size: 22),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('downloadPackages'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            _DownloadItem(
              icon: Icons.android,
              label: 'downloadApk'.tr(),
              subtitle: 'releaseApkSub'.tr(),
              url: DownloadLinks.apkUrl,
            ),
            _DownloadItem(
              icon: Icons.desktop_windows_outlined,
              label: 'downloadWindows'.tr(),
              subtitle: DownloadLinks.windowsReady
                  ? 'windowsPkgSub'.tr()
                  : 'comingSoon'.tr(),
              url: DownloadLinks.windowsExeUrl,
              enabled: DownloadLinks.windowsReady,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DownloadItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final String url;
  final bool enabled;

  const _DownloadItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.url,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: enabled ? ToDoColors.primary : Colors.grey),
      title: Text(label,
          style: TextStyle(color: enabled ? null : Colors.grey)),
      subtitle: Text(subtitle),
      trailing: enabled
          ? const Icon(Icons.open_in_new, size: 18)
          : const Icon(Icons.hourglass_empty, size: 18, color: Colors.grey),
      enabled: enabled,
      onTap: enabled
          ? () async {
              if (kIsWeb) {
                // Web：用原生 <a download> 强制触发下载，避免 url_launcher
                // 的 _self 跳转导致浏览器直接渲染二进制（看起来"没反应"）。
                // ignore: avoid_web_libraries_in_flutter
                final anchor = html.AnchorElement(href: url)
                  ..setAttribute('download', '')
                  ..target = '_blank';
                html.document.body?.append(anchor);
                anchor.click();
                anchor.remove();
              } else {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              }
              if (context.mounted) Navigator.pop(context);
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('comingSoon'.tr())),
              );
            },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
