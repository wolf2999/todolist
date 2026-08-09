import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';

/// Bottom navigation bar (UI1: 首页 / 分类 / 设置).
class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(0, Icons.home_outlined, Icons.home, 'navHome'.tr()),
          _item(1, Icons.category_outlined, Icons.category, 'navCategory'.tr()),
          _item(2, Icons.settings_outlined, Icons.settings, 'setting'.tr()),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData activeIcon, String label) {
    final active = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                active ? activeIcon : icon,
                color: active ? ToDoColors.primary : ToDoColors.textGrey,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? ToDoColors.primary : ToDoColors.textGrey,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
