# 待办清单 To Do List

一个使用 Flutter 构建的待办事项（Todo List）应用，基于 *Rudi Hartono* 的设计稿改造而来，原稿可在 [Uplabs](https://www.uplabs.com/posts/to-do-list-app-freebie-kit) 查看。

本项目在原静态 UI 基础上，使用 **最新版 Flutter** 重写为 **全平台** 支持，并采用 **MVC（Model-View-Controller）** 架构，新增本地持久化、任务新增、完成勾选、滑动删除等真实可用的功能。

## 平台支持

- Web（开发默认平台）
- Android / iOS
- macOS / Linux / Windows

## 项目结构（MVC）

```
lib/
├── main.dart                        # 入口：注入 Controller、注册路由
├── controllers/
│   └── task_controller.dart         # Controller：状态管理 + 本地持久化
├── models/
│   └── task.dart                    # Model：任务数据结构
├── utils/
│   ├── colors.dart                  # 颜色常量
│   └── date_helper.dart             # 日期格式化工具
└── views/                           # View：仅负责展示与转发用户操作
    ├── onboarding.dart              # 启动引导页
    ├── home.dart                    # 主页面
    └── widgets/
        ├── custom_app_bar.dart      # 顶部进度条与头像
        ├── bottom_nav.dart          # 底部导航
        ├── task_fab.dart            # 新增按钮
        ├── task_tile.dart           # 任务条目（含勾选 / 滑动删除）
        ├── task_bottom_sheet.dart   # 新增任务表单
        └── empty_state.dart         # 空状态提示
```

## 快速开始 🚀

```bash
# 1. 安装依赖
flutter pub get

# 2. 在 Web 上运行（默认开发平台）
flutter run -d chrome

# 3. 其他平台示例
flutter run -d macos
flutter run -d android
flutter run -d ios
```

## 技术栈

| 用途         | 依赖                          |
| ------------ | ----------------------------- |
| 状态管理     | `provider`                    |
| 本地持久化   | `shared_preferences`          |
| 日期格式化   | `intl`                        |
| 跨平台图标   | `cupertino_icons`             |

## 主要功能

- ✅ 任务新增（底部表单 + 日期选择）
- ✅ 任务勾选完成 / 取消完成
- ✅ 左滑删除任务
- ✅ 顶部进度条统计完成情况
- ✅ 数据本地持久化（关闭应用后任务仍保留）
- ✅ 全平台一致体验（Web / 桌面 / 移动端）

## 版本历史

| 版本 | 日期              | 说明                                                       |
| ---- | ----------------- | ---------------------------------------------------------- |
| 2.0  | 2026 / 08 / 09    | 基于最新 Flutter 重写，采用 MVC 架构，支持全平台，新增本地持久化 |
| 1.6  | 2021 / 05 / 19    | 迁移至 Flutter 2，新增子任务                                |
| 1.5  | 2019 / 12 / 10    | 构建由 production 改为 test                                 |
| 1.4  | 2019 / 09 / 26    | 在 Google Play 上架                                         |
| 1.3  | 2019 / 09 / 24    | 添加发布用 App 图标                                        |
| 1.2  | 2019 / 09 / 23    | 新增滑动删除                                                |
| 1.1  | 2019 / 09 / 16    | 状态栏设置为透明                                            |
| 1.0  | 2019 / 09         | 首次发布                                                    |

## 致谢

- UI 设计：[Rudi Hartono](https://www.uplabs.com/posts/to-do-list-app-freebie-kit)
- 原项目：参考 `../Flutter-Todolist` 目录下的 Flutter 项目

## 贡献

欢迎提交 Issue、Pull Request 或功能建议。