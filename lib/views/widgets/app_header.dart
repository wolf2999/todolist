import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                children: const [
                  Text(
                    '今日待办',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '高效管理你的每一天',
                    style: TextStyle(
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
              _StatChip(label: '全部', value: total),
              const SizedBox(width: 10),
              _StatChip(label: '已完成', value: done),
              const SizedBox(width: 10),
              _StatChip(label: '未完成', value: remaining),
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('下载安装包',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            _DownloadItem(
              icon: Icons.android,
              label: 'Android APK',
              subtitle: 'release 安装包',
              url: DownloadLinks.apkUrl,
            ),
            _DownloadItem(
              icon: Icons.desktop_windows_outlined,
              label: 'Windows EXE',
              subtitle: DownloadLinks.windowsReady
                  ? 'Windows 安装包'
                  : '即将推出',
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
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, webOnlyWindowName: '_self');
              }
              if (context.mounted) Navigator.pop(context);
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Windows 版本即将推出')),
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
